pfUI.uf = CreateFrame("Frame",nil,UIParent)

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

function pfUI.uf:RefreshUnit(unit)
  if not unit.cache then unit.cache = {} end
  if not unit.id then unit.id = "" end

  unit.cache.hp = UnitHealth(unit.label..unit.id)
  unit.cache.hpmax = UnitHealthMax(unit.label..unit.id)
  unit.cache.power = UnitMana(unit.label .. unit.id)
  unit.cache.powermax = UnitManaMax(unit.label .. unit.id)

  if this.label == "target" and MobHealth3 then
    unit.cache.hp, unit.cache.hpmax = MobHealth3:GetUnitHealth(this.label)
  end

  unit.hp.bar:SetMinMaxValues(0, unit.cache.hpmax)
  unit.power.bar:SetMinMaxValues(0, unit.cache.powermax)

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

  _, class = UnitClass(unit.label..unit.id)
  local color = RAID_CLASS_COLORS[class]

  local r, g, b = .2, .2, .2
  if pfUI_config.unitframes.custom == "1" and color then
    local cr, cg, cb, ca = pfUI.api.strsplit(",", pfUI_config.unitframes.customcolor)
    cr, cg, cb = tonumber(cr), tonumber(cg), tonumber(cb)
    unit.hp.bar:SetStatusBarColor(cr, cg, cb)
    if pfUI_config.unitframes.pastel == "1" then
      r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5
    else
      r, g, b = color.r, color.g, color.b
    end
  elseif color then
    if pfUI_config.unitframes.pastel == "1" then
      r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5
    else
      r, g, b = color.r, color.g, color.b
    end
    unit.hp.bar:SetStatusBarColor(r, g, b)
  end
  unit.caption:SetTextColor(r,g,b)

  local p = ManaBarColor[UnitPowerType(unit.label..unit.id)]
  local pr, pg, pb = 0, 0, 0
  if p then pr, pg, pb = p.r + .5, p.g +.5, p.b +.5 end
  unit.power.bar:SetStatusBarColor(pr, pg, pb)

  if UnitName(unit.label..unit.id) then
    if this.label == "raid" and unit.cache.hpmax ~= unit.cache.hp and pfUI_config.unitframes.raid.show_missing == "1" then
      unit.caption:SetText("-" .. unit.cache.hpmax - unit.cache.hp)
      unit.caption:SetTextColor(1,.3,.3)
    else
      unit.caption:SetText(UnitName(unit.label..unit.id))
      if pfUI_config.unitframes.custom ~= "1" then
        unit.caption:SetTextColor(1,1,1)
      end
    end
    unit.caption:SetAllPoints(unit.hp.bar)
  end
end

function pfUI.uf:CreatePortrait(frame, pos, spacing)
  if not frame then return end
  if pos == "off" then return end

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  local unit = frame.label
  local id = frame.id or ""
  local unitstr = unit .. id

  frame.portrait = CreateFrame("Frame", "pfPortrait" .. unitstr, frame)
  frame.portrait:RegisterEvent("UNIT_PORTRAIT_UPDATE")
  frame.portrait:RegisterEvent("UNIT_MODEL_CHANGED")
  frame.portrait:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame.portrait:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame.portrait:RegisterEvent("PARTY_MEMBERS_CHANGED")

  frame.portrait.base = frame
  frame.portrait.pos = pos

  frame.portrait.tex = frame.portrait:CreateTexture("pfPortraitTexture" .. unitstr, "OVERLAY")
  frame.portrait.tex:SetAllPoints(frame.portrait)
  frame.portrait.tex:SetTexCoord(.1, .9, .1, .9)

  frame.portrait.model = CreateFrame("PlayerModel", "pfPortraitModel" .. unitstr, frame.portrait)
  frame.portrait.model:SetFrameStrata("LOW")
  frame.portrait.model:SetAllPoints(frame.portrait)

  frame.portrait:SetScript("OnEvent", function()
    local unit = this.base.label
    local id = this.base.id or ""
    local unitstr = unit .. id

    if event == "PLAYER_ENTERING_WORLD" or
      ( event == "PARTY_MEMBERS_CHANGED" and this.base.label and this.base.label == "party" ) or
      ( unitstr == "target" and event == "PLAYER_TARGET_CHANGED" ) or
      ( unitstr == "targettarget" and event == "PLAYER_TARGET_CHANGED" ) or
      ( arg1 and arg1 == unitstr ) then
      pfUI.uf:UpdatePortrait()
    end
  end)

  frame.portrait:SetScript("OnShow", function()
    pfUI.uf:UpdatePortrait()
  end)

  if pos == "bar" then
    frame.portrait:SetParent(frame.hp.bar)
    frame.portrait:SetAllPoints(frame.hp.bar)
    frame.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)
  elseif pos == "left" then
    frame.portrait:SetWidth(frame:GetHeight())
    frame.portrait:SetHeight(frame:GetHeight())
    frame:SetWidth(frame:GetWidth() + default_border*2 + spacing + frame.portrait:GetWidth())
    frame.portrait:SetPoint("LEFT", frame, "LEFT", 0, 0)

    frame.hp:ClearAllPoints()
    frame.hp:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    frame.power:ClearAllPoints()
    frame.power:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    pfUI.api.CreateBackdrop(frame.portrait)
  elseif pos == "right" then
    frame.portrait:SetWidth(frame:GetHeight())
    frame.portrait:SetHeight(frame:GetHeight())
    frame:SetWidth(frame:GetWidth() + default_border*2 + spacing + frame.portrait:GetWidth())
    frame.portrait:SetPoint("RIGHT", frame, "RIGHT", 0, 0)

    frame.hp:ClearAllPoints()
    frame.hp:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.power:ClearAllPoints()
    frame.power:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)

    pfUI.api.CreateBackdrop(frame.portrait)
  end
end

function pfUI.uf:UpdatePortrait()
  local unit = this.base.label
  local id = this.base.id or ""
  local unitstr = unit .. id
  local name = UnitName(unitstr) or ""

  if not UnitIsVisible(unitstr) or not UnitIsConnected(unitstr) then
    if this.pos == "bar" then
      this.tex:Hide()
      this.model:Hide()
    elseif pfUI_config.unitframes.portraittexture == "1" then
      this.tex:Show()
      this.model:Hide()
      SetPortraitTexture(this.tex, unitstr)
    else
      this.tex:Hide()
      this.model:Show()
      this.model:SetModelScale(4.25)
      this.model:SetPosition(0, 0, -1)
      this.model:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
    end
  else
    this.tex:Hide()
    this.model:Show()
    this.model:SetUnit(unitstr)
    this.model:SetCamera(0)
  end
end

function pfUI.uf:CreateUnit(unit)
  unit:RegisterEvent("UNIT_AURA")
  unit:RegisterEvent("UNIT_HEALTH")
  unit:RegisterEvent("UNIT_MAXHEALTH")
  unit:RegisterEvent("UNIT_DISPLAYPOWER")
  unit:RegisterEvent("UNIT_MANA")
  unit:RegisterEvent("UNIT_MAXMANA")
  unit:RegisterEvent("UNIT_RAGE")
  unit:RegisterEvent("UNIT_MAXRAGE")
  unit:RegisterEvent("UNIT_ENERGY")
  unit:RegisterEvent("UNIT_MAXENERGY")
  unit:RegisterEvent("UNIT_FOCUS")

  unit:RegisterEvent("RAID_ROSTER_UPDATE")
  unit:RegisterEvent("PARTY_MEMBERS_CHANGED")

  unit:SetScript("OnShow", function ()
    pfUI.uf:RefreshUnit(this)
  end)

  unit:SetScript("OnEvent", function ()
    if this.label == "party" and event == "PARTY_MEMBERS_CHANGED" then
      pfUI.uf:RefreshUnit(this)
    end

    if this.label == "raid" and event == "RAID_ROSTER_UPDATE" then
      pfUI.uf:RefreshUnit(this)
    end

    if arg1 and arg1 == this.label .. this.id then
      pfUI.uf:RefreshUnit(this)
    end
  end)

  unit:SetScript("OnClick", function ()
    pfUI.uf:ClickAction(arg1)
  end)

  unit:SetScript("OnEnter", function()
    GameTooltip_SetDefaultAnchor(GameTooltip, this)
    GameTooltip:SetUnit(this.label .. this.id)
    GameTooltip:Show()
  end)

  unit:SetScript("OnLeave", function()
    GameTooltip:FadeOut()
  end)

  unit:SetScript("OnUpdate", function ()
    if CheckInteractDistance(this.label .. this.id, 4) or not UnitName(this.label .. this.id) then
      this:SetAlpha(1)
    else
      this:SetAlpha(.5)
    end

    if UnitIsConnected(this.label .. this.id) then
      if not this.cache then return end

      local hpDisplay = this.hp.bar:GetValue()
      local hpReal = this.cache.hp
      local hpDiff = abs(hpReal - hpDisplay)

      if this.label == "raid" and pfUI_config.unitframes.raid.invert_healthbar == "1" then
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
end
