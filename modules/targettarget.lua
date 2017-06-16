pfUI:RegisterModule("targettarget", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  pfUI.uf.targettargetScanner = CreateFrame("Button",nil,UIParent)
  pfUI.uf.targettargetScanner:SetScript("OnUpdate", function()
      if UnitExists("targettarget") or (pfUI.unlock and pfUI.unlock:IsShown()) then
        pfUI.uf.targettarget:Show()
      else
        pfUI.uf.targettarget:Hide()
      end
    end)

  pfUI.uf.targettarget = pfUI.uf:CreateUnitFrame("TargetTarget", nil, C.unitframes.ttarget, .2)
  pfUI.uf.targettarget:UpdateFrameSize()
  pfUI.uf.targettarget:SetPoint("BOTTOM", UIParent , "BOTTOM", 0, 125)
  UpdateMovable(pfUI.uf.targettarget)
end)
