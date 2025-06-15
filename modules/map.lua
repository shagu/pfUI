pfUI:RegisterModule("map", "vanilla:tbc", function ()
  table.insert(UISpecialFrames, "WorldMapFrame")

  local function UpdateTooltipScale()
    -- load scale data
    local tooltipscale = tonumber(C.appearance.worldmap.tooltipsize)
    local scale = WorldMapFrame:GetScale()

    -- apply tooltip scale
    if tooltipscale > 0 then
      WorldMapTooltip:SetScale(tooltipscale/scale)
    else
      WorldMapTooltip:SetScale(1)
    end
  end

  -- register config update handler
  pfUI.map = { UpdateConfig = UpdateTooltipScale }

  function _G.ToggleWorldMap()
    if WorldMapFrame:IsShown() then
      WorldMapFrame:Hide()
    else
      WorldMapFrame:Show()
    end
  end

  C.position["WorldMapFrame"] = C.position["WorldMapFrame"] or { alpha = 1.0, scale = 0.7 }
  C.position["WorldMapFrame"].parent = nil
  local alpha = C.position["WorldMapFrame"].alpha
  local scale = C.position["WorldMapFrame"].scale

  local pfMapLoader = CreateFrame("Frame")
  pfMapLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfMapLoader:SetScript("OnEvent", function()
    -- do not load if other map addon is loaded
    if Cartographer then return end
    if METAMAP_TITLE then return end

    UIPanelWindows["WorldMapFrame"] = { area = "center" }

    WorldMapFrame:SetMovable(true)
    WorldMapFrame:EnableMouse(true)
    WorldMapFrame:RegisterForDrag("LeftButton")

    -- make sure the hooks get only applied once
    if not this.hooked then
      this.hooked = true

      HookScript(WorldMapFrame, "OnShow", function()
        -- customize
        this:EnableKeyboard(false)
        this:EnableMouseWheel(1)

        -- set back to default scale
        WorldMapFrame:SetScale(scale or .85)
      end)

      HookScript(WorldMapFrame, "OnMouseWheel", function()
        if IsShiftKeyDown() then
          alpha = clamp(WorldMapFrame:GetAlpha() + arg1/10, 0.1, 1.0)
          WorldMapFrame:SetAlpha(alpha)
        end

        if IsControlKeyDown() then
          local oldscale = WorldMapFrame:GetScale()
          local point, rel, relpoint, offx, offy = WorldMapFrame:GetPoint()
          scale = clamp(oldscale + arg1/10, 0.1, 2.0)

          -- recalculate world frame position based on old and new scale
          if point == "TOPLEFT" and relpoint == "TOPLEFT" then
            offx = offx*oldscale/scale
            offy = offy*oldscale/scale
            WorldMapFrame:SetPoint(point, rel, relpoint, offx, offy)
          end

          WorldMapFrame:SetScale(scale)
          UpdateTooltipScale()
        end

        SaveMovable(this, true)
      end)

      HookScript(WorldMapFrame, "OnDragStart", function()
        WorldMapFrame:StartMoving()
      end)

      HookScript(WorldMapFrame, "OnDragStop",function()
        WorldMapFrame:StopMovingOrSizing()
        SaveMovable(this, true)
      end)
    end

    WorldMapFrame:SetAlpha(alpha)
    WorldMapFrame:SetScale(scale)
    UpdateTooltipScale()

    WorldMapFrame:ClearAllPoints()
    WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    WorldMapFrame:SetWidth(WorldMapButton:GetWidth() + 15)
    WorldMapFrame:SetHeight(WorldMapButton:GetHeight() + 55)
    LoadMovable(WorldMapFrame)

    -- skin
    WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", 0, 0)
    CreateBackdrop(WorldMapFrame)
    CreateBackdropShadow(WorldMapFrame)

    BlackoutWorld:Hide()
    StripTextures(WorldMapFrame)

    SkinButton(WorldMapZoomOutButton)
    SkinCloseButton(WorldMapFrameCloseButton, WorldMapFrame, -3, -3)
    SkinDropDown(WorldMapContinentDropDown)
    SkinDropDown(WorldMapZoneDropDown)
    if WorldMapZoneMinimapDropDown then
      SkinDropDown(WorldMapZoneMinimapDropDown)
    end
    local point, anchor, anchorPoint, x, y = WorldMapZoneDropDown:GetPoint()
    WorldMapZoneDropDown:ClearAllPoints()
    WorldMapZoneDropDown:SetPoint(point, anchor, anchorPoint, x+8, y)

    -- coordinates
    if not WorldMapButton.coords then
      WorldMapButton.coords = CreateFrame("Frame", "pfWorldMapButtonCoords", WorldMapButton)
      WorldMapButton.coords.text = WorldMapButton.coords:CreateFontString(nil, "OVERLAY")
      WorldMapButton.coords.text:SetPoint("BOTTOMRIGHT", WorldMapButton, "BOTTOMRIGHT", -10, 10)
      WorldMapButton.coords.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
      WorldMapButton.coords.text:SetTextColor(1, 1, 1)
      WorldMapButton.coords.text:SetJustifyH("RIGHT")

      WorldMapButton.coords:SetScript("OnUpdate", function()
        local width  = WorldMapButton:GetWidth()
        local height = WorldMapButton:GetHeight()
        local mx, my = WorldMapButton:GetCenter()
        local scale  = WorldMapButton:GetEffectiveScale()
        local x, y   = GetCursorPosition()

        if mx and my then
          mx = (( x / scale ) - ( mx - width / 2)) / width * 100
          my = (( my + height / 2 ) - ( y / scale )) / height * 100
        end

        if mx and my and MouseIsOver(WorldMapButton) then
          WorldMapButton.coords.text:SetText(string.format('%.1f / %.1f', mx, my))
        else
          WorldMapButton.coords.text:SetText("")
        end
      end)
    end
  end)

  pfUI.map.loader = pfMapLoader
end)
