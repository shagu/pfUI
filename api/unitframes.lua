-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

pfUI.uf = CreateFrame("Frame", nil, UIParent)
pfUI.uf:SetScript("OnUpdate", function()
  if InCombatLockdown and not InCombatLockdown() then
    for frame in pairs(pfUI.uf.delayed) do
      frame:UpdateVisibility()
      pfUI.uf.delayed[frame] = nil
    end
  end
end)

pfUI.uf.frames = {}
pfUI.uf.delayed = {}

local scanner
local glow = {
  edgeFile = pfUI.media["img:glow"], edgeSize = 8,
  insets = {left = 0, right = 0, top = 0, bottom = 0},
}

local glow2 = {
  edgeFile = pfUI.media["img:glow2"], edgeSize = 8,
  insets = {left = 0, right = 0, top = 0, bottom = 0},
}

local function BuffOnUpdate()
  local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(PLAYER_BUFF_START_ID+this.id,"HELPFUL"))
  CooldownFrame_SetTimer(this.cd, GetTime(), timeleft, 1)
end

local function TargetBuffOnUpdate()
  local name, rank, icon, count, duration, timeleft = _G.UnitBuff("target", this.id)
  if duration and timeleft then
    CooldownFrame_SetTimer(this.cd, GetTime() + timeleft - duration, duration, 1)
  else
    CooldownFrame_SetTimer(this.cd, 0, 0, 0)
  end
end

local function BuffOnEnter()
  local parent = this:GetParent()
  if not parent.label then return end

  GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
  if parent.label == "player" then
    GameTooltip:SetPlayerBuff(GetPlayerBuff(PLAYER_BUFF_START_ID+this.id,"HELPFUL"))
  else
    GameTooltip:SetUnitBuff(parent.label .. parent.id, this.id)
  end

  if IsShiftKeyDown() then
    local texture = parent.label == "player" and GetPlayerBuffTexture(GetPlayerBuff(PLAYER_BUFF_START_ID+this.id,"HELPFUL")) or UnitBuff(parent.label .. parent.id, this.id)

    local playerlist = ""
    local first = true

    if UnitInRaid("player") then
      for i=1,40 do
        local unitstr = "raid" .. i
        if not UnitHasBuff(unitstr, texture) and UnitName(unitstr) then
          playerlist = playerlist .. ( not first and ", " or "") .. GetUnitColor(unitstr) .. UnitName(unitstr) .. "|r"
          first = nil
        end
      end
    else
      if not UnitHasBuff("player", texture) then
        playerlist = playerlist .. ( not first and ", " or "") .. GetUnitColor("player") .. UnitName("player") .. "|r"
        first = nil
      end

      for i=1,4 do
        local unitstr = "party" .. i
        if not UnitHasBuff(unitstr, texture) and UnitName(unitstr) then
          playerlist = playerlist .. ( not first and ", " or "") .. GetUnitColor(unitstr) .. UnitName(unitstr) .. "|r"
          first = nil
        end
      end
    end

    if strlen(playerlist) > 0 then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(T["Unbuffed"] .. ":", .3, 1, .8)
      GameTooltip:AddLine(playerlist,1,1,1,1)
      GameTooltip:Show()
    end
  end
end

local function BuffOnLeave()
  GameTooltip:Hide()
end

local function BuffOnClick()
  if this:GetParent().label == "player" then
    CancelPlayerBuff(GetPlayerBuff(PLAYER_BUFF_START_ID+this.id,"HELPFUL"))
  end
end

local function DebuffOnUpdate()
  if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .4 end
  local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(PLAYER_BUFF_START_ID+this.id,"HARMFUL"))
  CooldownFrame_SetTimer(this.cd, GetTime(), timeleft, 1)
end

local function DebuffOnEnter()
  if not this:GetParent().label then return end

  GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
  if this:GetParent().label == "player" then
    GameTooltip:SetPlayerBuff(GetPlayerBuff(PLAYER_BUFF_START_ID+this.id,"HARMFUL"))
  else
    GameTooltip:SetUnitDebuff(this:GetParent().label .. this:GetParent().id, this.id)
  end
end

local function DebuffOnLeave()
  GameTooltip:Hide()
end

local function DebuffOnClick()
  if this:GetParent().label == "player" then
    CancelPlayerBuff(GetPlayerBuff(PLAYER_BUFF_START_ID+this.id,"HARMFUL"))
  end
end

local function UpdateVisibilityScanner(self)
  local self = self or this
  if ( self.limit or 1) > GetTime() then return else self.limit = GetTime() + .2 end
  self.frame:UpdateVisibility()
end

local aggrodata = { }
function pfUI.api.UnitHasAggro(unit)
  if aggrodata[unit] and GetTime() < aggrodata[unit].check + 1 then
    return aggrodata[unit].state
  end

  aggrodata[unit] = aggrodata[unit] or { }
  aggrodata[unit].check = GetTime()
  aggrodata[unit].state = 0

  if UnitExists(unit) and UnitIsFriend(unit, "player") then
    for u in pairs(pfValidUnits) do
      local t = u .. "target"
      local tt = t .. "target"

      if UnitExists(t) and UnitIsUnit(t, unit) and UnitCanAttack(u, unit) then
        aggrodata[unit].state = aggrodata[unit].state + 1
      end

      if UnitExists(tt) and UnitIsUnit(tt, unit) and UnitCanAttack(t, unit) then
        aggrodata[unit].state = aggrodata[unit].state + 1
      end
    end
  end

  return aggrodata[unit].state
end

pfUI.uf.glow = CreateFrame("Frame")
pfUI.uf.glow:SetScript("OnUpdate", function()
  local fpsmod = GetFramerate() / 30
  if not this.val or this.val >= .8 then
    this.mod = -0.01 / fpsmod
  elseif this.val <= .4 then
    this.mod = 0.01  / fpsmod
  end
  this.val = this.val + this.mod
end)

pfUI.uf.glow.mod = 0
pfUI.uf.glow.val = 0

function pfUI.uf.glow.UpdateGlowAnimation()
  this:SetAlpha(pfUI.uf.glow.val)
end

function pfUI.uf:UpdateVisibility()
  local self = self or this

  -- we're infight, delay the update
  if InCombatLockdown and InCombatLockdown() then
    pfUI.uf.delayed[self] = true
    return
  end

  -- cache result of strsub to avoid repeating calls
  if not self.cache_raid then
    if strsub(self:GetName(),0,6) == "pfRaid" then
      self.cache_raid = tonumber(strsub(self:GetName(),7,8))
    else
      self.cache_raid = 0
    end
  end

  -- show groupframes as raid
  if self.cache_raid > 0 then
    local id = self.cache_raid

    -- always show self in raidframes
    if not UnitInRaid("player") and GetNumPartyMembers() == 0 and C.unitframes.selfinraid == "1" and id == 1 then
      self.id = ""
      self.label = "player"

    -- use raidframes for groups
    elseif not UnitInRaid("player") and GetNumPartyMembers() > 0 and C.unitframes.raidforgroup == "1" then
      if id == 1 then
        self.id = ""
        self.label = "player"
      elseif id <= 5 then
        self.id = id - 1
        self.label = "party"
      end

    -- reset to regular raid unitstrings
    elseif self.label == "party" or self.label == "player" then
      self.id = id
      self.label = "raid"
    end
  end

  -- display every unit as player while pfUI.uf.showall is set
  if pfUI.uf.showall then
    self._label = self._label or self.label
    self._id = self._id or self.id
    self.label, self.id = "player", ""
  elseif not pfUI.uf.showall and self._label and self._id then
    self.label, self.id = self._label, self._id
    self._label, self._id = nil, nil
  end

  local unitstr = string.format("%s%s", self.label or "", self.id or "")
  local visibility = string.format("[target=%s,exists] show; hide", unitstr)

  if pfUI.unlock and pfUI.unlock:IsShown() then
    -- display during unlock mode
    visibility = "show"
    self.visible = true
  elseif self.config.visible == "0" then
    -- frame shall not be visible
    visibility = "hide"
    self.visible = nil
  elseif C["unitframes"]["group"]["hide_in_raid"] == "1" and self.label and strsub(self.label,0,5) == "party" and UnitInRaid("player") then
    -- hide group while in raid and option is set
    visibility = "hide"
    self.visible = nil
  elseif ( self.fname == "Group0" or self.fname == "PartyPet0" or self.fname == "Party0Target" )
  and (GetNumPartyMembers() <= 0 or (C["unitframes"]["group"]["hide_in_raid"] == "1" and UnitInRaid("player"))) then
     -- hide self in group if solo or hide in raid is set
     visibility = "hide"
     self.visible = nil
  end

  -- tbc visibility
  if pfUI.client > 11200 then
    self:SetAttribute("unit", unitstr)

    -- update visibility condition on change
    if self.visibilitycondition ~= visibility then
      RegisterStateDriver(self, 'visibility', visibility)
      self.visibilitycondition = visibility
      self.visible = true
    end

    return
  end

  -- vanilla visibility
  if self.unitname and self.unitname ~= "focus" then
    self:Show()
  elseif visibility == "hide" then
    self:Hide()
  elseif visibility == "show" then
    self:Show()
  else
    if UnitName(unitstr) then
      -- hide existing but too far away pet and pets of old group members
      if self.label == "partypet" then
        if not UnitIsVisible(unitstr) or not UnitExists("party" .. self.id) then
          self:Hide()
          return
        end
      elseif self.label == "pettarget" then
        if not UnitIsVisible(unitstr) or not UnitExists("pet") then
          self.frame:Hide()
          return
        end
      end
      self:Show()
    else
      self.lastUnit = nil
      self:Hide()
    end
  end
end

function pfUI.uf:UpdateFrameSize()
  local rawborder, default_border = GetBorderSize("unitframes")
  local spacing = self.config.pspace * GetPerfectPixel()
  local width = self.config.width
  local height = self.config.height
  local pheight = self.config.pheight
  local real_height = height + spacing + pheight + 2*default_border
  if spacing ~= abs(spacing) and abs(spacing) > tonumber(pheight) then
    real_height = height
    spacing = 0
  end

  local portrait = 0
  if self.config.portrait == "left" or self.config.portrait == "right" then
    self.portrait:SetWidth(real_height)
    self.portrait:SetHeight(real_height)
    portrait = real_height + spacing + 2*default_border
  end

  self:SetWidth(width + portrait)
  self:SetHeight(real_height)
end

function pfUI.uf:UpdateConfig()
  local f = self
  local C = pfUI_config
  local rawborder, default_border = GetBorderSize("unitframes")

  local relative_point = "BOTTOM"
  if f.config.panchor == "TOPLEFT" then
     relative_point = "BOTTOMLEFT"
  elseif f.config.panchor == "TOPRIGHT" then
     relative_point = "BOTTOMRIGHT"
  end

  f.dispellable = nil
  f.indicators = nil
  f.indicator_custom = nil

  f.alpha_visible = tonumber(f.config.alpha_visible)
  f.alpha_outrange = tonumber(f.config.alpha_outrange)
  f.alpha_offline = tonumber(f.config.alpha_offline)

  f:SetFrameStrata("BACKGROUND")

  f.glow:SetFrameStrata("BACKGROUND")
  f.glow:SetFrameLevel(0)
  f.glow:SetBackdrop(glow2)
  f.glow:SetPoint("TOPLEFT", f, "TOPLEFT", -6 - default_border,6 + default_border)
  f.glow:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 6 + default_border,-6 - default_border)
  f.glow:SetScript("OnUpdate", pfUI.uf.glow.UpdateGlowAnimation)
  f.glow:Hide()

  f.hp:ClearAllPoints()
  f.hp:SetPoint("TOP", 0, 0)

  f.hp:SetWidth(f.config.width)
  f.hp:SetHeight(f.config.height)
  if tonumber(f.config.height) < 0 then f.hp:Hide() end
  pfUI.api.CreateBackdrop(f.hp, default_border)

  f.hp.bar:SetStatusBarTexture(pfUI.media[f.config.bartexture])
  f.hp.bar:SetAllPoints(f.hp)
  if f.config.verticalbar == "1" then
    f.hp.bar:SetOrientation("VERTICAL")
  else
    f.hp.bar:SetOrientation("HORIZONTAL")
  end

  local custombg = f.config.defcolor == "0" and f.config.custombg or C.unitframes.custombg
  local custombgcolor = f.config.defcolor == "0" and f.config.custombgcolor or C.unitframes.custombgcolor

  if custombg == "1" then
    local cr, cg, cb, ca = pfUI.api.strsplit(",", custombgcolor)
    cr, cg, cb, ca = tonumber(cr), tonumber(cg), tonumber(cb), tonumber(ca)
    f.hp.bar:SetStatusBarBackgroundTexture(cr,cg,cb,ca)
  end

  f.power:ClearAllPoints()
  f.power:SetPoint(f.config.panchor, f.hp, relative_point, 0, -2*default_border - f.config.pspace * GetPerfectPixel())
  f.power:SetWidth((f.config.pwidth ~= "-1" and f.config.pwidth or f.config.width))
  f.power:SetHeight(f.config.pheight)
  if tonumber(f.config.pheight) < 0 then f.power:Hide() end

  pfUI.api.CreateBackdrop(f.power, default_border)
  f.power.bar:SetStatusBarTexture(pfUI.media[f.config.bartexture])
  f.power.bar:SetAllPoints(f.power)
  f.power.bar:SetFrameStrata("LOW")

  local custompbg = f.config.defcolor == "0" and f.config.custompbg or C.unitframes.custompbg
  local custompbgcolor = f.config.defcolor == "0" and f.config.custompbgcolor or C.unitframes.custompbgcolor

  if custompbg == "1" then
    local cr, cg, cb, ca = pfUI.api.strsplit(",", custompbgcolor)
    cr, cg, cb, ca = tonumber(cr), tonumber(cg), tonumber(cb), tonumber(ca)
    f.power.bar:SetStatusBarBackgroundTexture(cr,cg,cb,ca)
  end

  f.portrait:SetFrameStrata("LOW")
  f.portrait.tex:SetAllPoints(f.portrait)
  f.portrait.tex:SetTexCoord(.1, .9, .1, .9)
  f.portrait.model:SetFrameStrata("LOW")
  f.portrait.model:SetAllPoints(f.portrait)

  if f.config.portrait == "bar" then
    f.portrait:SetParent(f.hp.bar)
    f.portrait:SetAllPoints(f.hp.bar)

    f.portrait:SetAlpha(C.unitframes.portraitalpha)
    if f.portrait.backdrop then f.portrait.backdrop:Hide() end

    -- place portrait below fonts
    f.portrait:SetFrameStrata("BACKGROUND")
    f.portrait.model:SetFrameStrata("BACKGROUND")
    f.portrait.model:SetFrameLevel(3)

    f.portrait:Show()
  elseif f.config.portrait == "left" then
    f.portrait:SetParent(f)
    f.portrait:ClearAllPoints()
    f.portrait:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)

    f.hp:ClearAllPoints()
    f.hp:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)

    f.portrait:SetAlpha(f:GetAlpha())

    -- make sure incHeal is above
    f.portrait:SetFrameStrata("BACKGROUND")
    f.portrait.model:SetFrameStrata("BACKGROUND")
    f.portrait.model:SetFrameLevel(1)

    pfUI.api.CreateBackdrop(f.portrait, default_border)
    f.portrait.backdrop:Show()
    f.portrait:Show()
  elseif f.config.portrait == "right" then
    f.portrait:SetParent(f)
    f.portrait:ClearAllPoints()
    f.portrait:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)

    f.hp:ClearAllPoints()
    f.hp:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)

    f.portrait:SetAlpha(f:GetAlpha())

    -- make sure incHeal is above
    f.portrait:SetFrameStrata("BACKGROUND")
    f.portrait.model:SetFrameStrata("BACKGROUND")
    f.portrait.model:SetFrameLevel(1)

    pfUI.api.CreateBackdrop(f.portrait, default_border)
    f.portrait.backdrop:Show()
    f.portrait:Show()
  else
    f.portrait:Hide()
  end

  if f.config.hitindicator == "1" then
    f.feedbackText:SetFont(pfUI.media[f.config.hitindicatorfont], f.config.hitindicatorsize, "OUTLINE")
    f.feedbackFontHeight = f.config.hitindicatorsize
    f.feedbackStartTime = GetTime()
    if f.config.portrait == "bar" or f.config.portrait == "off" then
      f.feedbackText:SetParent(f.hp.bar)
      f.feedbackText:ClearAllPoints()
      f.feedbackText:SetPoint("CENTER", f.hp.bar, "CENTER")
    else
      f.feedbackText:SetParent(f.portrait)
      f.feedbackText:ClearAllPoints()
      f.feedbackText:SetPoint("CENTER", f.portrait, "CENTER")
    end
    f:RegisterEvent("UNIT_COMBAT")
  else
    f.feedbackText:Hide()
    f:UnregisterEvent("UNIT_COMBAT")
  end

  f.hpLeftText:SetFont(pfUI.font_unit, C.global.font_unit_size, C.global.font_unit_style)
  f.hpLeftText:SetJustifyH("LEFT")
  f.hpLeftText:SetFontObject(GameFontWhite)
  f.hpLeftText:SetParent(f.hp.bar)
  f.hpLeftText:ClearAllPoints()
  f.hpLeftText:SetPoint("TOPLEFT",f.hp.bar, "TOPLEFT", 2*default_border, 1)
  f.hpLeftText:SetPoint("BOTTOMRIGHT",f.hp.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.hpRightText:SetFont(pfUI.font_unit, C.global.font_unit_size, C.global.font_unit_style)
  f.hpRightText:SetJustifyH("RIGHT")
  f.hpRightText:SetFontObject(GameFontWhite)
  f.hpRightText:SetParent(f.hp.bar)
  f.hpRightText:ClearAllPoints()
  f.hpRightText:SetPoint("TOPLEFT",f.hp.bar, "TOPLEFT", 2*default_border, 1)
  f.hpRightText:SetPoint("BOTTOMRIGHT",f.hp.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.hpCenterText:SetFont(pfUI.font_unit, C.global.font_unit_size, C.global.font_unit_style)
  f.hpCenterText:SetJustifyH("CENTER")
  f.hpCenterText:SetFontObject(GameFontWhite)
  f.hpCenterText:SetParent(f.hp.bar)
  f.hpCenterText:ClearAllPoints()
  f.hpCenterText:SetPoint("TOPLEFT",f.hp.bar, "TOPLEFT", 2*default_border, 1)
  f.hpCenterText:SetPoint("BOTTOMRIGHT",f.hp.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.powerLeftText:SetFont(pfUI.font_unit, C.global.font_unit_size, C.global.font_unit_style)
  f.powerLeftText:SetJustifyH("LEFT")
  f.powerLeftText:SetFontObject(GameFontWhite)
  f.powerLeftText:SetParent(f.power.bar)
  f.powerLeftText:ClearAllPoints()
  f.powerLeftText:SetPoint("TOPLEFT",f.power.bar, "TOPLEFT", 2*default_border, 1)
  f.powerLeftText:SetPoint("BOTTOMRIGHT",f.power.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.powerRightText:SetFont(pfUI.font_unit, C.global.font_unit_size, C.global.font_unit_style)
  f.powerRightText:SetJustifyH("RIGHT")
  f.powerRightText:SetFontObject(GameFontWhite)
  f.powerRightText:SetParent(f.power.bar)
  f.powerRightText:ClearAllPoints()
  f.powerRightText:SetPoint("TOPLEFT",f.power.bar, "TOPLEFT", 2*default_border, 1)
  f.powerRightText:SetPoint("BOTTOMRIGHT",f.power.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.powerCenterText:SetFont(pfUI.font_unit, C.global.font_unit_size, C.global.font_unit_style)
  f.powerCenterText:SetJustifyH("CENTER")
  f.powerCenterText:SetFontObject(GameFontWhite)
  f.powerCenterText:SetParent(f.power.bar)
  f.powerCenterText:ClearAllPoints()
  f.powerCenterText:SetPoint("TOPLEFT",f.power.bar, "TOPLEFT", 2*default_border, 1)
  f.powerCenterText:SetPoint("BOTTOMRIGHT",f.power.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.incHeal:SetHeight(f.config.height)
  f.incHeal:SetWidth(f.config.width)
  f.incHeal.texture:SetTexture(pfUI.media["img:bar"])
  f.incHeal.texture:SetVertexColor(0, 1, 0, 0.5)
  f.incHeal:Hide()

  f.incHeal:SetScript("OnShow", function()
    if pfUI.prediction and f.label and f.id then
      pfUI.prediction:TriggerUpdate(UnitName(f.label .. f.id))
    end
  end)

  if f.config.verticalbar == "0" then
    f.incHeal:ClearAllPoints()
    f.incHeal:SetPoint("TOPLEFT", f.hp.bar, "TOPLEFT", 0, 0)
  else
    f.incHeal:ClearAllPoints()
    f.incHeal:SetPoint("BOTTOM", f.hp.bar, "BOTTOM", 0, 0)
  end

  f.ressIcon:SetFrameLevel(16)
  f.ressIcon:SetWidth(32)
  f.ressIcon:SetHeight(32)
  f.ressIcon:SetPoint("CENTER", f, "CENTER", 0, 4)
  f.ressIcon.texture:SetTexture(pfUI.media["img:ress"])
  f.ressIcon.texture:SetAllPoints(f.ressIcon)
  f.ressIcon:Hide()

  f.leaderIcon:SetWidth(10)
  f.leaderIcon:SetHeight(10)
  f.leaderIcon:SetPoint("CENTER", f, "TOPLEFT", 0, 0)
  f.leaderIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-LeaderIcon")
  f.leaderIcon.texture:SetAllPoints(f.leaderIcon)
  f.leaderIcon:Hide()

  f.lootIcon:SetWidth(10)
  f.lootIcon:SetHeight(10)
  f.lootIcon:SetPoint("CENTER", f, "LEFT", 0, 0)
  f.lootIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-MasterLooter")
  f.lootIcon.texture:SetAllPoints(f.lootIcon)
  f.lootIcon:Hide()

  f.pvpIcon:SetWidth(16)
  f.pvpIcon:SetHeight(16)
  f.pvpIcon:SetPoint("CENTER", 0, 0)
  f.pvpIcon.texture:SetTexture(pfUI.media["img:pvp"])
  f.pvpIcon.texture:SetAllPoints(f.pvpIcon)
  f.pvpIcon.texture:SetVertexColor(1,1,1,.5)
  f.pvpIcon:Hide()

  f.raidIcon:SetWidth(f.config.raidiconsize)
  f.raidIcon:SetHeight(f.config.raidiconsize)
  f.raidIcon:SetPoint("TOP", f, "TOP", 0, 6)
  f.raidIcon.texture:SetTexture(pfUI.media["img:raidicons"])
  f.raidIcon.texture:SetAllPoints(f.raidIcon)
  f.raidIcon:Hide()

  f.restIcon:SetWidth(16)
  f.restIcon:SetHeight(16)
  f.restIcon:SetPoint("TOP", f, "TOPLEFT", 0, -1)
  f.restIcon.texture:SetTexture("Interface\\CharacterFrame\\UI-StateIcon", true)
  f.restIcon.texture:SetTexCoord(0, .5, 0, .421875)
  f.restIcon.texture:SetAllPoints(f.restIcon)
  f.restIcon:Hide()

  f.happinessIcon:SetWidth(tonumber(C.unitframes.pet.happinesssize))
  f.happinessIcon:SetHeight(tonumber(C.unitframes.pet.happinesssize))
  f.happinessIcon:SetPoint("CENTER", f, "TOPLEFT", default_border, -default_border)
  f.happinessIcon.texture:SetTexture(pfUI.media["img:neutral"])
  f.happinessIcon.texture:SetAllPoints(f.happinessIcon)
  f.happinessIcon.texture:SetVertexColor(1, 1, 0, 1)
  f.happinessIcon:Hide()

  if f.config.buffs == "off" then
    for i=1, 32 do
      if f.buffs and f.buffs[i] then
        f.buffs[i]:Hide()
        f.buffs[i] = nil
      end
    end
    f.buffs = nil
  else
    f.buffs = f.buffs or {}

    for i=1, 32 do
      if i > tonumber(f.config.bufflimit) then break end

      local perrow = f.config.buffperrow
      local row = floor((i-1) / perrow)

      f.buffs[i] = f.buffs[i] or CreateFrame("Button", "pfUI" .. f.fname .. "Buff" .. i, f)
      f.buffs[i].texture = f.buffs[i].texture or f.buffs[i]:CreateTexture()
      f.buffs[i].texture:SetTexCoord(.08, .92, .08, .92)
      f.buffs[i].texture:SetAllPoints()
      f.buffs[i].stacks = f.buffs[i].stacks or f.buffs[i]:CreateFontString(nil, "OVERLAY", f.buffs[i])
      f.buffs[i].stacks:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
      f.buffs[i].stacks:SetPoint("BOTTOMRIGHT", f.buffs[i], 2, -2)
      f.buffs[i].stacks:SetJustifyH("LEFT")
      f.buffs[i].stacks:SetShadowColor(0, 0, 0)
      f.buffs[i].stacks:SetShadowOffset(0.8, -0.8)
      f.buffs[i].stacks:SetTextColor(1,1,.5)
      f.buffs[i].cd = f.buffs[i].cd or CreateFrame(COOLDOWN_FRAME_TYPE, nil, f.buffs[i])
      f.buffs[i].cd.pfCooldownType = "ALL"
      f.buffs[i].cd:SetAlpha(0)
      f.buffs[i].id = i
      f.buffs[i]:Hide()

      CreateBackdrop(f.buffs[i], default_border)
      CreateBackdropShadow(f.buffs[i])

      f.buffs[i]:RegisterForClicks("RightButtonUp")
      f.buffs[i]:ClearAllPoints()

      local invert_h, invert_v, af
      if f.config.buffs == "TOPLEFT" then
        invert_h = 1
        invert_v = 1
        af = "BOTTOMLEFT"
      elseif f.config.buffs == "BOTTOMLEFT" then
        invert_h = -1
        invert_v = 1
        af = "TOPLEFT"
      elseif f.config.buffs == "TOPRIGHT" then
        invert_h = 1
        invert_v = -1
        af = "BOTTOMRIGHT"
      elseif f.config.buffs == "BOTTOMRIGHT" then
        invert_h = -1
        invert_v = -1
        af = "TOPRIGHT"
      end

      f.buffs[i]:SetPoint(af, f, f.config.buffs,
      invert_v * (i-1-row*perrow)*(2*default_border + f.config.buffsize + 1),
      invert_h * (row*(2*default_border + f.config.buffsize + 1) + (2*default_border + 1)))

      f.buffs[i]:SetWidth(f.config.buffsize)
      f.buffs[i]:SetHeight(f.config.buffsize)

      if f:GetName() == "pfPlayer" then
        f.buffs[i]:SetScript("OnUpdate", BuffOnUpdate)
      elseif f:GetName() == "pfTarget" and pfUI.expansion == "tbc" then
        f.buffs[i]:SetScript("OnUpdate", TargetBuffOnUpdate)
      end

      f.buffs[i]:SetScript("OnEnter", BuffOnEnter)
      f.buffs[i]:SetScript("OnLeave", BuffOnLeave)
      f.buffs[i]:SetScript("OnClick", BuffOnClick)
    end
  end

  if f.config.debuffs == "off" then
    for i=1, 32 do
      if f.debuffs and f.debuffs[i] then
        f.debuffs[i]:Hide()
        f.debuffs[i] = nil
      end
    end
    f.debuffs = nil
  else
    f.debuffs = f.debuffs or {}

    for i=1, 32 do
      if i > tonumber(f.config.debufflimit) then break end

      f.debuffs[i] = f.debuffs[i] or CreateFrame("Button", "pfUI" .. f.fname .. "Debuff" .. i, f)
      f.debuffs[i].texture = f.debuffs[i].texture or f.debuffs[i]:CreateTexture()
      f.debuffs[i].texture:SetTexCoord(.08, .92, .08, .92)
      f.debuffs[i].texture:SetAllPoints()
      f.debuffs[i].stacks = f.debuffs[i].stacks or f.debuffs[i]:CreateFontString(nil, "OVERLAY", f.debuffs[i])
      f.debuffs[i].stacks:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
      f.debuffs[i].stacks:SetPoint("BOTTOMRIGHT", f.debuffs[i], 2, -2)
      f.debuffs[i].stacks:SetJustifyH("LEFT")
      f.debuffs[i].stacks:SetShadowColor(0, 0, 0)
      f.debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
      f.debuffs[i].stacks:SetTextColor(1,1,.5)
      f.debuffs[i].cd = f.debuffs[i].cd or CreateFrame(COOLDOWN_FRAME_TYPE, nil, f.debuffs[i])
      f.debuffs[i].cd.pfCooldownType = "ALL"
      f.debuffs[i].cd:SetAlpha(0)
      f.debuffs[i].id = i
      f.debuffs[i]:Hide()

      CreateBackdrop(f.debuffs[i], default_border)
      CreateBackdropShadow(f.debuffs[i])

      f.debuffs[i]:RegisterForClicks("RightButtonUp")
      f.debuffs[i]:ClearAllPoints()
      f.debuffs[i]:SetWidth(f.config.debuffsize)
      f.debuffs[i]:SetHeight(f.config.debuffsize)
      f.debuffs[i]:SetNormalTexture(nil)

      if f:GetName() == "pfPlayer" then
        f.debuffs[i]:SetScript("OnUpdate", DebuffOnUpdate)
      end

      f.debuffs[i]:SetScript("OnEnter", DebuffOnEnter)
      f.debuffs[i]:SetScript("OnLeave", DebuffOnLeave)
      f.debuffs[i]:SetScript("OnClick", DebuffOnClick)
    end
  end

  if f.config.visible == "1" then
    pfUI.uf:RefreshUnit(f, "all")
    f:EnableScripts()
    f:EnableEvents()
    f:UpdateFrameSize()
  else
    f:UnregisterAllEvents()
    f:Hide()
  end
end

function pfUI.uf.OnShow()
  pfUI.uf:RefreshUnit(this)
end

function pfUI.uf.OnEvent()
  -- update indicators
  if event == "PARTY_LEADER_CHANGED" or
     event == "PARTY_LOOT_METHOD_CHANGED" or
     event == "PARTY_MEMBERS_CHANGED" or
     event == "RAID_TARGET_UPDATE" or
     event == "RAID_ROSTER_UPDATE" or
     event == "PLAYER_UPDATE_RESTING"
  then
    pfUI.uf:RefreshIndicators(this)
  end

  -- abort on broken unitframes (e.g focus)
  if not this.label then return end

  -- update regular frames
  if event == "PLAYER_ENTERING_WORLD" then
    pfUI.uf:RefreshUnit(this, "all")
  elseif this.label == "target" and event == "PLAYER_TARGET_CHANGED" then
    pfUI.uf:RefreshUnit(this, "all")
  elseif ( this.label == "raid" or this.label == "party" or this.label == "player" ) and event == "PARTY_MEMBERS_CHANGED" then
    pfUI.uf:RefreshUnit(this, "all")
  elseif ( this.label == "raid" or this.label == "party" ) and event == "PARTY_MEMBER_ENABLE" then
    pfUI.uf:RefreshUnit(this, "all")
  elseif ( this.label == "raid" or this.label == "party" ) and event == "PARTY_MEMBER_DISABLE" then
    pfUI.uf:RefreshUnit(this, "all")
  elseif ( this.label == "raid" or this.label == "party" ) and event == "RAID_ROSTER_UPDATE" then
    pfUI.uf:RefreshUnit(this, "all")
  elseif this.label == "player" and (event == "PLAYER_AURAS_CHANGED" or event == "UNIT_INVENTORY_CHANGED") then
    pfUI.uf:RefreshUnit(this, "aura")
  elseif this.label == "pet" and event == "UNIT_PET" then
    pfUI.uf:RefreshUnit(this, "all")
  elseif this.label == "pet" and event == "UNIT_HAPPINESS" then
    pfUI.uf:RefreshUnit(this)
  -- UNIT_XXX Events
  elseif arg1 and arg1 == this.label .. this.id then
    if event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" then
      pfUI.uf:RefreshUnit(this, "portrait")
    elseif event == "UNIT_AURA" then
      pfUI.uf:RefreshUnit(this, "aura")
    elseif event == "UNIT_FACTION" then
      pfUI.uf:RefreshUnit(this, "pvp")
    elseif event == "UNIT_COMBAT" then
      CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5)
    else
      pfUI.uf:RefreshUnit(this)
    end
  end
end

function pfUI.uf.OnUpdate()
  -- update combat feedback
  if this.feedbackText then CombatFeedback_OnUpdate(arg1) end

  -- early return on unset focus frames
  if this.unitname then
    local unitname = ( this.label and UnitName(this.label) ) or ""

    if this.unitname == "focus" then
      return
    end

    -- focus unit detection
    if this.unitname ~= strlower(unitname) then
      -- invalid focus frame
      for unit, bool in pairs(pfValidUnits) do
        local scan = UnitName(unit) or ""
        if this.unitname == strlower(scan) then
          this.label = unit
          if this.portrait then this.portrait.model.lastUnit = nil end
          this.instantRefresh = true
          pfUI.uf:RefreshUnit(this, "all")
          return
        end
        this.label = nil
        this.instantRefresh = true
        this.hp.bar:SetStatusBarColor(.2,.2,.2)
      end
    end
  end

  if not this.label then return end

  -- update portrait on first visible frame
  if this.portrait and this.portrait.model and this.portrait.model.update then
    this.portrait.model.lastUnit = UnitName(this.portrait.model.update)
    this.portrait.model:SetUnit(this.portrait.model.update)
    this.portrait.model:SetCamera(0)
    this.portrait.model.update = nil
  end

  -- trigger eventless actions (online/offline/range)
  if not this.lastTick then this.lastTick = GetTime() + (this.tick or .2) end
  if this.lastTick and this.lastTick < GetTime() then
    local unitstr = this.label .. this.id

    this.lastTick = GetTime() + (this.tick or .2)
    pfUI.uf:RefreshUnitState(this)
    pfUI.uf:RefreshIndicators(this)

    if this.config.glowaggro == "1" and pfUI.api.UnitHasAggro(this.label .. this.id) > 0 then
      this.glow:SetBackdropBorderColor(1,.2,0)
      this.glow:Show()
    elseif this.config.glowcombat == "1" and UnitAffectingCombat(this.label .. this.id) then
      this.glow:SetBackdropBorderColor(1,1,.2)
      this.glow:Show()
    else
      this.glow:SetBackdropBorderColor(1,1,1)
      this.glow:Hide()
    end

    -- update everything on eventless frames (targettarget, etc)
    if this.tick then
      pfUI.uf:RefreshUnit(this, "all")
    end
  end
end

function pfUI.uf.OnEnter()
  if not this.label then return end
  if this.config.showtooltip == "0" then return end
  GameTooltip_SetDefaultAnchor(GameTooltip, this)
  GameTooltip:SetUnit(this.label .. this.id)
  GameTooltip:Show()
end

function pfUI.uf.OnLeave()
  GameTooltip:FadeOut()
end

function pfUI.uf.OnClick()
  if not this.label and this.unitname then
    TargetByName(this.unitname, true)
  else
    pfUI.uf:ClickAction(arg1)
  end
end

function pfUI.uf:RightClickAction(unit)
  if unit == "player" then
    ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor")
  elseif unit == "target" then
    ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
  elseif unit == "pet" then
    ToggleDropDownMenu(1, nil, PetFrameDropDown, "cursor")
  elseif unit == "party" or strfind(unit, "party%d") then
    ToggleDropDownMenu(1, nil, getglobal("PartyMemberFrame" .. this.id .. "DropDown"), "cursor")
  elseif unit == "raid" or strfind(unit, "raid%d") then
    local name = this.lastUnit
    local unitstr = this.label .. this.id
    FriendsDropDown.displayMode = "MENU"
    FriendsDropDown.initialize = function() UnitPopup_ShowMenu(_G[UIDROPDOWNMENU_OPEN_MENU], "PARTY", unitstr, name, id) end
    ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
  end
end

function pfUI.uf:EnableEvents()
  local f = self

  f:RegisterEvent("PLAYER_ENTERING_WORLD")
  f:RegisterEvent("UNIT_DISPLAYPOWER")
  f:RegisterEvent("UNIT_HEALTH")
  f:RegisterEvent("UNIT_MAXHEALTH")
  f:RegisterEvent("UNIT_MANA")
  f:RegisterEvent("UNIT_MAXMANA")
  f:RegisterEvent("UNIT_RAGE")
  f:RegisterEvent("UNIT_MAXRAGE")
  f:RegisterEvent("UNIT_ENERGY")
  f:RegisterEvent("UNIT_MAXENERGY")
  f:RegisterEvent("UNIT_FOCUS")
  f:RegisterEvent("UNIT_PORTRAIT_UPDATE")
  f:RegisterEvent("UNIT_MODEL_CHANGED")
  f:RegisterEvent("UNIT_FACTION")
  f:RegisterEvent("UNIT_AURA") -- frame=buff, frame=debuff
  f:RegisterEvent("PLAYER_AURAS_CHANGED") -- label=player && frame=buff
  f:RegisterEvent("UNIT_INVENTORY_CHANGED") -- label=player && frame=buff
  f:RegisterEvent("PARTY_MEMBERS_CHANGED") -- label=party, frame=leaderIcon
  f:RegisterEvent("PARTY_LEADER_CHANGED") -- frame=leaderIcon
  f:RegisterEvent("RAID_ROSTER_UPDATE") -- label=raidIcon
  f:RegisterEvent("PLAYER_UPDATE_RESTING") -- label=restIcon
  f:RegisterEvent("PLAYER_TARGET_CHANGED") -- label=target
  f:RegisterEvent("PARTY_LOOT_METHOD_CHANGED") -- frame=lootIcon
  f:RegisterEvent("RAID_TARGET_UPDATE") -- frame=raidIcon
  f:RegisterEvent("UNIT_PET")
  f:RegisterEvent("UNIT_HAPPINESS")

  f:RegisterForClicks('LeftButtonUp', 'RightButtonUp',
    'MiddleButtonUp', 'Button4Up', 'Button5Up')
end

function pfUI.uf:EnableScripts()
  local f = self

  -- handle secure unit button templates (> vanilla)
  if pfUI.client > 11200 then
    f.showmenu = pfUI.uf.RightClickAction
    f:SetAttribute("*type1", "target")
    f:SetAttribute("*type2", "showmenu")
  else
    f:SetScript("OnClick", pfUI.uf.OnClick)
  end

  f:SetScript("OnShow", pfUI.uf.OnShow)
  f:SetScript("OnEvent", pfUI.uf.OnEvent)
  f:SetScript("OnUpdate", pfUI.uf.OnUpdate)
  f:SetScript("OnEnter", pfUI.uf.OnEnter)
  f:SetScript("OnLeave", pfUI.uf.OnLeave)
  f:EnableClickCast()

  -- add generic visibility handler
  f.visibility:SetScript("OnUpdate", UpdateVisibilityScanner)
end

function pfUI.uf:CreateUnitFrame(unit, id, config, tick)
  local fname = (( unit == "Party" ) and "Group" or (unit or "")) .. (id or "")
  local unit = strlower(unit or "")
  local id = strlower(id or "")

  -- fake party0 units as self
  if unit == "party" and id == "0" then
    unit, id = "player", ""
  end

  if unit == "partypet" and id == "0" then
    unit, id = "pet", ""
  end

  if unit == "pettarget" and id == "0" then
    unit, id = "pettarget", ""
  end

  if unit == "party0target" then
    unit, id = "target", ""
  end

  local f = CreateFrame("Button", "pf" .. fname, UIParent, UNITFRAME_SECURE_TEMPLATE)

  -- add unitframe functions
  f.UpdateFrameSize  = pfUI.uf.UpdateFrameSize
  f.UpdateVisibility = pfUI.uf.UpdateVisibility
  f.UpdateConfig     = pfUI.uf.UpdateConfig
  f.EnableScripts    = pfUI.uf.EnableScripts
  f.EnableEvents     = pfUI.uf.EnableEvents
  f.EnableClickCast  = pfUI.uf.EnableClickCast
  f.GetColor         = pfUI.uf.GetColor

  -- cache values to the frame
  f.label = unit
  f.fname = fname
  f.id = id
  f.config = config or pfUI_config.unitframes.fallback
  f.tick = tick

  -- disable events for unknown unitstrings
  if not pfValidUnits[unit .. id] then
    f.unitname = unit
    f.label, f.id = "", ""
    f.RegisterEvent = function() return end
  end

  CreateBackdropShadow(f)

  f.hp = CreateFrame("Frame",nil, f)
  f.hp.bar = CreateStatusBar(nil, f.hp)

  f.power = CreateFrame("Frame",nil, f)
  f.power.bar = CreateStatusBar(nil, f.power)

  f.glow = CreateFrame("Frame", nil, f)

  f.hpLeftText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.hpRightText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.hpCenterText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.powerLeftText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.powerRightText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.powerCenterText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")

  f.incHeal = CreateFrame("Frame", nil, f.hp)
  f.incHeal.texture = f.incHeal:CreateTexture(nil, "BACKGROUND")
  f.incHeal.texture:SetAllPoints()

  f.ressIcon = CreateFrame("Frame", nil, f.hp.bar)
  f.ressIcon.texture = f.ressIcon:CreateTexture(nil,"BACKGROUND")

  f.leaderIcon = CreateFrame("Frame", nil, f.hp.bar)
  f.leaderIcon.texture = f.leaderIcon:CreateTexture(nil,"BACKGROUND")

  f.lootIcon = CreateFrame("Frame",nil, f.hp.bar)
  f.lootIcon.texture = f.lootIcon:CreateTexture(nil,"BACKGROUND")

  f.pvpIcon = CreateFrame("Frame", nil, f.hp.bar)
  f.pvpIcon.texture = f.pvpIcon:CreateTexture(nil,"BACKGROUND")

  f.raidIcon = CreateFrame("Frame", nil, f.hp.bar)
  f.raidIcon.texture = f.raidIcon:CreateTexture(nil,"ARTWORK")

  f.restIcon = CreateFrame("Frame", nil, f.hp.bar)
  f.restIcon.texture = f.restIcon:CreateTexture(nil, "BACKGROUND")

  f.happinessIcon = CreateFrame("Frame", nil, f.hp.bar)
  f.happinessIcon.texture = f.happinessIcon:CreateTexture(nil, "BACKGROUND")

  f.portrait = CreateFrame("Frame", "pfPortrait" .. f.label .. f.id, f)
  f.portrait.tex = f.portrait:CreateTexture("pfPortraitTexture" .. f.label .. f.id, "OVERLAY")
  f.portrait.model = CreateFrame("PlayerModel", "pfPortraitModel" .. f.label .. f.id, f.portrait)
  f.portrait.model.next = CreateFrame("PlayerModel", nil, nil)
  f.feedbackText = f:CreateFontString("pfHitIndicator" .. f.label .. f.id, "OVERLAY", "NumberFontNormalHuge")

  f.visibility = f.visibility or CreateFrame("Frame", nil, pfUI)
  f.visibility.frame = f

  f:Hide()
  f:UpdateConfig()
  f:UpdateFrameSize()
  f:EnableScripts()
  f:EnableEvents()

  if f.config.visible == "1" then
    pfUI.uf:RefreshUnit(f, "all")
    f:EnableScripts()
    f:EnableEvents()
    f:UpdateFrameSize()
  else
    f:UnregisterAllEvents()
    f:Hide()
  end

  table.insert(pfUI.uf.frames, f)
  return f
end

function pfUI.uf:RefreshUnitState(unit)
  local alpha = unit.alpha_visible
  local unlock = pfUI.unlock and pfUI.unlock:IsShown() or nil

  if not UnitIsConnected(unit.label .. unit.id) and not unlock then
    -- offline
    alpha = unit.alpha_offline
    unit.hp.bar:SetMinMaxValues(0, 100, true)
    unit.power.bar:SetMinMaxValues(0, 100, true)
    unit.hp.bar:SetValue(0)
    unit.power.bar:SetValue(0)
  elseif unit.config.faderange == "1" and not pfUI.api.UnitInRange(unit.label .. unit.id, 4) and not unlock then
    alpha = unit.alpha_outrange
  end

  -- skip if alpha is already correct
  if floor(unit:GetAlpha()*10+.5) == floor(alpha*10+.5) then return end

  -- set unitframe alpha
  unit:SetAlpha(alpha)

  -- refresh portrait alpha
  if unit.config.portrait == "bar" then
    unit.portrait:SetAlpha(pfUI_config.unitframes.portraitalpha)
  end

  -- refresh debuff indicator alpha
  local disptype = unit.config.debuff_indicator
  local indicator = unit.hp.bar.debuffindicators
  if indicator then
    indicator:SetAlpha(0)
    if ( disptype == "4" or disptype == "3" ) then
      indicator:SetAlpha(1)
    elseif disptype == "2" then
      indicator:SetAlpha(.4)
    elseif disptype == "1" then
      indicator:SetAlpha(.2)
    end
  end
end

function pfUI.uf:RefreshIndicators(unit)
  if not unit.label or not unit.id then return end
  local unitstr = unit.label .. unit.id

  if unit.leaderIcon then -- Leader Icon
    if unit.config.leadericon == "1" and UnitIsPartyLeader(unitstr) and ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 ) then
      unit.leaderIcon:Show()
    else
      unit.leaderIcon:Hide()
    end
  end

  if unit.lootIcon then -- Loot Icon
    if unit.config.looticon == "0" then
      unit.lootIcon:Hide()
    else
      -- no third return value here.. but leaving this as a hint
      local method, group, raid = GetLootMethod()
      local name = group and UnitName(group == 0 and "player" or "party"..group) or raid and UnitName("raid"..raid) or nil

      if name and name == UnitName(unitstr) then
        unit.lootIcon:Show()
      else
        unit.lootIcon:Hide()
      end
    end
  end

  if unit.pvpIcon then -- PvP Icon
    if unit.config.showPVP == "1" and UnitIsPVP(unitstr) then
      unit.pvpIcon:Show()
    else
      unit.pvpIcon:Hide()
    end
  end

  if unit.restIcon and unit:GetName() == "pfPlayer" then -- Rest Icon
    if C.unitframes.player.showRest == "1" and UnitIsUnit(unitstr, "player") and IsResting() then
      unit.restIcon:Show()
    else
      unit.restIcon:Hide()
    end
  end

  if unit.happinessIcon and unit:GetName() == "pfPet" then -- Happiness Icon
    if unit.config.happinessicon == "0" then
      unit.happinessIcon:Hide()
    else
      if UnitIsVisible("pet") then
        local happiness = GetPetHappiness()
        if happiness == 1 then
          unit.happinessIcon.texture:SetTexture(pfUI.media["img:sad"])
          unit.happinessIcon.texture:SetVertexColor(1, 0, 0, 1)
        elseif happiness == 2 then
          unit.happinessIcon.texture:SetTexture(pfUI.media["img:neutral"])
          unit.happinessIcon.texture:SetVertexColor(1, 1, 0, 1)
        else
          unit.happinessIcon.texture:SetTexture(pfUI.media["img:happy"])
          unit.happinessIcon.texture:SetVertexColor(0, 1, 0, 1)
        end
        unit.happinessIcon:Show()
      else
        unit.happinessIcon:Hide()
      end
    end
  end

  if unit.raidIcon then -- Raid Icon
    local raidIcon = UnitName(unitstr) and GetRaidTargetIndex(unitstr)
    if unit.config.raidicon == "1" and raidIcon then
      SetRaidTargetIconTexture(unit.raidIcon.texture, raidIcon)
      unit.raidIcon:Show()
    else
      unit.raidIcon:Hide()
    end
  end
end

local pfDebuffColors = {
  ["Magic"]   = { 0.1, 0.7, 0.8, 1 },
  ["Poison"]  = { 0.2, 0.7, 0.3, 1 },
  ["Curse"]   = { 0.6, 0.2, 0.6, 1 },
  ["Disease"] = { 0.9, 0.7, 0.2, 1 }
}

function pfUI.uf:RefreshUnit(unit, component)
  -- break early on misconfigured UF's
  if not unit.label then return end
  if not unit.hp then return end
  if not unit.power then return end
  if not unit.id then unit.id = "" end
  local component = component or ""

  -- don't update scanner activity
  if unit.label == "target" or unit.label == "targettarget" or unit.label == "targettargettarget" then
    if pfScanActive == true then return end
  end

  -- hide unused and invalid frames
  unit:UpdateVisibility()

  -- return on invisible unit frames
  if not unit:IsShown() and not unit.visible then return end

  -- create required fields
  local unitstr = unit.label..unit.id
  local rawborder, default_border = GetBorderSize("unitframes")

  -- Buffs
  if unit.buffs and ( component == "all" or component == "aura" ) then
    for i=1, unit.config.bufflimit do
      if not unit.buffs[i] then break end

      local texture, stacks
      if unit.label == "player" then
       stacks = GetPlayerBuffApplications(GetPlayerBuff(PLAYER_BUFF_START_ID+i,"HELPFUL"))
       texture = GetPlayerBuffTexture(GetPlayerBuff(PLAYER_BUFF_START_ID+i,"HELPFUL"))
      else
       texture, stacks = UnitBuff(unitstr, i)
      end

      unit.buffs[i].texture:SetTexture(texture)

      if texture then
        unit.buffs[i]:Show()

        if stacks > 1 then
          unit.buffs[i].stacks:SetText(stacks)
        else
          unit.buffs[i].stacks:SetText("")
        end
      else
        unit.buffs[i]:Hide()
      end
    end
  end

  -- Debuffs
  if unit.debuffs and ( component == "all" or component == "aura" ) then
    for i=1, unit.config.debufflimit do
      if not unit.debuffs[i] then break end

      local perrow = unit.config.debuffperrow
      local bperrow = unit.config.buffperrow

      local row = floor((i-1) / unit.config.debuffperrow)
      local buffrow = 0

      if unit.config.buffs == unit.config.debuffs then
        if unit.buffs[0*bperrow+1] and unit.buffs[0*bperrow+1]:IsShown() then buffrow = buffrow + 1 end
        if unit.buffs[1*bperrow+1] and unit.buffs[1*bperrow+1]:IsShown() then buffrow = buffrow + 1 end
        if unit.buffs[2*bperrow+1] and unit.buffs[2*bperrow+1]:IsShown() then buffrow = buffrow + 1 end
        if unit.buffs[3*bperrow+1] and unit.buffs[3*bperrow+1]:IsShown() then buffrow = buffrow + 1 end
      end

      local invert_h, invert_v, af
      if unit.config.debuffs == "TOPLEFT" then
        invert_h = 1
        invert_v = 1
        af = "BOTTOMLEFT"
      elseif unit.config.debuffs == "BOTTOMLEFT" then
        invert_h = -1
        invert_v = 1
        af = "TOPLEFT"
      elseif unit.config.debuffs == "TOPRIGHT" then
        invert_h = 1
        invert_v = -1
        af = "BOTTOMRIGHT"
      elseif unit.config.debuffs == "BOTTOMRIGHT" then
        invert_h = -1
        invert_v = -1
        af = "TOPRIGHT"
      end

      unit.debuffs[i]:SetPoint(af, unit, unit.config.debuffs,
      invert_v * (i-1-row*perrow)*(2*default_border + unit.config.debuffsize + 1),
      invert_h * ((row+buffrow)*(2*default_border + unit.config.debuffsize + 1) + (2*default_border + 1)))

      local texture, stacks, dtype
      if unit.label == "player" then
        texture = GetPlayerBuffTexture(GetPlayerBuff(PLAYER_BUFF_START_ID+i, "HARMFUL"))
        stacks = GetPlayerBuffApplications(GetPlayerBuff(PLAYER_BUFF_START_ID+i, "HARMFUL"))
        dtype = GetPlayerBuffDispelType(GetPlayerBuff(PLAYER_BUFF_START_ID+i, "HARMFUL"))
      else
        texture, stacks, dtype = UnitDebuff(unitstr, i)
      end

      unit.debuffs[i].texture:SetTexture(texture)

      local r,g,b = DebuffTypeColor.none.r,DebuffTypeColor.none.g,DebuffTypeColor.none.b
      if dtype and DebuffTypeColor[dtype] then
        r,g,b = DebuffTypeColor[dtype].r,DebuffTypeColor[dtype].g,DebuffTypeColor[dtype].b
      end
      unit.debuffs[i].backdrop:SetBackdropBorderColor(r,g,b,1)

      if texture then
        unit.debuffs[i]:Show()

        if unit:GetName() == "pfPlayer" then
          local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(PLAYER_BUFF_START_ID+unit.debuffs[i].id, "HARMFUL"),"HARMFUL")
          CooldownFrame_SetTimer(unit.debuffs[i].cd, GetTime(), timeleft, 1)
        elseif libdebuff then
          local name, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff(unitstr, i)
          if duration and timeleft then
            CooldownFrame_SetTimer(unit.debuffs[i].cd, GetTime() + timeleft - duration, duration, 1)
          end
        end

        if stacks > 1 then
          unit.debuffs[i].stacks:SetText(stacks)
        else
          unit.debuffs[i].stacks:SetText("")
        end
      else
        unit.debuffs[i]:Hide()
      end
    end
  end

  -- indicators
  if component == "all" or ( component == "all" or component == "aura" ) then
    if not unit.dispellable and unit.config.debuff_indicator ~= "0" then
      unit.dispellable = pfUI.uf:SetupDebuffFilter((unit.config.debuff_ind_class == "0" and true or nil))
    elseif not unit.dispellable then
      unit.dispellable = {}
    end

    if table.getn(unit.dispellable) > 0 then
      unit.hp.bar.debuffindicators = unit.hp.bar.debuffindicators or CreateFrame("Frame", nil, unit.hp.bar)

      -- 0 = OFF, 1 = Legacy, 2 = Glow, 3 = Square, 4 = Icons
      local disptype = unit.config.debuff_indicator
      local indicator = unit.hp.bar.debuffindicators
      local indipos = unit.config.debuff_ind_pos
      local count = 0
      local size

      if disptype == "4" or disptype == "3" then
        size = unit.hp.bar:GetHeight() * tonumber(unit.config.debuff_ind_size)
        if size ~= indicator.size or disptype ~= indicator.disp or indipos ~= indicator.ipos then
          indicator:ClearAllPoints()
          indicator:SetPoint(indipos, 0, 0)
          indicator:SetHeight(size)
          indicator:SetWidth(size)
          indicator.size = size
          indicator.disp = disptype
          indicator.ipos  = indipos
        end
      elseif disptype == "2" or disptype == "1" then
        size = "FULL"
        if size ~= indicator.size or disptype ~= indicator.disp or indipos ~= indicator.ipos then
          indicator:ClearAllPoints()
          indicator:SetAllPoints(unit.hp.bar)
          indicator.size = size
          indicator.disp = disptype
          indicator.ipos = indipos
        end
      end

      for _, debuff in pairs(unit.dispellable) do
        indicator[debuff] = indicator[debuff] or CreateFrame("Frame", nil, indicator)
        indicator[debuff]:SetParent(indicator)
        indicator[debuff].tex = indicator[debuff].tex or indicator[debuff]:CreateTexture(nil)
        indicator[debuff].tex:SetAllPoints(indicator[debuff])

        if indicator.size ~= indicator[debuff].size or disptype ~= indicator[debuff].disp then
          if disptype == "4" then
            indicator[debuff].tex:SetTexture(pfUI.media["img:"..debuff])
            indicator[debuff].tex:SetVertexColor(unpack(pfDebuffColors[debuff]))
            indicator[debuff].tex:Show()
            indicator[debuff]:ClearAllPoints()
            indicator[debuff]:SetHeight(size)
            indicator[debuff]:SetWidth(size)
            indicator[debuff]:SetBackdrop(nil)
          elseif disptype == "3" then
            indicator[debuff].tex:SetTexture(unpack(pfDebuffColors[debuff]))
            indicator[debuff].tex:SetVertexColor(1,1,1,1)
            indicator[debuff].tex:Show()
            indicator[debuff]:ClearAllPoints()
            indicator[debuff]:SetHeight(size)
            indicator[debuff]:SetWidth(size)
            indicator[debuff]:SetBackdrop(nil)
          elseif disptype == "2" then
            indicator[debuff].tex:Hide()
            indicator[debuff]:SetAllPoints(unit.hp.bar)
            indicator[debuff]:SetBackdrop(glow)
            indicator[debuff]:SetBackdropBorderColor(unpack(pfDebuffColors[debuff]))
          elseif disptype == "1" then
            indicator[debuff].tex:SetTexture(unpack(pfDebuffColors[debuff]))
            indicator[debuff].tex:SetVertexColor(1,1,1,1)
            indicator[debuff].tex:Show()
            indicator[debuff]:SetAllPoints(unit.hp.bar)
            indicator[debuff]:SetBackdrop(nil)
          end

          indicator[debuff].size = indicator.size
          indicator[debuff].disp = indicator.disp
        end

        indicator[debuff].visible = nil

        for i=1,16 do
          local _, _, dtype = UnitDebuff(unitstr, i)
          if dtype == debuff then
            indicator[debuff].visible = true
          end
        end

        if indicator[debuff].visible then
          indicator[debuff]:Show()
          indicator:Show()
          indicator:SetAlpha(0)
          if disptype == "4" or disptype == "3" then
            indicator:SetAlpha(1)
          elseif disptype == "2" then
            indicator:SetAlpha(.4)
          elseif disptype == "1" then
            indicator:SetAlpha(.2)
          end

          if disptype == "4" or disptype == "3" then
            indicator[debuff]:SetPoint("LEFT", indicator, "LEFT", count*(size+1), 0)
            count = count + 1
          end
        else
          indicator[debuff]:Hide()
        end
      end

      if disptype == "4" or disptype == "3" then
        indicator:SetWidth(count*(size+1))
      end
    elseif unit.hp.bar.debuffindicators then
      unit.hp.bar.debuffindicators:Hide()
    end

    if not unit.indicators and unit.config.buff_indicator == "1" then
      unit.indicators = pfUI.uf:SetupBuffIndicators(unit.config)
    elseif not unit.indicators then
      unit.indicators = {}
    end

    if not unit.indicator_custom and unit.config.buff_indicator == "1" then
      unit.indicator_custom = {}
      for k, v in pairs({strsplit("#", unit.config.custom_indicator)}) do
        unit.indicator_custom[k] = string.lower(v)
      end
    elseif not unit.indicator_custom then
      unit.indicator_custom = {}
    end

    local pos = 1
    if table.getn(unit.indicators) > 0 then
      for i=1,32 do
        local texture, count = UnitBuff(unitstr, i)
        local timeleft, _
        if pfUI.client > 11200 then
          _, _, texture, _, _, timeleft = _G.UnitBuff(unitstr, i)
        end

        if texture then
          -- match filter
          for _, filter in pairs(unit.indicators) do
            if filter == string.lower(texture) then
              pfUI.uf:AddIcon(unit, pos, texture, timeleft, count)
              pos = pos + 1
              break
            end
          end
        end
      end
    end

    if table.getn(unit.indicator_custom) > 0 then
      scanner = scanner or libtipscan:GetScanner("unitframes")

      for i=1,32 do -- scan for custom buffs
        local texture, count = UnitBuff(unitstr, i)
        if texture then
          local timeleft, name, _
          if pfUI.client > 11200 then
            name, _, texture, _, _, timeleft = _G.UnitBuff(unitstr, i)
          else
            scanner:SetUnitBuff(unitstr, i)
            name = scanner:Line(1) or ""
          end

          -- match filter
          for _, filter in pairs(unit.indicator_custom) do
            if filter == string.lower(name) then
              pfUI.uf:AddIcon(unit, pos, texture, timeleft, count)
              pos = pos + 1
              break
            end
          end
        end
      end

      for i=1,32 do -- scan for custom debuffs
        local texture, count = UnitDebuff(unitstr, i)
        if texture then
          local timeleft, name, _
          if libdebuff then
            name, _, texture, _, _, _, timeleft = libdebuff:UnitDebuff(unitstr, i)
          else
            scanner:SetUnitDebuff(unitstr, i)
            name = scanner:Line(1) or ""
          end

          -- match filter
          for _, filter in pairs(unit.indicator_custom) do
            if filter == string.lower(name) then
              pfUI.uf:AddIcon(unit, pos, texture, timeleft, count)
              pos = pos + 1
              break
            end
          end
        end
      end
    end

    -- hide unused icon slots
    for pos=pos, 6 do pfUI.uf:HideIcon(unit, pos) end
  end

  -- portrait
  if unit.portrait and ( component == "all" or component == "portrait" ) then
    if C.unitframes.always2dportrait == "1" then
      unit.portrait.tex:Show()
      unit.portrait.model:Hide()
      SetPortraitTexture(unit.portrait.tex, unitstr)
    else
      if not UnitIsVisible(unitstr) or not UnitIsConnected(unitstr) then
        if unit.config.portrait == "bar" then
          unit.portrait.tex:Hide()
          unit.portrait.model:Hide()
        elseif C.unitframes.portraittexture == "1" then
          unit.portrait.tex:Show()
          unit.portrait.model:Hide()
          SetPortraitTexture(unit.portrait.tex, unitstr)
        else
          unit.portrait.tex:Hide()
          unit.portrait.model:Show()
          unit.portrait.model:SetModelScale(4.25)
          unit.portrait.model:SetPosition(0, 0, -1)
          unit.portrait.model:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
        end
      else
        if unit.config.portrait == "bar" then
          unit.portrait:SetAlpha(C.unitframes.portraitalpha)
        else
          unit.portrait:SetAlpha(1)
        end
        unit.portrait.tex:Hide()
        unit.portrait.model:Show()

        if unit.tick then
          unit.portrait.model.next:SetUnit(unitstr)
          if unit.portrait.model.lastUnit ~= UnitName(unitstr) or unit.portrait.model:GetModel() ~= unit.portrait.model.next:GetModel() then
            unit.portrait.model.update = unitstr
          end
        else
          unit.portrait.model.update = unitstr
        end
      end
    end
  end

  -- Unit HP/MP
  local hp, hpmax = UnitHealth(unitstr), UnitHealthMax(unitstr)
  local power, powermax = UnitMana(unitstr), UnitManaMax(unitstr)

  if unit.config.invert_healthbar == "1" then
    hp = hpmax - hp
  end

  unit.hp.bar:SetMinMaxValues(0, hpmax, true)
  unit.hp.bar:SetValue(hp)

  unit.power.bar:SetMinMaxValues(0, powermax, true)
  unit.power.bar:SetValue(power)

  -- set healthbar color
  local custom_active = nil
  local customfullhp = unit.config.defcolor == "0" and unit.config.customfullhp or C.unitframes.customfullhp
  local customcolor = unit.config.defcolor == "0" and unit.config.customcolor or C.unitframes.customcolor
  local custom = unit.config.defcolor == "0" and unit.config.custom or C.unitframes.custom

  local r, g, b, a = .2, .2, .2, 1
  if customfullhp == "1" and UnitHealth(unitstr) == UnitHealthMax(unitstr) then
    r, g, b, a = pfUI.api.strsplit(",", customcolor)
    custom_active = true
  elseif custom == "0" then
    if UnitIsPlayer(unitstr) then
      local _, class = UnitClass(unitstr)
      local color = RAID_CLASS_COLORS[class]
      if color then r, g, b = color.r, color.g, color.b end
    elseif unit.label == "pet" then
      local happiness = GetPetHappiness()
      if happiness == 1 then
        r, g, b = 1, 0, 0
      elseif happiness == 2 then
        r, g, b = 1, 1, 0
      else
        r, g, b = 0, 1, 0
      end
    else
      local color = UnitReactionColor[UnitReaction(unitstr, "player")]
      if color then r, g, b = color.r, color.g, color.b end
    end
  elseif custom == "1"  then
    r, g, b, a = pfUI.api.strsplit(",", customcolor)
    custom_active = true
  elseif custom == "2" then
    if UnitHealthMax(unitstr) > 0 then
      r, g, b = GetColorGradient(UnitHealth(unitstr) / UnitHealthMax(unitstr))
    else
      r, g, b = 0, 0, 0
    end
  end

  if C.unitframes.pastel == "1" and not custom_active then
    r, g, b = (r + .5) * .5, (g + .5) * .5, (b + .5) * .5
  end

  unit.hp.bar:SetStatusBarColor(r, g, b, a)

  -- set powerbar color
  local mana = unit.config.defcolor == "0" and unit.config.manacolor or C.unitframes.manacolor
  local rage = unit.config.defcolor == "0" and unit.config.ragecolor or C.unitframes.ragecolor
  local energy = unit.config.defcolor == "0" and unit.config.energycolor or C.unitframes.energycolor
  local focus = unit.config.defcolor == "0" and unit.config.focuscolor or C.unitframes.focuscolor

  local r, g, b, a = .5, .5, .5, 1
  local utype = UnitPowerType(unitstr)
  if utype == 0 then
    r, g, b, a = pfUI.api.strsplit(",", mana)
  elseif utype == 1 then
    r, g, b, a = pfUI.api.strsplit(",", rage)
  elseif utype == 2 then
    r, g, b, a = pfUI.api.strsplit(",", focus)
  elseif utype == 3 then
    r, g, b, a = pfUI.api.strsplit(",", energy)
  end
  unit.power.bar:SetStatusBarColor(r, g, b, a)

  if UnitName(unitstr) then
    unit.hpLeftText:SetText(pfUI.uf:GetStatusValue(unit, "hpleft"))
    unit.hpCenterText:SetText(pfUI.uf:GetStatusValue(unit, "hpcenter"))
    unit.hpRightText:SetText(pfUI.uf:GetStatusValue(unit, "hpright"))

    unit.powerLeftText:SetText(pfUI.uf:GetStatusValue(unit, "powerleft"))
    unit.powerCenterText:SetText(pfUI.uf:GetStatusValue(unit, "powercenter"))
    unit.powerRightText:SetText(pfUI.uf:GetStatusValue(unit, "powerright"))

    if UnitIsTapped(unitstr) and not UnitIsTappedByPlayer(unitstr) then
      unit.hp.bar:SetStatusBarColor(.5,.5,.5,.5)
    end
  end

  pfUI.uf:RefreshUnitState(unit)
end

local buttons = {
  [1] = "LeftButton",
  [2] = "RightButton",
  [3] = "MiddleButton",
  [4] = "Button4",
  [5] = "Button5",
}

local modifiers = {
  [""] = "",
  ["alt"] = "_alt",
  ["ctrl"] = "_ctrl",
  ["shift"] = "_shift",
}

function pfUI.uf:EnableClickCast()
  if self.config.clickcast ~= "1" then return end
  for bid, button in pairs(buttons) do
    for modifier, mconf in pairs(modifiers) do
      local bconf = bid == 1 and "" or bid
      if pfUI_config.unitframes["clickcast"..bconf..mconf] ~= "" then
        -- prepare click casting
        if pfUI.client > 11200 then
          -- set attributes for tbc+
          local prefix = modifier == "" and "" or modifier .. "-"

          -- check for "/" in the beginning of the string, to detect macros
          if string.find(pfUI_config.unitframes["clickcast"..bconf..mconf], "^%/(.+)") then
            self:SetAttribute(prefix.."type"..bid, "macro")
            self:SetAttribute(prefix.."macrotext"..bid, pfUI_config.unitframes["clickcast"..bconf..mconf])
            self:SetAttribute(prefix.."spell"..bid, nil)
          elseif string.find(pfUI_config.unitframes["clickcast"..bconf..mconf], "^target") then
            self:SetAttribute(prefix.."type"..bid, "target")
            self:SetAttribute(prefix.."macrotext"..bid, nil)
            self:SetAttribute(prefix.."spell"..bid, nil)
          elseif string.find(pfUI_config.unitframes["clickcast"..bconf..mconf], "^menu") then
            self:SetAttribute(prefix.."type"..bid, "showmenu")
            self:SetAttribute(prefix.."macrotext"..bid, nil)
            self:SetAttribute(prefix.."spell"..bid, nil)
          else
            self:SetAttribute(prefix.."type"..bid, "spell")
            self:SetAttribute(prefix.."spell"..bid, pfUI_config.unitframes["clickcast"..bconf..mconf])
            self:SetAttribute(prefix.."macro"..bid, nil)
          end
        else
          -- fill clickaction table for vanillla
          self.clickactions = self.clickactions or {}
          self.clickactions[modifier..button] = pfUI_config.unitframes["clickcast"..bconf..mconf]
        end
      end
    end
  end
end

function pfUI.uf:ClickAction(button)
  local label = this.label or ""
  local id = this.id or ""
  local unitstr = label .. id
  local showmenu = button == "RightButton" and true or nil
  if SpellIsTargeting() and button == "RightButton" then
    SpellStopTargeting()
    return
  end

  if SpellIsTargeting() and button == "LeftButton" then
    SpellTargetUnit(unitstr)
  elseif CursorHasItem() then
    DropItemOnUnit(unitstr)
  end

  -- run click casting if enabled
  local modstring = ""
  modstring = IsAltKeyDown() and modstring.."alt" or modstring
  modstring = IsControlKeyDown() and modstring.."ctrl" or modstring
  modstring = IsShiftKeyDown() and modstring.."shift" or modstring
  modstring = modstring..button
  if this.clickactions and this.clickactions[modstring] then
    if string.find(this.clickactions[modstring], "^menu") then
      -- show menu
      showmenu = true
    elseif string.find(this.clickactions[modstring], "^target") then
      -- target unit
      showmenu = nil
    else
      -- run click cast action
      local tswitch = UnitIsUnit(unitstr, "target")
      TargetUnit(unitstr)

      if string.find(this.clickactions[modstring], "^%/(.+)") then
        RunMacroText(this.clickactions[modstring])
      else
        CastSpellByName(this.clickactions[modstring])
      end

      if not tswitch then TargetLastTarget() end
      return
    end
  end

  -- dropdown menus
  if showmenu then
    pfUI.uf:RightClickAction(label)
    return
  end

  -- drop food on petframe
  if label == "pet" and CursorHasItem() then
    local _, playerClass = UnitClass("player")
    if playerClass == "HUNTER" then
      DropItemOnUnit("pet")
      return
    end
  end

  -- default click
  TargetUnit(unitstr)
end

function pfUI.uf:AddIcon(frame, pos, icon, timeleft, stacks)
  local showtime = frame.config.indicator_time == "1" and true or nil
  local showstacks = frame.config.indicator_stacks == "1" and true or nil
  local position = frame.config.indicator_pos or "TOPLEFT"
  local iconsize = tonumber(frame.config.indicator_size)
  local spacing = tonumber(frame.config.indicator_spacing)

  if not frame.hp then return end
  local frame = frame.hp.bar
  if pos > 6 or pos > ceil(frame:GetWidth() / iconsize) then return end

  frame.icon = frame.icon or CreateFrame("Frame", nil, frame)

  if not frame.icon[pos] then
    frame.icon[pos] = CreateFrame("Frame", frame.icon)
    frame.icon[pos]:SetParent(frame)
    frame.icon[pos].tex = frame.icon[pos]:CreateTexture("OVERLAY")
    frame.icon[pos].tex:SetAllPoints(frame.icon[pos])
    frame.icon[pos].tex:SetTexCoord(.08, .92, .08, .92)
    frame.icon[pos].stacks = frame.icon[pos]:CreateFontString(nil, "OVERLAY")
    frame.icon[pos].stacks:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.icon[pos].stacks:SetJustifyH("RIGHT")
    frame.icon[pos].stacks:SetJustifyV("BOTTOM")
    frame.icon[pos].cd = CreateFrame(COOLDOWN_FRAME_TYPE, nil, frame.icon[pos])
    frame.icon[pos].cd.pfCooldownType = "ALL"
    frame.icon[pos].cd:SetAlpha(0)
  end

  -- update icon configuration
  if frame.icon[pos].iconsize ~= iconsize or frame.icon[pos].spacing ~= spacing then
    frame.icon[pos]:SetWidth(iconsize)
    frame.icon[pos]:SetHeight(iconsize)
    frame.icon[pos]:SetPoint("TOPLEFT", frame.icon, "TOPLEFT", (pos-1)*(iconsize + spacing), 0)
    frame.icon[pos].stacks:SetFont(pfUI.font_unit, math.max(iconsize/3, 10), "OUTLINE")
    frame.icon[pos].iconsize = iconsize
    frame.icon[pos].spacing = spacing
  end

  -- update icon
  if frame.icon[pos].icon ~= icon then
    frame.icon[pos].tex:SetTexture(icon)
    frame.icon[pos].icon = icon
  end

  -- show remaining time if config is set
  if showtime and timeleft and timeleft < 100 and iconsize > 9 then
    CooldownFrame_SetTimer(frame.icon[pos].cd, GetTime(), timeleft, 1)
  else
    CooldownFrame_SetTimer(frame.icon[pos].cd, GetTime(), 0, 1)
  end

  -- show stacks if config is set
  if showstacks and stacks and stacks > 1 and iconsize > 9 then
    frame.icon[pos].stacks:SetText(stacks)
  else
    frame.icon[pos].stacks:SetText("")
  end

  -- update parent icon size
  if frame.icon.iconsize ~= iconsize then
    frame.icon:SetHeight(iconsize)
    frame.icon.iconsize = iconsize
  end

  -- update parent position
  if frame.icon.position ~= position then
    frame.icon:ClearAllPoints()
    frame.icon:SetPoint(position, frame, position, 0, 0)
    frame.icon.position = position
  end

  frame.icon[pos]:Show()
  frame.icon:SetWidth((pos-1)*(iconsize+spacing)+iconsize)
end

function pfUI.uf:HideIcon(frame, pos)
  if not frame or not frame.hp or not frame.hp.bar then return end

  local frame = frame.hp.bar
  if frame.icon and frame.icon[pos] then
    frame.icon[pos]:Hide()
  end
end

function pfUI.uf:SetupDebuffFilter(allclasses)
  local _, myclass = UnitClass("player")
  local debuffs = {}

  if myclass == "PALADIN" or myclass == "PRIEST" or myclass == "WARLOCK" or allclasses then
    table.insert(debuffs, "Magic")
  end

  if myclass == "DRUID" or myclass == "PALADIN" or myclass == "SHAMAN" or allclasses then
    table.insert(debuffs, "Poison")
  end

  if myclass == "PRIEST" or myclass == "PALADIN" or myclass == "SHAMAN" or allclasses then
    table.insert(debuffs, "Disease")
  end

  if myclass == "DRUID" or myclass == "MAGE" or allclasses then
    table.insert(debuffs, "Curse")
  end

  return debuffs
end

function pfUI.uf:SetupBuffIndicators(config)
  local _, myclass = UnitClass("player")
  local indicators = {}

  if config.show_buffs == "1" then -- buffs
    if myclass == "DRUID" then
      -- Mark of the Wild
      table.insert(indicators, "interface\\icons\\spell_nature_regeneration")
      -- Gift of the Wild
      table.insert(indicators, "interface\\icons\\spell_nature_giftofthewild")
      -- Thorns
      table.insert(indicators, "interface\\icons\\spell_nature_thorns")
    end

    if myclass == "PRIEST" then
      -- Prayer Of Fortitude"
      table.insert(indicators, "interface\\icons\\spell_holy_wordfortitude")
      table.insert(indicators, "interface\\icons\\spell_holy_prayeroffortitude")
      -- Prayer of Spirit
      table.insert(indicators, "interface\\icons\\spell_holy_divinespirit")
      table.insert(indicators, "interface\\icons\\spell_holy_prayerofspirit")
      -- Shadow Protection
      table.insert(indicators, "interface\\icons\\spell_shadow_antishadow")
      table.insert(indicators, "interface\\icons\\spell_holy_prayerofshadowprotection")
      -- Fear Ward
      table.insert(indicators, "interface\\icons\\spell_holy_excorcism")
    end

    if myclass == "PALADIN" then
      -- Blessing of Salvation
      table.insert(indicators, "interface\\icons\\spell_holy_greaterblessingofsalvation")
      table.insert(indicators, "interface\\icons\\spell_holy_sealofsalvation")
      -- Blessing of Wisdom
      table.insert(indicators, "interface\\icons\\spell_holy_sealofwisdom")
      table.insert(indicators, "interface\\icons\\spell_holy_greaterblessingofwisdom")
      -- Blessing of Sanctuary
      table.insert(indicators, "interface\\icons\\spell_nature_lightningshield")
      table.insert(indicators, "interface\\icons\\spell_holy_greaterblessingofsanctuary")
      -- Blessing of Kings
      table.insert(indicators, "interface\\icons\\spell_magic_magearmor")
      table.insert(indicators, "interface\\icons\\spell_magic_greaterblessingofkings")
      -- Blessing of Might
      table.insert(indicators, "interface\\icons\\spell_holy_fistofjustice")
      table.insert(indicators, "interface\\icons\\spell_holy_greaterblessingofkings")
      -- Blessing of Light
      table.insert(indicators, "interface\\icons\\spell_holy_prayerofhealing02")
      table.insert(indicators, "interface\\icons\\spell_holy_greaterblessingoflight")
    end

    if myclass == "WARLOCK" then
      -- Fire Shield
      table.insert(indicators, "interface\\icons\\spell_fire_firearmor")
      -- Blood Pact
      table.insert(indicators, "interface\\icons\\spell_shadow_bloodboil")
      -- Soulstone
      table.insert(indicators, "interface\\icons\\spell_shadow_soulgem")
      -- Unending Breath
      table.insert(indicators, "interface\\icons\\spell_shadow_demonbreath")
      -- Detect Greater Invisibility or Detect Invisibility
      table.insert(indicators, "interface\\icons\\spell_shadow_detectinvisibility")
      -- Detect Lesser Invisibility
      table.insert(indicators, "interface\\icons\\spell_shadow_detectlesserinvisibility")
      -- Paranoia
      table.insert(indicators, "interface\\icons\\Spell_Shadow_AuraOfDarkness")
    end

    if myclass == "WARRIOR" then
      -- Battle Shout
      table.insert(indicators, "interface\\icons\\ability_warrior_battleshout")
      -- Commanding Shout (TBC)
      table.insert(indicators, "interface\\icons\\ability_warrior_rallyingcry")
    end

    if myclass == "MAGE" then
      -- Arcane Intellect
      table.insert(indicators, "interface\\icons\\spell_holy_magicalsentry")
      table.insert(indicators, "interface\\icons\\spell_holy_arcaneintellect")
      -- Dampen Magic
      table.insert(indicators, "interface\\icons\\spell_nature_abolishmagic")
      -- Amplify Magic
      table.insert(indicators, "interface\\icons\\spell_holy_flashheal")
    end

    if myclass == "HUNTER" then
      -- Aspect of the Wild
      table.insert(indicators, "interface\\icons\\spell_nature_protectionformnature")

      -- Aspect of the Pack
      table.insert(indicators, "interface\\icons\\ability_mount_whitetiger")

      -- Misdirection (TBC)
      table.insert(indicators, "interface\\icons\\ability_hunter_misdirection")
    end

    if myclass == "SHAMAN" then
      -- Earth Shield (TBC)
      table.insert(indicators, "interface\\icons\\spell_nature_skinofearth")
    end
  end

  if config.show_procs == "1" then -- procs
    if myclass == "SHAMAN" or config.all_procs == "1" then
      -- Ancestral Fortitude
      table.insert(indicators, "interface\\icons\\spell_nature_undyingstrength")
      -- Healing Way
      table.insert(indicators, "interface\\icons\\spell_nature_healingway")
      -- Totemic Power (known issue: one conflicts with Blessed Sunfruit buff)
      table.insert(indicators, "interface\\icons\\spell_holy_spiritualguidence")
      table.insert(indicators, "interface\\icons\\spell_holy_devotion")
      table.insert(indicators, "interface\\icons\\spell_holy_holynova")
      table.insert(indicators, "interface\\icons\\spell_magic_magearmor")
    end

    if myclass == "PRIEST" or config.all_procs == "1" then
      -- Inspiration
      table.insert(indicators, "interface\\icons\\inv_shield_06")
    end
  end

  if config.show_hots == "1" then -- hots
    if myclass == "PRIEST" or config.all_hots == "1" then
      -- Renew
      table.insert(indicators, "interface\\icons\\spell_holy_renew")
      -- Power Word: Shield
      table.insert(indicators, "interface\\icons\\spell_holy_powerwordshield")
      -- Prayer of Mending (TBC)
      table.insert(indicators, "interface\\icons\\spell_holy_prayerofmendingtga")
    end

    if myclass == "DRUID" or config.all_hots == "1" then
      -- Regrowth
      table.insert(indicators, "interface\\icons\\spell_nature_resistnature")
      -- Rejuvenation
      table.insert(indicators, "interface\\icons\\spell_nature_rejuvenation")
      -- Lifebloom
      table.insert(indicators, "interface\\icons\\inv_misc_herb_felblossom")
    end
  end

  if config.show_totems == "1" and myclass == "SHAMAN" then -- totems
    -- Strength of Earth Totem
    table.insert(indicators, "interface\\icons\\spell_nature_earthbindtotem")
    -- Stoneskin Totem
    table.insert(indicators, "interface\\icons\\spell_nature_stoneskintotem")
    -- Mana Spring Totem
    table.insert(indicators, "interface\\icons\\spell_nature_manaregentotem")
    -- Mana Tide Totem
    table.insert(indicators, "interface\\icons\\spell_frost_summonwaterelemental")
    -- Healing Spring Totem
    table.insert(indicators, "interface\\icons\\inv_spear_04")
    -- Tranquil Air Totem
    table.insert(indicators, "interface\\icons\\spell_nature_brilliance")
    -- Grace of Air Totem
    table.insert(indicators, "interface\\icons\\spell_nature_invisibilitytotem")
    -- Grounding Totem
    table.insert(indicators, "interface\\icons\\spell_nature_groundingtotem")
    -- Nature Resistance Totem
    table.insert(indicators, "interface\\icons\\spell_nature_natureresistancetotem")
    -- Fire Resistance Totem
    table.insert(indicators, "interface\\icons\\spell_fireresistancetotem_01")
    -- Frost Resistance Totem
    table.insert(indicators, "interface\\icons\\spell_frostresistancetotem_01")
  end

  return indicators
end

function pfUI.uf:GetLevelString(unitstr)
  local level = UnitLevel(unitstr)
  if level == -1 then level = "??" end

  local elite = UnitClassification(unitstr)
  if elite == "worldboss" then
    level = level .. "B"
  elseif elite == "rareelite" then
    level = level .. "R+"
  elseif elite == "elite" then
    level = level .. "+"
  elseif elite == "rare" then
    level = level .. "R"
  end

  return level
end

function pfUI.uf:GetStatusValue(unit, pos)
  if not pos or not unit then return end
  local config = unit.config["txt"..pos]
  local unitstr = unit.label .. unit.id
  local frame = unit[pos .. "Text"]

  -- as a fallback, draw the name
  if pos == "center" and not config then
    config = "unit"
  end


  local mp, mpmax = UnitMana(unitstr), UnitManaMax(unitstr)
  local hp, hpmax = UnitHealth(unitstr), UnitHealthMax(unitstr)
  local rhp, rhpmax = hp, hpmax

  if pfUI.libhealth and pfUI.libhealth.enabled then
    rhp, rhpmax = pfUI.libhealth:GetUnitHealth(unitstr)
  elseif unit.label == "target" and (MobHealth3 or MobHealthFrame) and MobHealth_GetTargetCurHP() then
    rhp, rhpmax = MobHealth_GetTargetCurHP(), MobHealth_GetTargetMaxHP()
  end

  if config == "unit" then
    local name = unit:GetColor("unit") .. UnitName(unitstr)
    local level = unit:GetColor("level") .. pfUI.uf:GetLevelString(unitstr)
    return level .. "  " .. name
  elseif config == "name" then
    return unit:GetColor("unit") .. UnitName(unitstr)
  elseif config == "nameshort" then
    return unit:GetColor("unit") .. strsub(UnitName(unitstr), 0, 3)
  elseif config == "level" then
    return unit:GetColor("level") .. pfUI.uf:GetLevelString(unitstr)
  elseif config == "class" then
    if UnitIsPlayer(unitstr) then
      return unit:GetColor("class") .. (UnitClass(unitstr) or UNKNOWN)
    else
      return ""
    end

  -- health
  elseif config == "health" then
    return unit:GetColor("health") .. pfUI.api.Abbreviate(rhp)
  elseif config == "healthmax" then
    return unit:GetColor("health") .. pfUI.api.Abbreviate(rhpmax)
  elseif config == "healthperc" then
    return unit:GetColor("health") .. ceil(hp / hpmax * 100)
  elseif config == "healthmiss" then
    local health = ceil(rhp - rhpmax)
    if UnitIsDead(unitstr) then
      return unit:GetColor("health") .. DEAD
    elseif health == 0 then
      return unit:GetColor("health") .. "0"
    else
      return unit:GetColor("health") .. pfUI.api.Abbreviate(health)
    end
  elseif config == "healthdyn" then
    if hp ~= hpmax then
      return unit:GetColor("health") .. pfUI.api.Abbreviate(rhp) .. " - " .. ceil(hp / hpmax * 100) .. "%"
    else
      return unit:GetColor("health") .. pfUI.api.Abbreviate(rhp)
    end
  elseif config == "namehealth" then
    local health = ceil(rhp - rhpmax)
    if UnitIsDead(unitstr) then
      return unit:GetColor("health") .. DEAD
    elseif health == 0 then
      return unit:GetColor("unit") .. UnitName(unitstr)
    else
      return unit:GetColor("health") .. pfUI.api.Abbreviate(health)
    end
  elseif config == "shortnamehealth" then
    local health = ceil(rhp - rhpmax)
    if UnitIsDead(unitstr) then
      return unit:GetColor("health") .. DEAD
    elseif health == 0 then
      return unit:GetColor("unit") .. strsub(UnitName(unitstr), 0, 3)
    else
      return unit:GetColor("health") .. pfUI.api.Abbreviate(health)
    end
  elseif config == "healthminmax" then
    return unit:GetColor("health") .. pfUI.api.Abbreviate(rhp) .. "/" .. pfUI.api.Abbreviate(rhpmax)

  -- mana/power/focus
  elseif config == "power" then
    return unit:GetColor("power") .. pfUI.api.Abbreviate(mp)
  elseif config == "powermax" then
    return unit:GetColor("power") .. pfUI.api.Abbreviate(mpmax)
  elseif config == "powerperc" then
    local perc = UnitManaMax(unitstr) > 0 and ceil(mp / mpmax * 100) or 0
    return unit:GetColor("power") .. perc
  elseif config == "powermiss" then
    local power = ceil(mp - mpmax)
    if power == 0 then
      return unit:GetColor("power") .. "0"
    else
      return unit:GetColor("power") .. pfUI.api.Abbreviate(power)
    end
  elseif config == "powerdyn" then
    -- show percentage when only mana is less than 100%
    if mp ~= mpmax and UnitPowerType(unitstr) == 0 then
      return unit:GetColor("power") .. pfUI.api.Abbreviate(mp) .. " - " .. ceil(mp / mpmax * 100) .. "%"
    else
      return unit:GetColor("power") .. pfUI.api.Abbreviate(mp)
    end
  elseif config == "powerminmax" then
    return unit:GetColor("power") .. pfUI.api.Abbreviate(mp) .. "/" .. pfUI.api.Abbreviate(mpmax)
  else
    return ""
  end
end

function pfUI.uf.GetColor(self, preset)
  local config = self.config

  local unitstr = self.label .. self.id
  local r, g, b = 1, 1, 1

  if preset == "unit" and config["classcolor"] == "1" then
    if UnitIsPlayer(unitstr) then
      local _, class = UnitClass(unitstr)
      if RAID_CLASS_COLORS[class] then
        r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
      end
    elseif self.label == "pet" then
      local happiness = GetPetHappiness()
      if happiness == 1 then
        r, g, b = 1, 0, 0
      elseif happiness == 2 then
        r, g, b = 1, 1, 0
      else
        r, g, b = 0, 1, 0
      end
    else
      local color = UnitReactionColor[UnitReaction(unitstr, "player")]
      if color then r, g, b = color.r, color.g, color.b end
    end

  elseif preset == "class" and config["classcolor"] == "1" then
    local _, class = UnitClass(unitstr)
    if RAID_CLASS_COLORS[class] then
      r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
    end

  elseif preset == "reaction" and config["classcolor"] == "1" then
    r = UnitReactionColor[UnitReaction(unitstr, "player")].r
    g = UnitReactionColor[UnitReaction(unitstr, "player")].g
    b = UnitReactionColor[UnitReaction(unitstr, "player")].b

  elseif preset == "health" and config["healthcolor"] == "1" then
    if UnitHealthMax(unitstr) > 0 then
      r, g, b = GetColorGradient(UnitHealth(unitstr) / UnitHealthMax(unitstr))
    else
      r, g, b = 0, 0, 0
    end

  elseif preset == "power" and config["powercolor"] == "1" then
    r = ManaBarColor[UnitPowerType(unitstr)].r
    g = ManaBarColor[UnitPowerType(unitstr)].g
    b = ManaBarColor[UnitPowerType(unitstr)].b

  elseif preset == "level" and config["levelcolor"] == "1" then
    r = GetDifficultyColor(UnitLevel(unitstr)).r
    g = GetDifficultyColor(UnitLevel(unitstr)).g
    b = GetDifficultyColor(UnitLevel(unitstr)).b
  end

  -- pastel
  if C.unitframes.pastel == "1" then
    r = ( r + .75 ) * .5
    g = ( g + .75 ) * .5
    b = ( b + .75 ) * .5
  end

  return rgbhex(r,g,b)
end
