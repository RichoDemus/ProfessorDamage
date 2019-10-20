
-- Professor H. Damage at your service! (it's french, probably)
PHD = {}
PHD.DEBUG = false
PHD.Spell = { descriptionMatcher = "" }
PHD.Spell.Implementations = {}

-- This is run on item/spell/talent mouseover and once every 0.5s during mouseover
local function OnTooltipSetSpell(self)
    local _, spellId = self:GetSpell()

    local spell = PHD:GetSpellFromId(spellId)

    -- not a spell the jedi would tell you about?
    if spell == nil then
        if PHD.DEBUG then
            PHD:AddTooltipLine("Spell id: %i", spellId)
        end
        
        GameTooltip:Show()
        return
    end

    -- run calculations specific for this particular spell
    local stats = spell:RunComputations()

    -- add relevant info to the tooltip about to be shown
    -- always start with a divider
    PHD.isAppropriateToShowDivider = true
    PHD:AddTooltipDivider()

    -- damage
    if stats.dmg then PHD:AddTooltipLine("Damage: %i", stats.dmg) end
    if stats.dps then PHD:AddTooltipLine("DpS: %i", stats.dps) end
    if stats.dpsc then PHD:AddTooltipLine("DpSC: %i", stats.dpsc) end
    if stats.dpm then PHD:AddTooltipLine("DpM: %1.1f", stats.dpm) end
    if stats.aoeDps then PHD:AddTooltipLine("AoE (3p) DpS: %i", stats.aoeDps) end
    if stats.aoeDpsc then PHD:AddTooltipLine("AoE (3p) DpSC: %i", stats.aoeDpsc) end
    if stats.aoeDpm then PHD:AddTooltipLine("AoE (3p) DpM: %1.1f", stats.aoeDpm) end

    if stats.hps or stats.hpm then
        PHD:AddTooltipDivider()
    end

    -- healing
    if stats.absorb then PHD:AddTooltipLine("Absorb: %i", stats.absorb) end
    if stats.heal then PHD:AddTooltipLine("Healing: %i", stats.heal) end
    if stats.hot then PHD:AddTooltipLine("HoT: %i", stats.hot) end
    if stats.postHeal then PHD:AddTooltipLine("Post Heal: %i", stats.postHeal) end
    if stats.hps then PHD:AddTooltipLine("HpS: %i", stats.hps) end
    if stats.hpsc then PHD:AddTooltipLine("HpSC: %i", stats.hpsc) end
    if stats.hpm then PHD:AddTooltipLine("HpM: %1.1f", stats.hpm) end
    if stats.aoeHps then PHD:AddTooltipLine("AoE (3p) HpS: %i", stats.aoeHps) end
    if stats.aoeHpsc then PHD:AddTooltipLine("AoE (3p) HpSC: %i", stats.aoeHpsc) end
    if stats.aoeHpm then PHD:AddTooltipLine("AoE (3p) HpM: %1.1f", stats.aoeHpm) end

    if PHD.DEBUG then
        PHD:AddTooltipDivider()
        PHD:AddTooltipLine("castTimeMs: %i", spell.castTimeMs)
        PHD:AddTooltipLine("cooldownMs: %i", spell.cooldownMs)
        PHD:AddTooltipLine("gcdMs: %i", spell.gcdMs)
        PHD:AddTooltipLine("maxCharges: %i", spell.maxCharges)
        PHD:AddTooltipLine("rechargeTimeMs: %i", spell.rechargeTimeMs)
    end

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

    if not costs[1] then
        return 0
    end

    -- I think [1] is always mana
    local manaCost = costs[1].cost
    return manaCost
end

-- add a "divider" of sorts to the tooltip, for some visual structure
-- but only add it if the previous line was not also a divider
function PHD:AddTooltipDivider()
    if PHD.isAppropriateToShowDivider then
        GameTooltip:AddLine("---", 1, 1, 1, true)
    end
    PHD.isAppropriateToShowDivider = false
end

-- simplified way of adding text to the tooltip
function PHD:AddTooltipLine(formatString, ...)
    GameTooltip:AddLine(string.format(formatString, ...), 1, 1, 1, true)
    PHD.isAppropriateToShowDivider = true
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
    local name, rank, icon, castTimeMs, minRange, maxRange, _ = GetSpellInfo(self.spellId)
    local cooldownMs, gcdMs = GetSpellBaseCooldown(self.spellId)
    local currentCharges, maxCharges, lastRechargeStart, rechargeTimeSec, _ = GetSpellCharges(self.spellId)
    local rechargeTimeMs = (rechargeTimeSec or 0) * 1000
    local manaCost = PHD:GetManaCost(self.spellId)

    self.description = description
    self.castTimeMs = castTimeMs or 0
    self.cooldownMs = cooldownMs or 0
    self.gcdMs = gcdMs or 0
    self.maxCharges = maxCharges or 0
    self.rechargeTimeMs = rechargeTimeMs
    self.manaCost = manaCost or 0
end

-- returns "x per second" for some value, such as dps, hps
function PHD.Spell:GetValPerSecond(val, channelingTimeMs)
    return self:_GetValPerSecond(val, channelingTimeMs, false)
end

-- returns "x per second" for some value, but account for cooldown, to get dpsc, hpsc, etc
function PHD.Spell:GetValPerSecondAccountForCooldown(val, channelingTimeMs)
    return self:_GetValPerSecond(val, channelingTimeMs, true)
end

-- returns "x per second" for some value
-- can account for cooldown, recharge time, etc
function PHD.Spell:_GetValPerSecond(val, channelingTimeMs, shouldAccomodateForCooldowns)
    local cooldownMs
    if channelingTimeMs then
        cooldownMs = channelingTimeMs
    else
        cooldownMs = self.castTimeMs
    end

    if shouldAccomodateForCooldowns then
        if cooldownMs <= self.rechargeTimeMs then
            cooldownMs = self.rechargeTimeMs
        end
        if cooldownMs <= self.cooldownMs then
            cooldownMs = self.cooldownMs
        end
    end

    -- when calculating xps we use the cast time, but account for the gcd
    if cooldownMs <= self.gcdMs then
        cooldownMs = self.gcdMs
    end

    return val / cooldownMs * 1000
end

-- returns "x per mana" for some value
function PHD.Spell:GetValPerMana(val)
    if self.manaCost <= 0 then
        return nil
    end
    return val / self.manaCost
end

-- triggers value computations to run for a given spell implementation and takes care of the result
function PHD.Spell:RunComputations()
    self:GetStats()

    local result = self:Compute()

    -- convert stuff to numbers if they are strings
    -- TODO: this doesn't seem to work... >_<
    for k, v in pairs(result) do
        if type(v) == 'string' then
            result[k] = PHD:StrToNumber(v)
        end
    end

    result.manaCost = self.manaCost

    if result.heal then
        result.hpm = self:GetValPerMana(result.heal)

        -- naively calculate hps, unless it's already provided
        if not result.hps then
            result.hps = self:GetValPerSecond(result.heal)
        end
        if not result.hpsc then
            local hpsc = self:GetValPerSecondAccountForCooldown(result.heal)
            if hpsc ~= result.hps then
                result.hpsc = hpsc
            end
        end
    end

    if result.dmg then
        result.dpm = self:GetValPerMana(result.dmg)

        -- naively calculate dps, unless it's already provided
        if not result.dps then
            result.dps = self:GetValPerSecond(result.dmg)
        end
        if not result.dpsc then
            local dpsc = self:GetValPerSecondAccountForCooldown(result.dmg)
            if dpsc ~= result.dps then
                result.dpsc = dpsc
            end
        end
    end

    return result
end



if PHD.DEBUG then
    -- just a function to print a table, nice for debugging
    local function dump(definition)
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
end
