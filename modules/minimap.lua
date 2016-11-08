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

  pfUI.minimap = CreateFrame("Frame","pfMinimap",UIParent)
  pfUI.minimap:SetBackdrop(pfUI.backdrop)
  pfUI.minimap:SetBackdropColor(0,0,0,0)
  pfUI.minimap:SetPoint("TOPRIGHT", UIParent, -5, -5)
  pfUI.utils:loadPosition(pfUI.minimap)
  pfUI.minimap:SetWidth(Minimap:GetWidth() + 5)
  pfUI.minimap:SetHeight(Minimap:GetHeight() + 5)
  pfUI.minimap:SetFrameStrata("BACKGROUND")

  Minimap:SetParent(pfUI.minimap)
  Minimap:ClearAllPoints()
  Minimap:SetPoint("TOPLEFT", pfUI.minimap, "TOPLEFT", 3, -3)
  Minimap:SetPoint("BOTTOMRIGHT", pfUI.minimap, "BOTTOMRIGHT", -2, 2)

  -- Set new mail frame position to top right corner of the minimap
  -- mostly taken from TukUI
  MiniMapMailFrame:ClearAllPoints()
  MiniMapMailFrame:SetPoint("TOPRIGHT", pfUI.minimap, "TOPRIGHT", 0, 0)
  MiniMapMailBorder:Hide()
  MiniMapMailIcon:SetTexture("Interface\\AddOns\\pfUI\\img\\mail")

  MiniMapTrackingFrame:SetFrameStrata("LOW")


  -- Coordinates in minimap
  -- Create location text frame in bottom left corner of minimap
  pfUI.minimapCoordinates = CreateFrame("Frame", nil, pfUI.minimap)
  pfUI.minimapCoordinates:SetPoint("BOTTOMLEFT", 3, 3)
  pfUI.minimapCoordinates:SetHeight(20)
  pfUI.minimapCoordinates:SetWidth(40)
  pfUI.minimapCoordinates:SetFrameStrata("BACKGROUND")
  -- Create text
  pfUI.minimapCoordinates.text = pfUI.minimapCoordinates:CreateFontString("MinimapCoordinatesText", "LOW", "GameFontNormal")
  pfUI.minimapCoordinates.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.minimapCoordinates.text:SetPoint("LEFT", 4, 0)
  pfUI.minimapCoordinates.text:SetFontObject(GameFontWhite)
  pfUI.minimapCoordinates.text:SetText("X, Y")
  pfUI.minimapCoordinates:Hide()

  -- Minimap hover event
  -- Update and toggle showing of coordinates on mouse enter/leave
  Minimap:SetScript("OnEnter", function()
    SetMapToCurrentZone()
    local posX, posY = GetPlayerMapPosition("player")
    local roundedX = ceil(posX * 1000)/10
    local roundedY = ceil(posY * 1000)/10
    pfUI.minimapCoordinates.text:SetText(roundedX..", "..roundedY)
    pfUI.minimapCoordinates:Show()
  end)
  Minimap:SetScript("OnLeave", function()
    pfUI.minimapCoordinates:Hide()
  end)

end)
