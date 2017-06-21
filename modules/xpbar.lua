pfUI:RegisterModule("xpbar", function ()
  pfUI.xp = CreateFrame("Frame",nil, UIParent)
  pfUI.xp:SetWidth(5)
  if pfUI.chat then
    pfUI.xp:SetPoint("TOPLEFT", pfUI.chat.left, "TOPRIGHT", C.appearance.border.default*2, 0)
    pfUI.xp:SetPoint("BOTTOMLEFT", pfUI.chat.left, "BOTTOMRIGHT", C.appearance.border.default*2, 0)
  else
    pfUI.xp:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
    pfUI.xp:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
  end
  pfUI.xp:SetFrameStrata("BACKGROUND")
  CreateBackdrop(pfUI.xp)
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
      if C.panel.xp.showalways == "1" then return end
      if pfUI.xp:GetAlpha() == 0 or pfUI.xp.mouseover == true then return end
      if not pfUI.xp.tick then
        pfUI.xp.tick = GetTime() + 0.01
      end

      if GetTime() >= pfUI.xp.tick then
        pfUI.xp.tick = nil
        pfUI.xp:SetAlpha(pfUI.xp:GetAlpha() - .05)
      end
    end)

  pfUI.xp:EnableMouse()
  pfUI.xp:SetScript("OnEnter", function()
      pfUI.xp.mouseover = true
      pfUI.xp:SetAlpha(1)
      local xp, xpmax, exh = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
      local xp_perc = round(xp / xpmax * 100)
      local remaining = xpmax - xp
      local remaining_perc = round(remaining / xpmax * 100)
      local exh_perc = 0
      if GetXPExhaustion() then
        exh_perc = round(GetXPExhaustion() / xpmax * 100)
      end

      GameTooltip:ClearLines()
      GameTooltip_SetDefaultAnchor(GameTooltip, this)
      GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
      GameTooltip:AddDoubleLine("|cff555555Experience")
      GameTooltip:AddDoubleLine("XP", "|cffffffff" .. xp .. " / " .. xpmax .. " (" .. xp_perc .. "%)")
      GameTooltip:AddDoubleLine("Remaining", "|cffffffff" .. remaining .. " (" .. remaining_perc .. "%)")
      if IsResting() then
        GameTooltip:AddDoubleLine("Status", "|cffffffffResting")
      end
      if GetXPExhaustion() then
        GameTooltip:AddDoubleLine("Rested", "|cff5555ff+" .. exh .. " (" .. exh_perc .. "%)")
      end
      GameTooltip:Show()
    end)

  pfUI.xp:SetScript("OnLeave", function()
      pfUI.xp.mouseover = false
      pfUI.xp.tick = GetTime() + 3.00
      GameTooltip:Hide()
    end)

  pfUI.xp.bar = CreateFrame("StatusBar", nil, pfUI.xp)
  pfUI.xp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.xp.bar:ClearAllPoints()
  pfUI.xp.bar:SetAllPoints(pfUI.xp)
  pfUI.xp.bar:SetFrameStrata("MEDIUM")
  pfUI.xp.bar:SetStatusBarColor(.25,.25,1,1)
  pfUI.xp.bar:SetMinMaxValues(0, 100)
  pfUI.xp.bar:SetOrientation("VERTICAL")
  pfUI.xp.bar:SetValue(59)

  pfUI.xp.restedbar = CreateFrame("StatusBar", nil, pfUI.xp)
  pfUI.xp.restedbar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.xp.restedbar:ClearAllPoints()
  pfUI.xp.restedbar:SetAllPoints(pfUI.xp)
  pfUI.xp.restedbar:SetFrameStrata("HIGH")
  pfUI.xp.restedbar:SetStatusBarColor(1,.25,1,.5)
  pfUI.xp.restedbar:SetMinMaxValues(0, 100)
  pfUI.xp.restedbar:SetOrientation("VERTICAL")

  pfUI.rep = CreateFrame("Frame",nil, UIParent)
  pfUI.rep:SetWidth(5)
  if pfUI.chat then
    pfUI.rep:SetPoint("TOPRIGHT",pfUI.chat.right,"TOPLEFT", -C.appearance.border.default*2, 0)
    pfUI.rep:SetPoint("BOTTOMRIGHT",pfUI.chat.right,"BOTTOMLEFT",-C.appearance.border.default*2, 0)
  else
    pfUI.rep:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
    pfUI.rep:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
  end
  pfUI.rep:SetFrameStrata("BACKGROUND")
  CreateBackdrop(pfUI.rep)

  pfUI.rep.bar = CreateFrame("StatusBar", nil, pfUI.rep)
  pfUI.rep.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.rep.bar:ClearAllPoints()
  pfUI.rep.bar:SetAllPoints(pfUI.rep)
  pfUI.rep.bar:SetMinMaxValues(0, 100)
  pfUI.rep.bar:SetOrientation("VERTICAL")
  pfUI.rep.bar:SetValue(59)

  pfUI.rep:RegisterEvent("UPDATE_FACTION")
  pfUI.rep:RegisterEvent("PLAYER_ENTERING_WORLD")

  pfUI.rep:SetScript("OnEvent", function()
      pfUI.rep:SetAlpha(0)
      for i=1, GetNumFactions() do
        local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(i)
        if isWatched then
          barMax = barMax - barMin
          barValue = barValue - barMin
          barMin = 0

          pfUI.rep.bar:SetMinMaxValues(barMin, barMax)
          pfUI.rep.bar:SetValue(barValue)
          local color = FACTION_BAR_COLORS[standingID]
          pfUI.rep.bar:SetStatusBarColor((color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5, 1)
          pfUI.rep:SetAlpha(1)
          pfUI.rep.tick = GetTime() + 3.00
        end
      end
    end)

  pfUI.rep:SetScript("OnUpdate",function()
      if C.panel.xp.showalways == "1" then return end
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
      for i=1, GetNumFactions() do
        local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(i)
        if isWatched then
          barMax = barMax - barMin
          barValue = barValue - barMin
          barMin = 0

          local color = FACTION_BAR_COLORS[standingID]
          if not color then color = 1,1,1 end

          GameTooltip:ClearLines()
          GameTooltip_SetDefaultAnchor(GameTooltip, this)
          GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
          GameTooltip:AddLine("|cff555555Reputation")
          GameTooltip:AddLine(name .. " (" .. GetText("FACTION_STANDING_LABEL"..standingID, gender) .. ")", color.r + .3, color.g + .3, color.b + .3)
          GameTooltip:AddLine(barValue .. " / " .. barMax .. " (" .. round(barValue / barMax * 100) .. "%)",1,1,1)
          GameTooltip:Show()

          pfUI.rep.mouseover = true
          pfUI.rep:SetAlpha(1)
        end
      end
    end)

  pfUI.rep:SetScript("OnLeave", function()
      pfUI.rep.mouseover = false
      pfUI.rep.tick = GetTime() + 3.00
      GameTooltip:Hide()
    end)
end)
