pfUI:RegisterSkin("Quest Log", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  _G.QUESTS_DISPLAYED = 23
  _G.MAX_WATCHABLE_QUESTS = 20 -- TODO

  do -- quest log frame
    hooksecurefunc("QuestLog_OnShow", function()
      QuestLogFrame:ClearAllPoints()
      QuestLogFrame:SetPoint("TOPLEFT", 10, -104)
    end, 1)

    QuestLogFrame:SetWidth(676)
    QuestLogFrame:SetHeight(440)
    QuestLogFrame:DisableDrawLayer("BACKGROUND")

    StripTextures(QuestLogFrame, true)
    CreateBackdrop(QuestLogFrame, nil, nil, .75)
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
      QuestLog_Update()
    end)
    SkinCheckbox(QuestLogFrameLevelsCheckButton, 23)
    QuestLogFrameLevelsCheckButtonText:SetText(T["Quest Levels"])

    QuestLogQuestCount:ClearAllPoints()
    QuestLogQuestCount:SetPoint("TOPRIGHT", -10, -30)

    CreateBackdrop(QuestLogTrack)
    QuestLogTrack:SetHeight(8)
    QuestLogTrack:SetWidth(8)
    QuestLogTrack:ClearAllPoints()
    QuestLogTrack:SetPoint("RIGHT", QuestLogQuestCount, "LEFT", -5, 0)
    HookScript(QuestLogTrack, "OnShow", function()
      QuestLogTrackTitle:Hide()
      QuestLogTrackTracking:SetTexture(.8,.8,.8,1)
    end)

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

    EmptyQuestLogFrame:SetScript("OnShow", function() QuestLogFrameExpandButton:Disable() end)
    EmptyQuestLogFrame:SetScript("OnHide", function() QuestLogFrameExpandButton:Enable() end)
    StripTextures(EmptyQuestLogFrame)
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
      local b = CreateFrame("Button", "QuestLogTitle"..i, QuestLogFrame, "QuestLogTitleButtonTemplate")
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
            text, level, questTag, isHeader = GetQuestLogTitle(questIndex)
            if not isHeader then
              _G["QuestLogTitle"..i]:SetText("  ".."["..(questTag and level.."+" or level).."] "..text)
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
      local xsize = item:GetWidth() - 10
      local ysize = item:GetHeight() - 10

      StripTextures(item)
      SkinButton(item)
      item:SetWidth(xsize)

      icon:SetWidth(ysize)
      icon:SetHeight(ysize)
      icon:ClearAllPoints()
      icon:SetPoint("LEFT", 3, 0)
      icon:SetTexCoord(.08, .92, .08, .92)
    end

    do -- overwrite colors
      hooksecurefunc("QuestLog_UpdateQuestDetails", function()
        for i=1, GetNumQuestLeaderBoards() do
          local string = _G["QuestLogObjective"..i]

          if not string._SetTextColor then
            string._SetTextColor = string.SetTextColor
            string.SetTextColor = function() return end
          end

          local text, type, finished = GetQuestLogLeaderBoard(i)
          if finished then
            string:_SetTextColor(.4, 1, .4)
          else
            string:_SetTextColor(.4, .4, .4)
          end
        end

        local reqmoney = GetQuestLogRequiredMoney()
        if reqmoney > 0 then
          if reqmoney > GetMoney() then
            QuestLogRequiredMoneyText:SetTextColor(1, .4, .4);
          else
            QuestLogRequiredMoneyText:SetTextColor(.4, 1, .4);
          end
        end
      end)

      local titles = { QuestLogQuestTitle, QuestLogDescriptionTitle, QuestLogRewardTitleText }
      for _, string in pairs(titles) do
        if not string._SetTextColor then
          string._SetTextColor = string.SetTextColor
          string.SetTextColor = function() return end
        end
        string:_SetTextColor(1,1,.2,1)
        string:SetShadowColor(0,0,0,0)
      end

      local texts = { QuestLogObjectivesText, QuestLogTimerText, QuestLogQuestDescription,
      QuestLogItemChooseText, QuestLogItemReceiveText, QuestLogSpellLearnText }
      for _, string in pairs(texts) do
        if not string._SetTextColor then
          string._SetTextColor = string.SetTextColor
          string.SetTextColor = function() return end
        end
        string:_SetTextColor(1,1,1,1)
      end
    end
  end
end)
