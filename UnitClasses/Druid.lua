
local Rejuvenation = PHD.Spell:NewWithId(774)
function Rejuvenation:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal, duration = string.match(description, "Heals the target for (%d[%d.,]*) over (%d+) sec.")
    if heal == nil then
        return
    end

    self:ReturnValues { heal = PHD:StrToNumber(heal) }
end

local Regrowth = PHD.Spell:NewWithId(8936)
function Regrowth:Compute()
    local initialHeal, healOverTime, duration = string.match(description, "Heals a friendly target for (%d[%d.,]*) and another (%d[%d.,]*) over (%d+) sec.")
    if initialHeal == nil or healOverTime == nil then
        return
    end

    local direct = PHD:StrToNumber(initialHeal)
    local hot = PHD:StrToNumber(healOverTime)
    self:ReturnValues {
        heal = direct + hot,
        hot = hot
    }
end

local Lifebloom = PHD.Spell:NewWithId(33763)
function Lifebloom:Compute()
    local healOverTime, duration, bloomHeal = string.match(description, "Heals the target for (%d[%d.,]*) over (%d+) sec. When Lifebloom expires or is dispelled, the target is instantly healed for (%d[%d.,]*). Limit 1.")
    if bloomHeal == nil or healOverTime == nil then
        return
    end

    local bloom = PHD:StrToNumber(bloomHeal)
    local hot = PHD:StrToNumber(healOverTime)
    self:ReturnValues {
        heal = bloom + hot,
        hot = hot,
        postHeal = bloom
    }
end

local Swiftmend = PHD.Spell:NewWithId(18562)
function Swiftmend:Compute()
    local heal = string.match(description, "Instantly heals a friendly target for (%d[%d.,]*).")
    if heal == nil then
        return
    end

    self:ReturnValues { heal = PHD:StrToNumber(heal) }
end
