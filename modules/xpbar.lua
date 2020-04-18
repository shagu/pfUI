pfUI:RegisterModule("xpbar", "vanilla:tbc", function ()
  local rawborder, default_border = GetBorderSize()
  local parse_faction = SanitizePattern(FACTION_STANDING_INCREASED)

  local function CreateBar(t)
    local xp_timeout = tonumber(C.panel.xp.xp_timeout)
    local xp_width = C.panel.xp.xp_width
    local xp_height = C.panel.xp.xp_height
    local xp_mode = C.panel.xp.xp_mode
    local xp_always = C.panel.xp.xp_always == "1" and true or nil
    local xp_position = C.panel.xp.xp_position
    local xp_anchor = C.panel.xp.xp_anchor
    local xp_color = C.panel.xp.xp_color
    local rest_color = C.panel.xp.rest_color

    local rep_timeout = tonumber(C.panel.xp.rep_timeout)
    local rep_width = C.panel.xp.rep_width
    local rep_height = C.panel.xp.rep_height
    local rep_mode = C.panel.xp.rep_mode
    local rep_always = C.panel.xp.rep_always == "1" and true or nil
    local rep_position = C.panel.xp.rep_position
    local rep_anchor = C.panel.xp.rep_anchor

    local t = t
    local width = t == "XP" and xp_width or rep_width
    local height = t == "XP" and xp_height or rep_height
    local mode = t == "XP" and xp_mode or rep_mode
    local timeout = t == "XP" and xp_timeout or rep_timeout
    local always = t == "XP" and xp_always or rep_always
    local name = t == "XP" and "pfExperienceBar" or "pfReputationBar"
    local anchor = t == "XP" and xp_anchor or rep_anchor
    local position = t == "XP" and xp_position or rep_position

    local b = _G[name] or CreateFrame("Frame", name, UIParent)
    b:SetWidth(width)
    b:SetHeight(height)
    b:SetFrameStrata("BACKGROUND")

    AlignToPosition(b, _G[anchor], position)
    CreateBackdrop(b)
    CreateBackdropShadow(b)

    b.bar = b.bar or CreateFrame("StatusBar", nil, b)
    b.bar:SetStatusBarTexture(pfUI.media["img:bar"])
    b.bar:ClearAllPoints()
    b.bar:SetAllPoints(b)
    b.bar:SetFrameStrata("LOW")

    local cr, cg, cb, ca = pfUI.api.GetStringColor(xp_color)
    b.bar:SetStatusBarColor(cr,cg,cb,ca)
    b.bar:SetOrientation(mode)

    b.restedbar = b.restedbar or CreateFrame("StatusBar", nil, b)
    b.restedbar:SetStatusBarTexture(pfUI.media["img:bar"])
    b.restedbar:ClearAllPoints()
    b.restedbar:SetAllPoints(b)
    b.restedbar:SetFrameStrata("MEDIUM")
    local cr, cg, cb, ca = pfUI.api.GetStringColor(rest_color)
    b.restedbar:SetStatusBarColor(cr,cg,cb,ca)
    b.restedbar:SetOrientation(mode)

    -- auto hide
    b:EnableMouse(true)
    b:SetScript("OnLeave", function()
      this.tick = GetTime() + 3.00
      GameTooltip:Hide()
    end)

    b:SetScript("OnUpdate",function()
      if always then return end
      if this:GetAlpha() == 0 or MouseIsOver(this) then return end
      if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .01 end
      this:SetAlpha(this:GetAlpha() - .05)
    end)

    b:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    b:RegisterEvent("PLAYER_ENTERING_WORLD")
    b:RegisterEvent("PLAYER_XP_UPDATE")
    b:RegisterEvent("PLAYER_LEVEL_UP")
    b:RegisterEvent("UPDATE_FACTION")
    b:SetScript("OnEvent", function()
      -- realign when entering world to ensure all frames got loaded
      AlignToPosition(b, _G[anchor], position)

      -- set either experience, reputation or flex-rep handler
      local mode = ( t == "XP" and UnitLevel("player") < MAX_LEVEL ) and "XP" or t == "REP" and "REP" or "FLEX"

      -- skip on events of no interest
      if mode == "XP" and ( event == "CHAT_MSG_COMBAT_FACTION_CHANGE" or event == "UPDATE_FACTION" ) then return end
      if ( mode == "REP" or mode == "FLEX" ) and event == "PLAYER_XP_UPDATE" then return end

      if mode == "XP" then
        this.enabled = true
        if event == "PLAYER_ENTERING_WORLD" then
          this.starttime = GetTime()
          this.startxp = UnitXP("player") or 0
        elseif event == "PLAYER_LEVEL_UP" then
          -- add previously gained experience to the session
          this.startxp = this.startxp - UnitXPMax("player")
        end

        this.bar:SetMinMaxValues(0, UnitXPMax("player"))
        this.bar:SetValue(UnitXP("player"))
        if GetXPExhaustion() then
          this.restedbar:Show()
          this.restedbar:SetMinMaxValues(0, UnitXPMax("player"))
          this.restedbar:SetValue(UnitXP("player") + GetXPExhaustion())
        else
          this.restedbar:Hide()
        end
        this.tick = GetTime() + timeout
        this:SetAlpha(1)
      else
        this.restedbar:Hide()

        if mode == "FLEX" and event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
          local _,_, faction, amount = string.find(arg1, parse_faction)
          this.faction = faction or this.faction
        end

        for i=1, 99 do
          local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(i)
          if ( mode == "REP" and isWatched ) or ( mode == "FLEX" and this.faction and name == this.faction) then
            this.enabled = true

            barMax = barMax - barMin
            barValue = barValue - barMin
            barMin = 0

            this.bar:SetMinMaxValues(barMin, barMax)
            this.bar:SetValue(barValue)
            local color = FACTION_BAR_COLORS[standingID]
            this.bar:SetStatusBarColor((color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5, 1)

            this.tick = GetTime() + rep_timeout
            this:SetAlpha(1)
            break
          end
        end
      end
    end)

    b:SetScript("OnEnter", function()
      if not this.enabled then return end

      -- set either experience, reputation or flex-rep handler
      local mode = ( t == "XP" and UnitLevel("player") < MAX_LEVEL ) and "XP" or t == "REP" and "REP" or "FLEX"
      local lines = {}

      this:SetAlpha(1)

      if mode == "XP" then
        local xp, xpmax, exh = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
        local xp_perc = round(xp / xpmax * 100)
        local remaining = xpmax - xp
        local remaining_perc = round(remaining / xpmax * 100)
        local exh_perc = GetXPExhaustion() and round(GetXPExhaustion() / xpmax * 100) or 0
        local xp_persec = ((xp - this.startxp)/(GetTime() - this.starttime))
        local session = UnitXP("player") - this.startxp
        local avg_hour = floor(((UnitXP("player") - this.startxp) / (GetTime() - this.starttime)) * 60 * 60)
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
      else
        for i=1, 99 do
          local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(i)
          if ( mode == "REP" and isWatched ) or ( mode == "FLEX" and this.faction and name == this.faction) then
            barMax = barMax - barMin
            barValue = barValue - barMin
            barMin = 0

            local color = FACTION_BAR_COLORS[standingID]
            if not color then color = 1,1,1 end

            local color = rgbhex(color.r + .3, color.g + .3, color.b + .3)
            table.insert(lines, { "|cff555555" .. T["Reputation"], "" })
            table.insert(lines, { color .. name .. " (" .. GetText("FACTION_STANDING_LABEL"..standingID, gender) .. ")"})
            table.insert(lines, { barValue .. " / " .. barMax .. " (" .. round(barValue / barMax * 100) .. "%)" })
            break
          end
        end
      end

      -- draw tooltip
      GameTooltip:ClearLines()
      GameTooltip_SetDefaultAnchor(GameTooltip, this)
      GameTooltip:SetOwner(this, "ANCHOR_CURSOR")

      for id, data in pairs(lines) do
        if data[2] then
          GameTooltip:AddDoubleLine(data[1], data[2])
        else
          GameTooltip:AddLine(data[1])
        end
      end
      GameTooltip:Show()
    end)

    return b
  end

  pfUI.xpbar = { ["UpdateConfig"] = function()
    pfUI.xp = CreateBar("XP")
    pfUI.rep = CreateBar("REP")
  end}

  pfUI.xpbar:UpdateConfig()
end)
