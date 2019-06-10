pfUI:RegisterSkin("Stack Split", "vanilla", function ()
  StripTextures(StackSplitFrame)
  CreateBackdrop(StackSplitFrame, nil, nil, .75)
  CreateBackdropShadow(StackSplitFrame)

  SkinButton(StackSplitOkayButton)
  SkinButton(StackSplitCancelButton)
end)

pfUI:RegisterSkin("Coin Pickup", function ()
  StripTextures(CoinPickupFrame)
  CreateBackdrop(CoinPickupFrame, nil, nil, .75)
  CreateBackdropShadow(CoinPickupFrame)

  SkinButton(CoinPickupOkayButton)
  SkinButton(CoinPickupCancelButton)
end)

pfUI:RegisterSkin("Color Picker", function ()
  CreateBackdrop(ColorPickerFrame)
  CreateBackdropShadow(ColorPickerFrame)

  ColorPickerFrameHeader:SetTexture("")

  SkinButton(ColorPickerOkayButton)
  ColorPickerOkayButton:ClearAllPoints()
  ColorPickerOkayButton:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOM", -4, 10)
  SkinButton(ColorPickerCancelButton)
  ColorPickerCancelButton:ClearAllPoints()
  ColorPickerCancelButton:SetPoint("BOTTOMLEFT", ColorPickerFrame, "BOTTOM", 4, 10)

  SkinSlider(OpacitySliderFrame)
end)

pfUI:RegisterSkin("Opacity", function ()
  CreateBackdrop(OpacityFrame, nil, true, .75)
  CreateBackdropShadow(OpacityFrame)

  SkinSlider(OpacityFrameSlider)
  OpacityFrameSlider:ClearAllPoints()
  OpacityFrameSlider:SetPoint("CENTER", 0, 0)
end)

pfUI:RegisterSkin("Tutorial", function ()
  CreateBackdrop(TutorialFrame, nil, true, .75)
  CreateBackdropShadow(TutorialFrame)

  SkinCheckbox(TutorialFrameCheckButton)
  SkinButton(TutorialFrameOkayButton)
end)

pfUI:RegisterSkin("Quest Timer", function ()
  CreateBackdrop(QuestTimerFrame, nil, nil, .75)
  CreateBackdropShadow(QuestTimerFrame)

  QuestTimerHeader:Hide()
end)
