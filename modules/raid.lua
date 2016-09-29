pfUI:RegisterModule("raid", function ()
  pfUI.uf.raid = CreateFrame("Button","pfRaid",UIParent)
  pfUI.uf.raid:Hide()

  pfUI.uf.raid:RegisterEvent("RAID_ROSTER_UPDATE")
  pfUI.uf.raid:RegisterEvent("VARIABLES_LOADED")
  pfUI.uf.raid:RegisterEvent("UNIT_AURA")

  pfUI.uf.raid:SetScript("OnEvent", function()
    for i=1, 40 do
      pfUI.uf.raid[i].id = 0
      pfUI.uf.raid[i]:Hide()
    end

    -- sort players into roster
    for i=1, GetNumRaidMembers() do
      local name, _, subgroup  = GetRaidRosterInfo(i);
      if name then
        for subindex = 1, 5 do
          ids = subindex + 5*(subgroup-1)
          if pfUI.uf.raid[ids].id == 0 then
            pfUI.uf.raid[ids].id = i
            pfUI.uf.raid[ids]:Show()
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
      pfUI.utils:loadPosition(pfUI.uf.raid[i])
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
      pfUI.uf.raid[i].caption:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", pfUI_config.global.font_size, "OUTLINE")
      pfUI.uf.raid[i].caption:SetAllPoints(pfUI.uf.raid[i].hp.bar)
      pfUI.uf.raid[i].caption:ClearAllPoints()
      pfUI.uf.raid[i].caption:SetParent(pfUI.uf.raid[i].hp.bar)
      pfUI.uf.raid[i].caption:SetPoint("CENTER",pfUI.uf.raid[i].hp.bar, "CENTER", 0, 0)
      pfUI.uf.raid[i].caption:SetJustifyH("CENTER")
      pfUI.uf.raid[i].caption:SetFontObject(GameFontWhite)
      pfUI.uf.raid[i].caption:SetText("Raid"..i)

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
        GameTooltip:SetOwner(this, "ANCHOR_NONE");
        GameTooltip:SetUnit("raid" .. this.id);
        GameTooltip:Show()
      end)

      pfUI.uf.raid[i]:SetScript("OnLeave", function()
        GameTooltip:FadeOut()
      end)

      pfUI.uf.raid[i]:SetScript("OnClick", function ()
        if ( SpellIsTargeting() and arg1 == "RightButton" ) then
          SpellStopTargeting();
          return;
        end

        if ( arg1 == "LeftButton" ) then
          if ( SpellIsTargeting() ) then
            SpellTargetUnit("raid" .. this.id);
          elseif ( CursorHasItem() ) then
            DropItemOnUnit("raid" .. this.id);
          else
            TargetUnit("raid" .. this.id);
            -- clickcast: Shift-modifier
            if IsShiftKeyDown() then
              if pfUI_config.unitframes.raid.clickcast_shift ~= "" then
                CastSpellByName(pfUI_config.unitframes.raid.clickcast_shift)
                TargetLastTarget()
                return
              end
            -- clickcast: alt modifier
            elseif IsAltKeyDown() then
              if pfUI_config.unitframes.raid.clickcast_alt ~= "" then
                CastSpellByName(pfUI_config.unitframes.raid.clickcast_alt)
                TargetLastTarget()
                return
              end
            -- clickcast: ctrl modifier
            elseif IsControlKeyDown() then
              if pfUI_config.unitframes.raid.clickcast_ctrl ~= "" then
                CastSpellByName(pfUI_config.unitframes.raid.clickcast_ctrl)
                TargetLastTarget()
                return
              end
            -- clickcast: default
            else
              if pfUI_config.unitframes.raid.clickcast ~= "" then
                CastSpellByName(pfUI_config.unitframes.raid.clickcast)
                TargetLastTarget()
                return
              else
                -- no clickcast: default action
                TargetUnit("raid" .. this.id);
              end
            end
          end
        else
          ToggleDropDownMenu(1, nil, getglobal("RaidMemberFrame" .. this.id .. "DropDown"), "cursor")
          FriendsDropDown.initialize = RaidFrameDropDown_Initialize;
          FriendsDropDown.displayMode = "MENU";
          ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor");
        end
      end)

      pfUI.uf.raid[i]:SetScript("OnUpdate", function ()
        if CheckInteractDistance("raid" .. this.id, 4) then
          this:SetAlpha(1)
        else
          this:SetAlpha(.5)
        end

        if UnitIsConnected("raid" .. this.id) then
          this.hp.bar:SetMinMaxValues(0, UnitHealthMax("raid"..this.id))
          this.power.bar:SetMinMaxValues(0, UnitManaMax("raid"..this.id))

          local hpDisplay = this.hp.bar:GetValue()
          local hpReal = UnitHealth("raid"..this.id)
          local hpDiff = abs(hpReal - hpDisplay)

          if hpDisplay < hpReal then
            this.hp.bar:SetValue(hpDisplay + ceil(hpDiff / pfUI_config.unitframes.animation_speed))
          elseif hpDisplay > hpReal then
            this.hp.bar:SetValue(hpDisplay - ceil(hpDiff / pfUI_config.unitframes.animation_speed))
          end

          local powerDisplay = this.power.bar:GetValue()
          local powerReal = UnitMana("raid"..this.id)
          local powerDiff = abs(powerReal - powerDisplay)

          if powerDisplay < powerReal then
            this.power.bar:SetValue(powerDisplay + ceil(powerDiff / pfUI_config.unitframes.animation_speed))
          elseif powerDisplay > powerReal then
            this.power.bar:SetValue(powerDisplay - ceil(powerDiff / pfUI_config.unitframes.animation_speed))
          end

          _, class = UnitClass("raid"..this.id)
          local c = RAID_CLASS_COLORS[class]
          local cr, cg, cb = 0, 0, 0
          if c then cr, cg, cb =(c.r + .5) * .5, (c.g + .5) * .5, (c.b + .5) * .5 end

          this.hp.bar:SetStatusBarColor(cr, cg, cb)

          local pcolor = ManaBarColor[UnitPowerType("raid"..this.id)];
          this.power.bar:SetStatusBarColor(pcolor.r + .5, pcolor.g +.5, pcolor.b +.5, 1)

        else
          this.hp.bar:SetMinMaxValues(0, 100)
          this.power.bar:SetMinMaxValues(0, 100)
          this.hp.bar:SetValue(0)
          this.power.bar:SetValue(0)
        end
        if UnitName("raid"..this.id) then
          this.caption:SetText(UnitName("raid"..this.id))
          this.caption:SetAllPoints(this.hp.bar)
        end
      end)
    end
  end
end)
