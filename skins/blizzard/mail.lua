pfUI:RegisterSkin("Mailbox", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  StripTextures(MailFrame, true)
  CreateBackdrop(MailFrame, nil, nil, .75)
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

    SkinArrowButton(InboxPrevPageButton, "left", 18)
    SkinArrowButton(InboxNextPageButton, "right", 18)
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
    SendMailBodyEditBox:SetMaxLetters(2000)

    SkinMoneyInputFrame(SendMailMoney)

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
    SkinButton(OpenMailPackageButton, nil, nil, nil, OpenMailPackageButtonIconTexture)
    SkinButton(OpenMailLetterButton, nil, nil, nil, OpenMailLetterButtonIconTexture)

    StripTextures(OpenMailScrollFrame)
    CreateBackdrop(OpenMailScrollFrame, nil, true)
    SkinScrollbar(OpenMailScrollFrameScrollBar)

    OpenStationeryBackgroundLeft:SetTexCoord(.1,1,.1,.9)
    OpenStationeryBackgroundLeft:SetAllPoints()
    OpenStationeryBackgroundRight:Hide()
  end

  -- support for addon 'Mail'
  if IsAddOnLoaded("Mail") then
    for i = 1, 21 do
      local button = _G["MailAttachment"..i]
      StripTextures(button)
      SkinButton(button)

      button.icon = button:CreateTexture(button:GetName().."Icon", "ARTWORK")
      HandleIcon(button, button.icon)
      button.SetNormalTexture = function(self, tex)
        button.icon:SetTexture(tex)
      end
    end
    SkinButton(GetNoNameObject(InboxFrame, "Button", nil, "UI--Panel--Button--Up", OPENMAIL))
    local button = GetNoNameObject(SendMailFrame, "Button", nil, "UI--Panel--Button--Up", SEND_LABEL) -- this is SendMailMailButton
    SkinButton(button) -- hack! only it happened to do it
    button:ClearAllPoints()
    button:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -2*bpad, 0)

  else
    StripTextures(SendMailPackageButton)
    SkinButton(SendMailPackageButton)
    hooksecurefunc("SendMailFrame_Update", function()
      HandleIcon(SendMailPackageButton, SendMailPackageButton:GetNormalTexture())
    end, 1)
  end
end)
