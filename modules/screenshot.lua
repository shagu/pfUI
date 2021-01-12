pfUI:RegisterModule("screenshot", "vanilla:tbc", function ()
  if C.screenshot.interval == "0"
    and C.screenshot.levelup == "0"
    and C.screenshot.pvprank == "0"
    and C.screenshot.faction == "0"
    and C.screenshot.battleground == "0"
    and C.screenshot.hk == "0"
    and C.screenshot.loot == "0" then
    return
  end
  local LOOT_ITEM_SELF_MULTIPLEregex = SanitizePattern(_G.LOOT_ITEM_SELF_MULTIPLE)
  local LOOT_ITEM_SELFregex = SanitizePattern(_G.LOOT_ITEM_SELF)
  local FACTION_STANDING_CHANGEDregex = SanitizePattern(_G.FACTION_STANDING_CHANGED)

  local color2quality = {}
  for i=-1,6 do
    color2quality[_G.ITEM_QUALITY_COLORS[i].hex] = i
  end
  pfUI.screenshot = CreateFrame("Frame")
  pfUI.screenshot.caption = CreateFrame("Frame")
  pfUI.screenshot.caption:SetPoint("TOP",nil,"TOP",0,-10)
  pfUI.screenshot.caption:SetWidth(400)
  pfUI.screenshot.caption:SetHeight(200)
  pfUI.screenshot.caption.text = pfUI.screenshot.caption:CreateFontString("Label", "OVERLAY")
  pfUI.screenshot.caption.text:SetFont(pfUI.media[C.screenshot.caption_font], C.screenshot.caption_size, "THICKOUTLINE")
  pfUI.screenshot.caption.text:SetAllPoints(pfUI.screenshot.caption)
  pfUI.screenshot.caption.text:SetJustifyH("CENTER")
  pfUI.screenshot.caption.text:SetJustifyV("TOP")

  function pfUI.screenshot.OnEvent()
    return this[event]~=nil and this[event](this,event,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11)
  end
  pfUI.screenshot:SetScript("OnEvent", pfUI.screenshot.OnEvent)

  if tonumber(C.screenshot.interval) > 0 then
    pfUI.screenshot._elapsed = 0
    pfUI.screenshot._interval = tonumber(C.screenshot.interval)*60
    pfUI.screenshot:SetScript("OnUpdate", function()
      this._elapsed = this._elapsed + arg1
      if this._elapsed > this._interval then
        local dt = date("%a, %b %d, %Y %X")
        local loc = string.format("%s - %s",GetRealZoneText(),GetSubZoneText())
        this:CustomScreenshot("interval", dt, loc)
      end
    end)
    pfUI.screenshot:Show()
  end
  pfUI.screenshot:RegisterEvent("PLAYER_ENTERING_WORLD")
  if C.screenshot.levelup == "1" then
    if UnitLevel("player") < MAX_PLAYER_LEVEL then
      pfUI.screenshot:RegisterEvent("PLAYER_LEVEL_UP")
    end
  end
  if C.screenshot.pvprank == "1" then
    pfUI.screenshot:RegisterEvent("PLAYER_PVP_RANK_CHANGED")
  end
  if C.screenshot.faction == "1" then
    pfUI.screenshot:RegisterEvent("CHAT_MSG_SYSTEM")
  end
  if C.screenshot.battleground ~= "0" then
    pfUI.screenshot:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
    pfUI.screenshot:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
  end
  if C.screenshot.hk == "1" then
    pfUI.screenshot:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
  end
  if C.screenshot.loot ~= "0" then
    pfUI.screenshot:RegisterEvent("CHAT_MSG_LOOT")
  end

  function pfUI.screenshot:CustomScreenshot(source, ...)
    local now = GetTime()
    if self._last and (now - self._last < 2) then return end
    self._elapsed = 0
    if C.screenshot.hideui == "1" then
      UIParent:Hide()
    end
    if C.screenshot.caption == "1" then
      if arg.n > 0 then
        self.caption.text:SetText(table.concat(arg,"\n"))
        self.caption:Show()
      end
    end
    self:RegisterEvent("SCREENSHOT_SUCCEEDED")
    self:RegisterEvent("SCREENSHOT_FAILED")
    TakeScreenshot()
    self._last = now
  end

  function pfUI.screenshot:PLAYER_ENTERING_WORLD()
    local _
    _, self._lastRank = GetPVPRankInfo(UnitPVPRank("player"))
  end

  function pfUI.screenshot:SCREENSHOT_SUCCEEDED()
    self:UnregisterEvent("SCREENSHOT_SUCCEEDED")
    self:UnregisterEvent("SCREENSHOT_FAILED")
    UIParent:Show()
    self.caption:Hide()
  end
  pfUI.screenshot.SCREENSHOT_FAILED = pfUI.screenshot.SCREENSHOT_SUCCEEDED

  function pfUI.screenshot:PLAYER_LEVEL_UP()
    local dt = date("%a, %b %d, %Y %X")
    local loc = string.format("%s - %s",GetRealZoneText(),GetSubZoneText())
    local name = string.format("%s : %s %d!",UnitName("player"), LEVEL, arg1)
    self:CustomScreenshot("levelup", dt, loc, name)
  end

  function pfUI.screenshot:PLAYER_PVP_RANK_CHANGED()
    local rankName, rankNumber = GetPVPRankInfo(UnitPVPRank("player"))
    if self._lastRank and self._lastRank ~= rankNumber then
      self._lastRank = rankNumber
      local dt = date("%a, %b %d, %Y %X")
      local loc = string.format("%s - %s",GetRealZoneText(),GetSubZoneText())
      local name = string.format("%s : %s %s!",UnitName("player"),RANK, rankName or _G.NONE)
      self:CustomScreenshot("pvprank", dt, loc, name)
    end
  end

  function pfUI.screenshot:CHAT_MSG_SYSTEM()
    local _,_, standing, rep = string.find(arg1, FACTION_STANDING_CHANGEDregex)
    if standing and rep then
      local dt = date("%a, %b %d, %Y %X")
      local loc = string.format("%s - %s",GetRealZoneText(),GetSubZoneText())
      self:CustomScreenshot("faction", dt, loc, string.format("%s:%s!",rep,standing))
    end
  end

  function pfUI.screenshot:UPDATE_BATTLEFIELD_STATUS()
    local factioncode = UnitFactionGroup("player") == "Alliance" and 1 or 0
    if GetBattlefieldInstanceExpiration() > 0 then
      local won = GetBattlefieldWinner() and GetBattlefieldWinner() == factioncode
      if C.screenshot.battleground == "2"
        or (C.screenshot.battleground == "1" and won) then
        local dt = date("%a, %b %d, %Y %X")
        local loc = string.format("%s - %s",GetRealZoneText(),GetSubZoneText())
        self:CustomScreenshot("battleground", dt, loc)
      end
    end
  end
  pfUI.screenshot.UPDATE_BATTLEFIELD_SCORE = pfUI.screenshot.UPDATE_BATTLEFIELD_STATUS

  function pfUI.screenshot:PLAYER_PVP_KILLS_CHANGED()
    local _, instancetype = IsInInstance()
    if instancetype and instancetype == "pvp" then return end -- not if we're in a BG
    local dt = date("%a, %b %d, %Y %X")
    local loc = string.format("%s - %s",GetRealZoneText(),GetSubZoneText())
    self:CustomScreenshot("hk", dt, loc, T["Honorable Kill!"])
  end

  function pfUI.screenshot:CHAT_MSG_LOOT()
    local _,_, item, amount = string.find(arg1, LOOT_ITEM_SELF_MULTIPLEregex)
    if amount then -- ignore stacks
      return
    else
      _,_, item = string.find(arg1, LOOT_ITEM_SELFregex)
      if item then
        local _, _, itemColor, itemString, itemName = string.find(item, "^(|c%x+)|H(.+)|h(%[.+%])")
        local quality = color2quality[itemColor]
        if quality and quality >= tonumber(C.screenshot.loot) then
          local dt = date("%a, %b %d, %Y %X")
          local loc = string.format("%s - %s",GetRealZoneText(),GetSubZoneText())
          local name = string.format("%s %s!", T["You got"], item)
          self:CustomScreenshot("loot", dt, loc, name)
        end
      end
    end
  end

end)
