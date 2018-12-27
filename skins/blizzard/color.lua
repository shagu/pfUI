pfUI:RegisterSkin("ColorPicker", function ()
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
