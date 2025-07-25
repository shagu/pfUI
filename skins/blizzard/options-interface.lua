pfUI:RegisterSkin("Options - Interface", "tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  StripTextures(InterfaceOptionsFrame)
  CreateBackdrop(InterfaceOptionsFrame, nil, nil, .75)
  CreateBackdropShadow(InterfaceOptionsFrame)

  EnableMovable(InterfaceOptionsFrame)

  InterfaceOptionsFrameHeaderText:ClearAllPoints()
  InterfaceOptionsFrameHeaderText:SetPoint("TOP", InterfaceOptionsFrame.backdrop, "TOP", 0, -10)

  StripTextures(InterfaceOptionsFrameCategories)
  CreateBackdrop(InterfaceOptionsFrameCategories, nil, true, .75)
  StripTextures(InterfaceOptionsFrameAddOns)
  CreateBackdrop(InterfaceOptionsFrameAddOns, nil, true, .75)
  CreateBackdrop(InterfaceOptionsFramePanelContainer, nil, true, .75)

  SkinTab(InterfaceOptionsFrameTab1)
  InterfaceOptionsFrameTab1:ClearAllPoints()
  InterfaceOptionsFrameTab1:SetPoint("BOTTOMLEFT", InterfaceOptionsFrameCategories, "TOPLEFT", bpad, border + (border == 1 and 1 or 2))
  SkinTab(InterfaceOptionsFrameTab2)
  InterfaceOptionsFrameTab2:ClearAllPoints()
  InterfaceOptionsFrameTab2:SetPoint("LEFT", InterfaceOptionsFrameTab1, "RIGHT", border*2 + 1, 0)

  SkinButton(InterfaceOptionsFrameDefaults)
  InterfaceOptionsFrameDefaults:ClearAllPoints()
  InterfaceOptionsFrameDefaults:SetPoint("TOPLEFT", InterfaceOptionsFrameCategories, "BOTTOMLEFT", 0, -10)
  SkinButton(InterfaceOptionsFrameCancel)
  InterfaceOptionsFrameCancel:ClearAllPoints()
  InterfaceOptionsFrameCancel:SetPoint("TOPRIGHT", InterfaceOptionsFramePanelContainer, "BOTTOMRIGHT", 0, -10)
  SkinButton(InterfaceOptionsFrameOkay)
  InterfaceOptionsFrameOkay:ClearAllPoints()
  InterfaceOptionsFrameOkay:SetPoint("RIGHT", InterfaceOptionsFrameCancel, "LEFT", -2*bpad, 0)

  -- universal code for handling any frames!
  local function SkinAllObjects(frame)
    for _,obj in ipairs({frame:GetChildren()}) do
    local obj_type = obj:GetObjectType()
      if obj_type == "CheckButton" then
        local size = obj:GetHeight()
        if size > 26 then size = 26 end
        SkinCheckbox(obj, size)
      elseif obj_type == "Button" then
        SkinButton(obj)
      elseif obj_type == "Slider" then
        SkinSlider(obj)
      elseif obj_type == "Frame" then
        local name = obj.GetName and obj:GetName()
        if name and _G[name.."Button"] then
          SkinDropDown(obj)
        else
          SkinAllObjects(obj)
        end
      end
    end
  end

  local blizzardCategories = {
    InterfaceOptionsControlsPanel, InterfaceOptionsCombatPanel, InterfaceOptionsDisplayPanel,
    InterfaceOptionsQuestsPanel, InterfaceOptionsSocialPanel, InterfaceOptionsActionBarsPanel,
    InterfaceOptionsNamesPanel, InterfaceOptionsCombatTextPanel, InterfaceOptionsStatusTextPanel,
    InterfaceOptionsPartyRaidPanel, InterfaceOptionsCameraPanel, InterfaceOptionsMousePanel,
    InterfaceOptionsHelpPanel, InterfaceOptionsLanguagesPanel
  }
  for _,frame in ipairs(blizzardCategories) do
    SkinAllObjects(frame)
  end

  -- skin the option panel of any addon
  for _,frame in pairs(INTERFACEOPTIONS_ADDONCATEGORIES) do
    SkinAllObjects(frame)
  end
end)

pfUI:RegisterSkin("Options - Interface", "vanilla", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  UIOptionsFrame:SetParent(UIParent)
  UIOptionsFrame:SetWidth(1024)
  UIOptionsFrame:SetHeight(700)

  StripTextures(UIOptionsFrame)
  CreateBackdrop(UIOptionsFrame, nil, nil, .75)
  CreateBackdropShadow(UIOptionsFrame)

  EnableMovable(UIOptionsFrame)

  HookScript(UIOptionsFrame, "OnShow", function()
    this:ClearAllPoints()
    this:SetPoint("CENTER", 0, 0)
  end)

  UIOptionsFrame.backdrop:SetPoint("BOTTOMRIGHT", 0, 50)
  UIOptionsFrame:SetHitRectInsets(0,0,0,50)


  -- increase button layer
  UIOptionsFrameTab1:SetFrameLevel(8)
  UIOptionsFrameTab2:SetFrameLevel(8)
  UIOptionsFrameDefaults:SetFrameLevel(8)
  UIOptionsFrameCancel:SetFrameLevel(8)
  UIOptionsFrameOkay:SetFrameLevel(8)

  local close = GetNoNameObject(UIOptionsFrame, "Button", nil, "UI-Panel-MinimizeButton-Up")
  if close then
    close:SetFrameLevel(8)
    SkinCloseButton(close, UIOptionsFrame.backdrop, -6, -6)
  end

  if UIOptionsFrameTitle then
    UIOptionsFrameTitle:ClearAllPoints()
    UIOptionsFrameTitle:SetPoint("TOP", UIOptionsFrame.backdrop, "TOP", 0, -10)
  end

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
