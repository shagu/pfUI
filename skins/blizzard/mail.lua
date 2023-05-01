pfUI:RegisterSkin("Mailbox", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  -- Compatibility
  local StationeryBackgroundLeft, StationeryBackgroundRight
  if ATTACHMENTS_MAX_SEND then -- tbc
    do -- SendMailFrame
      for i = 1, ATTACHMENTS_MAX_SEND do
        local btn = _G["SendMailAttachment"..i]
        StripTextures(btn)
        SkinButton(btn, nil, nil, nil, nil, true)
      end

      hooksecurefunc("SendMailFrame_Update", function()
        for i = 1, ATTACHMENTS_MAX_SEND do
          local btn = _G["SendMailAttachment"..i]
          HandleIcon(btn, btn:GetNormalTexture())

          local link = GetSendMailItemLink(i)
          if link then
            local r,g,b = GetItemQualityColor(select(3, GetItemInfo(link)))
            btn:SetBackdropBorderColor(r,g,b,1)
            else
            btn:SetBackdropBorderColor(GetStringColor(pfUI_config.appearance.border.color))
          end
        end
      end)

      StationeryBackgroundLeft, StationeryBackgroundRight = SendStationeryBackgroundLeft, SendStationeryBackgroundRight
    end

    do -- OpenMailFrame
      for i = 1, ATTACHMENTS_MAX_RECEIVE do
        SkinButton(_G["OpenMailAttachmentButton"..i], nil, nil, nil, _G["OpenMailAttachmentButton"..i.."IconTexture"], true)
      end

      hooksecurefunc("InboxFrame_OnClick", function(index)
        for i=1, ATTACHMENTS_MAX_RECEIVE do
          local link = GetInboxItemLink(index, i)
          if not link then return end
          local r,g,b = GetItemQualityColor(select(3, GetItemInfo(link)))
          _G["OpenMailAttachmentButton"..i]:SetBackdropBorderColor(r,g,b,1)
        end
      end)

      SkinButton(OpenMailReportSpamButton)
    end
  else -- vanilla
    do -- SendMailFrame
      local skin = CreateFrame("Frame")
      skin:SetScript("OnEvent", function()
        this:UnregisterEvent("MAIL_SHOW")
        if not this._Mail then
          StripTextures(SendMailPackageButton)
          SkinButton(SendMailPackageButton, nil, nil, nil, nil, true)

          hooksecurefunc("SendMailFrame_Update", function()
            HandleIcon(SendMailPackageButton, SendMailPackageButton:GetNormalTexture())

            local link = GetItemLinkByName(GetSendMailItem())
            if link then
              local _,_,linkstr = string.find(link, "(item:%d+:%d+:%d+:%d+)")
              local _,_,quality = GetItemInfo(linkstr)
              local r,g,b = GetItemQualityColor(quality)
              SendMailPackageButton:SetBackdropBorderColor(r,g,b,1)
              else
              SendMailPackageButton:SetBackdropBorderColor(GetStringColor(pfUI_config.appearance.border.color))
            end
          end, 1)
        end
      end)
      skin:RegisterEvent("MAIL_SHOW")

      HookAddonOrVariable("Mail", function()
        skin._Mail = true
        for i = 1, 21 do
          local button = _G["MailAttachment"..i]
          StripTextures(button)

          SkinButton(button, nil, nil, nil, nil, true)
          local orig = button.SetNormalTexture
          button.SetNormalTexture = function(self, tex)
            orig(self, tex)

            if button.item then
              HandleIcon(self, self:GetNormalTexture())

              local link = GetContainerItemLink(button.item[1], button.item[2])
              local _,_,linkstr = string.find(link, "(item:%d+:%d+:%d+:%d+)")
              local _,_,quality = GetItemInfo(linkstr)
              local r,g,b = GetItemQualityColor(quality)
              self:SetBackdropBorderColor(r,g,b,1)
            else
              self:SetBackdropBorderColor(GetStringColor(pfUI_config.appearance.border.color))
            end
          end
        end
        SkinButton(GetNoNameObject(InboxFrame, "Button", nil, "UI-Panel-Button-Up", OPENMAIL))
        local button = GetNoNameObject(SendMailFrame, "Button", nil, "UI-Panel-Button-Up", SEND_LABEL) -- this is SendMailMailButton
        SkinButton(button) -- hack! only it happened to do it
        button:ClearAllPoints()
        button:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -2*bpad, 0)
      end)

      StationeryBackgroundLeft, StationeryBackgroundRight = _G.StationeryBackgroundLeft, _G.StationeryBackgroundRight
    end

    do -- OpenMailFrame
      SkinButton(OpenMailPackageButton, nil, nil, nil, OpenMailPackageButtonIconTexture)

      hooksecurefunc("InboxFrame_OnClick", function(index)
        local name = GetInboxItem(index)
        local link = name and GetItemLinkByName(name)
        if link then
          local _,_,linkstr = string.find(link, "(item:%d+:%d+:%d+:%d+)")
          local _,_,quality = GetItemInfo(linkstr)
          local r,g,b = GetItemQualityColor(quality)
          OpenMailPackageButton:SetBackdropBorderColor(r,g,b,1)
        else
          OpenMailPackageButton:SetBackdropBorderColor(GetStringColor(pfUI_config.appearance.border.color))
        end
      end)
    end
  end

  StripTextures(MailFrame, true)
  CreateBackdrop(MailFrame, nil, nil, .75)
  CreateBackdropShadow(MailFrame)

  MailFrame.backdrop:SetPoint("TOPLEFT", 12, -12)
  MailFrame.backdrop:SetPoint("BOTTOMRIGHT", -30, 72)
  MailFrame:SetHitRectInsets(12,30,12,72)
  EnableMovable(MailFrame)

  SkinCloseButton(InboxCloseButton, MailFrame.backdrop, -6, -6)

  SkinTab(MailFrameTab1)
  MailFrameTab1:ClearAllPoints()
  MailFrameTab1:SetPoint("TOPLEFT", MailFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
  SkinTab(MailFrameTab2)
  MailFrameTab2:ClearAllPoints()
  MailFrameTab2:SetPoint("LEFT", MailFrameTab1, "RIGHT", border*2 + 1, 0)

  do -- InboxFrame
    InboxTitleText:ClearAllPoints()
    InboxTitleText:SetPoint("TOP", MailFrame.backdrop, "TOP", 0, -10)

    CreateBackdrop(InboxFrame, nil, nil, .75)
    InboxFrame.backdrop:SetPoint("TOPLEFT", _G["MailItem"..1], "TOPLEFT", 0, 1)
    InboxFrame.backdrop:SetPoint("BOTTOMRIGHT", _G["MailItem"..INBOXITEMS_TO_DISPLAY], "BOTTOMRIGHT", 0, 0)
    _G["MailItem"..1]:SetPoint("TOPLEFT", 28, -70)

    for i = 1, INBOXITEMS_TO_DISPLAY do
      StripTextures(_G["MailItem"..i])
      StripTextures(_G["MailItem"..i.."Button"])
      SkinButton(_G["MailItem"..i.."Button"], nil, nil, nil, _G["MailItem"..i.."ButtonIcon"])
    end

    InboxPrevPageButton:ClearAllPoints()
    InboxPrevPageButton:SetPoint("TOPLEFT", InboxFrame.backdrop, "BOTTOMLEFT", 0, -10)

    InboxNextPageButton:ClearAllPoints()
    InboxNextPageButton:SetPoint("TOPRIGHT", InboxFrame.backdrop, "BOTTOMRIGHT", 0, -10)

    SkinArrowButton(InboxPrevPageButton, "left", 16)
    SkinArrowButton(InboxNextPageButton, "right", 16)

    InboxPrevPageButton:GetRegions():SetPoint("LEFT", InboxPrevPageButton, "RIGHT", 5, 0)
    InboxNextPageButton:GetRegions():SetPoint("RIGHT", InboxNextPageButton, "LEFT", -5, 0)
  end

  do -- SendMailFrame
    SendMailTitleText:ClearAllPoints()
    SendMailTitleText:SetPoint("TOP", MailFrame.backdrop, "TOP", 0, -10)

    StripTextures(SendMailNameEditBox, nil, "BACKGROUND")
    CreateBackdrop(SendMailNameEditBox, nil, true)
    StripTextures(SendMailSubjectEditBox, nil, "BACKGROUND")
    CreateBackdrop(SendMailSubjectEditBox, nil, true)

    SkinButton(SendMailCancelButton)
    SkinButton(SendMailMailButton)
    SendMailMailButton:ClearAllPoints()
    SendMailMailButton:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -2*bpad, 0)

    StripTextures(SendMailFrame)
    StripTextures(SendMailScrollFrame)
    CreateBackdrop(SendMailScrollFrame, nil, true)
    SkinScrollbar(SendMailScrollFrameScrollBar)

    SkinMoneyInputFrame(SendMailMoney)

    StationeryBackgroundLeft:SetDrawLayer("BORDER")
    StationeryBackgroundLeft:SetAllPoints()
    StationeryBackgroundRight:Hide()
  end

  do -- OpenMailFrame
    StripTextures(OpenMailFrame)
    CreateBackdrop(OpenMailFrame, nil, nil, .75)
    OpenMailFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
    OpenMailFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
    OpenMailFrame:SetHitRectInsets(10,32,10,72)

    SkinCloseButton(OpenMailCloseButton, OpenMailFrame.backdrop, -6, -6)

    OpenMailFrame:DisableDrawLayer("BACKGROUND")

    OpenMailTitleText:ClearAllPoints()
    OpenMailTitleText:SetPoint("TOP", OpenMailFrame.backdrop, "TOP", 0, -10)

    SkinButton(OpenMailCancelButton)
    SkinButton(OpenMailDeleteButton)
    OpenMailDeleteButton:ClearAllPoints()
    OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -2*bpad, 0)
    SkinButton(OpenMailReplyButton)
    OpenMailReplyButton:ClearAllPoints()
    OpenMailReplyButton:SetPoint("RIGHT", OpenMailDeleteButton, "LEFT", -2*bpad, 0)

    SkinButton(OpenMailMoneyButton, nil, nil, nil, OpenMailMoneyButtonIconTexture)
    SkinButton(OpenMailLetterButton, nil, nil, nil, OpenMailLetterButtonIconTexture)

    StripTextures(OpenMailScrollFrame)
    CreateBackdrop(OpenMailScrollFrame, nil, true)
    SkinScrollbar(OpenMailScrollFrameScrollBar)

    OpenStationeryBackgroundLeft:SetDrawLayer("BORDER")
    OpenStationeryBackgroundLeft:SetTexCoord(.1,1,.1,.9)
    OpenStationeryBackgroundLeft:SetAllPoints()
    OpenStationeryBackgroundRight:Hide()
  end
end)
