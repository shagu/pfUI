SLASH_PFFOCUS1 = '/focus'
function SlashCmdList.PFFOCUS(msg)
  if not pfUI.uf or not pfUI.uf.focus then return end

  if msg ~= "" then
    pfUI.uf.focus:Show()
    pfUI.uf.focus.unitname = strlower(msg)
  elseif UnitName("target") then
    pfUI.uf.focus:Show()
    pfUI.uf.focus.unitname = strlower(UnitName("target"))
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

pfUI:RegisterModule("focus", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  pfUI.uf.focus = pfUI.uf:CreateUnitFrame("Focus", nil, C.unitframes.focus, .2)
  pfUI.uf.focus:UpdateFrameSize()
  pfUI.uf.focus:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 220, 220)
  UpdateMovable(pfUI.uf.focus)
  pfUI.uf.focus:Hide()
end)
