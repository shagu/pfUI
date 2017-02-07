pfUI:RegisterModule("nameplates", function ()
  pfUI.nameplates = CreateFrame("Frame", nil, UIParent)
  pfUI.nameplates.mobs = {}
  pfUI.nameplates.targets = {}

  -- catch all nameplates
  pfUI.nameplates.scanner = CreateFrame("Frame", "pfNameplateScanner", UIParent)
  pfUI.nameplates.scanner.objects = {}
  pfUI.nameplates.scanner:SetScript("OnUpdate", function()
    for _, nameplate in ipairs({WorldFrame:GetChildren()}) do
      if not nameplate.done and nameplate:GetObjectType() == "Button" then
        local regions = nameplate:GetRegions()
        if regions and regions:GetObjectType() == "Texture" and regions:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" then
          nameplate:Hide()
          nameplate:SetScript("OnShow", function() pfUI.nameplates:CreateNameplate() end)
          nameplate:SetScript("OnUpdate", function() pfUI.nameplates:UpdateNameplate() end)
          nameplate:Show()
          table.insert(this.objects, nameplate)
          nameplate.done = true
        end
      end
    end
  end)

  -- Create Nameplate
  function pfUI.nameplates:CreateNameplate()
    local healthbar = this:GetChildren()
    local border, glow, name, level, levelicon , raidicon = this:GetRegions()

    -- hide default plates
    border:Hide()

    -- remove glowing
    glow:Hide()
    glow:SetAlpha(0)
    glow.Show = function() return end

    if pfUI_config.nameplates.players == "1" then
      if not pfUI_playerDB[name:GetText()] or not pfUI_playerDB[name:GetText()]["class"] then
        this:Hide()
      end
    end

    -- healthbar
    healthbar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    healthbar:ClearAllPoints()
    healthbar:SetPoint("TOP", this, "TOP", 0, tonumber(pfUI_config.nameplates.vpos))
    healthbar:SetWidth(110)
    healthbar:SetHeight(7)

    if healthbar.bg == nil then
      healthbar.bg = healthbar:CreateTexture(nil, "BORDER")
      healthbar.bg:SetTexture(0,0,0,0.90)
      healthbar.bg:ClearAllPoints()
      healthbar.bg:SetPoint("CENTER", healthbar, "CENTER", 0, 0)
      healthbar.bg:SetWidth(healthbar:GetWidth() + 3)
      healthbar.bg:SetHeight(healthbar:GetHeight() + 3)
    end

    healthbar.reaction = nil

    -- raidtarget
    raidicon:ClearAllPoints()
    raidicon:SetWidth(pfUI_config.nameplates.raidiconsize)
    raidicon:SetHeight(pfUI_config.nameplates.raidiconsize)
    raidicon:SetPoint("CENTER", healthbar, "CENTER", 0, -5)

    -- adjust font
    name:SetFont(STANDARD_TEXT_FONT,11,STANDARD_TEXT_FONT_FLAGS)
    name:SetPoint("BOTTOM", healthbar, "CENTER", 0, 7)
    level:SetFont(STANDARD_TEXT_FONT,11, STANDARD_TEXT_FONT_FLAGS)
    level:ClearAllPoints()
    level:SetPoint("RIGHT", healthbar, "LEFT", -1, 0)
    levelicon:ClearAllPoints()
    levelicon:SetPoint("RIGHT", healthbar, "LEFT", -1, 0)

    -- show indicator for elite/rare mobs
    if level:GetText() ~= nil then
      if pfUI.nameplates.mobs[name:GetText()] and pfUI.nameplates.mobs[name:GetText()] == "elite" and not string.find(level:GetText(), "+", 1) then
        level:SetText(level:GetText() .. "+")
      elseif pfUI.nameplates.mobs[name:GetText()] and pfUI.nameplates.mobs[name:GetText()] == "rareelite" and not string.find(level:GetText(), "R+", 1) then
        level:SetText(level:GetText() .. "R+")
      elseif pfUI.nameplates.mobs[name:GetText()] and pfUI.nameplates.mobs[name:GetText()] == "rare" and not string.find(level:GetText(), "R", 1) then
        level:SetText(level:GetText() .. "R")
      end
    end

    pfUI.nameplates:CreateDebuffs(this)
    pfUI.nameplates:CreateCastbar(healthbar)
    pfUI.nameplates:CreateHP(healthbar)

    this.setup = true
  end

  function pfUI.nameplates:CreateDebuffs(frame)
    if not pfUI_config.nameplates["showdebuffs"] == "1" then return end

    if frame.debuffs == nil then frame.debuffs = {} end
    for j=1, 16, 1 do
      if frame.debuffs[j] == nil then
        frame.debuffs[j] = this:CreateTexture(nil, "BORDER")
        frame.debuffs[j]:SetTexture(0,0,0,0)
        frame.debuffs[j]:ClearAllPoints()
        frame.debuffs[j]:SetWidth(12)
        frame.debuffs[j]:SetHeight(12)
        if j == 1 then
          frame.debuffs[j]:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -3)
        elseif j <= 8 then
          frame.debuffs[j]:SetPoint("LEFT", frame.debuffs[j-1], "RIGHT", 1, 0)
        elseif j > 8 then
          frame.debuffs[j]:SetPoint("TOPLEFT", frame.debuffs[1], "BOTTOMLEFT", (j-9) * 13, -1)
        end
      end
    end
  end

  function pfUI.nameplates:CreateCastbar(healthbar)
    if not pfUI.castbar or not pfUI_config.nameplates["showcastbar"] == "1" then return end

    -- create frames
    if healthbar.castbar == nil then
      healthbar.castbar = CreateFrame("StatusBar", nil, healthbar)
      healthbar.castbar:Hide()
      healthbar.castbar:SetWidth(110)
      healthbar.castbar:SetHeight(7)
      healthbar.castbar:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -5)
      healthbar.castbar:SetBackdrop({  bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
                                       insets = {left = -1, right = -1, top = -1, bottom = -1} })
      healthbar.castbar:SetBackdropColor(0,0,0,1)
      healthbar.castbar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
      healthbar.castbar:SetStatusBarColor(.9,.8,0,1)

      if healthbar.castbar.bg == nil then
        healthbar.castbar.bg = healthbar.castbar:CreateTexture(nil, "BACKGROUND")
        healthbar.castbar.bg:SetTexture(0,0,0,0.90)
        healthbar.castbar.bg:ClearAllPoints()
        healthbar.castbar.bg:SetPoint("CENTER", healthbar.castbar, "CENTER", 0, 0)
        healthbar.castbar.bg:SetWidth(healthbar.castbar:GetWidth() + 3)
        healthbar.castbar.bg:SetHeight(healthbar.castbar:GetHeight() + 3)
      end

      if healthbar.castbar.text == nil then
        healthbar.castbar.text = healthbar.castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
        healthbar.castbar.text:SetPoint("RIGHT", healthbar.castbar, "LEFT")
        healthbar.castbar.text:SetNonSpaceWrap(false)
        healthbar.castbar.text:SetFontObject(GameFontWhite)
        healthbar.castbar.text:SetTextColor(1,1,1,.5)
        healthbar.castbar.text:SetFont(STANDARD_TEXT_FONT, 10, STANDARD_TEXT_FONT_FLAGS)
      end

      if healthbar.castbar.spell == nil then
        healthbar.castbar.spell = healthbar.castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
        healthbar.castbar.spell:SetPoint("CENTER", healthbar.castbar, "CENTER")
        healthbar.castbar.spell:SetNonSpaceWrap(false)
        healthbar.castbar.spell:SetFontObject(GameFontWhite)
        healthbar.castbar.spell:SetTextColor(1,1,1,1)
        healthbar.castbar.spell:SetFont(STANDARD_TEXT_FONT, 10, STANDARD_TEXT_FONT_FLAGS)
      end

      if healthbar.castbar.icon == nil then
        healthbar.castbar.icon = healthbar.castbar:CreateTexture(nil, "BORDER")
        healthbar.castbar.icon:ClearAllPoints()
        healthbar.castbar.icon:SetPoint("BOTTOMLEFT", healthbar.castbar, "BOTTOMRIGHT", 5, 0)
        healthbar.castbar.icon:SetWidth(18)
        healthbar.castbar.icon:SetHeight(18)
      end

      if healthbar.castbar.icon.bg == nil then
        healthbar.castbar.icon.bg = healthbar.castbar:CreateTexture(nil, "BACKGROUND")
        healthbar.castbar.icon.bg:SetTexture(0,0,0,0.90)
        healthbar.castbar.icon.bg:ClearAllPoints()
        healthbar.castbar.icon.bg:SetPoint("CENTER", healthbar.castbar.icon, "CENTER", 0, 0)
        healthbar.castbar.icon.bg:SetWidth(healthbar.castbar.icon:GetWidth() + 3)
        healthbar.castbar.icon.bg:SetHeight(healthbar.castbar.icon:GetHeight() + 3)
      end
    end
  end

  function pfUI.nameplates:CreateHP(healthbar)
    if pfUI_config.nameplates.showhp == "1" and not healthbar.hptext then
      healthbar.hptext = healthbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      healthbar.hptext:SetPoint("RIGHT", healthbar, "RIGHT")
      healthbar.hptext:SetNonSpaceWrap(false)
      healthbar.hptext:SetFontObject(GameFontWhite)
      healthbar.hptext:SetTextColor(1,1,1,1)
      healthbar.hptext:SetFont(STANDARD_TEXT_FONT, 10)
    end
  end

  -- Update Nameplate
  function pfUI.nameplates:UpdateNameplate()
    if not this.setup then pfUI.nameplates:CreateNameplate() return end

    local healthbar = this:GetChildren()
    local border, glow, name, level, levelicon , raidicon = this:GetRegions()

    if pfUI_config.nameplates.players == "1" then
      if not pfUI_playerDB[name:GetText()] or not pfUI_playerDB[name:GetText()]["class"] then
        this:Hide()
      end
    end

    pfUI.nameplates:UpdatePlayer(name)
    pfUI.nameplates:UpdateColors(name, level, healthbar)
    pfUI.nameplates:UpdateCastbar(this, name, healthbar)
    pfUI.nameplates:UpdateDebuffs(this, healthbar)
    pfUI.nameplates:UpdateHP(healthbar)
    pfUI.nameplates:UpdateClickHandler(this)
  end

  function pfUI.nameplates:UpdatePlayer(name)
    local name = name:GetText()

    -- target
    if not pfUI_playerDB[name] and pfUI.nameplates.targets[name] == nil and UnitName("target") == nil then
      TargetByName(name, true)
      if UnitIsPlayer("target") then
        local _, class = UnitClass("target")
        pfUI_playerDB[name] = {}
        pfUI_playerDB[name]["class"] = class
      elseif UnitClassification("target") ~= "normal" then
        local elite = UnitClassification("target")
        pfUI.nameplates.mobs[name] = elite
      end
      pfUI.nameplates.targets[name] = "OK"
      ClearTarget()
    end

    -- mouseover
    if not pfUI_playerDB[name] and pfUI.nameplates.targets[name] == nil and UnitName("mouseover") == name then
      if UnitIsPlayer("mouseover") then
        local _, class = UnitClass("mouseover")
        pfUI_playerDB[name] = {}
        pfUI_playerDB[name]["class"] = class
      elseif UnitClassification("mouseover") ~= "normal" then
        local elite = UnitClassification("mouseover")
        pfUI.nameplates.mobs[name] = elite
      end
      pfUI.nameplates.targets[name] = "OK"
    end
  end

  function pfUI.nameplates:UpdateColors(name, level, healthbar)
    -- name color
    local red, green, blue, _ = name:GetTextColor()
    if red > 0.99 and green == 0 and blue == 0 then
      name:SetTextColor(1,0.4,0.2,0.85)
    elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
      name:SetTextColor(1,1,1,0.85)
    end

    -- level colors
    local red, green, blue, _ = level:GetTextColor()
    if red > 0.99 and green == 0 and blue == 0 then
      level:SetTextColor(1,0.4,0.2,0.85)
    elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
      level:SetTextColor(1,1,1,0.85)
    end

    -- healthbar color
    -- reaction: 0 enemy ; 1 neutral ; 2 player ; 3 npc
    local red, green, blue, _ = healthbar:GetStatusBarColor()
    if red > 0.9 and green < 0.2 and blue < 0.2 then
      healthbar.reaction = 0
      healthbar:SetStatusBarColor(.9,.2,.3,0.8)
    elseif red > 0.9 and green > 0.9 and blue < 0.2 then
      healthbar.reaction = 1
      healthbar:SetStatusBarColor(1,1,.3,0.8)
    elseif ( blue > 0.9 and red == 0 and green == 0 ) then
      healthbar.reaction = 2
      healthbar:SetStatusBarColor(0.2,0.6,1,0.8)
    elseif red == 0 and green > 0.99 and blue == 0 then
      healthbar.reaction = 3
      healthbar:SetStatusBarColor(0.6,1,0,0.8)
    end

    local name = name:GetText()
    if healthbar.reaction == 0 then
      if pfUI_config.nameplates["enemyclassc"] == "1"
      and pfUI_playerDB[name]
      and pfUI_playerDB[name]["class"]
      and RAID_CLASS_COLORS[pfUI_playerDB[name]["class"]]
      then
        healthbar:SetStatusBarColor(
          RAID_CLASS_COLORS[pfUI_playerDB[name]["class"]].r,
          RAID_CLASS_COLORS[pfUI_playerDB[name]["class"]].g,
          RAID_CLASS_COLORS[pfUI_playerDB[name]["class"]].b,
          0.9)
      end
    elseif healthbar.reaction == 2 then
      if pfUI_config.nameplates["friendclassc"] == "1"
      and pfUI_playerDB[name]
      and pfUI_playerDB[name]["class"]
      and RAID_CLASS_COLORS[pfUI_playerDB[name]["class"]]
      then
        healthbar:SetStatusBarColor(
          RAID_CLASS_COLORS[pfUI_playerDB[name]["class"]].r,
          RAID_CLASS_COLORS[pfUI_playerDB[name]["class"]].g,
          RAID_CLASS_COLORS[pfUI_playerDB[name]["class"]].b,
          0.9)
      end
    end
  end

  function pfUI.nameplates:UpdateCastbar(frame, name, healthbar)
    if not healthbar.castbar then return end

    -- show castbar
    if pfUI.castbar and pfUI_config.nameplates["showcastbar"] == "1" and pfUI.castbar.target.casterDB[name:GetText()] ~= nil and pfUI.castbar.target.casterDB[name:GetText()]["cast"] ~= nil then
      if pfUI.castbar.target.casterDB[name:GetText()]["starttime"] + pfUI.castbar.target.casterDB[name:GetText()]["casttime"] <= GetTime() then
        pfUI.castbar.target.casterDB[name:GetText()] = nil
        healthbar.castbar:Hide()
      else
        healthbar.castbar:SetMinMaxValues(0,  pfUI.castbar.target.casterDB[name:GetText()]["casttime"])
        healthbar.castbar:SetValue(GetTime() -  pfUI.castbar.target.casterDB[name:GetText()]["starttime"])
        healthbar.castbar.text:SetText(pfUI.api.round( pfUI.castbar.target.casterDB[name:GetText()]["starttime"] +  pfUI.castbar.target.casterDB[name:GetText()]["casttime"] - GetTime(),1))
        if pfUI_config.nameplates.spellname == "1" and healthbar.castbar.spell then
          healthbar.castbar.spell:SetText(pfUI.castbar.target.casterDB[name:GetText()]["cast"])
        else
          healthbar.castbar.spell:SetText("")
        end
        healthbar.castbar:Show()
        frame.debuffs[1]:SetPoint("TOPLEFT", healthbar.castbar, "BOTTOMLEFT", 0, -3)

        if pfUI.castbar.target.casterDB[name:GetText()]["icon"] then
          healthbar.castbar.icon:SetTexture("Interface\\Icons\\" ..  pfUI.castbar.target.casterDB[name:GetText()]["icon"])
          healthbar.castbar.icon:SetTexCoord(.1,.9,.1,.9)
        end
      end
    else
      healthbar.castbar:Hide()
      frame.debuffs[1]:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -3)
    end
  end

  function pfUI.nameplates:UpdateDebuffs(frame, healthbar)
    if not frame.debuffs or not pfUI_config.nameplates["showdebuffs"] == "1" then return end

    if UnitExists("target") and healthbar:GetAlpha() == 1 then
    local j = 1
      local k = 1
      for j, e in ipairs(pfUI.nameplates.debuffs) do
        frame.debuffs[j]:SetTexture(pfUI.nameplates.debuffs[j])
        frame.debuffs[j]:SetTexCoord(.078, .92, .079, .937)
        frame.debuffs[j]:SetAlpha(0.9)
        k = k + 1
      end
      for j = k, 16, 1 do
        frame.debuffs[j]:SetTexture(nil)
      end
    elseif frame.debuffs then
      for j = 1, 16, 1 do
        frame.debuffs[j]:SetTexture(nil)
      end
    end
  end

  function pfUI.nameplates:UpdateHP(healthbar)
    if pfUI_config.nameplates.showhp == "1" and healthbar.hptext then
      local min, max = healthbar:GetMinMaxValues()
      local cur = healthbar:GetValue()
      healthbar.hptext:SetText(cur .. " / " .. max)
    end
  end

  function pfUI.nameplates:UpdateClickHandler(frame)
    -- enable clickthrough
    if pfUI_config.nameplates["clickthrough"] == "0" then
      frame:EnableMouse(true)
      if pfUI_config.nameplates["rightclick"] == "1" then
        frame:SetScript("OnMouseDown", function()
          if arg1 and arg1 == "RightButton" then
            MouselookStart()

            -- start detection of the rightclick emulation
            pfUI.nameplates.emulateRightClick.time = GetTime()
            pfUI.nameplates.emulateRightClick.frame = this
            pfUI.nameplates.emulateRightClick:Show()
          end
        end)
      end
    else
      frame:EnableMouse(false)
    end
  end

  -- debuff detection
  pfUI.nameplates:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.nameplates:RegisterEvent("UNIT_AURA")
  pfUI.nameplates:SetScript("OnEvent", function()
    pfUI.nameplates.debuffs = {}
    local i = 1
    local debuff = UnitDebuff("target", i)
    while debuff do
      pfUI.nameplates.debuffs[i] = debuff
      i = i + 1
      debuff = UnitDebuff("target", i)
    end
  end)

  -- combat tracker
  pfUI.nameplates.combat = CreateFrame("Frame")
  pfUI.nameplates.combat:RegisterEvent("PLAYER_ENTER_COMBAT")
  pfUI.nameplates.combat:RegisterEvent("PLAYER_LEAVE_COMBAT")
  pfUI.nameplates.combat:SetScript("OnEvent", function()
    if event == "PLAYER_ENTER_COMBAT" then
      this.inCombat = 1
    elseif event == "PLAYER_LEAVE_COMBAT" then
      this.inCombat = nil
    end
  end)

  -- emulate fake rightclick
  pfUI.nameplates.emulateRightClick = CreateFrame("Frame", nil, UIParent)
  pfUI.nameplates.emulateRightClick.time = nil
  pfUI.nameplates.emulateRightClick.frame = nil
  pfUI.nameplates.emulateRightClick:SetScript("OnUpdate", function()
    -- break here if nothing to do
    if not pfUI.nameplates.emulateRightClick.time or not pfUI.nameplates.emulateRightClick.frame then
      this:Hide()
      return
    end

    -- if threshold is reached (0.5 second) no click action will follow
    if not IsMouselooking() and pfUI.nameplates.emulateRightClick.time + tonumber(pfUI_config.nameplates["clickthreshold"]) < GetTime() then
      pfUI.nameplates.emulateRightClick:Hide()
      return
    end

    -- run a usual nameplate rightclick action
    if not IsMouselooking() then
      pfUI.nameplates.emulateRightClick.frame:Click("LeftButton")
      if UnitCanAttack("player", "target") and not pfUI.nameplates.combat.inCombat then AttackTarget() end
      pfUI.nameplates.emulateRightClick:Hide()
      return
    end
  end)
end)
