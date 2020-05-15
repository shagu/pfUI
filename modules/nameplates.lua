pfUI:RegisterModule("nameplates", "vanilla:tbc", function ()
  -- disable original castbars
  pcall(SetCVar, "ShowVKeyCastbar", 0)

  local unitcolors = {
    ["ENEMY_NPC"] = { .9, .2, .3, .8 },
    ["NEUTRAL_NPC"] = { 1, 1, .3, .8 },
    ["FRIENDLY_NPC"] = { .6, 1, 0, .8 },
    ["ENEMY_PLAYER"] = { .9, .2, .3, .8 },
    ["FRIENDLY_PLAYER"] = { .2, .6, 1, .8 }
  }

  local elitestrings = {
    ["elite"] = "+",
    ["rareelite"] = "R+",
    ["rare"] = "R",
    ["boss"] = "B"
  }

  -- catch all nameplates
  local childs, regions, plate
  local initialized = 0
  local parentCount = 0
  local registry = {}

  local function IsNamePlate(frame)
    if frame:GetObjectType() ~= NAMEPLATE_FRAMETYPE then return nil end
    regions = plate:GetRegions()

    if not regions then return nil end
    if not regions.GetObjectType then return nil end
    if not regions.GetTexture then return nil end

    if regions:GetObjectType() ~= "Texture" then return nil end
    return regions:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" or nil
  end

  local function DisableObject(object)
    if not object then return end
    if not object.GetObjectType then return end

    local otype = object:GetObjectType()

    if otype == "Texture" then
      object:SetTexture("")
      object:SetTexCoord(0, 0, 0, 0)
    elseif otype == "FontString" then
      object:SetWidth(0.001)
    elseif otype == "StatusBar" then
      object:SetStatusBarTexture("")
    end
  end

  local function HidePlate(unittype, name, fullhp, target)
    -- keep some plates always visible according to config
    if C.nameplates.fullhealth == "1" and not fullhp then return nil end
    if C.nameplates.target == "1" and target then return nil end

    -- return true when something needs to be hidden
    if C.nameplates.enemynpc == "1" and unittype == "ENEMY_NPC" then
      return true
    elseif C.nameplates.enemyplayer == "1" and unittype == "ENEMY_PLAYER" then
      return true
    elseif C.nameplates.neutralnpc == "1" and unittype == "NEUTRAL_NPC" then
      return true
    elseif C.nameplates.friendlynpc == "1" and unittype == "FRIENDLY_NPC" then
      return true
    elseif C.nameplates.friendlyplayer == "1" and unittype == "FRIENDLY_PLAYER" then
      return true
    elseif C.nameplates.critters == "1" and unittype == "NEUTRAL_NPC" then
      for i, critter in pairs(L["critters"]) do
        if string.find(name, critter) then return true end
      end
    elseif C.nameplates.totems == "1" then
      for totem in pairs(L["totems"]) do
        if string.find(name, totem) then return true end
      end
    end

    -- nothing to hide
    return nil
  end

  local function GetUnitType(red, green, blue)
    if red > .9 and green < .2 and blue < .2 then
      return "ENEMY_NPC"
    elseif red > .9 and green > .9 and blue < .2 then
      return "NEUTRAL_NPC"
    elseif red < .2 and green < .2 and blue > 0.9 then
      return "FRIENDLY_PLAYER"
    elseif red < .2 and green > .9 and blue < .2 then
      return "FRIENDLY_NPC"
    end
  end

  -- create nameplate core
  local nameplates = CreateFrame("Frame", "pfNameplates", UIParent)
  nameplates:SetScript("OnUpdate", function()
    parentCount = WorldFrame:GetNumChildren()
    if initialized < parentCount then
      childs = { WorldFrame:GetChildren() }
      for i = initialized + 1, parentCount do
        plate = childs[i]
        if IsNamePlate(plate) and not registry[plate] then
          nameplates.OnCreate(plate)
          registry[plate] = plate
        end
      end

      initialized = parentCount
    end
  end)

  -- combat tracker
  nameplates.combat = CreateFrame("Frame")
  nameplates.combat:RegisterEvent("PLAYER_ENTER_COMBAT")
  nameplates.combat:RegisterEvent("PLAYER_LEAVE_COMBAT")
  nameplates.combat:SetScript("OnEvent", function()
    if event == "PLAYER_ENTER_COMBAT" then
      this.inCombat = 1
      if PlayerFrame then PlayerFrame.inCombat = 1 end
    elseif event == "PLAYER_LEAVE_COMBAT" then
      this.inCombat = nil
      if PlayerFrame then PlayerFrame.inCombat = nil end
    end
  end)

  nameplates.OnCreate = function(frame)
    local parent = frame or this

    -- create pfUI nameplate overlay
    local nameplate = CreateFrame("Button", nil, parent)
    nameplate:EnableMouse(0)
    nameplate.parent = parent
    nameplate.cache = {}

    -- create shortcuts for all known elements and disable them
    parent.healthbar, parent.castbar = parent:GetChildren()
    DisableObject(parent.healthbar)
    DisableObject(parent.castbar)

    for i, object in pairs({parent:GetRegions()}) do
      if NAMEPLATE_OBJECTORDER[i] and NAMEPLATE_OBJECTORDER[i] == "raidicon" then
        nameplate[NAMEPLATE_OBJECTORDER[i]] = object
      else
        parent[NAMEPLATE_OBJECTORDER[i]] = object
        DisableObject(object)
      end
    end

    HookScript(parent.healthbar, "OnValueChanged", nameplates.OnValueChanged)

    -- adjust sizes and scaling of the nameplate
    nameplate:SetScale(UIParent:GetScale())

    nameplate.name = nameplate:CreateFontString(nil, "OVERLAY")
    nameplate.name:SetPoint("TOP", nameplate, "TOP", 0, 0)

    nameplate.health = CreateFrame("StatusBar", nil, nameplate)
    nameplate.health:SetPoint("TOP", nameplate.name, "BOTTOM", 0, -3)
    nameplate.health:SetFrameLevel(4) -- keep above glow
    nameplate.health.text = nameplate.health:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameplate.health.text:SetAllPoints()
    nameplate.health.text:SetTextColor(1,1,1,1)

    nameplate.glow = nameplate:CreateTexture(nil, "BACKGROUND")
    nameplate.glow:SetPoint("CENTER", nameplate.health, "CENTER", 0, 0)
    nameplate.glow:SetTexture(pfUI.media["img:dot"])
    nameplate.glow:Hide()

    nameplate.level = nameplate:CreateFontString(nil, "OVERLAY")
    nameplate.level:SetPoint("RIGHT", nameplate.health, "LEFT", -3, 0)

    nameplate.raidicon:SetParent(nameplate.health)
    nameplate.raidicon:ClearAllPoints()
    nameplate.raidicon:SetPoint("CENTER", nameplate.health, "CENTER", 0, -5)
    nameplate.raidicon:SetDrawLayer("OVERLAY")
    nameplate.raidicon:SetTexture(pfUI.media["img:raidicons"])

    do -- debuffs
      local debuffs = {}
      for i=1, 16, 1 do
        debuffs[i] = CreateFrame("Frame", nil, nameplate)
        debuffs[i]:Hide()
        debuffs[i]:SetFrameLevel(1)

        debuffs[i].icon = debuffs[i]:CreateTexture(nil, "BACKGROUND")
        debuffs[i].icon:SetTexture(.3,1,.8,1)
        debuffs[i].icon:SetAllPoints(debuffs[i])

        debuffs[i].cd = CreateFrame(COOLDOWN_FRAME_TYPE, nil, debuffs[i], "CooldownFrameTemplate")
        debuffs[i].cd.pfCooldownType = "ALL"
      end
      nameplate.debuffs = debuffs
    end

    do -- combopoints
      local combopoints = { }
      for i = 1, 5 do
        combopoints[i] = CreateFrame("Frame", nil, nameplate)
        combopoints[i]:Hide()
        combopoints[i]:SetFrameLevel(8)
        combopoints[i].tex = combopoints[i]:CreateTexture("OVERLAY")
        combopoints[i].tex:SetAllPoints()

        if i < 3 then
          combopoints[i].tex:SetTexture(1, .3, .3, .75)
        elseif i < 4 then
          combopoints[i].tex:SetTexture(1, 1, .3, .75)
        else
          combopoints[i].tex:SetTexture(.3, 1, .3, .75)
        end
      end
      nameplate.combopoints = combopoints
    end

    do -- castbar
      local castbar = CreateFrame("StatusBar", nil, nameplate.health)
      castbar:Hide()

      castbar:SetScript("OnShow", function()
        nameplate.debuffs[1]:SetPoint("TOPLEFT", this, "BOTTOMLEFT", 0, -4)
      end)

      castbar:SetScript("OnHide", function()
        nameplate.debuffs[1]:SetPoint("TOPLEFT", this:GetParent(), "BOTTOMLEFT", 0, -4)
      end)

      castbar.text = castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      castbar.text:SetPoint("RIGHT", castbar, "LEFT")
      castbar.text:SetNonSpaceWrap(false)
      castbar.text:SetTextColor(1,1,1,.5)

      castbar.spell = castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      castbar.spell:SetPoint("CENTER", castbar, "CENTER")
      castbar.spell:SetNonSpaceWrap(false)
      castbar.spell:SetTextColor(1,1,1,1)

      castbar.icon = CreateFrame("Frame", nil, castbar)
      castbar.icon.tex = castbar.icon:CreateTexture(nil, "BORDER")
      castbar.icon.tex:SetAllPoints()

      nameplate.castbar = castbar
    end

    parent.nameplate = nameplate
    parent:SetScript("OnShow", nameplates.OnShow)
    parent:SetScript("OnUpdate", nameplates.OnUpdate)
    parent:SetScript("OnEvent", nameplates.OnEvent)

    parent:RegisterEvent("PLAYER_TARGET_CHANGED")
    parent:RegisterEvent("UNIT_AURA")
    parent:RegisterEvent("UNIT_COMBO_POINTS")
    parent:RegisterEvent("PLAYER_COMBO_POINTS")

    nameplates.OnConfigChange(parent)
    nameplates.OnShow(parent)
  end

  nameplates.OnConfigChange = function(frame)
    local parent = frame
    local nameplate = frame.nameplate

    local font = C.nameplates.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
    local font_size = C.nameplates.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size
    local glowr, glowg, glowb, glowa = GetStringColor(C.nameplates.glowcolor)
    local hptexture = pfUI.media[C.nameplates.healthtexture]
    local rawborder, default_border = GetBorderSize("nameplates")

    local plate_width = C.nameplates.width + 50
    local plate_height = C.nameplates.heighthealth + font_size + 5
    local plate_height_cast = C.nameplates.heighthealth + font_size + 5 + C.nameplates.heightcast + 5
    local combo_size = 5

    local width = tonumber(C.nameplates.width)
    local debuffsize = tonumber(C.nameplates.debuffsize)

    nameplate:SetWidth(plate_width)
    nameplate:SetHeight(plate_height)
    nameplate:SetPoint("TOP", parent, "TOP", 0, 0)

    nameplate.name:SetFont(font, font_size, "OUTLINE")

    nameplate.health:SetStatusBarTexture(hptexture)
    nameplate.health:SetWidth(C.nameplates.width)
    nameplate.health:SetHeight(C.nameplates.heighthealth)
    CreateBackdrop(nameplate.health, default_border)

    nameplate.health.text:SetFont(font, font_size - 2, "OUTLINE")
    nameplate.health.text:SetJustifyH("RIGHT")

    nameplate.glow:SetWidth(C.nameplates.width + 60)
    nameplate.glow:SetHeight(C.nameplates.heighthealth + 30)
    nameplate.glow:SetVertexColor(glowr, glowg, glowb, glowa)

    nameplate.level:SetFont(font, font_size, "OUTLINE")
    nameplate.raidicon:SetWidth(C.nameplates.raidiconsize)
    nameplate.raidicon:SetHeight(C.nameplates.raidiconsize)

    -- update debuff positions
    local limit = floor(width / debuffsize)
    for i=1,16 do
      nameplate.debuffs[i]:ClearAllPoints()
      if i == 1 then
        nameplate.debuffs[i]:SetPoint("TOPLEFT", nameplate.health, "BOTTOMLEFT", 0, -4)
      elseif i <= limit then
        nameplate.debuffs[i]:SetPoint("LEFT", nameplate.debuffs[i-1], "RIGHT", 1, 0)
      elseif i > limit then
        nameplate.debuffs[i]:SetPoint("TOPLEFT", nameplate.debuffs[i-limit], "BOTTOMLEFT", 0, -1)
      end

      nameplate.debuffs[i]:SetWidth(tonumber(C.nameplates.debuffsize))
      nameplate.debuffs[i]:SetHeight(tonumber(C.nameplates.debuffsize))
    end

    for i=1,5 do
      nameplate.combopoints[i]:SetWidth(combo_size)
      nameplate.combopoints[i]:SetHeight(combo_size)
      nameplate.combopoints[i]:SetPoint("TOPRIGHT", nameplate.health, "BOTTOMRIGHT", -(i-1)*(combo_size+default_border*3), -default_border*3)
      CreateBackdrop(nameplate.combopoints[i], default_border)
    end

    nameplate.castbar:SetPoint("TOPLEFT", nameplate.health, "BOTTOMLEFT", 0, -default_border*3)
    nameplate.castbar:SetPoint("TOPRIGHT", nameplate.health, "BOTTOMRIGHT", 0, -default_border*3)
    nameplate.castbar:SetHeight(C.nameplates.heightcast)
    nameplate.castbar:SetStatusBarTexture(pfUI.media["img:bar"])
    nameplate.castbar:SetStatusBarColor(.9,.8,0,1)
    CreateBackdrop(nameplate.castbar, default_border)

    nameplate.castbar.text:SetFont(font, font_size, "OUTLINE")
    nameplate.castbar.spell:SetFont(font, font_size, "OUTLINE")
    nameplate.castbar.icon:SetPoint("BOTTOMLEFT", nameplate.castbar, "BOTTOMRIGHT", default_border*3, 0)
    nameplate.castbar.icon:SetPoint("TOPLEFT", nameplate.health, "TOPRIGHT", default_border*3, 0)
    nameplate.castbar.icon:SetWidth(C.nameplates.heightcast + default_border*3 + C.nameplates.heighthealth)
    CreateBackdrop(nameplate.castbar.icon, default_border)

    nameplates:OnDataChanged(nameplate)
  end

  nameplates.OnValueChanged = function(arg1)
    nameplates:OnDataChanged(this:GetParent().nameplate)
  end

  nameplates.OnEvent = function(frame)
    local frame = frame or this
    nameplates:OnDataChanged(frame.nameplate)
  end

  nameplates.OnDataChanged = function(self, plate)
    local hp = plate.parent.healthbar:GetValue()
    local hpmin, hpmax = plate.parent.healthbar:GetMinMaxValues()
    local name = plate.parent.name:GetText()
    local level = plate.parent.level:IsShown() and plate.parent.level:GetObjectType() == "FontString" and tonumber(plate.parent.level:GetText()) or "??"
    local class, _, elite, player = GetUnitData(name, true)
    local target = UnitExists("target") and plate.parent:GetAlpha() == 1 or nil
    local mouseover = UnitExists("mouseover") and plate.parent.glow:IsShown() or nil
    local unitstr = target and "target" or mouseover and "mouseover" or nil
    local red, green, blue = plate.parent.healthbar:GetStatusBarColor()
    local unittype = GetUnitType(red, green, blue)
    if player and unittype == "ENEMY_NPC" then unittype = "ENEMY_PLAYER" end
    elite = plate.parent.levelicon:IsShown() and not player and "boss" or elite
    if not class then plate.wait_for_scan = true end

    -- target event sometimes fires too quickly, where nameplate identifiers are not
    -- yet updated. So while being inside this event, we cannot trust the unitstr.
    if event == "PLAYER_TARGET_CHANGED" then unitstr = nil end

    if (MobHealth3 or MobHealthFrame) and target and name == UnitName('target') and MobHealth_GetTargetCurHP() then
      hp, hpmax = MobHealth_GetTargetCurHP(), MobHealth_GetTargetMaxHP()
    end

    plate:Show()
    plate:SetAlpha(1)

    if target and C.nameplates.targetglow == "1" then
      plate.glow:Show() else plate.glow:Hide()
    end

    -- target indicator
    if target and C.nameplates.targethighlight == "1" then
      plate.health.backdrop:SetBackdropBorderColor(1,1,1,1)
    else
      local rawborder, default_border = GetBorderSize("nameplates")
      CreateBackdrop(plate.health, default_border)
    end

    -- hide frames according to the configuration
    if HidePlate(unittype, name, (hpmax-hp == hpmin), target) then
      plate.level:SetPoint("RIGHT", plate.name, "LEFT", -3, 0)
      plate.health:Hide()
    else
      plate.level:SetPoint("RIGHT", plate.health, "LEFT", -3, 0)
      plate.health:Show()
    end

    plate.name:SetText(name)
    plate.level:SetText(string.format("%s%s", level, (elitestrings[elite] or "")))

    plate.health:SetMinMaxValues(hpmin, hpmax)
    plate.health:SetValue(hp)

    if C.nameplates.showhp == "1" then
      local rhp, rhpmax, estimated
      if hpmax > 100 or (round(hpmax/100*hp) ~= hp) then
        rhp, rhpmax = hp, hpmax
      elseif pfUI.libhealth and pfUI.libhealth.enabled then
        rhp, rhpmax, estimated = pfUI.libhealth:GetUnitHealthByName(name,level,tonumber(hp),tonumber(hpmax))
      end

      if C.nameplates.alwaysperc == "0" and ( estimated or hpmax > 100 or (round(hpmax/100*hp) ~= hp) ) then
        plate.health.text:SetText(string.format("%s / %s", Abbreviate(rhp), Abbreviate(rhpmax)))
      else
        plate.health.text:SetText(string.format("%s%%", hp))
      end
    else
      plate.health.text:SetText()
    end

    local r, g, b, a = unpack(unitcolors[unittype])

    if unittype == "ENEMY_PLAYER" and C.nameplates["enemyclassc"] == "1" and class and RAID_CLASS_COLORS[class] then
      r, g, b, a = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, 1
    elseif unittype == "FRIENDLY_PLAYER" and C.nameplates["friendclassc"] == "1" and class and RAID_CLASS_COLORS[class] then
      r, g, b, a = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, 1
    end

    if r ~= plate.cache.r or g ~= plate.cache.g or b ~= plate.cache.b then
      plate.health:SetStatusBarColor(r, g, b, a)
      plate.cache.r, plate.cache.g, plate.cache.b = r, g, b
    end

    -- update combopoints
    for i=1, 5 do plate.combopoints[i]:Hide() end
    if target and C.nameplates.cpdisplay == "1" then
      for i=1, GetComboPoints("target") do plate.combopoints[i]:Show() end
    end

    -- update debuffs
    for i = 1, 16 do
      if target and C.nameplates["showdebuffs"] == "1" and UnitDebuff("target", i) then
        local name, _, icon = libdebuff:UnitDebuff("target", i)
        plate.debuffs[i]:Show()
        plate.debuffs[i].icon:SetTexture(icon)
        plate.debuffs[i].icon:SetTexCoord(.078, .92, .079, .937)

        local name, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff("target", i)
        if duration and timeleft then
          plate.debuffs[i].cd:SetAlpha(0)
          plate.debuffs[i].cd:Show()
          CooldownFrame_SetTimer(plate.debuffs[i].cd, GetTime() + timeleft - duration, duration, 1)
        end
      else
        plate.debuffs[i]:Hide()
      end
    end
  end

  nameplates.OnShow = function(frame)
    local frame = frame or this
    local nameplate = frame.nameplate

    nameplates:OnDataChanged(nameplate)
  end

  nameplates.OnUpdate = function(frame)
    local frame = frame or this
    local name = frame.name:GetText()

    if frame:GetAlpha() < tonumber(C.nameplates.notargalpha) then frame:SetAlpha(tonumber(C.nameplates.notargalpha)) end

    -- trigger update when target state changed
    local target = UnitExists("target") and frame:GetAlpha() == 1 or nil
    if target ~= frame.nameplate.cache.istarget then
      frame.nameplate.cache.istarget = target
      nameplates:OnDataChanged(frame.nameplate)
    end

    -- trigger update when unit was found
    if frame.nameplate.wait_for_scan and GetUnitData(name, true) then
      frame.nameplate.wait_for_scan = nil
      nameplates:OnDataChanged(frame.nameplate)
    end

    -- trigger update when name color changed
    local r, g, b = frame.name:GetTextColor()
    if r + g + b ~= frame.nameplate.cache.namecolor then
      frame.nameplate.cache.namecolor = r + g + b

      if r > .9 and g < .2 and b < .2 then
        frame.nameplate.name:SetTextColor(1,0.4,0.2,1) -- infight
      else
        frame.nameplate.name:SetTextColor(r,g,b,1)
      end
    end

    -- trigger update when name color changed
    local r, g, b = frame.level:GetTextColor()
    r, g, b = r + .3, g + .3, b + .3
    if r + g + b ~= frame.nameplate.cache.levelcolor then
      frame.nameplate.cache.levelcolor = r + g + b
      frame.nameplate.level:SetTextColor(r,g,b,1)
      nameplates:OnDataChanged(frame.nameplate)
    end

    -- target zoom
    local w, h = frame.nameplate.health:GetWidth(), frame.nameplate.health:GetHeight()
    if target and C.nameplates.targetzoom == "1" then
      local wc = tonumber(C.nameplates.width)*1.4
      local hc = tonumber(C.nameplates.heighthealth)*1.3
      local animation = false

      if wc >= w then
        wc = w*1.05
        frame.nameplate.health:SetWidth(wc)
        frame.nameplate.health.zoomTransition = true
        animation = true
      end

      if hc >= h then
        hc = h*1.05
        frame.nameplate.health:SetHeight(hc)
        frame.nameplate.health.zoomTransition = true
        animation = true
      end

      if animation == false and not frame.nameplate.health.zoomed then
        frame.nameplate.health:SetWidth(wc)
        frame.nameplate.health:SetHeight(hc)
        frame.nameplate.health.zoomTransition = nil
        frame.nameplate.health.zoomed = true
      end
    elseif frame.nameplate.health.zoomed or frame.nameplate.health.zoomTransition then
      local wc = tonumber(C.nameplates.width)
      local hc = tonumber(C.nameplates.heighthealth)
      local animation = false

      if wc <= w then
        wc = w*.95
        frame.nameplate.health:SetWidth(wc)
        animation = true
      end

      if hc <= h then
        hc = h*0.95
        frame.nameplate.health:SetHeight(hc)
        animation = true
      end

      if animation == false then
        frame.nameplate.health:SetWidth(wc)
        frame.nameplate.health:SetHeight(hc)
        frame.nameplate.health.zoomTransition = nil
        frame.nameplate.health.zoomed = nil
      end
    end

    -- castbar update
    if C.nameplates["showcastbar"] == "1" then
      local cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(target and "target" or name)

      if not cast then
        frame.nameplate.castbar:Hide()
      elseif cast then
        local duration = endTime - startTime
        frame.nameplate.castbar:SetMinMaxValues(0,  duration/1000)
        frame.nameplate.castbar:SetValue(GetTime() - startTime/1000)
        frame.nameplate.castbar.text:SetText(round(startTime/1000 + duration/1000 - GetTime(),1))
        if C.nameplates.spellname == "1" then
          frame.nameplate.castbar.spell:SetText(cast)
        else
          frame.nameplate.castbar.spell:SetText("")
        end
        frame.nameplate.castbar:Show()

        if texture then
          frame.nameplate.castbar.icon.tex:SetTexture(texture)
          frame.nameplate.castbar.icon.tex:SetTexCoord(.1,.9,.1,.9)
        end
      end
    else
      frame.nameplate.castbar:Hide()
    end
  end

  nameplates.UpdateConfig = function()
    for plate in pairs(registry) do
      nameplates.OnConfigChange(plate)
    end
  end

  if pfUI.client <= 11200 then
    -- handle vanilla only settings
    -- due to the secured lua api, those settings can't be applied to TBC and later.
    local hookOnConfigChange = nameplates.OnConfigChange
    nameplates.OnConfigChange = function(self)
      hookOnConfigChange(self)

      local parent = self
      local nameplate = self.nameplate
      local plate = C.nameplates["overlap"] == "1" and nameplate or parent

      -- replace clickhandler
      if C.nameplates["overlap"] == "1" then
        parent:SetFrameLevel(0)
        nameplate:SetScript("OnClick", function() parent:Click() end)

        parent:EnableMouse(false)
        nameplate:EnableMouse(true)
      else
        parent:EnableMouse(true)
        nameplate:EnableMouse(false)
      end

      -- enable mouselook on rightbutton down
      if C.nameplates["rightclick"] == "1" then
        plate:SetScript("OnMouseDown", nameplates.mouselook.OnMouseDown)
      else
        plate:SetScript("OnMouseDown", nil)
      end

      -- disable click event on frames
      if C.nameplates["clickthrough"] == "1" then
        plate:EnableMouse(false)
      else
        plate:EnableMouse(true)
      end
    end

    local hookOnUpdate = nameplates.OnUpdate
    nameplates.OnUpdate = function(self)
      if C.nameplates["overlap"] == "1" then
        -- set parent to 1 pixel to have them overlap each other
        this:SetWidth(1)
        this:SetHeight(1)
      else
        -- align parent plate to the actual size
        this:SetWidth(this.nameplate:GetWidth() * UIParent:GetScale())
        this:SetHeight(this.nameplate:GetHeight() * UIParent:GetScale())
      end

      -- disable click events while spell is targeting
      local mouseEnabled = this.nameplate:IsMouseEnabled()
      if C.nameplates["clickthrough"] == "0" and C.nameplates["overlap"] == "1" and SpellIsTargeting() == mouseEnabled then
        this.nameplate:EnableMouse(not mouseEnabled)
      end

      hookOnUpdate(self)
    end

    -- enable mouselook on rightbutton down
    nameplates.mouselook = CreateFrame("Frame", nil, UIParent)
    nameplates.mouselook.time = nil
    nameplates.mouselook.frame = nil
    nameplates.mouselook.OnMouseDown = function()
      if arg1 and arg1 == "RightButton" then
        MouselookStart()

        -- start detection of the rightclick emulation
        nameplates.mouselook.time = GetTime()
        nameplates.mouselook.frame = this
        nameplates.mouselook:Show()
      end
    end

    nameplates.mouselook:SetScript("OnUpdate", function()
      -- break here if nothing to do
      if not this.time or not this.frame then
        this:Hide()
        return
      end

      -- if threshold is reached (0.5 second) no click action will follow
      if not IsMouselooking() and this.time + tonumber(C.nameplates["clickthreshold"]) < GetTime() then
        this:Hide()
        return
      end

      -- run a usual nameplate rightclick action
      if not IsMouselooking() then
        this.frame:Click("LeftButton")
        if UnitCanAttack("player", "target") and not nameplates.combat.inCombat then AttackTarget() end
        this:Hide()
        return
      end
    end)
  end

  pfUI.nameplates = nameplates
end)
