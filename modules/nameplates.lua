pfUI:RegisterModule("nameplates", "vanilla:tbc", function ()
  local font = C.nameplates.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
  local font_size = C.nameplates.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size
  local inactive_alpha = tonumber(C.nameplates.notargalpha)
  local glowr, glowg, glowb, glowa = GetStringColor(C.nameplates.glowcolor)
  local hptexture = pfUI.media[C.nameplates.healthtexture]

  pfUI.nameplates = CreateFrame("Frame", nil, UIParent)

  -- catch all nameplates
  local childs
  local regions
  local nameplate
  local initialized = 0
  local parentCount = 0

  pfUI.nameplates.scanner = CreateFrame("Frame", "pfNameplateScanner", UIParent)
  pfUI.nameplates.scanner:SetScript("OnUpdate", function()
    parentCount = WorldFrame:GetNumChildren()
    if initialized < parentCount then
      childs = { WorldFrame:GetChildren() }

      for i=initialized + 1, parentCount do
        nameplate = childs[i]
        if nameplate:GetObjectType() == NAMEPLATE_FRAMETYPE then
          regions = nameplate:GetRegions()
          if regions and regions:GetObjectType() == "Texture" and regions:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" then
            local visible = nameplate:IsVisible()
            nameplate:Hide()
            nameplate:SetScript("OnShow", pfUI.nameplates.OnShow)
            nameplate:SetScript("OnUpdate", pfUI.nameplates.OnUpdate)
            nameplate:SetAlpha(1)
            if visible then nameplate:Show() end
          end
        end
      end

      initialized = parentCount
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
      this.healthbar:SetScript("OnEnter", function() return nil end)
      for i, frame in pairs({this:GetRegions()}) do
        if NAMEPLATE_OBJECTORDER[i] == "_" then
          frame.Show = function() return end
          frame:Hide()
        elseif NAMEPLATE_OBJECTORDER[i] then
          this[NAMEPLATE_OBJECTORDER[i]] = frame
        end
      end

      this.healthbar:SetParent(this.nameplate)
      this.border:SetParent(this.nameplate)
      this.glow:SetParent(this.nameplate)
      this.name:SetParent(this.nameplate)
      this.level:SetParent(this.nameplate)
      this.levelicon:SetParent(this.nameplate)
      this.raidicon:SetParent(this.healthbar)
    end

    -- init
    if C.nameplates["legacy"] == "0" then
      this:SetFrameLevel(0)
      this:EnableMouse(false)
    end

    -- enable plate overlap
    if C.nameplates.overlap == "1" and C.nameplates["legacy"] == "0" then
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
    if C.nameplates["legacy"] == "0" then
      this.nameplate:SetPoint("TOP", this, "TOP", 0, -tonumber(C.nameplates.vpos))
    else
      this.nameplate:SetPoint("TOP", this, "TOP", 0, 0)
    end

    -- add click handlers
    if C.nameplates["clickthrough"] == "0" then
      if C.nameplates["legacy"] == "0" and pfUI.client < 20000 then
        this.nameplate:SetScript("OnClick", function() this.parent:Click() end)
      else
        this.nameplate:EnableMouse(false)
      end

      if C.nameplates["rightclick"] == "1" then
        local plate = C.nameplates["legacy"] == "0" and this.nameplate or this
        plate:SetScript("OnMouseDown", function()
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
      this:EnableMouse(false)
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
    this.healthbar:SetStatusBarTexture(hptexture)
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

    if not this.healthbar.bgtarget then
      this.healthbar.bgtarget = this.healthbar:CreateTexture(nil, "BACKGROUND")
      this.healthbar.bgtarget:SetTexture(1,1,1,.8)
      this.healthbar.bgtarget:ClearAllPoints()
      this.healthbar.bgtarget:SetPoint("CENTER", this.healthbar, "CENTER", 0, 0)
      this.healthbar.bgtarget:SetWidth(this.healthbar:GetWidth() + 5)
      this.healthbar.bgtarget:SetHeight(this.healthbar:GetHeight() + 5)
    end

    if not this.healthbar.glowtarget then
      this.healthbar.glowtarget = this.nameplate:CreateTexture(nil, "BACKGROUND")
      this.healthbar.glowtarget:SetTexture(pfUI.media["img:dot"])
      this.healthbar.glowtarget:ClearAllPoints()
      this.healthbar.glowtarget:SetPoint("CENTER", this.healthbar, "CENTER", 0, 0)
      this.healthbar.glowtarget:SetWidth(this.healthbar:GetWidth() + 50)
      this.healthbar.glowtarget:SetHeight(this.healthbar:GetHeight() + 25)
      this.healthbar.glowtarget:SetVertexColor(glowr, glowg, glowb, glowa)
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
    this.raidicon:SetTexture(pfUI.media["img:raidicons"])

    -- add debuff frames
    if C.nameplates["showdebuffs"] == "1" then
      if not this.debuffs then this.debuffs = {} end
      for j=1, 16, 1 do
        if this.debuffs[j] == nil then
          this.debuffs[j] = CreateFrame("Frame", nil, this.nameplate)
          this.debuffs[j]:ClearAllPoints()
          this.debuffs[j]:SetWidth(18)
          this.debuffs[j]:SetHeight(18)
          if j == 1 then
            this.debuffs[j]:SetPoint("TOPLEFT", this.healthbar, "BOTTOMLEFT", 0, -3)
          elseif j <= 8 then
            this.debuffs[j]:SetPoint("LEFT", this.debuffs[j-1], "RIGHT", 1, 0)
          elseif j > 8 then
            this.debuffs[j]:SetPoint("TOPLEFT", this.debuffs[j-8], "BOTTOMLEFT", 0, -1)
          end

          this.debuffs[j].icon = this.debuffs[j]:CreateTexture(nil, "BORDER")
          this.debuffs[j].icon:SetTexture(0,0,0,0)
          this.debuffs[j].icon:SetAllPoints(this.debuffs[j])
        end
      end
    end

    -- combopoints
    if C.nameplates.cpdisplay == "1" then
      local combo_size = 5
      local offset = 5 + C.nameplates.heightcast + C.nameplates.heighthealth + C.appearance.border.default*2

      if not this.combopoints then
        this.combopoints = CreateFrame("Frame", nil, this.nameplate)
        for point=1, 5 do
          if not this.combopoints["combopoint" .. point] then
            this.combopoints["combopoint" .. point] = CreateFrame("Frame", "pfNameplateCombo" .. point, this.nameplate)
            this.combopoints["combopoint" .. point]:SetFrameStrata("HIGH")
            this.combopoints["combopoint" .. point]:SetWidth(combo_size)
            this.combopoints["combopoint" .. point]:SetHeight(combo_size)
          end

          CreateBackdrop(this.combopoints["combopoint" .. point])
          this.combopoints["combopoint" .. point]:SetPoint("BOTTOMRIGHT", this.nameplate, "BOTTOMRIGHT", -(point - 1) * (combo_size + C.appearance.border.default*3) - offset, -C.appearance.border.default*3)

          if point < 3 then
            local tex = this.combopoints["combopoint" .. point]:CreateTexture("OVERLAY")
            tex:SetAllPoints(this.combopoints["combopoint" .. point])
            tex:SetTexture(1, .3, .3, .75)
          elseif point < 4 then
            local tex = this.combopoints["combopoint" .. point]:CreateTexture("OVERLAY")
            tex:SetAllPoints(this.combopoints["combopoint" .. point])
            tex:SetTexture(1, 1, .3, .75)
          else
            local tex = this.combopoints["combopoint" .. point]:CreateTexture("OVERLAY")
            tex:SetAllPoints(this.combopoints["combopoint" .. point])
            tex:SetTexture(.3, 1, .3, .75)
          end
          this.combopoints["combopoint" .. point]:Hide()
        end
      end
    end

    -- add castbar
    if pfUI.castbar and C.nameplates["showcastbar"] == "1" then
      local plate = this

      if not this.healthbar.castbar then
        this.healthbar.castbar = CreateFrame("StatusBar", nil, this.healthbar)
        this.healthbar.castbar:Hide()
        this.healthbar.castbar:SetHeight(C.nameplates.heightcast)
        this.healthbar.castbar:SetPoint("TOPLEFT", this.healthbar, "BOTTOMLEFT", 0, -5)
        this.healthbar.castbar:SetPoint("TOPRIGHT", this.healthbar, "BOTTOMRIGHT", 0, -5)
        this.healthbar.castbar:SetBackdrop({  bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
                                               insets = {left = -1, right = -1, top = -1, bottom = -1} })
        this.healthbar.castbar:SetBackdropColor(0,0,0,1)
        this.healthbar.castbar:SetStatusBarTexture(pfUI.media["img:bar"])
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
        this.healthbar.castbar.icon:SetPoint("BOTTOMLEFT", this.healthbar.castbar, "BOTTOMRIGHT", 5, -1)
        this.healthbar.castbar.icon:SetPoint("TOPLEFT", this.healthbar, "TOPRIGHT", 5, 1)
        this.healthbar.castbar.icon:SetWidth(C.nameplates.heightcast + 8 + C.nameplates.heighthealth)

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
      local _, _, _, uplayer = GetUnitData(this.name:GetText(), true)
      if uplayer then this:Hide() end
    end

    this.needClassColorUpdate = true
    this.needBasicColorUpdate = true
    this.needEliteUpdate = true

    this.setup = true
  end

  -- Nameplate OnUpdate
  function pfUI.nameplates:OnUpdate()
    if not this.setup then pfUI.nameplates:OnShow() return end

    -- set nameplate alpha
    if this:GetAlpha() < inactive_alpha then this:SetAlpha(inactive_alpha) end

    local healthbar = this.healthbar
    local border, glow, name, level, levelicon , raidicon, combopoints = this.border, this.glow, this.name, this.level, this.levelicon , this.raidicon, this.combopoints
    local unitname = name:GetText()
    local uclass, ulevel, uelite, uplayer = GetUnitData(unitname, true)

    if unitname == UNKNOWN then
      this.needClassColorUpdate = true
      this.needBasicColorUpdate = true
      this.needEliteUpdate = true
    end

    -- hide non-player frames
    if C.nameplates.players == "1" then
      if uplayer then this:Hide() end
    end

    -- hide critters
    if C.nameplates.critters == "1" then
      local red, green, blue, _ = healthbar:GetStatusBarColor()
      local name_val = unitname
      for i, critter_val in pairs(L["critters"]) do
        if red > 0.9 and green > 0.9 and blue < 0.2 and name_val == critter_val then
          this:Hide()
        end
      end
    end

    -- hide totems
    if C.nameplates.totems == "1" then
      for totem in pairs(L["totems"]) do
        if string.find(unitname, totem) then
          this:Hide()
        end
      end
    end

    -- disable click events while spell is targeting
    local mouseEnabled = this.nameplate:IsMouseEnabled()
    if C.nameplates["clickthrough"] == "0" and C.nameplates["legacy"] == "0" and SpellIsTargeting() == mouseEnabled then
      this.nameplate:EnableMouse(not mouseEnabled)
    end

    -- level elite indicator
    if this.needEliteUpdate and uelite then
      if level:GetText() ~= nil then
        if uelite == "elite" then
          level:SetText(level:GetText() .. "+")
        elseif uelite == "rareelite" then
          level:SetText(level:GetText() .. "R+")
        elseif uelite == "rare" then
          level:SetText(level:GetText() .. "R")
        end
      end
      this.needEliteUpdate = nil
    end

    -- level colors
    if this.needBasicColorUpdate then
      local red, green, blue, _ = level:GetTextColor()
      if red > 0.99 and green == 0 and blue == 0 then
        level:SetTextColor(1,0.4,0.2,0.85)
      elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
        level:SetTextColor(1,1,1,0.85)
      end

      -- healthbar: update colors
      local red, green, blue, _ = healthbar:GetStatusBarColor()
      -- reaction: 0 enemy ; 1 neutral ; 2 player ; 3 npc
      if red > 0.9 and green < 0.2 and blue < 0.2 then
        healthbar.reaction = 0
        healthbar.r, healthbar.g, healthbar.b, healthbar.a = .9, .2, .3, .8
      elseif red > 0.9 and green > 0.9 and blue < 0.2 then
        healthbar.reaction = 1
        healthbar.r, healthbar.g, healthbar.b, healthbar.a = 1, 1, .3, .8
      elseif ( blue > 0.9 and red == 0 and green == 0 ) then
        healthbar.reaction = 2
        healthbar.r, healthbar.g, healthbar.b, healthbar.a = .2, .6, 1, .8
      elseif red == 0 and green > 0.99 and blue == 0 then
        healthbar.reaction = 3
        healthbar.r, healthbar.g, healthbar.b, healthbar.a = .6, 1, 0, .8
      end

      this.needBasicColorUpdate = nil
    end

    -- add class colors
    if this.needClassColorUpdate and uplayer and uclass then
      if healthbar.reaction == 0 then
        if C.nameplates["enemyclassc"] == "1" and RAID_CLASS_COLORS[uclass] then
          local color = RAID_CLASS_COLORS[uclass]
          healthbar.r, healthbar.g, healthbar.b, healthbar.a = color.r, color.g, color.b, .9
        end
      elseif healthbar.reaction == 2 then
        if C.nameplates["friendclassc"] == "1" and RAID_CLASS_COLORS[uclass] then
          local color = RAID_CLASS_COLORS[uclass]
          healthbar.r, healthbar.g, healthbar.b, healthbar.a = color.r, color.g, color.b, .9
        end
      end

      this.needClassColorUpdate = nil
    end

    -- color changes are done within the C-API, we need to overwrite on each paint
    healthbar:SetStatusBarColor(healthbar.r, healthbar.g, healthbar.b, healthbar.a)

    -- name color
    local red, green, blue, _ = name:GetTextColor()
    if red > 0.99 and green == 0 and blue == 0 then
      name:SetTextColor(1,0.4,0.2,0.85)
    elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
      name:SetTextColor(1,1,1,0.85)
    end

    -- target indicator
    if UnitExists("target") and healthbar:GetAlpha() == 1 and C.nameplates.targethighlight == "1" then
      healthbar.bgtarget:Show()
    else
      healthbar.bgtarget:Hide()
    end

    -- glow target indicator
    if UnitExists("target") and healthbar:GetAlpha() == 1 and C.nameplates.targetglow == "1" then
      healthbar.glowtarget:Show()
    else
      healthbar.glowtarget:Hide()
    end

    -- target zoom
    local w, h = healthbar:GetWidth(), healthbar:GetHeight()
    if UnitExists("target") and healthbar:GetAlpha() == 1 and C.nameplates.targetzoom == "1" then
      local wc = tonumber(C.nameplates.width)*1.4
      local hc = tonumber(C.nameplates.heighthealth)*1.3
      local animation = false

      if wc >= w then
        wc = w*1.05
        healthbar:SetWidth(wc)
        healthbar.bg:SetWidth(wc + 3)
        healthbar.bgtarget:SetWidth(wc + 5)
        healthbar.zoomTransition = true
        animation = true
      end

      if hc >= h then
        hc = h*1.05
        healthbar:SetHeight(hc)
        healthbar.bg:SetHeight(hc + 3)
        healthbar.bgtarget:SetHeight(hc + 5)
        healthbar.zoomTransition = true
        animation = true
      end

      if animation == false and not healthbar.zoomed then
        healthbar:SetWidth(wc)
        healthbar.bg:SetWidth(wc + 3)
        healthbar.bgtarget:SetWidth(wc + 5)

        healthbar:SetHeight(hc)
        healthbar.bg:SetHeight(hc + 3)
        healthbar.bgtarget:SetHeight(hc + 5)

        healthbar.zoomTransition = nil
        healthbar.zoomed = true
      end
    elseif healthbar.zoomed or healthbar.zoomTransition then
      local wc = tonumber(C.nameplates.width)
      local hc = tonumber(C.nameplates.heighthealth)
      local animation = false

      if wc <= w then
        wc = w*.95
        healthbar:SetWidth(wc)
        healthbar.bg:SetWidth(wc + 3)
        healthbar.bgtarget:SetWidth(wc + 5)
        animation = true
      end

      if hc <= h then
        hc = h*0.95
        healthbar:SetHeight(hc)
        healthbar.bg:SetHeight(hc + 3)
        healthbar.bgtarget:SetHeight(hc + 5)
        animation = true
      end

      if animation == false then
        healthbar:SetWidth(wc)
        healthbar.bg:SetWidth(wc + 3)
        healthbar.bgtarget:SetWidth(wc + 5)

        healthbar:SetHeight(hc)
        healthbar.bg:SetHeight(hc + 3)
        healthbar.bgtarget:SetHeight(hc + 5)

        healthbar.zoomTransition = nil
        healthbar.zoomed = nil
      end
    end

    -- update combopoints
    if combopoints and C.nameplates.cpdisplay == "1" then
      for point=1, 5 do
        combopoints["combopoint" .. point]:Hide()
      end

      local cp = GetComboPoints("target")
      if GetUnitName("target") == unitname and healthbar:GetAlpha() == 1 and cp > 0 then
        for point=1, cp do
          combopoints["combopoint" .. point]:Show()
        end
      end
    end

    -- show castbar
    if healthbar.castbar and pfUI.castbar and C.nameplates["showcastbar"] == "1" then
      local cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unitname)

      if not cast then
        healthbar.castbar:Hide()
      else
        local duration = endTime - startTime
        healthbar.castbar:SetMinMaxValues(0,  duration/1000)
        healthbar.castbar:SetValue(GetTime() - startTime/1000)
        healthbar.castbar.text:SetText(round(startTime/1000 + duration/1000 - GetTime(),1))
        if C.nameplates.spellname == "1" and healthbar.castbar.spell then
          healthbar.castbar.spell:SetText(cast)
        else
          healthbar.castbar.spell:SetText("")
        end
        healthbar.castbar:Show()
        if this.debuffs then
          this.debuffs[1]:SetPoint("TOPLEFT", healthbar.castbar, "BOTTOMLEFT", 0, -3)
        end

        if icon then
          healthbar.castbar.icon:SetTexture(texture)
          healthbar.castbar.icon:SetTexCoord(.1,.9,.1,.9)
        end
      end
    else
      if healthbar.castbar then
        healthbar.castbar:Hide()
      end

      if this.debuffs then
        this.debuffs[1]:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -3)
      end
    end

    -- update debuffs
    if this.debuffs and pfUI.nameplates.debuffs and C.nameplates["showdebuffs"] == "1" then
      if UnitExists("target") and healthbar:GetAlpha() == 1 then
        local j = 1
        local k = 1
        for j, e in ipairs(pfUI.nameplates.debuffs) do
          local icon, name = unpack(pfUI.nameplates.debuffs[j])
          this.debuffs[j]:Show()
          this.debuffs[j].icon:SetTexture(icon)
          this.debuffs[j].icon:SetTexCoord(.078, .92, .079, .937)

          if icon then
            this.debuffs[j].cd = this.debuffs[j].cd or CreateFrame(COOLDOWN_FRAME_TYPE, nil, this.debuffs[j], "CooldownFrameTemplate")
            this.debuffs[j].cd.pfCooldownType = "ALL"

            local name, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff("target", j)
            if duration and timeleft then
              this.debuffs[j].cd:SetAlpha(0)
              CooldownFrame_SetTimer(this.debuffs[j].cd, GetTime() + timeleft - duration, duration, 1)
            end
          end

          k = k + 1
        end
        for j = k, 16, 1 do
          this.debuffs[j]:Hide()
        end
      elseif this.debuffs then
        for j = 1, 16, 1 do
          this.debuffs[j]:Hide()
        end
      end
    end

    -- show hp text
    if C.nameplates.showhp == "1" and healthbar.hptext then
      local min, max = healthbar:GetMinMaxValues()
      local cur = healthbar:GetValue()
      if (MobHealth3 or MobHealthFrame) and unitname == UnitName('target') and healthbar:GetAlpha() == 1 and MobHealth_GetTargetCurHP() then
        cur, max = MobHealth_GetTargetCurHP(), MobHealth_GetTargetMaxHP()
      end
      healthbar.hptext:SetText(cur .. " / " .. max)
    end
  end

  pfUI.nameplates:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.nameplates:RegisterEvent("UNIT_AURA")
  pfUI.nameplates:SetScript("OnEvent", function()
    if not arg1 or arg1 == "target" then
      pfUI.nameplates.debuffs = {}
      for i = 1, 16 do
        if not UnitDebuff("target", i) then return end
        local name, _, texture = libdebuff:UnitDebuff("target", i)
        pfUI.nameplates.debuffs[i] = { texture, name }
      end
    end
  end)

  -- combat tracker
  pfUI.nameplates.combat = CreateFrame("Frame")
  pfUI.nameplates.combat:RegisterEvent("PLAYER_ENTER_COMBAT")
  pfUI.nameplates.combat:RegisterEvent("PLAYER_LEAVE_COMBAT")
  pfUI.nameplates.combat:SetScript("OnEvent", function()
    if event == "PLAYER_ENTER_COMBAT" then
      this.inCombat = 1
      if PlayerFrame then PlayerFrame.inCombat = 1 end
    elseif event == "PLAYER_LEAVE_COMBAT" then
      this.inCombat = nil
      if PlayerFrame then PlayerFrame.inCombat = nil end
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
