pfUI:RegisterModule("mirrortimers", "vanilla:tbc", function ()
  local font = pfUI.font_default
  local fontsize = tonumber(C.global.font_size)
  local height = fontsize * 1.3

  for i = 1, MIRRORTIMER_NUMTIMERS do
    local frame = _G["MirrorTimer"..i]
    frame:GetRegions():Hide()
    frame:SetWidth(200)
    frame:SetHeight(height)
    frame:SetScript("OnUpdate", function()
      if this.paused or not this.timer then return end
      MirrorTimerFrame_OnUpdate(this, arg1)

      local text = this.label:GetText()
      if text and this.value then
        this.text:SetText(format("%s (%d:%02d)", text, this.value/60, this.value - math.floor(this.value/60)*60))
      end
    end)

    frame:ClearAllPoints()
    frame:SetPoint("TOP", UIParent, "TOP", 0, -120-(i-1)*(height + 10))

    CreateBackdrop(frame)
    CreateBackdropShadow(frame)
    UpdateMovable(frame)

    frame.border = _G["MirrorTimer"..i.."Border"]
    frame.border:Hide()

    frame.label = _G["MirrorTimer"..i.."Text"]
    frame.label:Hide()

    frame.statusbar = _G["MirrorTimer"..i.."StatusBar"]
    frame.statusbar:SetStatusBarTexture(pfUI.media["img:bar"])
    frame.statusbar:SetAllPoints(frame)

    frame.text = frame:CreateFontString(nil, "OVERLAY")
    frame.text:SetFont(font, fontsize, "OUTLINE")
    frame.text:SetPoint("CENTER", frame.statusbar, "CENTER", 0, 0)
  end
end)
