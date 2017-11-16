pfUI:RegisterModule("target", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  local spacing = C.unitframes.target.pspace

  -- Hide Blizzard target frame and unregister all events to prevent it from popping up again
  TargetFrame:Hide()
  TargetFrame:UnregisterAllEvents()

  if C.unitframes.target.panchor == "TOP" then
    relative_point = "BOTTOM"
  elseif C.unitframes.target.panchor == "LEFT" then
    relative_point = "BOTTOMLEFT"
  elseif C.unitframes.target.panchor == "RIGHT" then
    relative_point = "BOTTOMRIGHT"
  end

  pfUI.uf.target = pfUI.uf:CreateUnitFrame("Target", nil, C.unitframes.target)
  pfUI.uf.target.power:SetWidth(C.unitframes.target.pwidth)
  pfUI.uf.target.power:SetPoint(C.unitframes.target.panchor, pfUI.uf.target.hp.bar, relative_point, 0, -2*default_border - spacing)
  pfUI.uf.target:UpdateFrameSize()
  pfUI.uf.target:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 75, 125)
  UpdateMovable(pfUI.uf.target)
end)
