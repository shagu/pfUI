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

  do -- quest gossip
    StripTextures(QuestGreetingScrollChildFrame)

    QuestTitleText:SetPoint("TOPLEFT", 10, -10)
    QuestProgressTitleText:SetPoint("TOPLEFT", 10, -10)

    for _, name in pairs({ "QuestProgressItem", "QuestDetailItem" }) do
      for i = 1, 6 do
        local item = _G[name..i]
        local icon = _G[name..i.."IconTexture"]
        local count = _G[name..i.."Count"]
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
    end
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

      local scroll = _G[frameName..panel.."ScrollFrame"]
      scroll:SetHeight(330)
      SkinScrollbar(_G[scroll:GetName().."ScrollBar"])
      CreateBackdrop(scroll, nil, true, .75)

      local bg = scroll:CreateTexture(nil, "LOW")
      bg:SetAllPoints()
      bg:SetTexCoord(.1,1,0,1)
      bg:SetTexture("Interface\\Stationery\\StationeryTest1")

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
        end

      end
    end
  end
end)
