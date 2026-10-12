local AS_Name = "Auto Quest Sharing";
local AS_BLUE = "|c000099ff";
local AS_END_COLOR = "|r";

local EVENTS = {
	ADDON_LOADED = "ADDON_LOADED",
	QUEST_ACCEPTED = "QUEST_ACCEPTED",
};

local function AS_SendMessage(message)
	if print then
		print(tostring(message));
	elseif DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(tostring(message));
	end
end

-- Client tier detection:
-- Tier 1: Retail (WOW_PROJECT_MAINLINE)
-- Tier 2: Forever (WOW_PROJECT_CAMELOT / interface 16001)
-- Tier 3: Classic (WOW_PROJECT_CLASSIC / Era / Progression)
local buildInterface = GetBuildInfo and select(4, GetBuildInfo());
local isForever = (buildInterface == 16001) or (WOW_PROJECT_CAMELOT and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT);
local isRetail = (WOW_PROJECT_ID and WOW_PROJECT_MAINLINE and WOW_PROJECT_ID == WOW_PROJECT_MAINLINE);
local isClassic = not (isRetail or isForever);

-- Group check: check modern IsInGroup first, then GetNumGroupMembers, then legacy fallbacks
local function AS_IsInGroup()
	if IsInGroup then
		return IsInGroup();
	end
	if GetNumGroupMembers then
		return GetNumGroupMembers() > 0;
	end

	local partyMembers = GetNumPartyMembers and GetNumPartyMembers() or 0;
	local raidMembers = GetNumRaidMembers and GetNumRaidMembers() or 0;
	return partyMembers > 0 or raidMembers > 0;
end

-- Modern quest sharing (Retail and Forever tiers)
-- Uses C_QuestLog APIs: IsPushableQuest, SetSelectedQuest, QuestLogPushQuest
local function ShareQuestModern(questID)
	if not questID then
		return false;
	end

	if not (C_QuestLog and C_QuestLog.IsPushableQuest and C_QuestLog.SetSelectedQuest and QuestLogPushQuest) then
		return false;
	end

	if not C_QuestLog.IsPushableQuest(questID) then
		return false;
	end

	local previousQuest = C_QuestLog.GetSelectedQuest and C_QuestLog.GetSelectedQuest();
	C_QuestLog.SetSelectedQuest(questID);
	QuestLogPushQuest();
	if previousQuest and previousQuest > 0 and C_QuestLog.SetSelectedQuest then
		C_QuestLog.SetSelectedQuest(previousQuest);
	end
	return true;
end

-- Legacy quest sharing (Classic tier)
-- Uses SelectQuestLogEntry, GetQuestLogPushable, and QuestLogPushQuest
local function ShareQuestLegacy(questIndex, questID)
	if (not questIndex or questIndex == 0) and questID then
		if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
			questIndex = C_QuestLog.GetLogIndexForQuestID(questID);
		elseif GetQuestLogIndexByID then
			questIndex = GetQuestLogIndexByID(questID);
		end
	end

	if not questIndex or questIndex == 0 then
		return false;
	end

	if not (SelectQuestLogEntry and GetQuestLogPushable and QuestLogPushQuest) then
		return false;
	end

	local previousIndex = GetQuestLogSelection and GetQuestLogSelection();
	SelectQuestLogEntry(questIndex);
	if GetQuestLogPushable() then
		QuestLogPushQuest();
	end
	if previousIndex and previousIndex > 0 and SelectQuestLogEntry then
		SelectQuestLogEntry(previousIndex);
	end
	return true;
end

local hasModernAPI = (C_QuestLog and C_QuestLog.IsPushableQuest and C_QuestLog.SetSelectedQuest and QuestLogPushQuest);
local hasLegacyAPI = (SelectQuestLogEntry and GetQuestLogPushable and QuestLogPushQuest);
if not hasModernAPI and not hasLegacyAPI then
	AS_SendMessage(AS_BLUE .. AS_Name .. ": quest sharing APIs are unavailable on this client." .. AS_END_COLOR);
end

local function AS_HandleQuestAccepted(arg1, arg2)
	if not AS_IsInGroup() then
		return;
	end

	-- Extract questIndex and questID across tiers:
	-- In Classic, QUEST_ACCEPTED passes (questIndex, questID).
	-- In Retail / Forever, QUEST_ACCEPTED passes (questID).
	local questIndex, questID;
	if type(arg2) == "number" and arg2 > 0 then
		questIndex = arg1;
		questID = arg2;
	elseif type(arg1) == "number" and arg1 > 0 then
		questID = arg1;
		questIndex = arg1;
	end

	if isClassic then
		-- Classic tier: use older legacy checks first, falling back to modern
		if not ShareQuestLegacy(questIndex, questID) then
			if questID then
				ShareQuestModern(questID);
			end
		end
	else
		-- Forever and Retail tiers: use modern C_QuestLog APIs first, falling back to legacy
		if not (questID and ShareQuestModern(questID)) then
			ShareQuestLegacy(questIndex, questID);
		end
	end
end

local function AS_OnEvent(self, event, ...)
	if event == EVENTS.ADDON_LOADED and ... == "AutoShare" then
		AS_SendMessage(AS_BLUE .. AS_Name .. " loaded." .. AS_END_COLOR);
	elseif event == EVENTS.QUEST_ACCEPTED then
		AS_HandleQuestAccepted(...);
	end
end

local frame = CreateFrame("Frame", "AS_Frame");
for _, event in pairs(EVENTS) do
	frame:RegisterEvent(event);
end
frame:SetScript("OnEvent", AS_OnEvent);

AS_SendMessage(AS_BLUE .. AS_Name .. " by PsyKzz." .. AS_END_COLOR);
