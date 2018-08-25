pfUI:RegisterSkin("Friends", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  StripTextures(FriendsFrame, true)
  CreateBackdrop(FriendsFrame, nil, nil, .75)
  FriendsFrame.backdrop:SetPoint("TOPLEFT", 10, -12)
  FriendsFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 76)

  SkinCloseButton(FriendsFrameCloseButton, CharacterFrame, -37, -17)
  FriendsFrameCloseButton:SetParent(FriendsFrame)
  FriendsFrameCloseButton:ClearAllPoints()
  FriendsFrameCloseButton:SetPoint("TOPRIGHT", FriendsFrame.backdrop, "TOPRIGHT", -4, -4)

  for i = 1, 2 do
    for _, name in pairs({"FriendsFrameToggleTab", "IgnoreFrameToggleTab"}) do
      local tab = _G[name..i]
      StripTextures(tab, true)
      CreateBackdrop(tab)
      tab:SetWidth(75)
      tab:SetHeight(25)
      tab:ClearAllPoints()
      tab:SetPoint("TOPLEFT", FriendsFrame, "TOPLEFT", (i-1)*(75 + 2*bpad + 1)+21, -48 + border)
    end
  end

  FriendsFrameTab1:ClearAllPoints()
  FriendsFrameTab1:SetPoint("TOPLEFT", FriendsFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
  for i = 1, 4 do
    local tab = _G["FriendsFrameTab"..i]
    local lastTab = _G["FriendsFrameTab"..(i-1)]
    if lastTab then
      tab:ClearAllPoints()
      tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
    end
    SkinTab(tab)
  end

  do -- friends
    StripTextures(FriendsFrameFriendsScrollFrame)
    CreateBackdrop(FriendsFrameFriendsScrollFrame)
    SkinScrollbar(FriendsFrameFriendsScrollFrameScrollBar, FriendsFrameFriendsScrollFrame)

    SkinButton(FriendsFrameAddFriendButton)
    FriendsFrameAddFriendButton:ClearAllPoints()
    FriendsFrameAddFriendButton:SetPoint("TOPLEFT", FriendsFrameFriendsScrollFrame, "BOTTOMLEFT", -bpad, -5)
    FriendsFrameAddFriendButton:SetWidth(158)

    SkinButton(FriendsFrameRemoveFriendButton)
    FriendsFrameRemoveFriendButton:ClearAllPoints()
    FriendsFrameRemoveFriendButton:SetPoint("TOPLEFT", FriendsFrameAddFriendButton, "BOTTOMLEFT", 0, -4)
    FriendsFrameRemoveFriendButton:SetWidth(158)

    SkinButton(FriendsFrameSendMessageButton)
    FriendsFrameSendMessageButton:ClearAllPoints()
    FriendsFrameSendMessageButton:SetPoint("TOPRIGHT", FriendsFrameFriendsScrollFrameScrollBarScrollDownButton, "BOTTOMRIGHT", bpad, -5)
    FriendsFrameSendMessageButton:SetWidth(158)

    SkinButton(FriendsFrameGroupInviteButton)
    FriendsFrameGroupInviteButton:ClearAllPoints()
    FriendsFrameGroupInviteButton:SetPoint("TOPLEFT", FriendsFrameSendMessageButton, "BOTTOMLEFT", 0, -4)
    FriendsFrameGroupInviteButton:SetWidth(158)

    for i = 1, 10 do
      local frame = _G["FriendsFrameFriendButton"..i]
      if frame then
        local tex = frame:GetHighlightTexture()
        tex:SetTexture(1,1,1,.1)
        tex:ClearAllPoints()
        tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 2)
        frame:SetHeight(30)
      end
    end
  end

  do -- ignore
    StripTextures(FriendsFrameIgnoreScrollFrame)
    CreateBackdrop(FriendsFrameIgnoreScrollFrame)
    SkinScrollbar(FriendsFrameIgnoreScrollFrameScrollBar, FriendsFrameIgnoreScrollFrame)

    for i = 1, 20 do
      local frame = _G["FriendsFrameIgnoreButton"..i]
      if frame then
        local tex = frame:GetHighlightTexture()
        tex:SetTexture(1,1,1,.1)
        tex:ClearAllPoints()
        tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
        tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, -1)
      end
    end

    SkinButton(FriendsFrameIgnorePlayerButton)
    FriendsFrameIgnorePlayerButton:ClearAllPoints()
    FriendsFrameIgnorePlayerButton:SetPoint("TOPLEFT", FriendsFrameIgnoreScrollFrame, "BOTTOMLEFT", -bpad, -4)
    FriendsFrameIgnorePlayerButton:SetWidth(158)

    SkinButton(FriendsFrameStopIgnoreButton)
    FriendsFrameStopIgnoreButton:ClearAllPoints()
    FriendsFrameStopIgnoreButton:SetPoint("TOPRIGHT", FriendsFrameIgnoreScrollFrameScrollBarScrollDownButton, "BOTTOMRIGHT", bpad, -4)
    FriendsFrameStopIgnoreButton:SetWidth(158)
  end

  do -- who
    WhoListScrollFrame:SetPoint("TOPLEFT", 25, -70)
    WhoFrameButton1:SetPoint("TOPLEFT", WhoListScrollFrame, "TOPLEFT", -5, -5)

    StripTextures(WhoListScrollFrame)
    CreateBackdrop(WhoListScrollFrame)
    SkinScrollbar(WhoListScrollFrameScrollBar, WhoListScrollFrame)

    WhoFrameColumnHeader3:ClearAllPoints()
    WhoFrameColumnHeader3:SetPoint("BOTTOMLEFT", WhoListScrollFrame, "TOPLEFT", 5, 4)

    WhoFrameColumnHeader4:ClearAllPoints()
    WhoFrameColumnHeader4:SetPoint("LEFT", WhoFrameColumnHeader3, "RIGHT", -2, -0)
    WhoFrameColumnHeader4:SetWidth(68)

    WhoFrameColumnHeader1:ClearAllPoints()
    WhoFrameColumnHeader1:SetPoint("LEFT", WhoFrameColumnHeader4, "RIGHT", -5, -0)
    WhoFrameColumnHeader1:SetWidth(85)

    WhoFrameColumnHeader2:ClearAllPoints()
    WhoFrameColumnHeader2:SetPoint("LEFT", WhoFrameColumnHeader1, "RIGHT", -5, -0)

    for i = 1, 4 do
      StripTextures(_G["WhoFrameColumnHeader"..i])
    end

    SkinDropDown(WhoFrameDropDown)
    WhoFrameDropDown.backdrop:SetPoint("BOTTOMRIGHT", WhoListScrollFrame.backdrop, "TOPRIGHT", 0, 3)
    WhoFrameDropDownButton:ClearAllPoints()
    WhoFrameDropDownButton:SetPoint("RIGHT", WhoFrameDropDown.backdrop, "RIGHT", 0, 0)
    UIDropDownMenu_SetWidth(95, WhoFrameDropDown)
    WhoFrameDropDownButton.SetPoint = function() return end
    WhoFrameDropDown.SetWidth = function() return end
    WhoFrameDropDownMiddle.SetWidth = function() return end
    WhoFrameDropDownText.SetWidth = function() return end
    WhoFrameDropDownHighlightTexture:SetTexture(nil)

    for i = 1, 17 do
      local button = _G["WhoFrameButton"..i]
      local level = _G["WhoFrameButton"..i.."Level"]
      local name = _G["WhoFrameButton"..i.."Name"]

      if button then
        local tex = button:GetHighlightTexture()
        tex:SetTexture(1,1,1,.1)
        tex:ClearAllPoints()
        tex:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -2)
        tex:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, -1)
      end

      level:ClearAllPoints()
      level:SetPoint("TOPLEFT", 12, -2)

      name:SetWidth(80)
      name:SetHeight(14)
      name:ClearAllPoints()
      name:SetPoint("LEFT", 105, 0)
    end

    StripTextures(WhoListScrollFrame)
    SkinScrollbar(WhoListScrollFrameScrollBar)

    CreateBackdrop(WhoFrameEditBox)
    WhoFrameEditBox:SetTextInsets(5,5,5,5)
    WhoFrameEditBox:ClearAllPoints()
    WhoFrameEditBox:SetPoint("TOPLEFT",  WhoListScrollFrame, "BOTTOMLEFT", 0, -5)
    WhoFrameEditBox:SetPoint("TOPRIGHT",  WhoListScrollFrameScrollBarScrollDownButton, "BOTTOMRIGHT", 0, -5)
    WhoFrameEditBox:SetHeight(20)

    WhoFrameTotals:ClearAllPoints()
    WhoFrameTotals:SetPoint("TOP", WhoListScrollFrame, "BOTTOM", 0, -57)

    SkinButton(WhoFrameWhoButton)
    WhoFrameWhoButton:ClearAllPoints()
    WhoFrameWhoButton:SetPoint("TOPLEFT", WhoFrameEditBox, "BOTTOMLEFT", -bpad, -5)

    SkinButton(WhoFrameAddFriendButton)
    WhoFrameAddFriendButton:SetPoint("LEFT", WhoFrameWhoButton, "RIGHT", 3, 0)
    WhoFrameAddFriendButton:SetPoint("RIGHT", WhoFrameGroupInviteButton, "LEFT", -3, 0)

    SkinButton(WhoFrameGroupInviteButton)
    WhoFrameGroupInviteButton:ClearAllPoints()
    WhoFrameGroupInviteButton:SetPoint("TOPRIGHT", WhoFrameEditBox, "BOTTOMRIGHT", bpad, -5)
  end

  do -- guild
    GuildFrameColumnHeader3:ClearAllPoints()
    GuildFrameColumnHeader3:SetPoint("TOPLEFT", 20, -72)
    StripTextures(GuildFrameColumnHeader3)

    GuildFrameColumnHeader4:ClearAllPoints()
    GuildFrameColumnHeader4:SetPoint("LEFT", GuildFrameColumnHeader3, "RIGHT", -3, -0)
    GuildFrameColumnHeader4:SetWidth(68)
    StripTextures(GuildFrameColumnHeader4)

    GuildFrameColumnHeader1:ClearAllPoints()
    GuildFrameColumnHeader1:SetPoint("LEFT", GuildFrameColumnHeader4, "RIGHT", -4, -0)
    GuildFrameColumnHeader1:SetWidth(85)
    StripTextures(GuildFrameColumnHeader1)

    GuildFrameColumnHeader2:ClearAllPoints()
    GuildFrameColumnHeader2:SetPoint("LEFT", GuildFrameColumnHeader1, "RIGHT", -14, -0)
    GuildFrameColumnHeader2:SetWidth(127)
    StripTextures(GuildFrameColumnHeader2)

    GuildListScrollFrame:SetPoint("TOPLEFT", GuildFrameButton1, "TOPLEFT", 10, -2)
    GuildListScrollFrame:SetPoint("BOTTOMRIGHT", GuildFrameButton13, "BOTTOMRIGHT", 0, -4)
    CreateBackdrop(GuildListScrollFrame)

    StripTextures(GuildListScrollFrame)
    SkinScrollbar(GuildListScrollFrameScrollBar, GuildListScrollFrame)

    for i = 1, 4 do
      StripTextures(_G["GuildFrameColumnHeader"..i])
      StripTextures(_G["GuildFrameGuildStatusColumnHeader"..i])
    end

    GuildFrameTotals:ClearAllPoints()
    GuildFrameTotals:SetPoint("TOPLEFT", GuildListScrollFrame, "BOTTOMLEFT", 1, -7)
    GuildFrameGuildListToggleButton:SetPoint("TOPLEFT", GuildListScrollFrameScrollBarScrollDownButton, "BOTTOMLEFT", 0, -7)
    GuildFrameGuildListToggleButton:SetWidth(16)
    GuildFrameGuildListToggleButton:SetHeight(16)
    pfUI.api.SkinArrowButton(GuildFrameGuildListToggleButton, "right")
    GuildFrameGuildListToggleButton:SetFont(STANDARD_TEXT_FONT, C.global.font_size - 1)
    GuildFrameGuildListToggleButton:SetTextColor(1,1,1)

    CreateBackdrop(GuildMOTDEditButton)
    GuildMOTDEditButton:ClearAllPoints()
    GuildMOTDEditButton:SetPoint("TOPLEFT", GuildListScrollFrame, "BOTTOMLEFT", 0, -30)
    GuildMOTDEditButton:SetPoint("BOTTOMRIGHT", GuildListScrollFrameScrollBarScrollDownButton, "BOTTOMRIGHT", 0, -88)

    GuildFrameNotesLabel:SetPoint("TOPLEFT", GuildMOTDEditButton, 2, -2)
    GuildFrameNotesLabel:SetTextColor(.5,.5,.5,1)

    GuildFrameNotesText:ClearAllPoints()
    GuildFrameNotesText:SetPoint("TOPLEFT", GuildMOTDEditButton, "TOPLEFT", 4, -20)
    GuildFrameNotesText:SetPoint("BOTTOMRIGHT", GuildMOTDEditButton, "BOTTOMRIGHT", -4, 4)
    GuildFrameNotesText:SetTextColor(1,1,1,1)

    for i = 1, 13 do
      local frame = _G["GuildFrameButton"..i]
      if frame then
        local tex = frame:GetHighlightTexture()
        tex:SetTexture(1,1,1,.1)
        tex:ClearAllPoints()
        tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -3)
        tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, -2)
        frame:SetHeight(17)

        _G["GuildFrameButton"..i.."Level"]:ClearAllPoints()
        _G["GuildFrameButton"..i.."Level"]:SetPoint("TOPLEFT", 10, -3)

        _G["GuildFrameButton"..i.."Name"]:SetWidth(80)
        _G["GuildFrameButton"..i.."Name"]:SetHeight(14)

        _G["GuildFrameButton"..i.."Name"]:ClearAllPoints()
        _G["GuildFrameButton"..i.."Name"]:SetPoint("LEFT", 105, -3)
      end

      local frame = _G["GuildFrameGuildStatusButton"..i]
      if frame then
        local tex = frame:GetHighlightTexture()
        tex:SetTexture(1,1,1,.1)
        tex:ClearAllPoints()
        tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -3)
        tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, -2)
        frame:SetHeight(17)
      end
    end

    GuildFrameLFGFrame:ClearAllPoints()
    GuildFrameLFGFrame:SetPoint("TOPRIGHT", -35, -45)
    StripTextures(GuildFrameLFGFrame)
    SkinCheckbox(GuildFrameLFGButton)

    GuildFrameGuildInformationButton:SetHeight(18)
    GuildFrameGuildInformationButton:SetPoint("TOPLEFT", GuildMOTDEditButton, "BOTTOMLEFT", -bpad, -bpad - 2)
    SkinButton(GuildFrameGuildInformationButton)

    GuildFrameAddMemberButton:SetHeight(18)
    SkinButton(GuildFrameAddMemberButton)

    GuildFrameControlButton:SetHeight(18)
    GuildFrameControlButton:ClearAllPoints()
    GuildFrameControlButton:SetPoint("TOPRIGHT", GuildMOTDEditButton, "BOTTOMRIGHT", bpad, -bpad - 2)
    SkinButton(GuildFrameControlButton)

    -- side dock dialog
    StripTextures(GuildMemberDetailFrame)
    CreateBackdrop(GuildMemberDetailFrame)
    SetAllPointsOffset(GuildMemberDetailFrame.backdrop, GuildMemberDetailFrame, 2*bpad)

    GuildMemberDetailZoneText:SetPoint("RIGHT", -20, 0)
    GuildMemberDetailZoneText:SetJustifyH("RIGHT")

    GuildMemberDetailRankText:SetPoint("RIGHT", -20, 0)
    GuildMemberDetailRankText:SetJustifyH("RIGHT")

    GuildMemberDetailOnlineText:SetPoint("RIGHT", -20, 0)
    GuildMemberDetailOnlineText:SetJustifyH("RIGHT")

    SkinArrowButton(GuildFramePromoteButton, "up")
    GuildFramePromoteButton:SetWidth(12)
    GuildFramePromoteButton:SetHeight(12)
    GuildFramePromoteButton:ClearAllPoints()
    GuildFramePromoteButton:SetPoint("TOPLEFT", GuildMemberDetailRankText, "TOPRIGHT", 3, 6)

    SkinArrowButton(GuildFrameDemoteButton, "down")
    GuildFrameDemoteButton:SetWidth(12)
    GuildFrameDemoteButton:SetHeight(12)
    GuildFrameDemoteButton:ClearAllPoints()
    GuildFrameDemoteButton:SetPoint("BOTTOMLEFT", GuildMemberDetailRankText, "BOTTOMRIGHT", 3, -6)

    StripTextures(GuildMemberNoteBackground)
    CreateBackdrop(GuildMemberNoteBackground)
    SetAllPointsOffset(GuildMemberNoteBackground.backdrop, GuildMemberNoteBackground, 2)

    StripTextures(GuildMemberOfficerNoteBackground)
    CreateBackdrop(GuildMemberOfficerNoteBackground)
    SetAllPointsOffset(GuildMemberOfficerNoteBackground.backdrop, GuildMemberOfficerNoteBackground, 2)

    SkinButton(GuildMemberRemoveButton)
    SkinButton(GuildMemberGroupInviteButton)

    SkinCloseButton(GuildMemberDetailCloseButton)
    GuildMemberDetailCloseButton:SetPoint("TOPRIGHT", -6, -6)

    -- guild info dock
    StripTextures(GuildInfoFrame)
    CreateBackdrop(GuildInfoFrame)
    SetAllPointsOffset(GuildInfoFrame.backdrop, GuildInfoFrame, 2*bpad +2)
    CreateBackdrop(GuildInfoTextBackground, nil, true)

    SkinScrollbar(GuildInfoFrameScrollFrameScrollBar, GuildInfoFrameScrollFrame)

    SkinCloseButton(GuildInfoCloseButton)
    GuildInfoCloseButton:SetPoint("TOPRIGHT",  -8, -8)

    SkinButton(GuildInfoSaveButton)
    GuildInfoSaveButton:ClearAllPoints()
    GuildInfoSaveButton:SetPoint("TOPLEFT", GuildInfoTextBackground, "BOTTOMLEFT", 0, -2)
    GuildInfoSaveButton:SetPoint("TOPRIGHT", GuildInfoTextBackground, "BOTTOM", -1, 2)
    GuildInfoSaveButton:SetHeight(22)

    SkinButton(GuildInfoCancelButton)
    GuildInfoCancelButton:ClearAllPoints()
    GuildInfoCancelButton:SetPoint("TOPLEFT", GuildInfoTextBackground, "BOTTOM", 1, -2)
    GuildInfoCancelButton:SetPoint("TOPRIGHT", GuildInfoTextBackground, "BOTTOMRIGHT", 0, 2)
    GuildInfoCancelButton:SetHeight(22)

    -- guild control
    StripTextures(GuildControlPopupFrame)
    CreateBackdrop(GuildControlPopupFrame)
    GuildControlPopupFrame.backdrop:SetPoint("TOPLEFT", bpad*2+2, 0)

    SkinDropDown(GuildControlPopupFrameDropDown)

    GuildControlPopupFrameAddRankButton:SetPoint("LEFT", GuildControlPopupFrameDropDown, "RIGHT", -12, 3)
    SkinButton(GuildControlPopupFrameAddRankButton)
    GuildControlPopupFrameAddRankButton:SetWidth(18)
    GuildControlPopupFrameAddRankButton:SetHeight(18)
    GuildControlPopupFrameAddRankButton:SetText("+")

    GuildControlPopupFrameRemoveRankButton:SetPoint("LEFT", GuildControlPopupFrameAddRankButton, "RIGHT", bpad*2-1, 0)
    SkinButton(GuildControlPopupFrameRemoveRankButton)
    GuildControlPopupFrameRemoveRankButton:SetWidth(18)
    GuildControlPopupFrameRemoveRankButton:SetHeight(18)
    GuildControlPopupFrameRemoveRankButton:SetText("-")

    local _,_,_,_,_,left,right = GuildControlPopupFrameEditBox:GetRegions()
    left:Hide()
    right:Hide()

    CreateBackdrop(GuildControlPopupFrameEditBox)
    GuildControlPopupFrameEditBox:SetHeight(20)

    for i = 1, 13 do
      SkinCheckbox(_G["GuildControlPopupFrameCheckbox"..i])
    end

    SkinButton(GuildControlPopupAcceptButton)
    SkinButton(GuildControlPopupFrameCancelButton)
  end

  do -- raid
    SkinButton(RaidFrameConvertToRaidButton)
    SkinButton(RaidFrameRaidInfoButton)

    RaidFrameRaidInfoButton:ClearAllPoints()
    RaidFrameRaidInfoButton:SetPoint("TOPRIGHT", -70, -37)

    RaidFrameConvertToRaidButton:ClearAllPoints()
    RaidFrameConvertToRaidButton:SetPoint("RIGHT", RaidFrameRaidInfoButton, "LEFT", -4, 0)

    StripTextures(RaidInfoFrame)
    CreateBackdrop(RaidInfoFrame)
    RaidInfoFrame.backdrop:SetPoint("TOPLEFT", 2*bpad, 0)

    SkinCloseButton(RaidInfoCloseButton)
    StripTextures(RaidInfoScrollFrame)
    CreateBackdrop(RaidInfoScrollFrame)
    RaidInfoScrollFrame.backdrop:SetPoint("TOPLEFT", -10, 10)
    RaidInfoScrollFrame.backdrop:SetPoint("BOTTOMRIGHT", 5, -5)
    RaidInfoScrollFrame:SetPoint("TOPLEFT", 28, -60)
    SkinScrollbar(RaidInfoScrollFrameScrollBar, RaidInfoScrollFrame)
    RaidInfoScrollFrameScrollBar:ClearAllPoints()
    RaidInfoScrollFrameScrollBar:SetPoint("LEFT", RaidInfoScrollFrame.backdrop, "RIGHT", 5, 0)

    RaidInfoScrollFrameScrollBarScrollUpButton:ClearAllPoints()
    RaidInfoScrollFrameScrollBarScrollUpButton:SetWidth(16)
    RaidInfoScrollFrameScrollBarScrollUpButton:SetHeight(16)
    RaidInfoScrollFrameScrollBarScrollUpButton:SetPoint("TOPLEFT", RaidInfoScrollFrame.backdrop, "TOPRIGHT", 3, 0)

    RaidInfoScrollFrameScrollBarScrollDownButton:ClearAllPoints()
    RaidInfoScrollFrameScrollBarScrollDownButton:SetWidth(16)
    RaidInfoScrollFrameScrollBarScrollDownButton:SetHeight(16)
    RaidInfoScrollFrameScrollBarScrollDownButton:SetPoint("BOTTOMLEFT", RaidInfoScrollFrame.backdrop, "BOTTOMRIGHT", 3, 0)

    RaidInfoInstanceLabel:SetParent(RaidInfoScrollChildFrame)
    RaidInfoInstanceLabel:ClearAllPoints()
    RaidInfoInstanceLabel:SetPoint("TOPLEFT", RaidInfoScrollChildFrame, "TOPLEFT", -2, 2)

    RaidInfoIDLabel:SetParent(RaidInfoScrollChildFrame)
    RaidInfoIDLabel:ClearAllPoints()
    RaidInfoIDLabel:SetPoint("TOPRIGHT", RaidInfoScrollChildFrame, "TOPRIGHT", -30, 2)

    HookAddonOrVariable("Blizzard_RaidUI", function()
      for i = 1, 40 do
        StripTextures(_G["RaidGroupButton"..i])
      end

      for i = 1, 8 do
        for j = 1, 5 do
          local border = CreateFrame("Frame", nil, _G["RaidGroup" .. i])
          CreateBackdrop(border, nil, true)
          border:SetAllPoints(_G["RaidGroup"..i.."Slot"..j])
          _G["RaidGroup"..i.."Slot"..j]:Hide()
        end
        StripTextures(_G["RaidGroup" .. i])
        _G["RaidGroup" .. i .. "Label"]:SetPoint("TOP", 0, 10)
        _G["RaidGroup" .. i .. "Label"]:SetTextColor(.4,.4,.4)
      end

      SkinButton(RaidFrameReadyCheckButton)
      RaidFrameAddMemberButton:ClearAllPoints()
      RaidFrameAddMemberButton:SetPoint("TOPLEFT", 45, -37)

      SkinButton(RaidFrameAddMemberButton)
      RaidFrameReadyCheckButton:ClearAllPoints()
      RaidFrameReadyCheckButton:SetPoint("LEFT", RaidFrameAddMemberButton, "RIGHT", 2, 0)
    end)
  end
end)
