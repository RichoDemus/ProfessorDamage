
local ShadowMend = PHD.Spell:NewWithId(186263)
function ShadowMend:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal = string.match(self.description, "Wraps an ally in shadows which heal for (%d[%d.,]*), but at a price.")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local Penance = PHD.Spell:NewWithId(47540)
function Penance:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local dmg, heal, channelTimeSec = string.match(self.description, "Launches a volley of holy light at the target, causing (%d[%d.,]*) Holy damage to an enemy or (%d[%d.,]*) healing to an ally over (%d[%d.,]*) sec.")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)
    channelTimeSec = PHD:StrToNumber(channelTimeSec) * 1000

    return {
        dmg = PHD:StrToNumber(dmg),
        heal = heal,
        hps = self:GetValPerSecond(heal, channelTimeSec),
        hpsc = self:GetValPerSecondAccountForCooldown(heal, channelTimeSec)
    }
end

local PowerWordShield = PHD.Spell:NewWithId(17)
function PowerWordShield:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local absorb, weakenedSoulDurationSec = string.match(self.description, "absorbing (%d[%d.,]*) damage.  You cannot shield the target again for (%d[%d.,]*) sec.")
    if absorb == nil or weakenedSoulDurationSec == nil then
        return
    end

    absorb = PHD:StrToNumber(absorb)
    weakenedSoulDurationSec = PHD:StrToNumber(weakenedSoulDurationSec) * 1000

    return {
        absorb = absorb,
        hps = self:GetValPerSecond(absorb),
        hpsc = self:GetValPerSecondAccountForCooldown(absorb, weakenedSoulDurationSec),
        hpm = self:GetValPerMana(absorb)
    }
end

local PowerWordRadiance = PHD.Spell:NewWithId(194509)
function PowerWordRadiance:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal = string.match(self.description, "injured allies within 30 yards for (%d[%d.,]*)")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)

    return {
        heal = heal,
        aoeHpm = self:GetValPerMana(heal * 3)
    }
end

local PowerWordSolace = PHD.Spell:NewWithId(129250)
function PowerWordSolace:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local dmg = string.match(self.description, "with heavenly power, dealing (%d[%d.,]*) Holy damage")
    if dmg == nil then
        return
    end

    return { dmg = PHD:StrToNumber(dmg) }
end

local Smite = PHD.Spell:NewWithId(585)
function Smite:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local dmg = string.match(self.description, "Smites an enemy for (%d[%d.,]*) Holy damage")
    if dmg == nil then
        return
    end

    return { dmg = PHD:StrToNumber(dmg) }
end

local Schism = PHD.Spell:NewWithId(214621)
function Schism:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local dmg = string.match(self.description, "surge of Shadow energy, dealing (%d[%d.,]*) Shadow damage")
    if dmg == nil then
        return
    end

    return { dmg = PHD:StrToNumber(dmg) }
end

local PurgeTheWicked = PHD.Spell:NewWithId(204197)
function PurgeTheWicked:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local direct, dot, duration = string.match(self.description, "causing (%d[%d.,]*) Fire damage and an additional (%d[%d.,]*) Fire damage over (%d+) sec.")
    if direct == nil or dot == nil or duration == nil then
        return
    end

    direct = PHD:StrToNumber(direct)
    dot = PHD:StrToNumber(dot)
    duration = PHD:StrToNumber(duration) * 1000
    dmg = direct + dot

    return {
        dmg = dmg,
        instantDmg = direct,
        dot = dot,
        dpsc = self:GetValPerSecondAccomodateForCooldown(dmg, duration)
    }
end
