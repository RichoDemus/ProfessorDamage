-- todo remove, I'm 95% sure it wouldn't break the addon
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(f, event)
    if event == "PLAYER_LOGIN" then
        local _, englishClass = UnitClass("player")
        print("Hello, world,", englishClass)
    end
end)

-- This is run on item/spell/talent mouseover and once every 0.5s during mouseover
function OnTooltipSpell(self)
    local _, spellId = self:GetSpell();

    local desc = GetSpellDescription(spellId);
    local damageOrHealing = parseDescription(spellId, desc);

    if damageOrHealing == nil then
        GameTooltip:AddLine(string.format("Spell id: %i", spellId), 1, 1, 1, true);
        GameTooltip:Show();
        return
    end

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

function parseDescription(spellId, description)
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
    return nil;
end

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

GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSpell)

-- just a function to print a table, nice for debugging
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function toNumber2(number)
    local withoutComma = string.gsub(number, ",", "");
    return tonumber(withoutComma);
end
