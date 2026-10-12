local AS_Name = "Auto Quest Sharing";
local AS_BLUE = "|c000099ff";
local AS_END_COLOR = "|r";

local EVENTS = {};

-- Event ADDON_LOADED
EVENTS.ADDON_LOADED = "ADDON_LOADED";
EVENTS.QUEST_ACCEPTED = "QUEST_ACCEPTED";

local function AS_SendMessage(message)
	DEFAULT_CHAT_FRAME:AddMessage(tostring(message));
end

local ShareQuest
if C_QuestLog and C_QuestLog.IsPushableQuest and C_QuestLog.SetSelectedQuest and QuestLogPushQuest then
	ShareQuest = function(questID)
		if not C_QuestLog.IsPushableQuest(questID) then
			return
		end

		local previousQuest = C_QuestLog.GetSelectedQuest and C_QuestLog.GetSelectedQuest()
		C_QuestLog.SetSelectedQuest(questID)
		QuestLogPushQuest()
		if previousQuest and previousQuest > 0 then
			C_QuestLog.SetSelectedQuest(previousQuest)
		end
	end
elseif SelectQuestLogEntry and GetQuestLogPushable and QuestLogPushQuest then
	ShareQuest = function(questIndex, questID)
		if questID then
			if not GetQuestLogIndexByID then
				return
			end
			questIndex = GetQuestLogIndexByID(questID)
		end
		if not questIndex or questIndex == 0 then
			return
		end

		local previousIndex = GetQuestLogSelection and GetQuestLogSelection()
		SelectQuestLogEntry(questIndex)
		if GetQuestLogPushable() then
			QuestLogPushQuest()
		end
		if previousIndex and previousIndex > 0 then
			SelectQuestLogEntry(previousIndex)
		end
	end
else
	AS_SendMessage(AS_BLUE .. AS_Name .. ": quest sharing APIs are unavailable on this client." .. AS_END_COLOR)
end

local function AS_IsInGroup()
	if GetNumGroupMembers then
		return GetNumGroupMembers() > 0
	end

	local partyMembers = GetNumPartyMembers and GetNumPartyMembers() or 0
	local raidMembers = GetNumRaidMembers and GetNumRaidMembers() or 0
	return partyMembers > 0 or raidMembers > 0
end

local function AS_HandleQuestAccepted(questIndexOrID, questID)
	if AS_IsInGroup() and ShareQuest then
		ShareQuest(questIndexOrID, questID)
	end
end

local function AS_OnEvent(self, event, ...)
	if event == EVENTS.ADDON_LOADED and ... == "AutoShare" then
		AS_SendMessage(AS_BLUE .. AS_Name .. " loaded." .. AS_END_COLOR);
	elseif event == EVENTS.QUEST_ACCEPTED then
		AS_HandleQuestAccepted(...);
	end
end

local frame = CreateFrame("Frame", "AS_Frame")
for _, event in pairs(EVENTS) do
	frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", AS_OnEvent)

AS_SendMessage(AS_BLUE .. AS_Name .. " by PsyKzz." .. AS_END_COLOR)
