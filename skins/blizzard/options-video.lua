pfUI:RegisterSkin("Options-Video", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  CreateBackdrop(OptionsFrame, nil, nil, .75)
  EnableMovable(OptionsFrame)

  OptionsFrameHeader:SetTexture("")
  local OptionsFrameHeaderText = GetNoNameObject(OptionsFrame, "FontString", "ARTWORK", VIDEOOPTIONS_MENU)
  OptionsFrameHeaderText:ClearAllPoints()
  OptionsFrameHeaderText:SetPoint("TOP", OptionsFrame.backdrop, "TOP", 0, -10)

  SkinButton(OptionsFrameDefaults)
  SkinButton(OptionsFrameCancel)
  SkinButton(OptionsFrameOkay)
  OptionsFrameOkay:ClearAllPoints()
  OptionsFrameOkay:SetPoint("RIGHT", OptionsFrameCancel, "LEFT", -2*bpad, 0)

  SkinDropDown(OptionsFrameResolutionDropDown)
  SkinDropDown(OptionsFrameRefreshDropDown)
  SkinDropDown(OptionsFrameMultiSampleDropDown)

  CreateBackdrop(OptionsFrameDisplay, nil, true, .75)
  CreateBackdrop(OptionsFrameWorldAppearance, nil, true, .75)
  CreateBackdrop(OptionsFrameBrightness, nil, true, .75)
  CreateBackdrop(OptionsFramePixelShaders, nil, true, .75)
  CreateBackdrop(OptionsFrameMiscellaneous, nil, true, .75)

  for i=1, 9 do
    local shift = 0
    if i == 1 or i == 6 then shift = 4
    elseif i == 4 or i == 8 then shift = 10
    end
    SkinSlider(_G["OptionsFrameSlider"..i])
    local point, anchor, anchorPoint, x, y = _G["OptionsFrameSlider"..i]:GetPoint()
    _G["OptionsFrameSlider"..i]:ClearAllPoints()
    _G["OptionsFrameSlider"..i]:SetPoint(point, anchor, anchorPoint, x, y - shift)
  end

  for i=1, 18 do
    SkinCheckbox(_G["OptionsFrameCheckButton"..i], 28)
  end
end)
