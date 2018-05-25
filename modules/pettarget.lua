pfUI:RegisterModule("pettarget", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  pfUI.uf.pettargetScanner = CreateFrame("Button",nil,UIParent)
  pfUI.uf.pettargetScanner:SetScript("OnUpdate", function()
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
  pfUI.uf.pettarget:SetPoint("BOTTOM", UIParent , "BOTTOM", 0, 201)
  UpdateMovable(pfUI.uf.pettarget)
end)