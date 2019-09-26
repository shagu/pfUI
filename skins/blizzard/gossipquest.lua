pfUI:RegisterSkin("Gossip and Quest", "vanilla:tbc", function ()
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

    StripTextures(QuestRewardItemHighlight)
    local QuestRewardItemHighlight = CreateFrame("Frame", nil, QuestRewardScrollChildFrame)
    local QuestRewardItemHighlightBG = QuestRewardItemHighlight:CreateTexture(nil, "OVERLAY")
    QuestRewardItemHighlightBG:SetTexture(1,1,1,.2)
    QuestRewardItemHighlightBG:SetAllPoints()

    hooksecurefunc("QuestFrameItems_Update", function()
      QuestRewardItemHighlight:Hide()
    end)

    hooksecurefunc("QuestRewardItem_OnClick", function()
      if this.type == "choice" then
        QuestRewardItemHighlight:SetAllPoints(this.backdrop)
        QuestRewardItemHighlight:Show()
      end
    end)

    for _, name in pairs({ "QuestProgressItem", "QuestDetailItem", "QuestRewardItem" }) do
      for i = 1, 6 do
        local name = name .. i
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
  end

  for _, f in pairs(frames) do
    local frameName = f
    local frame = _G[frameName.."Frame"]
    local NPCName = _G[frame:GetName().."NpcNameText"]
    CreateBackdrop(frame, nil, nil, .75)
    CreateBackdropShadow(frame)

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

      local fname = frame:GetName()..panel.."Panel"
      StripTextures(_G[fname])

      local scroll = _G[frameName..panel.."ScrollFrame"]
      scroll:SetHeight(330)
      SkinScrollbar(_G[scroll:GetName().."ScrollBar"])
      CreateBackdrop(scroll, nil, true, .75)

      local bg = scroll:CreateTexture(nil, "LOW")
      bg:SetAllPoints()
      bg:SetTexCoord(.1,1,0,1)
      bg:SetTexture("Interface\\Stationery\\StationeryTest1")

      -- assign material backgrounds to the default one
      _G[fname.."MaterialTopLeft"].SetTexture = function(self, texture)
        bg:SetTexture(texture)
      end

      _G[fname.."MaterialTopLeft"].Hide = function()
        bg:SetTexture("Interface\\Stationery\\StationeryTest1")
      end

      -- disable meterial backgrounds
      _G[fname.."MaterialTopLeft"].Show = function() return end
      _G[fname.."MaterialTopRight"].Show = function() return end
      _G[fname.."MaterialBotLeft"].Show = function() return end
      _G[fname.."MaterialBotRight"].Show = function() return end
      _G[fname.."MaterialTopLeft"]:Hide()
      _G[fname.."MaterialTopRight"]:Hide()
      _G[fname.."MaterialBotLeft"]:Hide()
      _G[fname.."MaterialBotRight"]:Hide()

      if panel ~= 'Greeting' then
        local num_items, hook_func
        if panel == 'Progress' then
          num_items = MAX_REQUIRED_ITEMS
          hook_func = "QuestFrameProgressItems_Update"
          else
          num_items = MAX_NUM_ITEMS
          hook_func = "QuestFrameItems_Update"
        end
      end
    end
  end
end)
