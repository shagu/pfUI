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
  local parentcount = 0
  local platecount = 0
  local registry = {}
  local debuffdurations = C.appearance.cd.debuffs == "1" and true or nil

  -- cache default border color
  local er, eg, eb, ea = GetStringColor(pfUI_config.appearance.border.color)

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

  local function TotemPlate(name)
    if C.nameplates.totemicons == "1" then
      for totem, icon in pairs(L["totems"]) do
        if string.find(name, totem) then return icon end
      end
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
        if string.lower(name) == string.lower(critter) then return true end
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

  local filter, list, cache
  local function DebuffFilterPopulate()
    -- initialize variables
    filter = C.nameplates["debuffs"]["filter"]
    if filter == "none" then return end
    list = C.nameplates["debuffs"][filter]
    cache = {}

    -- populate list
    for _, val in pairs({strsplit("#", list)}) do
      cache[strlower(val)] = true
    end
  end

  local function DebuffFilter(effect)
    if filter == "none" then return true end
    if not cache then DebuffFilterPopulate() end

    if filter == "blacklist" and cache[strlower(effect)] then
      return nil
    elseif filter == "blacklist" then
      return true
    elseif filter == "whitelist" and cache[strlower(effect)] then
      return true
    elseif filter == "whitelist" then
      return nil
    end
  end

  local function PlateCacheDebuffs(self, unitstr, verify)
    if not self.debuffcache then self.debuffcache = {} end

    for id = 1, 16 do
      local effect, _, texture, stacks, _, duration, timeleft = libdebuff:UnitDebuff(unitstr, id)
      if effect and timeleft then
        local start = GetTime() - ( (duration or 0) - ( timeleft or 0) )
        local stop = GetTime() + ( timeleft or 0 )
        self.debuffcache[id] = self.debuffcache[id] or {}
        self.debuffcache[id].effect = effect
        self.debuffcache[id].texture = texture
        self.debuffcache[id].stacks = stacks
        self.debuffcache[id].duration = duration or 0
        self.debuffcache[id].start = start
        self.debuffcache[id].stop = stop
      elseif self.debuffcache[id] then
        self.debuffcache[id] = nil
        table.remove(self.debuffcache, id)
      end
    end

    self.verify = verify
  end

  local function PlateUnitDebuff(self, id)
    if not self.debuffcache then return end
    if not self.debuffcache[id] then return end
    if not self.debuffcache[id].stop then return end

    local c = self.debuffcache[id]
    return c.effect, c.rank, c.texture, c.stacks, c.dtype, c.duration, (c.stop - GetTime())
  end

  local function CreateDebuffIcon(plate, index)
    plate.debuffs[index] = CreateFrame("Frame", plate.platename.."Debuff"..index, plate)
    plate.debuffs[index]:Hide()
    plate.debuffs[index]:SetFrameLevel(1)

    plate.debuffs[index].icon = plate.debuffs[index]:CreateTexture(nil, "BACKGROUND")
    plate.debuffs[index].icon:SetTexture(.3,1,.8,1)
    plate.debuffs[index].icon:SetAllPoints(plate.debuffs[index])

    plate.debuffs[index].stacks = plate.debuffs[index]:CreateFontString(nil, "OVERLAY")
    plate.debuffs[index].stacks:SetAllPoints(plate.debuffs[index])
    plate.debuffs[index].stacks:SetJustifyH("RIGHT")
    plate.debuffs[index].stacks:SetJustifyV("BOTTOM")
    plate.debuffs[index].stacks:SetTextColor(1,1,0)

    plate.debuffs[index].cd = CreateFrame(COOLDOWN_FRAME_TYPE, plate.platename.."Debuff"..index.."Cooldown", plate.debuffs[index], "CooldownFrameTemplate")
    plate.debuffs[index].cd.pfCooldownStyleAnimation = 0
    plate.debuffs[index].cd.pfCooldownType = "ALL"
  end

  local function UpdateDebuffConfig(nameplate, i)
    if not nameplate.debuffs[i] then return end

    -- update debuff positions
    local width = tonumber(C.nameplates.width)
    local debuffsize = tonumber(C.nameplates.debuffsize)
    local limit = floor(width / debuffsize)
    local font = C.nameplates.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
    local font_size = C.nameplates.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size
    local font_style = C.nameplates.name.fontstyle

    local aligna, alignb, offs, space
    if C.nameplates.debuffs["position"] == "BOTTOM" then
      aligna, alignb, offs, space = "TOPLEFT", "BOTTOMLEFT", -4, -1
    else
      aligna, alignb, offs, space = "BOTTOMLEFT", "TOPLEFT", 20, 1
    end

    nameplate.debuffs[i].stacks:SetFont(font, font_size, font_style)
    nameplate.debuffs[i]:ClearAllPoints()
    if i == 1 then
      nameplate.debuffs[i]:SetPoint(aligna, nameplate.health, alignb, 0, offs)
    elseif i <= limit then
      nameplate.debuffs[i]:SetPoint("LEFT", nameplate.debuffs[i-1], "RIGHT", 1, 0)
    elseif i > limit and limit > 0 then
      nameplate.debuffs[i]:SetPoint(aligna, nameplate.debuffs[i-limit], alignb, 0, space)
    end

    nameplate.debuffs[i]:SetWidth(tonumber(C.nameplates.debuffsize))
    nameplate.debuffs[i]:SetHeight(tonumber(C.nameplates.debuffsize))
  end

  -- create nameplate core
  local nameplates = CreateFrame("Frame", "pfNameplates", UIParent)
  nameplates:RegisterEvent("PLAYER_ENTERING_WORLD")
  nameplates:SetScript("OnEvent", function()
    this:SetGameVariables()
  end)

  nameplates:SetScript("OnUpdate", function()
    parentcount = WorldFrame:GetNumChildren()
    if initialized < parentcount then
      childs = { WorldFrame:GetChildren() }
      for i = initialized + 1, parentcount do
        plate = childs[i]
        if IsNamePlate(plate) and not registry[plate] then
          nameplates.OnCreate(plate)
          registry[plate] = plate
        end
      end

      initialized = parentcount
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
    platecount = platecount + 1
    platename = "pfNamePlate" .. platecount

    -- create pfUI nameplate overlay
    local nameplate = CreateFrame("Button", platename, parent)
    nameplate.platename = platename
    nameplate:EnableMouse(0)
    nameplate.parent = parent
    nameplate.cache = {}
    nameplate.UnitDebuff = PlateUnitDebuff
    nameplate.CacheDebuffs = PlateCacheDebuffs
    nameplate.original = {}

    -- create shortcuts for all known elements and disable them
    nameplate.original.healthbar, nameplate.original.castbar = parent:GetChildren()
    DisableObject(nameplate.original.healthbar)
    DisableObject(nameplate.original.castbar)

    for i, object in pairs({parent:GetRegions()}) do
      if NAMEPLATE_OBJECTORDER[i] and NAMEPLATE_OBJECTORDER[i] == "raidicon" then
        nameplate[NAMEPLATE_OBJECTORDER[i]] = object
      elseif NAMEPLATE_OBJECTORDER[i] then
        nameplate.original[NAMEPLATE_OBJECTORDER[i]] = object
        DisableObject(object)
      else
        DisableObject(object)
      end
    end

    HookScript(nameplate.original.healthbar, "OnValueChanged", nameplates.OnValueChanged)

    -- adjust sizes and scaling of the nameplate
    nameplate:SetScale(UIParent:GetScale())

    nameplate.health = CreateFrame("StatusBar", nil, nameplate)
    nameplate.health:SetFrameLevel(4) -- keep above glow
    nameplate.health.text = nameplate.health:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameplate.health.text:SetAllPoints()
    nameplate.health.text:SetTextColor(1,1,1,1)

    nameplate.name = nameplate:CreateFontString(nil, "OVERLAY")
    nameplate.name:SetPoint("TOP", nameplate, "TOP", 0, nameoffset)

    nameplate.glow = nameplate:CreateTexture(nil, "BACKGROUND")
    nameplate.glow:SetPoint("CENTER", nameplate.health, "CENTER", 0, 0)
    nameplate.glow:SetTexture(pfUI.media["img:dot"])
    nameplate.glow:Hide()

    nameplate.guild = nameplate:CreateFontString(nil, "OVERLAY")
    nameplate.guild:SetPoint("BOTTOM", nameplate.health, "BOTTOM", 0, 0)

    nameplate.level = nameplate:CreateFontString(nil, "OVERLAY")
    nameplate.level:SetPoint("RIGHT", nameplate.health, "LEFT", -3, 0)

    nameplate.raidicon:SetParent(nameplate.health)
    nameplate.raidicon:SetDrawLayer("OVERLAY")
    nameplate.raidicon:SetTexture(pfUI.media["img:raidicons"])

    nameplate.totem = CreateFrame("Frame", nil, nameplate)
    nameplate.totem:SetPoint("CENTER", nameplate, "CENTER", 0, 0)
    nameplate.totem:SetHeight(32)
    nameplate.totem:SetWidth(32)
    nameplate.totem.icon = nameplate.totem:CreateTexture(nil, "OVERLAY")
    nameplate.totem.icon:SetTexCoord(.078, .92, .079, .937)
    nameplate.totem.icon:SetAllPoints()
    CreateBackdrop(nameplate.totem)

    do -- debuffs
      nameplate.debuffs = {}
      CreateDebuffIcon(nameplate, 1)
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
        if C.nameplates.debuffs["position"] == "BOTTOM" then
          nameplate.debuffs[1]:SetPoint("TOPLEFT", this, "BOTTOMLEFT", 0, -4)
        end
      end)

      castbar:SetScript("OnHide", function()
        if C.nameplates.debuffs["position"] == "BOTTOM" then
          nameplate.debuffs[1]:SetPoint("TOPLEFT", this:GetParent(), "BOTTOMLEFT", 0, -4)
        end
      end)

      castbar.text = castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      castbar.text:SetPoint("RIGHT", castbar, "LEFT", -4, 0)
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
    HookScript(parent, "OnShow", nameplates.OnShow)
    HookScript(parent, "OnUpdate", nameplates.OnUpdate)


    nameplate:RegisterEvent("PLAYER_TARGET_CHANGED")
    nameplate:RegisterEvent("UNIT_AURA")
    nameplate:RegisterEvent("UNIT_COMBO_POINTS")
    nameplate:RegisterEvent("PLAYER_COMBO_POINTS")
    nameplate:SetScript("OnEvent", nameplates.OnEvent)

    nameplates.OnConfigChange(parent)
    nameplates.OnShow(parent)
  end

  nameplates.OnConfigChange = function(frame)
    local parent = frame
    local nameplate = frame.nameplate

    local font = C.nameplates.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
    local font_size = C.nameplates.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size
    local font_style = C.nameplates.name.fontstyle
    local glowr, glowg, glowb, glowa = GetStringColor(C.nameplates.glowcolor)
    local hlr, hlg, hlb, hla = GetStringColor(C.nameplates.highlightcolor)
    local hptexture = pfUI.media[C.nameplates.healthtexture]
    local rawborder, default_border = GetBorderSize("nameplates")

    local plate_width = C.nameplates.width + 50
    local plate_height = C.nameplates.heighthealth + font_size + 5
    local plate_height_cast = C.nameplates.heighthealth + font_size + 5 + C.nameplates.heightcast + 5
    local combo_size = 5

    local width = tonumber(C.nameplates.width)
    local debuffsize = tonumber(C.nameplates.debuffsize)
    local healthoffset = tonumber(C.nameplates.health.offset)

    nameplate:SetWidth(plate_width)
    nameplate:SetHeight(plate_height)
    nameplate:SetPoint("TOP", parent, "TOP", 0, 0)

    nameplate.name:SetFont(font, font_size, font_style)

    nameplate.health:SetPoint("TOP", nameplate.name, "BOTTOM", 0, healthoffset)
    nameplate.health:SetStatusBarTexture(hptexture)
    nameplate.health:SetWidth(C.nameplates.width)
    nameplate.health:SetHeight(C.nameplates.heighthealth)
    nameplate.health.hlr, nameplate.health.hlg, nameplate.health.hlb, nameplate.health.hla = hlr, hlg, hlb, hla
    CreateBackdrop(nameplate.health, default_border)

    nameplate.health.text:SetFont(font, font_size - 2, "OUTLINE")
    nameplate.health.text:SetJustifyH(C.nameplates.hptextpos)

    nameplate.guild:SetFont(font, font_size, font_style)

    nameplate.glow:SetWidth(C.nameplates.width + 60)
    nameplate.glow:SetHeight(C.nameplates.heighthealth + 30)
    nameplate.glow:SetVertexColor(glowr, glowg, glowb, glowa)

    nameplate.raidicon:ClearAllPoints()
    nameplate.raidicon:SetPoint(C.nameplates.raidiconpos, nameplate.health, C.nameplates.raidiconpos, C.nameplates.raidiconoffx, C.nameplates.raidiconoffy)
    nameplate.level:SetFont(font, font_size, font_style)
    nameplate.raidicon:SetWidth(C.nameplates.raidiconsize)
    nameplate.raidicon:SetHeight(C.nameplates.raidiconsize)

    for i=1,16 do
      UpdateDebuffConfig(nameplate, i)
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
    frame.eventcache = true
  end

  nameplates.OnDataChanged = function(self, plate)
    local visible = plate:IsVisible()
    local hp = plate.original.healthbar:GetValue()
    local hpmin, hpmax = plate.original.healthbar:GetMinMaxValues()
    local name = plate.original.name:GetText()
    local level = plate.original.level:IsShown() and plate.original.level:GetObjectType() == "FontString" and tonumber(plate.original.level:GetText()) or "??"
    local class, ulevel, elite, player, guild = GetUnitData(name, true)
    local target = plate.istarget
    local mouseover = UnitExists("mouseover") and plate.original.glow:IsShown() or nil
    local unitstr = target and "target" or mouseover and "mouseover" or nil
    local red, green, blue = plate.original.healthbar:GetStatusBarColor()
    local unittype = GetUnitType(red, green, blue) or "ENEMY_NPC"
    local font_size = C.nameplates.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size

    -- ignore players with npc names if plate level is lower than player level
    if ulevel and ulevel > (level == "??" and -1 or level) then player = nil end

    -- cache name and reset unittype on change
    if plate.cache.name ~= name then
      plate.cache.name = name
      plate.cache.player = nil
    end

    -- read and cache unittype
    if plate.cache.player then
      -- overwrite unittype from cache if existing
      player = plate.cache.player == "PLAYER" and true or nil
    elseif unitstr then
      -- read unit type while unitstr is set
      plate.cache.player = UnitIsPlayer(unitstr) and "PLAYER" or "NPC"
    end

    if player and unittype == "ENEMY_NPC" then unittype = "ENEMY_PLAYER" end
    elite = plate.original.levelicon:IsShown() and not player and "boss" or elite
    if not class then plate.wait_for_scan = true end

    -- skip data updates on invisible frames
    if not visible then return end

    -- target event sometimes fires too quickly, where nameplate identifiers are not
    -- yet updated. So while being inside this event, we cannot trust the unitstr.
    if event == "PLAYER_TARGET_CHANGED" then unitstr = nil end

    -- remove unitstr on unit name mismatch
    if unitstr and UnitName(unitstr) ~= name then unitstr = nil end

    -- use mobhealth values if addon is running
    if (MobHealth3 or MobHealthFrame) and target and name == UnitName('target') and MobHealth_GetTargetCurHP() then
      hp = MobHealth_GetTargetCurHP() > 0 and MobHealth_GetTargetCurHP() or hp
      hpmax = MobHealth_GetTargetMaxHP() > 0 and MobHealth_GetTargetMaxHP() or hpmax
    end

    -- always make sure to keep plate visible
    plate:Show()

    if target and C.nameplates.targetglow == "1" then
      plate.glow:Show() else plate.glow:Hide()
    end

    -- target indicator
    if target and C.nameplates.targethighlight == "1" then
      plate.health.backdrop:SetBackdropBorderColor(plate.health.hlr, plate.health.hlg, plate.health.hlb, plate.health.hla)
    elseif C.nameplates.outfriendlynpc == "1" and unittype == "FRIENDLY_NPC" then
      plate.health.backdrop:SetBackdropBorderColor(.2,.7,.3,1)
    elseif C.nameplates.outfriendly == "1" and unittype == "FRIENDLY_PLAYER" then
      plate.health.backdrop:SetBackdropBorderColor(.2,.3,.7,1)
    elseif C.nameplates.outneutral == "1" and strfind(unittype, "NEUTRAL") then
      plate.health.backdrop:SetBackdropBorderColor(.7,.7,.2,1)
    elseif C.nameplates.outenemy == "1" and strfind(unittype, "ENEMY") then
      plate.health.backdrop:SetBackdropBorderColor(.7,.2,.3,1)
    else
      plate.health.backdrop:SetBackdropBorderColor(er,eg,eb,ea)
    end

    -- hide frames according to the configuration
    local TotemIcon = TotemPlate(name)

    if TotemIcon then
      -- create totem icon
      plate.totem.icon:SetTexture("Interface\\Icons\\" .. TotemIcon)

      plate.glow:Hide()
      plate.level:Hide()
      plate.name:Hide()
      plate.health:Hide()
      plate.guild:Hide()
      plate.totem:Show()
    elseif HidePlate(unittype, name, (hpmax-hp == hpmin), target) then
      plate.level:SetPoint("RIGHT", plate.name, "LEFT", -3, 0)
      plate.name:SetParent(plate)
      plate.guild:SetPoint("BOTTOM", plate.name, "BOTTOM", -2, -(font_size + 2))

      plate.level:Show()
      plate.name:Show()
      plate.health:Hide()
      if guild and C.nameplates.showguildname == "1" then
        plate.glow:SetPoint("CENTER", plate.name, "CENTER", 0, -(font_size / 2) - 2)
      else
        plate.glow:SetPoint("CENTER", plate.name, "CENTER", 0, 0)
      end
      plate.totem:Hide()
    else
      plate.level:SetPoint("RIGHT", plate.health, "LEFT", -5, 0)
      plate.name:SetParent(plate.health)
      plate.guild:SetPoint("BOTTOM", plate.health, "BOTTOM", 0, -(font_size + 4))

      plate.level:Show()
      plate.name:Show()
      plate.health:Show()
      plate.glow:SetPoint("CENTER", plate.health, "CENTER", 0, 0)
      plate.totem:Hide()
    end

    plate.name:SetText(name)
    plate.level:SetText(string.format("%s%s", level, (elitestrings[elite] or "")))

    if guild and C.nameplates.showguildname == "1" then
      plate.guild:SetText(guild)
      if guild == GetGuildInfo("player") then
        plate.guild:SetTextColor(0, 0.9, 0, 1)
      else
        plate.guild:SetTextColor(0.8, 0.8, 0.8, 1)
      end
      plate.guild:Show()
    else
      plate.guild:Hide()
    end

    plate.health:SetMinMaxValues(hpmin, hpmax)
    plate.health:SetValue(hp)

    if C.nameplates.showhp == "1" then
      local rhp, rhpmax, estimated
      if hpmax > 100 or (round(hpmax/100*hp) ~= hp) then
        rhp, rhpmax = hp, hpmax
      elseif pfUI.libhealth and pfUI.libhealth.enabled then
        rhp, rhpmax, estimated = pfUI.libhealth:GetUnitHealthByName(name,level,tonumber(hp),tonumber(hpmax))
      end

      local setting = C.nameplates.hptextformat
      local hasdata = ( estimated or hpmax > 100 or (round(hpmax/100*hp) ~= hp) )

      if setting == "curperc" and hasdata then
        plate.health.text:SetText(string.format("%s | %s%%", Abbreviate(rhp), ceil(hp/hpmax*100)))
      elseif setting == "cur" and hasdata then
        plate.health.text:SetText(string.format("%s", Abbreviate(rhp)))
      elseif setting == "curmax" and hasdata then
        plate.health.text:SetText(string.format("%s - %s", Abbreviate(rhp), Abbreviate(rhpmax)))
      elseif setting == "curmaxs" and hasdata then
        plate.health.text:SetText(string.format("%s / %s", Abbreviate(rhp), Abbreviate(rhpmax)))
      elseif setting == "curmaxperc" and hasdata then
        plate.health.text:SetText(string.format("%s - %s | %s%%", Abbreviate(rhp), Abbreviate(rhpmax), ceil(hp/hpmax*100)))
      elseif setting == "curmaxpercs" and hasdata then
        plate.health.text:SetText(string.format("%s / %s | %s%%", Abbreviate(rhp), Abbreviate(rhpmax), ceil(hp/hpmax*100)))
      elseif setting == "deficit" then
        plate.health.text:SetText(string.format("-%s" .. (hasdata and "" or "%%"), Abbreviate(rhpmax) - Abbreviate(rhp)))
      else -- "percent" as fallback
        plate.health.text:SetText(string.format("%s%%", ceil(hp/hpmax*100)))
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

    if r + g + b ~= plate.cache.namecolor and unittype == "FRIENDLY_PLAYER" and C.nameplates["friendclassnamec"] == "1" and class and RAID_CLASS_COLORS[class] then
      plate.name:SetTextColor(r, g, b, a)
      plate.cache.namecolor = r + g + b
    end

    -- update combopoints
    for i=1, 5 do plate.combopoints[i]:Hide() end
    if target and C.nameplates.cpdisplay == "1" then
      for i=1, GetComboPoints("target") do plate.combopoints[i]:Show() end
    end

    -- update debuffs
    local index = 1

    if C.nameplates["showdebuffs"] == "1" then
      local verify = string.format("%s:%s", (name or ""), (level or ""))

      -- update cached debuffs
      if C.nameplates["guessdebuffs"] == "1" and unitstr then
        plate:CacheDebuffs(unitstr, verify)
      end

      -- update all debuff icons
      for i = 1, 16 do
        local effect, rank, texture, stacks, dtype, duration, timeleft
        if unitstr then
          effect, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff(unitstr, i)
        elseif plate.verify == verify then
          effect, rank, texture, stacks, dtype, duration, timeleft = plate:UnitDebuff(i)
        end

        if effect and texture and DebuffFilter(effect) then
          if not plate.debuffs[index] then
            CreateDebuffIcon(plate, index)
            UpdateDebuffConfig(plate, index)
          end

          plate.debuffs[index]:Show()
          plate.debuffs[index].icon:SetTexture(texture)
          plate.debuffs[index].icon:SetTexCoord(.078, .92, .079, .937)

          if stacks and stacks > 1 and C.nameplates.debuffs["showstacks"] == "1" then
            plate.debuffs[index].stacks:SetText(stacks)
            plate.debuffs[index].stacks:Show()
          else
            plate.debuffs[index].stacks:Hide()
          end

          if duration and timeleft and debuffdurations then
            plate.debuffs[index].cd:SetAlpha(0)
            plate.debuffs[index].cd:Show()
            CooldownFrame_SetTimer(plate.debuffs[index].cd, GetTime() + timeleft - duration, duration, 1)
          end

          index = index + 1
        end
      end
    end

    -- hide remaining debuffs
    for i = index, 16 do
      if plate.debuffs[i] then
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
    local update
    local frame = frame or this
    local nameplate = frame.nameplate
    local original = nameplate.original
    local name = original.name:GetText()
    local target = UnitExists("target") and frame:GetAlpha() == 1 or nil
    local mouseover = UnitExists("mouseover") and original.glow:IsShown() or nil

    -- trigger queued event update
    if nameplate.eventcache then
      nameplates:OnDataChanged(nameplate)
      nameplate.eventcache = nil
    end

    -- cache target value
    nameplate.istarget = target

    -- set non-target plate alpha
    if target or not UnitExists("target") then
      nameplate:SetAlpha(1)
    else
      frame:SetAlpha(.95)
      nameplate:SetAlpha(tonumber(C.nameplates.notargalpha))
    end

    -- use timer based updates
    if not nameplate.tick or nameplate.tick < GetTime() then
      nameplate.tick = GetTime() + .2
      update = true
    end

    -- queue update on visual target update
    if nameplate.cache.target ~= target then
      nameplate.cache.target = target
      update = true
    end

    -- queue update on visual mouseover update
    if nameplate.cache.mouseover ~= mouseover then
      nameplate.cache.mouseover = mouseover
      update = true
    end

    -- trigger update when unit was found
    if nameplate.wait_for_scan and GetUnitData(name, true) then
      nameplate.wait_for_scan = nil
      update = true
    end

    -- trigger update when name color changed
    local r, g, b = original.name:GetTextColor()
    if r + g + b ~= nameplate.cache.namecolor then
      nameplate.cache.namecolor = r + g + b
      if r > .9 and g < .2 and b < .2 then
        nameplate.name:SetTextColor(1,0.4,0.2,1) -- infight
      else
        nameplate.name:SetTextColor(r,g,b,1)
      end
      update = true
    end

    -- trigger update when name color changed
    local r, g, b = original.level:GetTextColor()
    r, g, b = r + .3, g + .3, b + .3
    if r + g + b ~= nameplate.cache.levelcolor then
      nameplate.cache.levelcolor = r + g + b
      nameplate.level:SetTextColor(r,g,b,1)
      update = true
    end

    -- scan for debuff timeouts
    if nameplate.debuffcache then
      -- delete timed out caches
      for id, data in pairs(nameplate.debuffcache) do
        if not data.stop or data.stop < GetTime() then
          nameplate.debuffcache[id] = nil
          trigger = true
        end
      end

      -- remove nil keys whenever a value was removed
      if trigger then
        local count = 1
        for id, data in pairs(nameplate.debuffcache) do
          if id ~= count then
            nameplate.debuffcache[count] = nameplate.debuffcache[id]
            nameplate.debuffcache[id] = nil
          end
          count = count + 1
        end
        update = true
      end
    end

    -- run full updates if required
    if update then
      nameplates:OnDataChanged(nameplate)
    end

    -- target zoom
    local w, h = nameplate.health:GetWidth(), nameplate.health:GetHeight()
    if target and C.nameplates.targetzoom == "1" then
      local zoomval = tonumber(C.nameplates.targetzoomval)+1
      local wc = tonumber(C.nameplates.width)*zoomval
      local hc = tonumber(C.nameplates.heighthealth)*(zoomval*.9)
      local animation = false

      if wc >= w then
        wc = w*1.05
        nameplate.health:SetWidth(wc)
        nameplate.health.zoomTransition = true
        animation = true
      end

      if hc >= h then
        hc = h*1.05
        nameplate.health:SetHeight(hc)
        nameplate.health.zoomTransition = true
        animation = true
      end

      if animation == false and not nameplate.health.zoomed then
        nameplate.health:SetWidth(wc)
        nameplate.health:SetHeight(hc)
        nameplate.health.zoomTransition = nil
        nameplate.health.zoomed = true
      end
    elseif nameplate.health.zoomed or nameplate.health.zoomTransition then
      local wc = tonumber(C.nameplates.width)
      local hc = tonumber(C.nameplates.heighthealth)
      local animation = false

      if wc <= w then
        wc = w*.95
        nameplate.health:SetWidth(wc)
        animation = true
      end

      if hc <= h then
        hc = h*0.95
        nameplate.health:SetHeight(hc)
        animation = true
      end

      if animation == false then
        nameplate.health:SetWidth(wc)
        nameplate.health:SetHeight(hc)
        nameplate.health.zoomTransition = nil
        nameplate.health.zoomed = nil
      end
    end

    -- castbar update
    if C.nameplates["showcastbar"] == "1" then
      local cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(target and "target" or name)

      if not cast then
        nameplate.castbar:Hide()
      elseif cast then
        local duration = endTime - startTime
        nameplate.castbar:SetMinMaxValues(0,  duration/1000)
        nameplate.castbar:SetValue(GetTime() - startTime/1000)
        nameplate.castbar.text:SetText(round(startTime/1000 + duration/1000 - GetTime(),1))
        if C.nameplates.spellname == "1" then
          nameplate.castbar.spell:SetText(cast)
        else
          nameplate.castbar.spell:SetText("")
        end
        nameplate.castbar:Show()

        if texture then
          nameplate.castbar.icon.tex:SetTexture(texture)
          nameplate.castbar.icon.tex:SetTexCoord(.1,.9,.1,.9)
        end
      end
    else
      nameplate.castbar:Hide()
    end
  end

  -- set nameplate game settings
  nameplates.SetGameVariables = function()
    -- update visibility (hostile)
    if C.nameplates["showhostile"] == "1" then
      _G.NAMEPLATES_ON = true
      ShowNameplates()
    else
      _G.NAMEPLATES_ON = nil
      HideNameplates()
    end

    -- update visibility (hostile)
    if C.nameplates["showfriendly"] == "1" then
      _G.FRIENDNAMEPLATES_ON = true
      ShowFriendNameplates()
    else
      _G.FRIENDNAMEPLATES_ON = nil
      HideFriendNameplates()
    end
  end

  nameplates:SetGameVariables()

  nameplates.UpdateConfig = function()
    -- update debuff filters
    DebuffFilterPopulate()

    -- update nameplate visibility
    nameplates:SetGameVariables()

    -- apply all config changes
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
