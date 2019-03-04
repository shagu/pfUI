pfUI:RegisterSkin("StackSplitFrame", function ()
  StripTextures(StackSplitFrame)
  CreateBackdrop(StackSplitFrame, nil, nil, .75)

  SkinButton(StackSplitOkayButton)
  SkinButton(StackSplitCancelButton)
end)

pfUI:RegisterSkin("CoinPickupFrame", function ()
  StripTextures(CoinPickupFrame)
  CreateBackdrop(CoinPickupFrame, nil, nil, .75)

  SkinButton(CoinPickupOkayButton)
  SkinButton(CoinPickupCancelButton)
end)

pfUI:RegisterSkin("ColorPickerFrame", function ()
  CreateBackdrop(ColorPickerFrame)

  ColorPickerFrameHeader:SetTexture("")

  SkinButton(ColorPickerOkayButton)
  ColorPickerOkayButton:ClearAllPoints()
  ColorPickerOkayButton:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOM", -4, 10)
  SkinButton(ColorPickerCancelButton)
  ColorPickerCancelButton:ClearAllPoints()
  ColorPickerCancelButton:SetPoint("BOTTOMLEFT", ColorPickerFrame, "BOTTOM", 4, 10)

  SkinSlider(OpacitySliderFrame)
end)

pfUI:RegisterSkin("OpacityFrame", function ()
  CreateBackdrop(OpacityFrame, nil, true, .75)

  SkinSlider(OpacityFrameSlider)
  OpacityFrameSlider:ClearAllPoints()
  OpacityFrameSlider:SetPoint("CENTER", 0, 0)
end)

pfUI:RegisterSkin("TutorialFrame", function ()
  CreateBackdrop(TutorialFrame, nil, true, .75)
  --[[
    for i = 1, MAX_TUTORIAL_ALERTS do
    local button = _G["TutorialFrameAlertButton"..i]
    end
  --]]
  SkinCheckbox(TutorialFrameCheckButton)
  SkinButton(TutorialFrameOkayButton)
end)

pfUI:RegisterSkin("QuestTimerFrame", function ()
  CreateBackdrop(QuestTimerFrame, nil, nil, .75)
  --EnableMovable(QuestTimerFrame) -- Does not work! I need to fix it later! point update in UIParent_ManageFramePositions

  QuestTimerHeader:Hide()
end)
