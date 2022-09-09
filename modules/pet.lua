pfUI:RegisterModule("pet", "vanilla:tbc", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end
  pfUI.uf.pet = pfUI.uf:CreateUnitFrame("Pet", nil, C.unitframes.pet)
  pfUI.uf.pet:UpdateFrameSize()
  pfUI.uf.pet:SetPoint("BOTTOM", UIParent , "BOTTOM", 0, 163)
  UpdateMovable(pfUI.uf.pet)
end)
