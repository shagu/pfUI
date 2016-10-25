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
    b:SetBackdrop(pfUI.backdrop)
    b:SetNormalTexture(nil)
    b:SetHighlightTexture(nil)
    b:SetPushedTexture(nil)
    b:SetDisabledTexture(nil)
    b:SetScript("OnEnter", function()
        b:SetBackdrop(pfUI.backdrop_col)
        b:SetBackdropBorderColor(cr,cg,cb,1)
      end)
    b:SetScript("OnLeave", function()
        b:SetBackdrop(pfUI.backdrop)
        b:SetBackdropBorderColor(1,1,1,1)
      end)
    b:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  end

  for _, box in pairs(boxes) do
    local b = getglobal(box)
    b:SetBackdrop(pfUI.backdrop)
    b:SetBackdropColor(0,0,0,.5)
  end

  for i,v in ipairs({GameMenuFrame:GetRegions()}) do
    if v.SetTextColor then
      v:SetTextColor(1,1,1,1)
      v:SetPoint("TOP", GameMenuFrame, "TOP", 0, 16)
      v:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
    end
  end

  ShoppingTooltip1:SetBackdrop(pfUI.backdrop)
  ShoppingTooltip2:SetBackdrop(pfUI.backdrop)
end)
