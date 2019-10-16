
local FlashOfLight = PHD.Spell:NewWithId(19750)
function FlashOfLight:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal = string.match(self.description, "Expends a large amount of mana to quickly heal a friendly target for (%d[%d.,]*).")
    if heal == nil then
        return
    end

    self:ReturnValues { heal = PHD:StrToNumber(heal) }
end

local HolyLight = PHD.Spell:NewWithId(82326)
function HolyLight:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal = string.match(self.description, "An efficient spell, healing a friendly target for (%d[%d.,]*).")
    if heal == nil then
        return
    end

    self:ReturnValues { heal = PHD:StrToNumber(heal) }
end

-- local HolyShock = Spell:NewWithId(20473, { descriptionMatcher = "Triggers a burst of Light on the target, dealing (%d[%d.,]*) ." })
