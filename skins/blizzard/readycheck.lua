pfUI:RegisterSkin("Readycheck", "vanilla", function ()
  HookAddonOrVariable("Blizzard_RaidUI", function()
    StripTextures(ReadyCheckFrame, true)
    CreateBackdrop(ReadyCheckFrame, nil, nil, .75)
    CreateBackdropShadow(ReadyCheckFrame)

    SkinButton(ReadyCheckFrameYesButton)
    ReadyCheckFrameYesButton:ClearAllPoints()
    ReadyCheckFrameYesButton:SetPoint("RIGHT", ReadyCheckFrame, "BOTTOM", -8, 24)

    SkinButton(ReadyCheckFrameNoButton)
    ReadyCheckFrameNoButton:ClearAllPoints()
    ReadyCheckFrameNoButton:SetPoint("LEFT", ReadyCheckFrame, "BOTTOM", 8, 24)

    ReadyCheckFrameText:ClearAllPoints()
    ReadyCheckFrameText:SetPoint("TOP", ReadyCheckFrame, "TOP", 0, -12)

    local frame = CreateFrame("Button", nil, ReadyCheckFrame)
    frame:SetPoint("TOP", ReadyCheckFrameText, "BOTTOM", 0, -6)
    frame:SetWidth(220)
    frame:SetHeight(10)

    frame.bar = CreateFrame("StatusBar", "ReadyCheckFrameStatusBar", ReadyCheckFrame)
    frame.bar:SetStatusBarTexture(pfUI.media["img:bar"])
    frame.bar:SetAllPoints(frame)

    frame.bar.text = frame.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
    frame.bar.text:SetFontObject(GameFontWhite)
    frame.bar.text:SetFont(pfUI.font_default, 12, "OUTLINE")
    frame.bar.text:SetPoint("CENTER", 0, 0)

    local max
    hooksecurefunc("ShowReadyCheck", function()
      max = ReadyCheckFrame.timer
      frame.bar:SetMinMaxValues(0, max)
    end, 1)

    hooksecurefunc("ReadyCheck_OnUpdate", function()
      if not ReadyCheckFrame.timer then return end

      local perc = ReadyCheckFrame.timer/max
      frame.bar:SetStatusBarColor(GetColorGradient(perc))
      frame.bar:SetValue(ReadyCheckFrame.timer)
      frame.bar.text:SetText(round(ReadyCheckFrame.timer, 2))
    end, 1)
  end)
end)
