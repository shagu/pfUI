pfUI:RegisterModule("skin", function ()

  -- durability frame
  pfUI.durability = CreateFrame("Frame","pfDurability",UIParent)
  if pfUI.minimap then
    pfUI.durability:SetPoint("TOPLEFT", pfUI.minimap, "BOTTOMLEFT", 0, -35)
  else
    pfUI.durability:SetPoint("LEFT", UIParent, "RIGHT", -120, 120)
  end
  UpdateMovable(pfUI.durability)
  pfUI.durability:SetWidth(80)
  pfUI.durability:SetHeight(70)
  pfUI.durability:SetFrameStrata("BACKGROUND")
  DurabilityFrame:SetParent(pfUI.durability)
  DurabilityFrame:SetAllPoints(pfUI.durability)
  DurabilityFrame:SetFrameLevel(1)
  DurabilityFrame.SetPoint = function() return end

  if C.appearance.cd.blizzard == "1" then
    hooksecurefunc("PaperDollItemSlotButton_Update", function()
        local cooldown = getglobal(this:GetName().."Cooldown")
        if cooldown then cooldown.pfCooldownType = "ALL" end
    end)

    hooksecurefunc("SpellButton_UpdateButton", function()
      local cooldown = getglobal(this:GetName().."Cooldown")
      if cooldown then cooldown.pfCooldownType = "ALL" end
    end)
  end

  _, class = UnitClass("player")
  local color = RAID_CLASS_COLORS[class]
  local cr, cg, cb = color.r , color.g, color.b

  local boxes = {
    "DropDownList1MenuBackdrop",
    "DropDownList2MenuBackdrop",
    "DropDownList1Backdrop",
    "DropDownList2Backdrop",
  }

  local pfUIButton = CreateFrame("Button", "GameMenuButtonPFUI", GameMenuFrame, "GameMenuButtonTemplate")
  pfUIButton:SetPoint("TOP", 0, -10)
  pfUIButton:SetText(T["|cff33ffccpf|cffffffffUI|cffcccccc Config"])
  pfUIButton:SetScript("OnClick", function()
    pfUI.gui:Show()
    HideUIPanel(GameMenuFrame)
  end)
  SkinButton(pfUIButton)

  local point, relativeTo, relativePoint, xOffset, yOffset = GameMenuButtonOptions:GetPoint()
  GameMenuButtonOptions:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset - 22)

  for _, box in pairs(boxes) do
    local b = getglobal(box)
    CreateBackdrop(b, nil, true, .8)
  end

  local alpha = tonumber(C.tooltip.alpha)

  -- skin worldmap tooltips
  WorldMapTooltip:SetScript("OnShow", function()
    CreateBackdrop(WorldMapTooltip, nil, nil, alpha)
  end)

  -- skin item tooltips
  CreateBackdrop(ShoppingTooltip1, nil, nil, alpha)
  CreateBackdrop(ShoppingTooltip2, nil, nil, alpha)
  CreateBackdrop(ItemRefTooltip, nil, nil, alpha)

  ShoppingTooltip1:SetClampedToScreen(true)
  ShoppingTooltip1:SetScript("OnShow", function()
    local a, b, c, d, e = this:GetPoint()
    local border = tonumber(C.appearance.border.default)
    if not d or d == 0 then d = (border*2) + ( d or 0 ) + 1 end
    if a then this:SetPoint(a, b, c, d, e) end
  end)

  ShoppingTooltip2:SetClampedToScreen(true)
  ShoppingTooltip2:SetScript("OnShow", function()
    local a, b, c, d, e = this:GetPoint()
    local border = tonumber(C.appearance.border.default)
    if not d or d == 0 then d = (border*2) + ( d or 0 ) + 1 end
    if a then this:SetPoint(a, b, c, d, e) end
  end)

  CreateBackdrop(TicketStatusFrame)
  TicketStatusFrame:ClearAllPoints()
  TicketStatusFrame:SetPoint("TOP", 0, -5)
  UpdateMovable(TicketStatusFrame)
  function TicketStatusFrame_OnEvent()
    if ( event == "PLAYER_ENTERING_WORLD" ) then
      GetGMTicket()
    else
      if ( arg1 ~= 0 ) then
        this:Show()
        refreshTime = GMTICKET_CHECK_INTERVAL
      else
        this:Hide()
      end
    end
  end

  UI_OPTIONS_FRAME:SetScript("OnShow", function()
    -- default events
    UIOptionsFrame_Load();
    MultiActionBar_Update();
    MultiActionBar_ShowAllGrids();
    Disable_BagButtons();
    UpdateMicroButtons();

    -- customize
    UIOptionsBlackground:Hide()

    UI_OPTIONS_FRAME:SetMovable(true)
    UI_OPTIONS_FRAME:EnableMouse(true)
    UI_OPTIONS_FRAME:SetScale(.8)
    UI_OPTIONS_FRAME:SetScript("OnMouseDown",function()
      UI_OPTIONS_FRAME:StartMoving()
    end)

    UI_OPTIONS_FRAME:SetScript("OnMouseUp",function()
      UI_OPTIONS_FRAME:StopMovingOrSizing()
    end)
  end)

  if C.global.errors_limit == "1" then
    UIErrorsFrame:SetHeight(25)
  end

  if C.global.errors_hide == "1" then
    UIErrorsFrame:Hide()
  end
end)
