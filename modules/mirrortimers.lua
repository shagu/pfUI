pfUI:RegisterModule("mirrortimers", function ()
  for i = 1, MIRRORTIMER_NUMTIMERS do
    local mirrorTimer = _G["MirrorTimer"..i]
    local statusBar = _G["MirrorTimer"..i.."StatusBar"]
    local text = _G["MirrorTimer"..i.."Text"]
    local border = _G["MirrorTimer"..i.."Border"]

    text:Hide()
    border:Hide()

    mirrorTimer:GetRegions():Hide()
    mirrorTimer.label = text
    mirrorTimer.scale = 1
    mirrorTimer.value = 0

    statusBar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    statusBar:SetWidth(222)
    statusBar:SetHeight(18)
    statusBar:SetPoint("TOP", 0, 0)
    CreateBackdrop(statusBar)

    mirrorTimer:SetWidth(statusBar:GetWidth())
    mirrorTimer:SetHeight(statusBar:GetHeight())

    if (i ~= 1) then
      mirrorTimer:ClearAllPoints()
      mirrorTimer:SetPoint("CENTER", _G["MirrorTimer"..(i-1)], "CENTER", 0, -26)
    end

    UpdateMovable(mirrorTimer)

    local TimerText = mirrorTimer:CreateFontString(nil, "OVERLAY")
    TimerText:SetFont(pfUI.font_default, 12, "OUTLINE")
    TimerText:SetPoint("CENTER", statusBar, "CENTER", 0, 0)
    mirrorTimer.TimerText = TimerText

    hooksecurefunc("MirrorTimerFrame_OnUpdate", function(frame, elapsed)
      if frame.paused then return end
      if not frame.value then return end
      if not frame.scale then return end

      local minutes = frame.value / 60
      local seconds = frame.value - math.floor(frame.value / 60) * 60
      local text = frame.label:GetText()

      if not text then return end

      if not frame:IsShown() then frame:Show() end

      if frame.value > 0 then
        frame.TimerText:SetText(format("%s (%d:%02d)", text, minutes, seconds))
      else
        frame.TimerText:SetText(format("%s (0:00)", text))
      end
    end)
  end
end)
