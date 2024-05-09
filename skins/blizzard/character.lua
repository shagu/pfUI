pfUI:RegisterSkin("Character", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  -- Compatibility
  if PlayerTitleDropDown then -- tbc, wotlk
    -- Character Tab
    SkinDropDown(PlayerTitleDropDown)
    PlayerTitleDropDown:SetPoint("TOP", CharacterLevelText, "BOTTOM", 0, -2)
    PlayerTitleDropDownText:SetPoint("LEFT", PlayerTitleDropDown.backdrop, "LEFT", 6, 2)
    SkinDropDown(PlayerStatFrameLeftDropDown)
    SkinDropDown(PlayerStatFrameRightDropDown)

    -- Honor Tab
    StripTextures(PVPFrame)
  else -- vanilla
    -- Honor Tab
    StripTextures(HonorFrame)

    HonorFrameProgressBar:SetStatusBarTexture(pfUI.media["img:bar"])
    CreateBackdrop(HonorFrameProgressBar)
    HonorFrameProgressBar:SetHeight(24)
  end

  local magicResTextureCords = {
    {0.21875, 0.78125, 0.25, 0.3203125},
    {0.21875, 0.78125, 0.0234375, 0.09375},
    {0.21875, 0.78125, 0.13671875, 0.20703125},
    {0.21875, 0.78125, 0.36328125, 0.43359375},
    {0.21875, 0.78125, 0.4765625, 0.546875}
  }

  CreateBackdrop(CharacterFrame, nil, nil, .75)
  CreateBackdropShadow(CharacterFrame)

  CharacterFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
  CharacterFrame.backdrop:SetPoint("BOTTOMRIGHT", -30, 72)
  CharacterFrame:SetHitRectInsets(10,30,10,72)
  EnableMovable("CharacterFrame", nil, CHARACTERFRAME_SUBFRAMES)

  SkinCloseButton(CharacterFrameCloseButton, CharacterFrame.backdrop, -6, -6)

  CharacterFrame:DisableDrawLayer("ARTWORK")

  CharacterNameText:ClearAllPoints()
  CharacterNameText:SetPoint("TOP", CharacterFrame.backdrop, "TOP", 0, -10)

  CharacterFrameTab1:ClearAllPoints()
  CharacterFrameTab1:SetPoint("TOPLEFT", CharacterFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
  for i = 1, 5 do
    local tab = _G["CharacterFrameTab"..i]
    local lastTab = _G["CharacterFrameTab"..(i-1)]
    if lastTab and lastTab:IsShown() then
      tab:ClearAllPoints()
      tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
    end
    SkinTab(tab)
  end

  do -- Character Tab
    local slots = {
      "HeadSlot",
      "NeckSlot",
      "ShoulderSlot",
      "BackSlot",
      "ChestSlot",
      "ShirtSlot",
      "TabardSlot",
      "WristSlot",
      "HandsSlot",
      "WaistSlot",
      "LegsSlot",
      "FeetSlot",
      "Finger0Slot",
      "Finger1Slot",
      "Trinket0Slot",
      "Trinket1Slot",
      "MainHandSlot",
      "SecondaryHandSlot",
      "RangedSlot",
      "AmmoSlot"
    }

    local function RefreshPetPosition()
      CharacterFrameTab3:ClearAllPoints()
      CharacterFrameTab3:SetPoint("LEFT", HasPetUI() and CharacterFrameTab2 or CharacterFrameTab1, "RIGHT", border*2 + 1, 0)
    end

    local function RefreshCharacterSlot(slot)
      local slotId = slot:GetID()
      local link = GetInventoryItemLink("player", slotId)
      if slot and slot.backdrop then
        if link then
          local isBroken = GetInventoryItemBroken("player", slotId)
          local quality = GetInventoryItemQuality("player", slotId)
          if isBroken then
            slot.backdrop:SetBackdropBorderColor(0.9, 0, 0, 1)
          elseif quality and quality > 0 then
            local r, g, b = GetItemQualityColor(quality)
            slot.backdrop:SetBackdropBorderColor(r, g, b, 1)
          else
            slot.backdrop:SetBackdropBorderColor(pfUI.cache.er, pfUI.cache.eg, pfUI.cache.eb, pfUI.cache.ea)
          end
        else
          slot.backdrop:SetBackdropBorderColor(pfUI.cache.er, pfUI.cache.eg, pfUI.cache.eb, pfUI.cache.ea)
        end

        if ShaguScore and link then
          local _, _, itemID = string.find(GetInventoryItemLink("player", slotId), "item:(%d+):%d+:%d+:%d+")
          local itemLevel = ShaguScore.Database[tonumber(itemID)] or 0
          local _, _, quality, _, _, _, _, _, itemSlot, _ = GetItemInfo(itemID)
          local score = ShaguScore:Calculate(itemSlot, quality, itemLevel)
          if score and score > 0 and quality and quality > 0 then
            local r,g,b = GetItemQualityColor(quality)
            slot.scoreText:SetText(score)
            slot.scoreText:SetTextColor(r, g, b, 1)
          else
            slot.scoreText:SetText("")
            slot.scoreText:SetTextColor(1, 1, 1, 1)
          end
        else
          slot.scoreText:SetText("")
          slot.scoreText:SetTextColor(1, 1, 1, 1)
        end
      end
    end
    local function RefreshCharacterSlots()
      for _, slotName in pairs(slots) do
        local slot = _G["Character"..slotName]
        RefreshCharacterSlot(slot)
      end
    end

    HookScript(CharacterFrame, "OnShow", function()
      RefreshCharacterSlots()
      RefreshPetPosition()

      if not this.hooked then
        hooksecurefunc("PaperDollItemSlotButton_Update", function()
          -- update only character slots!
          if string.find(this:GetName(), "^Character.-Slot$") then
            RefreshCharacterSlot(this)
          end
        end)
        hooksecurefunc("PetTab_Update", RefreshPetPosition, 1)
        this.hooked = true
      end
    end)

    StripTextures(PaperDollFrame)
    StripTextures(CharacterAttributesFrame)
    StripTextures(CharacterResistanceFrame)

    EnableClickRotate(CharacterModelFrame)
    CharacterModelFrameRotateLeftButton:Hide()
    CharacterModelFrameRotateRightButton:Hide()

    for i,c in pairs(magicResTextureCords) do
      local magicResFrame = _G["MagicResFrame"..i]
      magicResFrame:SetWidth(26)
      magicResFrame:SetHeight(26)
      CreateBackdrop(magicResFrame)
      SetAllPointsOffset(magicResFrame.backdrop, magicResFrame, 2)
      local icon = GetNoNameObject(magicResFrame, "Texture", "BACKGROUND", "ResistanceIcons")
      SetAllPointsOffset(icon, magicResFrame, 3)
      icon:SetTexCoord(c[1], c[2], c[3], c[4])
    end

    for _, slotName in pairs(slots) do
      local frame = _G["Character"..slotName]
      StripTextures(frame)
      CreateBackdrop(frame)
      SetAllPointsOffset(frame.backdrop, frame, 0)

      HandleIcon(frame.backdrop, _G["Character"..slotName.."IconTexture"])

      if not frame.scoreText then
        frame.scoreText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.scoreText:SetFont(pfUI.font_default, 12, "OUTLINE")
        frame.scoreText:SetPoint("TOPRIGHT", 0, 0)
      end
    end
  end

  do -- Pet Tab
    StripTextures(PetPaperDollFrame)

    PetNameText:ClearAllPoints()
    PetNameText:SetPoint("TOP", CharacterFrame.backdrop, "TOP", 0, -10)

    EnableClickRotate(PetModelFrame)
    PetModelFrameRotateLeftButton:Hide()
    PetModelFrameRotateRightButton:Hide()

    PetPaperDollCloseButton:Hide()

    StripTextures(PetAttributesFrame)
    StripTextures(PetPaperDollFrameExpBar)
    CreateBackdrop(PetPaperDollFrameExpBar, nil, true)
    PetPaperDollFrameExpBar:SetStatusBarTexture(pfUI.media["img:bar"])
    PetPaperDollFrameExpBar:ClearAllPoints()
    PetPaperDollFrameExpBar:SetPoint("BOTTOM", PetModelFrame, "BOTTOM", 0, -120)

    PetTrainingPointLabel:ClearAllPoints()
    PetTrainingPointLabel:SetPoint("TOPLEFT", PetArmorFrame, "BOTTOMLEFT", 0, -16)

    PetTrainingPointText:ClearAllPoints()
    PetTrainingPointText:SetPoint("TOPRIGHT", PetArmorFrame, "BOTTOMRIGHT", 0, -16)

    PetPaperDollPetInfo:ClearAllPoints()
    PetPaperDollPetInfo:SetPoint("TOPLEFT", PetModelFrame, "TOPLEFT")
    PetPaperDollPetInfo:SetFrameLevel(255)

    PetResistanceFrame:ClearAllPoints()
    PetResistanceFrame:SetPoint("TOPRIGHT", PetModelFrame, "TOPRIGHT")

    for i,c in pairs(magicResTextureCords) do
      local magicResFrame = _G["PetMagicResFrame"..i]
      magicResFrame:SetWidth(26)
      magicResFrame:SetHeight(26)
      CreateBackdrop(magicResFrame)
      SetAllPointsOffset(magicResFrame.backdrop, magicResFrame, 2)
      local icon = GetNoNameObject(magicResFrame, "Texture", "BACKGROUND", "ResistanceIcons")
      SetAllPointsOffset(icon, magicResFrame, 3)
      icon:SetTexCoord(c[1], c[2], c[3], c[4])
    end
  end

  do -- Reputation Tab
    StripTextures(ReputationFrame)

    for i = 1, NUM_FACTIONS_DISPLAYED do
      local bar = _G["ReputationBar" .. i]
      StripTextures(bar)
      CreateBackdrop(bar)
      bar:SetStatusBarTexture(pfUI.media["img:bar"])

      local war = _G["ReputationBar"..i.."AtWarCheck"]
      StripTextures(war)
      war:SetWidth(13)
      war:SetHeight(13)
      war:ClearAllPoints()
      war:SetPoint("LEFT", bar.backdrop, "RIGHT", 6, 0)
      war.icon = war:CreateTexture(nil, "OVERLAY")
      war.icon:SetPoint("LEFT", -3, -8)
      war.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")

      SkinCollapseButton(_G["ReputationHeader"..i])
    end

    StripTextures(ReputationListScrollFrame)
    SkinScrollbar(ReputationListScrollFrameScrollBar)

    StripTextures(ReputationDetailFrame)
    CreateBackdrop(ReputationDetailFrame, nil, nil, .75)
    SkinCloseButton(ReputationDetailCloseButton, ReputationDetailFrame.backdrop, -6, -6)

    ReputationDetailFrame:ClearAllPoints()
    ReputationDetailFrame:SetPoint("TOPLEFT", CharacterFrame.backdrop, "TOPRIGHT", 2*border, 0)

    SkinCheckbox(ReputationDetailAtWarCheckBox)
    SkinCheckbox(ReputationDetailInactiveCheckBox)
    SkinCheckbox(ReputationDetailMainScreenCheckBox)
  end

  do -- Skills Tab
    StripTextures(SkillFrame)

    SkillFrameExpandButtonFrame:DisableDrawLayer("BACKGROUND")

    SkillFrameCancelButton:Hide()

    StripTextures(SkillFrameCollapseAllButton)
    SkinCollapseButton(SkillFrameCollapseAllButton, true)
    SkillFrameCollapseAllButton:ClearAllPoints()
    SkillFrameCollapseAllButton:SetPoint("BOTTOMLEFT", SkillTypeLabel1, "TOPLEFT", 2, 2)

    for i = 1, SKILLS_TO_DISPLAY do
      local header = _G["SkillTypeLabel"..i]
      StripTextures(header)
      SkinCollapseButton(header)

      StripTextures(_G["SkillRankFrame"..i.."Border"])

      local frame = _G["SkillRankFrame" .. i]
      local lastframe = _G["SkillRankFrame" .. i-1]
      StripTextures(frame)
      CreateBackdrop(frame)

      if lastframe then
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", lastframe, "BOTTOMLEFT", 0, -6)
      end
      frame:SetStatusBarTexture(pfUI.media["img:bar"])
      frame:SetHeight(12)
    end

    StripTextures(SkillListScrollFrame)
    SkinScrollbar(SkillListScrollFrameScrollBar)

    StripTextures(SkillDetailScrollFrame)
    SkillDetailScrollFrameScrollBar:Hide()
    SkillDetailScrollChildFrame:Hide()

    SkillDetailCostText:SetParent(SkillDetailScrollFrame)
    SkillDetailDescriptionText:SetParent(SkillDetailScrollFrame)

    StripTextures(SkillDetailStatusBar)
    CreateBackdrop(SkillDetailStatusBar)
    SkillDetailStatusBar:SetStatusBarTexture(pfUI.media["img:bar"])
    SkillDetailStatusBar:SetParent(SkillDetailScrollFrame)

    StripTextures(SkillDetailStatusBarUnlearnButton)
    SkillDetailStatusBarUnlearnButton:SetWidth(20)
    SkillDetailStatusBarUnlearnButton:SetHeight(20)
    SkillDetailStatusBarUnlearnButton:SetHitRectInsets(0,0,0,0)
    SkillDetailStatusBarUnlearnButton:ClearAllPoints()
    SkillDetailStatusBarUnlearnButton:SetPoint("LEFT", SkillDetailStatusBar, "RIGHT", 6, 0)
    SkillDetailStatusBarUnlearnButton:SetPushedTexture(nil)
    SkillDetailStatusBarUnlearnButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
  end
end)
