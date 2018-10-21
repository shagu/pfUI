pfUI:RegisterModule("buffwatch", function ()
  local border = C.appearance.border.default
  local scanner = libtipscan:GetScanner("buffwatch")

  local fcache = {}
  local function BuffIsVisible(config, name)
    -- return if all buffs should be shown
    if config.filter == "none" then return true end

    local index = tostring(config)
    local mode = config.filter

    if not fcache[index] then
      fcache[index] = {}
      for _, val in pairs({strsplit("#", config[mode])}) do
        fcache[index][val] = true
      end
    end

    if mode == "whitelist" then
      return fcache[index][name]
    elseif mode == "blacklist" then
      return not fcache[index][name]
    end
  end

  local rgbcache = setmetatable({},{__mode="kv"})
  local function str2rgb(text)
    if not text then return 1, 1, 1 end
    if rgbcache[text] then return unpack(rgbcache[text]) end
    local counter = 1
    local l = string.len(text)
    for i = 1, l, 3 do
      counter = math.mod(counter*8161, 4294967279) + (string.byte(text,i)*16776193) + ((string.byte(text,i+1) or (l-i+256))*8372226) + ((string.byte(text,i+2) or (l-i+256))*3932164)
    end
    counter = math.mod(8161, 4294967279) + (string.byte(text,l)*16776193) + ((string.byte(text,l+1) or (l-l+256))*8372226) + ((string.byte(text,l+2) or (l+256))*3932164)

    local hash = math.mod(math.mod(counter, 4294967291),16777216)
    local r = (hash - (math.mod(hash,65536))) / 65536
    local g = ((hash - r*65536) - ( math.mod((hash - r*65536),256)) ) / 256
    local b = hash - r*65536 - g*256
    rgbcache[text] = { r / 255, g / 255, b / 255 }
    return unpack(rgbcache[text])
  end

  -- iterate over given tables and return the first frame that is shown
  local function FirstOneShown(anchors, v)
    for _, tbl in pairs(anchors) do
      for i=32, 1, -1 do
        if tbl and tbl[i] and tbl[i]:IsShown() and tbl[i]:IsVisible() then
          return tbl[i]
        end
      end
    end

    return anchors[1]
  end

  local function GetBuffData(unit, id, type, skipTooltip)
    if unit == "player" then
      local bid = GetPlayerBuff(id-1, type)
      local remaining = GetPlayerBuffTimeLeft(bid)
      local texture = GetPlayerBuffTexture(bid)
      local name

      if not skipTooltip then
        scanner:SetPlayerBuff(bid)
        name = scanner:Line(1)
      end

      return remaining, texture, name
    elseif libdebuff then
      local name, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff(unit, id)
      return timeleft, texture, name
    end
  end

  local function StatusBarOnClick()
    if arg1 == "LeftButton" then
      local config = this.parent.config
      local skill = this.text:GetText()
      if IsControlKeyDown() then
        for _, val in pairs({strsplit("#", config.whitelist)}) do
          if val == skill then return end
        end
        config.whitelist = config.whitelist .. "#" .. skill
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ffcc" .. skill .. "|r" .. T["is now whitelisted."])
      elseif IsShiftKeyDown() then
        for _, val in pairs({strsplit("#", config.blacklist)}) do
          if val == skill then return end
        end
        config.blacklist = config.blacklist .. "#" .. skill
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ffcc" .. skill .. "|r" .. T["is now blacklisted."])
      end
    elseif this.parent.unit == "player" then
      CancelPlayerBuff(GetPlayerBuff(this.id-1,this.type))
    end
  end

  local function StatusBarOnEnter()
    GameTooltip:SetOwner(this, "NONE")

    if this.unit == "player" then
      GameTooltip:SetPlayerBuff(GetPlayerBuff(this.id-1,this.type))
    elseif this.type == "HARMFUL" then
      GameTooltip:SetUnitDebuff(this.unit, this.id)
    elseif this.type == "HELPFUL" then
      GameTooltip:SetUnitBuff(this.unit, this.id)
    end

    if IsShiftKeyDown() then
      GameTooltip:AddLine(" ")
      GameTooltip:AddDoubleLine(T["Ctrl-Click"], T["Add to Whitelist"], 1,1,1, .2,1,.8)
      GameTooltip:AddDoubleLine(T["Shift-Click"], T["Add to Blacklist"], 1,1,1, .2,1,.8)
    end

    GameTooltip:Show()
  end

  local function StatusBarOnLeave()
    GameTooltip:Hide()
  end

  local function StatusBarOnUpdate()
    local remaining = this.endtime - GetTime()
    this.bar:SetValue(remaining > 0 and remaining or 0)

    if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .1 end
    this.time:SetText(remaining > 0 and GetColoredTimeString(remaining) or "N/A")
  end

  local function StatusBarRefreshParent()
    this.parent:RefreshPosition()
  end

  local function CreateStatusBar(bar, parent)
    local color = parent.color
    local width = parent:GetWidth()
    local height = parent:GetHeight()
    local framename = "pf" .. parent.unit .. ( parent.type == "HARMFUL" and "Debuff" or "Buff" ) .. "Bar" .. bar

    frame = _G[framename] or CreateFrame("Button", framename, parent)
    frame:EnableMouse(1)
    frame:Hide()
    frame:SetPoint("BOTTOM", 0, (bar-1)*(height+2*border+1))
    frame:SetWidth(width)
    frame:SetHeight(height)

    frame.bar = CreateFrame("StatusBar", "pfBuffBar" .. bar, frame)
    frame.bar:SetPoint("TOPLEFT", frame, "TOPLEFT", height+1, 0)
    frame.bar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    frame.bar:SetStatusBarColor(color.r, color.g, color.b, color.a)

    frame.text = frame.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
    frame.text:ClearAllPoints()
    frame.text:SetPoint("TOPLEFT", frame.bar, "TOPLEFT", 3, 0)
    frame.text:SetPoint("BOTTOMRIGHT", frame.bar, "BOTTOMRIGHT", -3, 0)
    frame.text:SetNonSpaceWrap(false)
    frame.text:SetFontObject(GameFontWhite)
    frame.text:SetTextColor(1,1,1,1)
    frame.text:SetJustifyH("LEFT")

    frame.time = frame.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
    frame.time:ClearAllPoints()
    frame.time:SetPoint("TOPLEFT", frame.bar, "TOPLEFT", 3, 0)
    frame.time:SetPoint("BOTTOMRIGHT", frame.bar, "BOTTOMRIGHT", -3, 0)
    frame.time:SetNonSpaceWrap(false)
    frame.time:SetFontObject(GameFontWhite)
    frame.time:SetTextColor(1,1,1,1)
    frame.time:SetJustifyH("RIGHT")

    frame.icon = frame:CreateTexture(nil, "OVERLAY")
    frame.icon:SetWidth(height)
    frame.icon:SetHeight(height)
    frame.icon:SetPoint("LEFT", frame, "LEFT", 0, 0)
    frame.icon:SetTexCoord(.07,.93,.07,.93)

    frame.parent = parent
    frame:SetScript("OnUpdate", StatusBarOnUpdate)
    frame:SetScript("OnShow", StatusBarRefreshParent)
    frame:SetScript("OnHide", StatusBarRefreshParent)

    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame:SetScript("OnClick", StatusBarOnClick)
    frame:SetScript("OnEnter", StatusBarOnEnter)
    frame:SetScript("OnLeave", StatusBarOnLeave)

    CreateBackdrop(frame)
    return frame
  end

  local function RefreshBuffBarFrame(frame)
    -- reinitialize all active buffs
    for i=1,32 do
      local timeleft, texture, name = GetBuffData(frame.unit, i, frame.type)

      if texture and name and name ~= "" and BuffIsVisible(frame.config, name) and timeleft and timeleft ~= 0 then
        frame.buffs[i][1] = timeleft
        frame.buffs[i][2] = i
        frame.buffs[i][3] = name
        frame.buffs[i][4] = texture
      else
        frame.buffs[i][1] = 0
        frame.buffs[i][2] = nil
        frame.buffs[i][3] = nil
        frame.buffs[i][4] = nil
      end
    end

    table.sort(frame.buffs, frame.buffcmp)

    -- create a buff bar for each below threshold
    local bar = 1
    for id, data in pairs(frame.buffs) do
      if data[1] and data[1] ~= 0 and data[1] < frame.threshold -- timeleft checks
        and data[3] and data[3] ~= "" -- buff has a name
        and data[4] and data[4] ~= "" -- buff has a texture
      then
        -- update bar data
        frame.bars[bar] = frame.bars[bar] or CreateStatusBar(bar, frame)
        frame.bars[bar].id = data[2]
        frame.bars[bar].unit = frame.unit
        frame.bars[bar].type = frame.type
        frame.bars[bar].endtime = GetTime() + ( data[1] > 0 and data[1] or -1 )

        -- update max duration the cached remaining values is less than
        -- the real one, indicates a buff renewal
        frame.durations[data[4]] = frame.durations[data[4]] or {}
        if not frame.durations[data[4]][1] or frame.durations[data[4]][1] < data[1] then
          frame.durations[data[4]][2] = data[1] -- max
        end
        frame.durations[data[4]][1] = data[1] -- current

        -- set name
        if frame.bars[bar].cacheName ~= data[3] then
          frame.bars[bar].cacheName = data[3]
          frame.bars[bar].text:SetText(data[3])

          local r, g, b
          if frame.type == "HARMFUL" then
            r, g, b = 1, .2, .2
            local _, _, dtype = UnitDebuff(frame.unit, data[2])
            if dtype and DebuffTypeColor[dtype] then
              r,g,b = DebuffTypeColor[dtype].r,DebuffTypeColor[dtype].g,DebuffTypeColor[dtype].b
            end

            if frame.config.autocolor == "1" then
              frame.bars[bar].backdrop:SetBackdropBorderColor(1,0,0,1)
              frame.bars[bar].bar:SetStatusBarColor(1,.2,.2,1)
              frame.bars[bar].text:SetTextColor(r+.5,g+.5,b+.5,1)
            else
              frame.bars[bar].backdrop:SetBackdropBorderColor(r,g,b,1)
            end
          elseif frame.config.autocolor == "1" then
            r,g,b = str2rgb(data[3])
            frame.bars[bar].bar:SetStatusBarColor(r,g,b,1)
          end
        end

        -- set texture
        if frame.bars[bar].cacheTexture ~= data[4] then
          frame.bars[bar].cacheTexture = data[4]
          frame.bars[bar].icon:SetTexture(data[4])
        end

        -- cache maxduration
        if frame.bars[bar].cacheMaxDuration ~= frame.durations[data[4]][2] then
          frame.bars[bar].cacheMaxDuration = frame.durations[data[4]][2]
          frame.bars[bar].bar:SetMinMaxValues(0, frame.durations[data[4]][2])
        end

        frame.bars[bar]:Show()
        bar = bar + 1
      end
    end

    -- hide remaining bars
    for i = bar, table.getn(frame.bars) do
      frame.bars[i]:Hide()
    end
  end

  -- Create a new Buff Bar
  local function BuffBarFrameOnUpdate()
    if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .4 end
    RefreshBuffBarFrame(this)
    this:RefreshPosition()
  end

  local function RefreshPosition(self)
    -- avoid position changes during unlock
    if pfUI.unlock and pfUI.unlock:IsShown() then return end

    if not pfUI_config["position"][self:GetName()] then
      local anchor = FirstOneShown(self.anchors, ( self.unit == "target"))

      if not self.lastanchor or self.lastanchor ~= anchor then
        self:ClearAllPoints()
        self:SetPoint("LEFT", self.anchors[1], "LEFT", 0, 0)
        self:SetPoint("BOTTOM", anchor, "TOP", 0, border*2+1)
        UpdateMovable(self, true)
        self.lastanchor = anchor
      end
    end
  end

  local function CreateBuffBarFrame(unit, type)
    local framename = "pf" .. unit .. ( type == "HARMFUL" and "Debuff" or "Buff" ) .. "Bar"
    local frame = _G[framename] or CreateFrame("Frame", framename, UIParent)

    frame.unit = strlower(unit)
    frame.type = type
    frame.bars = { }
    frame.durations = { }
    frame.buffs = { }
    for i=1,32 do
      frame.buffs[i] = { }
    end

    frame.RefreshPosition = RefreshPosition

    -- OnEvent (UNIT_AURA) doesn't trigger properly on buff refresh
    frame:SetScript("OnUpdate", BuffBarFrameOnUpdate)

    return frame
  end

  local function asc(a,b)
    return a[1] > b[1]
  end

  local function desc(a,b)
    return a[1] < b[1]
  end

  -- create player buffbars
  if pfUI.uf.player and C.buffbar.pbuff.enable == "1" then
    pfUI.uf.player.buffbar = CreateBuffBarFrame("Player", "HELPFUL")
    local config = C.buffbar.pbuff
    local r, g, b, a = strsplit(",", C.buffbar.pbuff.color)

    pfUI.uf.player.buffbar:SetWidth(config.width == "-1" and C.unitframes.player.width or config.width)
    pfUI.uf.player.buffbar:SetHeight(config.height)
    pfUI.uf.player.buffbar.threshold = tonumber(config.threshold)
    pfUI.uf.player.buffbar.config = config
    pfUI.uf.player.buffbar.buffcmp = config.sort == "asc" and asc or desc
    pfUI.uf.player.buffbar.color = { r = r, g = g, b = b, a = a }
    pfUI.uf.player.buffbar.anchors = {
      pfUI.uf.player,
      pfUI.uf.player and pfUI.uf.player.debuffs,
      pfUI.uf.player and pfUI.uf.player.buffs
    }

    pfUI.uf.player.buffbar:SetPoint("LEFT", pfUI.uf.player, "LEFT", 0, 0)
    pfUI.uf.player.buffbar:SetPoint("BOTTOM", pfUI.uf.player, "TOP", 0, border*2+1)
    UpdateMovable(pfUI.uf.player.buffbar)
  end

  -- create player debuffbars
  if pfUI.uf.player and C.buffbar.pdebuff.enable == "1" then
    local config = C.buffbar.pdebuff
    local r, g, b, a = strsplit(",", C.buffbar.pdebuff.color)

    pfUI.uf.player.debuffbar = CreateBuffBarFrame("Player", "HARMFUL")
    pfUI.uf.player.debuffbar:SetWidth(config.width == "-1" and C.unitframes.player.width or config.width)
    pfUI.uf.player.debuffbar:SetHeight(config.height)
    pfUI.uf.player.debuffbar.threshold = tonumber(config.threshold)
    pfUI.uf.player.debuffbar.config = config
    pfUI.uf.player.debuffbar.buffcmp = config.sort == "asc" and asc or desc
    pfUI.uf.player.debuffbar.color = { r = r, g = g, b = b, a = a }
    pfUI.uf.player.debuffbar.anchors = {
      pfUI.uf.player,
      pfUI.uf.player and pfUI.uf.player.buffbar and pfUI.uf.player.buffbar.bars,
      pfUI.uf.player and pfUI.uf.player.debuffs,
      pfUI.uf.player and pfUI.uf.player.buffs
    }

    pfUI.uf.player.debuffbar:SetPoint("LEFT", pfUI.uf.player, "LEFT", 0, 0)
    pfUI.uf.player.debuffbar:SetPoint("BOTTOM", pfUI.uf.player, "TOP", 0, border*2+1)
    UpdateMovable(pfUI.uf.player.debuffbar)
  end

  -- create target debuffbars
  if pfUI.uf.target and C.buffbar.tdebuff.enable == "1" then
    local config = C.buffbar.tdebuff
    local r, g, b, a = strsplit(",", config.color)

    pfUI.uf.target.debuffbar = CreateBuffBarFrame("Target", "HARMFUL")
    pfUI.uf.target.debuffbar:SetWidth(config.width == "-1" and C.unitframes.target.width or config.width)
    pfUI.uf.target.debuffbar:SetHeight(config.height)
    pfUI.uf.target.debuffbar.config = config
    pfUI.uf.target.debuffbar.buffcmp = config.sort == "asc" and asc or desc
    pfUI.uf.target.debuffbar.color = { r = r, g = g, b = b, a = a }
    pfUI.uf.target.debuffbar.threshold = tonumber(config.threshold)
    pfUI.uf.target.debuffbar.anchors = {
      pfUI.uf.target,
      pfUI.uf.target and pfUI.uf.target.buffbar and pfUI.uf.target.buffbar.bars,
      pfUI.uf.target and pfUI.uf.target.debuffs,
      pfUI.uf.target and pfUI.uf.target.buffs
    }

    pfUI.uf.target.debuffbar:SetPoint("LEFT", pfUI.uf.target, "LEFT", 0, 0)
    pfUI.uf.target.debuffbar:SetPoint("BOTTOM", pfUI.uf.target, "TOP", 0, border*2+1)
    UpdateMovable(pfUI.uf.target.debuffbar)
  end
end)
