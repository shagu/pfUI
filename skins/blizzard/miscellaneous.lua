pfUI:RegisterSkin("Stack Split", "vanilla:tbc", function ()
  StripTextures(StackSplitFrame)
  CreateBackdrop(StackSplitFrame, nil, nil, .75)
  CreateBackdropShadow(StackSplitFrame)

  SkinButton(StackSplitOkayButton)
  SkinButton(StackSplitCancelButton)
end)

pfUI:RegisterSkin("Coin Pickup", "vanilla:tbc", function ()
  StripTextures(CoinPickupFrame)
  CreateBackdrop(CoinPickupFrame, nil, nil, .75)
  CreateBackdropShadow(CoinPickupFrame)

  SkinButton(CoinPickupOkayButton)
  SkinButton(CoinPickupCancelButton)
end)

pfUI:RegisterSkin("Color Picker", "vanilla:tbc", function ()
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

pfUI:RegisterSkin("Opacity", "vanilla:tbc", function ()
  CreateBackdrop(OpacityFrame, nil, true, .75)
  CreateBackdropShadow(OpacityFrame)

  SkinSlider(OpacityFrameSlider)
  OpacityFrameSlider:ClearAllPoints()
  OpacityFrameSlider:SetPoint("CENTER", 0, 0)
end)

pfUI:RegisterSkin("Tutorial", "vanilla:tbc", function ()
  CreateBackdrop(TutorialFrame, nil, true, .75)
  CreateBackdropShadow(TutorialFrame)

  SkinCheckbox(TutorialFrameCheckButton)
  SkinButton(TutorialFrameOkayButton)
end)

pfUI:RegisterSkin("Quest Timer", "vanilla:tbc", function ()
  CreateBackdrop(QuestTimerFrame, nil, nil, .75)
  CreateBackdropShadow(QuestTimerFrame)
  UpdateMovable(QuestTimerFrame, true)
  QuestTimerHeader:Hide()

  -- UIParent_ManageFramePositions overwrites positions. Ignore those:
  QuestTimerFrame._SetPoint = QuestTimerFrame.SetPoint
  QuestTimerFrame.SetPoint = function(self, a, b, c, d, e, f)
    if b ~= "MinimapCluster" then self:_SetPoint(a,b,c,d,e,f) end
  end
end)
