
-- Professor H. Damage at your service! (it's french, probably)
PHD = {}
PHD.Spell = { descriptionMatcher = "" }
PHD.Spell.Implementations = {}

-- This is run on item/spell/talent mouseover and once every 0.5s during mouseover
function OnTooltipSetSpell(self)
    local _, spellId = self:GetSpell()

    local spell = PHD:GetSpellFromId(spellId)

    -- not a spell the jedi would tell you about?
    if spell == nil then
        PHD:AddTooltipLine("Spell id: %i", spellId)
        GameTooltip:Show()
        return
    end

    -- run calculations specific for this particular spell
    local stats = spell:RunComputations()

    -- add relevant info to the tooltip about to be shown
    PHD:AddTooltipLine("Mana Cost: %i", stats.manaCost)

    if stats.dmg then PHD:AddTooltipLine("Damage: %i", stats.dmg) end
    if stats.dps then PHD:AddTooltipLine("DPS: %i", stats.dps) end
    if stats.dpm then PHD:AddTooltipLine("DpM: %6.1f", stats.dpm) end
    if stats.aoeDpm then PHD:AddTooltipLine("AoE (3p) DpM: %6.1f", stats.aoeDpm) end

    if stats.heal then PHD:AddTooltipLine("Healing: %i", stats.heal) end
    if stats.hps then PHD:AddTooltipLine("HPS: %i", stats.heal) end
    if stats.hpm then PHD:AddTooltipLine("HpM: %6.1f", stats.hpm) end
    if stats.hot then PHD:AddTooltipLine("HoT: %i", stats.hot) end
    if stats.postHeal then PHD:AddTooltipLine("Post Heal: %i", stats.postHeal) end
    if stats.aoeHpm then PHD:AddTooltipLine("AoE (3p) HpM: %6.1f", stats.aoeHpm) end

    GameTooltip:Show()
end

GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)

-- ask the professor for a registered spell with a given id
function PHD:GetSpellFromId(spellId)
    local spell = PHD.Spell.Implementations[spellId]
    if spell then
        return spell
    end
    return nil
end

-- returns the mana cost of a given spell
function PHD:GetManaCost(spellId)
    -- returns a collection of mana costs since different spells use different resources
    local costs = GetSpellPowerCost(spellId)

    -- I think [1] is always mana
    local manaCost = costs[1].cost
    return manaCost
end

-- simplified way of adding text to the tooltip
function PHD:AddTooltipLine(formatString, ...)
    GameTooltip:AddLine(string.format(formatString, ...), 1, 1, 1, true)
end

-- parse a numerical representation in text with comma being the thousand separator
function PHD:StrToNumber(str)
    local withoutComma = string.gsub(str, ",", "");
    return tonumber(withoutComma);
end



-- "instantiate"/register a new spell object
function PHD.Spell:NewWithId(spellId)
    local definition = {}
    setmetatable(definition, self)
    self.__index = self
    PHD.Spell.Implementations[spellId] = definition

    definition.spellId = spellId

    return definition
end

-- default/fallback implementation for computations
function PHD.Spell:Compute()
    return {}
end

-- fetch current, updated statistics for a respective spell
function PHD.Spell:GetStats()
    local description = GetSpellDescription(self.spellId)
    local name, rank, icon, castTime, minRange, maxRange, _ = GetSpellInfo(self.spellId)
    local manaCost = PHD:GetManaCost(self.spellId)

    self.description = description
    self.manaCost = manaCost
    self.castTime = castTime
end

-- returns "x per mana" for some value
function PHD.Spell:GetValPerMana(val)
    return val / self.manaCost
end

-- triggers value computations to run for a given spell implementation and takes care of the result
function PHD.Spell:RunComputations()
    self:GetStats()

    local result = self:Compute()

    -- convert stuff to numbers if they are strings
    -- TODO: this doesn't seem to work... >_<
    for k, v in pairs(result) do
        if type(v) ~= 'string' then
            result[k] = PHD:StrToNumber(v)
        end
    end

    result.manaCost = self.manaCost

    if result.heal then
        result.hpm = self:GetValPerMana(result.heal)
        if result.duration then
            result.hps = self:GetValuePerSecond(result.heal, result.duration)
        else
            result.hps = self:GetValuePerSecond(result.heal, result.castTime)
        end
    end

    if result.dmg then
        result.dpm = self:GetValPerMana(result.dmg)
        if result.duration then
            result.dps = self:GetValuePerSecond(result.dmp, result.duration)
        else
            result.dps = self:GetValuePerSecond(result.dmp, result.castTime)
        end
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
