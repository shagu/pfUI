-- todo: add dropdown with all available tracking spells on left mouse click, and "/cast" chosen spell
pfUI:RegisterModule("tracking", function ()
  MiniMapTrackingFrame:UnregisterAllEvents()
  MiniMapTrackingFrame:Hide()

  local config = {
      border = C.appearance.border.tracking ~= "-1" and C.appearance.border.tracking or C.appearance.border.default,
      size = tonumber(C.appearance.minimap.tracking_size),
      pulse = C.appearance.minimap.tracking_pulse == "1"
  }

  local state = {
    texture = nil,
    pulsing = false
  }

  pfUI.tracking = CreateFrame("Button", "pfUITracking", UIParent)
  pfUI.tracking:SetFrameStrata("LOW")
  CreateBackdrop(pfUI.tracking, config.border)
  pfUI.tracking:SetPoint("TOPLEFT", pfUI.minimap, -10, -10)
  UpdateMovable(pfUI.tracking)
  pfUI.tracking:SetWidth(config.size)
  pfUI.tracking:SetHeight(config.size)

  pfUI.tracking.icon = pfUI.tracking:CreateTexture("BACKGROUND")
  pfUI.tracking.icon:SetTexCoord(.08, .92, .08, .92)
  pfUI.tracking.icon:SetAllPoints(pfUI.tracking)

  pfUI.tracking:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.tracking:RegisterEvent("PLAYER_AURAS_CHANGED")
  pfUI.tracking:SetScript("OnEvent", function()
    local texture = GetTrackingTexture()
    if texture ~= state.texture or event == "PLAYER_ENTERING_WORLD" then
      state.texture = texture
      if texture then
        state.pulsing = false
        pfUI.tracking.icon:SetTexture(texture)
        pfUI.tracking:SetAlpha(1)
        pfUI.tracking:Show()
      else
        if config.pulse then
          state.pulsing = {tick = 1, dir = 1, min = 1, max = 25}
          pfUI.tracking.icon:SetTexture("Interface\\Icons\\inv_misc_questionmark")
          pfUI.tracking:Show()
        else
          state.pulsing = false
          pfUI.tracking:Hide()
        end
      end
    end
  end)

  pfUI.tracking:SetScript("OnUpdate", function()
    local p = state.pulsing
    if p then
      pfUI.tracking:SetAlpha(p.tick / p.max)
      p.tick = p.tick + p.dir
      if p.tick == p.max or p.tick == p.min then
        p.dir = -p.dir
      end
    end
  end)

  pfUI.tracking:RegisterForClicks("RightButtonUp")
  pfUI.tracking:SetScript("OnClick", function()
    if arg1 == "RightButton" and state.texture then
      CancelTrackingBuff()
    end
  end)

  pfUI.tracking:SetScript("OnEnter", function()
    GameTooltip_SetDefaultAnchor(GameTooltip, this)
    if state.texture then
      GameTooltip:SetTrackingSpell()
    else
      GameTooltip:SetText(T["No tracking spell active"])
    end
    GameTooltip:Show()
  end)

  pfUI.tracking:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end)
