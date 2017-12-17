pfUI:RegisterModule("tracking", function ()

  MiniMapTrackingFrame:UnregisterAllEvents()
  MiniMapTrackingFrame:Hide()

  local config = {
      border = C.appearance.border.default,
      size = tonumber(C.appearance.minimap.tracking_size),
      pulse = C.appearance.minimap.tracking_pulse == "1"
  }

  local knownTrackingSpellTextures = {
    any = {
      "Racial_Dwarf_FindTreasure", -- Find Treasure
      "Spell_Nature_Earthquake", -- Find Minerals
      "INV_Misc_Flower_02" -- Find Herbs
    },
    HUNTER = {
      "Ability_Tracking", -- Track Beasts, 4+
      "Spell_Holy_PrayerOfHealing", -- Track Humanoids, 10+
      "Spell_Shadow_DarkSummoning", -- Track Undead, 18+
      "Ability_Stealth", -- Track Hidden, 24+
      "Spell_Frost_SummonWaterElemental", -- Track Elementals, 26+
      "Spell_Shadow_SummonFelhunter", -- Track Deamons, 32+
      "Ability_Racial_Avatar", -- Track Giants, 40+
      "INV_Misc_Head_Dragon_01" -- Track Dragonkin, 50+
    },
    PALADIN = {
      "Spell_Holy_SenseUndead" -- Sense Undead, 20+
    },
    WARLOCK = {
      "Spell_Shadow_Metamorphosis" -- Sense Demons, 24+
    },
    DRUID = {
      "Ability_Tracking" -- Track Humanoids, 32+, Cat Form only!
    }
  }

  local state = {
    texture = nil,
    spells = {}
  }

  pfUI.tracking = CreateFrame("Button", "pfUITracking", UIParent)
  pfUI.tracking:SetFrameStrata("LOW")
  CreateBackdrop(pfUI.tracking, config.border)
  pfUI.tracking:SetPoint("TOPLEFT", pfUI.minimap, -10, -10)
  UpdateMovable(pfUI.tracking)
  pfUI.tracking:SetWidth(config.size)
  pfUI.tracking:SetHeight(config.size)

  pfUI.tracking.icon = pfUI.tracking:CreateTexture("BACKGROUND")
  pfUI.tracking.icon:SetTexCoord(.08, .92, .08, .92)
  pfUI.tracking.icon:SetAllPoints(pfUI.tracking)

  pfUI.tracking.menu = CreateFrame("Frame", "pfUIDropDownMenuTracking", nil, "UIDropDownMenuTemplate")

  pfUI.tracking:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.tracking:RegisterEvent("PLAYER_AURAS_CHANGED")
  pfUI.tracking:RegisterEvent("SPELLS_CHANGED")
  pfUI.tracking:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
  pfUI.tracking:SetScript("OnEvent", function()
    this:RefreshSpells()
    local texture = GetTrackingTexture()
    if texture and texture ~= state.texture then
      state.texture = texture
      this.pulse = nil
      this.icon:SetTexture(texture)
      this.icon:SetVertexColor(1,1,1,1)
      this:Show()
    else
      state.texture = texture

      if config.pulse and table.getn(state.spells) > 0 then
        this.pulse = true
        this.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        this.icon:SetVertexColor(1,1,1,1)
        this:Show()
      else
        this.pulse = nil
        this:Hide()
      end
    end
  end)

  pfUI.tracking:SetScript("OnUpdate", function()
    if this.pulse then
      local _,_,_,alpha = this.icon:GetVertexColor()
      local fpsmod = GetFramerate() / 30
      if not alpha or alpha >= 0.9 then
        this.modifier = -0.03 / fpsmod
      elseif alpha <= .5 then
        this.modifier = 0.03  / fpsmod
      end

      this.icon:SetVertexColor(1,1,1,alpha + this.modifier)
    end
  end)

  pfUI.tracking:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  pfUI.tracking:SetScript("OnClick", function()
    if arg1 == "RightButton" then
      pfUI.tracking:InitMenu()
      ToggleDropDownMenu(1, nil, pfUI.tracking.menu, this, -5, -5)
    end
    if arg1 == "LeftButton" and state.texture then
      CancelTrackingBuff()
    end
  end)

  pfUI.tracking:SetScript("OnEnter", function()
    GameTooltip_SetDefaultAnchor(GameTooltip, this)
    if state.texture then
      GameTooltip:SetTrackingSpell()
    else
      GameTooltip:SetText(T["No tracking spell active"])
    end
    GameTooltip:Show()
  end)

  pfUI.tracking:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  function pfUI.tracking:RefreshSpells()
    local _, playerClass = UnitClass(PLAYER)
    local isCatForm = pfUI.tracking:PlayerIsDruidInCatForm(playerClass)

    state.spells = {}
    for tabIndex = 1, GetNumSpellTabs() do
      local _, _, offset, numSpells = GetSpellTabInfo(tabIndex)
      for spellIndex = offset + 1, offset + numSpells do
        local spellTexture = GetSpellTexture(spellIndex, BOOKTYPE_SPELL)
        for _, c in pairs({"any", playerClass}) do
          for _, t in pairs(knownTrackingSpellTextures[c] or {}) do
            if c == "DRUID" and not isCatForm then
              break
            end
            if strfind(spellTexture, t) then
              table.insert(state.spells, {
                index = spellIndex,
                name = GetSpellName(spellIndex, BOOKTYPE_SPELL),
                texture = spellTexture
              })
              break
            end
          end
        end
      end
    end
  end

  function pfUI.tracking:PlayerIsDruidInCatForm(playerClass)
    if playerClass == "DRUID" then
      for i = 0, 31 do
        local texture = GetPlayerBuffTexture(i)
        if not texture then break end
        if strfind(texture, "Ability_Druid_CatForm") then
          return true
        end
      end
    end
    return false
  end

  function pfUI.tracking:InitMenu()
    UIDropDownMenu_Initialize(pfUI.tracking.menu, function ()
      UIDropDownMenu_AddButton({text = T["Minimap Tracking"], isTitle = 1})
      for _, spell in pairs(state.spells) do
        UIDropDownMenu_AddButton({
          text = spell.name,
          icon = spell.texture,
          tCoordLeft = .1,
          tCoordRight = .9,
          tCoordTop = .1,
          tCoordBottom = .9,
          checked = spell.texture == state.texture,
          arg1 = spell,
          func = function (arg1)
            CastSpell(arg1.index, BOOKTYPE_SPELL)
            CloseDropDownMenus()
          end
        })
      end
    end, "MENU");
  end
end)
