pfUI:RegisterModule("totems", "vanilla:tbc", function ()
  local _, class = UnitClass("player")

  local slots = {
    [FIRE_TOTEM_SLOT]  = { r = .5, g = .2, b = .1 },
    [EARTH_TOTEM_SLOT] = { r = .2, g = .4, b = .1 },
    [WATER_TOTEM_SLOT] = { r = .1, g = .4, b = .6 },
    [AIR_TOTEM_SLOT]   = { r = .4, g = .1, b = .7 },
  }

  local totems = CreateFrame("Frame", "pfTotems", UIParent)
  totems:RegisterEvent("PLAYER_TOTEM_UPDATE")
  totems:RegisterEvent("PLAYER_ENTERING_WORLD")
  totems:SetScript("OnEvent", function(self)
    totems:RefreshList()
  end)

  if pfUI.client <= 11200 and class == "SHAMAN" then
    -- there's no totem event in vanilla using ticks instead
    local eventemu = CreateFrame("Frame")
    eventemu:SetScript("OnUpdate", function()
      if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .5 end
      totems:RefreshList()
    end)
  end

  totems.OnEnter = function(self)
    if not this.id then return end
    local active, name, start, duration, icon = GetTotemInfo(this.id)
    local color = slots[this.id]
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText(name, color.r+.2, color.g+.2, color.b+.2)
    GameTooltip:Show()
  end

  totems.OnLeave = function(self)
    GameTooltip:Hide()
  end

  totems.OnClick = function(self)
    if pfUI.client <= 11200 and this.id and arg1 and arg1 == "LeftButton" then
      -- Try to recast totem on left click in vanilla
      local active, name, start, duration, icon = GetTotemInfo(this.id)
      if name then CastSpellByName(name) end
    elseif pfUI.client > 11200 and this.id and arg1 and arg1 == "RightButton" then
      -- Try to cancel totem on right click in tbc+
      DestroyTotem(this.id)
    end
  end

  totems.RefreshList = function(self)
    local count = 0
    for i = 1, MAX_TOTEMS do
      local active, name, start, duration, icon = GetTotemInfo(i)

      if active and icon and icon ~= "" then
        count = count + 1
        local color = slots[i]

        self.bar[count]:Show()
        self.bar[count]:SetBackdropBorderColor(color.r, color.g, color.b)
        self.bar[count].icon:SetTexture(icon)
        self.bar[count].id = i

        CooldownFrame_SetTimer(self.bar[count].cd, start, duration, 1)
      end
    end

    self:UpdateSize(count)
  end

  totems.UpdateSize = function(self, count)
    if not count or count == 0 then
      -- hide entire panel
      self:Hide()
    else
      -- hide remaining totems and show panel
      for i = count + 1, MAX_TOTEMS do self.bar[i]:Hide() end
      self:Show()
    end

    local count = count and count > 0 and count or MAX_TOTEMS

    if pfUI_config.totems.direction == "HORIZONTAL" then
      self:SetHeight(self.iconsize + self.spacing*2)
      self:SetWidth(self.spacing*2 + self.iconsize + (count-1)*(self.iconsize + self.spacing*2))
    else
      self:SetWidth(self.iconsize + self.spacing*2)
      self:SetHeight(self.spacing*2 + self.iconsize + (count-1)*(self.iconsize + self.spacing*2))
    end
  end

  totems.UpdateConfig = function(self)
    local rawborder, border = GetBorderSize()
    self.iconsize = pfUI_config.totems.iconsize
    self.direction = pfUI_config.totems.direction
    self.spacing = tonumber(pfUI_config.totems.spacing) * GetPerfectPixel()
    self.showbg = pfUI_config.totems.showbg == "1" and true or nil

    for i = 1, MAX_TOTEMS do
      self.bar = self.bar or {}
      self.bar[i] = self.bar[i] or CreateFrame("Button", "pfTotemsBar"..i, totems)
      self.bar[i]:ClearAllPoints()

      if pfUI_config.totems.direction == "HORIZONTAL" then
        if self.bar[i-1] then
          self.bar[i]:SetPoint("LEFT", self.bar[i-1], "RIGHT", self.spacing*2, 0)
        else
          self.bar[i]:SetPoint("TOPLEFT", self, "TOPLEFT", self.spacing, -self.spacing)
        end
      else
        if self.bar[i-1] then
          self.bar[i]:SetPoint("TOP", self.bar[i-1], "BOTTOM", 0, -self.spacing*2)
        else
          self.bar[i]:SetPoint("TOPLEFT", self, "TOPLEFT", self.spacing, -self.spacing)
        end
      end

      self.bar[i]:SetHeight(self.iconsize)
      self.bar[i]:SetWidth(self.iconsize)
      CreateBackdrop(self.bar[i], nil, true)

      self.bar[i].icon = self.bar[i].icon or self.bar[i]:CreateTexture(nil, "ARTWORK")
      self.bar[i].icon:SetTexCoord(.08, .92, .08, .92)
      SetAllPointsOffset(self.bar[i].icon, self.bar[i], 2,-2)

      self.bar[i].cdbg = self.bar[i].cdbg or CreateFrame("Frame", nil, self.bar[i])
      self.bar[i].cdbg:SetHeight(self.iconsize - 3)
      self.bar[i].cdbg:SetWidth(self.iconsize - 3)
      self.bar[i].cdbg:SetPoint("CENTER", self.bar[i], "CENTER", 0, 0)
      self.bar[i].cd = self.bar[i].cd or CreateFrame(COOLDOWN_FRAME_TYPE, "pfTotemsBar"..i.."Cooldown", self.bar[i].cdbg, "CooldownFrameTemplate")
      self.bar[i].cd.pfCooldownStyleAnimation = 1
      self.bar[i].cd.pfCooldownType = "ALL"

      self.bar[i]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
      self.bar[i]:SetScript("OnClick", self.OnClick)
      self.bar[i]:SetScript("OnEnter", self.OnEnter)
      self.bar[i]:SetScript("OnLeave", self.OnLeave)
    end

    self:RefreshList()
    self:ClearAllPoints()
    self:SetPoint("BOTTOM", 0, 75)
    UpdateMovable(self, true)

    if self.showbg then
      CreateBackdrop(self)
      self.backdrop:Show()
    elseif self.backdrop then
      self.backdrop:Hide()
    end
  end

  -- add totems to the pfUI global space
  pfUI.totems = totems
  pfUI.totems:UpdateConfig()
end)
