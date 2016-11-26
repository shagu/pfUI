pfUI:RegisterModule("skin", function ()
  GameMenuFrameHeader:SetTexture(nil)
  GameMenuFrame:SetHeight(GameMenuFrame:GetHeight()-20)
  GameMenuFrame:SetWidth(GameMenuFrame:GetWidth()-30)

  _, class = UnitClass("player")
  local color = RAID_CLASS_COLORS[class]
  local cr, cg, cb = color.r , color.g, color.b

  local buttons = {
    "GameMenuButtonPFUI",
    "GameMenuButtonOptions",
    "GameMenuButtonSoundOptions",
    "GameMenuButtonUIOptions",
    "GameMenuButtonKeybindings",
    "GameMenuButtonMacros",
    "GameMenuButtonLogout",
    "GameMenuButtonQuit",
    "GameMenuButtonContinue",
    "StaticPopup1Button1",
    "StaticPopup1Button2",
    "StaticPopup2Button1",
    "StaticPopup2Button2",
    "pfReloadYes",
    "pfReloadNo",
  }
  local boxes = {
    "StaticPopup1",
    "StaticPopup2",
    "GameMenuFrame",
    "DropDownList1MenuBackdrop",
    "DropDownList2MenuBackdrop",
    "DropDownList1Backdrop",
    "DropDownList2Backdrop",
  }

  local pfUIButton = CreateFrame("Button", "GameMenuButtonPFUI", GameMenuFrame, "GameMenuButtonTemplate")
  pfUIButton:SetPoint("TOP", 0, -10)
  pfUIButton:SetText("\"pfUI\" Settings")
  pfUIButton:SetScript("OnClick", function()
    pfUI.gui:Show()
    HideUIPanel(GameMenuFrame)
  end)
  GameMenuButtonOptions:SetPoint("TOP", 0, -35)
  GameMenuButtonContinue:ClearAllPoints()
  GameMenuButtonContinue:SetPoint("BOTTOM", 0, 10)

  for _, button in pairs(buttons) do
    local b = getglobal(button)
    pfUI.utils:CreateBackdrop(b, nil, true)
    b:SetNormalTexture(nil)
    b:SetHighlightTexture(nil)
    b:SetPushedTexture(nil)
    b:SetDisabledTexture(nil)
    b:SetScript("OnEnter", function()
      pfUI.utils:CreateBackdrop(b, nil, true)
      b:SetBackdropBorderColor(cr,cg,cb,1)
    end)
    b:SetScript("OnLeave", function()
      pfUI.utils:CreateBackdrop(b, nil, true)
    end)
    b:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  end

  for _, box in pairs(boxes) do
    local b = getglobal(box)
    pfUI.utils:CreateBackdrop(b, nil, true, true)
  end

  for i,v in ipairs({GameMenuFrame:GetRegions()}) do
    if v.SetTextColor then
      v:SetTextColor(1,1,1,1)
      v:SetPoint("TOP", GameMenuFrame, "TOP", 0, 16)
      v:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size + 2, "OUTLINE")
    end
  end

pfUI.utils:CreateBackdrop(ShoppingTooltip1)
pfUI.utils:CreateBackdrop(ShoppingTooltip2)

pfUI.utils:CreateBackdrop(TicketStatusFrame)
  TicketStatusFrame:ClearAllPoints()
  TicketStatusFrame:SetPoint("TOP", 0, -5)
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

  -- due to the fontsize, the auctionhouse dropdown menu is misplaced.
  -- This hackfix rearranges it, by setting the width of it, as soon as
  -- the auctionhouse window is ready to get hooked.
  local pfAuctionHouseFix = CreateFrame("Frame", nil)
  pfAuctionHouseFix:RegisterEvent("ADDON_LOADED")
  pfAuctionHouseFix:SetScript("OnEvent", function ()
    if not pfAuctionFrame_OnShow and AuctionFrame_OnShow then
      pfAuctionFrame_OnShow = AuctionFrame_OnShow
      function AuctionFrame_OnShow ()
        pfAuctionFrame_OnShow()
        BrowseLevelText:SetWidth(70)
      end
      pfAuctionHouseFix:UnregisterAllEvents()
    end
  end)

end)
