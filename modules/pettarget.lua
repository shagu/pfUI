pfUI:RegisterModule("pettarget", "vanilla:tbc", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  pfUI.uf.pettarget = pfUI.uf:CreateUnitFrame("PetTarget", nil, C.unitframes.ptarget, .2)
  pfUI.uf.pettarget:UpdateFrameSize()
  pfUI.uf.pettarget:SetPoint("TOP", pfUI.uf.pet or pfUI.uf.target or UIParent, "BOTTOM", 0, -default_border)
  UpdateMovable(pfUI.uf.pettarget)
end)
