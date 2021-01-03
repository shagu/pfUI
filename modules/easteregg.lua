pfUI:RegisterModule("easteregg", "vanilla:tbc", function ()
  -- merry x-mas!
  if date("%m%d") == "1224" or date("%m%d") == "1225" then
    local title = (UnitFactionGroup("player") == "Horde") and PVP_RANK_18_0 or PVP_RANK_18_1
    local oldflag = _G.CHAT_FLAG_AFK

    local pvpking = CreateFrame("Frame", "pfPvPKing", UIParent)
    pvpking:Hide()

    pvpking:RegisterEvent("CHAT_MSG_SYSTEM")
    pvpking:SetScript("OnEvent", function()
      if strfind(arg1, "You are now", 1) and strfind(arg1, "(AFK)", 1) then
        _G.CHAT_FLAG_AFK = title .. " "
        this.time = GetTime()
        this:Show()
      end
    end)

    pvpking:SetScript("OnUpdate", function()
      if this.time + 1 < GetTime() then
        _G.CHAT_FLAG_AFK = oldflag
        this:Hide()
      end
    end)

    _G.MARKED_AFK           = "You are now |cff33ffcc" .. title .. "|r (AFK)."
    _G.MARKED_AFK_MESSAGE   = "You are now |cff33ffcc" .. title .. "|r (AFK): %s"
    _G.CLEARED_AFK          = "You are no longer |cff33ffcc" .. title .. "|r (AFK).\n|cff33ffccShagu|cffffffff wishes you a merry christmas. Thanks for using |cff33ffccpf|cffffffffUI|cffffffff!|r"
  end

  -- happy new year
  if date("%m%d") == "1231" or date("%m%d") == "0101" then
    local fireworks = CreateFrame("Button", "pfFireworks", WorldFrame)
    fireworks:SetFrameStrata("DIALOG")
    fireworks:SetAllPoints()
    fireworks:Hide()

    fireworks.night = fireworks:CreateTexture("LOW")
    fireworks.night:SetTexture(0,0,0,1)
    fireworks.night:SetGradientAlpha("VERTICAL", 0,0,0,.5, 0,0,0,1)
    fireworks.night:SetAllPoints()

    fireworks.stext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.stext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.stext:SetPoint("TOP", 0, -380)
    fireworks.stext:SetText("|cff33ffccShagu|cffffffff wishes you a")

    fireworks.text = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.text:SetFont(pfUI.media["font:BigNoodleTitling.ttf"], 38)
    fireworks.text:SetPoint("TOP", 0, -400)
    fireworks.text:SetText("happy new year!")

    fireworks.dtext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.dtext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.dtext:SetPoint("TOP", 0, -430)
    fireworks.dtext:SetText("Another year with |cff33ffccpf|rUI has passed.\nThanks for continuing to use it!\n\n|cff444444<Click> or '/afk' to exit")

    fireworks:SetScript("OnClick", function()
      this:Hide()
    end)

    -- trigger fireworks when being AFK
    fireworks:RegisterEvent("CHAT_MSG_SYSTEM")
    fireworks:SetScript("OnEvent", function()
      if strfind(arg1, _G.MARKED_AFK) or strfind(arg1, _G.MARKED_AFK_MESSAGE) then
        this:SetAlpha(0)
        this:Show()
      elseif strfind(arg1, _G.CLEARED_AFK) then
        this:Hide()
      end
    end)

    -- basic explosion animation
    local function animation()
      local fps = (60 / math.max(GetFramerate(), 1))
      this:SetWidth(this:GetWidth()+fps)
      this:SetHeight(this:GetHeight()+fps)
      this:SetAlpha(this:GetAlpha()-fps*.01)
      if this:GetAlpha() <= 0 then
        this.free = true
        this:Hide()
      end
    end

    -- cache explosions to reuse frames
    local explosions = {}
    local function GetExplosion()
      for id, frame in pairs(explosions) do
        if frame.free then
          frame.free = nil
          return frame
        end
      end

      local frame = CreateFrame("Frame", nil, fireworks)
      frame:SetScript("OnUpdate", animation)
      frame.tex = frame:CreateTexture("HIGH")
      frame.tex:SetAllPoints()

      table.insert(explosions, frame)

      return frame
    end

    -- create random amount of fireworks at random positions
    local width, height = GetScreenWidth(), GetScreenHeight()
    fireworks:SetScript("OnUpdate", function()
      -- fade in the night
      if this:GetAlpha() < 1 then
        this:SetAlpha(this:GetAlpha() + .02)
        return
      end

      -- let the "happy new year" blink
      local r,g,b = this.text:GetTextColor()
      this.text:SetTextColor(r+(math.random()-.5)/10, g+(math.random()-.5)/10, b+(math.random()-.5)/10,1)

      if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + math.random() - .2 end

      local x,y = math.random(1, width), -1*math.random(1,height)

      -- create the base explosion
      local f = GetExplosion()
      f:ClearAllPoints()
      f:SetPoint("CENTER", fireworks, "TOPLEFT", x, y)
      f:SetWidth(25)
      f:SetHeight(25)
      f.tex:SetTexture(1,1,1,.5)
      f:SetAlpha(1)
      f:Show()

      -- create random amount of colored explosions
      for i=1, math.random(20) do
        local f = GetExplosion()
        f:ClearAllPoints()
        f:SetPoint("CENTER", fireworks, "TOPLEFT", x+(math.random(0,100)-50), y+(math.random(0,100)-50))
        f:SetWidth(2)
        f:SetHeight(2)
        f.tex:SetTexture(math.random(),math.random(),math.random(),1)
        f:SetAlpha(1)
        f:Show()
      end
    end)
  end
end)
