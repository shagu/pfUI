pfUI:RegisterSkin("QuestLogFrame", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  hooksecurefunc("QuestLog_OnShow", function()
    QuestLogFrame:ClearAllPoints()
    QuestLogFrame:SetPoint("TOPLEFT", 10, -104)
  end, 1)

  StripTextures(QuestLogFrame, true)
  CreateBackdrop(QuestLogFrame, nil, nil, .75)
  QuestLogFrame:SetWidth(353)
  QuestLogFrame:SetHeight(480)
  EnableMovable(QuestLogFrame)

  SkinCloseButton(QuestLogFrameCloseButton, QuestLogFrame, -6, -6)

  QuestLogFrame:DisableDrawLayer("BACKGROUND")

  StripTextures(EmptyQuestLogFrame)

  QuestLogTitleText:ClearAllPoints()
  QuestLogTitleText:SetPoint("TOP", 0, -10)

  QuestLogNoQuestsText:ClearAllPoints()
  QuestLogNoQuestsText:SetPoint("TOP", QuestLogFrame, 0, -100)

  SkinButton(QuestLogFrameAbandonButton)
  QuestLogFrameAbandonButton:ClearAllPoints()
  QuestLogFrameAbandonButton:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 10, 10)
  SkinButton(QuestFramePushQuestButton)
  QuestFramePushQuestButton:ClearAllPoints()
  QuestFramePushQuestButton:SetPoint("LEFT", QuestLogFrameAbandonButton, "RIGHT", 2*bpad, 0)
  SkinButton(QuestFrameExitButton)
  QuestFrameExitButton:ClearAllPoints()
  QuestFrameExitButton:SetPoint("LEFT", QuestFramePushQuestButton, "RIGHT", 2*bpad, 0)

  StripTextures(QuestLogListScrollFrame)
  SkinScrollbar(QuestLogListScrollFrameScrollBar)

  StripTextures(QuestLogDetailScrollFrame)
  SkinScrollbar(QuestLogDetailScrollFrameScrollBar)

  StripTextures(QuestLogExpandButtonFrame)
  StripTextures(QuestLogCollapseAllButton)
  SkinCollapseButton(QuestLogCollapseAllButton, true)
  QuestLogCollapseAllButton:ClearAllPoints()
  QuestLogCollapseAllButton:SetPoint("BOTTOMLEFT", QuestLogTitle1, "TOPLEFT", 2, 2)

  for i = 1, QUESTS_DISPLAYED do
    SkinCollapseButton(_G["QuestLogTitle"..i])
  end

  for i = 1, MAX_OBJECTIVES do
    local button = _G["QuestLogItem"..i]
    StripTextures(button)
    CreateBackdrop(button, nil, true, .5)

    local itemButton = CreateFrame("Button", button:GetName().."ItemButton", button)
    itemButton:SetWidth(37)
    itemButton:SetHeight(37)
    itemButton:SetPoint("LEFT", 2, 0)
    itemButton.icon = itemButton:CreateTexture("ARTWORK")
    itemButton.icon:SetTexture(_G[button:GetName().."IconTexture"]:GetTexture())
    SkinButton(itemButton, nil, nil, nil, itemButton.icon, true)
    itemButton.text = itemButton:CreateFontString("Status", "LOW", "GameFontNormal")
    itemButton.text:SetFontObject(GameFontWhite)
    itemButton.text:SetPoint("BOTTOMRIGHT", -4, 1)
    itemButton.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
  end

  hooksecurefunc("QuestLog_UpdateQuestDetails", function()
    for i = 1, MAX_OBJECTIVES do
      local button = _G["QuestLogItem"..i]
      if button:IsShown() then
        local itemButton = _G[button:GetName().."ItemButton"]
        local texture = _G[button:GetName().."IconTexture"]:GetTexture()
        local numItems = _G[button:GetName().."Count"]:GetText() or 1

        itemButton.icon:SetTexture(texture)
        itemButton.text:SetText(tonumber(numItems) > 1 and numItems)
        _G[button:GetName().."Count"]:SetText()
      end
    end
  end, 1)

  local texture = "StationeryTest"
  if date("%m%d") == "0223" then texture = "Stationery_Val" end
  local tex_Left = QuestLogDetailScrollFrame:CreateTexture("BACKGROUND")
  tex_Left:SetTexture("Interface\\Stationery\\"..texture.."1")
  tex_Left:SetPoint("TOPLEFT", 0, 0)
  local tex_Right = QuestLogDetailScrollFrame:CreateTexture("BACKGROUND")
  tex_Right:SetTexture("Interface\\Stationery\\"..texture.."2")
  tex_Right:SetPoint("LEFT", tex_Left, "RIGHT", 0, 0)



  -- Custom stuff for Extended QuestLogFrame
  _G.QUESTS_DISPLAYED = 23

  local QuestLogFrameExpandButton = CreateFrame("Button", "QuestLogFrameExpandButton", QuestLogFrame, "UIPanelButtonTemplate")
  SkinButton(QuestLogFrameExpandButton)
  QuestLogFrameExpandButton:SetWidth(77)
  QuestLogFrameExpandButton:SetHeight(21)
  QuestLogFrameExpandButton:SetText(">>>")
  QuestLogFrameExpandButton:SetPoint("BOTTOMRIGHT", QuestLogFrame, "BOTTOMRIGHT", -10, 10)
  QuestLogFrameExpandButton:SetScript("OnClick", function()
    if QuestLogDetailScrollFrame:IsShown() then
      QuestLogDetailScrollFrame:Hide()
      QuestLogDetailScrollFrame.hidden = true
      else
      QuestLogDetailScrollFrame:Show()
      QuestLogDetailScrollFrame.hidden = false
    end
  end)

  EmptyQuestLogFrame:SetScript("OnShow", function() QuestLogFrameExpandButton:Disable() end)
  EmptyQuestLogFrame:SetScript("OnHide", function() QuestLogFrameExpandButton:Enable() end)

  for i = 7, QUESTS_DISPLAYED do
    local b = CreateFrame("Button", "QuestLogTitle"..i, QuestLogFrame, "QuestLogTitleButtonTemplate")
    b:SetID(i)
    b:SetPoint("TOPLEFT", _G["QuestLogTitle"..(i-1)], "BOTTOMLEFT", 0, 1)
    SkinCollapseButton(_G["QuestLogTitle"..i])
  end

  QuestLogListScrollFrame:SetHeight(350)
  QuestLogDetailScrollFrame:ClearAllPoints()
  QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 30, 0)
  QuestLogDetailScrollFrame:SetHeight(350)
  QuestLogDetailScrollChildFrame:SetHeight(350)
  QuestLogDetailScrollFrame:SetScript("OnHide", function()
    QuestLogFrame:SetWidth(353)
    QuestLogFrameExpandButton:SetText(">>>")
  end)
  QuestLogDetailScrollFrame:SetScript("OnShow", function()
    QuestLogFrame:SetWidth(680)
    QuestLogFrameExpandButton:SetText("<<<")
    if QuestLogQuestTitle:GetText() == "Quest title" then
      QuestLog_UpdateQuestDetails()
    end
  end)


  local QuestLogFrameLevelsCheckButton = CreateFrame("CheckButton", "QuestLogFrameLevelsCheckButton", QuestLogFrame, "UICheckButtonTemplate")
  QuestLogFrameLevelsCheckButton:SetChecked(pfUI_config.questlog.showQuestLevels)
  QuestLogFrameLevelsCheckButton:SetPoint("BOTTOMLEFT", QuestLogCollapseAllButton, "TOPLEFT", 0, 10)
  QuestLogFrameLevelsCheckButton:SetScript("OnClick", function()
    pfUI_config.questlog.showQuestLevels = not pfUI_config.questlog.showQuestLevels
    QuestLog_Update()
  end)
  QuestLogFrameLevelsCheckButtonText:SetText(T["Show quest levels"])
  SkinCheckbox(QuestLogFrameLevelsCheckButton, 24)


  hooksecurefunc("QuestLog_Update", function()
    if QuestLogCollapseAllButton.collapsed or QuestLogDetailScrollFrame.hidden then
      QuestLogDetailScrollFrame:Hide()
    end

    if QuestLogFrameLevelsCheckButton:GetChecked() then
      local numEntries = GetNumQuestLogEntries()
      local questIndex, text, level, questTag, isHeader
      for i=1, QUESTS_DISPLAYED do
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

  QuestFrameExitButton:Hide()

  tex_Left:SetHeight(QuestLogDetailScrollFrame:GetHeight())
  tex_Right:SetHeight(QuestLogDetailScrollFrame:GetHeight())
end)
