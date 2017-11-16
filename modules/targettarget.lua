pfUI:RegisterModule("targettarget", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  local spacing = C.unitframes.ttarget.pspace

  pfUI.uf.targettargetScanner = CreateFrame("Button",nil,UIParent)
  pfUI.uf.targettargetScanner:SetScript("OnUpdate", function()
      if ( this.limit or 1) > GetTime() then return else this.limit = GetTime() + .2 end
      if UnitExists("targettarget") or (pfUI.unlock and pfUI.unlock:IsShown()) then
        pfUI.uf.targettarget:Show()
      else
        pfUI.uf.targettarget:Hide()
        pfUI.uf.targettarget.lastUnit = nil
      end
    end)

  if C.unitframes.ttarget.panchor == "TOP" then
    relative_point = "BOTTOM"
  elseif C.unitframes.ttarget.panchor == "LEFT" then
    relative_point = "BOTTOMLEFT"
  elseif C.unitframes.ttarget.panchor == "RIGHT" then
    relative_point = "BOTTOMRIGHT"
  end

  pfUI.uf.targettarget = pfUI.uf:CreateUnitFrame("TargetTarget", nil, C.unitframes.ttarget, .2)
  pfUI.uf.targettarget.power:SetWidth(C.unitframes.ttarget.pwidth)
  pfUI.uf.targettarget.power:SetPoint(C.unitframes.ttarget.panchor, pfUI.uf.targettarget.hp.bar, relative_point, 0, -2*default_border - spacing)
  pfUI.uf.targettarget:UpdateFrameSize()
  pfUI.uf.targettarget:SetPoint("BOTTOM", UIParent , "BOTTOM", 0, 125)
  UpdateMovable(pfUI.uf.targettarget)
end)
