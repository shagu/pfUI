pfUI:RegisterModule("target", "vanilla:tbc", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  -- Hide Blizzard target frame and unregister all events to prevent it from popping up again
  TargetFrame:Hide()
  TargetFrame:UnregisterAllEvents()

  pfUI.uf.target = pfUI.uf:CreateUnitFrame("Target", nil, C.unitframes.target)
  pfUI.uf.target:UpdateFrameSize()
  pfUI.uf.target:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 75, 125)
  UpdateMovable(pfUI.uf.target)
end)
