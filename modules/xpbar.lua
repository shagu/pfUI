pfUI.xp = CreateFrame("Frame",nil, pfUI.bars.bottom)
pfUI.xp:SetWidth(10)
pfUI.xp:SetPoint("TOPLEFT",pfUI.chat.left,"TOPRIGHT", 1, 0)
pfUI.xp:SetPoint("BOTTOMLEFT",pfUI.chat.left,"BOTTOMRIGHT",1, 0)
pfUI.xp:SetFrameStrata("BACKGROUND")
pfUI.xp:SetBackdrop(pfUI.backdrop)
pfUI.xp:RegisterEvent("PLAYER_LEVEL_UP")
pfUI.xp:RegisterEvent("PLAYER_XP_UPDATE")
pfUI.xp:RegisterEvent("PLAYER_ENTERING_WORLD")

pfUI.xp:SetScript("OnEvent", function()
    if UnitXPMax("player") ~= 0 then
      pfUI.xp.bar:SetMinMaxValues(0, UnitXPMax("player"))
      pfUI.xp.bar:SetValue(UnitXP("player"))
      if GetXPExhaustion() then
        pfUI.xp.restedbar:Show()
        pfUI.xp.restedbar:SetMinMaxValues(0, UnitXPMax("player"))
        pfUI.xp.restedbar:SetValue(UnitXP("player") + GetXPExhaustion())
        pfUI.xp.restedbar:SetAlpha(pfUI.xp:GetAlpha()/2)
      else
        pfUI.xp.restedbar:Hide()
      end
      pfUI.xp:SetAlpha(1)
      pfUI.xp.tick = GetTime() + 3.00

    else
      pfUI.xp:Hide(0)
    end
  end)

pfUI.xp:SetScript("OnUpdate",function()
    if pfUI.xp:GetAlpha() == 0 or pfUI.xp.mouseover == true then return end
    if not pfUI.xp.tick then
      pfUI.xp.tick = GetTime() + 0.01
    end

    if GetTime() >= pfUI.xp.tick then
      pfUI.xp.tick = nil
      pfUI.xp:SetAlpha(pfUI.xp:GetAlpha() - .05)
      pfUI.xp.restedbar:SetAlpha(pfUI.xp:GetAlpha()/2)
    end
  end);

pfUI.xp:EnableMouse()
pfUI.xp:SetScript("OnEnter", function()
    pfUI.xp.mouseover = true
    pfUI.xp:SetAlpha(1)
    pfUI.xp.restedbar:SetAlpha(pfUI.xp:GetAlpha()/2)

  end)

pfUI.xp:SetScript("OnLeave", function()
    pfUI.xp.mouseover = false
    pfUI.xp.tick = GetTime() + 3.00
  end)

pfUI.xp.bar = CreateFrame("StatusBar", nil, pfUI.xp)
pfUI.xp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
pfUI.xp.bar:ClearAllPoints()
pfUI.xp.bar:SetPoint("TOPLEFT", pfUI.xp, "TOPLEFT", 3, -3)
pfUI.xp.bar:SetPoint("BOTTOMRIGHT", pfUI.xp, "BOTTOMRIGHT", -3, 3)
pfUI.xp.bar:SetStatusBarColor(.25,.25,1,1)
pfUI.xp.bar:SetMinMaxValues(0, 100)
pfUI.xp.bar:SetOrientation("VERTICAL")
pfUI.xp.bar:SetValue(59)

pfUI.xp.restedbar = CreateFrame("StatusBar", nil, pfUI.xp)
pfUI.xp.restedbar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
pfUI.xp.restedbar:ClearAllPoints()
pfUI.xp.restedbar:SetPoint("TOPLEFT", pfUI.xp, "TOPLEFT", 3, -3)
pfUI.xp.restedbar:SetPoint("BOTTOMRIGHT", pfUI.xp, "BOTTOMRIGHT", -3, 3)
pfUI.xp.restedbar:SetFrameStrata("HIGH")
pfUI.xp.restedbar:SetStatusBarColor(1,.25,1,1)
pfUI.xp.restedbar:SetMinMaxValues(0, 100)
pfUI.xp.restedbar:SetOrientation("VERTICAL")

pfUI.rep = CreateFrame("Frame",nil, pfUI.bars.bottom)
pfUI.rep:SetWidth(10)
pfUI.rep:SetPoint("TOPRIGHT",pfUI.chat.right,"TOPLEFT", -1, 0)
pfUI.rep:SetPoint("BOTTOMRIGHT",pfUI.chat.right,"BOTTOMLEFT",-1, 0)
pfUI.rep:SetFrameStrata("BACKGROUND")
pfUI.rep:SetBackdrop(pfUI.backdrop)

pfUI.rep.bar = CreateFrame("StatusBar", nil, pfUI.rep)
pfUI.rep.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
pfUI.rep.bar:ClearAllPoints()
pfUI.rep.bar:SetPoint("TOPLEFT", pfUI.rep, "TOPLEFT", 3, -3)
pfUI.rep.bar:SetPoint("BOTTOMRIGHT", pfUI.rep, "BOTTOMRIGHT", -3, 3)
pfUI.rep.bar:SetMinMaxValues(0, 100)
pfUI.rep.bar:SetOrientation("VERTICAL")
pfUI.rep.bar:SetValue(59)

pfUI.rep:RegisterEvent("UPDATE_FACTION")
pfUI.rep:RegisterEvent("PLAYER_ENTERING_WORLD")

pfUI.rep:SetScript("OnEvent", function()
    pfUI.rep:SetAlpha(0)
    for i=1, GetNumFactions() do
      local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(i);
      if isWatched then
        barMax = barMax - barMin;
        barValue = barValue - barMin;
        barMin = 0;

        pfUI.rep.bar:SetMinMaxValues(barMin, barMax)
        pfUI.rep.bar:SetValue(barValue)
        local color = FACTION_BAR_COLORS[standingID];
        pfUI.rep.bar:SetStatusBarColor((color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5, 1)
        pfUI.rep:SetAlpha(1)
        pfUI.rep.tick = GetTime() + 3.00

      end
    end
  end)

pfUI.rep:SetScript("OnUpdate",function()
    if pfUI.rep:GetAlpha() == 0 or pfUI.rep.mouseover == true then return end
    if not pfUI.rep.tick then
      pfUI.rep.tick = GetTime() + 0.01
    end

    if GetTime() >= pfUI.rep.tick then
      pfUI.rep.tick = nil
      pfUI.rep:SetAlpha(pfUI.rep:GetAlpha() - .05)
    end
  end)

pfUI.rep:EnableMouse()
pfUI.rep:SetScript("OnEnter", function()
    pfUI.rep.mouseover = true
    pfUI.rep:SetAlpha(1)
  end)

pfUI.rep:SetScript("OnLeave", function()
    pfUI.rep.mouseover = false
    pfUI.rep.tick = GetTime() + 3.00
  end)
