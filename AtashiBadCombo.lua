local AtashiBadCombo = CreateFrame("FRAME", "AtashiBadCombo")

AtashiBadCombo:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
AtashiBadCombo.m_missCount = 0
AtashiBadCombo.m_trackedSkills = {
	["WARRIOR"] = {
		"Sunder Armor",
		"Heroic Strike",
		"Bloodthirst",
		"Shield Slam",
		"Revenge",
		"Taunt",
		"Whirlwind",
		"Cleave",
		"Mocking Blow",
		"Challenging Shout",
		"Demoralizing Shout"
	},
	["WARLOCK"] = {
		"Shadow Bolt",
		"Curse of Agony",
		"Curse of Shadow",
		"Curse of Elements",
		"Curse of Recklessness",
		"Corruption",
		"Immolate",
		"Curse of Weakness",
		"Searing Pain",
		"Shadowburn",
		"Curse of Tongues",
		"Banish"
	}
}

local function ShouldTrackSpell(spellId)
	local localizedClass, englishClass, classIndex = UnitClass("player")

	for i = 1, #AtashiBadCombo.m_trackedSkills[englishClass] do
		if AtashiBadCombo.m_trackedSkills[englishClass][i] == spellId then
			return true
		end
	end

	return false
end

function AtashiBadCombo:OnEvent(event, ...)
	if event =="COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	
		if sourceGUID == UnitGUID("player") then
			--AtashiBadCombo:DebugParameters(...)

			if subevent == "SPELL_MISSED" then
				local spellId = select(13, ...)

				if ShouldTrackSpell(spellId) then
					local missType, isOffHand, amountMissed = select(12, ...)
		
					--if missType == "DODGE" or missType == "PARRY" or missType == "MISS" then
						AtashiBadCombo.m_missCount = AtashiBadCombo.m_missCount + 1
					--end

					--DEFAULT_CHAT_FRAME:AddMessage("Missed with " .. spellId .. "(" .. missType .. ")")
				end
			elseif subevent == "SPELL_DAMAGE" or subevent == "SPELL_AURA_APPLIED" then
				local spellId = select(13, ...)

				if ShouldTrackSpell(spellId) then
					if AtashiBadCombo.m_missCount >= 3 then
						if IsInRaid() then
							SendChatMessage(UnitName("player") .. " just had a miss combo of " .. AtashiBadCombo.m_missCount, "RAID");
						elseif IsInGroup() then
							SendChatMessage(UnitName("player") .. " just had a miss combo of " .. AtashiBadCombo.m_missCount, "PARTY");
						end

						DEFAULT_CHAT_FRAME:AddMessage("You just had a miss combo of " .. AtashiBadCombo.m_missCount)
					end
					
					AtashiBadCombo.m_missCount = 0
					--DEFAULT_CHAT_FRAME:AddMessage("Hit with " .. spellId)
				end
			end
		end
	end
end

AtashiBadCombo:SetScript("OnEvent", function(self, event)
	self:OnEvent(event, CombatLogGetCurrentEventInfo())
end)

function AtashiBadCombo:DebugParameters(...)
	-- Debugging all the parameters in the combat log event. Comment the elements you don't want to see.
	local parameters = {
		[1] = "Timestamp",
		[2] = "Sub-event",
		[4] = "Source GUID",
		[5] = "Source Name",
		--[6] = "Source Flags",
		--[7] = "Source Raid Flags",
		[8] = "Destination GUID",
		[9] = "Destination Name",
		--[10] = "Destination Flags",
		--[11] = "Destination Raid Flags",
		[13] = "Spell ID"
	}

	for i = 1, select('#', ...) do
		if parameters[i] then
			DEFAULT_CHAT_FRAME:AddMessage(parameters[i] .. ": " .. tostring(select(i, ...)))
		else
			--DEFAULT_CHAT_FRAME:AddMessage("Parameter #" .. i .. ": " .. tostring(select(i, ...)))
		end
	end
end