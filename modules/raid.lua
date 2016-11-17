pfUI:RegisterModule("raid", function ()
  -- do not go further on disabled UFs
  if pfUI_config.unitframes.disable == "1" then return end

  pfUI.uf.raid = CreateFrame("Button","pfRaid",UIParent)
  pfUI.uf.raid:Hide()


  function pfUI.uf.raid:RefreshUnit(unit)
    if not unit.cache then unit.cache = {} end
    unit.cache.hp = UnitHealth("raid"..unit.id)
    unit.cache.hpmax = UnitHealthMax("raid"..unit.id)
    unit.cache.power = UnitMana("raid" .. unit.id)
    unit.cache.powermax = UnitManaMax("raid" .. unit.id)

    unit.hp.bar:SetMinMaxValues(0, unit.cache.hpmax)
    unit.power.bar:SetMinMaxValues(0, unit.cache.powermax)

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
      pfUI.uf.raid[i]:SetHeight(35)
      pfUI.uf.raid[i]:SetPoint("BOTTOMLEFT", (r-1) * 52 + 5, 160 + ((g-1)*37))
      pfUI.utils:UpdateMovable(pfUI.uf.raid[i])
      pfUI.uf.raid[i]:Hide()
      pfUI.uf.raid[i].id = 0

      pfUI.uf.raid[i].hp = CreateFrame("Frame",nil, pfUI.uf.raid[i])
      pfUI.uf.raid[i].hp:SetBackdrop(pfUI.backdrop)
      pfUI.uf.raid[i].hp:SetHeight(30)
      pfUI.uf.raid[i].hp:SetPoint("TOPLEFT",pfUI.uf.raid[i],"TOPLEFT")
      pfUI.uf.raid[i].hp:SetPoint("TOPRIGHT",pfUI.uf.raid[i],"TOPRIGHT")

      pfUI.uf.raid[i].hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.raid[i].hp)
      pfUI.uf.raid[i].hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")

      pfUI.uf.raid[i].hp.bar:ClearAllPoints()
      pfUI.uf.raid[i].hp.bar:SetPoint("TOPLEFT", pfUI.uf.raid[i].hp, "TOPLEFT", 3, -3)
      pfUI.uf.raid[i].hp.bar:SetPoint("BOTTOMRIGHT", pfUI.uf.raid[i].hp, "BOTTOMRIGHT", -3, 3)

      pfUI.uf.raid[i].hp.bar:SetStatusBarColor(0,1,0)

      pfUI.uf.raid[i].hp.bar:SetMinMaxValues(0, 100)
      pfUI.uf.raid[i].hp.bar:SetValue(0)

      pfUI.uf.raid[i].power = CreateFrame("Frame",nil, pfUI.uf.raid[i])
      pfUI.uf.raid[i].power:SetBackdrop(pfUI.backdrop)
      pfUI.uf.raid[i].power:SetPoint("TOPLEFT",pfUI.uf.raid[i].hp,"BOTTOMLEFT",0,3)
      pfUI.uf.raid[i].power:SetPoint("BOTTOMRIGHT",pfUI.uf.raid[i],"BOTTOMRIGHT",0,0)

      pfUI.uf.raid[i].power.bar = CreateFrame("StatusBar", nil, pfUI.uf.raid[i].power)
      pfUI.uf.raid[i].power.bar:ClearAllPoints()
      pfUI.uf.raid[i].power.bar:SetPoint("TOPLEFT", pfUI.uf.raid[i].power, "TOPLEFT", 3, -3)
      pfUI.uf.raid[i].power.bar:SetPoint("BOTTOMRIGHT", pfUI.uf.raid[i].power, "BOTTOMRIGHT", -3, 3)
      pfUI.uf.raid[i].power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")

      pfUI.uf.raid[i].power.bar:SetStatusBarColor(1,0,0)
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
            this.hp.bar:SetValue(this.cache.hp)
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
