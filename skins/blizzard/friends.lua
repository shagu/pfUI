pfUI:RegisterSkin("Friends", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()
  local maxtab = pfUI.expansion == "vanilla" and 4 or 5

  StripTextures(FriendsFrame, true)
  CreateBackdrop(FriendsFrame, nil, nil, .75)
  CreateBackdropShadow(FriendsFrame)

  FriendsFrame.backdrop:SetPoint("TOPLEFT", 8, -10)
  FriendsFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 74)
  FriendsFrame:SetHitRectInsets(8,32,10,74)
  EnableMovable("FriendsFrame")

  SkinCloseButton(FriendsFrameCloseButton, FriendsFrame.backdrop, -6, -6)

  FriendsFrameTitleText:ClearAllPoints()
  FriendsFrameTitleText:SetPoint("TOP", FriendsFrame.backdrop, "TOP", 0, -10)

  FriendsFrameTab1:ClearAllPoints()
  FriendsFrameTab1:SetPoint("TOPLEFT", FriendsFrame.backdrop, "BOTTOMLEFT", border, -2*border)
  for i = 1, maxtab do
    local tab = _G["FriendsFrameTab"..i]
    local lastTab = _G["FriendsFrameTab"..(i-1)]
    if lastTab then
      tab:ClearAllPoints()
      tab:SetPoint("LEFT", lastTab, "RIGHT", 3*border, 0)
    end
    SkinTab(tab)
  end

  do -- Friends Tab
    -- Friends SubTab
    SkinTab(FriendsFrameToggleTab1)
    FriendsFrameToggleTab1:ClearAllPoints()
    FriendsFrameToggleTab1:SetPoint("BOTTOMLEFT", FriendsFrameFriendsScrollFrame, "TOPLEFT", 0, border*2 + 1)
    SkinTab(FriendsFrameToggleTab2)
    FriendsFrameToggleTab2:ClearAllPoints()
    FriendsFrameToggleTab2:SetPoint("LEFT", FriendsFrameToggleTab1, "RIGHT", border*2 + 1, 0)

    StripTextures(FriendsFrameFriendsScrollFrame)
    CreateBackdrop(FriendsFrameFriendsScrollFrame)
    SkinScrollbar(FriendsFrameFriendsScrollFrameScrollBar, true)

    SkinButton(FriendsFrameAddFriendButton)
    FriendsFrameAddFriendButton:SetWidth(158)
    FriendsFrameAddFriendButton:ClearAllPoints()
    FriendsFrameAddFriendButton:SetPoint("TOPLEFT", FriendsFrameFriendsScrollFrame, "BOTTOMLEFT", -bpad, -border*2)

    SkinButton(FriendsFrameRemoveFriendButton)
    FriendsFrameRemoveFriendButton:SetWidth(158)
    FriendsFrameRemoveFriendButton:ClearAllPoints()
    FriendsFrameRemoveFriendButton:SetPoint("TOP", FriendsFrameAddFriendButton, "BOTTOM", 0, -4)

    SkinButton(FriendsFrameSendMessageButton)
    FriendsFrameSendMessageButton:SetWidth(158)
    FriendsFrameSendMessageButton:ClearAllPoints()
    FriendsFrameSendMessageButton:SetPoint("TOPRIGHT", FriendsFrameFriendsScrollFrameScrollBarScrollDownButton, "BOTTOMRIGHT", bpad, -border*2)

    SkinButton(FriendsFrameGroupInviteButton)
    FriendsFrameGroupInviteButton:SetWidth(158)
    FriendsFrameGroupInviteButton:ClearAllPoints()
    FriendsFrameGroupInviteButton:SetPoint("TOP", FriendsFrameSendMessageButton, "BOTTOM", 0, -4)

    for i = 1, FRIENDS_TO_DISPLAY do
      local frame = _G["FriendsFrameFriendButton"..i]
      if frame then
        local tex = frame:GetHighlightTexture()
        tex:ClearAllPoints()
        tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 2)
        frame:SetHeight(30)
      end
    end

    -- Ignore SubTab
    SkinTab(IgnoreFrameToggleTab1)
    IgnoreFrameToggleTab1:ClearAllPoints()
    IgnoreFrameToggleTab1:SetPoint("BOTTOMLEFT", FriendsFrameIgnoreScrollFrame, "TOPLEFT", 0, border*2 + 1)
    SkinTab(IgnoreFrameToggleTab2)
    IgnoreFrameToggleTab2:ClearAllPoints()
    IgnoreFrameToggleTab2:SetPoint("LEFT", IgnoreFrameToggleTab1, "RIGHT", border*2 + 1, 0)

    StripTextures(FriendsFrameIgnoreScrollFrame)
    CreateBackdrop(FriendsFrameIgnoreScrollFrame)
    SkinScrollbar(FriendsFrameIgnoreScrollFrameScrollBar, true)
    FriendsFrameIgnoreScrollFrame:SetHeight(329)

    SkinButton(FriendsFrameIgnorePlayerButton)
    FriendsFrameIgnorePlayerButton:SetWidth(158)
    FriendsFrameIgnorePlayerButton:ClearAllPoints()
    FriendsFrameIgnorePlayerButton:SetPoint("TOPLEFT", FriendsFrameIgnoreScrollFrame, "BOTTOMLEFT", -bpad, -border*2)

    SkinButton(FriendsFrameStopIgnoreButton)
    FriendsFrameStopIgnoreButton:SetWidth(158)
    FriendsFrameStopIgnoreButton:ClearAllPoints()
    FriendsFrameStopIgnoreButton:SetPoint("TOPRIGHT", FriendsFrameIgnoreScrollFrameScrollBarScrollDownButton, "BOTTOMRIGHT", bpad, -border*2)

    for i = 1, IGNORES_TO_DISPLAY do
      local frame = _G["FriendsFrameIgnoreButton"..i]
      if frame then
        local tex = frame:GetHighlightTexture()
        tex:ClearAllPoints()
        tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
        tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, -1)
      end
    end
  end

  do -- Who Tab
    WhoListScrollFrame:SetPoint("TOPLEFT", 25, -70)
    WhoFrameButton1:SetPoint("TOPLEFT", WhoListScrollFrame, "TOPLEFT", -5, -5)

    StripTextures(WhoListScrollFrame)
    CreateBackdrop(WhoListScrollFrame)
    SkinScrollbar(WhoListScrollFrameScrollBar, true)

    StripTextures(WhoFrameColumnHeader3)
    WhoFrameColumnHeader3:ClearAllPoints()
    WhoFrameColumnHeader3:SetPoint("BOTTOMLEFT", WhoListScrollFrame, "TOPLEFT", 0, 4)

    StripTextures(WhoFrameColumnHeader4)
    WhoFrameColumnHeader4:SetWidth(32)
    WhoFrameColumnHeader4:ClearAllPoints()
    WhoFrameColumnHeader4:SetPoint("LEFT", WhoFrameColumnHeader3, "RIGHT", -2, 0)

    StripTextures(WhoFrameColumnHeader1)
    WhoFrameColumnHeader1:SetWidth(120)
    WhoFrameColumnHeader1:ClearAllPoints()
    WhoFrameColumnHeader1:SetPoint("LEFT", WhoFrameColumnHeader4, "RIGHT", -2, 0)

    StripTextures(WhoFrameColumnHeader2)
    WhoFrameColumnHeader2:ClearAllPoints()
    WhoFrameColumnHeader2:SetPoint("LEFT", WhoFrameColumnHeader1, "RIGHT", -2, 0)

    SkinDropDown(WhoFrameDropDown)
    WhoFrameDropDown.backdrop:SetPoint("BOTTOMRIGHT", WhoListScrollFrame.backdrop, "TOPRIGHT", 0, 3)
    WhoFrameDropDownButton:ClearAllPoints()
    WhoFrameDropDownButton:SetPoint("RIGHT", WhoFrameDropDown.backdrop, "RIGHT", 0, 0)

    -- add class icon buttons
    for i = 1, WHOS_TO_DISPLAY do
      local frame = _G["WhoFrameButton"..i]
      frame.classicon = frame.classicon or frame:CreateTexture(nil, "OVERLAY")
      frame.classicon:SetPoint("CENTER", _G["WhoFrameButton"..i.."Class"], "CENTER", -4, 0)
      frame.classicon:SetWidth(15)
      frame.classicon:SetHeight(15)
      frame.classicon:SetTexture(pfUI.media["img:classicons"])
      frame.classicon:Hide()
    end

    -- set positions
    hooksecurefunc("WhoList_Update", function()
      for i = 1, WHOS_TO_DISPLAY do
        local level = _G["WhoFrameButton"..i.."Level"]
        level:ClearAllPoints()
        level:SetPoint("TOPLEFT", 10, -3)

        local class = _G["WhoFrameButton"..i.."Class"]
        class:SetWidth(30)
        class:ClearAllPoints()
        class:SetPoint("LEFT", level, "RIGHT", 10, 0)

        local name = _G["WhoFrameButton"..i.."Name"]
        name:SetWidth(120)
        name:ClearAllPoints()
        name:SetPoint("LEFT", class, "RIGHT", 0, 0)
      end
    end)

    CreateBackdrop(WhoFrameEditBox, nil, true)
    WhoFrameEditBox:SetTextInsets(5,5,5,5)
    WhoFrameEditBox:ClearAllPoints()
    WhoFrameEditBox:SetPoint("TOPLEFT",  WhoListScrollFrame.backdrop, "BOTTOMLEFT", 0, -4)
    WhoFrameEditBox:SetPoint("TOPRIGHT",  WhoListScrollFrameScrollBarScrollDownButton, "BOTTOMRIGHT", 0, -5)
    WhoFrameEditBox:SetHeight(20)

    WhoFrameTotals:ClearAllPoints()
    WhoFrameTotals:SetPoint("BOTTOM", FriendsFrame.backdrop, "BOTTOM", 0, 8)

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

  do -- Guild Tab
    for i = 1, 4 do
      StripTextures(_G["GuildFrameColumnHeader"..i])
      StripTextures(_G["GuildFrameGuildStatusColumnHeader"..i])
    end

    -- level
    GuildFrameColumnHeader3:ClearAllPoints()
    GuildFrameColumnHeader3:SetPoint("TOPLEFT", 20, -70)

    -- class
    GuildFrameColumnHeader4:ClearAllPoints()
    GuildFrameColumnHeader4:SetPoint("LEFT", GuildFrameColumnHeader3, "RIGHT", -12, -0)
    GuildFrameColumnHeader4:SetWidth(32)

    -- name
    GuildFrameColumnHeader1:ClearAllPoints()
    GuildFrameColumnHeader1:SetPoint("LEFT", GuildFrameColumnHeader4, "RIGHT", -2, -0)
    GuildFrameColumnHeader1:SetWidth(120)

    -- zone
    GuildFrameColumnHeader2:ClearAllPoints()
    GuildFrameColumnHeader2:SetPoint("LEFT", GuildFrameColumnHeader1, "RIGHT", -2, -0)

    StripTextures(GuildListScrollFrame)
    CreateBackdrop(GuildListScrollFrame)
    SkinScrollbar(GuildListScrollFrameScrollBar, true)

    -- add class icon buttons
    for i = 1, GUILDMEMBERS_TO_DISPLAY do
      local frame = _G["GuildFrameButton"..i]
      frame.classicon = frame.classicon or frame:CreateTexture(nil, "OVERLAY")
      frame.classicon:SetPoint("CENTER", _G["GuildFrameButton"..i.."Class"], "CENTER", -4, 0)
      frame.classicon:SetWidth(15)
      frame.classicon:SetHeight(15)
      frame.classicon:SetTexture(pfUI.media["img:classicons"])
      frame.classicon:Hide()
    end

    -- set positions
    hooksecurefunc("GuildStatus_Update", function()
      for i = 1, GUILDMEMBERS_TO_DISPLAY do
        local level = _G["GuildFrameButton"..i.."Level"]
        level:ClearAllPoints()
        level:SetPoint("TOPLEFT", 10, -3)

        local class = _G["GuildFrameButton"..i.."Class"]
        class:SetWidth(30)
        class:ClearAllPoints()
        class:SetPoint("LEFT", level, "RIGHT", 5, 0)

        local name = _G["GuildFrameButton"..i.."Name"]
        name:SetWidth(120)
        name:ClearAllPoints()
        name:SetPoint("LEFT", class, "RIGHT", 0, 0)
      end
    end)

    SkinArrowButton(GuildFrameGuildListToggleButton, "right", 16)
    GuildFrameGuildListToggleButton:ClearAllPoints()
    GuildFrameGuildListToggleButton:SetPoint("TOPLEFT", GuildListScrollFrame, "BOTTOMRIGHT", -20, 20)

    CreateBackdrop(GuildMOTDEditButton)
    GuildMOTDEditButton:ClearAllPoints()
    GuildMOTDEditButton:SetPoint("TOPLEFT", GuildListScrollFrame, "BOTTOMLEFT", 0, -border*2)
    GuildMOTDEditButton:SetPoint("BOTTOMRIGHT", GuildListScrollFrameScrollBarScrollDownButton, "BOTTOMRIGHT", 0, -68)

    GuildFrameNotesLabel:SetPoint("TOPLEFT", GuildMOTDEditButton, 2, -2)
    GuildFrameNotesLabel:SetTextColor(.5,.5,.5,1)

    GuildFrameNotesText:ClearAllPoints()
    GuildFrameNotesText:SetPoint("TOPLEFT", GuildMOTDEditButton, "TOPLEFT", 4, -20)
    GuildFrameNotesText:SetPoint("BOTTOMRIGHT", GuildMOTDEditButton, "BOTTOMRIGHT", -4, 4)
    GuildFrameNotesText:SetTextColor(1,1,1,1)

    StripTextures(GuildFrameLFGFrame)
    GuildFrameLFGFrame:ClearAllPoints()
    GuildFrameLFGFrame:SetPoint("TOPRIGHT", -35, -45)
    SkinCheckbox(GuildFrameLFGButton)

    SkinButton(GuildFrameGuildInformationButton)
    GuildFrameGuildInformationButton:ClearAllPoints()
    GuildFrameGuildInformationButton:SetPoint("TOPLEFT", GuildMOTDEditButton, "BOTTOMLEFT", -bpad, -5)

    SkinButton(GuildFrameAddMemberButton)
    GuildFrameAddMemberButton:SetPoint("LEFT", GuildFrameGuildInformationButton, "RIGHT", 3, 0)
    GuildFrameAddMemberButton:SetPoint("RIGHT", GuildFrameControlButton, "LEFT", -3, 0)

    SkinButton(GuildFrameControlButton)
    GuildFrameControlButton:ClearAllPoints()
    GuildFrameControlButton:SetPoint("TOPRIGHT", GuildMOTDEditButton, "BOTTOMRIGHT", bpad, -5)

    -- side dock dialog
    StripTextures(GuildMemberDetailFrame)
    CreateBackdrop(GuildMemberDetailFrame, nil, true, .75)
    GuildMemberDetailFrame:ClearAllPoints()
    GuildMemberDetailFrame:SetPoint("TOPLEFT", FriendsFrame.backdrop, "TOPRIGHT", border*2, 0)

    SkinCloseButton(GuildMemberDetailCloseButton, GuildMemberDetailFrame, -6, -6)

    for _,text in pairs({"ZoneText", "RankText", "OnlineText"}) do
      text = _G["GuildMemberDetail"..text]
      text:SetPoint("RIGHT", -20, 0)
      text:SetJustifyH("RIGHT")
    end

    SkinArrowButton(GuildFramePromoteButton, "up", 12)
    GuildFramePromoteButton:ClearAllPoints()
    GuildFramePromoteButton:SetPoint("TOPLEFT", GuildMemberDetailRankText, "TOPRIGHT", 3, 6)

    SkinArrowButton(GuildFrameDemoteButton, "down", 12)
    GuildFrameDemoteButton:ClearAllPoints()
    GuildFrameDemoteButton:SetPoint("BOTTOMLEFT", GuildMemberDetailRankText, "BOTTOMRIGHT", 3, -6)

    StripTextures(GuildMemberNoteBackground)
    CreateBackdrop(GuildMemberNoteBackground, nil, true)

    StripTextures(GuildMemberOfficerNoteBackground)
    CreateBackdrop(GuildMemberOfficerNoteBackground, nil, true)

    SkinButton(GuildMemberRemoveButton)
    GuildMemberRemoveButton:ClearAllPoints()
    GuildMemberRemoveButton:SetPoint("BOTTOMRIGHT", GuildMemberDetailFrame, "BOTTOM", -bpad, 8)

    SkinButton(GuildMemberGroupInviteButton)
    GuildMemberGroupInviteButton:ClearAllPoints()
    GuildMemberGroupInviteButton:SetPoint("BOTTOMLEFT", GuildMemberDetailFrame, "BOTTOM", bpad, 8)

    -- guild info dock
    StripTextures(GuildInfoFrame)
    CreateBackdrop(GuildInfoFrame, nil, true, .75)

    SkinCloseButton(GuildInfoCloseButton, GuildInfoFrame, -6, -6)

    CreateBackdrop(GuildInfoTextBackground, nil, true)
    SkinScrollbar(GuildInfoFrameScrollFrameScrollBar)

    SkinButton(GuildInfoSaveButton)
    GuildInfoSaveButton:ClearAllPoints()
    GuildInfoSaveButton:SetPoint("BOTTOMLEFT", GuildInfoFrame, "BOTTOMLEFT", 10, 8)

    SkinButton(GuildInfoCancelButton)
    GuildInfoCancelButton:ClearAllPoints()
    GuildInfoCancelButton:SetPoint("BOTTOMRIGHT", GuildInfoFrame, "BOTTOMRIGHT", -10, 8)

    if GuildInfoGuildEventButton then -- log button (tbc+)
      SkinButton(GuildInfoGuildEventButton)
      GuildInfoGuildEventButton:ClearAllPoints()
      GuildInfoGuildEventButton:SetPoint("BOTTOM", GuildInfoFrame, "BOTTOM", 0, 8)
    end

    if GuildEventLogFrame then -- guild log frame (tbc+)
      StripTextures(GuildEventFrame)
      CreateBackdrop(GuildEventFrame, nil, true, .75)
      StripTextures(GuildEventLogFrame)
      CreateBackdrop(GuildEventLogFrame, nil, true, .75)
      StripTextures(GuildEventLogScrollFrame)
      SkinScrollbar(GuildEventLogScrollFrameScrollBar)
      SkinCloseButton(GuildEventLogCloseButton)
      GuildEventLogCancelButton:SetPoint("BOTTOMRIGHT", -9, 8)
      SkinButton(GuildEventLogCancelButton)
    end

    -- guild control
    StripTextures(GuildControlPopupFrame)
    CreateBackdrop(GuildControlPopupFrame, nil, true, .75)
    GuildControlPopupFrame:ClearAllPoints()
    GuildControlPopupFrame:SetPoint("TOPLEFT", FriendsFrame.backdrop, "TOPRIGHT", border*2, 0)

    SkinDropDown(GuildControlPopupFrameDropDown)

    SkinButton(GuildControlPopupFrameAddRankButton)
    GuildControlPopupFrameAddRankButton:SetWidth(18)
    GuildControlPopupFrameAddRankButton:SetHeight(18)
    GuildControlPopupFrameAddRankButton:SetText("+")
    GuildControlPopupFrameAddRankButton:ClearAllPoints()
    GuildControlPopupFrameAddRankButton:SetPoint("LEFT", GuildControlPopupFrameDropDown.backdrop, "RIGHT", 4, 0)

    SkinButton(GuildControlPopupFrameRemoveRankButton)
    GuildControlPopupFrameRemoveRankButton:SetWidth(18)
    GuildControlPopupFrameRemoveRankButton:SetHeight(18)
    GuildControlPopupFrameRemoveRankButton:SetText("-")
    GuildControlPopupFrameRemoveRankButton:ClearAllPoints()
    GuildControlPopupFrameRemoveRankButton:SetPoint("LEFT", GuildControlPopupFrameAddRankButton, "RIGHT", 2*bpad, 0)

    local _,_,_,_,_,left,right = GuildControlPopupFrameEditBox:GetRegions()
    left:Hide()
    right:Hide()
    CreateBackdrop(GuildControlPopupFrameEditBox)
    GuildControlPopupFrameEditBox:SetHeight(20)

    for i = 1, 13 do
      SkinCheckbox(_G["GuildControlPopupFrameCheckbox"..i])
    end

    SkinButton(GuildControlPopupFrameCancelButton)
    SkinButton(GuildControlPopupAcceptButton)
    GuildControlPopupAcceptButton:ClearAllPoints()
    GuildControlPopupAcceptButton:SetPoint("RIGHT", GuildControlPopupFrameCancelButton, "LEFT", -2*bpad, 0)
  end

  if ChannelFrameVerticalBar then -- Channel Tab (TBC+)
    StripTextures(ChannelFrameVerticalBar)
    SkinButton(ChannelFrameNewButton)
    ChannelFrameNewButton:SetPoint("BOTTOMRIGHT", -15, 82)

    StripTextures(ChannelListScrollFrame)
    SkinScrollbar(ChannelListScrollFrameScrollBar)

    for i = 1, MAX_DISPLAY_CHANNEL_BUTTONS do
      StripTextures(_G["ChannelButton"..i])
      SkinButton(_G["ChannelButton"..i])
    end

    for i = 1, 22 do
      StripTextures(_G["ChannelMemberButton"..i])
    end

    CreateBackdrop(ChannelMemberButton1)
    ChannelMemberButton1.backdrop:SetPoint("BOTTOMRIGHT", ChannelMemberButton22, "BOTTOMRIGHT", -1, 0)

    StripTextures(ChannelRosterScrollFrame)
    SkinScrollbar(ChannelRosterScrollFrameScrollBar)

    StripTextures(ChannelFrameDaughterFrame)
    CreateBackdrop(ChannelFrameDaughterFrame)

    StripTextures(ChannelFrameDaughterFrameChannelName)
    CreateBackdrop(ChannelFrameDaughterFrameChannelName, nil, true)
    ChannelFrameDaughterFrameChannelName:SetTextInsets(5,5,5,5)

    StripTextures(ChannelFrameDaughterFrameChannelPassword)
    CreateBackdrop(ChannelFrameDaughterFrameChannelPassword, nil, true)
    ChannelFrameDaughterFrameChannelPassword:SetTextInsets(5,5,5,5)

    SkinCloseButton(ChannelFrameDaughterFrameDetailCloseButton)

    SkinButton(ChannelFrameDaughterFrameCancelButton)
    SkinButton(ChannelFrameDaughterFrameOkayButton)
  end

  do -- Raid Tab
    StripTextures(RaidInfoFrame)
    CreateBackdrop(RaidInfoFrame, nil, true, .75)
    RaidInfoFrame:ClearAllPoints()
    RaidInfoFrame:SetPoint("TOPLEFT", FriendsFrame.backdrop, "TOPRIGHT", border*2, 0)

    SkinCloseButton(RaidInfoCloseButton, RaidInfoFrame, -6, -6)

    StripTextures(RaidInfoScrollFrame)
    SkinScrollbar(RaidInfoScrollFrameScrollBar)

    RaidInfoInstanceLabel:ClearAllPoints()
    RaidInfoInstanceLabel:SetPoint("TOPLEFT", RaidInfoSubheader, "BOTTOMLEFT", 0, -6)

    RaidInfoIDLabel:ClearAllPoints()
    RaidInfoIDLabel:SetPoint("TOPRIGHT", RaidInfoSubheader, "BOTTOMRIGHT", 24, -6)

    for i=1, 10 do
      if _G["RaidInfoInstance"..i.."Name"] then
        _G["RaidInfoInstance"..i.."Name"]:SetPoint("TOPLEFT", 2, -2)
      end
    end

    SkinButton(RaidFrameRaidInfoButton)
    SkinButton(RaidFrameConvertToRaidButton)

    HookAddonOrVariable("Blizzard_RaidUI", function()
      for i = 1, MAX_RAID_MEMBERS do
        StripTextures(_G["RaidGroupButton"..i])
        CreateBackdrop(_G["RaidGroupButton"..i], nil, true)
        SetHighlight(_G["RaidGroupButton"..i], 1, 1, 0)
      end

      for i = 1, NUM_RAID_GROUPS do
        StripTextures(_G["RaidGroup" .. i])

        _G["RaidGroup" .. i .. "Label"]:ClearAllPoints()
        _G["RaidGroup" .. i .. "Label"]:SetPoint("TOP", 0, 10)

        for j = 1, MEMBERS_PER_RAID_GROUP do
          StripTextures(_G["RaidGroup"..i.."Slot"..j])
          CreateBackdrop(_G["RaidGroup"..i.."Slot"..j], nil, true)
          SetHighlight(_G["RaidGroup"..i.."Slot"..j], 1, 1, 0)
        end
      end

      SkinButton(RaidFrameReadyCheckButton)
      SkinButton(RaidFrameAddMemberButton)
    end)
  end
end)
