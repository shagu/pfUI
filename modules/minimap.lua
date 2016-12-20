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
  pfUI.utils:CreateBackdrop(pfUI.minimap)
  pfUI.minimap:SetPoint("TOPRIGHT", UIParent, -5, -5)
  pfUI.utils:UpdateMovable(pfUI.minimap)
  pfUI.minimap:SetWidth(140)
  pfUI.minimap:SetHeight(140)
  pfUI.minimap:SetFrameStrata("BACKGROUND")

  Minimap:SetParent(pfUI.minimap)
  Minimap:SetPoint("CENTER", pfUI.minimap, "CENTER", 0.5, -.5)

  -- Set new mail frame position to top right corner of the minimap
  -- mostly taken from TukUI
  MiniMapMailFrame:ClearAllPoints()
  MiniMapMailFrame:SetPoint("TOPRIGHT", pfUI.minimap, "TOPRIGHT", 0, 0)
  MiniMapMailBorder:Hide()
  MiniMapMailIcon:SetTexture("Interface\\AddOns\\pfUI\\img\\mail")

  MiniMapMailFrame:SetScript("OnShow", function()
    if not this.highlight then
      this.highlight = CreateFrame("Frame", nil, this)
      this.highlight:SetAllPoints(this)
      this.highlight:SetFrameLevel(this:GetFrameLevel() + 1)

      this.highlight.tex = this.highlight:CreateTexture("OVERLAY")
      this.highlight.tex:SetTexture("Interface\\AddOns\\pfUI\\img\\mail")
      this.highlight.tex:SetPoint("TOPLEFT", MiniMapMailIcon, "TOPLEFT", -2, 2)
      this.highlight.tex:SetPoint("BOTTOMRIGHT", MiniMapMailIcon, "BOTTOMRIGHT", 2, -2)
      this.highlight.tex:SetVertexColor(1,.5,.5)

      this.highlight:SetScript("OnUpdate", function()
        if not this.count then this.count = 0 end
        if not this.modifier then this.modifier = 1 end
        if this.count >= 10 then this:Hide() end

        this:SetAlpha(this:GetAlpha() + this.modifier)

        if this:GetAlpha() <= 0.1 then
          this.modifier = 0.05
          this.count = this.count + 1
        elseif this:GetAlpha() >= 0.9 then
          this.modifier = -0.05
        end
      end)
    end

    this.highlight.count = 0
    this.highlight:Show()
  end)

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
  pfUI.minimapCoordinates.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.minimapCoordinates.text:SetPoint("LEFT", 4, 0)
  pfUI.minimapCoordinates.text:SetFontObject(GameFontWhite)
  pfUI.minimapCoordinates.text:SetText("X, Y")
  pfUI.minimapCoordinates:Hide()

  -- Minimap hover event
  -- Update and toggle showing of coordinates on mouse enter/leave
  Minimap:SetScript("OnEnter", function()
    SetMapToCurrentZone()
    local posX, posY = GetPlayerMapPosition("player")
    if posX ~= 0 and posY ~= 0 then
      local roundedX = ceil(posX * 1000)/10
      local roundedY = ceil(posY * 1000)/10
      pfUI.minimapCoordinates.text:SetText(roundedX..", "..roundedY)
    else
      pfUI.minimapCoordinates.text:SetText("|cffffaaaaN/A")
    end

    pfUI.minimapCoordinates:Show()
  end)
  Minimap:SetScript("OnLeave", function()
    pfUI.minimapCoordinates:Hide()
  end)

end)
