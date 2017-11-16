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

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  local spacing = C.unitframes.focus.pspace

  if C.unitframes.focus.panchor == "TOP" then
    relative_point = "BOTTOM"
  elseif C.unitframes.focus.panchor == "LEFT" then
    relative_point = "BOTTOMLEFT"
  elseif C.unitframes.focus.panchor == "RIGHT" then
    relative_point = "BOTTOMRIGHT"
  end

  pfUI.uf.focus = pfUI.uf:CreateUnitFrame("Focus", nil, C.unitframes.focus, .2)
  pfUI.uf.focus.power:SetWidth(C.unitframes.focus.pwidth)
  pfUI.uf.focus.power:SetPoint(C.unitframes.focus.panchor, pfUI.uf.focus.hp.bar, relative_point, 0, -2*default_border - spacing)
  pfUI.uf.focus:UpdateFrameSize()
  pfUI.uf.focus:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 220, 220)
  UpdateMovable(pfUI.uf.focus)
  pfUI.uf.focus:Hide()
end)
