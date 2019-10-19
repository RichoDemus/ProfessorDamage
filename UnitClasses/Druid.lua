
local Rejuvenation = PHD.Spell:NewWithId(774)
function Rejuvenation:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal, duration = string.match(self.description, "Heals the target for (%d[%d.,]*) over (%d+) sec.")
    if heal == nil then
        return
    end

    return {
        heal = PHD:StrToNumber(heal),
        duration = duration
    }
end

local Regrowth = PHD.Spell:NewWithId(8936)
function Regrowth:Compute()
    local initialHeal, healOverTime, duration = string.match(self.description, "Heals a friendly target for (%d[%d.,]*) and another (%d[%d.,]*) over (%d+) sec.")
    if initialHeal == nil or healOverTime == nil then
        return
    end

    local direct = PHD:StrToNumber(initialHeal)
    local hot = PHD:StrToNumber(healOverTime)
    return {
        heal = direct + hot,
        hot = hot,
        duration = duration
    }
end

local Lifebloom = PHD.Spell:NewWithId(33763)
function Lifebloom:Compute()
    local healOverTime, duration, bloomHeal = string.match(self.description, "Heals the target for (%d[%d.,]*) over (%d+) sec. When Lifebloom expires or is dispelled, the target is instantly healed for (%d[%d.,]*). Limit 1.")
    if bloomHeal == nil or healOverTime == nil then
        return
    end

    local bloom = PHD:StrToNumber(bloomHeal)
    local hot = PHD:StrToNumber(healOverTime)
    return {
        heal = bloom + hot,
        hot = hot,
        postHeal = bloom,
        duration = duration
    }
end

local Swiftmend = PHD.Spell:NewWithId(18562)
function Swiftmend:Compute()
    local heal = string.match(self.description, "Instantly heals a friendly target for (%d[%d.,]*).")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local Nourish = PHD.Spell:NewWithId(289022)
function Nourish:Compute()
    local heal = string.match(self.description, "Heals a friendly target for (%d[%d.,]*) and automatically applies one of your missing healing over time spells to the target. If all of them are present, Nourish critically heals.")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local WildGrowth = PHD.Spell:NewWithId(48438)
function WildGrowth:Compute()
    local heal, duration = string.match(self.description, "Heals up to 6 injured allies within 30 yards of the target for (%d[%d.,]*) over (%d+) sec. Healing starts high and declines over the duration.")
    if heal == nil then
        return
    end

    local heal = PHD:StrToNumber(heal)

    return {
        heal = heal,
        aoeHpm = self:GetValPerMana(heal),
        duration = duration
    }
end

local SolarWrath = PHD.Spell:NewWithId(5176)
function SolarWrath:Compute()
    local dmg = string.match(self.description, "Causes (%d[%d.,]*) Nature damage to the target.")
    if dmg == nil then
        return
    end

    local dmg = PHD:StrToNumber(dmg)

    return {
        dmg = dmg
    }
end
