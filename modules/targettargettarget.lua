pfUI:RegisterModule("targettargettarget", "vanilla:tbc", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  pfUI.uf.targettargettarget = pfUI.uf:CreateUnitFrame("TargetTargetTarget", nil, C.unitframes.tttarget, .2)
  pfUI.uf.targettargettarget:UpdateFrameSize()
  pfUI.uf.targettargettarget:SetPoint("BOTTOM", UIParent , "BOTTOM", 0, 200)
  UpdateMovable(pfUI.uf.targettargettarget)
end)
