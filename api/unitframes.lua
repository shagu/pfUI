pfUI.uf = CreateFrame("Frame",nil,UIParent)
pfUI.uf.frames = {}

-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

local pfValidUnits = {}
pfValidUnits["player"] = true
pfValidUnits["target"] = true
pfValidUnits["pet"] = true
pfValidUnits["mouseover"] = true

pfValidUnits["player" .. "target"] = true
pfValidUnits["target" .. "target"] = true
pfValidUnits["pet" .. "target"] = true

for i=1,4 do pfValidUnits["party" .. i] = true end
for i=1,4 do pfValidUnits["partypet" .. i] = true end
for i=1,40 do pfValidUnits["raid" .. i] = true end
for i=1,40 do pfValidUnits["raidpet" .. i] = true end

for i=1,4 do pfValidUnits["party" .. i .. "target"] = true end
for i=1,4 do pfValidUnits["partypet" .. i .. "target"] = true end
for i=1,40 do pfValidUnits["raid" .. i .. "target"] = true end
for i=1,40 do pfValidUnits["raidpet" .. i .. "target"] = true end

local aggrodata = { }
function pfUI.api.UnitHasAggro(unit)
  if aggrodata[unit] and GetTime() < aggrodata[unit].check + 1 then
    return aggrodata[unit].state
  end

  aggrodata[unit] = { check = GetTime(), state = 0}

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
  if not this.val or this.val >= .9 then
    this.mod = -0.01 / fpsmod
  elseif this.val <= .6 then
    this.mod = 0.01  / fpsmod
  end
  this.val = this.val + this.mod
end)

pfUI.uf.glow.mod = 0
pfUI.uf.glow.val = 0

function pfUI.uf.glow.UpdateGlowAnimation()
  this:SetAlpha(pfUI.uf.glow.val)
end

function pfUI.uf:UpdateFrameSize()
  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  local spacing = self.config.pspace
  local width = self.config.width
  local height = self.config.height
  local pheight = self.config.pheight
  local real_height = height + spacing + pheight + 2*default_border
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
  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  local relative_point = "BOTTOM"
  if f.config.panchor == "TOPLEFT" then
     relative_point = "BOTTOMLEFT"
  elseif f.config.panchor == "TOPRIGHT" then
     relative_point = "BOTTOMRIGHT"
  end

  f:SetFrameStrata("BACKGROUND")

  f.hp:ClearAllPoints()
  f.hp:SetPoint("TOP", 0, 0)

  f.hp:SetWidth(f.config.width)
  f.hp:SetHeight(f.config.height)
  if tonumber(f.config.height) < 0 then f.hp:Hide() end
  pfUI.api.CreateBackdrop(f.hp, default_border)

  f.hp.glow:SetFrameStrata("BACKGROUND")
  f.hp.glow:SetFrameLevel(0)
  f.hp.glow:SetBackdrop({
    edgeFile = "Interface\\AddOns\\pfUI\\img\\glow2", edgeSize = 8,
    insets = {left = 0, right = 0, top = 0, bottom = 0},
  })
  f.hp.glow:SetPoint("TOPLEFT", f.hp, "TOPLEFT", -6 - default_border,6 + default_border)
  f.hp.glow:SetPoint("BOTTOMRIGHT", f.hp, "BOTTOMRIGHT", 6 + default_border,-6 - default_border)
  f.hp.glow:SetScript("OnUpdate", pfUI.uf.glow.UpdateGlowAnimation)
  f.hp.glow:Hide()

  f.hp.bar:SetStatusBarTexture(f.config.bartexture)
  f.hp.bar:SetAllPoints(f.hp)
  if f.config.verticalbar == "1" then
    f.hp.bar:SetOrientation("VERTICAL")
  else
    f.hp.bar:SetOrientation("HORIZONTAL")
  end

  if C.unitframes.custombg == "1" then
    local cr, cg, cb, ca = pfUI.api.strsplit(",", C.unitframes.custombgcolor)
    cr, cg, cb, ca = tonumber(cr), tonumber(cg), tonumber(cb), tonumber(ca)
    f.hp.bar.texture = f.hp.bar.texture or f.hp:CreateTexture(nil,"BACKGROUND")
    f.hp.bar.texture:SetTexture(cr,cg,cb,ca)
    f.hp.bar.texture:SetAllPoints(f.hp.bar)
  end

  f.power:ClearAllPoints()
  f.power:SetPoint(f.config.panchor, f.hp, relative_point, 0, -2*default_border - f.config.pspace)
  f.power:SetWidth((f.config.pwidth ~= "-1" and f.config.pwidth or f.config.width))
  f.power:SetHeight(f.config.pheight)
  if tonumber(f.config.pheight) < 0 then f.power:Hide() end

  pfUI.api.CreateBackdrop(f.power, default_border)
  f.power.bar:SetStatusBarTexture(f.config.bartexture)
  f.power.bar:SetAllPoints(f.power)

  f.power.glow:SetFrameStrata("BACKGROUND")
  f.power.glow:SetFrameLevel(0)
  f.power.glow:SetBackdrop({
    edgeFile = "Interface\\AddOns\\pfUI\\img\\glow2", edgeSize = 8,
    insets = {left = 0, right = 0, top = 0, bottom = 0},
  })
  f.power.glow:SetPoint("TOPLEFT", f.power, "TOPLEFT", -6 - default_border,6 + default_border)
  f.power.glow:SetPoint("BOTTOMRIGHT", f.power, "BOTTOMRIGHT", 6 + default_border,-6 - default_border)
  f.power.glow:SetScript("OnUpdate", pfUI.uf.glow.UpdateGlowAnimation)
  f.power.glow:Hide()

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
    f.portrait:SetFrameStrata("LOW")
    f.portrait.model:SetFrameStrata("LOW")
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
    f.feedbackText:SetFont(f.config.hitindicatorfont, f.config.hitindicatorsize, "OUTLINE")
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

  f.hpLeftText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.hpLeftText:SetJustifyH("LEFT")
  f.hpLeftText:SetFontObject(GameFontWhite)
  f.hpLeftText:SetParent(f.hp.bar)
  f.hpLeftText:ClearAllPoints()
  f.hpLeftText:SetPoint("TOPLEFT",f.hp.bar, "TOPLEFT", 2*default_border, 1)
  f.hpLeftText:SetPoint("BOTTOMRIGHT",f.hp.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.hpRightText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.hpRightText:SetJustifyH("RIGHT")
  f.hpRightText:SetFontObject(GameFontWhite)
  f.hpRightText:SetParent(f.hp.bar)
  f.hpRightText:ClearAllPoints()
  f.hpRightText:SetPoint("TOPLEFT",f.hp.bar, "TOPLEFT", 2*default_border, 1)
  f.hpRightText:SetPoint("BOTTOMRIGHT",f.hp.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.hpCenterText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.hpCenterText:SetJustifyH("CENTER")
  f.hpCenterText:SetFontObject(GameFontWhite)
  f.hpCenterText:SetParent(f.hp.bar)
  f.hpCenterText:ClearAllPoints()
  f.hpCenterText:SetPoint("TOPLEFT",f.hp.bar, "TOPLEFT", 2*default_border, 1)
  f.hpCenterText:SetPoint("BOTTOMRIGHT",f.hp.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.powerLeftText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.powerLeftText:SetJustifyH("LEFT")
  f.powerLeftText:SetFontObject(GameFontWhite)
  f.powerLeftText:SetParent(f.power.bar)
  f.powerLeftText:ClearAllPoints()
  f.powerLeftText:SetPoint("TOPLEFT",f.power.bar, "TOPLEFT", 2*default_border, 1)
  f.powerLeftText:SetPoint("BOTTOMRIGHT",f.power.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.powerRightText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.powerRightText:SetJustifyH("RIGHT")
  f.powerRightText:SetFontObject(GameFontWhite)
  f.powerRightText:SetParent(f.power.bar)
  f.powerRightText:ClearAllPoints()
  f.powerRightText:SetPoint("TOPLEFT",f.power.bar, "TOPLEFT", 2*default_border, 1)
  f.powerRightText:SetPoint("BOTTOMRIGHT",f.power.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.powerCenterText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
  f.powerCenterText:SetJustifyH("CENTER")
  f.powerCenterText:SetFontObject(GameFontWhite)
  f.powerCenterText:SetParent(f.power.bar)
  f.powerCenterText:ClearAllPoints()
  f.powerCenterText:SetPoint("TOPLEFT",f.power.bar, "TOPLEFT", 2*default_border, 1)
  f.powerCenterText:SetPoint("BOTTOMRIGHT",f.power.bar, "BOTTOMRIGHT", -2*default_border, 0)

  f.incHeal:SetFrameLevel(2)
  f.incHeal:SetHeight(f.config.height)
  f.incHeal:SetWidth(f.config.width)
  f.incHeal:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  f.incHeal:SetStatusBarColor(0, 1, 0, 0.5)
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
  f.ressIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\ress")
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
  f.pvpIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\pvp")
  f.pvpIcon.texture:SetAllPoints(f.pvpIcon)
  f.pvpIcon.texture:SetVertexColor(1,1,1,.5)
  f.pvpIcon:Hide()

  f.raidIcon:SetWidth(24)
  f.raidIcon:SetHeight(24)
  f.raidIcon:SetPoint("TOP", f, "TOP", 0, 6)

  f.raidIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")
  f.raidIcon.texture:SetAllPoints(f.raidIcon)
  f.raidIcon:Hide()

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

      local id = i
      local perrow = f.config.buffperrow
      local row = floor((i-1) / perrow)

      f.buffs[i] = f.buffs[i] or CreateFrame("Button", "pfUI" .. f.fname .. "Buff" .. i, f)
      f.buffs[i]:SetID(i)

      f.buffs[i].stacks = f.buffs[i].stacks or f.buffs[i]:CreateFontString(nil, "OVERLAY", f.buffs[i])
      f.buffs[i].stacks:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
      f.buffs[i].stacks:SetPoint("BOTTOMRIGHT", f.buffs[i], 2, -2)
      f.buffs[i].stacks:SetJustifyH("LEFT")
      f.buffs[i].stacks:SetShadowColor(0, 0, 0)
      f.buffs[i].stacks:SetShadowOffset(0.8, -0.8)
      f.buffs[i].stacks:SetTextColor(1,1,.5)
      f.buffs[i].cd = f.buffs[i].cd or CreateFrame("Model", nil, f.buffs[i])
      f.buffs[i].cd.pfCooldownType = "ALL"

      f.buffs[i]:RegisterForClicks("RightButtonUp")
      f.buffs[i]:ClearAllPoints()

      local invert, af, as
      if f.config.buffs == "top" then
        invert = 1
        af = "BOTTOMLEFT"
        as = "TOPLEFT"
      elseif f.config.buffs == "bottom" then
        invert = -1
        af = "TOPLEFT"
        as = "BOTTOMLEFT"
      end

      f.buffs[i]:SetPoint(af, f, as,
      (i-1-row*perrow)*((2*default_border) + f.config.buffsize + 1),
      invert * (row)*((2*default_border) + f.config.buffsize + 1) + invert*(2*default_border + 1))

      f.buffs[i]:SetWidth(f.config.buffsize)
      f.buffs[i]:SetHeight(f.config.buffsize)

      if f:GetName() == "pfPlayer" then
        f.buffs[i]:SetScript("OnUpdate", function()
          if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .4 end
          local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(this:GetID()-1,"HELPFUL"))
          CooldownFrame_SetTimer(this.cd, GetTime(), timeleft, 1)
        end)
      end

      f.buffs[i]:SetScript("OnEnter", function()
        local parent = this:GetParent()
        if not parent.label then return end

        GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
        if parent.label == "player" then
          GameTooltip:SetPlayerBuff(GetPlayerBuff(id-1,"HELPFUL"))
        else
          GameTooltip:SetUnitBuff(parent.label .. parent.id, id)
        end

        if IsShiftKeyDown() then
          local texture = parent.label == "player" and GetPlayerBuffTexture(GetPlayerBuff(id-1,"HELPFUL")) or UnitBuff(parent.label .. parent.id, id)

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
      end)

      f.buffs[i]:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)

      f.buffs[i]:SetScript("OnClick", function()
        if this:GetParent().label == "player" then
          CancelPlayerBuff(GetPlayerBuff(id-1,"HELPFUL"))
        end
      end)
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

      local id = i
      f.debuffs[i] = f.debuffs[i] or CreateFrame("Button", "pfUI" .. f.fname .. "Debuff" .. i, f)
      f.debuffs[i]:SetID(i)
      f.debuffs[i].stacks = f.debuffs[i].stacks or f.debuffs[i]:CreateFontString(nil, "OVERLAY", f.debuffs[i])
      f.debuffs[i].stacks:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
      f.debuffs[i].stacks:SetPoint("BOTTOMRIGHT", f.debuffs[i], 2, -2)
      f.debuffs[i].stacks:SetJustifyH("LEFT")
      f.debuffs[i].stacks:SetShadowColor(0, 0, 0)
      f.debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
      f.debuffs[i].stacks:SetTextColor(1,1,.5)
      f.debuffs[i].cd = f.debuffs[i].cd or CreateFrame("Model", nil, f.debuffs[i])
      f.debuffs[i].cd.pfCooldownType = "ALL"

      f.debuffs[i]:RegisterForClicks("RightButtonUp")
      f.debuffs[i]:ClearAllPoints()
      f.debuffs[i]:SetWidth(f.config.debuffsize)
      f.debuffs[i]:SetHeight(f.config.debuffsize)
      f.debuffs[i]:SetNormalTexture(nil)

      if f:GetName() == "pfPlayer" then
        f.debuffs[i]:SetScript("OnUpdate", function()
          if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .4 end
          local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(this:GetID()-1,"HARMFUL"))
          CooldownFrame_SetTimer(this.cd, GetTime(), timeleft, 1)
        end)
      end

      f.debuffs[i]:SetScript("OnEnter", function()
        if not this:GetParent().label then return end
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
        if this:GetParent().label == "player" then
          GameTooltip:SetPlayerBuff(GetPlayerBuff(id-1,"HARMFUL"))
        else
          GameTooltip:SetUnitDebuff(this:GetParent().label .. this:GetParent().id, id)
        end
      end)

      f.debuffs[i]:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)

      f.debuffs[i]:SetScript("OnClick", function()
        if this:GetParent().label == "player" then
          CancelPlayerBuff(GetPlayerBuff(id-1,"HARMFUL"))
        end
      end)
    end
  end

  if f.config.visible == "1" then
    pfUI.uf:RefreshUnit(f, "all")
    f:EnableScripts()
    f:UpdateFrameSize()
  else
    f:UnregisterAllEvents()
    f:Hide()
  end
end

function pfUI.uf:EnableScripts()
  local f = self

  f:RegisterForClicks('LeftButtonUp', 'RightButtonUp',
    'MiddleButtonUp', 'Button4Up', 'Button5Up')

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
  f:RegisterEvent("RAID_ROSTER_UPDATE") -- label=raid
  f:RegisterEvent("PLAYER_TARGET_CHANGED") -- label=target
  f:RegisterEvent("PARTY_LOOT_METHOD_CHANGED") -- frame=lootIcon
  f:RegisterEvent("RAID_TARGET_UPDATE") -- frame=raidIcon
  f:RegisterEvent("UNIT_PET")
  f:RegisterEvent("UNIT_HAPPINESS")

  f:SetScript("OnShow", function ()
      pfUI.uf:RefreshUnit(this)
    end)

  f:SetScript("OnEvent", function()
    if this.label == "target" and event == "PLAYER_TARGET_CHANGED" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif ( this.label == "party" or this.label == "player" ) and event == "PARTY_MEMBERS_CHANGED" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif this.label == "party" and event == "PARTY_MEMBER_ENABLE" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif this.label == "party" and event == "PARTY_MEMBER_DISABLE" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif this.label == "party" and event == "GROUP_ROSTER_UPDATE" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif ( this.label == "raid" or this.label == "party" ) and event == "RAID_ROSTER_UPDATE" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif this.label == "player" and (event == "PLAYER_AURAS_CHANGED" or event == "UNIT_INVENTORY_CHANGED") then
      pfUI.uf:RefreshUnit(this, "aura")
    elseif event == "PLAYER_ENTERING_WORLD" then
      pfUI.uf:RefreshUnit(this, "all")
    elseif event == "RAID_TARGET_UPDATE" then
      pfUI.uf:RefreshUnit(this, "raidIcon")
    elseif event == "PARTY_LOOT_METHOD_CHANGED" then
      pfUI.uf:RefreshUnit(this, "lootIcon")
    elseif event == "PARTY_LEADER_CHANGED" then
      pfUI.uf:RefreshUnit(this, "leaderIcon")
    elseif event == "UNIT_PET" and this.label == "pet" then
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
  end)

  f:SetScript("OnUpdate", function()
    local unitname = ( this.label and UnitName(this.label) ) or ""

    -- update combat feedback
    if this.feedbackText then CombatFeedback_OnUpdate(arg1) end

    -- focus unit detection
    if this.unitname and this.unitname ~= strlower(unitname) then
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

    if not this.label then return end

    pfUI.uf:RefreshUnitAnimation(this)

    -- trigger eventless actions (online/offline/range)
    if not this.lastTick then this.lastTick = GetTime() + (this.tick or .2) end
    if this.lastTick and this.lastTick < GetTime() then
      this.lastTick = GetTime() + (this.tick or .2)
      pfUI.uf:RefreshUnitState(this)

      if this.config.glowaggro == "1" and pfUI.api.UnitHasAggro(this.label .. this.id) > 0 then
        this.hp.glow:SetBackdropBorderColor(1,.2,0)
        this.power.glow:SetBackdropBorderColor(1,.2,0)
        this.hp.glow:Show()
        this.power.glow:Show()
      elseif this.config.glowcombat == "1" and UnitAffectingCombat(this.label .. this.id) then
        this.hp.glow:SetBackdropBorderColor(1,1,.2)
        this.power.glow:SetBackdropBorderColor(1,1,.2)
        this.hp.glow:Show()
        this.power.glow:Show()
      else
        this.hp.glow:SetBackdropBorderColor(1,1,1)
        this.power.glow:SetBackdropBorderColor(1,1,1)
        this.hp.glow:Hide()
        this.power.glow:Hide()
      end

      -- update everything on eventless frames (targettarget, etc)
      if this.tick then
        pfUI.uf:RefreshUnit(this, "all")
      end
    end
  end)

  f:SetScript("OnEnter", function()
    if not this.label then return end
    if this.config.showtooltip == "0" then return end
    GameTooltip_SetDefaultAnchor(GameTooltip, this)
    GameTooltip:SetUnit(this.label .. this.id)
    GameTooltip:Show()
  end)

  f:SetScript("OnLeave", function()
    GameTooltip:FadeOut()
  end)

  f:SetScript("OnClick", function ()
    if not this.label and this.unitname then
      local player = UnitIsUnit("target", "player")
      TargetByName(this.unitname)
      if strlower(UnitName("target")) ~= strlower(this.unitname) then
        if player then
          TargetUnit("player")
        else
          TargetLastTarget()
        end
      end
    else
      pfUI.uf:ClickAction(arg1)
    end
  end)
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

  local f = CreateFrame("Button", "pf" .. fname, UIParent)

  -- add unitframe functions
  f.UpdateFrameSize = pfUI.uf.UpdateFrameSize
  f.UpdateConfig    = pfUI.uf.UpdateConfig
  f.EnableScripts   = pfUI.uf.EnableScripts
  f.GetColor        = pfUI.uf.GetColor

  -- cache values to the frame
  f.label = unit
  f.fname = fname
  f.id = id
  f.config = config or pfUI_config.unitframes.fallback
  f.tick = tick

  -- disable events for unknown unitstrings
  if not pfValidUnits[unit .. id] then
    f.unitname = unit
    f.label, f.id = "mouseover", ""
    f.RegisterEvent = function() return end
  end

  f.hp = CreateFrame("Frame",nil, f)
  f.hp.glow = CreateFrame("Frame", nil, f.hp)
  f.hp.bar = CreateFrame("StatusBar", nil, f.hp)
  f.power = CreateFrame("Frame",nil, f)
  f.power.glow = CreateFrame("Frame", nil, f.power)
  f.power.bar = CreateFrame("StatusBar", nil, f.power)

  f.hpLeftText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.hpRightText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.hpCenterText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.powerLeftText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.powerRightText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
  f.powerCenterText = f:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")

  f.incHeal = CreateFrame("StatusBar", nil, f.hp)
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

  f.portrait = CreateFrame("Frame", "pfPortrait" .. f.label .. f.id, f)
  f.portrait.tex = f.portrait:CreateTexture("pfPortraitTexture" .. f.label .. f.id, "OVERLAY")
  f.portrait.model = CreateFrame("PlayerModel", "pfPortraitModel" .. f.label .. f.id, f.portrait)
  f.portrait.model.next = CreateFrame("PlayerModel", nil, nil)
  f.feedbackText = f:CreateFontString("pfHitIndicator" .. f.label .. f.id, "OVERLAY", "NumberFontNormalHuge")

  f:Hide()
  f:UpdateConfig()
  f:UpdateFrameSize()
  f:EnableScripts()

  if f.config.visible == "1" then
    pfUI.uf:RefreshUnit(f, "all")
    f:EnableScripts()
    f:UpdateFrameSize()
  else
    f:UnregisterAllEvents()
    f:Hide()
  end

  table.insert(pfUI.uf.frames, f)
  return f
end

function pfUI.uf:RefreshUnitAnimation(unitframe)
  if not unitframe.cache then return end
  if not unitframe.cache.hp or not unitframe.cache.power then return end
  if not UnitIsConnected(unitframe.label .. unitframe.id) then return end

  local hpDiff = abs(unitframe.cache.hp - unitframe.cache.hpdisplay)
  local powerDiff = abs(unitframe.cache.power - unitframe.cache.powerdisplay)

  if UnitName(unitframe.label .. unitframe.id) ~= ( unitframe.lastUnit or "" ) then
    -- instant refresh on unit change (e.g. target)
    unitframe.cache.hp = UnitHealth(unitframe.label .. unitframe.id)
    unitframe.cache.hpmax = UnitHealthMax(unitframe.label .. unitframe.id)

    if unitframe.config.invert_healthbar == "1" then
      unitframe.cache.hp = unitframe.cache.hpmax - unitframe.cache.hp
    end

    unitframe.cache.hpdisplay = unitframe.cache.hp
    unitframe.hp.bar:SetMinMaxValues(0, unitframe.cache.hpmax)
    unitframe.hp.bar:SetValue(unitframe.cache.hp)

    unitframe.cache.powermax = UnitManaMax(unitframe.label .. unitframe.id)
    unitframe.cache.powerdisplay = unitframe.cache.power
    unitframe.power.bar:SetMinMaxValues(0, unitframe.cache.powermax)
    unitframe.power.bar:SetValue(unitframe.cache.power)

    unitframe.lastUnit = UnitName(unitframe.label .. unitframe.id)
  else
    -- smoothen animation based on framerate
    local fpsmod = GetFramerate() / 30

    -- health animation active
    if unitframe.cache.hpanimation then
      if unitframe.cache.hpdisplay < unitframe.cache.hp then
        unitframe.cache.hpdisplay = unitframe.cache.hpdisplay + ceil(hpDiff / (pfUI_config.unitframes.animation_speed * fpsmod))
      elseif unitframe.cache.hpdisplay > unitframe.cache.hp then
        unitframe.cache.hpdisplay = unitframe.cache.hpdisplay - ceil(hpDiff / (pfUI_config.unitframes.animation_speed * fpsmod))
      else
        unitframe.cache.hpdisplay = unitframe.cache.hp
        unitframe.cache.hpanimation = nil
      end

      -- set statusbar
      unitframe.hp.bar:SetValue(unitframe.cache.hpdisplay)
    end

    -- power animation active
    if unitframe.cache.poweranimation then
      if unitframe.cache.powerdisplay < unitframe.cache.power then
        unitframe.cache.powerdisplay = unitframe.cache.powerdisplay + ceil(powerDiff / (pfUI_config.unitframes.animation_speed * fpsmod))
      elseif unitframe.cache.powerdisplay > unitframe.cache.power then
        unitframe.cache.powerdisplay = unitframe.cache.powerdisplay - ceil(powerDiff / (pfUI_config.unitframes.animation_speed * fpsmod))
      else
        unitframe.cache.powerdisplay = unitframe.cache.power
        unitframe.cache.poweranimation = nil
      end

      -- set statusbar
      unitframe.power.bar:SetValue(unitframe.cache.powerdisplay)
    end
  end
end

function pfUI.uf:RefreshUnitState(unit)
  local alpha = 1
  local unlock = pfUI.unlock and pfUI.unlock:IsShown() or nil

  if not UnitIsConnected(unit.label .. unit.id) and not unlock then
    -- offline
    alpha = .25
    unit.hp.bar:SetMinMaxValues(0, 100)
    unit.power.bar:SetMinMaxValues(0, 100)
    unit.hp.bar:SetValue(0)
    unit.power.bar:SetValue(0)
  elseif unit.config.faderange == "1" and not pfUI.api.UnitInRange(unit.label .. unit.id, 4) and not unlock then
    alpha = .5
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

  local component = component or ""

  if unit.config.visible ~= "1" then
    unit:Hide()
    return
  end

  -- don't update scanner activity
  if unit.label == "target" or unit.label == "targettarget" then
    if pfScanActive == true then return end
  end

  local C = pfUI_config
  -- show groupframes as raid
  if C["unitframes"]["raidforgroup"] == "1" then
    if strsub(unit:GetName(),0,6) == "pfRaid" then
      local id = tonumber(strsub(unit:GetName(),7,8))

      if not UnitInRaid("player") and GetNumPartyMembers() > 0 then
        if id == 1 then
          unit.id = ""
          unit.label = "player"
        elseif id <= 5 then
          unit.id = id - 1
          unit.label = "party"
        end
      elseif unit.label == "party" or unit.label == "player" then
        unit.id = id
        unit.label = "raid"
      end
    end
  end

  local unitstr = unit.label..unit.id

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  -- hide and return early on unused frames
  if not ( pfUI.unlock and pfUI.unlock:IsShown() ) then

    --keep focus and named frames visible
    if unit.unitname and unit.unitname ~= "focus" then
      unit:Show()


    -- only update visibility state for existing units
    elseif UnitName(unitstr) then

      -- hide group while in raid and option is set
      if C["unitframes"]["group"]["hide_in_raid"] == "1" and strsub(unit.label,0,5) == "party" and UnitInRaid("player") then
        unit:Hide()
        return

      -- hide existing but too far away pet and pets of old group members
      elseif unit.label == "partypet" then
        if not UnitIsVisible(unitstr) or not UnitExists("party" .. unit.id) then
          unit:Hide()
          return
        end

      elseif unit.label == "pettarget" then
        if not UnitIsVisible(unitstr) or not UnitExists("pet") then
          unit:Hide()
          return
        end

      -- hide self in group if solo or hide in raid is set
      elseif unit.fname == "Group0" or unit.fname == "PartyPet0" or unit.fname == "Party0Target" then
        if ( GetNumPartyMembers() <= 0 ) or ( C["unitframes"]["group"]["hide_in_raid"] == "1" and UnitInRaid("player") ) then
          unit:Hide()
          return
        end
      end

      unit:Show()
    else
      unit:Hide()
      return
    end
  end

  -- create required fields
  if not unit.cache then unit.cache = {} end
  if not unit.id then unit.id = "" end

  if not unit:IsShown() then return end

  -- Raid Icon
  if unit.raidIcon and ( component == "all" or component == "raidIcon" ) then
    local raidIcon = GetRaidTargetIndex(unitstr)
    if raidIcon and UnitName(unitstr) then
      SetRaidTargetIconTexture(unit.raidIcon.texture, raidIcon)
      unit.raidIcon:Show()
    else
      unit.raidIcon:Hide()
    end
  end

  -- Leader Icon
  if unit.leaderIcon and ( component == "all" or component == "leaderIcon" ) then
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
      unit.leaderIcon:Hide()
    elseif UnitIsPartyLeader(unitstr) then
      unit.leaderIcon:Show()
    else
      unit.leaderIcon:Hide()
    end
  end

  -- Loot Icon
  if unit.lootIcon and ( component == "all" or component == "lootIcon" ) then
    -- no third return value here.. but leaving this as a hint
    local method, group, raid = GetLootMethod()
    local name = group and UnitName(group == 0 and "player" or "party"..group) or raid and UnitName("raid"..raid) or nil

    if name and name == UnitName(unitstr) then
      unit.lootIcon:Show()
    else
      unit.lootIcon:Hide()
    end
  end

  -- PvP Icon
  if unit.pvpIcon and ( component == "all" or component == "pvp" ) then
    if unit.config.showPVP == "1" and UnitIsPVP(unitstr) then
      unit.pvpIcon:Show()
    else
      unit.pvpIcon:Hide()
    end
  end

  -- Buffs
  if unit.buffs and ( component == "all" or component == "aura" ) then
    for i=1, unit.config.bufflimit do
      local texture, stacks
      if unit.label == "player" then
       stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HELPFUL"))
       texture = GetPlayerBuffTexture(GetPlayerBuff(i-1,"HELPFUL"))
      else
       texture, stacks = UnitBuff(unitstr, i)
      end

      pfUI.api.CreateBackdrop(unit.buffs[i], default_border)
      unit.buffs[i]:SetNormalTexture(texture)
      for i,v in ipairs({unit.buffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

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

      local invert, af, as
      if unit.config.debuffs == "top" then
        invert = 1
        af = "BOTTOMLEFT"
        as = "TOPLEFT"
      elseif unit.config.debuffs == "bottom" then
        invert = -1
        af = "TOPLEFT"
        as = "BOTTOMLEFT"
      end

      unit.debuffs[i]:SetPoint(af, unit, as,
      (i-1-(row)*perrow)*((2*default_border) + unit.config.debuffsize + 1),
      invert * (row+buffrow)*((2*default_border) + unit.config.debuffsize + 1) + invert*(2*default_border + 1))

      local texture, stacks, dtype
      if unit.label == "player" then
        texture = GetPlayerBuffTexture(GetPlayerBuff(i-1, "HARMFUL"))
        stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1, "HARMFUL"))
        dtype = GetPlayerBuffDispelType(GetPlayerBuff(i-1, "HARMFUL"))
     else
       texture, stacks, dtype = UnitDebuff(unitstr, i)
     end

      pfUI.api.CreateBackdrop(unit.debuffs[i], default_border)
      unit.debuffs[i]:SetNormalTexture(texture)
      for i,v in ipairs({unit.debuffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

      local r,g,b = DebuffTypeColor.none.r,DebuffTypeColor.none.g,DebuffTypeColor.none.b
      if dtype and DebuffTypeColor[dtype] then
        r,g,b = DebuffTypeColor[dtype].r,DebuffTypeColor[dtype].g,DebuffTypeColor[dtype].b
      end
      unit.debuffs[i].backdrop:SetBackdropBorderColor(r,g,b,1)

      if texture then
        unit.debuffs[i]:Show()

        if unit:GetName() == "pfPlayer" then
          local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(unit.debuffs[i]:GetID() - 1, "HARMFUL"),"HARMFUL")
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
  if component == "all" or component == "aura" then
    pfUI.uf:SetupDebuffFilter()
    if table.getn(pfUI.uf.debuffs) > 0 and unit.config.debuff_indicator ~= "0" then
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

      for _, debuff in pairs(pfUI.uf.debuffs) do
        indicator[debuff] = indicator[debuff] or CreateFrame("Frame", nil, indicator)
        indicator[debuff]:SetParent(indicator)
        indicator[debuff].tex = indicator[debuff].tex or indicator[debuff]:CreateTexture(nil)
        indicator[debuff].tex:SetAllPoints(indicator[debuff])

        if indicator.size ~= indicator[debuff].size or disptype ~= indicator[debuff].disp then
          if disptype == "4" then
            indicator[debuff].tex:SetTexture("Interface\\AddOns\\pfUI\\img\\debuffs\\" .. debuff)
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
            indicator[debuff]:SetBackdrop({
              edgeFile = "Interface\\AddOns\\pfUI\\img\\glow", edgeSize = 8,
              insets = {left = 0, right = 0, top = 0, bottom = 0},
            })
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

    pfUI.uf:SetupBuffFilter()
    if table.getn(pfUI.uf.buffs) > 0 and unit.config.buff_indicator == "1" then
      local active = {}

      for i=1,32 do
        local texture = UnitBuff(unitstr, i)

        if texture then
          -- match filter
          for _, filter in pairs(pfUI.uf.buffs) do
            if filter == string.lower(texture) then
              table.insert(active, texture)
              break
            end
          end
        end
      end

      -- add icons for every found buff
      for pos, icon in pairs(active) do
        pfUI.uf:AddIcon(unit, pos, icon)
      end

      -- hide unued icon slots
      for pos=table.getn(active)+1, 6 do
        pfUI.uf:HideIcon(unit, pos)
      end
    end
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
        end
        unit.portrait.tex:Hide()
        unit.portrait.model:Show()

        if unit.tick then
          unit.portrait.model.next:SetUnit(unitstr)
          if unit.portrait.model.lastUnit ~= UnitName(unitstr) or unit.portrait.model:GetModel() ~= unit.portrait.model.next:GetModel() then
            unit.portrait.model:SetUnit(unitstr)
            unit.portrait.model.lastUnit = UnitName(unitstr)
            unit.portrait.model:SetCamera(0)
          end
        else
          unit.portrait.model:SetUnit(unitstr)
          unit.portrait.model:SetCamera(0)
        end
      end
    end
  end

  -- Unit HP/MP
  unit.cache.hp = UnitHealth(unitstr)
  unit.cache.hpmax = UnitHealthMax(unitstr)
  unit.cache.hpdisplay = unit.hp.bar:GetValue()

  unit.cache.power = UnitMana(unitstr)
  unit.cache.powermax = UnitManaMax(unitstr)
  unit.cache.powerdisplay = unit.power.bar:GetValue()

  unit.hp.bar:SetMinMaxValues(0, unit.cache.hpmax)
  unit.power.bar:SetMinMaxValues(0, unit.cache.powermax)

  if unit.config.invert_healthbar == "1" then
    unit.cache.hp = unit.cache.hpmax - unit.cache.hp
  end

  if unit.cache.hpdisplay ~= unit.cache.hp then
    if C.unitframes.animation_speed == "1" then
      unit.hp.bar:SetValue(unit.cache.hp)
    else
      unit.cache.hpanimation = true
    end
  end

  if unit.cache.powerdisplay ~= unit.cache.power then
    if C.unitframes.animation_speed == "1" then
      unit.power.bar:SetValue(unit.cache.power)
    else
      unit.cache.poweranimation = true
    end
  end

  local color = { r = .2, g = .2, b = .2 }
  if UnitIsPlayer(unitstr) then
    local _, class = UnitClass(unitstr)
    color = RAID_CLASS_COLORS[class] or color
  elseif unit.label == "pet" then
    local happiness = GetPetHappiness()
    if happiness == 1 then
      color = { r = 1, g = 0, b = 0 }
    elseif happiness == 2 then
      color = { r = 1, g = 1, b = 0 }
    else
      color = { r = 0, g = 1, b = 0 }
    end
  else
    color = UnitReactionColor[UnitReaction(unitstr, "player")] or color
  end

  local r, g, b = .2, .2, .2
  if C.unitframes.custom == "1" then
    local cr, cg, cb, ca = pfUI.api.strsplit(",", C.unitframes.customcolor)
    cr, cg, cb, ca = tonumber(cr), tonumber(cg), tonumber(cb), tonumber(ca)
    unit.hp.bar:SetStatusBarColor(cr, cg, cb, ca)
    if C.unitframes.pastel == "1" then
      r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5
    else
      r, g, b = color.r, color.g, color.b
    end
  else
    if C.unitframes.pastel == "1" then
      r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5
    else
      r, g, b = color.r, color.g, color.b
    end
    unit.hp.bar:SetStatusBarColor(r, g, b)
  end

  local p = ManaBarColor[UnitPowerType(unitstr)]
  local pr, pg, pb = 0, 0, 0
  if p then pr, pg, pb = p.r + .5, p.g +.5, p.b +.5 end
  unit.power.bar:SetStatusBarColor(pr, pg, pb)

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

function pfUI.uf:ClickAction(button)
  local label = this.label or ""
  local id = this.id or ""
  local unitstr = label .. id

  if SpellIsTargeting() and button == "RightButton" then
    SpellStopTargeting()
    return
  end

  if SpellIsTargeting() and button == "LeftButton" then
    SpellTargetUnit(unitstr)
  elseif CursorHasItem() then
    DropItemOnUnit(unitstr)
  end

  -- dropdown menus
  if button == "RightButton" then
    if label == "player" then
      ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor")
    elseif label == "target" then
      ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
    elseif label == "pet" then
      ToggleDropDownMenu(1, nil, PetFrameDropDown, "cursor")
    elseif label == "party" then
      ToggleDropDownMenu(1, nil, getglobal("PartyMemberFrame" .. this.id .. "DropDown"), "cursor")
    elseif label == "raid" then
      local name = this.lastUnit
      FriendsDropDown.displayMode = "MENU"
      FriendsDropDown.initialize = function() UnitPopup_ShowMenu(getglobal(UIDROPDOWNMENU_OPEN_MENU), "PARTY", unitstr, name, id) end
      ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
    end
  else
    -- drop food on petframe
    if label == "pet" and CursorHasItem() then
      local _, playerClass = UnitClass("player")
      if playerClass == "HUNTER" then
        DropItemOnUnit("pet")
        return
      end
    end

    -- prevent TargetLastTarget if target was target
    local tswitch = UnitIsUnit(unitstr, "target")

    -- default click
    TargetUnit(unitstr)

    if this.config.clickcast == "1" then
      -- clickcast: shift modifier
      if IsShiftKeyDown() then
        if pfUI_config.unitframes.clickcast_shift ~= "" then
          CastSpellByName(pfUI_config.unitframes.clickcast_shift)
          if not tswitch then TargetLastTarget() end
          return
        end

      -- clickcast: alt modifier
      elseif IsAltKeyDown() then
        if pfUI_config.unitframes.clickcast_alt ~= "" then
          CastSpellByName(pfUI_config.unitframes.clickcast_alt)
          if not tswitch then TargetLastTarget() end
          return
        end

      -- clickcast: ctrl modifier
      elseif IsControlKeyDown() then
        if pfUI_config.unitframes.clickcast_ctrl ~= "" then
          CastSpellByName(pfUI_config.unitframes.clickcast_ctrl)
          if not tswitch then TargetLastTarget() end
          return
        end

      -- clickcast: default
      else
        if pfUI_config.unitframes.clickcast ~= "" then
          CastSpellByName(pfUI_config.unitframes.clickcast)
          if not tswitch then TargetLastTarget() end
          return
        end
      end
    end
  end
end

function pfUI.uf:AddIcon(frame, pos, icon)
  local iconsize = C.unitframes.indicator_size
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
  pfUI.api.CreateBackdrop(frame.icon[pos], nil, true)
  frame.icon[pos]:Show()
end

function pfUI.uf:HideIcon(frame, pos)
  if not frame or not frame.hp or not frame.hp.bar then return end

  local frame = frame.hp.bar
  if frame.icon and frame.icon[pos] then
    frame.icon[pos]:Hide()
  end
end

function pfUI.uf:SetupDebuffFilter()
  if pfUI.uf.debuffs then return end

  local _, myclass = UnitClass("player")
  pfUI.uf.debuffs = {}
  if myclass == "PALADIN" or myclass == "PRIEST" or myclass == "WARLOCK" or pfUI_config.unitframes.debuffs_class == "0" then
    table.insert(pfUI.uf.debuffs, "Magic")
  end

  if myclass == "DRUID" or myclass == "PALADIN" or myclass == "SHAMAN" or pfUI_config.unitframes.debuffs_class == "0" then
    table.insert(pfUI.uf.debuffs, "Poison")
  end

  if myclass == "PRIEST" or myclass == "PALADIN" or myclass == "SHAMAN" or pfUI_config.unitframes.debuffs_class == "0" then
    table.insert(pfUI.uf.debuffs, "Disease")
  end

  if myclass == "DRUID" or myclass == "MAGE" or pfUI_config.unitframes.debuffs_class == "0" then
    table.insert(pfUI.uf.debuffs, "Curse")
  end
end

function pfUI.uf:SetupBuffFilter()
  if pfUI.uf.buffs then return end

  local _, myclass = UnitClass("player")

  pfUI.uf.buffs = {}

  -- [[ DRUID ]]
  if myclass == "DRUID" then
    -- Gift of the Wild
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_regeneration")

    -- Thorns
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_thorns")
  end

  -- [[ PRIEST ]]
  if myclass == "PRIEST" then
    -- Prayer Of Fortitude"
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_wordfortitude")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_prayeroffortitude")

    -- Prayer of Spirit
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_divinespirit")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_prayerofspirit")

    -- Shadow Protection
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_antishadow")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_prayerofshadowprotection")

    -- Fear Ward
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_excorcism")
  end

  -- [[ PALADIN ]]
  if myclass == "PALADIN" then
    -- Blessing of Salvation
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_greaterblessingofsalvation")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_sealofsalvation")

    -- Blessing of Wisdom
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_sealofwisdom")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_greaterblessingofwisdom")

    -- Blessing of Sanctuary
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_lightningshield")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_greaterblessingofsanctuary")

    -- Blessing of Kings
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_magic_magearmor")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_magic_greaterblessingofkings")

    -- Blessing of Might
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_fistofjustice")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_greaterblessingofkings")

    -- Blessing of Light
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_prayerofhealing02")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_greaterblessingoflight")
  end


  -- [[ WARLOCK ]]
  if myclass == "WARLOCK" then
    -- Fire Shield
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_fire_firearmor")

    -- Blood Pact
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_bloodboil")

    -- Soulstone
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_soulgem")

    -- Unending Breath
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_demonbreath")

    -- Detect Greater Invisibility or Detect Invisibility
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_detectinvisibility")

    -- Detect Lesser Invisibility
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_shadow_detectlesserinvisibility")

    -- Paranoia
    table.insert(pfUI.uf.buffs, "interface\\icons\\Spell_Shadow_AuraOfDarkness")
  end


  -- [[ WARRIOR ]]
  if myclass == "WARRIOR" then
    -- Battle Shout
    table.insert(pfUI.uf.buffs, "interface\\icons\\ability_warrior_battleshout")
  end


  -- [[ MAGE ]]
  if myclass == "MAGE" then
    -- Arcane Intellect
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_magicalsentry")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_arcaneintellect")

    -- Dampen Magic
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_abolishmagic")

    -- Amplify Magic
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_flashheal")
  end

  -- PROCS
  -- [[ SHAMAN ]]
  if (pfUI_config.unitframes.all_procs == "1" or myclass == "SHAMAN") and pfUI_config.unitframes.show_procs == "1" then
    -- Ancestral Fortitude
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_undyingstrength")

    -- Healing Way
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_healingway")

    -- Totemic Power (known issue: one conflicts with Blessed Sunfruit buff)
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_spiritualguidence")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_devotion")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_holynova")
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_magic_magearmor")
  end

  if (pfUI_config.unitframes.all_procs == "1" or myclass == "SHAMAN") and pfUI_config.unitframes.show_totems == "1" then
    -- Strength of Earth Totem
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_earthbindtotem")

    -- Stoneskin Totem
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_stoneskintotem")

    -- Mana Spring Totem
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_manaregentotem")

    -- Mana Tide Totem
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_frost_summonwaterelemental")

    -- Healing Spring Totem
    table.insert(pfUI.uf.buffs, "interface\\icons\\inv_spear_04")

    -- Tranquil Air Totem
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_brilliance")

    -- Grace of Air Totem
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_invisibilitytotem")

    -- Grounding Totem
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_groundingtotem")

    -- Nature Resistance Totem
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_natureresistancetotem")

    -- Fire Resistance Totem
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_fireresistancetotem_01")

    -- Frost Resistance Totem
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_frostresistancetotem_01")
  end

  if (pfUI_config.unitframes.all_procs == "1" or myclass == "PRIEST") and pfUI_config.unitframes.show_procs == "1" then
    -- Inspiration
    table.insert(pfUI.uf.buffs, "interface\\icons\\inv_shield_06")
  end

  -- HOTS
  if (pfUI_config.unitframes.all_hots == "1" or myclass == "PRIEST") and pfUI_config.unitframes.show_hots == "1" then
    -- Renew
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_holy_renew")
  end

  if (pfUI_config.unitframes.all_hots == "1" or myclass == "DRUID") and pfUI_config.unitframes.show_hots == "1" then
    -- Regrowth
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_resistnature")

    -- Rejuvenation
    table.insert(pfUI.uf.buffs, "interface\\icons\\spell_nature_rejuvenation")
  end
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
  if unit.label == "target" and (MobHealth3 or MobHealthFrame) and MobHealth_GetTargetCurHP() then
    hp, hpmax = MobHealth_GetTargetCurHP(), MobHealth_GetTargetMaxHP()
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
    return unit:GetColor("class") .. (UnitClass(unitstr) or UNKNOWN)

  -- health
  elseif config == "health" then
    return unit:GetColor("health") .. pfUI.api.Abbreviate(hp)
  elseif config == "healthmax" then
    return unit:GetColor("health") .. pfUI.api.Abbreviate(hpmax)
  elseif config == "healthperc" then
    return unit:GetColor("health") .. ceil(hp / hpmax * 100)
  elseif config == "healthmiss" then
    local health = ceil(hp - hpmax)
    if UnitIsDead(unitstr) then
      return unit:GetColor("health") .. DEAD
		elseif health == 0 then
      return unit:GetColor("health") .. "0"
    else
      return unit:GetColor("health") .. pfUI.api.Abbreviate(health)
    end
  elseif config == "healthdyn" then
    if hp ~= hpmax then
      return unit:GetColor("health") .. pfUI.api.Abbreviate(hp) .. " - " .. ceil(hp / hpmax * 100) .. "%"
    else
      return unit:GetColor("health") .. pfUI.api.Abbreviate(hp)
    end
  elseif config == "healthminmax" then
    return unit:GetColor("health") .. pfUI.api.Abbreviate(hp) .. "/" .. pfUI.api.Abbreviate(hpmax)

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
    if mp ~= mpmax then
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
  r = ( r + .75 ) * .5
  g = ( g + .75 ) * .5
  b = ( b + .75 ) * .5

  return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255)
end
