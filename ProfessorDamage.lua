-- todo remove, I'm 95% sure it wouldn't break the addon
-- local f = CreateFrame("Frame")
-- f:RegisterEvent("PLAYER_LOGIN")
-- f:SetScript("OnEvent", function(f, event)
--     if event == "PLAYER_LOGIN" then
--         local _, englishClass = UnitClass("player")
--         print("Hello, world,", englishClass)
--     end
-- end)

PHD = {}
PHD.Spell = { descriptionMatcher = "" }
PHD.Spell.Implementations = {}

-- This is run on item/spell/talent mouseover and once every 0.5s during mouseover
function OnTooltipSetSpell(self)
    local _, spellId = self:GetSpell()

    local spell = PHD:GetSpellFromId(spellId)

    if spell == nil then
        PHD:AddTooltipLine("Spell id: %i", spellId)
        GameTooltip:Show()
        return
    end

    --local damageOrHealing = spell:GetDmgOrHealing()
    --local name, rank, icon, castTime, minRange, maxRange, _ = GetSpellInfo(spellId)

    --print(string.format("spell id: %i",spellId));
    --print(string.format("desc: %s",desc));
    --print(string.format("cast: %s",castTime));

    --local manaCost = PHD:GetManaCost(spellId)
    --print(string.format("cost: %s",manaCost));

    --print(string.format("healing: %s",damageOrHealing));
    --local hpm = damageOrHealing / manaCost;

    local stats = spell:RunComputations()

    if stats.heal then PHD:AddTooltipLine("Healing: %i", stats.heal) end
    if stats.dmg then PHD:AddTooltipLine("Damage: %i", stats.dmg) end

    PHD:AddTooltipLine("Mana Cost: %i", stats.manaCost)

    if stats.hpm then PHD:AddTooltipLine("HPM: %6.1f", stats.hpm) end
    if stats.dpm then PHD:AddTooltipLine("DPM: %6.1f", stats.dpm) end

    GameTooltip:Show()
end

GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)

function PHD:GetSpellFromId(spellId)
    local spell = PHD.Spell.Implementations[spellId]
    if spell then
        return spell
    end
    return nil
end

function PHD:GetManaCost(spellId)
    -- returns a collection of mana costs since different spells use different resources
    local costs = GetSpellPowerCost(spellId);
    --print(string.format("costs: %s",dump(costs)));

    -- I think [1] is always mana
    local manaCost = costs[1].cost;
    --print(string.format("cost: %s",manaCost));
    return manaCost;
end

function PHD:AddTooltipLine(formatString, value)
    GameTooltip:AddLine(string.format(formatString, value), 1, 1, 1, true)
end

function PHD:StrToNumber(str)
    local withoutComma = string.gsub(str, ",", "");
    return tonumber(withoutComma);
end



-- "instantiate" a new spell object
function PHD.Spell:NewWithId(spellId, spellParser)
    local definition = {}
    setmetatable(definition, self)
    self.__index = self
    PHD.Spell.Implementations[spellId] = definition

    local description = GetSpellDescription(spellId)
    local name, rank, icon, castTime, minRange, maxRange, _ = GetSpellInfo(spellId)
    local manaCost = PHD:GetManaCost(spellId)

    definition.spellId = spellId
    definition.spellParser = spellParser
    definition.description = description
    definition.manaCost = manaCost

    return definition
end

-- default/fallback implementation for computations
function PHD.Spell:Compute()
    self:ReturnValues {}
end

function PHD.Spell:GetValPerMinute(val)
    return val / self.manaCost
end

function PHD.Spell:ReturnValues(result)
    self.result = result
end

function PHD.Spell:RunComputations()
    self.result = {}
    self:Compute()
    local result = self.result

    result.manaCost = self.manaCost

    if result.heal then
        result.hpm = self:GetValPerMinute(result.heal)
    end

    if result.dmg then
        result.dpm = self:GetValPerMinute(result.dmg)
    end

    return result
end



-- just a function to print a table, nice for debugging
function dump(definition)
    if type(definition) == 'table' then
        local s = '{ '
        for k, v in pairs(definition) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(definition)
    end
end
