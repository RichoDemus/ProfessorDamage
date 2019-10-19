
local FlashOfLight = PHD.Spell:NewWithId(19750)
function FlashOfLight:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal = string.match(self.description, "Expends a large amount of mana to quickly heal a friendly target for (%d[%d.,]*).")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local HolyLight = PHD.Spell:NewWithId(82326)
function HolyLight:Compute()
    local heal = string.match(self.description, "An efficient spell, healing a friendly target for (%d[%d.,]*).")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local HolyShock = PHD.Spell:NewWithId(20473)
function HolyShock:Compute()
    local dmg, heal = string.match(self.description, "Triggers a burst of Light on the target, dealing (%d[%d.,]*) Holy damage to an enemy, or (%d[%d.,]*) healing to an ally.")
    if dmg == nil or heal == nil then
        return
    end

    return {
        dmg = PHD:StrToNumber(dmg),
        heal = PHD:StrToNumber(heal)
    }
end

local LightOfDawn = PHD.Spell:NewWithId(85222)
function LightOfDawn:Compute()
    local heal = string.match(self.description, "Unleashes a wave of holy energy, healing up to 5 injured allies within a 15 yd frontal cone for (%d[%d.,]*).")
    if heal == nil then
        return
    end

    local heal = PHD:StrToNumber(heal)

    return {
        heal = heal,
        aoeHpm = self:GetValPerMana(heal)
    }
end

local LightOfTheMartyr = PHD.Spell:NewWithId(183998)
function LightOfTheMartyr:Compute()
    local heal = string.match(self.description, "Sacrifice a portion of your own health to instantly heal an ally for (%d[%d.,]*).")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local BestowFaith = PHD.Spell:NewWithId(223306)
function BestowFaith:Compute()
    local heal = string.match(self.description, "Begin mending the wounds of a friendly target, healing them for (%d[%d.,]*) after 5 sec.")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local HolyPrism = PHD.Spell:NewWithId(114165)
function HolyPrism:Compute()
    local offensiveDmg, offensiveHeal = string.match(self.description, "If the beam is aimed at an enemy target, it deals (%d[%d.,]*) Holy damage and radiates (%d[%d.,]*) healing")
    if offensiveDmg == nil then
        return
    end

    local defensiveHeal, defensiveDmg = string.match(self.description, "If the beam is aimed at a friendly target, it heals for (%d[%d.,]*) and radiates (%d[%d.,]*) Holy damage")
    if defensiveHeal == nil then
        return
    end

    local defDmg = PHD:StrToNumber(defensiveDmg)
    local offHeal = PHD:StrToNumber(offensiveHeal)

    return {
        dmg = PHD:StrToNumber(offensiveDmg),
        aoeDpm = self:GetValPerMana(defDmg),

        heal = PHD:StrToNumber(defensiveHeal),
        aoeHpm = self:GetValPerMana(offHeal)
    }
end
