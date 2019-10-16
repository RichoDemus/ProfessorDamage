
-- local Rejuvenation = Spell:NewWithId(774, { descriptionMatcher = "Heals the target for (%d[%d.,]*) over (%d+) sec." })

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
