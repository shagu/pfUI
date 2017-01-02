-- [ Client Fixes ] --
-- The 1.12.1 Gameclient is no longer developed and therefore
-- a few bugs popped up during the last few years. This class will
-- take care and fix these bugs if they are lua related and possible.
-- If you find an inappropriate fix that should be fixed in another way
-- or even works as expected, please create an issue on the pfUI bugtracker.
-- All changes to the original functions are marked with an "FIX:".

-- [ FloatingChatFrame.lua line 63/75 ] --
-- Gameclient automatically hides all undocked and "not visible"
-- chatframes whenever a "UPDATE_CHAT_WINDOWS" event is triggered.
-- This can also affect proper chatwindows that are just temporarily
-- invisible, e.g because of a completely hidden UI (Alt+Y).
function FloatingChatFrame_Update(id, onUpdateEvent)
	local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(id);
	local chatFrame = getglobal("ChatFrame"..id);
	local chatTab = getglobal("ChatFrame"..id.."Tab");

	-- Set Tab Name
	FCF_SetWindowName(chatFrame, name, 1)

	-- Locked display stuff
	local init = nil;
	-- Only do this if the frame is not initialized
	if ( onUpdateEvent and not chatFrame.isInitialized) then
		-- Set Frame Color and Alpha
		FCF_SetWindowColor(chatFrame, r, g, b, 1);
		FCF_SetWindowAlpha(chatFrame, a, 1);
		FCF_SetLocked(chatFrame, locked);
	end

	if ( shown ) then
		chatFrame:Show();
		FCF_SetTabPosition(chatFrame, 0);
	else
		if ( not chatFrame.isDocked ) then
			-- FIX: chatFrame:Hide();
			-- FIX: chatTab:Hide();
		end
	end

	if ( docked ) then
		FCF_DockFrame(chatFrame, docked);
	else
		if ( shown ) then
			FCF_UnDockFrame(chatFrame);
		else
			-- FIX: FCF_Close(chatFrame);
		end
	end
end
