SLASH_PFFOCUS1 = '/focus'
function SlashCmdList.PFFOCUS(msg)
  if not pfUI.uf or not pfUI.uf.focus then return end

  if msg ~= "" then
    pfUI.uf.focus.unitname = strlower(msg)
    pfUI.uf.focus:Show()
  elseif UnitName("target") then
    pfUI.uf.focus.unitname = strlower(UnitName("target"))
    pfUI.uf.focus:Show()
  else
    pfUI.uf.focus:Hide()
  end
end

SLASH_PFCLEARFOCUS1 = '/clearfocus'
function SlashCmdList.PFCLEARFOCUS(msg)
  if pfUI.uf and pfUI.uf.focus then
    pfUI.uf.focus:Hide()
  end
end

SLASH_PFCASTFOCUS1 = '/castfocus'
function SlashCmdList.PFCASTFOCUS(msg)
  if not pfUI.uf.focus or not pfUI.uf.focus:IsShown() or not pfUI.uf.focus.unitname then
    UIErrorsFrame:AddMessage(SPELL_FAILED_BAD_TARGETS, 1, 0, 0)
    return
  end

  local skiptarget = false
  local player = UnitIsUnit("target", "player")

  if pfUI.uf.focus.label and UnitIsUnit("target", pfUI.uf.focus.label .. pfUI.uf.focus.id) then
    skiptarget = true
  else
    pfScanActive = true
    if pfUI.uf.focus.label and pfUI.uf.focus.id then
      TargetUnit(pfUI.uf.focus.label .. pfUI.uf.focus.id)
    else
      TargetByName(pfUI.uf.focus.unitname)
    end

    if strlower(UnitName("target")) ~= strlower(pfUI.uf.focus.unitname) then
      pfScanActive = nil
      TargetLastTarget()
      UIErrorsFrame:AddMessage(SPELL_FAILED_BAD_TARGETS, 1, 0, 0)
      return
    end
  end

  local func = loadstring(msg or "")
  if func then
    func()
  else
    CastSpellByName(msg)
  end

  if skiptarget == false then
    pfScanActive = nil
    if player then
      TargetUnit("player")
    else
      TargetLastTarget()
    end
  end
end

pfUI:RegisterModule("focus", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  pfUI.uf.focus = pfUI.uf:CreateUnitFrame("Focus", nil, C.unitframes.focus, .2)
  pfUI.uf.focus:UpdateFrameSize()
  pfUI.uf.focus:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 220, 220)
  UpdateMovable(pfUI.uf.focus)
  pfUI.uf.focus:Hide()
end)
