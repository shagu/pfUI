pfUI:RegisterModule("nameplates", function ()
  local font = C.nameplates.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
  local font_size = C.nameplates.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size

  pfUI.nameplates = CreateFrame("Frame", nil, UIParent)
  pfUI.nameplates.players = pfUI_playerDB
  pfUI.nameplates.mobs = {}
  pfUI.nameplates.targets = {}
  pfUI.nameplates.scanqueue = {}

  -- catch all nameplates
  pfUI.nameplates.scanner = CreateFrame("Frame", "pfNameplateScanner", UIParent)
  pfUI.nameplates.scanner.parentCount = 0
  pfUI.nameplates.scanner:SetScript("OnUpdate", function()
    local parentCount = WorldFrame:GetNumChildren()

    -- [[ scan nameplate frames ]]
    if pfUI.nameplates.scanner.parentCount < parentCount then
      pfUI.nameplates.scanner.parentCount = parentCount

      for _, nameplate in ipairs({WorldFrame:GetChildren()}) do
        if not nameplate.done and nameplate:GetObjectType() == "Button" then
          local regions = nameplate:GetRegions()
          if regions and regions:GetObjectType() == "Texture" and regions:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" then

            local visible = nameplate:IsVisible()
            nameplate:Hide()
            nameplate:SetScript("OnShow", pfUI.nameplates.OnShow)
            nameplate:SetScript("OnUpdate", pfUI.nameplates.OnUpdate)
            nameplate:SetAlpha(1)
            if visible then nameplate:Show() end
            nameplate.done = true
          end
        end
      end
    end

    -- [[ scan missing names ]]
    for index, name in pairs(pfUI.nameplates.scanqueue) do
      -- remove entry if already scanned
      if pfUI.nameplates.targets[name] == "OK" then
        table.remove(pfUI.nameplates.scanqueue, index)
      else
        if UnitName("mouseover") == name then
          if UnitIsPlayer("mouseover") then
            local _, class = UnitClass("mouseover")
            pfUI.nameplates.players[name] = {}
            pfUI.nameplates.players[name]["mouseover"] = class
          elseif UnitClassification("mouseover") then
            local elite = UnitClassification("mouseover")
            pfUI.nameplates.mobs[name] = elite
          end
          pfUI.nameplates.targets[name] = "OK"

        elseif not UnitName("target") then
          TargetByName(name, true)

          if UnitIsPlayer("target") then
            local _, class = UnitClass("target")
            pfUI.nameplates.players[name] = {}
            pfUI.nameplates.players[name]["class"] = class
          elseif UnitClassification("target") then
            local elite = UnitClassification("target")
            pfUI.nameplates.mobs[name] = elite
          end
          pfUI.nameplates.targets[name] = "OK"

          ClearTarget()
        end
      end
    end
  end)

  local plate_width = C.nameplates.width + 50
  local plate_height = C.nameplates.heighthealth + font_size + 5
  local plate_height_cast = C.nameplates.heighthealth + font_size + 5 + C.nameplates.heightcast + 5

  -- Create Nameplate
  function pfUI.nameplates:OnShow()
    -- initialize nameplate frames
    if not this.nameplate then
      this.nameplate = CreateFrame("Button", nil, this)
      this.nameplate.parent = this
      this.healthbar = this:GetChildren()
      this.border, this.glow, this.name, this.level, this.levelicon , this.raidicon = this:GetRegions()

      this.healthbar:SetParent(this.nameplate)
      this.border:SetParent(this.nameplate)
      this.glow:SetParent(this.nameplate)
      this.name:SetParent(this.nameplate)
      this.level:SetParent(this.nameplate)
      this.levelicon:SetParent(this.nameplate)
      this.raidicon:SetParent(this.healthbar)
    end

    -- init
    this:SetFrameLevel(0)
    this:EnableMouse(false)

    -- enable plate overlap
    if C.nameplates.overlap == "1" then
      this:SetWidth(1)
      this:SetHeight(1)
    else
      this:SetWidth(plate_width * UIParent:GetScale())
      this:SetHeight(plate_height * UIParent:GetScale())
    end

    -- set dimensions
    this.nameplate:SetScale(UIParent:GetScale())
    this.nameplate:SetWidth(plate_width)
    this.nameplate:SetHeight(plate_height)
    this.nameplate:SetPoint("TOP", this, "TOP", 0, -tonumber(C.nameplates.vpos))

    -- add click handlers
    if C.nameplates["clickthrough"] == "0" then
      this.nameplate:SetScript("OnClick", function() this.parent:Click() end)
      if C.nameplates["rightclick"] == "1" then
        this.nameplate:SetScript("OnMouseDown", function()
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
      this.nameplate:EnableMouse(false)
    end

    -- hide default plates
    this.border:Hide()

    -- remove glowing
    this.glow:Hide()
    this.glow:SetAlpha(0)
    this.glow.Show = function() return end

    -- name
    this.name:SetFont(font, font_size, "OUTLINE")
    this.name:ClearAllPoints()
    this.name:SetPoint("TOP", this.nameplate, "TOP", 0, 0)

    -- healthbar
    this.healthbar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    this.healthbar:ClearAllPoints()
    this.healthbar:SetPoint("TOP", this.name, "BOTTOM", 0, -3)
    this.healthbar:SetWidth(C.nameplates.width)
    this.healthbar:SetHeight(C.nameplates.heighthealth)

    if not this.healthbar.bg then
      this.healthbar.bg = this.healthbar:CreateTexture(nil, "BORDER")
      this.healthbar.bg:SetTexture(0,0,0,0.90)
      this.healthbar.bg:ClearAllPoints()
      this.healthbar.bg:SetPoint("CENTER", this.healthbar, "CENTER", 0, 0)
      this.healthbar.bg:SetWidth(this.healthbar:GetWidth() + 3)
      this.healthbar.bg:SetHeight(this.healthbar:GetHeight() + 3)
    end

    this.healthbar.reaction = nil

    -- level
    this.level:SetFont(font, font_size, "OUTLINE")
    this.level:ClearAllPoints()
    this.level:SetPoint("RIGHT", this.healthbar, "LEFT", 0, 0)
    this.level.needUpdate = true
    this.healthbar.needReactionUpdate = true

    -- adjust font
    this.levelicon:ClearAllPoints()
    this.levelicon:SetPoint("RIGHT", this.healthbar, "LEFT", -1, 0)

    -- raidtarget
    this.raidicon:ClearAllPoints()
    this.raidicon:SetWidth(C.nameplates.raidiconsize)
    this.raidicon:SetHeight(C.nameplates.raidiconsize)
    this.raidicon:SetPoint("CENTER", this.healthbar, "CENTER", 0, -5)
    this.raidicon:SetDrawLayer("OVERLAY")
    this.raidicon:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")

    -- add debuff frames
    if C.nameplates["showdebuffs"] == "1" then
      if not this.debuffs then this.debuffs = {} end
      for j=1, 16, 1 do
        if this.debuffs[j] == nil then
          this.debuffs[j] = this:CreateTexture(nil, "BORDER")
          this.debuffs[j]:SetTexture(0,0,0,0)
          this.debuffs[j]:ClearAllPoints()
          this.debuffs[j]:SetWidth(12)
          this.debuffs[j]:SetHeight(12)
          if j == 1 then
            this.debuffs[j]:SetPoint("TOPLEFT", this.healthbar, "BOTTOMLEFT", 0, -3)
          elseif j <= 8 then
            this.debuffs[j]:SetPoint("LEFT", this.debuffs[j-1], "RIGHT", 1, 0)
          elseif j > 8 then
            this.debuffs[j]:SetPoint("TOPLEFT", this.debuffs[1], "BOTTOMLEFT", (j-9) * 13, -1)
          end
        end
      end
    end

    -- add castbar
    if pfUI.castbar and C.nameplates["showcastbar"] == "1" then
      local plate = this

      if not this.healthbar.castbar then
        this.healthbar.castbar = CreateFrame("StatusBar", nil, this.healthbar)
        this.healthbar.castbar:Hide()
        this.healthbar.castbar:SetWidth(this.healthbar:GetWidth())
        this.healthbar.castbar:SetHeight(C.nameplates.heightcast)
        this.healthbar.castbar:SetPoint("TOPLEFT", this.healthbar, "BOTTOMLEFT", 0, -5)
        this.healthbar.castbar:SetBackdrop({  bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
                                               insets = {left = -1, right = -1, top = -1, bottom = -1} })
        this.healthbar.castbar:SetBackdropColor(0,0,0,1)
        this.healthbar.castbar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
        this.healthbar.castbar:SetStatusBarColor(.9,.8,0,1)

        plate.healthbar.castbar:SetScript("OnShow", function()
          plate:SetHeight(plate_height_cast * UIParent:GetScale())
          plate.nameplate:SetHeight(plate_height_cast)

          if plate.debuffs then
            plate.debuffs[1]:SetPoint("TOPLEFT", plate.healthbar.castbar, "BOTTOMLEFT", 0, -3)
          end
        end)

        this.healthbar.castbar:SetScript("OnHide", function()
          plate:SetHeight(plate_height * UIParent:GetScale())
          plate.nameplate:SetHeight(plate_height)

          if plate.debuffs then
            plate.debuffs[1]:SetPoint("TOPLEFT", plate.healthbar, "BOTTOMLEFT", 0, -3)
          end
        end)

        this.healthbar.castbar.bg = this.healthbar.castbar:CreateTexture(nil, "BACKGROUND")
        this.healthbar.castbar.bg:SetTexture(0,0,0,0.90)
        this.healthbar.castbar.bg:ClearAllPoints()
        this.healthbar.castbar.bg:SetPoint("CENTER", this.healthbar.castbar, "CENTER", 0, 0)
        this.healthbar.castbar.bg:SetWidth(this.healthbar.castbar:GetWidth() + 3)
        this.healthbar.castbar.bg:SetHeight(this.healthbar.castbar:GetHeight() + 3)

        this.healthbar.castbar.text = this.healthbar.castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
        this.healthbar.castbar.text:SetPoint("RIGHT", this.healthbar.castbar, "LEFT")
        this.healthbar.castbar.text:SetNonSpaceWrap(false)
        this.healthbar.castbar.text:SetFontObject(GameFontWhite)
        this.healthbar.castbar.text:SetTextColor(1,1,1,.5)
        this.healthbar.castbar.text:SetFont(font, font_size, "OUTLINE")

        this.healthbar.castbar.spell = this.healthbar.castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
        this.healthbar.castbar.spell:SetPoint("CENTER", this.healthbar.castbar, "CENTER")
        this.healthbar.castbar.spell:SetNonSpaceWrap(false)
        this.healthbar.castbar.spell:SetFontObject(GameFontWhite)
        this.healthbar.castbar.spell:SetTextColor(1,1,1,1)
        this.healthbar.castbar.spell:SetFont(font, font_size, "OUTLINE")

        this.healthbar.castbar.icon = this.healthbar.castbar:CreateTexture(nil, "BORDER")
        this.healthbar.castbar.icon:ClearAllPoints()
        this.healthbar.castbar.icon:SetPoint("BOTTOMLEFT", this.healthbar.castbar, "BOTTOMRIGHT", 5, 0)
        this.healthbar.castbar.icon:SetWidth(C.nameplates.heightcast + 5 + C.nameplates.heighthealth)
        this.healthbar.castbar.icon:SetHeight(C.nameplates.heightcast + 5 + C.nameplates.heighthealth)

        this.healthbar.castbar.icon.bg = this.healthbar.castbar:CreateTexture(nil, "BACKGROUND")
        this.healthbar.castbar.icon.bg:SetTexture(0,0,0,0.90)
        this.healthbar.castbar.icon.bg:ClearAllPoints()
        this.healthbar.castbar.icon.bg:SetPoint("CENTER", this.healthbar.castbar.icon, "CENTER", 0, 0)
        this.healthbar.castbar.icon.bg:SetWidth(this.healthbar.castbar.icon:GetWidth() + 3)
        this.healthbar.castbar.icon.bg:SetHeight(this.healthbar.castbar.icon:GetHeight() + 3)
      end
    end

    if C.nameplates.showhp == "1" and not this.healthbar.hptext then
      this.healthbar.hptext = this.healthbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      this.healthbar.hptext:SetPoint("RIGHT", this.healthbar, "RIGHT")
      this.healthbar.hptext:SetNonSpaceWrap(false)
      this.healthbar.hptext:SetFontObject(GameFontWhite)
      this.healthbar.hptext:SetTextColor(1,1,1,1)
      this.healthbar.hptext:SetFont(font, font_size)
    end

    if C.nameplates.players == "1" then
      if pfUI.nameplates.targets[this.name:GetText()] == "OK" then
        if not pfUI.nameplates.players[this.name:GetText()] then this:Hide() end
      end
    end

    this.needNameUpdate = true
    this.needClassColorUpdate = true
    this.needLevelColorUpdate = true
    this.needEliteUpdate = true

    this.setup = true
  end

  -- Nameplate OnUpdate
  function pfUI.nameplates:OnUpdate()
    if not this.setup then pfUI.nameplates:OnShow() return end

    local healthbar = this.healthbar
    local border, glow, name, level, levelicon , raidicon = this.border, this.glow, this.name, this.level, this.levelicon , this.raidicon

    -- add scan entry if not existing
    if this.needNameUpdate and name:GetText() ~= UNKNOWN then
      if not pfUI.nameplates.targets[this.name:GetText()] then
        table.insert(pfUI.nameplates.scanqueue, this.name:GetText())
      end
      this.needNameUpdate = nil
    end

    -- hide non-player frames
    if C.nameplates.players == "1" and not this.needNameUpdate then
      if pfUI.nameplates.targets[name:GetText()] == "OK" then
        if not pfUI.nameplates.players[name:GetText()] then this:Hide() end
      end
    end

    -- hide critters
    if C.nameplates.critters == "1" and not this.needNameUpdate then
      local red, green, blue, _ = healthbar:GetStatusBarColor()
      local name_val = name:GetText()
      for i, critter_val in pairs(L["critters"]) do
        if red > 0.9 and green > 0.9 and blue < 0.2 and name_val == critter_val then
          this:Hide()
        end
      end
    end

    -- level elite indicator
    if this.needEliteUpdate and pfUI.nameplates.mobs[name:GetText()] then
      if level:GetText() ~= nil then
        if pfUI.nameplates.mobs[name:GetText()] == "elite" then
          level:SetText(level:GetText() .. "+")
        elseif pfUI.nameplates.mobs[name:GetText()] == "rareelite" then
          level:SetText(level:GetText() .. "R+")
        elseif pfUI.nameplates.mobs[name:GetText()] == "rare" then
          level:SetText(level:GetText() .. "R")
        end
      end
      this.needEliteUpdate = nil
    end

    -- level colors
    if this.needLevelColorUpdate then
      local red, green, blue, _ = level:GetTextColor()
      if red > 0.99 and green == 0 and blue == 0 then
        level:SetTextColor(1,0.4,0.2,0.85)
      elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
        level:SetTextColor(1,1,1,0.85)
      end
      this.needLevelColorUpdate = nil
    end

    -- healtbar: update colors
    local red, green, blue, _ = healthbar:GetStatusBarColor()
    if red ~= healthbar.wantR or green ~= healthbar.wantG or blue ~= healthbar.wantB then
      -- set reaction color
      -- reaction: 0 enemy ; 1 neutral ; 2 player ; 3 npc
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

      healthbar.wantR, healthbar.wantG, healthbar.wantB  = healthbar:GetStatusBarColor()
      this.needClassColorUpdate = true
    end

    -- add class colors
    if this.needClassColorUpdate and pfUI.nameplates.targets[name:GetText()] == "OK" then
      -- show class names?
      if healthbar.reaction == 0 then
        if C.nameplates["enemyclassc"] == "1"
        and pfUI.nameplates.players[name:GetText()]
        and pfUI.nameplates.players[name:GetText()]["class"]
        and RAID_CLASS_COLORS[pfUI.nameplates.players[name:GetText()]["class"]]
        then
          healthbar:SetStatusBarColor(
            RAID_CLASS_COLORS[pfUI.nameplates.players[name:GetText()]["class"]].r,
            RAID_CLASS_COLORS[pfUI.nameplates.players[name:GetText()]["class"]].g,
            RAID_CLASS_COLORS[pfUI.nameplates.players[name:GetText()]["class"]].b,
            0.9)
        end
      elseif healthbar.reaction == 2 then
        if C.nameplates["friendclassc"] == "1"
        and pfUI.nameplates.players[name:GetText()]
        and pfUI.nameplates.players[name:GetText()]["class"]
        and RAID_CLASS_COLORS[pfUI.nameplates.players[name:GetText()]["class"]]
        then
          healthbar:SetStatusBarColor(
            RAID_CLASS_COLORS[pfUI.nameplates.players[name:GetText()]["class"]].r,
            RAID_CLASS_COLORS[pfUI.nameplates.players[name:GetText()]["class"]].g,
            RAID_CLASS_COLORS[pfUI.nameplates.players[name:GetText()]["class"]].b,
            0.9)
        end
      end

      healthbar.wantR, healthbar.wantG, healthbar.wantB  = healthbar:GetStatusBarColor()
      this.needClassColorUpdate = nil
    end

    -- name color
    local red, green, blue, _ = name:GetTextColor()
    if red > 0.99 and green == 0 and blue == 0 then
      name:SetTextColor(1,0.4,0.2,0.85)
    elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
      name:SetTextColor(1,1,1,0.85)
    end

    -- show castbar
    if healthbar.castbar and pfUI.castbar and C.nameplates["showcastbar"] == "1" and pfUI.castbar.target.casterDB[name:GetText()] ~= nil and pfUI.castbar.target.casterDB[name:GetText()]["cast"] ~= nil then
      if pfUI.castbar.target.casterDB[name:GetText()]["starttime"] + pfUI.castbar.target.casterDB[name:GetText()]["casttime"] <= GetTime() then
        pfUI.castbar.target.casterDB[name:GetText()] = nil
        healthbar.castbar:Hide()
      else
        healthbar.castbar:SetMinMaxValues(0,  pfUI.castbar.target.casterDB[name:GetText()]["casttime"])
        healthbar.castbar:SetValue(GetTime() -  pfUI.castbar.target.casterDB[name:GetText()]["starttime"])
        healthbar.castbar.text:SetText(round( pfUI.castbar.target.casterDB[name:GetText()]["starttime"] +  pfUI.castbar.target.casterDB[name:GetText()]["casttime"] - GetTime(),1))
        if C.nameplates.spellname == "1" and healthbar.castbar.spell then
          healthbar.castbar.spell:SetText(pfUI.castbar.target.casterDB[name:GetText()]["cast"])
        else
          healthbar.castbar.spell:SetText("")
        end
        healthbar.castbar:Show()
        if this.debuffs then
          this.debuffs[1]:SetPoint("TOPLEFT", healthbar.castbar, "BOTTOMLEFT", 0, -3)
        end

        if pfUI.castbar.target.casterDB[name:GetText()]["icon"] then
          healthbar.castbar.icon:SetTexture("Interface\\Icons\\" ..  pfUI.castbar.target.casterDB[name:GetText()]["icon"])
          healthbar.castbar.icon:SetTexCoord(.1,.9,.1,.9)
        end
      end
    else
      healthbar.castbar:Hide()
      if this.debuffs then
        this.debuffs[1]:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -3)
      end
    end

    -- update debuffs
    if this.debuffs and C.nameplates["showdebuffs"] == "1" then
      if UnitExists("target") and healthbar:GetAlpha() == 1 then
        local j = 1
        local k = 1
        for j, e in ipairs(pfUI.nameplates.debuffs) do
          this.debuffs[j]:SetTexture(pfUI.nameplates.debuffs[j])
          this.debuffs[j]:SetTexCoord(.078, .92, .079, .937)
          this.debuffs[j]:SetAlpha(0.9)
          k = k + 1
        end
        for j = k, 16, 1 do
          this.debuffs[j]:SetTexture(nil)
        end
      elseif this.debuffs then
        for j = 1, 16, 1 do
          this.debuffs[j]:SetTexture(nil)
        end
      end
    end

    -- show hp text
    if C.nameplates.showhp == "1" and healthbar.hptext then
      local min, max = healthbar:GetMinMaxValues()
      local cur = healthbar:GetValue()
      healthbar.hptext:SetText(cur .. " / " .. max)
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
    if not IsMouselooking() and pfUI.nameplates.emulateRightClick.time + tonumber(C.nameplates["clickthreshold"]) < GetTime() then
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
