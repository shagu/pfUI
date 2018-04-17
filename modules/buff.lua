pfUI:RegisterModule("buff", function ()
  -- Hide Blizz
  BuffFrame:Hide()
  BuffFrame:UnregisterAllEvents()
  TemporaryEnchantFrame:Hide()
  TemporaryEnchantFrame:UnregisterAllEvents()

  local function RefreshBuffButton(buff)
    buff.id = buff.gid - (buff.btype == "HELPFUL" and pfUI.buff.buffs.offset or 0)
    buff.bid = GetPlayerBuff(buff.id-1, buff.btype)

    -- detect weapon buffs
    if buff.gid <= pfUI.buff.buffs.offset and buff.btype == "HELPFUL" then
      local mh, mhtime, mhcharge, oh, ohtime, ohcharge = GetWeaponEnchantInfo()
      if pfUI.buff.buffs.offset == 2 then
        if buff.gid == 1 then
          buff.mode = "MAINHAND"
        else
          buff.mode = "OFFHAND"
        end
      else
        buff.mode = oh and "OFFHAND" or mh and "MAINHAND"
      end

      -- Set Weapon Texture and Border
      if buff.mode == "MAINHAND" then
        buff.texture:SetTexture(GetInventoryItemTexture("player", 16))
        buff.backdrop:SetBackdropBorderColor(GetItemQualityColor(GetInventoryItemQuality("player", 16) or 1))
      elseif buff.mode == "OFFHAND" then
        buff.texture:SetTexture(GetInventoryItemTexture("player", 17))
        buff.backdrop:SetBackdropBorderColor(GetItemQualityColor(GetInventoryItemQuality("player", 17) or 1))
      end
    elseif buff.bid >= 0 and (( buff.btype == "HARMFUL" and C.buffs.debuffs == "1" ) or ( buff.btype == "HELPFUL" and C.buffs.buffs == "1" )) then
      -- Set Buff Texture and Border
      buff.mode = buff.btype
      buff.texture:SetTexture(GetPlayerBuffTexture(buff.bid))
      CreateBackdrop(buff)

      if buff.btype == "HARMFUL" then
        local dtype = GetPlayerBuffDispelType(buff.bid)
        if dtype == "Magic" then
          buff.backdrop:SetBackdropBorderColor(0,1,1,1)
        elseif dtype == "Poison" then
          buff.backdrop:SetBackdropBorderColor(0,1,0,1)
        elseif dtype == "Curse" then
          buff.backdrop:SetBackdropBorderColor(1,0,1,1)
        elseif dtype == "Disease" then
          buff.backdrop:SetBackdropBorderColor(1,1,0,1)
        else
          buff.backdrop:SetBackdropBorderColor(1,0,0,1)
        end
      end
    else
      buff:Hide()
      return
    end

    buff:Show()
  end

  local function CreateBuffButton(i, btype)
    local buff = CreateFrame("Button", ( btype == "HELPFUL" and "pfBuffFrameBuff" or "pfDebuffFrameBuff" ) .. i, ( btype == "HARMFUL" and pfUI.buff.debuffs or pfUI.buff.buffs ))
    buff.texture = buff:CreateTexture("BuffIcon" .. i, "BACKGROUND")
    buff.texture:SetTexCoord(.07,.93,.07,.93)
    buff.texture:SetAllPoints(buff)

    buff.timer = buff:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buff.timer:SetTextColor(1,1,1,1)
    buff.timer:SetJustifyH("CENTER")
    buff.timer:SetJustifyV("CENTER")

    buff.stacks = buff:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buff.stacks:SetTextColor(1,1,1,1)
    buff.stacks:SetJustifyH("RIGHT")
    buff.stacks:SetJustifyV("BOTTOM")
    buff.stacks:SetAllPoints(buff)

    buff:RegisterForClicks("RightButtonUp")

    buff.btype = btype
    buff.gid = i

    buff:SetScript("OnUpdate", function()
      if not this.next then this.next = GetTime() + .1 end
      if this.next > GetTime() then return end
      this.next = GetTime() + .1

      local timeleft = 0
      local stacks = 0

      if this.mode == this.btype then
        timeleft = GetPlayerBuffTimeLeft(this.bid, this.btype)
        stacks = GetPlayerBuffApplications(this.bid, this.btype)
      elseif this.mode == "MAINHAND" then
        local _, mhtime, mhcharge = GetWeaponEnchantInfo()
        timeleft = mhtime/1000
        stacks = mhcharge
      elseif this.mode == "OFFHAND" then
        local _, _, _, _, ohtime, ohcharge = GetWeaponEnchantInfo()
        timeleft = ohtime/1000
        charge = ohcharge
      end

      this.timer:SetText(timeleft > 0 and GetColoredTimeString(timeleft) or "")
      this.stacks:SetText(stacks > 1 and stacks or "")
    end)

    buff:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
      if this.mode == this.btype then
        GameTooltip:SetPlayerBuff(this.bid)

        if IsShiftKeyDown() then
          local texture = GetPlayerBuffTexture(this.bid)

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
              playerlist = playerlist .. ( not first and ", " or "") .. GetUnitColor(unitstr) .. UnitName("player") .. "|r"
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
      elseif this.mode == "MAINHAND" then
        GameTooltip:SetInventoryItem("player", 16)
      elseif this.mode == "OFFHAND" then
        GameTooltip:SetInventoryItem("player", 17)
      end
    end)

    buff:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    buff:SetScript("OnClick", function()
      CancelPlayerBuff(this.bid)
    end)

    CreateBackdrop(buff)
    RefreshBuffButton(buff)

    return buff
  end

  local function GetNumBuffs()
    local mh, mhtime, mhcharge, oh, ohtime, ohcharge = GetWeaponEnchantInfo()
    local offset = (mh and 1 or 0) + (oh and 1 or 0)

    for i=1,32 do
      local bid, untilCancelled = GetPlayerBuff(i-1, "HELPFUL")
      if bid < 0 then
        return i - 1 + offset
      end
    end
    return 0 + offset
  end

  pfUI.buff = CreateFrame("Frame", "pfGlobalBuffFrame", UIParent)
  pfUI.buff:RegisterEvent("PLAYER_AURAS_CHANGED")
  pfUI.buff:RegisterEvent("UNIT_INVENTORY_CHANGED")
  pfUI.buff:RegisterEvent("UNIT_MODEL_CHANGED")
  pfUI.buff:SetScript("OnEvent", function()
    if C.buffs.weapons == "1" then
      local mh, mhtime, mhcharge, oh, ohtime, ohcharge = GetWeaponEnchantInfo()
      pfUI.buff.buffs.offset = (mh and 1 or 0) + (oh and 1 or 0)
    else
      pfUI.buff.buffs.offset = 0
    end

    for i=1,32 do
      RefreshBuffButton(pfUI.buff.buffs.buttons[i])
    end

    for i=1,16 do
      RefreshBuffButton(pfUI.buff.debuffs.buttons[i])
    end
  end)

  -- Buff Frame
  pfUI.buff.buffs = CreateFrame("Frame", "pfBuffFrame", UIParent)
  pfUI.buff.buffs.offset = 0
  pfUI.buff.buffs.buttons = {}
  for i=1,32 do
    pfUI.buff.buffs.buttons[i] = CreateBuffButton(i, "HELPFUL")
  end

  -- Debuffs
  pfUI.buff.debuffs = CreateFrame("Frame", "pfDebuffFrame", UIParent)
  pfUI.buff.debuffs.buttons = {}
  for i=1,16 do
    pfUI.buff.debuffs.buttons[i] = CreateBuffButton(i, "HARMFUL")
  end

  -- config loading
  function pfUI.buff:UpdateConfigBuffButton(buff)
    local fontsize = C.buffs.fontsize == "-1" and C.global.font_size or C.buffs.fontsize
    local rowcount = floor((buff.gid-1) / tonumber(C.buffs.rowsize))
    buff:SetWidth(tonumber(C.buffs.size))
    buff:SetHeight(tonumber(C.buffs.size))
    buff:ClearAllPoints()
    buff:SetPoint("TOPRIGHT", ( buff.btype == "HARMFUL" and pfUI.buff.debuffs or pfUI.buff.buffs ), "TOPRIGHT", -(buff.gid-1-rowcount*tonumber(C.buffs.rowsize))*(tonumber(C.buffs.size)+2*tonumber(C.buffs.spacing)), -(rowcount) * ((C.buffs.textinside == "1" and 0 or (fontsize*1.5))+tonumber(C.buffs.size)+2*tonumber(C.buffs.spacing)))

    buff.timer:SetFont(pfUI.font_default, fontsize, "OUTLINE")
    buff.stacks:SetFont(pfUI.font_default, fontsize+1, "OUTLINE")

    buff.timer:SetHeight(fontsize * 1.3)

    buff.timer:ClearAllPoints()
    if C.buffs.textinside == "1" then
      buff.timer:SetAllPoints(buff)
    else
      buff.timer:SetPoint("TOP", buff, "BOTTOM", 0, -3)
    end
  end

  function pfUI.buff:UpdateConfig()
    local fontsize = C.buffs.fontsize == "-1" and C.global.font_size or C.buffs.fontsize

    pfUI.buff.buffs:SetWidth(tonumber(C.buffs.rowsize) * (tonumber(C.buffs.size)+2*tonumber(C.buffs.spacing)))
    pfUI.buff.buffs:SetHeight(ceil(32/tonumber(C.buffs.rowsize)) * ((C.buffs.textinside == "1" and 0 or (fontsize*1.5))+tonumber(C.buffs.size)+2*tonumber(C.buffs.spacing)))
    pfUI.buff.buffs:SetPoint("TOPRIGHT", pfUI.minimap or UIParent, "TOPLEFT", -2*tonumber(C.buffs.spacing), 0)
    UpdateMovable(pfUI.buff.buffs)

    pfUI.buff.debuffs:SetWidth(tonumber(C.buffs.rowsize) * (tonumber(C.buffs.size)+2*tonumber(C.buffs.spacing)))
    pfUI.buff.debuffs:SetHeight(ceil(16/tonumber(C.buffs.rowsize)) * ((C.buffs.textinside == "1" and 0 or (fontsize*1.5))+tonumber(C.buffs.size)+2*tonumber(C.buffs.spacing)))
    pfUI.buff.debuffs:SetPoint("TOPRIGHT", pfUI.buff.buffs, "BOTTOMRIGHT", 0, 0)
    UpdateMovable(pfUI.buff.debuffs)

    for i=1,32 do
      pfUI.buff:UpdateConfigBuffButton(pfUI.buff.buffs.buttons[i])
    end

    for i=1,16 do
      pfUI.buff:UpdateConfigBuffButton(pfUI.buff.debuffs.buttons[i])
    end

    pfUI.buff:GetScript("OnEvent")()
  end

  pfUI.buff:UpdateConfig()
end)
