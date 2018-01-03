local AS_Name = "Auto Quest Sharing";
local AS_BLUE = "|c000099ff";
local AS_YELLOW = "|cffffff55";
local AS_END_COLOR = "|r";
local AS_Title = AS_BLUE .. AS_Name .. ":" .. AS_END_COLOR .. " ";

local EVENTS = {};

-- Event ADDON_LOADED
EVENTS.ADDON_LOADED = "ADDON_LOADED";
EVENTS.QUEST_ACCEPTED = "QUEST_ACCEPTED";

function AS_SendMessage(message)
	DEFAULT_CHAT_FRAME:AddMessage(tostring(message));
end

function AS_OnLoad(self)
	for _,v in pairs(EVENTS) do
		self:RegisterEvent(strupper(v));
	end

	AS_SendMessage(AS_BLUE .. AS_Name .. " by PsyKzz." .. AS_END_COLOR);
end

function AS_OnEvent(self, event, ...)
	if event == EVENTS.ADDON_LOADED and ... == "AutoShare" then
		AS_SendMessage(AS_BLUE .. AS_Name .. " loaded." .. AS_END_COLOR);
	elseif event == EVENTS.QUEST_ACCEPTED then
		AS_HandleQuestAccepted(...);
	end
end

function AS_HandleQuestAccepted(questIndex)
	if GetNumGroupMembers() >= 1 then
		
		SelectQuestLogEntry(questIndex);

		if GetQuestLogPushable() then
			QuestLogPushQuest();
		end
	end
end
