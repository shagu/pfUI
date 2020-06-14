pfUI:RegisterModule("map", "vanilla:tbc", function ()
  table.insert(UISpecialFrames, "WorldMapFrame")

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

    WorldMapFrame:SetScript("OnShow", function()
      -- default events
      UpdateMicroButtons()
      PlaySound("igQuestLogOpen")
      CloseDropDownMenus()
      SetMapToCurrentZone()
      WorldMapFrame_PingPlayerPosition()

      -- customize
      this:EnableKeyboard(false)
      this:EnableMouseWheel(1)
    end)

    WorldMapFrame:SetScript("OnMouseWheel", function()
      if IsShiftKeyDown() then
        alpha = clamp(WorldMapFrame:GetAlpha() + arg1/10, 0.1, 1.0)
        WorldMapFrame:SetAlpha(alpha)
      end

      if IsControlKeyDown() then
        scale = clamp(WorldMapFrame:GetScale() + arg1/10, 0.1, 2.0)
        WorldMapFrame:SetScale(scale)
      end

      SaveMovable(this, true)
    end)

    WorldMapFrame:SetScript("OnMouseDown",function()
      WorldMapFrame:StartMoving()
    end)

    WorldMapFrame:SetScript("OnMouseUp",function()
      WorldMapFrame:StopMovingOrSizing()
      SaveMovable(this, true)
    end)

    WorldMapFrame:SetMovable(true)
    WorldMapFrame:EnableMouse(true)

    WorldMapFrame:SetAlpha(alpha)
    WorldMapFrame:SetScale(scale)

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

        mx = (( x / scale ) - ( mx - width / 2)) / width * 100
        my = (( my + height / 2 ) - ( y / scale )) / height * 100

        if MouseIsOver(WorldMapButton) then
          WorldMapButton.coords.text:SetText(string.format('%.1f / %.1f', mx, my))
        else
          WorldMapButton.coords.text:SetText("")
        end
      end)
    end
  end)
end)
