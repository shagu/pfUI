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
  CreateBackdrop(pfUI.minimap)
  pfUI.minimap:SetPoint("TOPRIGHT", UIParent, -5, -5)
  UpdateMovable(pfUI.minimap)
  pfUI.minimap:SetWidth(140)
  pfUI.minimap:SetHeight(140)
  pfUI.minimap:SetFrameStrata("BACKGROUND")

  Minimap:SetParent(pfUI.minimap)
  Minimap:SetPoint("CENTER", pfUI.minimap, "CENTER", 0.5, -.5)

  -- battleground icon
  MiniMapBattlefieldFrame:ClearAllPoints()
  MiniMapBattlefieldFrame:SetPoint("BOTTOMRIGHT", Minimap, 4, -4)
  MiniMapBattlefieldBorder:Hide()
  MiniMapBattlefieldFrame:SetScript("OnClick", function()
    GameTooltip:Hide()
    if MiniMapBattlefieldFrame.status == "active" then
      if arg1 == "RightButton" then
        ToggleDropDownMenu(1, nil, MiniMapBattlefieldDropDown, "MiniMapBattlefieldFrame", -95, -5)
      elseif IsShiftKeyDown() then
        ToggleBattlefieldMinimap()
      else
        ToggleWorldStateScoreFrame()
      end
    elseif arg1 == "RightButton" then
      ToggleDropDownMenu(1, nil, MiniMapBattlefieldDropDown, "MiniMapBattlefieldFrame", -95, -5)
    end
  end)

  -- mail icon
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

  -- Create coordinates text frame in bottom left corner of minimap
  pfUI.minimapCoordinates = CreateFrame("Frame", "pfMinimapCoord", pfUI.minimap)
  pfUI.minimapCoordinates:SetPoint("BOTTOMLEFT", 3, 3)
  pfUI.minimapCoordinates:SetHeight(C.global.font_size)
  pfUI.minimapCoordinates:SetWidth(Minimap:GetWidth())
  pfUI.minimapCoordinates:SetFrameStrata("BACKGROUND")
  pfUI.minimapCoordinates.text = pfUI.minimapCoordinates:CreateFontString("MinimapCoordinatesText", "LOW", "GameFontNormal")
  pfUI.minimapCoordinates.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
  pfUI.minimapCoordinates.text:SetTextColor(1,1,1,1)
  pfUI.minimapCoordinates.text:SetAllPoints(pfUI.minimapCoordinates)
  pfUI.minimapCoordinates.text:SetJustifyH("LEFT")
  pfUI.minimapCoordinates:Hide()

  -- Create zone text frame in top center of minimap
  pfUI.minimapZone = CreateFrame("Frame", "pfMinimapZone", pfUI.minimap)
  pfUI.minimapZone:SetPoint("TOP", 0, -3)
  pfUI.minimapZone:SetHeight(C.global.font_size + 2)
  pfUI.minimapZone:SetWidth(Minimap:GetWidth())
  pfUI.minimapZone:SetFrameStrata("BACKGROUND")
  pfUI.minimapZone.text = pfUI.minimapZone:CreateFontString("minimapZoneText", "LOW", "GameFontNormal")
  pfUI.minimapZone.text:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
  pfUI.minimapZone.text:SetAllPoints(pfUI.minimapZone)
  pfUI.minimapZone.text:SetJustifyH("CENTER")
  pfUI.minimapZone:Hide()

  -- Minimap hover event
  -- Update and toggle showing of coordinates and zone text on mouse enter/leave
  Minimap:SetScript("OnEnter", function()
    SetMapToCurrentZone()
    local posX, posY = GetPlayerMapPosition("player")
    if posX ~= 0 and posY ~= 0 then
      pfUI.minimapCoordinates.text:SetText(round(posX * 100, 1) .. ", " .. round(posY * 100, 1))
    else
      pfUI.minimapCoordinates.text:SetText("|cffffaaaaN/A")
    end
    pfUI.minimapCoordinates:Show()

    if C.appearance.minimap.mouseoverzone == "1" then
      local pvp, _, arena = GetZonePVPInfo()
      if arena then
        pfUI.minimapZone.text:SetTextColor(1.0, 0.1, 0.1)
      elseif pvp == "friendly" then
        pfUI.minimapZone.text:SetTextColor(0.1, 1.0, 0.1)
      elseif pvp == "hostile" then
        pfUI.minimapZone.text:SetTextColor(1.0, 0.1, 0.1)
      elseif pvp == "contested" then
        pfUI.minimapZone.text:SetTextColor(1.0, 0.7, 0)
      else
        pfUI.minimapZone.text:SetTextColor(1, 1, 1, 1)
      end

      pfUI.minimapZone.text:SetText(GetMinimapZoneText())
      pfUI.minimapZone:Show()
    end
  end)
  Minimap:SetScript("OnLeave", function()
    pfUI.minimapCoordinates:Hide()
    pfUI.minimapZone:Hide()
  end)

  pfUI.minimap.pvpicon = CreateFrame("Frame", nil, pfUI.minimap)
  pfUI.minimap.pvpicon:Hide()
  pfUI.minimap.pvpicon:RegisterEvent("UPDATE_FACTION")
  pfUI.minimap.pvpicon:RegisterEvent("UNIT_FACTION")
  pfUI.minimap.pvpicon:SetFrameStrata("HIGH")
  pfUI.minimap.pvpicon:SetWidth(16)
  pfUI.minimap.pvpicon:SetHeight(16)
  pfUI.minimap.pvpicon:SetAlpha(.5)
  pfUI.minimap.pvpicon:SetParent(pfUI.minimap)
  pfUI.minimap.pvpicon:SetPoint("BOTTOMRIGHT", pfUI.minimap, "BOTTOMRIGHT", -5, 5)
  pfUI.minimap.pvpicon.texture = pfUI.minimap.pvpicon:CreateTexture(nil,"DIALOG")
  pfUI.minimap.pvpicon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\pvp")
  pfUI.minimap.pvpicon.texture:SetAllPoints(pfUI.minimap.pvpicon)

  pfUI.minimap.pvpicon:SetScript("OnEvent", function()
    if C.unitframes.player.showPVPMinimap == "1" and UnitIsPVP("player") then
      pfUI.minimap.pvpicon:Show()
    else
      pfUI.minimap.pvpicon:Hide()
    end
  end)

end)
