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

  -- Set new mail frame position to top right corner of the minimap
  -- mostly taken from TukUI
  MiniMapMailFrame:ClearAllPoints()
  MiniMapMailFrame:SetPoint("TOPRIGHT", pfUI.minimap, "TOPRIGHT", 0, 0)
  MiniMapMailBorder:Hide()
  MiniMapMailIcon:SetTexture("Interface\\AddOns\\pfUI\\img\\mail")

  MiniMapTrackingFrame:SetFrameStrata("LOW")

  -- Current location
  -- Create location text frame under minimap
  pfUI.minimapLocation = CreateFrame("Frame", nil, UIParent)
  pfUI.minimapLocation:SetBackdrop(pfUI.backdrop)
  pfUI.minimapLocation:SetBackdropColor(0,0,0,0)
  pfUI.minimapLocation:SetPoint("TOPRIGHT",UIParent, -5, -7 - Minimap:GetHeight())
  pfUI.minimapLocation:SetHeight(20)
  pfUI.minimapLocation:SetWidth(Minimap:GetWidth())
  pfUI.minimapLocation:SetFrameStrata("BACKGROUND")
  pfUI.minimapLocation.background = pfUI.minimapLocation:CreateTexture(nil,"BACKGROUND")
  pfUI.minimapLocation.background:SetTexture(0,0,0,1)
  pfUI.minimapLocation.background:SetAllPoints(pfUI.minimapLocation)
  -- Create text
  pfUI.minimapLocation.text = pfUI.minimapLocation:CreateFontString("MinimapZoneText", "LOW", "GameFontNormal")
  pfUI.minimapLocation.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 9, "OUTLINE")
  pfUI.minimapLocation.text:SetPoint("CENTER", 0, 0)
  pfUI.minimapLocation.text:SetFontObject(GameFontWhite)
  -- Register zone change event
  pfUI.minimapLocation:RegisterEvent("ZONE_CHANGED")
  local function zoneChangeEventHandler(self, event, ...)
    pfUI.minimapLocation.text:SetText(GetZoneText())
  end
  pfUI.minimapLocation:SetScript("OnEvent", zoneChangeEventHandler)
  -- Initiate zone text
  zoneChangeEventHandler()

  -- Coordinates in minimap
  -- Create location text frame in bottom left corner of minimap
  pfUI.minimapCoordinates = CreateFrame("Frame", nil, pfUI.minimap)
  pfUI.minimapCoordinates:SetPoint("BOTTOMLEFT", 3, 3)
  pfUI.minimapCoordinates:SetHeight(20)
  pfUI.minimapCoordinates:SetWidth(40)
  pfUI.minimapCoordinates:SetFrameStrata("BACKGROUND")
  pfUI.minimapCoordinates.background = pfUI.minimapCoordinates:CreateTexture(nil,"BACKGROUND")
  pfUI.minimapCoordinates.background:SetTexture(0,0,0,1)
  pfUI.minimapCoordinates.background:SetAllPoints(pfUI.minimapCoordinates)
  -- Create text
  pfUI.minimapCoordinates.text = pfUI.minimapCoordinates:CreateFontString("MinimapCoordinatesText", "LOW", "GameFontNormal")
  pfUI.minimapCoordinates.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 11, "OUTLINE")
  pfUI.minimapCoordinates.text:SetPoint("LEFT", 0, 0)
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
