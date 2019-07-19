pfUI:RegisterModule("targettarget", "vanilla:tbc", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  pfUI.uf.targettarget = pfUI.uf:CreateUnitFrame("TargetTarget", nil, C.unitframes.ttarget, .2)
  pfUI.uf.targettarget:UpdateFrameSize()
  pfUI.uf.targettarget:SetPoint("BOTTOM", UIParent , "BOTTOM", 0, 125)
  UpdateMovable(pfUI.uf.targettarget)
end)
