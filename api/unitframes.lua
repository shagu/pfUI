pfUI.uf = CreateFrame("Frame",nil,UIParent)

local uf_defaults = {
  portrait = "bar",
  width = "200",
  height = "50",
  pheight = "10",
  pspace = "-3",
  buffs = "top",
  buffsize = "20",
  debuffs = "top",
  debuffsize = "20",
}

function pfUI.uf:CreateUnitFrame(unit, id, config, tick)
  local fname
  if unit == "Party" then
    fname = "Group" .. (id or "")
  else
    fname = (unit or "") .. (id or "")
  end

  local unit = strlower(unit or "")
  local id = strlower(id or "")
  local C = pfUI_config
  local spacing = pfUI_config.unitframes.player.pspace
  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  local f = CreateFrame("Button", "pf" .. fname, UIParent)

  f.UpdateFrameSize = pfUI.uf.UpdateFrameSize
  f.GetColor = pfUI.uf.GetColor

  f.label = unit
  f.id = id
  f.config = config or uf_defaults
  f.tick = tick

  f.hp = CreateFrame("Frame",nil, f)
  f.hp:SetPoint("TOP", 0, 0)
  f.hp:SetWidth(f.config.width)
  f.hp:SetHeight(f.config.height)
  pfUI.api.CreateBackdrop(f.hp, default_border)

  f.hp.bar = CreateFrame("StatusBar", nil, f.hp)
  f.hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  f.hp.bar:SetAllPoints(f.hp)
  f.hp.bar:SetMinMaxValues(0, 100)

  if pfUI_config.unitframes.custombg == "1" then
    local cr, cg, cb, ca = strsplit(",", pfUI_config.unitframes.custombgcolor)
    cr, cg, cb = tonumber(cr), tonumber(cg), tonumber(cb)
    f.hp.bar.texture = f.hp.bar:CreateTexture(nil,"BACKGROUND")
    f.hp.bar.texture:SetTexture(cr,cg,cb,ca)
    f.hp.bar.texture:SetAllPoints(f.hp.bar)
  end

  f.power = CreateFrame("Frame",nil, f)
  f.power:SetPoint("BOTTOM", 0, 0)
  f.power:SetWidth(f.config.width)
  f.power:SetHeight(f.config.pheight)
  pfUI.api.CreateBackdrop(f.power, default_border)

  f.power.bar = CreateFrame("StatusBar", nil, f.power)
  f.power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  f.power.bar:SetAllPoints(f.power)
  f.power.bar:SetMinMaxValues(0, 100)

  f.rightText = f:CreateFontString("Status", "OVERLAY", "GameFontNormal")
  f.rightText:SetFont(pfUI.font_square, C.global.font_size, "OUTLINE")
  f.rightText:ClearAllPoints()
  f.rightText:SetJustifyH("RIGHT")
  f.rightText:SetFontObject(GameFontWhite)
  f.rightText:SetParent(f.hp.bar)
  f.rightText:SetPoint("RIGHT",f.hp.bar, "RIGHT", -10, 0)

  f.leftText = f:CreateFontString("Status", "OVERLAY", "GameFontNormal")
  f.leftText:SetFont(pfUI.font_square, C.global.font_size, "OUTLINE")
  f.leftText:ClearAllPoints()
  f.leftText:SetJustifyH("LEFT")
  f.leftText:SetFontObject(GameFontWhite)
  f.leftText:SetParent(f.hp.bar)
  f.leftText:SetPoint("LEFT",f.hp.bar, "LEFT", 10, 0)

  f.centerText = f:CreateFontString("Status", "OVERLAY", "GameFontNormal")
  f.centerText:SetFont(pfUI.font_square, C.global.font_size, "OUTLINE")
  f.centerText:ClearAllPoints()
  f.centerText:SetJustifyH("CENTER")
  f.centerText:SetFontObject(GameFontWhite)
  f.centerText:SetParent(f.hp.bar)
  f.centerText:SetAllPoints(f.hp.bar)

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
      elseif this.label == "raid" and event == "RAID_ROSTER_UPDATE" then
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
      if this.tick and not this.lastTick then this.lastTick = GetTime() + this.tick end
      if this.lastTick and this.lastTick < GetTime() then
        this.lastTick = GetTime() + this.tick
        pfUI.uf:RefreshUnit(this, "all")
      end

      if CheckInteractDistance(this.label .. this.id, 4) or not UnitName(this.label .. this.id) then
        if this:GetAlpha() ~= 1 then
          this:SetAlpha(1)
          if this.config.portrait == "bar" then
            this.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)
          end
        end
      else
        if this:GetAlpha() ~= .5 then
          this:SetAlpha(.5)
          if this.config.portrait == "bar" then
            this.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)
          end
        end
      end

      if UnitIsConnected(this.label .. this.id) then
        if not this.cache then return end

        local hpDisplay = this.hp.bar:GetValue()
        local hpReal = this.cache.hp
        local hpDiff = abs(hpReal - hpDisplay)

        if pfUI_config.unitframes.raid.invert_healthbar == "1" then
          hpDisplay = this.hp.bar:GetValue()
          hpReal = this.cache.hpmax - this.cache.hp
          hpDiff = abs(hpReal - hpDisplay)
        end

        if hpDisplay < hpReal then
          this.hp.bar:SetValue(hpDisplay + ceil(hpDiff / pfUI_config.unitframes.animation_speed))
        elseif hpDisplay > hpReal then
          this.hp.bar:SetValue(hpDisplay - ceil(hpDiff / pfUI_config.unitframes.animation_speed))
        else
          this.hp.bar:SetValue(hpReal)
        end

        local powerDisplay = this.power.bar:GetValue()
        local powerReal = this.cache.power
        local powerDiff = abs(powerReal - powerDisplay)

        if powerDisplay < powerReal then
          this.power.bar:SetValue(powerDisplay + ceil(powerDiff / pfUI_config.unitframes.animation_speed))
        elseif powerDisplay > powerReal then
          this.power.bar:SetValue(powerDisplay - ceil(powerDiff / pfUI_config.unitframes.animation_speed))
        else
          this.power.bar:SetValue(this.cache.power)
        end
      else
        this.hp.bar:SetMinMaxValues(0, 100)
        this.power.bar:SetMinMaxValues(0, 100)
        this.hp.bar:SetValue(0)
        this.power.bar:SetValue(0)
      end
    end)
  f:SetScript("OnEnter", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, this)
        GameTooltip:SetUnit(this.label .. this.id)
        GameTooltip:Show()
      end)
  f:SetScript("OnLeave", function()
        GameTooltip:FadeOut()
      end)
  f:SetScript("OnClick", function ()
        pfUI.uf:ClickAction(arg1)
      end)

  f.leaderIcon = CreateFrame("Frame", nil, f.hp.bar)
  f.leaderIcon:SetWidth(10)
  f.leaderIcon:SetHeight(10)
  f.leaderIcon:SetPoint("CENTER", f, "TOPLEFT", 0, 0)
  f.leaderIcon.texture = f.leaderIcon:CreateTexture(nil,"BACKGROUND")
  f.leaderIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-LeaderIcon")
  f.leaderIcon.texture:SetAllPoints(f.leaderIcon)

  f.lootIcon = CreateFrame("Frame",nil, f.hp.bar)
  f.lootIcon:SetWidth(10)
  f.lootIcon:SetHeight(10)
  f.lootIcon:SetPoint("CENTER", f, "LEFT", 0, 0)
  f.lootIcon.texture = f.lootIcon:CreateTexture(nil,"BACKGROUND")
  f.lootIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-MasterLooter")
  f.lootIcon.texture:SetAllPoints(f.lootIcon)

  f.raidIcon = CreateFrame("Frame", nil, f.hp.bar)
  f.raidIcon:SetWidth(24)
  f.raidIcon:SetHeight(24)
  f.raidIcon:SetPoint("TOP", f, "TOP", 0, 6)
  f.raidIcon.texture = f.raidIcon:CreateTexture(nil,"ARTWORK")
  f.raidIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")
  f.raidIcon.texture:SetAllPoints(f.raidIcon)


  if f.config.buffs ~= "off" then
    f.buffs = {}

    for i=1, 16 do
      local id = i
      local row = 0
      if i <= 8 then row = 0 else row = 1 end

      f.buffs[i] = CreateFrame("Button", "pfUIPlayerBuff" .. i, f)
      f.buffs[i]:SetID(i)

      f.buffs[i].stacks = f.buffs[i]:CreateFontString(nil, "OVERLAY", f.buffs[i])
      f.buffs[i].stacks:SetFont(pfUI.font_square, C.global.font_size, "OUTLINE")
      f.buffs[i].stacks:SetPoint("BOTTOMRIGHT", f.buffs[i], 2, -2)
      f.buffs[i].stacks:SetJustifyH("LEFT")
      f.buffs[i].stacks:SetShadowColor(0, 0, 0)
      f.buffs[i].stacks:SetShadowOffset(0.8, -0.8)
      f.buffs[i].stacks:SetTextColor(1,1,.5)
      f.buffs[i].cd = f.buffs[i]:CreateFontString(nil, "OVERLAY", f.buffs[i])
      f.buffs[i].cd:SetFont(pfUI.font_square, C.global.font_size, "OUTLINE")
      f.buffs[i].cd:SetPoint("CENTER", f.buffs[i], 0, 0)
      f.buffs[i].cd:SetJustifyH("LEFT")
      f.buffs[i].cd:SetShadowColor(0, 0, 0)
      f.buffs[i].cd:SetShadowOffset(0.8, -0.8)
      f.buffs[i].cd:SetTextColor(1,1,1)

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
      (i-1-8*row)*((2*default_border) + C.unitframes.buff_size + 1),
      invert * (row)*((2*default_border) + C.unitframes.buff_size + 1) + invert*(2*default_border + 1))

      f.buffs[i]:SetWidth(C.unitframes.buff_size)
      f.buffs[i]:SetHeight(C.unitframes.buff_size)

      f.buffs[i]:SetScript("OnEnter", function()
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

      if f.label == "player" then
        f.buffs[i]:SetScript("OnUpdate", function()
          local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(this:GetID()-1,"HELPFUL"))
          if timeleft ~= nil and timeleft ~= 0 then
            -- if there are more than 0 seconds left
            if timeleft < 60 then
              -- show seconds if less than 60 seconds
              this.cd:SetText(ceil(timeleft))
            elseif timeleft < 3600 then
              -- show minutes if less than 3600 seconds (1 hour)
              this.cd:SetText(ceil(timeleft/60) .. 'm')
            else
              -- otherwise show hours
              this.cd:SetText(ceil(timeleft/3600) .. 'h')
            end
          else
            -- if there's no time left or not set, empty buff text
            this.cd:SetText("")
          end
        end)
      end
    end
  end

  if f.config.debuffs ~= "off" then
    f.debuffs = {}

    for i=1, 16 do
      local id = i
      f.debuffs[i] = CreateFrame("Button", "pfUIPlayerDebuff" .. i, f)
      f.debuffs[i]:SetID(i)
      f.debuffs[i].stacks = f.debuffs[i]:CreateFontString(nil, "OVERLAY", f.debuffs[i])
      f.debuffs[i].stacks:SetFont(pfUI.font_square, C.global.font_size, "OUTLINE")
      f.debuffs[i].stacks:SetPoint("BOTTOMRIGHT", f.debuffs[i], 2, -2)
      f.debuffs[i].stacks:SetJustifyH("LEFT")
      f.debuffs[i].stacks:SetShadowColor(0, 0, 0)
      f.debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
      f.debuffs[i].stacks:SetTextColor(1,1,.5)
      f.debuffs[i].cd = f.debuffs[i]:CreateFontString(nil, "OVERLAY", f.debuffs[i])
      f.debuffs[i].cd:SetFont(pfUI.font_square, C.global.font_size, "OUTLINE")
      f.debuffs[i].cd:SetPoint("CENTER", f.debuffs[i], 0, 0)
      f.debuffs[i].cd:SetJustifyH("LEFT")
      f.debuffs[i].cd:SetShadowColor(0, 0, 0)
      f.debuffs[i].cd:SetShadowOffset(0.8, -0.8)
      f.debuffs[i].cd:SetTextColor(1,1,1)

      f.debuffs[i]:RegisterForClicks("RightButtonUp")
      f.debuffs[i]:ClearAllPoints()
      f.debuffs[i]:SetWidth(C.unitframes.debuff_size)
      f.debuffs[i]:SetHeight(C.unitframes.debuff_size)
      f.debuffs[i]:SetNormalTexture(nil)
      f.debuffs[i]:SetScript("OnEnter", function()
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

      if f.label == "player" then
        f.debuffs[i]:SetScript("OnUpdate", function()
          local bid = GetPlayerBuff(this:GetID() - 1, "HARMFUL");
          local timeleft = GetPlayerBuffTimeLeft(bid,"HARMFUL")

          if timeleft ~= nil and timeleft ~= 0 then
            -- if there are more than 0 seconds left
            if timeleft < 60 then
              -- show seconds if less than 60 seconds
              f.debuffs[this:GetID()].cd:SetText(ceil(timeleft))
            elseif timeleft < 3600 then
              -- show minutes if less than 3600 seconds (1 hour)
              f.debuffs[this:GetID()].cd:SetText(ceil(timeleft/60)..'m')
            else
              -- otherwise show hours
              f.debuffs[this:GetID()].cd:SetText(ceil(timeleft/3600) .. 'h')
            end
          else
            -- if there's no time left or not set, empty buff text
            f.debuffs[this:GetID()].cd:SetText("")
          end
        end)
      end
    end
  end

  if f.config.portrait ~= "off" then
    f.portrait = CreateFrame("Frame", "pfPortrait" .. f.label .. f.id, f)
    f.portrait:SetFrameStrata("LOW")
    f.portrait.tex = f.portrait:CreateTexture("pfPortraitTexture" .. f.label .. f.id, "OVERLAY")
    f.portrait.tex:SetAllPoints(f.portrait)
    f.portrait.tex:SetTexCoord(.1, .9, .1, .9)

    f.portrait.model = CreateFrame("PlayerModel", "pfPortraitModel" .. f.label .. f.id, f.portrait)
    f.portrait.model:SetFrameStrata("LOW")
    f.portrait.model:SetAllPoints(f.portrait)
    f.portrait.model.next = CreateFrame("PlayerModel", nil, nil)

    if f.config.portrait == "bar" then
      f.portrait:SetParent(f.hp.bar)
      f.portrait:SetAllPoints(f.hp.bar)
      f.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)

    elseif f.config.portrait == "left" then
      f.portrait:SetPoint("LEFT", f, "LEFT", 0, 0)
      f.hp:ClearAllPoints()
      f.hp:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
      f.power:ClearAllPoints()
      f.power:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
      pfUI.api.CreateBackdrop(f.portrait)

    elseif f.config.portrait == "right" then
      f.portrait:SetPoint("RIGHT", f, "RIGHT", 0, 0)
      f.hp:ClearAllPoints()
      f.hp:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
      f.power:ClearAllPoints()
      f.power:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
      pfUI.api.CreateBackdrop(f.portrait)
    end
  end

  return f
end

function pfUI.uf:RefreshUnit(unit, component)
  local component = component or ""
  -- break early on misconfigured UF's
  if not this.label then return end

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.groupframes ~= "-1" then
    default_border = pfUI_config.appearance.border.groupframes
  end

  local C = pfUI_config

  if UnitName(this.label .. this.id) or (pfUI.gitter and pfUI.gitter:IsShown()) then
    this:Show() else this:Hide()
  end

  if not this.cache then unit.cache = {} end
  if not unit.id then unit.id = "" end

  -- Raid Icon
  if this.raidIcon and ( component == "all" or component == "raidIcon" ) then
    local raidIcon = GetRaidTargetIndex(this.label .. this.id)
    if raidIcon and UnitName(this.label .. this.id) then
      SetRaidTargetIconTexture(this.raidIcon.texture, raidIcon)
      this.raidIcon:Show()
    else
      this.raidIcon:Hide()
    end
  end

  -- Leader Icon
  if this.leaderIcon and ( component == "all" or component == "leaderIcon" ) then
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
      this.leaderIcon:Hide()
    elseif UnitIsPartyLeader(this.label .. this.id) then
      this.leaderIcon:Show()
    else
      this.leaderIcon:Hide()
    end
  end

  -- Loot Icon
  if this.lootIcon and ( component == "all" or component == "lootIcon" ) then
    local _, lootmaster = GetLootMethod()
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
      this.lootIcon:Hide()
    elseif lootmaster and (
        ( this.label == "party" and tonumber(this.id) == lootmaster ) or
        ( this.label == "player" and lootmaster == 0 ) )then
      this.lootIcon:Show()
    else
      this.lootIcon:Hide()
    end
  end

  -- Buffs
  if this.buffs and ( component == "all" or component == "aura" ) then
    for i=1, 16 do
      local texture, stacks
      if this.label == "player" then
       stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HELPFUL"))
       texture = GetPlayerBuffTexture(GetPlayerBuff(i-1,"HELPFUL"))
      else
       texture, stacks = UnitBuff(this.label .. this.id ,i)
      end

      pfUI.api.CreateBackdrop(this.buffs[i], default_border)
      this.buffs[i]:SetNormalTexture(texture)
      for i,v in ipairs({this.buffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

      if texture then
        this.buffs[i]:Show()
        if stacks > 1 then
          this.buffs[i].stacks:SetText(stacks)
        else
          this.buffs[i].stacks:SetText("")
        end
      else
        this.buffs[i]:Hide()
      end
    end
  end

  -- Debuffs
  if this.debuffs and ( component == "all" or component == "aura" ) then
    for i=1, 16 do
      local row = 0
      local top = 0
      if i > 8 then row = 1 end

      if this.config.buffs == this.config.debuffs then
        if this.buffs[1]:IsShown() then top = top + 1 end
        if this.buffs[9]:IsShown() then top = top + 1 end
      end

      local invert, af, as
      if this.config.debuffs == "top" then
        invert = 1
        af = "BOTTOMLEFT"
        as = "TOPLEFT"
      elseif this.config.debuffs == "bottom" then
        invert = -1
        af = "TOPLEFT"
        as = "BOTTOMLEFT"
      end

      this.debuffs[i]:SetPoint(af, this, as,
      (i-1-8*row)*((2*default_border) + C.unitframes.debuff_size + 1),
      invert * (top)*((2*default_border) + C.unitframes.buff_size + 1) +
      invert * (row)*((2*default_border) + C.unitframes.debuff_size + 1) + invert*(2*default_border + 1))

      local texture, stacks, dtype
      if this.label == "player" then
        texture = GetPlayerBuffTexture(GetPlayerBuff(i-1, "HARMFUL"))
        stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1, "HARMFUL"))
        dtype = GetPlayerBuffDispelType(GetPlayerBuff(i-1, "HARMFUL"))
     else
       texture, stacks, dtype = UnitDebuff(this.label .. this.id ,i)
     end

      pfUI.api.CreateBackdrop(this.debuffs[i], default_border)
      this.debuffs[i]:SetNormalTexture(texture)
      for i,v in ipairs({this.debuffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

      if dtype == "Magic" then
        this.debuffs[i].backdrop:SetBackdropBorderColor(0,1,1,1)
      elseif dtype == "Poison" then
        this.debuffs[i].backdrop:SetBackdropBorderColor(0,1,0,1)
      elseif dtype == "Curse" then
        this.debuffs[i].backdrop:SetBackdropBorderColor(1,0,1,1)
      elseif dtype == "Disease" then
        this.debuffs[i].backdrop:SetBackdropBorderColor(1,1,0,1)
      else
        this.debuffs[i].backdrop:SetBackdropBorderColor(1,0,0,1)
      end

      if texture then
        this.debuffs[i]:Show()
        if stacks > 1 then
          this.debuffs[i].stacks:SetText(stacks)
        else
          this.debuffs[i].stacks:SetText("")
        end
      else
        this.debuffs[i]:Hide()
      end
    end
  end

  -- portrait
  if this.portrait and ( component == "all" or component == "portrait" ) then
    if not UnitIsVisible(this.label .. this.id) or not UnitIsConnected(this.label .. this.id) then
      if this.config.portrait == "bar" then
        this.portrait.tex:Hide()
        this.portrait.model:Hide()
      elseif pfUI_config.unitframes.portraittexture == "1" then
        this.portrait.tex:Show()
        this.portrait.model:Hide()
        SetPortraitTexture(this.portrait.tex, this.label .. this.id)
      else
        this.portrait.tex:Hide()
        this.portrait.model:Show()
        this.portrait.model:SetModelScale(4.25)
        this.portrait.model:SetPosition(0, 0, -1)
        this.portrait.model:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
      end
    else
      if this.config.portrait == "bar" then
        this.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)
      end
      this.portrait.tex:Hide()
      this.portrait.model:Show()

      if this.tick then
        this.portrait.model.next:SetUnit(this.label .. this.id)
        if this.portrait.model.lastUnit ~= UnitName(this.label .. this.id) or this.portrait.model:GetModel() ~= this.portrait.model.next:GetModel() then
          this.portrait.model:SetUnit(this.label .. this.id)
          this.portrait.model.lastUnit = UnitName(this.label .. this.id)
          this.portrait.model:SetCamera(0)
        end
      else
        this.portrait.model:SetUnit(this.label .. this.id)
        this.portrait.model:SetCamera(0)
      end

    end
  end

  -- Unit HP/MP
  unit.cache.hp = UnitHealth(unit.label..unit.id)
  unit.cache.hpmax = UnitHealthMax(unit.label..unit.id)
  unit.cache.power = UnitMana(unit.label .. unit.id)
  unit.cache.powermax = UnitManaMax(unit.label .. unit.id)

  if this.label == "target" and MobHealth3 then
    unit.cache.hp, unit.cache.hpmax = MobHealth3:GetUnitHealth(this.label)
  end

  unit.hp.bar:SetMinMaxValues(0, unit.cache.hpmax)
  unit.power.bar:SetMinMaxValues(0, unit.cache.powermax)

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
    cr, cg, cb = tonumber(cr), tonumber(cg), tonumber(cb)
    unit.hp.bar:SetStatusBarColor(cr, cg, cb)
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
    unit.leftText:SetText(pfUI.uf:GetStatusValue(unit, "left"))
    unit.centerText:SetText(pfUI.uf:GetStatusValue(unit, "center"))
    unit.rightText:SetText(pfUI.uf:GetStatusValue(unit, "right"))

    if UnitIsTapped(unit.label .. unit.id) and not UnitIsTappedByPlayer(unit.label .. unit.id) then
      unit.hp.bar:SetStatusBarColor(.5,.5,.5,.5)
    end
  end

  pfUI.uf:SetupDebuffFilter()
  if table.getn(pfUI.uf.debuffs) > 0 and
    ((pfUI_config.unitframes.group.raid_debuffs == "1" and this.label == "party") or
    this.label == "raid")
  then
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
  if table.getn(pfUI.uf.buffs) > 0 and
    ((pfUI_config.unitframes.group.raid_buffs == "1" and this.label == "party") or
    this.label == "raid")
  then
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

        -- add icons for every found buff
        for pos, icon in pairs(active) do
          pfUI.uf:AddIcon(this, pos, icon)
        end
      end
    end

    -- hide unued icon slots
    for pos=table.getn(active)+1, 6 do
      pfUI.uf:HideIcon(this, pos)
    end
  end
end

function pfUI.uf.UpdateFrameSize(self)
  local unit = self.label .. self.id
  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.groupframes ~= "-1" then
    default_border = pfUI_config.appearance.border.groupframes
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
      ToggleDropDownMenu(1, nil, pfUI.uf.player.Dropdown,"cursor")
      if UnitIsPartyLeader("player") then
        UIDropDownMenu_AddButton({text = "Reset Instances", func = ResetInstances, notCheckable = 1}, 1)
      end
    elseif label == "target" then
      ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
    elseif label == "pet" then
      ToggleDropDownMenu(1, nil, PetFrameDropDown, "cursor")
    elseif label == "party" then
      ToggleDropDownMenu(1, nil, getglobal("PartyMemberFrame" .. this.id .. "DropDown"), "cursor")
    elseif label == "raid" then
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

    -- break here if party frame and no clickcast is activated
    if label == "party" and pfUI_config.unitframes.group.clickcast == "0" and pfUI_config.unitframes.globalclick == "0" then
      return
    end

    -- break here for non-party and non-raid frames without clickcast
    if label ~= "raid" and label ~= "party" and pfUI_config.unitframes.globalclick == "0" then
      return
    end

    -- clickcast: shift modifier
    if IsShiftKeyDown() then
      if pfUI_config.unitframes.raid.clickcast_shift ~= "" then
        CastSpellByName(pfUI_config.unitframes.raid.clickcast_shift)
        pfUI.uf.target.noanim = "yes"
        if not tswitch then TargetLastTarget() end
        return
      end

    -- clickcast: alt modifier
    elseif IsAltKeyDown() then
      if pfUI_config.unitframes.raid.clickcast_alt ~= "" then
        CastSpellByName(pfUI_config.unitframes.raid.clickcast_alt)
        pfUI.uf.target.noanim = "yes"
        if not tswitch then TargetLastTarget() end
        return
      end

    -- clickcast: ctrl modifier
    elseif IsControlKeyDown() then
      if pfUI_config.unitframes.raid.clickcast_ctrl ~= "" then
        CastSpellByName(pfUI_config.unitframes.raid.clickcast_ctrl)
        pfUI.uf.target.noanim = "yes"
        if not tswitch then TargetLastTarget() end
        return
      end

    -- clickcast: default
    else
      if pfUI_config.unitframes.raid.clickcast ~= "" then
        CastSpellByName(pfUI_config.unitframes.raid.clickcast)
        pfUI.uf.target.noanim = "yes"
        if not tswitch then TargetLastTarget() end
        return
      end
    end
  end
end

function pfUI.uf:AddIcon(frame, pos, icon)
  local iconsize = 10
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
  if pfUI_config.unitframes.raid.debuffs_enable == "1" then
    if myclass == "PALADIN" or myclass == "PRIEST" or myclass == "WARLOCK" or pfUI_config.unitframes.raid.debuffs_class ~= "1" then
      table.insert(pfUI.uf.debuffs, "magic")
    end

    if myclass == "DRUID" or myclass == "PALADIN" or myclass == "SHAMAN" or pfUI_config.unitframes.raid.debuffs_class ~= "1" then
      table.insert(pfUI.uf.debuffs, "poison")
    end

    if myclass == "PRIEST" or myclass == "PALADIN" or myclass == "SHAMAN" or pfUI_config.unitframes.raid.debuffs_class ~= "1" then
      table.insert(pfUI.uf.debuffs, "disease")
    end

    if myclass == "DRUID" or myclass == "MAGE" or pfUI_config.unitframes.raid.debuffs_class ~= "1" then
      table.insert(pfUI.uf.debuffs, "curse")
    end
  end
end

function pfUI.uf:SetupBuffFilter()
  if pfUI.uf.buffs then return end

  local _, myclass = UnitClass("player")

  pfUI.uf.buffs = {}

  -- [[ DRUID ]]
  if myclass == "DRUID" and pfUI_config.unitframes.raid.buffs_buffs == "1" then
    -- Gift of the Wild
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_regeneration")

    -- Thorns
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_thorns")
  end

  if (pfUI_config.unitframes.raid.buffs_classonly ~= "1" or myclass == "DRUID") and pfUI_config.unitframes.raid.buffs_hots == "1" then
    -- Regrowth
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_resistnature")

    -- Rejuvenation
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_rejuvenation")
  end


  -- [[ PRIEST ]]
  if myclass == "PRIEST" and pfUI_config.unitframes.raid.buffs_buffs == "1" then
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

  if (pfUI_config.unitframes.raid.buffs_classonly ~= "1" or myclass == "PRIEST") and pfUI_config.unitframes.raid.buffs_hots == "1" then
    -- Renew
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_renew")
  end

  if (pfUI_config.unitframes.raid.buffs_classonly ~= "1" or myclass == "PRIEST") and pfUI_config.unitframes.raid.buffs_procs == "1" then
    -- Inspiration
    table.insert(pfUI.uf.buffs, "interface\\icons\\inv_shield_06")
  end


  -- [[ PALADIN ]]
  if myclass == "PALADIN" and pfUI_config.unitframes.raid.buffs_buffs == "1" then
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


  -- [[ SHAMAN ]]
  if (pfUI_config.unitframes.raid.buffs_classonly ~= "1" or myclass == "SHAMAN") and pfUI_config.unitframes.raid.buffs_procs == "1" then
    -- Ancestral Fortitude
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_undyingstrength")

    -- Healing Way
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_healingway")
  end


  -- [[ WARRIOR ]]
  if myclass == "WARRIOR" and pfUI_config.unitframes.raid.buffs_buffs == "1" then
    -- Battle Shout
    table.insert(pfUI.uf.buffs, "interface\\icons\\ability_warrior_battleshout")
  end


  -- [[ MAGE ]]
  if myclass == "MAGE" and pfUI_config.unitframes.raid.buffs_buffs == "1" then
    -- Arcane Intellect
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_magicalsentry")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_arcaneintellect")

    -- Dampen Magic
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_abolishmagic")

    -- Amplify Magic
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_flashheal")
  end
end

function pfUI.uf:GetStatusValue(unit, pos)
  if not pos or not unit then return end
  local config = unit.config["txt"..pos]
  local unitstr = unit.label .. unit.id
  local frame = unit[pos .. "Text"]

  -- as a fallback, draw the name
  if pos == "center" and not config then
    frame:SetTextColor(pfUI.uf:GetColorUnit(unitstr))
    return UnitName(unitstr)
  end

  if config == "unit" then
    local level = UnitLevel(unitstr)
    if level == -1 then level = "??" end

    local name = UnitName(unitstr)

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
    level = this:GetColor("level") .. level
    name = this:GetColor("unit") .. name

    return level .. " " .. name

  elseif config == "name" then
    return this:GetColor("unit") .. UnitName(unitstr)
  elseif config == "level" then
    return this:GetColor("level") .. UnitLevel(unitstr)
  elseif config == "class" then
    return this:GetColor("class") .. UnitClass(unitstr)

  -- health
  elseif config == "health" then
    return this:GetColor("health") .. UnitHealth(unitstr)
  elseif config == "healthmax" then
    return this:GetColor("health") .. UnitHealthMax(unitstr)
  elseif config == "healthperc" then
    return this:GetColor("health") .. ceil(UnitHealth(unitstr) / UnitHealthMax(unitstr) * 100)
  elseif config == "healthmiss" then
    return this:GetColor("health") .. ceil(UnitHealth(unitstr) - UnitHealthMax(unitstr))
  elseif config == "healthdyn" then
    if UnitHealth(unitstr) ~= UnitHealthMax(unitstr) then
      return this:GetColor("health") .. UnitHealth(unitstr) .. " - " .. ceil(UnitHealth(unitstr) / UnitHealthMax(unitstr) * 100) .. "%"
    else
      return this:GetColor("health") .. UnitHealth(unitstr)
    end

  -- mana/power/focus
  elseif config == "power" then
    return this:GetColor("power") .. UnitMana(unitstr)
  elseif config == "powermax" then
    return this:GetColor("power") .. UnitManaMax(unitstr)
  elseif config == "powerperc" then
    return this:GetColor("power") .. ceil(UnitMana(unitstr) / UnitManaMax(unitstr) * 100)
  elseif config == "powermiss" then
    return this:GetColor("power") .. ceil(UnitMana(unitstr) - UnitManaMax(unitstr))
  elseif config == "powerdyn" then
    if UnitMana(unitstr) ~= UnitManaMax(unitstr) then
      return this:GetColor("power") .. UnitMana(unitstr) .. " - " .. ceil(UnitMana(unitstr) / UnitManaMax(unitstr) * 100) .. "%"
    else
      return this:GetColor("power") .. UnitMana(unitstr)
    end
  else
    return ""
  end
end

function pfUI.uf.GetColor(self, preset)
  local unitstr = self.label .. self.id
  local r, g, b = 1, 1, 1
  if preset == "unit" then
    if UnitIsPlayer(unitstr) then
      local _, class = UnitClass(unitstr)
      r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
    else
      r, g, b = UnitReactionColor[UnitReaction(unitstr, "player")].r, UnitReactionColor[UnitReaction(unitstr, "player")].g, UnitReactionColor[UnitReaction(unitstr, "player")].b
    end

  elseif preset == "class" then
    local _, class = UnitClass(unitstr)
    r = RAID_CLASS_COLORS[class].r
    g = RAID_CLASS_COLORS[class].g
    b = RAID_CLASS_COLORS[class].b

  elseif preset == "reaction" then
    r = UnitReactionColor[UnitReaction(unitstr, "player")].r
    g = UnitReactionColor[UnitReaction(unitstr, "player")].g
    b = UnitReactionColor[UnitReaction(unitstr, "player")].b

  elseif preset == "health" then
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

  elseif preset == "power" then
    r = ManaBarColor[UnitPowerType(unitstr)].r
    g = ManaBarColor[UnitPowerType(unitstr)].g
    b = ManaBarColor[UnitPowerType(unitstr)].b

  elseif preset == "level" then
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
