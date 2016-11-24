pfUI:RegisterModule("raid", function ()
  -- do not go further on disabled UFs
  if pfUI_config.unitframes.disable == "1" then return end

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.raidframes ~= "-1" then
    default_border = pfUI_config.appearance.border.raidframes
  end

  pfUI.uf.raid = CreateFrame("Button","pfRaid",UIParent)
  pfUI.uf.raid:Hide()

  function pfUI.uf.raid:AddIcon(frame, pos, icon)
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
    pfUI.utils:CreateBackdrop(frame.icon[pos], nil, true)
    frame.icon[pos]:Show()
  end

  function pfUI.uf.raid:HideIcon(frame, pos)
    if not frame or not frame.hp or not frame.hp.bar then return end

    local frame = frame.hp.bar
    if frame.icon and frame.icon[pos] then
      frame.icon[pos]:Hide()
    end
  end

  function pfUI.uf.raid:SetupDebuffFilter()
    if pfUI.uf.raid.debuffs then return end

    local _, myclass = UnitClass("player")
    pfUI.uf.raid.debuffs = {}
    if pfUI_config.unitframes.raid.debuffs_enable == "1" then
      if myclass == "PALADIN" or myclass == "PRIEST" or pfUI_config.unitframes.raid.debuffs_class ~= "1" then
        table.insert(pfUI.uf.raid.debuffs, "magic")
      end

      if myclass == "DRUID" or myclass == "PALADIN" or myclass == "SHAMAN" or pfUI_config.unitframes.raid.debuffs_class ~= "1" then
        table.insert(pfUI.uf.raid.debuffs, "poison")
      end

      if myclass == "PRIEST" or myclass == "PALADIN" or myclass == "SHAMAN" or pfUI_config.unitframes.raid.debuffs_class ~= "1" then
        table.insert(pfUI.uf.raid.debuffs, "disease")
      end

      if myclass == "DRUID" or myclass == "MAGE" or pfUI_config.unitframes.raid.debuffs_class ~= "1" then
        table.insert(pfUI.uf.raid.debuffs, "curse")
      end
    end
  end

  function pfUI.uf.raid:SetupBuffFilter()
    if pfUI.uf.raid.buffs then return end

    local _, myclass = UnitClass("player")

    pfUI.uf.raid.buffs = {}

    -- [[ DRUID ]]
    if myclass == "DRUID" and pfUI_config.unitframes.raid.buffs_buffs == "1" then
      -- Gift of the Wild
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_nature_regeneration")

      -- Thorns
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_nature_thorns")
    end

    if (pfUI_config.unitframes.raid.buffs_classonly ~= "1" or myclass == "DRUID") and pfUI_config.unitframes.raid.buffs_hots == "1" then
      -- Regrowth
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_nature_resistnature")

      -- Rejuvenation
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_nature_rejuvenation")
    end


    -- [[ PRIEST ]]
    if myclass == "PRIEST" and pfUI_config.unitframes.raid.buffs_buffs == "1" then
      -- Prayer Of Fortitude"
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_holy_wordfortitude")
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_holy_prayeroffortitude")

      -- Prayer of Spirit
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_divinespirit")
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_holy_prayerofspirit")
    end

    if (pfUI_config.unitframes.raid.buffs_classonly ~= "1" or myclass == "PRIEST") and pfUI_config.unitframes.raid.buffs_hots == "1" then
      -- Renew
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_holy_renew")
    end

    if (pfUI_config.unitframes.raid.buffs_classonly ~= "1" or myclass == "PRIEST") and pfUI_config.unitframes.raid.buffs_procs == "1" then
      -- Inspiration
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\inv_shield_06")
    end


    -- [[ PALADIN ]]
    if myclass == "PALADIN" and pfUI_config.unitframes.raid.buffs_buffs == "1" then
      -- Blessing of Salvation
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_holy_greaterblessingofsalvation")
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_holy_sealofsalvation")

      -- Blessing of Wisdom
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_holy_sealofwisdom")
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_holy_greaterblessingofwisdom")

      -- Blessing of Sanctuary
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_nature_lightningshield")
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_holy_greaterblessingofsanctuary")

      -- Blessing of Kings
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_magic_magearmor")
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_magic_greaterblessingofkings")

      -- Blessing of Might
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_holy_fistofjustice")
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_holy_greaterblessingofkings")
    end


    -- [[ SHAMAN ]]
    if (pfUI_config.unitframes.raid.buffs_classonly ~= "1" or myclass == "SHAMAN") and pfUI_config.unitframes.raid.buffs_procs == "1" then
      -- Ancestral Fortitude
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_nature_undyingstrength")

      -- Healing Way
      table.insert(pfUI.uf.raid.buffs, "interface\\icons\\spell_nature_healingway")
    end
  end


  function pfUI.uf.raid:RefreshUnit(unit)
    if not unit.cache then unit.cache = {} end

    unit.cache.hp = UnitHealth("raid"..unit.id)
    unit.cache.hpmax = UnitHealthMax("raid"..unit.id)
    unit.cache.power = UnitMana("raid" .. unit.id)
    unit.cache.powermax = UnitManaMax("raid" .. unit.id)

    unit.hp.bar:SetMinMaxValues(0, unit.cache.hpmax)
    unit.power.bar:SetMinMaxValues(0, unit.cache.powermax)

    pfUI.uf.raid:SetupDebuffFilter()
    if table.getn(pfUI.uf.raid.debuffs) > 0 then
      local infected = false
      for i=1,32 do
        local _,_,dtype = UnitDebuff("raid" .. unit.id, i)
        if dtype then
          for _, filter in pairs(pfUI.uf.raid.debuffs) do
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

    pfUI.uf.raid:SetupBuffFilter()
    if table.getn(pfUI.uf.raid.buffs) > 0 then
      local active = {}

      for i=1,32 do
        local texture = UnitBuff("raid" .. unit.id,i)

        if texture then
          -- match filter
          for _, filter in pairs(pfUI.uf.raid.buffs) do
            if filter == string.lower(texture) then
              table.insert(active, texture)
              break
            end
          end

          -- add icons for every found buff
          for pos, icon in pairs(active) do
            pfUI.uf.raid:AddIcon(this, pos, icon)
          end
        end
      end

      -- hide unued icon slots
      for pos=table.getn(active)+1, 6 do
        pfUI.uf.raid:HideIcon(this, pos)
      end
    end

    _, class = UnitClass("raid"..unit.id)
    local c = RAID_CLASS_COLORS[class]
    local cr, cg, cb = 0, 0, 0
    if c then cr, cg, cb =(c.r + .5) * .5, (c.g + .5) * .5, (c.b + .5) * .5 end
    unit.hp.bar:SetStatusBarColor(cr, cg, cb)

    local p = ManaBarColor[UnitPowerType("raid"..unit.id)]
    local pr, pg, pb = 0, 0, 0
    if p then pr, pg, pb = p.r + .5, p.g +.5, p.b +.5 end
    unit.power.bar:SetStatusBarColor(pr, pg, pb)

    if UnitName("raid"..unit.id) then
      if unit.cache.hpmax ~= unit.cache.hp and pfUI_config.unitframes.raid.show_missing == "1" then
        unit.caption:SetText("-" .. unit.cache.hpmax - unit.cache.hp)
        unit.caption:SetTextColor(1,.3,.3)
      else
        unit.caption:SetText(UnitName("raid"..unit.id))
        unit.caption:SetTextColor(1,1,1)
      end
      unit.caption:SetAllPoints(unit.hp.bar)
    end
  end

  pfUI.uf.raid:RegisterEvent("RAID_ROSTER_UPDATE")
  pfUI.uf.raid:RegisterEvent("VARIABLES_LOADED")
  pfUI.uf.raid:SetScript("OnEvent", function()
    for i=1, 40 do
      pfUI.uf.raid[i].id = 0
      pfUI.uf.raid[i]:Hide()
    end

    -- sort players into roster
    for i=1, GetNumRaidMembers() do
      local name, _, subgroup  = GetRaidRosterInfo(i)
      if name then
        for subindex = 1, 5 do
          ids = subindex + 5*(subgroup-1)
          if pfUI.uf.raid[ids].id == 0 then
            pfUI.uf.raid[ids].id = i
            pfUI.uf.raid[ids]:Show()
            pfUI.uf.raid:RefreshUnit(pfUI.uf.raid[ids])
            break
          end
        end
      end
    end
  end)

  for r=1, 8 do
    for g=1, 5 do
      i = g + 5*(r-1)
      pfUI.uf.raid[i] = CreateFrame("Button","pfRaid" .. i,UIParent)

      pfUI.uf.raid[i]:SetWidth(50)
      pfUI.uf.raid[i]:SetHeight(30 + 2*default_border + pfUI_config.unitframes.raid.pspace)
      pfUI.uf.raid[i]:SetPoint("BOTTOMLEFT", (r-1) * (54+default_border) + 5, 160 + ((g-1)*(37+default_border))+default_border)
      pfUI.utils:UpdateMovable(pfUI.uf.raid[i])
      pfUI.uf.raid[i]:Hide()
      pfUI.uf.raid[i].id = 0

      pfUI.uf.raid[i].hp = CreateFrame("Frame",nil, pfUI.uf.raid[i])
      pfUI.uf.raid[i].hp:SetPoint("TOP", 0, 0)
      pfUI.uf.raid[i].hp:SetWidth(50)
      pfUI.uf.raid[i].hp:SetHeight(27)
      pfUI.utils:CreateBackdrop(pfUI.uf.raid[i].hp, default_border)

      pfUI.uf.raid[i].hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.raid[i].hp)
      pfUI.uf.raid[i].hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
      pfUI.uf.raid[i].hp.bar:SetAllPoints(pfUI.uf.raid[i].hp)
      pfUI.uf.raid[i].hp.bar:SetMinMaxValues(0, 100)

      pfUI.uf.raid[i].power = CreateFrame("Frame",nil, pfUI.uf.raid[i])
      pfUI.uf.raid[i].power:SetPoint("BOTTOM", 0, 0)
      pfUI.uf.raid[i].power:SetWidth(50)
      pfUI.uf.raid[i].power:SetHeight(3)
      pfUI.utils:CreateBackdrop(pfUI.uf.raid[i].power, default_border)

      pfUI.uf.raid[i].power.bar = CreateFrame("StatusBar", nil, pfUI.uf.raid[i].power)
      pfUI.uf.raid[i].power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
      pfUI.uf.raid[i].power.bar:SetAllPoints(pfUI.uf.raid[i].power)
      pfUI.uf.raid[i].power.bar:SetMinMaxValues(0, 100)

      pfUI.uf.raid[i].caption = pfUI.uf.raid[i]:CreateFontString("Status", "HIGH", "GameFontNormal")
      pfUI.uf.raid[i].caption:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
      pfUI.uf.raid[i].caption:SetAllPoints(pfUI.uf.raid[i].hp.bar)
      pfUI.uf.raid[i].caption:ClearAllPoints()
      pfUI.uf.raid[i].caption:SetParent(pfUI.uf.raid[i].hp.bar)
      pfUI.uf.raid[i].caption:SetPoint("CENTER",pfUI.uf.raid[i].hp.bar, "CENTER", 0, 0)
      pfUI.uf.raid[i].caption:SetJustifyH("CENTER")
      pfUI.uf.raid[i].caption:SetFontObject(GameFontWhite)

      pfUI.uf.raid[i].hp.leaderIcon = CreateFrame("Frame",nil,pfUI.uf.raid[i].hp)
      pfUI.uf.raid[i].hp.leaderIcon:SetWidth(10)
      pfUI.uf.raid[i].hp.leaderIcon:SetHeight(10)
      pfUI.uf.raid[i].hp.leaderIcon.texture = pfUI.uf.raid[i].hp.leaderIcon:CreateTexture(nil,"BACKGROUND")
      pfUI.uf.raid[i].hp.leaderIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Raid-LeaderIcon")
      pfUI.uf.raid[i].hp.leaderIcon.texture:SetAllPoints(pfUI.uf.raid[i].hp.leaderIcon)
      pfUI.uf.raid[i].hp.leaderIcon:SetPoint("TOPLEFT", pfUI.uf.raid[i].hp, "TOPLEFT", -4, 4)
      pfUI.uf.raid[i].hp.leaderIcon:Hide()

      pfUI.uf.raid[i].hp.lootIcon = CreateFrame("Frame",nil,pfUI.uf.raid[i].hp)
      pfUI.uf.raid[i].hp.lootIcon:SetWidth(10)
      pfUI.uf.raid[i].hp.lootIcon:SetHeight(10)
      pfUI.uf.raid[i].hp.lootIcon.texture = pfUI.uf.raid[i].hp.lootIcon:CreateTexture(nil,"BACKGROUND")
      pfUI.uf.raid[i].hp.lootIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Raid-MasterLooter")
      pfUI.uf.raid[i].hp.lootIcon.texture:SetAllPoints(pfUI.uf.raid[i].hp.lootIcon)
      pfUI.uf.raid[i].hp.lootIcon:SetPoint("TOPLEFT", pfUI.uf.raid[i].hp, "LEFT", -4, 4)
      pfUI.uf.raid[i].hp.lootIcon:Hide()

      pfUI.uf.raid[i].hp.raidIcon = CreateFrame("Frame",nil,pfUI.uf.raid[i].hp.bar)
      pfUI.uf.raid[i].hp.raidIcon:SetWidth(24)
      pfUI.uf.raid[i].hp.raidIcon:SetHeight(24)
      pfUI.uf.raid[i].hp.raidIcon.texture = pfUI.uf.raid[i].hp.raidIcon:CreateTexture(nil,"ARTWORK")
      pfUI.uf.raid[i].hp.raidIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")
      pfUI.uf.raid[i].hp.raidIcon.texture:SetAllPoints(pfUI.uf.raid[i].hp.raidIcon)
      pfUI.uf.raid[i].hp.raidIcon:SetPoint("TOP", pfUI.uf.raid[i].hp, "TOP", -4, 4)
      pfUI.uf.raid[i].hp.raidIcon:Hide()

      pfUI.uf.raid[i]:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

      pfUI.uf.raid[i]:SetScript("OnEnter", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, this)
        GameTooltip:SetUnit("raid" .. this.id)
        GameTooltip:Show()
      end)

      pfUI.uf.raid[i]:SetScript("OnLeave", function()
        GameTooltip:FadeOut()
      end)

      pfUI.uf.raid[i]:SetScript("OnClick", function ()
        if ( SpellIsTargeting() and arg1 == "RightButton" ) then
          SpellStopTargeting()
          return
        end

        if ( arg1 == "LeftButton" ) then
          if ( SpellIsTargeting() ) then
            SpellTargetUnit("raid" .. this.id)
          elseif ( CursorHasItem() ) then
            DropItemOnUnit("raid" .. this.id)
          else
            TargetUnit("raid" .. this.id)
            -- clickcast: shift modifier
            if IsShiftKeyDown() then
              if pfUI_config.unitframes.raid.clickcast_shift ~= "" then
                CastSpellByName(pfUI_config.unitframes.raid.clickcast_shift)
                pfUI.uf.target.noanim = "yes"
                TargetLastTarget()
                return
              end
            -- clickcast: alt modifier
            elseif IsAltKeyDown() then
              if pfUI_config.unitframes.raid.clickcast_alt ~= "" then
                CastSpellByName(pfUI_config.unitframes.raid.clickcast_alt)
                pfUI.uf.target.noanim = "yes"
                TargetLastTarget()
                return
              end
            -- clickcast: ctrl modifier
            elseif IsControlKeyDown() then
              if pfUI_config.unitframes.raid.clickcast_ctrl ~= "" then
                CastSpellByName(pfUI_config.unitframes.raid.clickcast_ctrl)
                pfUI.uf.target.noanim = "yes"
                TargetLastTarget()
                return
              end
            -- clickcast: default
            else
              if pfUI_config.unitframes.raid.clickcast ~= "" then
                CastSpellByName(pfUI_config.unitframes.raid.clickcast)
                pfUI.uf.target.noanim = "yes"
                TargetLastTarget()
                return
              else
                -- no clickcast: default action
                TargetUnit("raid" .. this.id)
              end
            end
          end
        else
          ToggleDropDownMenu(1, nil, getglobal("RaidMemberFrame" .. this.id .. "DropDown"), "cursor")
          FriendsDropDown.initialize = RaidFrameDropDown_Initialize
          FriendsDropDown.displayMode = "MENU"
          ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
        end
      end)

      pfUI.uf.raid[i]:RegisterEvent("UNIT_AURA")
      pfUI.uf.raid[i]:RegisterEvent("UNIT_HEALTH")
      pfUI.uf.raid[i]:RegisterEvent("UNIT_MAXHEALTH")
      pfUI.uf.raid[i]:RegisterEvent("UNIT_MANA")
      pfUI.uf.raid[i]:RegisterEvent("UNIT_MANAMAX")
      pfUI.uf.raid[i]:RegisterEvent("RAID_ROSTER_UPDATE")
      pfUI.uf.raid[i]:SetScript("OnShow", function ()
        pfUI.uf.raid:RefreshUnit(this)
      end)

      pfUI.uf.raid[i]:SetScript("OnEvent", function ()
        if arg1 == "raid" .. this.id or event == "RAID_ROSTER_UPDATE" then
          pfUI.uf.raid:RefreshUnit(this)
        end
      end)

      pfUI.uf.raid[i]:SetScript("OnUpdate", function ()
        if CheckInteractDistance("raid" .. this.id, 4) or not UnitName("raid" .. this.id) then
          this:SetAlpha(1)
        else
          this:SetAlpha(.5)
        end

        if UnitIsConnected("raid" .. this.id) then
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
    end
  end
end)
