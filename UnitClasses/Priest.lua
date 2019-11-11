
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
    local dmg, heal, channelTimeSec = string.match(self.description, "Launches a volley of holy light at the target, causing (%d[%d.,]*) Holy damage to an enemy or (%d[%d.,]*) healing to an ally over (%d[%d.,]*) sec.")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)
    local channelTimeMs = PHD:StrToNumber(channelTimeSec) * 1000

    return {
        dmg = PHD:StrToNumber(dmg),
        heal = heal,
        hps = self:GetValPerSecond(heal, channelTimeMs),
        hpsc = self:GetValPerSecondAccountForCooldown(heal, channelTimeMs)
    }
end

local PowerWordShield = PHD.Spell:NewWithId(17)
function PowerWordShield:Compute()
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

local LuminousBarrier = PHD.Spell:NewWithId(271466)
function LuminousBarrier:Compute()
    local absorb = string.match(self.description, "absorbing (%d[%d.,]*) damage on each of them")
    if absorb == nil then
        return
    end

    absorb = PHD:StrToNumber(absorb)

    return {
        absorb = absorb,
        hps = self:GetValPerSecond(absorb),
        hpsc = self:GetValPerSecondAccountForCooldown(absorb),
        hpm = self:GetValPerMana(absorb),
        aoeHps = self:GetValPerSecond(absorb * PHD.AOE_AVERAGE_TARGETS),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(absorb * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(absorb * PHD.AOE_AVERAGE_TARGETS)
    }
end

local PowerWordRadiance = PHD.Spell:NewWithId(194509)
function PowerWordRadiance:Compute()
    local heal = string.match(self.description, "injured allies within 30 yards for (%d[%d.,]*)")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)

    return {
        heal = heal,
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local PowerWordSolace = PHD.Spell:NewWithId(129250)
function PowerWordSolace:Compute()
    local dmg = string.match(self.description, "with heavenly power, dealing (%d[%d.,]*) Holy damage")
    if dmg == nil then
        return
    end

    return { dmg = PHD:StrToNumber(dmg) }
end

local Smite = PHD.Spell:NewWithId(585)
function Smite:Compute()
    local dmg = string.match(self.description, "Smites an enemy for (%d[%d.,]*) Holy damage")
    if dmg == nil then
        return
    end

    return { dmg = PHD:StrToNumber(dmg) }
end

local Schism = PHD.Spell:NewWithId(214621)
function Schism:Compute()
    local dmg = string.match(self.description, "surge of Shadow energy, dealing (%d[%d.,]*) Shadow damage")
    if dmg == nil then
        return
    end

    return { dmg = PHD:StrToNumber(dmg) }
end

local PurgeTheWicked = PHD.Spell:NewWithId(204197)
function PurgeTheWicked:Compute()
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
        dpsc = self:GetValPerSecondAccountForCooldown(dmg, duration)
    }
end

local HolyNova = PHD.Spell:NewWithId(132157)
function HolyNova:Compute()
    local dmg, heal = string.match(self.description, "dealing (%d[%d.,]*) Holy damage to all enemies and (%d[%d.,]*) healing")
    if dmg == nil or heal == nil then
        return
    end

    dmg = PHD:StrToNumber(dmg)
    heal = PHD:StrToNumber(heal)

    return {
        dmg = dmg,
        aoeDps = self:GetValPerSecond(dmg * PHD.AOE_AVERAGE_TARGETS),
        aoeDpm = self:GetValPerMana(dmg * PHD.AOE_AVERAGE_TARGETS),
        heal = heal,
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local Halo = PHD.Spell:NewWithId(120517)
function Halo:Compute()
    local heal, dmg = string.match(self.description, "healing allies for (%d[%d.,]*) and dealing (%d[%d.,]*) Holy damage")
    if heal == nil or dmg == nil then
        return
    end

    dmg = PHD:StrToNumber(dmg)
    heal = PHD:StrToNumber(heal)

    return {
        dmg = dmg,
        aoeDps = self:GetValPerSecond(dmg * PHD.AOE_AVERAGE_TARGETS),
        aoeDpsc = self:GetValPerSecondAccountForCooldown(dmg * PHD.AOE_AVERAGE_TARGETS),
        aoeDpm = self:GetValPerMana(dmg * PHD.AOE_AVERAGE_TARGETS),
        heal = heal,
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local DivineStar = PHD.Spell:NewWithId(110744)
function DivineStar:Compute()
    local heal, dmg = string.match(self.description, "healing allies in its path for (%d[%d.,]*) and dealing (%d[%d.,]*) Holy damage")
    if heal == nil or dmg == nil then
        return
    end

    dmg = PHD:StrToNumber(dmg) * 2
    heal = PHD:StrToNumber(heal) * 2

    return {
        dmg = dmg,
        aoeDps = self:GetValPerSecond(dmg * PHD.AOE_AVERAGE_TARGETS),
        aoeDpsc = self:GetValPerSecondAccountForCooldown(dmg * PHD.AOE_AVERAGE_TARGETS),
        aoeDpm = self:GetValPerMana(dmg * PHD.AOE_AVERAGE_TARGETS),
        heal = heal,
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local Heal = PHD.Spell:NewWithId(2060)
function Heal:Compute()
    local heal = string.match(self.description, "An efficient spell that heals an ally for (%d[%d.,]*).")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local FlashHeal = PHD.Spell:NewWithId(2061)
function FlashHeal:Compute()
    local heal = string.match(self.description, "A fast spell that heals an ally for (%d[%d.,]*).")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local HolyWordSerenity = PHD.Spell:NewWithId(2050)
function HolyWordSerenity:Compute()
    local heal = string.match(self.description, "Perform a miracle, healing an ally for (%d[%d.,]*).")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local PrayerOfMending = PHD.Spell:NewWithId(33076)
function PrayerOfMending:Compute()
    local heal = string.match(self.description, "that heals them for (%d[%d.,]*)")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)

    return {
        heal = heal,
        hps = PHD.IGNORE_STAT,
        hpsc = PHD.IGNORE_STAT,
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local HolyWordSanctify = PHD.Spell:NewWithId(34861)
function HolyWordSanctify:Compute()
    local range, heal = string.match(self.description, "within (%d+) yds for (%d[%d.,]*)")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)

    return {
        heal = heal,
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local PrayerOfHealing = PHD.Spell:NewWithId(596)
function PrayerOfHealing:Compute()
    local count, range, heal = string.match(self.description, "A powerful prayer that heals the target and the (%d+) nearest allies within (%d+) yards for (%d[%d.,]*)")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)

    return {
        heal = heal,
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local DivineHymn = PHD.Spell:NewWithId(64843)
function DivineHymn:Compute()
    local range, heal, channelTimeSec = string.match(self.description, "Heals all party or raid members within (%d+) yards for (%d[%d.,]*) over (%d[%d.,]*) sec")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal) * 2
    local channelTimeMs = PHD:StrToNumber(channelTimeSec) * 1000

    return {
        heal = heal,
        hps = self:GetValPerSecond(heal, channelTimeMs),
        hpsc = self:GetValPerSecondAccountForCooldown(heal, channelTimeMs),
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS, channelTimeMs),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(heal * PHD.AOE_AVERAGE_TARGETS, channelTimeMs),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local HolyWordSalvation = PHD.Spell:NewWithId(265202)
function HolyWordSalvation:Compute()
    local range, heal = string.match(self.description, "Heals all allies within (%d+) yards for (%d[%d.,]*)")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)

    -- TODO: add stats for the Renew and PoM stacks as well? ...how?
    return {
        heal = heal,
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local CircleOfHealing = PHD.Spell:NewWithId(204883)
function CircleOfHealing:Compute()
    local count, range, heal = string.match(self.description, "Heals the target and (%d+) injured allies within (%d+) yards of the target for (%d[%d.,]*)")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)

    return {
        heal = heal,
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local BindingHeal = PHD.Spell:NewWithId(32546)
function BindingHeal:Compute()
    local range, heal = string.match(self.description, "Heals you, your target, and another friendly target within (%d+) yards for (%d[%d.,]*)")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)
    local count = 3

    return {
        heal = heal,
        aoeHps = self:GetValPerSecond(heal * count),
        aoeHpm = self:GetValPerMana(heal * count)
    }
end

local Renew = PHD.Spell:NewWithId(139)
function Renew:Compute()
    local initialHeal, healOverTime, durationSec = string.match(self.description, "healing them instantly for (%d[%d.,]*) and then (%d[%d.,]*) over (%d+) sec")
    if initialHeal == nil or healOverTime == nil then
        return
    end

    local direct = PHD:StrToNumber(initialHeal)
    local hot = PHD:StrToNumber(healOverTime)
    heal = direct + hot
    local durationMs = PHD:StrToNumber(durationSec) * 1000

    return {
        heal = heal,
        hot = hot,
        hps = self:GetValPerSecond(heal, durationMs),
        hpsc = PHD.IGNORE_STAT
    }
end
