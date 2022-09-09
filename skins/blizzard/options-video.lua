pfUI:RegisterSkin("Options - Video", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  -- Compatibility
  local MAX_SLIDERS, MAX_CHECKBOXES
  if OptionsFrameSlider10 then -- tbc
    MAX_SLIDERS = 11
    MAX_CHECKBOXES = 19

    for i=1, MAX_SLIDERS do
      local slider = _G["OptionsFrameSlider"..i]
      local shift = 0
      if i == 4 or i == 5 or i == 7 or i == 8 or i == 10 or i == 11 then shift = 10 end
      local point, anchor, anchorPoint, x, y = slider:GetPoint()
      slider:ClearAllPoints()
      slider:SetPoint(point, anchor, anchorPoint, x, y - shift)
    end

    hooksecurefunc("OptionsFrame_Load", function()
      OptionsFramePixelShaders:SetWidth(230)
      OptionsFrameMiscellaneous:ClearAllPoints()
      OptionsFrameMiscellaneous:SetPoint("LEFT", OptionsFramePixelShaders, "RIGHT", 6, 0)
    end)
    OptionsFrameDefaults:ClearAllPoints()
    OptionsFrameDefaults:SetPoint("TOPLEFT", OptionsFramePixelShaders, "BOTTOMLEFT", 0, -10)
    OptionsFrameCancel:ClearAllPoints()
    OptionsFrameCancel:SetPoint("TOPRIGHT", OptionsFrameMiscellaneous, "BOTTOMRIGHT", 0, -10)
  else -- vanilla
    MAX_SLIDERS = 9
    MAX_CHECKBOXES = 18

    for i=1, MAX_SLIDERS do
      local slider = _G["OptionsFrameSlider"..i]
      local shift = 0
      if i == 1 or i == 6 then shift = 4
      elseif i == 4 or i == 8 then shift = 10
      end
      local point, anchor, anchorPoint, x, y = slider:GetPoint()
      slider:ClearAllPoints()
      slider:SetPoint(point, anchor, anchorPoint, x, y - shift)
    end
  end

  CreateBackdrop(OptionsFrame, nil, nil, .75)
  CreateBackdropShadow(OptionsFrame)

  EnableMovable(OptionsFrame)

  HookScript(OptionsFrame, "OnShow", function()
    this:ClearAllPoints()
    this:SetPoint("CENTER", 0, 0)
  end)

  OptionsFrameHeader:SetTexture("")
  local OptionsFrameHeaderText = GetNoNameObject(OptionsFrame, "FontString", "ARTWORK", VIDEOOPTIONS_MENU)
  OptionsFrameHeaderText:ClearAllPoints()
  OptionsFrameHeaderText:SetPoint("TOP", OptionsFrame.backdrop, "TOP", 0, -10)

  CreateBackdrop(OptionsFrameDisplay, nil, true, .75)
  CreateBackdrop(OptionsFrameWorldAppearance, nil, true, .75)
  CreateBackdrop(OptionsFrameBrightness, nil, true, .75)
  CreateBackdrop(OptionsFramePixelShaders, nil, true, .75)
  CreateBackdrop(OptionsFrameMiscellaneous, nil, true, .75)

  SkinButton(OptionsFrameDefaults)
  SkinButton(OptionsFrameCancel)
  SkinButton(OptionsFrameOkay)
  OptionsFrameOkay:ClearAllPoints()
  OptionsFrameOkay:SetPoint("RIGHT", OptionsFrameCancel, "LEFT", -2*bpad, 0)

  SkinDropDown(OptionsFrameResolutionDropDown)
  SkinDropDown(OptionsFrameRefreshDropDown)
  SkinDropDown(OptionsFrameMultiSampleDropDown)

  for i=1, MAX_SLIDERS do
    SkinSlider(_G["OptionsFrameSlider"..i])
  end

  for i=1, MAX_CHECKBOXES do
    local btn = _G["OptionsFrameCheckButton"..i]
    if btn then
      SkinCheckbox(btn, 28)
    end
  end
end)
