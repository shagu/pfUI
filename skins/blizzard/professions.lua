pfUI:RegisterSkin("Profession Frames", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  HookAddonOrVariable("Blizzard_TradeSkillUI", function()
    StripTextures(TradeSkillFrame)
    CreateBackdrop(TradeSkillFrame, nil, nil, .75)
    TradeSkillFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
    TradeSkillFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
    TradeSkillFrame:SetHitRectInsets(10,32,10,72)
    EnableMovable(TradeSkillFrame)

    SkinCloseButton(TradeSkillFrameCloseButton, TradeSkillFrame.backdrop, -6, -6)

    TradeSkillFrame:DisableDrawLayer("BACKGROUND")

    TradeSkillFrameTitleText:ClearAllPoints()
    TradeSkillFrameTitleText:SetPoint("TOP", TradeSkillFrame.backdrop, "TOP", 0, -10)

    StripTextures(TradeSkillRankFrameBorder)
    CreateBackdrop(TradeSkillRankFrame, nil, true)
    TradeSkillRankFrame:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    TradeSkillRankFrame:ClearAllPoints()
    TradeSkillRankFrame:SetPoint("TOP", TradeSkillFrame.backdrop, "TOP", 0, -32)

    StripTextures(TradeSkillInvSlotDropDown)
    SkinDropDown(TradeSkillInvSlotDropDown)
    StripTextures(TradeSkillSubClassDropDown)
    SkinDropDown(TradeSkillSubClassDropDown)
    TradeSkillSubClassDropDown:ClearAllPoints()
    TradeSkillSubClassDropDown:SetPoint("RIGHT", TradeSkillInvSlotDropDown, "LEFT", 27, 0)

    StripTextures(TradeSkillDetailScrollFrame)
    StripTextures(TradeSkillDetailScrollChildFrame)
    SkinScrollbar(TradeSkillDetailScrollFrameScrollBar)

    StripTextures(TradeSkillListScrollFrame)
    SkinScrollbar(TradeSkillListScrollFrameScrollBar)

    SkinArrowButton(TradeSkillDecrementButton, "left", 18)
    SkinArrowButton(TradeSkillIncrementButton, "right", 18)

    TradeSkillInputBox:DisableDrawLayer("BACKGROUND")
    CreateBackdrop(TradeSkillInputBox, nil, true)
    TradeSkillInputBox:SetWidth(36)

    SkinButton(TradeSkillCreateAllButton)
    SkinButton(TradeSkillCancelButton)
    SkinButton(TradeSkillCreateButton)
    TradeSkillCreateButton:ClearAllPoints()
    TradeSkillCreateButton:SetPoint("RIGHT", TradeSkillCancelButton, "LEFT", -2*bpad, 0)

    StripTextures(TradeSkillExpandButtonFrame)
    StripTextures(TradeSkillCollapseAllButton)
    SkinCollapseButton(TradeSkillCollapseAllButton, true)
    for i = 1, TRADE_SKILLS_DISPLAYED do
      SkinCollapseButton(_G["TradeSkillSkill"..i])
    end

    for i = 1, MAX_TRADE_SKILL_REAGENTS do
      local button = _G["TradeSkillReagent"..i]
      StripTextures(button)
      SkinButton(button, nil, nil, nil, nil, true)

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

    StripTextures(TradeSkillSkillIcon)
    SkinButton(TradeSkillSkillIcon, nil, nil, nil, nil, true)

    hooksecurefunc("TradeSkillFrame_SetSelection", function()
      HandleIcon(TradeSkillSkillIcon, TradeSkillSkillIcon:GetNormalTexture())

      for i = 1, MAX_TRADE_SKILL_REAGENTS do
        local button = _G["TradeSkillReagent"..i]
        if button:IsShown() then
          local count = _G[button:GetName().."Count"]:GetText()
          local texture = _G[button:GetName().."IconTexture"]:GetTexture()
          local itemButton = _G[button:GetName().."ItemButton"]

          itemButton.icon:SetTexture(texture)
          itemButton.text:SetText(count)
        end
      end
    end, 1)
  end)

  HookAddonOrVariable("Blizzard_CraftUI", function()
    StripTextures(CraftFrame)
    CreateBackdrop(CraftFrame, nil, nil, .75)
    CraftFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
    CraftFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
    CraftFrame:SetHitRectInsets(10,32,10,72)
    EnableMovable(CraftFrame)

    SkinCloseButton(CraftFrameCloseButton, CraftFrame.backdrop, -6, -6)

    CraftFrame:DisableDrawLayer("BACKGROUND")

    CraftFrameTitleText:ClearAllPoints()
    CraftFrameTitleText:SetPoint("TOP", CraftFrame.backdrop, "TOP", 0, -10)

    StripTextures(CraftRankFrameBorder)
    CreateBackdrop(CraftRankFrame, nil, true)
    CraftRankFrame:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    CraftRankFrame:ClearAllPoints()
    CraftRankFrame:SetPoint("TOP", CraftFrame.backdrop, "TOP", 0, -32)

    StripTextures(CraftDetailScrollFrame)
    StripTextures(CraftDetailScrollChildFrame)
    SkinScrollbar(CraftDetailScrollFrameScrollBar)

    StripTextures(CraftListScrollFrame)
    SkinScrollbar(CraftListScrollFrameScrollBar)
    SkinButton(CraftCancelButton)
    SkinButton(CraftCreateButton)
    CraftCreateButton:ClearAllPoints()
    CraftCreateButton:SetPoint("RIGHT", CraftCancelButton, "LEFT", -2*bpad, 0)

    for i = 1, MAX_CRAFT_REAGENTS do
      local button = _G["CraftReagent"..i]
      StripTextures(button)
      SkinButton(button, nil, nil, nil, nil, true)

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

    StripTextures(CraftIcon)
    SkinButton(CraftIcon, nil, nil, nil, nil, true)

    hooksecurefunc("CraftFrame_SetSelection", function(id)
      HandleIcon(CraftIcon, CraftIcon:GetNormalTexture())

      for i = 1, MAX_CRAFT_REAGENTS do
        local button = _G["CraftReagent"..i]
        if button:IsShown() then
          local count = _G[button:GetName().."Count"]:GetText()
          local texture = _G[button:GetName().."IconTexture"]:GetTexture()
          local itemButton = _G[button:GetName().."ItemButton"]

          itemButton.icon:SetTexture(texture)
          itemButton.text:SetText(count)
        end
      end

      -- fix Blizzard bug
      if GetCraftNumReagents(id) < 3 and CraftDetailScrollFrameScrollBar:IsShown() then
        CraftDetailScrollFrameScrollBar:Hide()
      end
    end, 1)
  end)
end)
