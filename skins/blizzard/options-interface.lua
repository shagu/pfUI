pfUI:RegisterSkin("Options - Interface", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  UIOptionsFrame:SetParent(UIParent)
  UIOptionsFrame:SetWidth(1024)
  UIOptionsFrame:SetHeight(700)

  StripTextures(UIOptionsFrame)
  CreateBackdrop(UIOptionsFrame, nil, nil, .75)
  EnableMovable(UIOptionsFrame)

  HookScript(UIOptionsFrame, "OnShow", function()
    this:ClearAllPoints()
    this:SetPoint("CENTER", 0, 0)
  end)

  UIOptionsFrame.backdrop:SetPoint("BOTTOMRIGHT", 0, 50)
  UIOptionsFrame:SetHitRectInsets(0,0,0,50)

  local close = GetNoNameObject(UIOptionsFrame, "Button", nil, "UI-Panel-MinimizeButton-Up")

  -- increase button layer
  UIOptionsFrameTab1:SetFrameLevel(8)
  UIOptionsFrameTab2:SetFrameLevel(8)
  UIOptionsFrameDefaults:SetFrameLevel(8)
  UIOptionsFrameCancel:SetFrameLevel(8)
  UIOptionsFrameOkay:SetFrameLevel(8)
  close:SetFrameLevel(8)

  SkinCloseButton(close, UIOptionsFrame.backdrop, -6, -6)
  UIOptionsFrameTitle:ClearAllPoints()
  UIOptionsFrameTitle:SetPoint("TOP", UIOptionsFrame.backdrop, "TOP", 0, -10)

  SkinTab(UIOptionsFrameTab1)
  UIOptionsFrameTab1:ClearAllPoints()
  UIOptionsFrameTab1:SetPoint("TOPLEFT", UIOptionsFrame.backdrop, "TOPLEFT", 20, -20)
  UIOptionsFrameTab1:SetScript("OnClick", function()
    PanelTemplates_Tab_OnClick(UIOptionsFrame)
    BasicOptions:Show()
    AdvancedOptions:Hide()
    PlaySound("igCharacterInfoTab")
  end)
  SkinTab(UIOptionsFrameTab2)
  UIOptionsFrameTab2:ClearAllPoints()
  UIOptionsFrameTab2:SetPoint("LEFT", UIOptionsFrameTab1, "RIGHT", border*2 + 1, 0)
  UIOptionsFrameTab2:SetScript("OnClick", function()
    PanelTemplates_Tab_OnClick(UIOptionsFrame)
    BasicOptions:Hide()
    AdvancedOptions:Show()
    PlaySound("igCharacterInfoTab")
  end)

  UIOptionsFrameCheckButton1:ClearAllPoints() -- Invert Mouse button
  UIOptionsFrameCheckButton1:SetPoint("TOPLEFT", UIOptionsFrameSlider1, "TOPRIGHT", 38, 14)

  for i=1, 69 do
    local buton = _G["UIOptionsFrameCheckButton"..i]
    if buton then
      SkinCheckbox(buton)
    end
  end

  for i=1, 4 do
    SkinSlider(_G["UIOptionsFrameSlider"..i])
  end

  CreateBackdrop(BasicOptionsGeneral, nil, true, .75)
  CreateBackdrop(BasicOptionsDisplay, nil, true, .75)
  CreateBackdrop(BasicOptionsCamera, nil, true, .75)
  CreateBackdrop(BasicOptionsHelp, nil, true, .75)
  CreateBackdrop(AdvancedOptionsActionBars, nil, true, .75)
  CreateBackdrop(AdvancedOptionsChat, nil, true, .75)
  CreateBackdrop(AdvancedOptionsRaid, nil, true, .75)
  CreateBackdrop(AdvancedOptionsCombatText, nil, true, .75)

  SkinDropDown(UIOptionsFrameClickCameraDropDown)
  SkinDropDown(UIOptionsFrameCameraDropDown)
  SkinDropDown(UIOptionsFrameTargetofTargetDropDown)
  SkinDropDown(UIOptionsFrameCombatTextDropDown)

  SkinButton(UIOptionsFrameResetTutorials)
  SkinButton(UIOptionsFrameDefaults)
  UIOptionsFrameDefaults:ClearAllPoints()
  UIOptionsFrameDefaults:SetPoint("BOTTOMLEFT", UIOptionsFrame.backdrop, "BOTTOMLEFT", 14, 14)
  SkinButton(UIOptionsFrameCancel)
  UIOptionsFrameCancel:ClearAllPoints()
  UIOptionsFrameCancel:SetPoint("BOTTOMRIGHT", UIOptionsFrame.backdrop, "BOTTOMRIGHT", -14, 14)
  SkinButton(UIOptionsFrameOkay)
  UIOptionsFrameOkay:ClearAllPoints()
  UIOptionsFrameOkay:SetPoint("RIGHT", UIOptionsFrameCancel, "LEFT", -2*bpad, 0)
end)
