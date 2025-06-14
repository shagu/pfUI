pfUI:RegisterModule("minimap", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local size = tonumber(C.appearance.minimap.size) or 140

  if MiniMapWorldMapButton then MiniMapWorldMapButton:Hide() end
  if MinimapToggleButton then MinimapToggleButton:Hide() end
  MinimapBorderTop:Hide()
  MinimapZoneTextButton:Hide()
  MinimapZoomIn:Hide()
  MinimapZoomOut:Hide()
  GameTimeFrame:Hide()

  MinimapBorder:SetTexture(nil)

  pfUI.minimap = CreateFrame("Frame","pfMinimap",UIParent)
  CreateBackdrop(pfUI.minimap)
  CreateBackdropShadow(pfUI.minimap)
  pfUI.minimap:SetPoint("TOPRIGHT", UIParent, -border*2, -border*2)
  UpdateMovable(pfUI.minimap)
  pfUI.minimap:SetScript("OnShow", function()
    QueueFunction(ShowUIPanel, Minimap)
  end)

  Minimap:SetParent(pfUI.minimap)
  Minimap:SetPoint("CENTER", pfUI.minimap, "CENTER", 0.5, -.5)
  Minimap:SetFrameLevel(1)
  Minimap:SetMaskTexture(pfUI.media["img:minimap"])
  Minimap:EnableMouseWheel(true)
  Minimap:SetScript("OnMouseWheel", function()
    if(arg1 > 0) then Minimap_ZoomIn() else Minimap_ZoomOut() end
  end)

  pfUI.minimap.UpdateConfig = function(self)
    size = tonumber(C.appearance.minimap.size) or 140

    pfUI.minimap:SetWidth(size)
    pfUI.minimap:SetHeight(size)

    Minimap:SetWidth(size)
    Minimap:SetHeight(size)

    -- vanilla+tbc: do the best to detect the minimap arrow
    local arrowscale = tonumber(C.appearance.minimap.arrowscale)
    local minimaparrow = ({Minimap:GetChildren()})[9]
    for k, v in pairs({Minimap:GetChildren()}) do
      if v:IsObjectType("Model") and not v:GetName() then
        if string.find(strlower(v:GetModel()), "interface\\minimap\\minimaparrow") then
          minimaparrow = v
          break
        end
      end
    end

    if minimaparrow then
      minimaparrow:SetScale(arrowscale)
    end
  end

  pfUI.minimap:UpdateConfig()

  hooksecurefunc("ToggleMinimap", function()
    if pfUI.farmmap and pfUI.farmmap:IsShown() then
      Minimap:Hide()
      return
    end

    if Minimap:IsVisible() then
      pfUI.minimap:SetHeight(size)
      pfUI.minimap:SetAlpha(1)
    else
      pfUI.minimap:SetHeight(-border-5)
      pfUI.minimap:SetAlpha(0)
      Minimap:Hide()
    end
  end, true)

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
  MiniMapMailIcon:SetTexture(pfUI.media["img:mail"])

  MiniMapMailFrame:SetScript("OnShow", function()
    if not this.highlight then
      this.highlight = CreateFrame("Frame", nil, this)
      this.highlight:SetAllPoints(this)
      this.highlight:SetFrameLevel(this:GetFrameLevel() + 1)

      this.highlight.tex = this.highlight:CreateTexture("OVERLAY")
      this.highlight.tex:SetTexture(pfUI.media["img:mail"])
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

  -- Create coordinates text frame with location configurable
  pfUI.minimapCoordinates = CreateFrame("Frame", "pfMinimapCoord", pfUI.minimap)
  pfUI.minimapCoordinates:SetScript("OnUpdate", function()
    -- update coords every 0.1 seconds
    if C.appearance.minimap.coordstext ~= "off" and ( this.tick or .1) > GetTime() then return else this.tick = GetTime() + .1 end

    this.posX, this.posY = GetPlayerMapPosition("player")
    if this.posX ~= 0 and this.posY ~= 0 then
      this.text:SetText(string.format("%.1f, %.1f", round(this.posX * 100, 1), round(this.posY * 100, 1)))
    else
      this.text:SetText("|cffffaaaaN/A")
    end
  end)

  if C.appearance.minimap.coordsloc == "topleft" then
    pfUI.minimapCoordinates:SetPoint("TOPLEFT", 3, -3)
  elseif C.appearance.minimap.coordsloc == "topright" then
    pfUI.minimapCoordinates:SetPoint("TOPRIGHT", -3, -3)
  elseif C.appearance.minimap.coordsloc == "bottomright" then
    pfUI.minimapCoordinates:SetPoint("BOTTOMRIGHT", -3, 3)
  else
    pfUI.minimapCoordinates:SetPoint("BOTTOMLEFT", 3, 3)
  end

  pfUI.minimapCoordinates:SetHeight(C.global.font_size)
  pfUI.minimapCoordinates:SetWidth(Minimap:GetWidth())
  pfUI.minimapCoordinates.text = pfUI.minimapCoordinates:CreateFontString("MinimapCoordinatesText", "LOW", "GameFontNormal")
  pfUI.minimapCoordinates.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
  pfUI.minimapCoordinates.text:SetTextColor(1,1,1,1)
  pfUI.minimapCoordinates.text:SetAllPoints(pfUI.minimapCoordinates)

  if C.appearance.minimap.coordsloc == "topright" or C.appearance.minimap.coordsloc == "bottomright" then
    pfUI.minimapCoordinates.text:SetJustifyH("RIGHT")
  else
    pfUI.minimapCoordinates.text:SetJustifyH("LEFT")
  end

  if C.appearance.minimap.coordstext ~= "on" then
    pfUI.minimapCoordinates:Hide()
  else
    pfUI.minimapCoordinates:Show()
  end

  -- Create zone text frame in top center of minimap
  pfUI.minimapZone = CreateFrame("Frame", "pfMinimapZone", pfUI.minimap)
  pfUI.minimapZone:RegisterEvent("MINIMAP_ZONE_CHANGED")
  pfUI.minimapZone:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.minimapZone:SetPoint("TOP", 0, -3)
  pfUI.minimapZone:SetHeight(C.global.font_size + 2)
  pfUI.minimapZone:SetWidth(Minimap:GetWidth())
  pfUI.minimapZone.text = pfUI.minimapZone:CreateFontString("minimapZoneText", "LOW", "GameFontNormal")
  pfUI.minimapZone.text:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
  pfUI.minimapZone.text:SetAllPoints(pfUI.minimapZone)
  pfUI.minimapZone.text:SetJustifyH("CENTER")

  pfUI.minimapZone:SetScript("OnEvent", function()
    if not WorldMapFrame:IsShown() then
      SetMapToCurrentZone()
    end

    if C.appearance.minimap.zonetext ~= "off" then
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
    end
  end)

  if C.appearance.minimap.zonetext ~= "on" then
    pfUI.minimapZone:Hide()
  else
    pfUI.minimapZone:Show()
  end

  -- Minimap hover event
  -- Update and toggle showing of coordinates and zone text on mouse enter/leave
  Minimap:SetScript("OnEnter", function()
    if C.appearance.minimap.coordstext ~= "off" then
      pfUI.minimapCoordinates:Show()
    end
    if C.appearance.minimap.zonetext ~= "off" then
      pfUI.minimapZone:Show()
    end
  end)
  Minimap:SetScript("OnLeave", function()
    if C.appearance.minimap.coordstext ~= "on" then
      pfUI.minimapCoordinates:Hide()
    end
    if C.appearance.minimap.zonetext ~= "on" then
      pfUI.minimapZone:Hide()
    end
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
  pfUI.minimap.pvpicon.texture:SetTexture(pfUI.media["img:pvp"])
  pfUI.minimap.pvpicon.texture:SetAllPoints(pfUI.minimap.pvpicon)

  pfUI.minimap.pvpicon:SetScript("OnEvent", function()
    if C.unitframes.player.showPVPMinimap == "1" and UnitIsPVP("player") then
      pfUI.minimap.pvpicon:Show()
    else
      pfUI.minimap.pvpicon:Hide()
    end
  end)

end)
