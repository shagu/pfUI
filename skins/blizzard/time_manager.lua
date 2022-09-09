pfUI:RegisterSkin("Time Manager", "tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  HookAddonOrVariable("Blizzard_TimeManager", function()
    do -- TimeManagerFrame
      StripTextures(TimeManagerFrame)
      CreateBackdrop(TimeManagerFrame, nil, nil, .75)
      CreateBackdropShadow(TimeManagerFrame)
      TimeManagerClockButton:Hide()
      TimeManagerClockButton.Show = function() return end

      TimeManagerFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
      TimeManagerFrame.backdrop:SetPoint("BOTTOMRIGHT", -48, 1)
      TimeManagerFrame:SetHitRectInsets(10,48,10,1)
      EnableMovable(TimeManagerFrame)

      SkinCloseButton(TimeManagerCloseButton, TimeManagerFrame.backdrop, -6, -6)

      local header = GetNoNameObject(TimeManagerFrame, 'FontString', 'BORDER', TIMEMANAGER_TITLE)
      header:ClearAllPoints()
      header:SetPoint("TOP", TimeManagerFrame.backdrop, "TOP", 0, -10)

      TimeManagerFrameTicker:ClearAllPoints()
      TimeManagerFrameTicker:SetPoint("TOPLEFT", TimeManagerFrame.backdrop, "TOPLEFT", 30, -37)

      StripTextures(TimeManagerStopwatchFrame)
      local texture = TimeManagerStopwatchCheck:GetNormalTexture():GetTexture()
      SkinButton(TimeManagerStopwatchCheck)
      TimeManagerStopwatchCheck:SetNormalTexture(texture)
      HandleIcon(TimeManagerStopwatchCheck, TimeManagerStopwatchCheck:GetNormalTexture())

      local frames = {
        [TimeManagerAlarmHourDropDown] = '0',
        [TimeManagerAlarmMinuteDropDown] = '1',
        [TimeManagerAlarmAMPMDropDown] = '-4'
      }
      for frame,Xoffset in pairs(frames) do
        SkinDropDown(frame, nil, nil, nil, true)
        local text = _G[frame:GetName().."Text"]
        local left = _G[frame:GetName().."Left"]
        text:ClearAllPoints()
        text:SetPoint("LEFT", left, "LEFT", Xoffset, 1)
      end
      TimeManagerAlarmHourDropDown:ClearAllPoints()
      TimeManagerAlarmHourDropDown:SetPoint("TOPLEFT", TimeManagerAlarmTimeLabel, "BOTTOMLEFT", -4, -4)

      TimeManagerAlarmMessageFrame:ClearAllPoints()
      TimeManagerAlarmMessageFrame:SetPoint("TOPLEFT", TimeManagerAlarmTimeFrame, "BOTTOMLEFT", 0, 0)

      TimeManagerAlarmMessageEditBox:DisableDrawLayer("BACKGROUND")
      CreateBackdrop(TimeManagerAlarmMessageEditBox)
      TimeManagerAlarmMessageEditBox:ClearAllPoints()
      TimeManagerAlarmMessageEditBox:SetWidth(142)
      TimeManagerAlarmMessageEditBox:SetPoint("TOPLEFT", TimeManagerAlarmMessageLabel, "BOTTOMLEFT", 13, -5)

      SkinButton(TimeManagerAlarmEnabledButton)
      TimeManagerAlarmEnabledButton.SetNormalTexture = function() end
      TimeManagerAlarmEnabledButton.SetPushedTexture = function() end
      hooksecurefunc("TimeManagerAlarmEnabledButton_Update", function()
        if TimeManagerAlarmEnabledButton:GetText() == TIMEMANAGER_ALARM_ENABLED then
          TimeManagerAlarmEnabledButton:LockHighlight()
        else
          TimeManagerAlarmEnabledButton:UnlockHighlight()
        end
      end)
      TimeManagerAlarmEnabledButton:ClearAllPoints()
      TimeManagerAlarmEnabledButton:SetWidth(146)
      TimeManagerAlarmEnabledButton:SetPoint("TOP", TimeManagerAlarmMessageEditBox, "BOTTOM", 0, -8)


      SkinCheckbox(TimeManagerMilitaryTimeCheck)
      SkinCheckbox(TimeManagerLocalTimeCheck)
    end

    do -- StopwatchFrame
      StripTextures(StopwatchFrame)

      StripTextures(StopwatchTabFrame)
      CreateBackdrop(StopwatchTabFrame, nil, true)
      StopwatchTabFrame:SetWidth(122)
      StopwatchTabFrame:SetHeight(18)
      StopwatchTitle:ClearAllPoints()
      StopwatchTitle:SetPoint("CENTER", 0, 0)
      SkinCloseButton(StopwatchCloseButton, StopwatchTabFrame, 0, 0)

      local orig = StopwatchResetButton.SetNormalTexture
      StopwatchResetButton.SetNormalTexture = function(self, tex)
        orig(self, tex)
        local texture = self:GetNormalTexture()
        texture:SetDesaturated(1)
        texture:SetTexCoord(.25, .75, .28, .78)
      end
      SkinButton(StopwatchResetButton, nil, nil, nil, StopwatchResetButton:GetNormalTexture())
      StopwatchResetButton:SetNormalTexture("Interface\\TimeManager\\ResetButton") -- initiate update texture
      StopwatchResetButton:ClearAllPoints()
      StopwatchResetButton:SetWidth(20)
      StopwatchResetButton:SetHeight(20)
      StopwatchResetButton:SetPoint("TOPRIGHT", StopwatchTabFrame, "BOTTOMRIGHT", 0, -2*border + 1)

      local orig = StopwatchPlayPauseButton.SetNormalTexture
      StopwatchPlayPauseButton.SetNormalTexture = function(self, tex)
        orig(self, tex)
        local texture = self:GetNormalTexture()
        texture:SetDesaturated(1)
        texture:SetTexCoord(.25, .75, .28, .78)
      end
      SkinButton(StopwatchPlayPauseButton, nil, nil, nil, StopwatchPlayPauseButton:GetNormalTexture())
      StopwatchPlayPauseButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up") -- initiate update texture
      StopwatchPlayPauseButton:ClearAllPoints()
      StopwatchPlayPauseButton:SetWidth(20)
      StopwatchPlayPauseButton:SetHeight(20)
      StopwatchPlayPauseButton:SetPoint("RIGHT", StopwatchResetButton, "LEFT", -2*bpad, 0)

      CreateBackdrop(StopwatchTicker)
      StopwatchTicker:ClearAllPoints()
      StopwatchTicker:SetWidth(70)
      StopwatchTicker:SetHeight(16)
      StopwatchTicker:SetPoint("RIGHT", StopwatchPlayPauseButton, "LEFT", -2*border + 1, 0)
    end
  end)
end)
