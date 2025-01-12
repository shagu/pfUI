pfUI:RegisterModule("focus", "vanilla:tbc", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

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
if pfUI.client > 11200 then return end
SLASH_PFFOCUS1, SLASH_PFFOCUS2 = '/focus', '/pffocus'
function SlashCmdList.PFFOCUS(msg)
  if not pfUI.uf or not pfUI.uf.focus then return end

  if msg ~= "" then
    pfUI.uf.focus.unitname = strlower(msg)
  elseif UnitName("target") then
    pfUI.uf.focus.unitname = strlower(UnitName("target"))
  else
    pfUI.uf.focus.unitname = nil
    pfUI.uf.focus.label = nil
  end
end

SLASH_PFCLEARFOCUS1, SLASH_PFCLEARFOCUS2 = '/clearfocus', '/pfclearfocus'
function SlashCmdList.PFCLEARFOCUS(msg)
  if pfUI.uf and pfUI.uf.focus then
    pfUI.uf.focus.unitname = nil
    pfUI.uf.focus.label = nil
    pfUI.uf.focus.id = nil
  end

  if pfUI.uf and pfUI.uf.focustarget then
    pfUI.uf.focustarget.unitname = nil
    pfUI.uf.focustarget.label = nil
    pfUI.uf.focustarget.id = nil
  end
end

SLASH_PFCASTFOCUS1, SLASH_PFCASTFOCUS2 = '/castfocus', '/pfcastfocus'
function SlashCmdList.PFCASTFOCUS(msg)
  if not pfUI.uf.focus or not pfUI.uf.focus:IsShown() then
    UIErrorsFrame:AddMessage(SPELL_FAILED_BAD_TARGETS, 1, 0, 0)
    return
  end

  local skiptarget = false
  local player = UnitIsUnit("target", "player")
  local unitname = ""

  if pfUI.uf.focus.label and UnitIsUnit("target", pfUI.uf.focus.label .. pfUI.uf.focus.id) then
    skiptarget = true
  else
    pfScanActive = true
    if pfUI.uf.focus.label and pfUI.uf.focus.id then
      unitname = UnitName(pfUI.uf.focus.label .. pfUI.uf.focus.id)
      TargetUnit(pfUI.uf.focus.label .. pfUI.uf.focus.id)
    else
      unitname = pfUI.uf.focus.unitname
      TargetByName(pfUI.uf.focus.unitname, true)
    end

    if strlower(UnitName("target")) ~= strlower(unitname) then
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

SLASH_PFSWAPFOCUS1, SLASH_PFSWAPFOCUS2 = '/swapfocus', '/pfswapfocus'
function SlashCmdList.PFSWAPFOCUS(msg)
  if not pfUI.uf or not pfUI.uf.focus then return end

  local oldunit = UnitExists("target") and strlower(UnitName("target"))
  if oldunit and pfUI.uf.focus.unitname then
    TargetByName(pfUI.uf.focus.unitname)
    pfUI.uf.focus.unitname = oldunit
  end
end
