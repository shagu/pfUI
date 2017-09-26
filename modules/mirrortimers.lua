pfUI:RegisterModule("mirrortimers", function ()
  for i = 1, MIRRORTIMER_NUMTIMERS do
    _G["MirrorTimer" .. i]:GetRegions():Hide()
    _G["MirrorTimer" .. i .. "Border"]:Hide()
    _G["MirrorTimer"..i.."Text"]:SetFont(pfUI.font_default, 12, "OUTLINE")
  
    local mirrorTimerBar = _G["MirrorTimer" .. i .. "StatusBar"]
    mirrorTimerBar:SetPoint("TOP", 0, 0)
    mirrorTimerBar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    pfUI.api.CreateBackdrop(mirrorTimerBar)
  end
end)
