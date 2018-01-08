pfUI.uf = CreateFrame("Frame",nil,UIParent)
pfUI.uf.frames = {}

-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

local pfValidUnits = {}
pfValidUnits["player"] = true
pfValidUnits["target"] = true
pfValidUnits["pet"] = true
pfValidUnits["mouseover"] = true

pfValidUnits["player" .. "target"] = true
pfValidUnits["target" .. "target"] = true
pfValidUnits["pet" .. "target"] = true

for i=1,4 do pfValidUnits["party" .. i] = true end
for i=1,4 do pfValidUnits["partypet" .. i] = true end
for i=1,40 do pfValidUnits["raid" .. i] = true end
for i=1,40 do pfValidUnits["raidpet" .. i] = true end

for i=1,4 do pfValidUnits["party" .. i .. "target"] = true end
for i=1,4 do pfValidUnits["partypet" .. i .. "target"] = true end
for i=1,40 do pfValidUnits["raid" .. i .. "target"] = true end
for i=1,40 do pfValidUnits["raidpet" .. i .. "target"] = true end

function pfUI.uf:UpdateFrameSize()
  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  local spacing = self.config.pspace
  local width = self.config.width
  local height = self.config.height
  local pheight = self.config.pheight
  local real_height = height + spacing + pheight + 2*default_border
  local portrait = 0
  if self.config.portrait == "left" or self.config.portrait == "right" then
    self.portrait:SetWidth(real_height)
    self.portrait:SetHeight(real_height)
    portrait = real_height + spacing + 2*default_border
  end

  self:SetWidth(width + portrait)
  self:SetHeight(real_height)
end

function pfUI.uf:UpdateConfig()
  local f = self
  local C = pfUI_config
  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  local relative_point = "BOTTOM"
  if f.config.panchor == "TOPLEFT" then
     relative_point = "BOTTOMLEFT"
  elseif f.config.panchor == "TOPRIGHT" then
     relative_point = "BOTTOMRIGHT"
  end

  f:SetFrameStrata("BACKGROUND")

  f.hp:ClearAllPoints()
  f.hp:SetPoint("TOP", 0, 0)

  f.hp:SetWidth(f.config.width)
  f.hp:SetHeight(f.config.height)
  if tonumber(f.config.height) < 0 then f.hp:Hide() end
  pfUI.api.CreateBackdrop(f.hp, default_border)

  f.hp.bar:SetStatusBarTexture(f.config.bartexture)
  f.hp.bar:SetAllPoints(f.hp)
  if f.config.verticalbar == "1" then
    f.hp.bar:SetOrientation("VERTICAL")
  end

  if pfUI_config.unitframes.custombg == "1" then
    local cr, cg, cb, ca = pfUI.api.strsplit(",", pfUI_config.unitframes.custombgcolor)
    cr, cg, cb, ca = tonumber(cr), tonumber(cg), tonumber(cb), tonumber(ca)
    f.hp.bar.texture = f.hp.bar.texture or f.hp:CreateTexture(nil,"BACKGROUND")
    f.hp.bar.texture:SetTexture(cr,cg,cb,ca)
    f.hp.bar.texture:SetAllPoints(f.hp.bar)
  end

  f.power:ClearAllPoints()
  f.power:SetPoint(f.config.panchor, f.hp, relative_point, 0, -2*default_border - f.config.pspace)
  f.power:SetWidth((f.config.pwidth ~= "-1" and f.config.pwidth or f.config.width))
  f.power:SetHeight(f.config.pheight)
  if tonumber(f.config.pheight) < 0 then f.power:Hide() end

  pfUI.api.CreateBackdrop(f.power, default_border)
  f.power.bar:SetStatusBarTexture(f.config.bartexture)
  f.power.bar:SetAllPoints(f.power)

  f.portrait:SetFrameStrata("LOW")
  f.portrait.tex:SetAllPoints(f.portrait)
  f.portrait.tex:SetTexCoord(.1, .9, .1, .9)
  f.portrait.model:SetFrameStrata("LOW")
  f.portrait.model:SetAllPoints(f.portrait)

  if f.config.portrait == "bar" then
    f.portrait:SetParent(f.hp.bar)
    f.portrait:SetAllPoints(f.hp.bar)

    f.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)
    if f.portrait.backdrop then f.portrait.backdrop:Hide() end

    f.portrait:Show()
  elseif f.config.portrait == "left" then
    f.portrait:SetParent(f)
    f.portrait:ClearAllPoints()
    f.portrait:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)

    f.hp:ClearAllPoints()
    f.hp:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)

    f.portrait:SetAlpha(f:GetAlpha())

    pfUI.api.CreateBackdrop(f.portrait, default_border)
    f.portrait.backdrop:Show()
    -- still required? remove in two weeks
    --f.portrait:SetFrameStrata("BACKGROUND")
    --f.portrait.model:SetFrameLevel(1)

    f.portrait:Show()
  elseif f.config.portrait == "right" then
    f.portrait:SetParent(f)
    f.portrait:ClearAllPoints()
    f.portrait:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)

    f.hp:ClearAllPoints()
    f.hp:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)

    f.portrait:SetAlpha(f:GetAlpha())

    pfUI.api.CreateBackdrop(f.portrait, default_border)
    f.portrait.backdrop:Show()
    -- still required? remove in two weeks
    --f.portrait:SetFrameStrata("BACKGROUND")
    --f.portrait.model:SetFrameLevel(1)

    f.portrait:Show()
  else
    f.portrait:Hide()
  end

  f.hpLeftText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.hpLeftText:SetJustifyH("LEFT")
  f.hpLeftText:SetFontObject(GameFontWhite)
  f.hpLeftText:SetParent(f.hp.bar)
  f.hpLeftText:ClearAllPoints()
  f.hpLeftText:SetPoint("TOPLEFT",f.hp.bar, "TOPLEFT", 2*default_border, 1)
  f.hpLeftText:SetPoint("BOTTOMRIGHT",f.hp.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.hpRightText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.hpRightText:SetJustifyH("RIGHT")
  f.hpRightText:SetFontObject(GameFontWhite)
  f.hpRightText:SetParent(f.hp.bar)
  f.hpRightText:ClearAllPoints()
  f.hpRightText:SetPoint("TOPLEFT",f.hp.bar, "TOPLEFT", 2*default_border, 1)
  f.hpRightText:SetPoint("BOTTOMRIGHT",f.hp.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.hpCenterText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.hpCenterText:SetJustifyH("CENTER")
  f.hpCenterText:SetFontObject(GameFontWhite)
  f.hpCenterText:SetParent(f.hp.bar)
  f.hpCenterText:ClearAllPoints()
  f.hpCenterText:SetPoint("TOPLEFT",f.hp.bar, "TOPLEFT", 2*default_border, 1)
  f.hpCenterText:SetPoint("BOTTOMRIGHT",f.hp.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.powerLeftText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.powerLeftText:SetJustifyH("LEFT")
  f.powerLeftText:SetFontObject(GameFontWhite)
  f.powerLeftText:SetParent(f.power.bar)
  f.powerLeftText:ClearAllPoints()
  f.powerLeftText:SetPoint("TOPLEFT",f.power.bar, "TOPLEFT", 2*default_border, 1)
  f.powerLeftText:SetPoint("BOTTOMRIGHT",f.power.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.powerRightText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.powerRightText:SetJustifyH("RIGHT")
  f.powerRightText:SetFontObject(GameFontWhite)
  f.powerRightText:SetParent(f.power.bar)
  f.powerRightText:ClearAllPoints()
  f.powerRightText:SetPoint("TOPLEFT",f.power.bar, "TOPLEFT", 2*default_border, 1)
  f.powerRightText:SetPoint("BOTTOMRIGHT",f.power.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.powerCenterText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.powerCenterText:SetJustifyH("CENTER")
  f.powerCenterText:SetFontObject(GameFontWhite)
  f.powerCenterText:SetParent(f.power.bar)
  f.powerCenterText:ClearAllPoints()
  f.powerCenterText:SetPoint("TOPLEFT",f.power.bar, "TOPLEFT", 2*default_border, 1)
  f.powerCenterText:SetPoint("BOTTOMRIGHT",f.power.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.incHeal:SetFrameLevel(2)
  f.incHeal:SetHeight(f.config.height)
  f.incHeal:SetWidth(f.config.width)
  f.incHeal:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  f.incHeal:SetStatusBarColor(0, 1, 0, 0.5)
  f.incHeal:Hide()

  f.incHeal:SetScript("OnShow", function()
    if pfUI.prediction and f.label and f.id then
      pfUI.prediction:TriggerUpdate(UnitName(f.label .. f.id))
    end
  end)

  if f.config.verticalbar == "0" then
    f.incHeal:ClearAllPoints()
    f.incHeal:SetPoint("TOPLEFT", f.hp.bar, "TOPLEFT", 0, 0)
  else
    f.incHeal:ClearAllPoints()
    f.incHeal:SetPoint("BOTTOM", f.hp.bar, "BOTTOM", 0, 0)
  end

  f.ressIcon:SetFrameLevel(16)
  f.ressIcon:SetWidth(32)
  f.ressIcon:SetHeight(32)
  f.ressIcon:SetPoint("CENTER", f, "CENTER", 0, 4)
  f.ressIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\ress")
  f.ressIcon.texture:SetAllPoints(f.ressIcon)
  f.ressIcon:Hide()

  f.leaderIcon:SetWidth(10)
  f.leaderIcon:SetHeight(10)
  f.leaderIcon:SetPoint("CENTER", f, "TOPLEFT", 0, 0)
  f.leaderIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-LeaderIcon")
  f.leaderIcon.texture:SetAllPoints(f.leaderIcon)
  f.leaderIcon:Hide()

  f.lootIcon:SetWidth(10)
  f.lootIcon:SetHeight(10)
  f.lootIcon:SetPoint("CENTER", f, "LEFT", 0, 0)

  f.lootIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-MasterLooter")
  f.lootIcon.texture:SetAllPoints(f.lootIcon)
  f.lootIcon:Hide()

  f.raidIcon:SetWidth(24)
  f.raidIcon:SetHeight(24)
  f.raidIcon:SetPoint("TOP", f, "TOP", 0, 6)

  f.raidIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")
  f.raidIcon.texture:SetAllPoints(f.raidIcon)
  f.raidIcon:Hide()

  if f.config.buffs == "off" then
    for i=1, 32 do
      if f.buffs and f.buffs[i] then
        f.buffs[i]:Hide()
        f.buffs[i] = nil
      end
    end
    f.buffs = nil
  else
    f.buffs = f.buffs or {}

    for i=1, 32 do
      if i > tonumber(f.config.bufflimit) then break end

      local id = i
      local perrow = f.config.buffperrow
      local row = floor((i-1) / perrow)

      f.buffs[i] = f.buffs[i] or CreateFrame("Button", "pfUI" .. f.fname .. "Buff" .. i, f)
      f.buffs[i]:SetID(i)

      f.buffs[i].stacks = f.buffs[i].stacks or f.buffs[i]:CreateFontString(nil, "OVERLAY", f.buffs[i])
      f.buffs[i].stacks:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
      f.buffs[i].stacks:SetPoint("BOTTOMRIGHT", f.buffs[i], 2, -2)
      f.buffs[i].stacks:SetJustifyH("LEFT")
      f.buffs[i].stacks:SetShadowColor(0, 0, 0)
      f.buffs[i].stacks:SetShadowOffset(0.8, -0.8)
      f.buffs[i].stacks:SetTextColor(1,1,.5)
      f.buffs[i].cd = f.buffs[i].cd or CreateFrame("Model", nil, f.buffs[i], "CooldownFrameTemplate")
      f.buffs[i].cd:SetAlpha(0)

      f.buffs[i]:RegisterForClicks("RightButtonUp")
      f.buffs[i]:ClearAllPoints()

      local invert, af, as
      if f.config.buffs == "top" then
        invert = 1
        af = "BOTTOMLEFT"
        as = "TOPLEFT"
      elseif f.config.buffs == "bottom" then
        invert = -1
        af = "TOPLEFT"
        as = "BOTTOMLEFT"
      end

      f.buffs[i]:SetPoint(af, f, as,
      (i-1-row*perrow)*((2*default_border) + f.config.buffsize + 1),
      invert * (row)*((2*default_border) + f.config.buffsize + 1) + invert*(2*default_border + 1))

      f.buffs[i]:SetWidth(f.config.buffsize)
      f.buffs[i]:SetHeight(f.config.buffsize)

      if f:GetName() == "pfPlayer" then
        f.buffs[i]:SetScript("OnUpdate", function()
          local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(this:GetID()-1,"HELPFUL"))
          CooldownFrame_SetTimer(this.cd, GetTime(), timeleft, 1)
        end)
      end

      f.buffs[i]:SetScript("OnEnter", function()
        if not this:GetParent().label then return end

        GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
        if this:GetParent().label == "player" then
          GameTooltip:SetPlayerBuff(GetPlayerBuff(id-1,"HELPFUL"))
        else
          GameTooltip:SetUnitBuff(this:GetParent().label .. this:GetParent().id, id)
        end
      end)

      f.buffs[i]:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)

      f.buffs[i]:SetScript("OnClick", function()
        if this:GetParent().label == "player" then
          CancelPlayerBuff(GetPlayerBuff(id-1,"HELPFUL"))
        end
      end)
    end
  end

  if f.config.debuffs == "off" then
    for i=1, 32 do
      if f.debuffs and f.debuffs[i] then
        f.debuffs[i]:Hide()
        f.debuffs[i] = nil
      end
    end
    f.debuffs = nil
  else
    f.debuffs = f.debuffs or {}

    for i=1, 32 do
      if i > tonumber(f.config.debufflimit) then break end

      local id = i
      f.debuffs[i] = f.debuffs[i] or CreateFrame("Button", "pfUI" .. f.fname .. "Debuff" .. i, f)
      f.debuffs[i]:SetID(i)
      f.debuffs[i].stacks = f.debuffs[i].stacks or f.debuffs[i]:CreateFontString(nil, "OVERLAY", f.debuffs[i])
      f.debuffs[i].stacks:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
      f.debuffs[i].stacks:SetPoint("BOTTOMRIGHT", f.debuffs[i], 2, -2)
      f.debuffs[i].stacks:SetJustifyH("LEFT")
      f.debuffs[i].stacks:SetShadowColor(0, 0, 0)
      f.debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
      f.debuffs[i].stacks:SetTextColor(1,1,.5)
      f.debuffs[i].cd = f.debuffs[i].cd or CreateFrame("Model", nil, f.debuffs[i], "CooldownFrameTemplate")
      f.debuffs[i].cd:SetAlpha(0)

      f.debuffs[i]:RegisterForClicks("RightButtonUp")
      f.debuffs[i]:ClearAllPoints()
      f.debuffs[i]:SetWidth(f.config.debuffsize)
      f.debuffs[i]:SetHeight(f.config.debuffsize)
      f.debuffs[i]:SetNormalTexture(nil)
      f.debuffs[i]:SetScript("OnEnter", function()
        if not this:GetParent().label then return end
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
        if this:GetParent().label == "player" then
          GameTooltip:SetPlayerBuff(GetPlayerBuff(id-1,"HARMFUL"))
        else
          GameTooltip:SetUnitDebuff(this:GetParent().label .. this:GetParent().id, id)
        end
      end)

      f.debuffs[i]:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)

      f.debuffs[i]:SetScript("OnClick", function()
        if this:GetParent().label == "player" then
          CancelPlayerBuff(GetPlayerBuff(id-1,"HARMFUL"))
        end
      end)
    end
  end

  if f.config.visible == "1" then
    pfUI.uf:RefreshUnit(f, "all")
    f:EnableScripts()
    f:UpdateFrameSize()
  else
    f:UnregisterAllEvents()
    f:Hide()
  end
end

function pfUI.uf:EnableScripts()
  local f = self

  f:RegisterForClicks('LeftButtonUp', 'RightButtonUp',
    'MiddleButtonUp', 'Button4Up', 'Button5Up')

  f:RegisterEvent("PLAYER_ENTERING_WORLD")
  f:RegisterEvent("UNIT_DISPLAYPOWER")
  f:RegisterEvent("UNIT_HEALTH")
  f:RegisterEvent("UNIT_MAXHEALTH")
  f:RegisterEvent("UNIT_MANA")
  f:RegisterEvent("UNIT_MAXMANA")
  f:RegisterEvent("UNIT_RAGE")
  f:RegisterEvent("UNIT_MAXRAGE")
  f:RegisterEvent("UNIT_ENERGY")
  f:RegisterEvent("UNIT_MAXENERGY")
  f:RegisterEvent("UNIT_FOCUS")
  f:RegisterEvent("UNIT_PORTRAIT_UPDATE")
  f:RegisterEvent("UNIT_MODEL_CHANGED")
  f:RegisterEvent("UNIT_AURA") -- frame=buff, frame=debuff
  f:RegisterEvent("PLAYER_AURAS_CHANGED") -- label=player && frame=buff
  f:RegisterEvent("PARTY_MEMBERS_CHANGED") -- label=party, frame=leaderIcon
  f:RegisterEvent("PARTY_LEADER_CHANGED") -- frame=leaderIcon
  f:RegisterEvent("RAID_ROSTER_UPDATE") -- label=raid
  f:RegisterEvent("PLAYER_TARGET_CHANGED") -- label=target
  f:RegisterEvent("PARTY_LOOT_METHOD_CHANGED") -- frame=lootIcon
  f:RegisterEvent("RAID_TARGET_UPDATE") -- frame=raidIcon
  f:RegisterEvent("UNIT_PET")
  f:RegisterEvent("UNIT_HAPPINESS")

  f:SetScript("OnShow", function ()
      pfUI.uf:RefreshUnit(this)
    end)

  f:SetScript("OnEvent", function()
    if this.label == "target" and event == "PLAYER_TARGET_CHANGED" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif ( this.label == "party" or this.label == "player" ) and event == "PARTY_MEMBERS_CHANGED" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif this.label == "party" and event == "PARTY_MEMBER_ENABLE" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif this.label == "party" and event == "PARTY_MEMBER_DISABLE" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif this.label == "party" and event == "GROUP_ROSTER_UPDATE" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif ( this.label == "raid" or this.label == "party" ) and event == "RAID_ROSTER_UPDATE" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif this.label == "player" and event == "PLAYER_AURAS_CHANGED" then
      pfUI.uf:RefreshUnit(this, "aura")
    elseif event == "PLAYER_ENTERING_WORLD" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif event == "RAID_TARGET_UPDATE" then
      pfUI.uf:RefreshUnit(this, "raidIcon")
    elseif event == "PARTY_LOOT_METHOD_CHANGED" then
      pfUI.uf:RefreshUnit(this, "lootIcon")
    elseif event == "PARTY_LEADER_CHANGED" then
      pfUI.uf:RefreshUnit(this, "leaderIcon")
    elseif event == "UNIT_PET" and this.label == "pet" then
      pfUI.uf:RefreshUnit(this)

    -- UNIT_XXX Events
    elseif arg1 and arg1 == this.label .. this.id then
      if event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" then
        pfUI.uf:RefreshUnit(this, "portrait")
      elseif event == "UNIT_AURA" then
        pfUI.uf:RefreshUnit(this, "aura")
      else
        pfUI.uf:RefreshUnit(this)
      end
    end
  end)

  f:SetScript("OnUpdate", function()
    local unitname = ( this.label and UnitName(this.label) ) or ""

    -- focus unit detection
    if this.unitname and this.unitname ~= strlower(unitname) then
      -- invalid focus frame
      for unit, bool in pairs(pfValidUnits) do
        local scan = UnitName(unit) or ""
        if this.unitname == strlower(scan) then
          this.label = unit
          if this.portrait then this.portrait.model.lastUnit = nil end
          this.instantRefresh = true
          pfUI.uf:RefreshUnit(this, "all")
          return
        end
        this.label = nil
        this.instantRefresh = true
        this.hp.bar:SetStatusBarColor(.2,.2,.2)
      end
    end

    if not this.label then return end

    pfUI.uf:RefreshUnitAnimation(this)

    -- trigger eventless actions (online/offline/range)
    if not this.lastTick then this.lastTick = GetTime() + (this.tick or .2) end
    if this.lastTick and this.lastTick < GetTime() then
      this.lastTick = GetTime() + (this.tick or .2)
      pfUI.uf:RefreshUnitState(this)

      -- update everything on eventless frames (targettarget, etc)
      if this.tick then
        pfUI.uf:RefreshUnit(this, "all")
      end
    end
  end)

  f:SetScript("OnEnter", function()
    if not this.label then return end
    if this.config.showtooltip == "0" then return end
    GameTooltip_SetDefaultAnchor(GameTooltip, this)
    GameTooltip:SetUnit(this.label .. this.id)
    GameTooltip:Show()
  end)

  f:SetScript("OnLeave", function()
    GameTooltip:FadeOut()
  end)

  f:SetScript("OnClick", function ()
    if not this.label and this.unitname then
      TargetByName(this.unitname)
    else
      pfUI.uf:ClickAction(arg1)
    end
  end)
end

function pfUI.uf:CreateUnitFrame(unit, id, config, tick)
  local fname = (( unit == "Party" ) and "Group" or (unit or "")) .. (id or "")
  local unit = strlower(unit or "")
  local id = strlower(id or "")

  -- fake party0 units as self
  if unit == "party" and id == "0" then
    unit, id = "player", ""
  end

  if unit == "partypet" and id == "0" then
    unit, id = "pet", ""
  end

  if unit == "party0target" then
    unit, id = "target", ""
  end

  local f = CreateFrame("Button", "pf" .. fname, UIParent)

  -- add unitframe functions
  f.UpdateFrameSize = pfUI.uf.UpdateFrameSize
  f.UpdateConfig    = pfUI.uf.UpdateConfig
  f.EnableScripts   = pfUI.uf.EnableScripts
  f.GetColor        = pfUI.uf.GetColor

  -- cache values to the frame
  f.label = unit
  f.fname = fname
  f.id = id
  f.config = config or pfUI_config.unitframes.fallback
  f.tick = tick

  -- disable events for unknown unitstrings
  if not pfValidUnits[unit .. id] then
    f.unitname = unit
    f.label, f.id = "mouseover", ""
    f.RegisterEvent = function() return end
  end

  f.hp = CreateFrame("Frame",nil, f)
  f.hp.bar = CreateFrame("StatusBar", nil, f.hp)
  f.power = CreateFrame("Frame",nil, f)
  f.power.bar = CreateFrame("StatusBar", nil, f.power)
  f.hpLeftText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.hpRightText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.hpCenterText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.powerLeftText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.powerRightText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.powerCenterText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")

  f.incHeal = CreateFrame("StatusBar", nil, f.hp)
  f.ressIcon = CreateFrame("Frame", nil, f.hp.bar)
  f.ressIcon.texture = f.ressIcon:CreateTexture(nil,"BACKGROUND")

  f.leaderIcon = CreateFrame("Frame", nil, f.hp.bar)
  f.leaderIcon.texture = f.leaderIcon:CreateTexture(nil,"BACKGROUND")

  f.lootIcon = CreateFrame("Frame",nil, f.hp.bar)
  f.lootIcon.texture = f.lootIcon:CreateTexture(nil,"BACKGROUND")

  f.raidIcon = CreateFrame("Frame", nil, f.hp.bar)
  f.raidIcon.texture = f.raidIcon:CreateTexture(nil,"ARTWORK")

  f.portrait = CreateFrame("Frame", "pfPortrait" .. f.label .. f.id, f)
  f.portrait.tex = f.portrait:CreateTexture("pfPortraitTexture" .. f.label .. f.id, "OVERLAY")
  f.portrait.model = CreateFrame("PlayerModel", "pfPortraitModel" .. f.label .. f.id, f.portrait)
  f.portrait.model.next = CreateFrame("PlayerModel", nil, nil)

  f:Hide()
  f:UpdateConfig()
  f:UpdateFrameSize()
  f:EnableScripts()

  table.insert(pfUI.uf.frames, f)
  return f
end

function pfUI.uf:RefreshUnitAnimation(unitframe)
  if not unitframe.cache then return end
  if not unitframe.cache.hp or not unitframe.cache.power then return end
  if not UnitIsConnected(unitframe.label .. unitframe.id) then return end

  local hpDiff = abs(unitframe.cache.hp - unitframe.cache.hpdisplay)
  local powerDiff = abs(unitframe.cache.power - unitframe.cache.powerdisplay)

  if UnitName(unitframe.label .. unitframe.id) ~= ( unitframe.lastUnit or "" ) then
    -- instant refresh on unit change (e.g. target)
    unitframe.cache.hp = UnitHealth(unitframe.label .. unitframe.id)
    unitframe.cache.hpmax = UnitHealthMax(unitframe.label .. unitframe.id)

    if unitframe.config.invert_healthbar == "1" then
      unitframe.cache.hp = unitframe.cache.hpmax - unitframe.cache.hp
    end

    unitframe.cache.hpdisplay = unitframe.cache.hp
    unitframe.hp.bar:SetMinMaxValues(0, unitframe.cache.hpmax)
    unitframe.hp.bar:SetValue(unitframe.cache.hp)

    unitframe.cache.powermax = UnitManaMax(unitframe.label .. unitframe.id)
    unitframe.cache.powerdisplay = unitframe.cache.power
    unitframe.power.bar:SetMinMaxValues(0, unitframe.cache.powermax)
    unitframe.power.bar:SetValue(unitframe.cache.power)

    unitframe.lastUnit = UnitName(unitframe.label .. unitframe.id)
  else
    -- smoothen animation based on framerate
    local fpsmod = GetFramerate() / 30

    -- health animation active
    if unitframe.cache.hpanimation then
      if unitframe.cache.hpdisplay < unitframe.cache.hp then
        unitframe.cache.hpdisplay = unitframe.cache.hpdisplay + ceil(hpDiff / (pfUI_config.unitframes.animation_speed * fpsmod))
      elseif unitframe.cache.hpdisplay > unitframe.cache.hp then
        unitframe.cache.hpdisplay = unitframe.cache.hpdisplay - ceil(hpDiff / (pfUI_config.unitframes.animation_speed * fpsmod))
      else
        unitframe.cache.hpdisplay = unitframe.cache.hp
        unitframe.cache.hpanimation = nil
      end

      -- set statusbar
      unitframe.hp.bar:SetValue(unitframe.cache.hpdisplay)
    end

    -- power animation active
    if unitframe.cache.poweranimation then
      if unitframe.cache.powerdisplay < unitframe.cache.power then
        unitframe.cache.powerdisplay = unitframe.cache.powerdisplay + ceil(powerDiff / (pfUI_config.unitframes.animation_speed * fpsmod))
      elseif unitframe.cache.powerdisplay > unitframe.cache.power then
        unitframe.cache.powerdisplay = unitframe.cache.powerdisplay - ceil(powerDiff / (pfUI_config.unitframes.animation_speed * fpsmod))
      else
        unitframe.cache.powerdisplay = unitframe.cache.power
        unitframe.cache.poweranimation = nil
      end

      -- set statusbar
      unitframe.power.bar:SetValue(unitframe.cache.powerdisplay)
    end
  end
end

function pfUI.uf:RefreshUnitState(unitframe)
  if UnitIsConnected(this.label .. this.id) or (pfUI.unlock and pfUI.unlock:IsShown()) then
    -- online (or unlock)
    if unitframe.config.faderange == "1" then
      if pfUI.api.UnitInRange(unitframe.label .. unitframe.id, 4) or (pfUI.unlock and pfUI.unlock:IsShown()) then
        if unitframe:GetAlpha() ~= 1 then
          unitframe:SetAlpha(1)
          if unitframe.config.portrait == "bar" then
            unitframe.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)
          end
        end
      else
        if unitframe:GetAlpha() ~= .5 then
          unitframe:SetAlpha(.5)
          if unitframe.config.portrait == "bar" then
            unitframe.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)
          end
        end
      end
    else
      if unitframe:GetAlpha() ~= 1 then
        unitframe:SetAlpha(1)
        if unitframe.config.portrait == "bar" then
          unitframe.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)
        end
      end
    end
  else
    -- offline
    unitframe.hp.bar:SetMinMaxValues(0, 100)
    unitframe.power.bar:SetMinMaxValues(0, 100)
    unitframe.hp.bar:SetValue(0)
    unitframe.power.bar:SetValue(0)

    if ( unitframe.label == "party" or unitframe.label == "raid" ) and unitframe:GetAlpha() ~= .25 then
      unitframe:SetAlpha(.25)
      if unitframe.config.portrait == "bar" then
        unitframe.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)
      end
    end
  end
end

function pfUI.uf:RefreshUnit(unit, component)
  if not unit.label then return end
  if not unit.hp then return end
  if not unit.power then return end

  local component = component or ""
  -- break early on misconfigured UF's
  if unit.label == "target" or unit.label == "targettarget" then
    if pfScanActive == true then return end
  end

  -- show groupframes as raid
  if pfUI_config["unitframes"]["raidforgroup"] == "1" then
    if strsub(unit:GetName(),0,6) == "pfRaid" then
      local id = tonumber(strsub(unit:GetName(),7,8))

      if not UnitInRaid("player") and GetNumPartyMembers() > 0 then
        if id == 1 then
          unit.id = ""
          unit.label = "player"
        elseif id <= 5 then
          unit.id = id - 1
          unit.label = "party"
        end
      elseif unit.label == "party" or unit.label == "player" then
        unit.id = id
        unit.label = "raid"
      end
    end
  end

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  local C = pfUI_config

  -- hide and return early on unused frames
  if not ( pfUI.unlock and pfUI.unlock:IsShown() ) then
    -- check existing units or focus frames
    if unit.unitname and unit.unitname ~= "focus" then
      unit:Show()
    elseif UnitName(unit.label .. unit.id) then
      -- hide group while in raid and option is set
      if pfUI_config["unitframes"]["group"]["hide_in_raid"] == "1" and strsub(unit.label,0,5) == "party" and UnitInRaid("player") then
        unit:Hide()
        return

      -- hide existing but too far away pet
      elseif strsub(unit.label,0,8) == "partypet" and not UnitIsVisible(unit.label .. unit.id) then
        unit:Hide()
        return

      -- hide self in group if solo or hide in raid is set
      elseif unit.fname == "Group0" or unit.fname == "PartyPet0" or unit.fname == "Party0Target" then
        if ( GetNumPartyMembers() <= 0 ) or ( pfUI_config["unitframes"]["group"]["hide_in_raid"] == "1" and UnitInRaid("player") ) then
          unit:Hide()
          return
        end
      end

      unit:Show()
    else
      -- hide unused frame
      unit:Hide()
      return
    end
  end

  if not unit.cache then unit.cache = {} end
  if not unit.id then unit.id = "" end

  if not unit:IsShown() then return end

  -- Raid Icon
  if unit.raidIcon and ( component == "all" or component == "raidIcon" ) then
    local raidIcon = GetRaidTargetIndex(unit.label .. unit.id)
    if raidIcon and UnitName(unit.label .. unit.id) then
      SetRaidTargetIconTexture(unit.raidIcon.texture, raidIcon)
      unit.raidIcon:Show()
    else
      unit.raidIcon:Hide()
    end
  end

  -- Leader Icon
  if unit.leaderIcon and ( component == "all" or component == "leaderIcon" ) then
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
      unit.leaderIcon:Hide()
    elseif UnitIsPartyLeader(unit.label .. unit.id) then
      unit.leaderIcon:Show()
    else
      unit.leaderIcon:Hide()
    end
  end

  -- Loot Icon
  if unit.lootIcon and ( component == "all" or component == "lootIcon" ) then
    local _, lootmaster = GetLootMethod()
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
      unit.lootIcon:Hide()
    elseif lootmaster and (
        ( unit.label == "party" and tonumber(unit.id) == lootmaster ) or
        ( unit.label == "player" and lootmaster == 0 ) )then
      unit.lootIcon:Show()
    else
      unit.lootIcon:Hide()
    end
  end

  -- Buffs
  if unit.buffs and ( component == "all" or component == "aura" ) then
    for i=1, unit.config.bufflimit do
      local texture, stacks
      if unit.label == "player" then
       stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HELPFUL"))
       texture = GetPlayerBuffTexture(GetPlayerBuff(i-1,"HELPFUL"))
      else
       texture, stacks = UnitBuff(unit.label .. unit.id ,i)
      end

      pfUI.api.CreateBackdrop(unit.buffs[i], default_border)
      unit.buffs[i]:SetNormalTexture(texture)
      for i,v in ipairs({unit.buffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

      if texture then
        unit.buffs[i]:Show()

        if stacks > 1 then
          unit.buffs[i].stacks:SetText(stacks)
        else
          unit.buffs[i].stacks:SetText("")
        end
      else
        unit.buffs[i]:Hide()
      end
    end
  end

  -- Debuffs
  if unit.debuffs and ( component == "all" or component == "aura" ) then
    for i=1, unit.config.debufflimit do
      local perrow = unit.config.debuffperrow
      local bperrow = unit.config.buffperrow

      local row = floor((i-1) / unit.config.debuffperrow)
      local buffrow = 0

      if unit.config.buffs == unit.config.debuffs then
        if unit.buffs[0*bperrow+1] and unit.buffs[0*bperrow+1]:IsShown() then buffrow = buffrow + 1 end
        if unit.buffs[1*bperrow+1] and unit.buffs[1*bperrow+1]:IsShown() then buffrow = buffrow + 1 end
        if unit.buffs[2*bperrow+1] and unit.buffs[2*bperrow+1]:IsShown() then buffrow = buffrow + 1 end
        if unit.buffs[3*bperrow+1] and unit.buffs[3*bperrow+1]:IsShown() then buffrow = buffrow + 1 end
      end

      local invert, af, as
      if unit.config.debuffs == "top" then
        invert = 1
        af = "BOTTOMLEFT"
        as = "TOPLEFT"
      elseif unit.config.debuffs == "bottom" then
        invert = -1
        af = "TOPLEFT"
        as = "BOTTOMLEFT"
      end

      unit.debuffs[i]:SetPoint(af, unit, as,
      (i-1-(row)*perrow)*((2*default_border) + unit.config.debuffsize + 1),
      invert * (row+buffrow)*((2*default_border) + unit.config.debuffsize + 1) + invert*(2*default_border + 1))

      local texture, stacks, dtype
      if unit.label == "player" then
        texture = GetPlayerBuffTexture(GetPlayerBuff(i-1, "HARMFUL"))
        stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1, "HARMFUL"))
        dtype = GetPlayerBuffDispelType(GetPlayerBuff(i-1, "HARMFUL"))
     else
       texture, stacks, dtype = UnitDebuff(unit.label .. unit.id ,i)
     end

      pfUI.api.CreateBackdrop(unit.debuffs[i], default_border)
      unit.debuffs[i]:SetNormalTexture(texture)
      for i,v in ipairs({unit.debuffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

      if dtype == "Magic" then
        unit.debuffs[i].backdrop:SetBackdropBorderColor(0,1,1,1)
      elseif dtype == "Poison" then
        unit.debuffs[i].backdrop:SetBackdropBorderColor(0,1,0,1)
      elseif dtype == "Curse" then
        unit.debuffs[i].backdrop:SetBackdropBorderColor(1,0,1,1)
      elseif dtype == "Disease" then
        unit.debuffs[i].backdrop:SetBackdropBorderColor(1,1,0,1)
      else
        unit.debuffs[i].backdrop:SetBackdropBorderColor(1,0,0,1)
      end

      if texture then
        unit.debuffs[i]:Show()

        if unit:GetName() == "pfPlayer" then
            local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(unit.debuffs[i]:GetID() - 1, "HARMFUL"),"HARMFUL")
            CooldownFrame_SetTimer(unit.debuffs[i].cd, GetTime(), timeleft, 1)
        elseif pfUI.debuffs and pfUI.debuffs.active then
            local effect = pfUI.debuffs:GetDebuffName(unit.label .. unit.id, unit.debuffs[i]:GetID())
            local start, duration, timeleft = pfUI.debuffs:GetDebuffInfo(unit.label .. unit.id, effect)
            CooldownFrame_SetTimer(unit.debuffs[i].cd, start, duration, 1)
        end

        if stacks > 1 then
          unit.debuffs[i].stacks:SetText(stacks)
        else
          unit.debuffs[i].stacks:SetText("")
        end
      else
        unit.debuffs[i]:Hide()
      end
    end
  end

  -- indicators
  if component == "all" or component == "aura" then
    pfUI.uf:SetupDebuffFilter()
    if table.getn(pfUI.uf.debuffs) > 0 and unit.config.debuff_indicator == "1" then
      local infected = false
      for i=1,32 do
        local _,_,dtype = UnitDebuff(unit.label .. unit.id, i)
        if dtype then
          for _, filter in pairs(pfUI.uf.debuffs) do
            if filter == string.lower(dtype) then
              if dtype == "Magic" then
                if not unit.hp.bar.magic then
                  unit.hp.bar.magic = CreateFrame("Frame", unit.hp.bar)
                  unit.hp.bar.magic:SetAllPoints(unit)
                  unit.hp.bar.magic:SetParent(unit.hp.bar)
                  unit.hp.bar.magic.tex = unit.hp.bar.magic:CreateTexture("OVERLAY")
                  unit.hp.bar.magic.tex:SetAllPoints(unit.hp.bar.magic)
                  unit.hp.bar.magic.tex:SetTexture(.2,.8,.8,.4)
                end
                unit.hp.bar.magic:Show()
                infected = true

              elseif dtype == "Poison" then
                if not unit.hp.bar.poison then
                  unit.hp.bar.poison = CreateFrame("Frame", unit.hp.bar)
                  unit.hp.bar.poison:SetAllPoints(unit)
                  unit.hp.bar.poison:SetParent(unit.hp.bar)
                  unit.hp.bar.poison.tex = unit.hp.bar.poison:CreateTexture("OVERLAY")
                  unit.hp.bar.poison.tex:SetAllPoints(unit.hp.bar.poison)
                  unit.hp.bar.poison.tex:SetTexture(.2,.8,.2,.4)
                end
                unit.hp.bar.poison:Show()
                infected = true

              elseif dtype == "Curse" then
                if not unit.hp.bar.curse then
                  unit.hp.bar.curse = CreateFrame("Frame", unit.hp.bar)
                  unit.hp.bar.curse:SetAllPoints(unit)
                  unit.hp.bar.curse:SetParent(unit.hp.bar)
                  unit.hp.bar.curse.tex = unit.hp.bar.curse:CreateTexture("OVERLAY")
                  unit.hp.bar.curse.tex:SetAllPoints(unit.hp.bar.curse)
                  unit.hp.bar.curse.tex:SetTexture(.8,.2,.8,.4)
                end
                unit.hp.bar.curse:Show()
                infected = true

              elseif dtype == "Disease" then
                if not unit.hp.bar.disease then
                  unit.hp.bar.disease = CreateFrame("Frame", unit.hp.bar)
                  unit.hp.bar.disease:SetAllPoints(unit)
                  unit.hp.bar.disease:SetParent(unit.hp.bar)
                  unit.hp.bar.disease.tex = unit.hp.bar.disease:CreateTexture("OVERLAY")
                  unit.hp.bar.disease.tex:SetAllPoints(unit.hp.bar.disease)
                  unit.hp.bar.disease.tex:SetTexture(.8,.8,.2,.4)
                end
                unit.hp.bar.disease:Show()
                infected = true
              end
            end
          end
        end
      end
      if infected == false then
        if unit.hp.bar.magic then unit.hp.bar.magic:Hide() end
        if unit.hp.bar.poison then unit.hp.bar.poison:Hide() end
        if unit.hp.bar.curse then unit.hp.bar.curse:Hide() end
        if unit.hp.bar.disease then unit.hp.bar.disease:Hide() end
      end
    end

    pfUI.uf:SetupBuffFilter()
    if table.getn(pfUI.uf.buffs) > 0 and unit.config.buff_indicator == "1" then
      local active = {}

      for i=1,32 do
        local texture = UnitBuff(unit.label .. unit.id,i)

        if texture then
          -- match filter
          for _, filter in pairs(pfUI.uf.buffs) do
            if filter == string.lower(texture) then
              table.insert(active, texture)
              break
            end
          end
        end
      end

      -- add icons for every found buff
      for pos, icon in pairs(active) do
        pfUI.uf:AddIcon(unit, pos, icon)
      end

      -- hide unued icon slots
      for pos=table.getn(active)+1, 6 do
        pfUI.uf:HideIcon(unit, pos)
      end
    end
  end

  -- portrait
  if unit.portrait and ( component == "all" or component == "portrait" ) then
    if pfUI_config.unitframes.always2dportrait == "1" then
      unit.portrait.tex:Show()
      unit.portrait.model:Hide()
      SetPortraitTexture(unit.portrait.tex, unit.label .. unit.id)
    else
      if not UnitIsVisible(unit.label .. unit.id) or not UnitIsConnected(unit.label .. unit.id) then
        if unit.config.portrait == "bar" then
          unit.portrait.tex:Hide()
          unit.portrait.model:Hide()
        elseif pfUI_config.unitframes.portraittexture == "1" then
          unit.portrait.tex:Show()
          unit.portrait.model:Hide()
          SetPortraitTexture(unit.portrait.tex, unit.label .. unit.id)
        else
          unit.portrait.tex:Hide()
          unit.portrait.model:Show()
          unit.portrait.model:SetModelScale(4.25)
          unit.portrait.model:SetPosition(0, 0, -1)
          unit.portrait.model:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
        end
      else
        if unit.config.portrait == "bar" then
          unit.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)
        end
        unit.portrait.tex:Hide()
        unit.portrait.model:Show()

        if unit.tick then
          unit.portrait.model.next:SetUnit(unit.label .. unit.id)
          if unit.portrait.model.lastUnit ~= UnitName(unit.label .. unit.id) or unit.portrait.model:GetModel() ~= unit.portrait.model.next:GetModel() then
            unit.portrait.model:SetUnit(unit.label .. unit.id)
            unit.portrait.model.lastUnit = UnitName(unit.label .. unit.id)
            unit.portrait.model:SetCamera(0)
          end
        else
          unit.portrait.model:SetUnit(unit.label .. unit.id)
          unit.portrait.model:SetCamera(0)
        end
      end
    end
  end

  -- Unit HP/MP
  unit.cache.hp = UnitHealth(unit.label..unit.id)
  unit.cache.hpmax = UnitHealthMax(unit.label..unit.id)
  unit.cache.hpdisplay = unit.hp.bar:GetValue()

  unit.cache.power = UnitMana(unit.label .. unit.id)
  unit.cache.powermax = UnitManaMax(unit.label .. unit.id)
  unit.cache.powerdisplay = unit.power.bar:GetValue()

  unit.hp.bar:SetMinMaxValues(0, unit.cache.hpmax)
  unit.power.bar:SetMinMaxValues(0, unit.cache.powermax)

  if unit.config.invert_healthbar == "1" then
    unit.cache.hp = unit.cache.hpmax - unit.cache.hp
  end

  if unit.cache.hpdisplay ~= unit.cache.hp then
    if pfUI_config.unitframes.animation_speed == "1" then
      unit.hp.bar:SetValue(unit.cache.hp)
    else
      unit.cache.hpanimation = true
    end
  end

  if unit.cache.powerdisplay ~= unit.cache.power then
    if pfUI_config.unitframes.animation_speed == "1" then
      unit.power.bar:SetValue(unit.cache.power)
    else
      unit.cache.poweranimation = true
    end
  end

  local color = { r = .2, g = .2, b = .2 }
  if UnitIsPlayer(unit.label..unit.id) then
    local _, class = UnitClass(unit.label..unit.id)
    color = RAID_CLASS_COLORS[class] or color
  elseif unit.label == "pet" then
    local happiness = GetPetHappiness()
    if happiness == 1 then
      color = { r = 1, g = 0, b = 0 }
    elseif happiness == 2 then
      color = { r = 1, g = 1, b = 0 }
    else
      color = { r = 0, g = 1, b = 0 }
    end
  else
    color = UnitReactionColor[UnitReaction(unit.label..unit.id, "player")] or color
  end

  local r, g, b = .2, .2, .2
  if pfUI_config.unitframes.custom == "1" then
    local cr, cg, cb, ca = pfUI.api.strsplit(",", pfUI_config.unitframes.customcolor)
    cr, cg, cb, ca = tonumber(cr), tonumber(cg), tonumber(cb), tonumber(ca)
    unit.hp.bar:SetStatusBarColor(cr, cg, cb, ca)
    if pfUI_config.unitframes.pastel == "1" then
      r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5
    else
      r, g, b = color.r, color.g, color.b
    end
  else
    if pfUI_config.unitframes.pastel == "1" then
      r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5
    else
      r, g, b = color.r, color.g, color.b
    end
    unit.hp.bar:SetStatusBarColor(r, g, b)
  end

  local p = ManaBarColor[UnitPowerType(unit.label..unit.id)]
  local pr, pg, pb = 0, 0, 0
  if p then pr, pg, pb = p.r + .5, p.g +.5, p.b +.5 end
  unit.power.bar:SetStatusBarColor(pr, pg, pb)

  if UnitName(unit.label..unit.id) then
    unit.hpLeftText:SetText(pfUI.uf:GetStatusValue(unit, "hpleft"))
    unit.hpCenterText:SetText(pfUI.uf:GetStatusValue(unit, "hpcenter"))
    unit.hpRightText:SetText(pfUI.uf:GetStatusValue(unit, "hpright"))

    unit.powerLeftText:SetText(pfUI.uf:GetStatusValue(unit, "powerleft"))
    unit.powerCenterText:SetText(pfUI.uf:GetStatusValue(unit, "powercenter"))
    unit.powerRightText:SetText(pfUI.uf:GetStatusValue(unit, "powerright"))

    if UnitIsTapped(unit.label .. unit.id) and not UnitIsTappedByPlayer(unit.label .. unit.id) then
      unit.hp.bar:SetStatusBarColor(.5,.5,.5,.5)
    end
  end
end

function pfUI.uf:ClickAction(button)
  local label = this.label or ""
  local id = this.id or ""
  local unitstr = label .. id

  if SpellIsTargeting() and button == "RightButton" then
    SpellStopTargeting()
    return
  end

  if SpellIsTargeting() and button == "LeftButton" then
    SpellTargetUnit(unitstr)
  elseif CursorHasItem() then
    DropItemOnUnit(unitstr)
  end

  -- dropdown menues
  if button == "RightButton" then
    if label == "player" then
      ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor")
    elseif label == "target" then
      ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
    elseif label == "pet" then
      ToggleDropDownMenu(1, nil, PetFrameDropDown, "cursor")
    elseif label == "party" then
      ToggleDropDownMenu(1, nil, getglobal("PartyMemberFrame" .. this.id .. "DropDown"), "cursor")
    elseif label == "raid" then
      -- RaidFrameDropDown_Initialize expects .name and .unit attributes on raid unit buttons
      if not (this.name) then this.name = this.lastUnit end
      if not (this.unit) then this.unit = unitstr end
      ToggleDropDownMenu(1, nil, getglobal("RaidMemberFrame" .. this.id .. "DropDown"), "cursor")
      FriendsDropDown.initialize = RaidFrameDropDown_Initialize
      FriendsDropDown.displayMode = "MENU"
      ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
    end
  else
    -- drop food on petframe
    if label == "pet" and CursorHasItem() then
      local _, playerClass = UnitClass("player")
      if playerClass == "HUNTER" then
        DropItemOnUnit("pet")
        return
      end
    end

    -- prevent TargetLastTarget if target was target
    local tswitch = UnitIsUnit(unitstr, "target")

    -- default click
    TargetUnit(unitstr)

    if this.config.clickcast == "1" then
      -- clickcast: shift modifier
      if IsShiftKeyDown() then
        if pfUI_config.unitframes.clickcast_shift ~= "" then
          CastSpellByName(pfUI_config.unitframes.clickcast_shift)
          if not tswitch then TargetLastTarget() end
          return
        end

      -- clickcast: alt modifier
      elseif IsAltKeyDown() then
        if pfUI_config.unitframes.clickcast_alt ~= "" then
          CastSpellByName(pfUI_config.unitframes.clickcast_alt)
          if not tswitch then TargetLastTarget() end
          return
        end

      -- clickcast: ctrl modifier
      elseif IsControlKeyDown() then
        if pfUI_config.unitframes.clickcast_ctrl ~= "" then
          CastSpellByName(pfUI_config.unitframes.clickcast_ctrl)
          if not tswitch then TargetLastTarget() end
          return
        end

      -- clickcast: default
      else
        if pfUI_config.unitframes.clickcast ~= "" then
          CastSpellByName(pfUI_config.unitframes.clickcast)
          if not tswitch then TargetLastTarget() end
          return
        end
      end
    end
  end
end

function pfUI.uf:AddIcon(frame, pos, icon)
  local iconsize = C.unitframes.indicator_size
  if not frame.hp then return end
  local frame = frame.hp.bar
  if pos > floor(frame:GetWidth() / iconsize) then return end

  if not frame.icon then frame.icon = {} end

  for i=1,6 do
    if not frame.icon[i] then
      frame.icon[i] = CreateFrame("Frame", frame)
      frame.icon[i]:SetPoint("TOPLEFT", frame, "TOPLEFT", (i-1)*iconsize, 0)
      frame.icon[i]:SetWidth(iconsize)
      frame.icon[i]:SetHeight(iconsize)
      frame.icon[i]:SetAlpha(.7)
      frame.icon[i]:SetParent(frame)
      frame.icon[i].tex = frame.icon[i]:CreateTexture("OVERLAY")
      frame.icon[i].tex:SetAllPoints(frame.icon[i])
      frame.icon[i].tex:SetTexCoord(.08, .92, .08, .92)
    end
  end
  frame.icon[pos].tex:SetTexture(icon)
  pfUI.api.CreateBackdrop(frame.icon[pos], nil, true)
  frame.icon[pos]:Show()
end

function pfUI.uf:HideIcon(frame, pos)
  if not frame or not frame.hp or not frame.hp.bar then return end

  local frame = frame.hp.bar
  if frame.icon and frame.icon[pos] then
    frame.icon[pos]:Hide()
  end
end

function pfUI.uf:SetupDebuffFilter()
  if pfUI.uf.debuffs then return end

  local _, myclass = UnitClass("player")
  pfUI.uf.debuffs = {}
  if myclass == "PALADIN" or myclass == "PRIEST" or myclass == "WARLOCK" or pfUI_config.unitframes.debuffs_class == "0" then
    table.insert(pfUI.uf.debuffs, "magic")
  end

  if myclass == "DRUID" or myclass == "PALADIN" or myclass == "SHAMAN" or pfUI_config.unitframes.debuffs_class == "0" then
    table.insert(pfUI.uf.debuffs, "poison")
  end

  if myclass == "PRIEST" or myclass == "PALADIN" or myclass == "SHAMAN" or pfUI_config.unitframes.debuffs_class == "0" then
    table.insert(pfUI.uf.debuffs, "disease")
  end

  if myclass == "DRUID" or myclass == "MAGE" or pfUI_config.unitframes.debuffs_class == "0" then
    table.insert(pfUI.uf.debuffs, "curse")
  end
end

function pfUI.uf:SetupBuffFilter()
  if pfUI.uf.buffs then return end

  local _, myclass = UnitClass("player")

  pfUI.uf.buffs = {}

  -- [[ DRUID ]]
  if myclass == "DRUID" then
    -- Gift of the Wild
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_regeneration")

    -- Thorns
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_thorns")
  end

  -- [[ PRIEST ]]
  if myclass == "PRIEST" then
    -- Prayer Of Fortitude"
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_wordfortitude")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_prayeroffortitude")

    -- Prayer of Spirit
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_divinespirit")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_prayerofspirit")

    -- Shadow Protection
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_antishadow")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_prayerofshadowprotection")

    -- Fear Ward
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_excorcism")
  end

  -- [[ PALADIN ]]
  if myclass == "PALADIN" then
    -- Blessing of Salvation
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_greaterblessingofsalvation")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_sealofsalvation")

    -- Blessing of Wisdom
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_sealofwisdom")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_greaterblessingofwisdom")

    -- Blessing of Sanctuary
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_lightningshield")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_greaterblessingofsanctuary")

    -- Blessing of Kings
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_magic_magearmor")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_magic_greaterblessingofkings")

    -- Blessing of Might
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_fistofjustice")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_greaterblessingofkings")
  end


  -- [[ WARLOCK ]]
  if myclass == "WARLOCK" then
    -- Fire Shield
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_fire_firearmor")

    -- Blood Pact
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_bloodboil")

    -- Soulstone
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_soulgem")

    -- Unending Breath
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_demonbreath")

    -- Detect Greater Invisibility or Detect Invisibility
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_detectinvisibility")

    -- Detect Lesser Invisibility
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_detectlesserinvisibility")

    -- Paranoia
    table.insert(pfUI.uf.buffs, "interface\\icons\\Spell_Shadow_AuraOfDarkness")
  end


  -- [[ WARRIOR ]]
  if myclass == "WARRIOR" then
    -- Battle Shout
    table.insert(pfUI.uf.buffs, "interface\\icons\\ability_warrior_battleshout")
  end


  -- [[ MAGE ]]
  if myclass == "MAGE" then
    -- Arcane Intellect
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_magicalsentry")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_arcaneintellect")

    -- Dampen Magic
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_abolishmagic")

    -- Amplify Magic
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_flashheal")
  end

  -- PROCS
  -- [[ SHAMAN ]]
  if (pfUI_config.unitframes.all_procs == "1" or myclass == "SHAMAN") and pfUI_config.unitframes.show_procs == "1" then
    -- Ancestral Fortitude
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_undyingstrength")

    -- Healing Way
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_healingway")
  end

  if (pfUI_config.unitframes.all_procs == "1" or myclass == "PRIEST") and pfUI_config.unitframes.show_procs == "1" then
    -- Inspiration
    table.insert(pfUI.uf.buffs, "interface\\icons\\inv_shield_06")
  end

  -- HOTS
  if (pfUI_config.unitframes.all_hots == "1" or myclass == "PRIEST") and pfUI_config.unitframes.show_hots == "1" then
    -- Renew
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_renew")
  end

  if (pfUI_config.unitframes.all_hots == "1" or myclass == "DRUID") and pfUI_config.unitframes.show_hots == "1" then
    -- Regrowth
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_resistnature")

    -- Rejuvenation
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_rejuvenation")
  end
end

function pfUI.uf:GetLevelString(unitstr)
  local level = UnitLevel(unitstr)
  if level == -1 then level = "??" end

  local elite = UnitClassification(unitstr)
  if elite == "worldboss" then
    level = level .. "B"
  elseif elite == "rareelite" then
    level = level .. "R+"
  elseif elite == "elite" then
    level = level .. "+"
  elseif elite == "rare" then
    level = level .. "R"
  end

  return level
end

function pfUI.uf:GetStatusValue(unit, pos)
  if not pos or not unit then return end
  local config = unit.config["txt"..pos]
  local unitstr = unit.label .. unit.id
  local frame = unit[pos .. "Text"]

  -- as a fallback, draw the name
  if pos == "center" and not config then
    config = "unit"
  end

  if config == "unit" then
    local name = unit:GetColor("unit") .. UnitName(unitstr)
    local level = unit:GetColor("level") .. pfUI.uf:GetLevelString(unitstr)
    return level .. "  " .. name
  elseif config == "name" then
    return unit:GetColor("unit") .. UnitName(unitstr)
  elseif config == "level" then
    return unit:GetColor("level") .. pfUI.uf:GetLevelString(unitstr)
  elseif config == "class" then
    return unit:GetColor("class") .. (UnitClass(unitstr) or UNKNOWN)

  -- health
  elseif config == "health" then
    if unit.label == "target" and MobHealth3 then
      local hp, hpmax = MobHealth3:GetUnitHealth(unit.label)
      return unit:GetColor("health") .. pfUI.api.Abbreviate(hp)
    elseif unit.label == "target" and MobHealthFrame and MobHealth_GetTargetCurHP() then
      local hp = MobHealth_GetTargetCurHP()
      return unit:GetColor("health") .. pfUI.api.Abbreviate(hp)
    end
    return unit:GetColor("health") .. pfUI.api.Abbreviate(UnitHealth(unitstr))
  elseif config == "healthmax" then
    if unit.label == "target" and MobHealth3 then
      local hp, hpmax = MobHealth3:GetUnitHealth(unit.label)
      return unit:GetColor("health") .. pfUI.api.Abbreviate(hpmax)
    elseif unit.label == "target" and MobHealthFrame and MobHealth_GetTargetMaxHP() then
      local hpmax = MobHealth_GetTargetMaxHP()
      return unit:GetColor("health") .. pfUI.api.Abbreviate(hpmax)
    end
    return unit:GetColor("health") .. pfUI.api.Abbreviate(UnitHealthMax(unitstr))
  elseif config == "healthperc" then
    return unit:GetColor("health") .. ceil(UnitHealth(unitstr) / UnitHealthMax(unitstr) * 100)
  elseif config == "healthmiss" then
    local health = ceil(UnitHealth(unitstr) - UnitHealthMax(unitstr))
    if health == 0 or UnitIsDead(unitstr) then
      return ""
    else
      return unit:GetColor("health") .. pfUI.api.Abbreviate(health)
    end
  elseif config == "healthdyn" then
    if UnitHealth(unitstr) ~= UnitHealthMax(unitstr) then
      if unit.label == "target" and MobHealth3 then
        local hp, hpmax = MobHealth3:GetUnitHealth(unit.label)
        return unit:GetColor("health") .. pfUI.api.Abbreviate(hp) .. " - " .. ceil(hp / hpmax * 100) .. "%"
      elseif unit.label == "target" and MobHealthFrame and MobHealth_GetTargetCurHP() then
        local hp, hpmax = MobHealth_GetTargetCurHP(),MobHealth_GetTargetMaxHP()
        return unit:GetColor("health") .. pfUI.api.Abbreviate(hp) .. " - " .. ceil(hp / hpmax * 100) .. "%"
      end
      return unit:GetColor("health") .. pfUI.api.Abbreviate(UnitHealth(unitstr)) .. " - " .. ceil(UnitHealth(unitstr) / UnitHealthMax(unitstr) * 100) .. "%"
    else
      if unit.label == "target" and MobHealth3 then
        local hp, hpmax = MobHealth3:GetUnitHealth(unit.label)
        return unit:GetColor("health") .. pfUI.api.Abbreviate(hp)
      elseif unit.label == "target" and MobHealthFrame and MobHealth_GetTargetCurHP() then
        local hp = MobHealth_GetTargetCurHP()
        return unit:GetColor("health") .. pfUI.api.Abbreviate(hp)
      end
      return unit:GetColor("health") .. pfUI.api.Abbreviate(UnitHealth(unitstr))
    end
  elseif config == "healthminmax" then
    local hp, hpmax = UnitHealth(unitstr), UnitHealthMax(unitstr)
    if unit.label == "target" and MobHealth3 then
      hp, hpmax = MobHealth3:GetUnitHealth(unit.label)
    elseif unit.label == "target" and MobHealthFrame and MobHealth_GetTargetCurHP() then
      local hp, hpmax = MobHealth_GetTargetCurHP(), MobHealth_GetTargetMaxHP()
    end
    return unit:GetColor("health") .. pfUI.api.Abbreviate(hp) .. "/" .. pfUI.api.Abbreviate(hpmax)

  -- mana/power/focus
  elseif config == "power" then
    return unit:GetColor("power") .. pfUI.api.Abbreviate(UnitMana(unitstr))
  elseif config == "powermax" then
    return unit:GetColor("power") .. pfUI.api.Abbreviate(UnitManaMax(unitstr))
  elseif config == "powerperc" then
    local perc = UnitManaMax(unitstr) > 0 and ceil(UnitMana(unitstr) / UnitManaMax(unitstr) * 100) or 0
    return unit:GetColor("power") .. perc
  elseif config == "powermiss" then
    local power = ceil(UnitMana(unitstr) - UnitManaMax(unitstr))
    if power == 0 then
      return ""
    else
      return unit:GetColor("power") .. pfUI.api.Abbreviate(power)
    end
  elseif config == "powerdyn" then
    if UnitMana(unitstr) ~= UnitManaMax(unitstr) then
      return unit:GetColor("power") .. pfUI.api.Abbreviate(UnitMana(unitstr)) .. " - " .. ceil(UnitMana(unitstr) / UnitManaMax(unitstr) * 100) .. "%"
    else
      return unit:GetColor("power") .. pfUI.api.Abbreviate(UnitMana(unitstr))
    end
  elseif config == "powerminmax" then
    return unit:GetColor("power") .. pfUI.api.Abbreviate(UnitMana(unitstr)) .. "/" .. pfUI.api.Abbreviate(UnitManaMax(unitstr))
  else
    return ""
  end
end

function pfUI.uf.GetColor(self, preset)
  local config = self.config

  local unitstr = self.label .. self.id
  local r, g, b = 1, 1, 1

  if preset == "unit" and config["classcolor"] == "1" then
    if UnitIsPlayer(unitstr) then
      local _, class = UnitClass(unitstr)
      if RAID_CLASS_COLORS[class] then
        r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
      end
    elseif self.label == "pet" then
      local happiness = GetPetHappiness()
      if happiness == 1 then
        r, g, b = 1, 0, 0
      elseif happiness == 2 then
        r, g, b = 1, 1, 0
      else
        r, g, b = 0, 1, 0
      end
    else
      local color = UnitReactionColor[UnitReaction(unitstr, "player")]
      if color then r, g, b = color.r, color.g, color.b end
    end

  elseif preset == "class" and config["classcolor"] == "1" then
    local _, class = UnitClass(unitstr)
    if RAID_CLASS_COLORS[class] then
      r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
    end

  elseif preset == "reaction" and config["classcolor"] == "1" then
    r = UnitReactionColor[UnitReaction(unitstr, "player")].r
    g = UnitReactionColor[UnitReaction(unitstr, "player")].g
    b = UnitReactionColor[UnitReaction(unitstr, "player")].b

  elseif preset == "health" and config["healthcolor"] == "1" then
    local perc = UnitHealth(unitstr) / UnitHealthMax(unitstr)
    local r1, g1, b1, r2, g2, b2
    if perc <= 0.5 then
      perc = perc * 2
      r1, g1, b1 = 1, 0, 0
      r2, g2, b2 = 1, 1, 0
    else
      perc = perc * 2 - 1
      r1, g1, b1 = 1, 1, 0
      r2, g2, b2 = 0, 1, 0
    end
    r = r1 + (r2 - r1)*perc
    g = g1 + (g2 - g1)*perc
    b = b1 + (b2 - b1)*perc

  elseif preset == "power" and config["powercolor"] == "1" then
    r = ManaBarColor[UnitPowerType(unitstr)].r
    g = ManaBarColor[UnitPowerType(unitstr)].g
    b = ManaBarColor[UnitPowerType(unitstr)].b

  elseif preset == "level" and config["levelcolor"] == "1" then
    r = GetDifficultyColor(UnitLevel(unitstr)).r
    g = GetDifficultyColor(UnitLevel(unitstr)).g
    b = GetDifficultyColor(UnitLevel(unitstr)).b
  end

  -- pastel
  r = ( r + .75 ) * .5
  g = ( g + .75 ) * .5
  b = ( b + .75 ) * .5

  return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255)
end
