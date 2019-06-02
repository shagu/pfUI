pfUI:RegisterSkin("Options - Sound", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  StripTextures(SoundOptionsFrame)
  CreateBackdrop(SoundOptionsFrame, nil, true, .75)
  CreateBackdropShadow(SoundOptionsFrame)

  EnableMovable(SoundOptionsFrame)

  HookScript(SoundOptionsFrame, "OnShow", function()
    this:ClearAllPoints()
    this:SetPoint("CENTER", 0, 0)
  end)

  local SoundOptionsFrameHeaderText = GetNoNameObject(SoundOptionsFrame, "FontString", "ARTWORK", SOUNDOPTIONS_MENU)
  SoundOptionsFrameHeaderText:ClearAllPoints()
  SoundOptionsFrameHeaderText:SetPoint("TOP", 0, -10)

  SkinButton(SoundOptionsFrameDefaults)
  SkinButton(SoundOptionsFrameCancel)
  SkinButton(SoundOptionsFrameOkay)
  SoundOptionsFrameOkay:ClearAllPoints()
  SoundOptionsFrameOkay:SetPoint("RIGHT", SoundOptionsFrameCancel, "LEFT", -2*bpad, 0)

  for i=1, 8 do
    if i == 3 then i = 4 end -- Blizzard missed this number...
    SkinCheckbox(_G["SoundOptionsFrameCheckButton"..i], 28)
  end

  SkinSlider(SoundOptionsFrameSlider1)
  SoundOptionsFrameSlider1:ClearAllPoints()
  SoundOptionsFrameSlider1:SetPoint("TOPRIGHT", SoundOptionsFrame, "TOPRIGHT", -18, -43)
  for i=2, 4 do
    SkinSlider(_G["SoundOptionsFrameSlider"..i])
    _G["SoundOptionsFrameSlider"..i]:ClearAllPoints()
    _G["SoundOptionsFrameSlider"..i]:SetPoint("TOP", _G["SoundOptionsFrameSlider"..i-1], "BOTTOM", 0, -30)
  end
end)
