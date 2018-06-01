pfUI:RegisterModule("pettarget", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  pfUI.uf.pettargetScanner = CreateFrame("Button",nil,UIParent)
  pfUI.uf.pettargetScanner:SetScript("OnUpdate", function()
      if pfUI.uf.pettarget.config.visible == "0" then return end
      if ( this.limit or 1) > GetTime() then return else this.limit = GetTime() + .2 end
      if UnitExists("pettarget") or (pfUI.unlock and pfUI.unlock:IsShown()) then
        pfUI.uf.pettarget:Show()
      else
        pfUI.uf.pettarget:Hide()
        pfUI.uf.pettarget.lastUnit = nil
      end
    end)

  pfUI.uf.pettarget = pfUI.uf:CreateUnitFrame("PetTarget", nil, C.unitframes.ptarget, .2)
  pfUI.uf.pettarget:UpdateFrameSize()
  pfUI.uf.pettarget:SetPoint("TOP", pfUI.uf.pet or pfUI.uf.target or UIParent, "BOTTOM", 0, -default_border)
  UpdateMovable(pfUI.uf.pettarget)
end)
