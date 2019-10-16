-- todo remove, I'm 95% sure it wouldn't break the addon
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(f, event)
    if event == "PLAYER_LOGIN" then
        local _, englishClass = UnitClass("player")
        print("Hello, world,", englishClass)
    end
end)

local Spell = { descriptionMatcher = "" }
Spell.implementations = {}

-- This is run on item/spell/talent mouseover and once every 0.5s during mouseover
function OnTooltipSpell(self)
    local _, spellId = self:GetSpell();

    local spell = Spell:FromId(spellId)

    if spell == nil then
        GameTooltip:AddLine(string.format("Spell id: %i", spellId), 1, 1, 1, true);
        GameTooltip:Show();
        return
    end

    local damageOrHealing = spell:GetDmgOrHealing()
    local name, rank, icon, castTime, minRange, maxRange, _ = GetSpellInfo(spellId)

    --print(string.format("spell id: %i",spellId));
    --print(string.format("desc: %s",desc));
    --print(string.format("cast: %s",castTime));

    local manaCost = GetManaCost(spellId)
    --print(string.format("cost: %s",manaCost));

    --print(string.format("healing: %s",damageOrHealing));
    local hpm = damageOrHealing / manaCost;

    GameTooltip:AddLine(string.format("Healing: %i", damageOrHealing), 1, 1, 1, true);
    GameTooltip:AddLine(string.format("Mana Cost: %i", manaCost), 1, 1, 1, true);
    GameTooltip:AddLine(string.format("HPM: %6.1f", hpm), 1, 1, 1, true);

    GameTooltip:Show();
end

function GetManaCost(spellId)
    -- returns a collection of mana costs since different spells use different resources
    local costs = GetSpellPowerCost(spellId);
    --print(string.format("costs: %s",dump(costs)));

    -- I think [1] is always mana
    local manaCost = costs[1].cost;
    --print(string.format("cost: %s",manaCost));
    return manaCost;
end



function Spell:define(spellId, definition)
    local definition = definition or {}
    setmetatable(definition, self)
    self.__index = self
    Spell.implementations[spellId] = definition

    definition.spellId = spellId
    return definition
end

function Spell:FromId(spellId)
    local spell = Spell.implementations[spellId]
    if spell then
        return spell
    end
    return nil
end

function Spell:GetDmgOrHealing()
    local description = GetSpellDescription(self.spellId)
    local heal, duration = string.match(description, self.descriptionMatcher)
    if heal == nil then
        print("heal is null")
        return -1
    end

    return toNumber2(heal)
end

local Rejuvenation = Spell:define(774, { descriptionMatcher = "Heals the target for (%d[%d.,]*) over (%d+) sec." })

local FlashOfLight = Spell:define(19750, { descriptionMatcher = "Expends a large amount of mana to quickly heal a friendly target for (%d[%d.,]*)." })
local HolyLight = Spell:define(82326, { descriptionMatcher = "An efficient spell, healing a friendly target for (%d[%d.,]*)." })
local HolyShock = Spell:define(20473, { descriptionMatcher = "Triggers a burst of Light on the target, dealing (%d[%d.,]*) ." })



function parseDescription(spellId, description)
    -- druid
    if spellId == 774 then
        return parseRejuvenation(description);
    end
    if spellId == 8936 then
        return parseRegrowth(description);
    end
    if spellId == 33763 then
        return parseLifebloom(description);
    end
    if spellId == 18562 then
        return parseSwiftmend(description);
    end

    -- paladin
    if spellId == 19750 then
        return parseFlashOfLight(description);
    end

    return nil;
end



-- druid

function parseRejuvenation(description)
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal, duration = string.match(description, "Heals the target for (%d[%d.,]*) over (%d+) sec.");
    if heal == nil then
        print("heal is null")
        return -1;
    end
    return toNumber2(heal);
end

function parseRegrowth(description)
    -- %d[%d.,]* is for handling , as the thousand separator
    local initialHeal, healOverTime, duration = string.match(description, "Heals a friendly target for (%d[%d.,]*) and another (%d[%d.,]*) over (%d+) sec.");
    if initialHeal == nil then
        print("heal is null")
        return -1;
    end
    return toNumber2(initialHeal) + toNumber2(healOverTime);
end

function parseLifebloom(description)
    -- %d[%d.,]* is for handling , as the thousand separator
    local healOverTime, duration, bloomHeal = string.match(description, "Heals the target for (%d[%d.,]*) over (%d+) sec. When Lifebloom expires or is dispelled, the target is instantly healed for (%d[%d.,]*). Limit 1.");
    if healOverTime == nil then
        print("heal is null")
        return -1;
    end
    return toNumber2(healOverTime) + toNumber2(bloomHeal);
end

function parseSwiftmend(description)
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal = string.match(description, "Instantly heals a friendly target for (%d[%d.,]*).");
    if heal == nil then
        print("heal is null")
        return -1;
    end
    return toNumber2(heal);
end



-- paladin

function parseFlashOfLight(description)
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal, duration = string.match(description, "Expends a large amount of mana to quickly heal a friendly target for (%d[%d.,]*).");
    if heal == nil then
        print("heal is null")
        return -1;
    end
    return toNumber2(heal);
end



GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSpell)

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

function toNumber2(number)
    local withoutComma = string.gsub(number, ",", "");
    return tonumber(withoutComma);
end
