pfUI:RegisterModule("tooltip", function ()
  GameTooltip:SetBackdrop(pfUI.backdrop)

  if pfUI_config.tooltip.position == "cursor" then
    function GameTooltip_SetDefaultAnchor(tooltip, parent)		
      tooltip:SetOwner(parent, "ANCHOR_CURSOR");
    end
  end

  pfUI.tooltip = CreateFrame('Frame', nil, GameTooltip) 
  pfUI.tooltip:SetAllPoints()
  pfUI.tooltip:SetScript("OnShow", function()
      if GameTooltip:GetAnchorType() == "ANCHOR_NONE" then
        GameTooltip:ClearAllPoints();
        if pfUI_config.tooltip.position == "bottom" then
          GameTooltip:SetPoint("BOTTOMRIGHT",pfUI.panel.right,"TOPRIGHT",0,0)
        elseif pfUI_config.tooltip.position == "chat" then
          GameTooltip:SetPoint("BOTTOMRIGHT",pfUI.chat.right,"TOPRIGHT",0,0)
        end
      end
    end)

  pfUI.tooltipStatusBar = CreateFrame('Frame', nil, GameTooltipStatusBar) 
  pfUI.tooltipStatusBar:SetScript("OnUpdate", function()
      if(not UnitExists('mouseover')) then 

        return 
      end
      local _, class = UnitClass("mouseover")
      local reaction = UnitReaction("mouseover", "player")

      local hp = UnitHealth("mouseover")
      local hpm = UnitHealthMax("mouseover")

      if pfUI.tooltipStatusBar.HP == nil then
        pfUI.tooltipStatusBar.HP = GameTooltipStatusBar:CreateFontString("Status", "DIALOG", "GameFontNormal")
        pfUI.tooltipStatusBar.HP:SetPoint("TOP", 0,8)
        pfUI.tooltipStatusBar.HP:SetNonSpaceWrap(false)
        pfUI.tooltipStatusBar.HP:SetFontObject(GameFontWhite)
        pfUI.tooltipStatusBar.HP:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 12, "OUTLINE")
      end

      if hp and hpm then
        if hp >= 1000 then hp = round(hp / 1000, 1) .. "k" end
        if hpm >= 1000 then hpm = round(hpm / 1000, 1) .. "k" end
        pfUI.tooltipStatusBar.HP:SetText(hp .. " / " .. hpm)
      end

      if class and reaction then
        if UnitIsPlayer("mouseover") then
          local color = RAID_CLASS_COLORS[class]
          GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
        else
          local color = UnitReactionColor[reaction]
          GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
        end
      end
    end)

  pfUI.tooltipEvent = CreateFrame("Frame")
  pfUI.tooltipEvent:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
  pfUI.tooltipEvent:SetScript("OnEvent", function()
      local pvpname = UnitPVPName("mouseover")
      local name = UnitName("mouseover")
      local target = UnitName("mouseovertarget")
      local _, targetClass = UnitClass("mouseovertarget")
      local targetReaction = UnitReaction("player","mouseovertarget")
      local _, class = UnitClass("mouseover")
      local guild = GetGuildInfo("mouseover")
      local reaction = UnitReaction("player", "mouseover")
      local pvptitle = gsub(pvpname," "..name, "", 1)

      if name and reaction then
        if UnitIsPlayer("mouseover") and class then
          local color = RAID_CLASS_COLORS[class]
          GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
          GameTooltip:SetBackdropBorderColor(color.r, color.g, color.b)
          GameTooltipTextLeft1:SetText("|c" .. color.colorStr .. name)
        else
          local color = UnitReactionColor[reaction]
          GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
          GameTooltip:SetBackdropBorderColor(color.r, color.g, color.b)
        end

        if pvptitle ~= name then
          GameTooltip:AppendText(" |cff666666["..pvptitle.."]|r")
        end
      end

      if guild then
        GameTooltip:AddLine("<" .. guild .. ">", 0.3, 1, 0.5)
      end

      if target and ( targetClass or targetReaction ) then
        if UnitIsPlayer("mouseovertarget") then
          local color = RAID_CLASS_COLORS[targetClass]
          GameTooltip:AddLine(target, color.r, color.g, color.b)
        elseif targetReaction ~= nil then
          local color = UnitReactionColor[targetReaction]
          GameTooltip:AddLine(target, color.r, color.g, color.b)
        end
      end

      GameTooltip:Show()
    end)

  GameTooltipStatusBar:SetHeight(6)
  GameTooltipStatusBar:ClearAllPoints()
  GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 1, 2)
  GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -1, 2)
  GameTooltipStatusBar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  GameTooltipStatusBar:SetBackdrop( { bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
                                    insets = {left = -1, right = -1, top = -1, bottom = -1} })
  GameTooltipStatusBar:SetBackdropColor(0, 0, 0, 1)

end)
