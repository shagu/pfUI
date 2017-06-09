pfUI:RegisterModule("pet", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  local spacing = C.unitframes.pet.pspace

  pfUI.uf.pet = pfUI.uf:CreateUnitFrame("Pet", nil, C.unitframes.pet)
  pfUI.uf.pet:UpdateFrameSize()
  pfUI.uf.pet:SetPoint("BOTTOM", UIParent , "BOTTOM", 0, 163)
  UpdateMovable(pfUI.uf.pet)
end)
