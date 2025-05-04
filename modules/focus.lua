pfUI:RegisterModule("focus", "vanilla:tbc", function()
	-- do not go further on disabled UFs
	if C.unitframes.disable == "1" then
		return
	end

	pfUI.uf.focus = pfUI.uf:CreateUnitFrame("Focus", nil, C.unitframes.focus, .2)
	pfUI.uf.focus:UpdateFrameSize()
	pfUI.uf.focus:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 220, 220)
	UpdateMovable(pfUI.uf.focus)
	pfUI.uf.focus:Hide()

	pfUI.uf.focustarget = pfUI.uf:CreateUnitFrame("FocusTarget", nil, C.unitframes.focustarget, .2)
	pfUI.uf.focustarget:UpdateFrameSize()
	pfUI.uf.focustarget:SetPoint("BOTTOMLEFT", pfUI.uf.focus, "TOP", 0, 10)
	UpdateMovable(pfUI.uf.focustarget)
	pfUI.uf.focustarget:Hide()
end)

-- register focus emulation commands for vanilla
if pfUI.client > 11200 then
	return
end

function pfUI:SetFocus(msg)
	if not pfUI.uf or not pfUI.uf.focus then
		return
	end

	if msg ~= "" then
		pfUI.uf.focus.unitname = strlower(msg)
	elseif UnitName("target") then
		pfUI.uf.focus.unitname = strlower(UnitName("target"))
	else
		pfUI.uf.focus.unitname = nil
		pfUI.uf.focus.label = nil
	end
	local _, guid = UnitExists("target")
	pfUI.uf.focus.guid = guid
end

function pfUI:SetFocusGuid(guid)
	if not pfUI.uf or not pfUI.uf.focus then
		return
	end

	pfUI.uf.focus.guid = guid
	pfUI.uf.focus.unitname = strlower(UnitName(guid))
end

function pfUI:ClearFocus()
	if pfUI.uf and pfUI.uf.focus then
		pfUI.uf.focus.unitname = nil
		pfUI.uf.focus.label = nil
	end
end

function pfUI:CastFocus(msg)
	if not pfUI.uf.focus or not pfUI.uf.focus:IsShown() or not pfUI.uf.focus.unitname then
		UIErrorsFrame:AddMessage(SPELL_FAILED_BAD_TARGETS, 1, 0, 0)
		return
	end

	local skiptarget = false
	local player = UnitIsUnit("target", "player")

	if pfUI.uf.focus.guid then
		CastSpellByName(msg, pfUI.uf.focus.guid)
	elseif pfUI.uf.focus.label and UnitIsUnit("target", pfUI.uf.focus.label .. pfUI.uf.focus.id) then
		skiptarget = true
	else
		pfScanActive = true
		if pfUI.uf.focus.label and pfUI.uf.focus.id then
			TargetUnit(pfUI.uf.focus.label .. pfUI.uf.focus.id)
		else
			TargetByName(pfUI.uf.focus.unitname, true)
		end

		if strlower(UnitName("target")) ~= strlower(pfUI.uf.focus.unitname) then
			TargetLastTarget()
			UIErrorsFrame:AddMessage(SPELL_FAILED_BAD_TARGETS, 1, 0, 0)
			return
		end
		pfScanActive = nil
	end

	local func = loadstring(msg or "")
	if func then
		func()
	else
		CastSpellByName(msg)
	end
end

function pfUI:SwapFocus()
	if not pfUI.uf or not pfUI.uf.focus then
		return
	end

	local currentUnitName = strlower(UnitName("target"))
	local exists, currentUnitGUID = UnitExists("target")
	if exists and currentUnitName and pfUI.uf.focus.guid then
		TargetUnit(pfUI.uf.focus.guid)
		pfUI.uf.focus.unitname = currentUnitName
		pfUI.uf.focus.guid = currentUnitGUID
	end
end

SLASH_PFFOCUS1, SLASH_PFFOCUS2 = '/focus', '/pffocus'
function SlashCmdList.PFFOCUS(msg)
	pfUI:SetFocus(msg)
end

SLASH_PFCLEARFOCUS1, SLASH_PFCLEARFOCUS2 = '/clearfocus', '/pfclearfocus'
function SlashCmdList.PFCLEARFOCUS(msg)
	pfUI:ClearFocus()
end

SLASH_PFCASTFOCUS1, SLASH_PFCASTFOCUS2 = '/castfocus', '/pfcastfocus'
function SlashCmdList.PFCASTFOCUS(msg)
	pfUI:CastFocus(msg)
end

SLASH_PFSWAPFOCUS1, SLASH_PFSWAPFOCUS2 = '/swapfocus', '/pfswapfocus'
function SlashCmdList.PFSWAPFOCUS(msg)
	pfUI:SwapFocus()
end
