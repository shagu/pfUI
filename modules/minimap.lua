pfUI:RegisterModule("minimap", function ()
  MinimapToggleButton:Hide()
  MinimapBorderTop:Hide()
  MinimapZoneTextButton:Hide()
  MinimapZoomIn:Hide()
  MinimapZoomOut:Hide()
  GameTimeFrame:Hide()

  MinimapBorder:SetTexture(nil)
  Minimap:SetMaskTexture("Interface\\AddOns\\pfUI\\img\\minimap")

  Minimap:EnableMouseWheel(true)
  Minimap:SetScript("OnMouseWheel", function()
      if(arg1 > 0) then Minimap_ZoomIn() else Minimap_ZoomOut() end
    end)

  pfUI.minimap = CreateFrame("Frame",nil,UIParent)
  pfUI.minimap:SetBackdrop(pfUI.backdrop)
  pfUI.minimap:SetBackdropColor(0,0,0,0)
  pfUI.minimap:SetPoint("TOPRIGHT", UIParent, -5, -5)
  pfUI.minimap:SetWidth(Minimap:GetWidth())
  pfUI.minimap:SetHeight(Minimap:GetHeight())
  pfUI.minimap:SetFrameStrata("BACKGROUND")
  pfUI.minimap.background = pfUI.minimap:CreateTexture(nil,"BACKGROUND")
  pfUI.minimap.background:SetTexture(0,0,0,1)
  pfUI.minimap.background:SetAllPoints(pfUI.minimap)

  Minimap:SetParent(pfUI.minimap)
  Minimap:ClearAllPoints()
  Minimap:SetPoint("TOPLEFT", pfUI.minimap, "TOPLEFT", 3, -3)
  Minimap:SetPoint("BOTTOMRIGHT", pfUI.minimap, "BOTTOMRIGHT", -3, 3)

  MiniMapTrackingFrame:SetFrameStrata("LOW")
end)
