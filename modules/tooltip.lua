pfUI:RegisterModule("tooltip", function ()
  local alpha = tonumber(C.tooltip.alpha)
  CreateBackdrop(GameTooltip, nil, nil, alpha)

  -- prevent tooltips from being placed offscreen
  GameTooltip:SetClampedToScreen(true)
  GameTooltipStatusBar:SetClampedToScreen(true)

  if C.tooltip.position == "cursor" then
    function _G.GameTooltip_SetDefaultAnchor(tooltip, parent)
      tooltip:SetOwner(parent, "ANCHOR_CURSOR")
      if C.tooltip.cursoralign ~= "native" then
        -- create mouse follow frame
        if not tooltip.cursor then
          tooltip.cursor = CreateFrame("Frame")
          tooltip.cursor:SetWidth(tonumber(C.tooltip.cursoroffset) * 2)
          tooltip.cursor:SetHeight(tonumber(C.tooltip.cursoroffset) * 2)
          tooltip.cursor:SetScript("OnUpdate", function()
            local x, y = GetCursorPosition()
            this:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
            if C.tooltip.cursoralign == "top" then
              tooltip.cursor:SetWidth(tooltip:GetWidth())
            end
          end)
        end

        -- adjust tooltip to mouse frame
        if C.tooltip.cursoralign == "top" then
          tooltip:SetPoint("BOTTOMLEFT", tooltip.cursor, "TOPLEFT", 0, 0)
        elseif C.tooltip.cursoralign == "left" then
          tooltip:SetPoint("BOTTOMRIGHT", tooltip.cursor, "TOPLEFT", 0, 0)
        elseif C.tooltip.cursoralign == "right" then
          tooltip:SetPoint("BOTTOMLEFT", tooltip.cursor, "TOPRIGHT", 0, 0)
        end
      end
    end
  end

  pfUI.tooltip = CreateFrame('Frame', "pfTooltip", GameTooltip)
  function pfUI.tooltip:GetUnit()
    pfUI.tooltip.unit = "none"

    for i, unit in pairs({"mouseover", "player", "pet", "target", "party", "partypet", "raid", "raidpet"}) do
      if unit == "party" or unit == "partypet" then
        for i=1,4 do
          if UnitExists(unit .. i) and ( UnitName(unit .. i) == GameTooltipTextLeft1:GetText() or UnitPVPName(unit .. i) == GameTooltipTextLeft1:GetText() ) then
            pfUI.tooltip.unit = unit .. i
            return pfUI.tooltip.unit
          end
        end
      elseif unit == "raid" or unit == "raidpet" then
        for i=1,40 do
          if UnitExists(unit .. i) and ( UnitName(unit .. i) == GameTooltipTextLeft1:GetText() or UnitPVPName(unit .. i) == GameTooltipTextLeft1:GetText() ) then
            pfUI.tooltip.unit = unit .. i
            return pfUI.tooltip.unit
          end
        end
      else
        if UnitExists(unit) and ( UnitName(unit) == GameTooltipTextLeft1:GetText() or UnitPVPName(unit) == GameTooltipTextLeft1:GetText() ) then
          pfUI.tooltip.unit = unit
          return pfUI.tooltip.unit
        end
      end
    end
    return pfUI.tooltip.unit
  end

  pfUI.tooltip:SetAllPoints()
  pfUI.tooltip:SetScript("OnShow", function()
      pfUI.tooltip:Update()
      if GameTooltip:GetAnchorType() == "ANCHOR_NONE" then
        GameTooltip:ClearAllPoints()
        if C.tooltip.position == "bottom" then
          if pfUI.panel then
            GameTooltip:SetPoint("BOTTOMRIGHT", pfUI.panel.right, "TOPRIGHT", 0, C.appearance.border.default*2)
          else
            GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 5)
          end
        elseif C.tooltip.position == "chat" then
          local anchor = nil

          if pfUI.panel and pfUI.panel.right:IsShown() then
            anchor = pfUI.panel.right
          end

          if pfUI.chat and pfUI.chat.right:IsShown() then
            anchor = pfUI.chat.right
          end

          if pfUI.bag and pfUI.bag.right and pfUI.bag.right:IsShown() and C.appearance.bags.movable == "0" then
            anchor = pfUI.bag.right
          end

          if anchor then
            GameTooltip:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, C.appearance.border.default*2)
          else
            GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 5)
          end
        end
      end
    end)

  pfUI.tooltipStatusBar = CreateFrame('Frame', nil, GameTooltipStatusBar)
  pfUI.tooltipStatusBar:SetScript("OnUpdate", function()
      hp = GameTooltipStatusBar:GetValue()
      _, hpm = GameTooltipStatusBar:GetMinMaxValues()

      if hp and hpm then
        if hp >= 1000 then hp = round(hp / 1000, 1) .. "k" end
        if hpm >= 1000 then hpm = round(hpm / 1000, 1) .. "k" end

        if pfUI.tooltipStatusBar and pfUI.tooltipStatusBar.HP then
          pfUI.tooltipStatusBar.HP:SetText(hp .. " / " .. hpm)
        end
      end
  end)

  GameTooltipStatusBar:SetHeight(6)
  GameTooltipStatusBar:ClearAllPoints()
  GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 0, 0)
  GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", 0, 0)
  GameTooltipStatusBar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  CreateBackdrop(GameTooltipStatusBar)
  GameTooltipStatusBar.SetStatusBarColor_orig = GameTooltipStatusBar.SetStatusBarColor
  GameTooltipStatusBar.SetStatusBarColor = function() return end

  function pfUI.tooltip:Update()
      local unit = pfUI.tooltip:GetUnit()
      if unit == "none" then return end
      local pvpname = UnitPVPName(unit)
      local name = UnitName(unit)
      local target = UnitName(unit .. "target")
      local _, targetClass = UnitClass(unit .. "target")
      local targetReaction = UnitReaction("player",unit .. "target")
      local _, class = UnitClass(unit)
      local guild, rankstr, rankid = GetGuildInfo(unit)
      local reaction = UnitReaction(unit, "player")
      local pvptitle = gsub(pvpname or name," "..name, "", 1)
      local hp = UnitHealth(unit)
      local hpm = UnitHealthMax(unit)

      if name then
        if UnitIsPlayer(unit) and class then
          local color = RAID_CLASS_COLORS[class]
          GameTooltipStatusBar:SetStatusBarColor_orig(color.r, color.g, color.b)
          GameTooltip:SetBackdropBorderColor(color.r, color.g, color.b)
          if color.colorStr then
            GameTooltipTextLeft1:SetText("|c" .. color.colorStr .. name)
          end
        elseif reaction then
          local color = UnitReactionColor[reaction]
          GameTooltipStatusBar:SetStatusBarColor_orig(color.r, color.g, color.b)
          GameTooltip:SetBackdropBorderColor(color.r, color.g, color.b)
        end
        if pvptitle ~= name then
          GameTooltip:AppendText(" |cff666666["..pvptitle.."]|r")
        end
      end

      if guild then
        local rank = ""
        local lead = ""
        if C.tooltip.extguild == "1" then
          if rankstr then rank = " |cffaaaaaa(" .. rankstr .. ")"  end
          if rankid and rankid == 0 then lead = "|cffffcc00*|r" end
        end

        GameTooltip:AddLine("<" .. guild .. ">" .. lead .. rank, 0.3, 1, 0.5)
      end

      if target then
        if UnitIsPlayer(unit .. "target") and targetClass then
          local color = RAID_CLASS_COLORS[targetClass]
          GameTooltip:AddLine(target, color.r, color.g, color.b)
        elseif targetReaction then
          local color = UnitReactionColor[targetReaction]
          GameTooltip:AddLine(target, color.r, color.g, color.b)
        end
      end

      if pfUI.tooltipStatusBar.HP == nil then
        pfUI.tooltipStatusBar.HP = GameTooltipStatusBar:CreateFontString("Status", "DIALOG", "GameFontNormal")
        pfUI.tooltipStatusBar.HP:SetPoint("TOP", 0,8)
        pfUI.tooltipStatusBar.HP:SetNonSpaceWrap(false)
        pfUI.tooltipStatusBar.HP:SetFontObject(GameFontWhite)
        pfUI.tooltipStatusBar.HP:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
      end

      if hp and hpm then
        if hp >= 1000 then hp = round(hp / 1000, 1) .. "k" end
        if hpm >= 1000 then hpm = round(hpm / 1000, 1) .. "k" end
        pfUI.tooltipStatusBar.HP:SetText(hp .. " / " .. hpm)
      end
      GameTooltip:Show()
    end
end)
