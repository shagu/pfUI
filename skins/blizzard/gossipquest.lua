pfUI:RegisterSkin("Gossip and Quest", function ()
  local frames = {'Quest', 'Gossip'}
  local panels = {'Greeting', 'Detail', 'Progress', 'Reward'}
  local buttons = {
    QuestFrameGreetingGoodbyeButton, GossipFrameGreetingGoodbyeButton,
    QuestFrameDeclineButton, QuestFrameAcceptButton,
    QuestFrameGoodbyeButton, QuestFrameCompleteButton,
    QuestFrameCancelButton, QuestFrameCompleteQuestButton
  }

  for _, button in pairs(buttons) do
    SkinButton(button)
  end

  for _, f in pairs(frames) do
    local frameName = f
    local frame = _G[frameName.."Frame"]
    local NPCName = _G[frame:GetName().."NpcNameText"]
    CreateBackdrop(frame, nil, nil, .75)
    frame.backdrop:SetPoint("TOPLEFT", 12, -18)
    frame.backdrop:SetPoint("BOTTOMRIGHT", -28, 66)
    frame:SetHitRectInsets(12,28,18,66)
    EnableMovable(frame)

    SkinCloseButton(_G[frame:GetName()..'CloseButton'], frame.backdrop, -6, -6)

    _G[frame:GetName()..'Portrait']:Hide()

    NPCName:ClearAllPoints()
    NPCName:SetPoint("TOP", frame.backdrop, "TOP", 0, -10)

    for _, v in pairs(panels) do
      local panel = v
      if frameName == 'Gossip' and panel ~= 'Greeting' then break end

      StripTextures(_G[frame:GetName()..panel.."Panel"])

      local texture = "StationeryTest"
      if date("%m%d") == "0223" then texture = "Stationery_Val" end
      local tex_Left = frame:CreateTexture("BACKGROUND")
      tex_Left:SetTexture("Interface\\Stationery\\"..texture.."1")
      tex_Left:SetPoint("TOPLEFT", 23, -81)
      tex_Left:SetHeight(330)
      local tex_Right = frame:CreateTexture("BACKGROUND")
      tex_Right:SetTexture("Interface\\Stationery\\"..texture.."2")
      tex_Right:SetPoint("LEFT", tex_Left, "RIGHT", 0, 0)
      tex_Right:SetHeight(330)

      local scroll = _G[frameName..panel.."ScrollFrame"]
      scroll:SetHeight(330)
      SkinScrollbar(_G[scroll:GetName().."ScrollBar"])

      if panel ~= 'Greeting' then
        local num_items, hook_func
        if panel == 'Progress' then
          num_items = MAX_REQUIRED_ITEMS
          hook_func = "QuestFrameProgressItems_Update"
          else
          num_items = MAX_NUM_ITEMS
          hook_func = "QuestFrameItems_Update"
        end

        for i = 1, num_items do
          local button = _G[frameName..panel.."Item"..i]
          StripTextures(button)
          CreateBackdrop(button, nil, true, .5)

          local itemButton = CreateFrame("Button", button:GetName().."ItemButton", button)
          itemButton:SetWidth(37)
          itemButton:SetHeight(37)
          itemButton:SetPoint("LEFT", 2, 0)
          itemButton.icon = itemButton:CreateTexture("ARTWORK")
          SkinButton(itemButton, nil, nil, nil, itemButton.icon, true)
          itemButton.text = itemButton:CreateFontString("Status", "LOW", "GameFontNormal")
          itemButton.text:SetFontObject(GameFontWhite)
          itemButton.text:SetPoint("BOTTOMRIGHT", -4, 1)
          itemButton.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
        end

        hooksecurefunc(hook_func, function()
          for i = 1, num_items do
            local button = _G[frameName..panel.."Item"..i]
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
      end
    end
  end
end)
