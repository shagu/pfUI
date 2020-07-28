pfUI:RegisterModule("xpbar", "vanilla:tbc", function ()
  local rawborder, default_border = GetBorderSize()
  local parse_faction = SanitizePattern(FACTION_STANDING_INCREASED)

  local data = CreateFrame("Frame", "pfExperienceBarData", UIParent)
  data:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
  data:RegisterEvent("PLAYER_ENTERING_WORLD")
  data:RegisterEvent("PLAYER_LEVEL_UP")
  data:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
      this.starttime = GetTime()
      this.startxp = UnitXP("player") or 0
    elseif event == "PLAYER_LEVEL_UP" then
      -- add previously gained experience to the session
      this.startxp = this.startxp - UnitXPMax("player")
    elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
      local _,_, faction, amount = string.find(arg1, parse_faction)
      this.faction = faction or this.faction
    end
  end)

  local function OnLeave(self)
    local self = self or this

    self.tick = GetTime() + 3.00
    GameTooltip:Hide()
  end

local function OnEnter(self)
  local self = self or this
  local lines = {}

  -- set either experience, reputation or flex-rep handler
  local mode = self.display
  if self.display == "XPFLEX" then
    mode = UnitLevel("player") < MAX_LEVEL and "XP" or "REP"
  elseif self.display == "FLEX" then
    mode = "REP"
  end

  self:SetAlpha(1)

  if mode == "XP" then
    local xp, xpmax, exh = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
    local xp_perc = round(xp / xpmax * 100)
    local remaining = xpmax - xp
    local remaining_perc = round(remaining / xpmax * 100)
    local exh_perc = GetXPExhaustion() and round(GetXPExhaustion() / xpmax * 100) or 0
    local xp_persec = ((xp - data.startxp)/(GetTime() - data.starttime))
    local session = UnitXP("player") - data.startxp
    local avg_hour = floor(((UnitXP("player") - data.startxp) / (GetTime() - data.starttime)) * 60 * 60)
    local time_remaining = xp_persec > 0 and SecondsToTime(remaining/xp_persec) or 0

    -- fill gametooltip data
    table.insert(lines, { "|cff555555" .. T["Experience"], "" })
    table.insert(lines, { T["XP"], "|cffffffff" .. xp .. " / " .. xpmax .. " (" .. xp_perc .. "%)" })
    table.insert(lines, { T["Remaining"], "|cffffffff" .. remaining .. " (" .. remaining_perc .. "%)" })
    if IsResting() then
      table.insert(lines, { T["Status"], "|cffffffff" .. T["Resting"] })
    end
    if GetXPExhaustion() then
      table.insert(lines, { T["Rested"], "|cff5555ff+" .. exh .. " (" .. exh_perc .. "%)" })
    end
    table.insert(lines, { "" })
    table.insert(lines, { T["This Session"], "|cffffffff" .. session })
    table.insert(lines, { T["Average Per Hour"], "|cffffffff" .. avg_hour })
    table.insert(lines, { T["Time Remaining"], "|cffffffff" .. time_remaining })
  elseif mode == "REP" then
    for i=1, 99 do
      local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(i)
      if ( isWatched and not self.faction ) or ( self.faction and name == self.faction) then
        barMax = barMax - barMin
        barValue = barValue - barMin

        local color = FACTION_BAR_COLORS[standingID]
        if color then
          color = rgbhex(color.r + .3, color.g + .3, color.b + .3)
        else
          color = rgbhex(.5, .5, .5)
        end

        table.insert(lines, { "|cff555555" .. T["Reputation"], "" })
        table.insert(lines, { color .. name .. " (" .. GetText("FACTION_STANDING_LABEL"..standingID, gender) .. ")"})
        table.insert(lines, { barValue .. " / " .. barMax .. " (" .. round(barValue / barMax * 100) .. "%)" })
        break
      end
    end
  end

  -- draw tooltip
  GameTooltip:ClearLines()
  GameTooltip_SetDefaultAnchor(GameTooltip, self)
  GameTooltip:SetOwner(self, "ANCHOR_CURSOR")

  for id, data in pairs(lines) do
    if data[2] then
      GameTooltip:AddDoubleLine(data[1], data[2])
    else
      GameTooltip:AddLine(data[1])
    end
  end
  GameTooltip:Show()
end

  local function OnUpdate(self)
    local self = self or this

    if self.always then return end
    if self:GetAlpha() == 0 or MouseIsOver(self) then return end
    if ( self.tick or 1) > GetTime() then return else self.tick = GetTime() + .01 end
    self:SetAlpha(self:GetAlpha() - .05)
  end

  local function OnEvent(self)
    local self = self or this

    -- realign when entering world to ensure all frames got loaded
    AlignToPosition(self, _G[self.anchor], self.position, default_border*3)
    UpdateMovable(self, true)

    -- set either experience, reputation or flex-rep handler
    local mode = self.display
    if self.display == "XPFLEX" then
      self.faction = data.faction or nil
      mode = UnitLevel("player") < MAX_LEVEL and "XP" or "REP"
    elseif self.display == "FLEX" then
      self.faction = data.faction or nil
      mode = "REP"
    end

    if self.always then
      self:SetAlpha(1)
      self:Show()
    end

    -- skip on events of no interest
    if mode == "XP" and ( event == "CHAT_MSG_COMBAT_FACTION_CHANGE" or event == "UPDATE_FACTION" ) then return end
    if mode == "REP" and event == "PLAYER_XP_UPDATE" then return end

    if mode == "XP" then
      self.enabled = true
      self:SetAlpha(1)
      self.bar:SetMinMaxValues(0, UnitXPMax("player"))
      self.bar:SetValue(UnitXP("player"))
      if GetXPExhaustion() then
        self.restedbar:Show()
        self.restedbar:SetMinMaxValues(0, UnitXPMax("player"))
        self.restedbar:SetValue(UnitXP("player") + GetXPExhaustion())
      else
        self.restedbar:Hide()
      end

      self.tick = GetTime() + self.timeout
      return
    elseif mode == "REP" then
      self.restedbar:Hide()

      for i=1, 99 do
        local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(i)
        if ( isWatched and not self.faction ) or ( self.faction and name == self.faction) then
          self.enabled = true
          self:SetAlpha(1)

          barMax = barMax - barMin
          barValue = barValue - barMin

          self.bar:SetMinMaxValues(0, barMax)
          self.bar:SetValue(barValue)

          local color = FACTION_BAR_COLORS[standingID]
          if color then
            self.bar:SetStatusBarColor((color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5, 1)
          else
            self.bar:SetStatusBarColor(.5,.5,.5,1)
          end

          self.tick = GetTime() + self.timeout
          return
        end
      end
    end

    self.bar:SetStatusBarColor(.5,.5,.5,1)
    self.bar:SetMinMaxValues(0, 1)
    self.bar:SetValue(0)
  end

  local function CreateBar(t)
    local name = t == "XP" and "pfExperienceBar" or "pfReputationBar"
    local b = _G[name] or CreateFrame("Frame", name, UIParent)

    b.xp_color = C.panel.xp.xp_color
    b.rest_color = C.panel.xp.rest_color
    b.width = t == "XP" and C.panel.xp.xp_width or C.panel.xp.rep_width
    b.height = t == "XP" and C.panel.xp.xp_height or C.panel.xp.rep_height
    b.mode = t == "XP" and C.panel.xp.xp_mode or C.panel.xp.rep_mode
    b.timeout = t == "XP" and tonumber(C.panel.xp.xp_timeout) or tonumber(C.panel.xp.rep_timeout)
    b.anchor = t == "XP" and C.panel.xp.xp_anchor or C.panel.xp.rep_anchor
    b.position = t == "XP" and C.panel.xp.xp_position or C.panel.xp.rep_position
    b.display = t == "XP" and C.panel.xp.xp_display or C.panel.xp.rep_display

    local barStrata = "LOW"
    local restedStrata = "MEDIUM"
    
    if C.panel.xp.dont_overlap == "1" then
      barStrata = "MEDIUM"
      restedStrata = "LOW"
    end

    if t == "XP" and C.panel.xp.xp_always == "1" then
      b.always = true
    elseif t == "REP" and C.panel.xp.rep_always == "1" then
      b.always = true
    else
      b.always = nil
    end

    b:SetWidth(b.width)
    b:SetHeight(b.height)
    b:SetFrameStrata("BACKGROUND")

    AlignToPosition(b, _G[b.anchor], b.position, default_border*3)
    UpdateMovable(b, true)
    CreateBackdrop(b)
    CreateBackdropShadow(b)

    b.bar = b.bar or CreateFrame("StatusBar", nil, b)
    b.bar:SetStatusBarTexture(pfUI.media["img:bar"])
    b.bar:ClearAllPoints()
    b.bar:SetAllPoints(b)
    b.bar:SetFrameStrata(barStrata)

    local cr, cg, cb, ca = pfUI.api.GetStringColor(b.xp_color)
    b.bar:SetStatusBarColor(cr,cg,cb,ca)
    b.bar:SetOrientation(b.mode)

    b.restedbar = b.restedbar or CreateFrame("StatusBar", nil, b)
    b.restedbar:SetStatusBarTexture(pfUI.media["img:bar"])
    b.restedbar:ClearAllPoints()
    b.restedbar:SetAllPoints(b)
    b.restedbar:SetFrameStrata(restedStrata)
    local cr, cg, cb, ca = pfUI.api.GetStringColor(b.rest_color)
    b.restedbar:SetStatusBarColor(cr,cg,cb,ca)
    b.restedbar:SetOrientation(b.mode)

    -- auto hide
    b:EnableMouse(true)

    b:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    b:RegisterEvent("PLAYER_ENTERING_WORLD")
    b:RegisterEvent("PLAYER_XP_UPDATE")
    b:RegisterEvent("PLAYER_LEVEL_UP")
    b:RegisterEvent("UPDATE_FACTION")

    b:SetScript("OnUpdate", OnUpdate)
    b:SetScript("OnEvent", OnEvent)
    b:SetScript("OnEnter", OnEnter)
    b:SetScript("OnLeave", OnLeave)
    b:GetScript("OnEvent")(b)

    return b
  end

  pfUI.xpbar = { ["UpdateConfig"] = function()
    pfUI.xp = CreateBar("XP")
    pfUI.rep = CreateBar("REP")
  end}

  pfUI.xpbar:UpdateConfig()
end)
