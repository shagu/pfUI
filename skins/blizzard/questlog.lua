pfUI:RegisterSkin("Quest Log", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  _G.QUESTS_DISPLAYED = 23
  _G.MAX_WATCHABLE_QUESTS = 20 -- TODO

  do -- quest log frame
    -- Compatibility
    local QUEST_COUNT
    if QuestLogCount then -- tbc
      QUEST_COUNT = QuestLogCount

      StripTextures(QUEST_COUNT)
      QUEST_COUNT:ClearAllPoints()
      hooksecurefunc("QuestLogUpdateQuestCount", function(numQuests)
        QUEST_COUNT:ClearAllPoints()
        QUEST_COUNT:SetPoint("BOTTOMRIGHT", QuestLogFrame, "TOPRIGHT", 0, -50)
      end)
    else -- vanilla
      QUEST_COUNT = QuestLogQuestCount

      QUEST_COUNT:ClearAllPoints()
      QUEST_COUNT:SetPoint("TOPRIGHT", -10, -30)
    end

    hooksecurefunc("QuestLog_OnShow", function()
      QuestLogFrame:ClearAllPoints()
      QuestLogFrame:SetPoint("TOPLEFT", 10, -104)
    end, 1)

    QuestLogFrame:SetWidth(676)
    QuestLogFrame:SetHeight(440)
    QuestLogFrame:DisableDrawLayer("BACKGROUND")

    StripTextures(QuestLogFrame, true)
    CreateBackdrop(QuestLogFrame, nil, nil, .75)
    CreateBackdropShadow(QuestLogFrame)

    EnableMovable(QuestLogFrame)

    QuestLogTitleText:ClearAllPoints()
    QuestLogTitleText:SetPoint("TOP", 0, -10)
    SkinCloseButton(QuestLogFrameCloseButton, QuestLogFrame, -6, -6)

    QuestLogNoQuestsText:ClearAllPoints()
    QuestLogNoQuestsText:SetPoint("TOP", QuestLogFrame, 0, -100)

    local QuestLogFrameLevelsCheckButton = CreateFrame("CheckButton", "QuestLogFrameLevelsCheckButton", QuestLogFrame, "UICheckButtonTemplate")
    QuestLogFrameLevelsCheckButton:SetChecked(C.questlog.showQuestLevels == "1" and true or nil)
    QuestLogFrameLevelsCheckButton:SetPoint("LEFT", QuestLogCollapseAllButton, "RIGHT", 0, 1)
    QuestLogFrameLevelsCheckButton:SetScript("OnClick", function()
      C.questlog.showQuestLevels = C.questlog.showQuestLevels == "1" and "0" or "1"

      -- also update pfQuest's config
      if pfQuest_config and pfQuestConfig and pfQuestConfig.UpdateConfigEntries then
        pfQuest_config["questloglevel"] = C.questlog.showQuestLevels
        pfQuestConfig:UpdateConfigEntries()
      end

      QuestLog_Update()
    end)
    SkinCheckbox(QuestLogFrameLevelsCheckButton, 23)
    QuestLogFrameLevelsCheckButtonText:SetText(T["Quest Levels"])

    CreateBackdrop(QuestLogTrack)
    QuestLogTrack:SetHeight(8)
    QuestLogTrack:SetWidth(8)
    QuestLogTrack:ClearAllPoints()
    QuestLogTrack:SetPoint("RIGHT", QUEST_COUNT, "LEFT", -5, 0)

    StripTextures(QuestLogTrack)
    QuestLogTrackTracking:SetTexture(.8,.8,.8,1)
    QuestLogTrackTitle:Hide()

    SkinButton(QuestLogFrameAbandonButton)
    QuestLogFrameAbandonButton:ClearAllPoints()
    QuestLogFrameAbandonButton:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 5, 5)
    QuestLogFrameAbandonButton:SetWidth(98)

    SkinButton(QuestFramePushQuestButton)
    QuestFramePushQuestButton:ClearAllPoints()
    QuestFramePushQuestButton:SetPoint("LEFT", QuestLogFrameAbandonButton, "RIGHT", 5, 0)
    QuestFramePushQuestButton:SetWidth(98)

    SkinButton(QuestFrameExitButton)
    QuestFrameExitButton:ClearAllPoints()
    QuestFrameExitButton:SetPoint("LEFT", QuestFramePushQuestButton, "RIGHT", 5, 0)
    QuestFrameExitButton:SetWidth(99)

    local QuestLogFrameExpandButton = CreateFrame("Button", "QuestLogFrameExpandButton", QuestLogFrame, "UIPanelButtonTemplate")
    SkinArrowButton(QuestLogFrameExpandButton, "LEFT", 21)
    SetAllPointsOffset(QuestLogFrameExpandButton.icon, QuestLogFrameExpandButton, 6)
    QuestLogFrameExpandButton:SetPoint("LEFT", QuestFrameExitButton, "RIGHT", 5, 0)
    QuestLogFrameExpandButton:SetScript("OnClick", function()
      if QuestLogDetailScrollFrame:IsShown() then
        QuestLogDetailScrollFrame:Hide()
        QuestLogDetailScrollFrame.hidden = true
      else
        QuestLogDetailScrollFrame:Show()
        QuestLogDetailScrollFrame.hidden = nil
      end
    end)

    HookScript(QuestLogDetailScrollFrame, "OnHide", function()
      SkinArrowButton(QuestLogFrameExpandButton, "RIGHT", 21)
      QuestLogDetailScrollFrame:Hide()
      QuestLogFrame:SetWidth(340)
    end)

    HookScript(QuestLogDetailScrollFrame, "OnShow", function()
      SkinArrowButton(QuestLogFrameExpandButton, "LEFT", 21)
      QuestLogDetailScrollFrame:Show()
      QuestLogFrame:SetWidth(676)
      QuestLog_UpdateQuestDetails()
    end)

    StripTextures(EmptyQuestLogFrame)
    EmptyQuestLogFrame:SetScript("OnShow", function()
      -- trigger hide events
      if QuestLogDetailScrollFrame:IsShown() then
        QuestLogDetailScrollFrame:Hide()
      else
        QuestLogDetailScrollFrame:GetScript("OnHide")()
      end
      QuestLogFrameExpandButton:Disable()
    end)

    EmptyQuestLogFrame:SetScript("OnHide", function()
      QuestLogFrameExpandButton:Enable()
    end)
  end

  do -- left pane
    StripTextures(QuestLogListScrollFrame)
    SkinScrollbar(QuestLogListScrollFrameScrollBar)
    StripTextures(QuestLogExpandButtonFrame) -- ?
    StripTextures(QuestLogCollapseAllButton)
    SkinCollapseButton(QuestLogCollapseAllButton, true)

    -- collapse buttons
    QuestLogCollapseAllButton:ClearAllPoints()
    QuestLogCollapseAllButton:SetPoint("BOTTOMLEFT", QuestLogTitle1, "TOPLEFT", -6, 4)
    for i = 1, QUESTS_DISPLAYED do SkinCollapseButton(_G["QuestLogTitle"..i]) end

    -- quest list backdrop
    local backdrop = CreateFrame("Frame", nil, QuestLogFrame)
    CreateBackdrop(backdrop, nil, nil, .75)
    backdrop.backdrop:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPLEFT", -5, 5)
    backdrop.backdrop:SetPoint("BOTTOMRIGHT", QuestLogListScrollFrame, "BOTTOMRIGHT", 26, -5)

    QuestLogTitle1:ClearAllPoints()
    QuestLogTitle1:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPLEFT", 0, 0)

    -- add additional scroll entries
    for i = 7, QUESTS_DISPLAYED do
      local b = _G["QuestLogTitle"..i] or CreateFrame("Button", "QuestLogTitle"..i, QuestLogFrame, "QuestLogTitleButtonTemplate")
      b:SetID(i)
      b:SetPoint("TOPLEFT", _G["QuestLogTitle"..(i-1)], "BOTTOMLEFT", 0, 1)
      SkinCollapseButton(_G["QuestLogTitle"..i])
    end

    QuestLogListScrollFrame:SetPoint("TOPLEFT", 10, -54)
    QuestLogListScrollFrame:SetHeight(350)

    hooksecurefunc("QuestLog_Update", function()
      local numEntries = GetNumQuestLogEntries()
      local questIndex, text, level, questTag, isHeader

      if QuestLogDetailScrollFrame.hidden then
        QuestLogDetailScrollFrame:Hide()
      end

      for i=1, QUESTS_DISPLAYED do
        -- update tracked quest marks
        _G["QuestLogTitle"..i.."Check"]:ClearAllPoints()
        _G["QuestLogTitle"..i.."Check"]:SetPoint("RIGHT", _G["QuestLogTitle"..i], "LEFT", 24, 0)

        -- update quest level
        if C.questlog.showQuestLevels == "1" then
          questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
          if questIndex <= numEntries then
            if pfUI.expansion == 'vanilla' then
              text, level, questTag, isHeader = GetQuestLogTitle(questIndex)
            else
              text, level, questTag, _, isHeader = GetQuestLogTitle(questIndex)
            end
            if not isHeader then
              _G["QuestLogTitle"..i]:SetText(" ".."["..(questTag and level.."+" or level).."] "..text)
            end
          end
        end
      end
    end, 1)
  end

  do -- right pane
    StripTextures(QuestLogDetailScrollFrame)
    SkinScrollbar(QuestLogDetailScrollFrameScrollBar)



    QuestLogDetailScrollFrame:ClearAllPoints()
    QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 35, 0)
    QuestLogDetailScrollFrame:SetHeight(376)
    QuestLogDetailScrollChildFrame:SetHeight(376)

    local bg = QuestLogDetailScrollFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexCoord(.1,1,0,1)
    bg:SetTexture("Interface\\Stationery\\StationeryTest1")

    -- quest log backdrop
    CreateBackdrop(QuestLogDetailScrollFrame, nil, nil, .75)
    QuestLogDetailScrollFrame.backdrop:SetPoint("TOPLEFT", -5, 5)
    QuestLogDetailScrollFrame.backdrop:SetPoint("BOTTOMRIGHT", 26, -5)

    -- skin item buttons
    for i = 1, MAX_NUM_ITEMS do
      local name = "QuestLogItem" .. i
      local item = _G[name]
      local icon = _G[name.."IconTexture"]
      local count = _G[name.."Count"]
      local title = _G[name.."Name"]

      local xsize = item:GetWidth() -12
      local ysize = item:GetHeight() -12

      item:SetWidth(xsize)
      StripTextures(item)
      CreateBackdrop(item, nil, nil, .75)
      SetAllPointsOffset(item.backdrop, item, 4)
      SetHighlight(item)

      icon:SetWidth(ysize)
      icon:SetHeight(ysize)
      icon:ClearAllPoints()
      icon:SetPoint("LEFT", 6, 0)
      icon:SetTexCoord(.08, .92, .08, .92)
      icon:SetParent(item.backdrop)
      icon:SetDrawLayer("OVERLAY")

      count:SetParent(item.backdrop)
      count:SetDrawLayer("OVERLAY")

      title:SetParent(item.backdrop)
      title:SetDrawLayer("OVERLAY")
    end
  end
end)
