pfUI:RegisterSkin("Character", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  local magicResTextureCords = {
    {0.21875, 0.78125, 0.25, 0.3203125},
    {0.21875, 0.78125, 0.0234375, 0.09375},
    {0.21875, 0.78125, 0.13671875, 0.20703125},
    {0.21875, 0.78125, 0.36328125, 0.43359375},
    {0.21875, 0.78125, 0.4765625, 0.546875}
  }

  do -- character frame
    local CharacterFrame = _G["PaperDollFrame"]
    StripTextures(CharacterFrame)
    CreateBackdrop(CharacterFrame, nil, nil, .75)
    CharacterFrame.backdrop:SetPoint("TOPLEFT", 10, -12)
    CharacterFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 76)
    SkinCloseButton(CharacterFrameCloseButton, CharacterFrame, -37, -17)

    CharacterFramePortrait:Hide()
    CharacterNameFrame:SetPoint("TOP", -10, -20)

    StripTextures(CharacterAttributesFrame)
    StripTextures(CharacterResistanceFrame)

    CharacterModelFrameRotateLeftButton:Hide()
    CharacterModelFrameRotateRightButton:Hide()
    EnableClickRotate(CharacterModelFrame)

    for i,c in pairs(magicResTextureCords) do
      local magicResFrame = _G["MagicResFrame"..i]
      magicResFrame:SetWidth(26)
      magicResFrame:SetHeight(26)
      CreateBackdrop(magicResFrame)
      SetAllPointsOffset(magicResFrame.backdrop, magicResFrame, 2)

      for k,f in pairs({magicResFrame:GetRegions()}) do
        if f:GetObjectType() == "Texture" then
          f:SetTexCoord(c[1], c[2], c[3], c[4])
          SetAllPointsOffset(f, magicResFrame, 3)
        end
      end
    end

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

    for i, slot in pairs(slots) do
      local slotId, _, _ = GetInventorySlotInfo(slot)
      local quality = GetInventoryItemQuality("player", slotId)

      local frame = _G["Character"..slot]
      local texture = _G["Character"..slot.."IconTexture"]
      texture:SetTexCoord(.08, .92, .08, .92)
      texture:ClearAllPoints()
      texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
      texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)

      StripTextures(frame)
      CreateBackdrop(frame)

      frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
      frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)

      if not frame.scoreText then
        frame.scoreText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.scoreText:SetFont(pfUI.font_default, 12, "OUTLINE")
        frame.scoreText:SetPoint("BOTTOMRIGHT", 0, 0)
      end

      if true == false and i ~= 1 and i ~= 9 and i ~= 17 then
        local isBottomSlots = i > 17
        local lastSlot = slots[i-1]
        lastSlot = _G["Character"..lastSlot]
        slot:ClearAllPoints()

        if isBottomSlots then
          slot:SetPoint("LEFT", lastSlot, "RIGHT", 8, 0)
        else
          slot:SetPoint("TOP", lastSlot, "BOTTOM", 0, -7)
        end
      end
    end

    hooksecurefunc("PaperDollItemSlotButton_Update", function()
      for i, slot in pairs(slots) do
        local slotId, _, _ = GetInventorySlotInfo(slot)
        local quality = GetInventoryItemQuality("player", slotId)
        slot = _G["Character"..slot]

        if slot and slot.backdrop then
          if quality and quality > 0 then
            slot.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
          else
            slot.backdrop:SetBackdropBorderColor(pfUI.cache.er, pfUI.cache.eg, pfUI.cache.eb, pfUI.cache.ea)
          end

          if ShaguScore and GetInventoryItemLink("player", slotId) and slot.scoreText then
            local _, _, itemID = string.find(GetInventoryItemLink("player", slotId), "item:(%d+):%d+:%d+:%d+")
            local itemLevel = ShaguScore.Database[tonumber(itemID)] or 0
            local _, _, itemRarity, _, _, _, _, itemSlot, _ = GetItemInfo(itemID)
            local r,g,b = GetItemQualityColor((itemRarity or 1))
            local score = ShaguScore:Calculate(itemSlot, itemRarity, itemLevel)
            if score and score > 0  then
              if quality and quality > 0 then
                slot.scoreText:SetText(score)
                slot.scoreText:SetTextColor(r, g, b, 1)
              else
                slot.scoreText:SetText("")
              end
            else
              if slot.scoreText then slot.scoreText:SetText("") end
            end
          else
            if slot.scoreText then slot.scoreText:SetText("") end
          end
        end
      end
    end)
  end

  do -- pet frame
    CreateBackdrop(PetPaperDollFrame, nil, nil, .75)

    PetPaperDollFrame.backdrop:SetPoint("TOPLEFT", 10, -12)
    PetPaperDollFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 76)
    StripTextures(PetPaperDollFrame)
    StripTextures(PetAttributesFrame)
    StripTextures(PetPaperDollFrameExpBar)
    CreateBackdrop(PetPaperDollFrameExpBar)
    PetPaperDollFrameExpBar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    PetPaperDollFrameExpBar:ClearAllPoints()
    PetPaperDollFrameExpBar:SetPoint("BOTTOM", PetModelFrame, "BOTTOM", 0, -120)

    PetPaperDollCloseButton:Hide()
    PetModelFrameRotateLeftButton:Hide()
    PetModelFrameRotateRightButton:Hide()
    EnableClickRotate(PetModelFrame)

    PetTrainingPointText:ClearAllPoints()
    PetTrainingPointText:SetJustifyH("RIGHT")
    PetTrainingPointText:SetPoint("TOPRIGHT", PetArmorFrame, "BOTTOMRIGHT", 0, -16)

    PetTrainingPointLabel:ClearAllPoints()
    PetTrainingPointLabel:SetJustifyH("LEFT")
    PetTrainingPointLabel:SetPoint("TOPLEFT", PetArmorFrame, "BOTTOMLEFT", 0, -16)

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

      for k,f in pairs({magicResFrame:GetRegions()}) do
        if f:GetObjectType() == "Texture" then
          f:SetTexCoord(c[1], c[2], c[3], c[4])
          SetAllPointsOffset(f, magicResFrame, 3)
        end
      end
    end
  end

  do -- reputation frame
    CreateBackdrop(ReputationFrame, nil, nil, .75)
    ReputationFrame.backdrop:SetPoint("TOPLEFT", 10, -12)
    ReputationFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 76)
    StripTextures(ReputationFrame)

    for i = 1, NUM_FACTIONS_DISPLAYED do
      local frame = _G["ReputationBar" .. i]
      local header = _G["ReputationHeader"..i]
      local name = _G["ReputationBar"..i.."FactionName"]
      local war = _G["ReputationBar"..i.."AtWarCheck"]

      StripTextures(frame)
      CreateBackdrop(frame)
      frame:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")

      StripTextures(war)
      war:SetPoint("LEFT", frame, "RIGHT", 0, 0)
      war.icon = war:CreateTexture(nil, "OVERLAY")
      war.icon:SetPoint("LEFT", 6, -8)
      war.icon:SetWidth(32)
      war.icon:SetHeight(32)
      war.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")

      StripTextures(header)
      header:SetNormalTexture(nil)
      header.SetNormalTexture = function() return end

      header:SetPoint("TOPLEFT", frame, "TOPLEFT", -125, 0)
      header.text = header:CreateFontString(nil, "OVERLAY")
      header.text:SetFontObject(GameFontWhite)
      header.text:SetJustifyH("CENTER")
      header.text:SetJustifyV("CENTER")
      header.text:SetPoint("LEFT", 0, 0)
      header.text:SetWidth(12)
      header.text:SetHeight(12)

      header.SetNormalTexture = function(self, tex)
        self.text:SetText(strfind(tex, "MinusButton") and "-" or "+")
      end

      header.backdrop = CreateFrame("Frame", nil, header)
      header.backdrop:SetAllPoints(header.text)
      CreateBackdrop(header.backdrop)
    end

    StripTextures(ReputationListScrollFrame)
    SkinScrollbar(ReputationListScrollFrameScrollBar)

    ReputationDetailFrame:ClearAllPoints()
    ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", -26, -28)
    CreateBackdrop(ReputationDetailFrame)
    StripTextures(ReputationDetailFrame)
    SkinCloseButton(ReputationDetailCloseButton, ReputationDetailFrame, -3, -3)

    SkinCheckbox(ReputationDetailAtWarCheckBox)
    local texWar = ReputationDetailAtWarCheckBox:GetCheckedTexture()
    texWar:SetWidth(20)
    texWar:SetHeight(20)
    SkinCheckbox(ReputationDetailInactiveCheckBox)
    SkinCheckbox(ReputationDetailMainScreenCheckBox)
  end

  do -- skills frame
    StripTextures(SkillFrame)
    CreateBackdrop(SkillFrame, nil, nil, .75)
    SkillFrame.backdrop:SetPoint("TOPLEFT", 10, -12)
    SkillFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 76)
    SkillFrameCancelButton:Hide()

    SkillFrameExpandButtonFrame:DisableDrawLayer("BACKGROUND")
    StripTextures(SkillFrameCollapseAllButton)
    SkillFrameCollapseAllButton:SetNormalTexture(nil)
    SkillFrameCollapseAllButton.SetNormalTexture = function(self, tex)
      self.text:SetText(strfind(tex, "MinusButton") and "-" or "+")
    end

    SkillFrameCollapseAllButton:SetPoint("LEFT", SkillFrameExpandButtonFrame, "LEFT", -50, 5)
    SkillFrameCollapseAllButton.text = SkillFrameCollapseAllButton:CreateFontString(nil, "OVERLAY")
    SkillFrameCollapseAllButton.text:SetFontObject(GameFontWhite)
    SkillFrameCollapseAllButton.text:SetJustifyH("CENTER")
    SkillFrameCollapseAllButton.text:SetJustifyV("CENTER")
    SkillFrameCollapseAllButton.text:SetPoint("LEFT", 0, 0)
    SkillFrameCollapseAllButton.text:SetWidth(14)
    SkillFrameCollapseAllButton.text:SetHeight(14)
    SkillFrameCollapseAllButton.backdrop = CreateFrame("Frame", nil, SkillFrameCollapseAllButton)
    SkillFrameCollapseAllButton.backdrop:SetAllPoints(SkillFrameCollapseAllButton.text)
    CreateBackdrop(SkillFrameCollapseAllButton.backdrop)

    for i = 1, SKILLS_TO_DISPLAY do
      local lastframe = _G["SkillRankFrame" .. i-1]
      local frame = _G["SkillRankFrame" .. i]
      local border = _G["SkillRankFrame"..i.."Border"]
      local header = _G["SkillTypeLabel"..i]

      StripTextures(border)
      StripTextures(header)
      StripTextures(frame)

      frame:SetHeight(12)

      if lastframe then
        frame:SetPoint("TOPLEFT", lastframe, "BOTTOMLEFT", 0, -6)
      end

      CreateBackdrop(frame)
      frame:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
      StripTextures(border)
      StripTextures(header)
      header:SetNormalTexture(nil)
      header:SetPoint("TOPLEFT", frame, "TOPLEFT", -18, 0)
      header.text = header:CreateFontString(nil, "OVERLAY")
      header.text:SetFontObject(GameFontWhite)
      header.text:SetJustifyH("CENTER")
      header.text:SetJustifyV("CENTER")
      header.text:SetPoint("LEFT", 0, 0)
      header.text:SetWidth(10)
      header.text:SetHeight(10)

      header.SetNormalTexture = function(self, tex)
        self.text:SetText(strfind(tex, "MinusButton") and "-" or "+")
      end

      header.backdrop = CreateFrame("Frame", nil, header)

      header.backdrop:SetAllPoints(header.text)
      CreateBackdrop(header.backdrop)

      StripTextures(SkillListScrollFrame)
      SkinScrollbar(SkillListScrollFrameScrollBar)

      StripTextures(SkillDetailScrollFrame)
      SkinScrollbar(SkillDetailScrollFrameScrollBar)
      CreateBackdrop(SkillDetailScrollFrame)
      SkillDetailScrollFrame:SetPoint("TOPLEFT", SkillListScrollFrame, "BOTTOMLEFT", 0, -10)
      SkillDetailScrollFrame:SetPoint("BOTTOMRIGHT", SkillFrame, "BOTTOMRIGHT", -45, 90)

      SkillDetailScrollFrameScrollBar:SetPoint("TOPRIGHT", SkillDetailScrollFrame, "TOPRIGHT", -22, 0)
      SkillDetailScrollFrameScrollBar:SetPoint("BOTTOMRIGHT", SkillDetailScrollFrame, "BOTTOMRIGHT", -22, 0)

      StripTextures(SkillDetailStatusBar)
      CreateBackdrop(SkillDetailStatusBar)
      SkillDetailStatusBar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
      SkillDetailStatusBar:SetParent(SkillDetailScrollFrame)
      SkillDetailStatusBar:SetFrameLevel(128)

      SkillDetailStatusBar:ClearAllPoints()
      SkillDetailStatusBar:SetPoint("TOPLEFT", SkillDetailScrollFrame, "TOPLEFT", 10, -10)
      SkillDetailStatusBar:SetPoint("TOPRIGHT", SkillDetailScrollFrame, "TOPRIGHT", -30, -40)


      StripTextures(SkillDetailStatusBarUnlearnButton)
      SkillDetailStatusBarUnlearnButton:SetPoint("LEFT", SkillDetailStatusBar, "RIGHT", -2, -5)
      SkillDetailStatusBarUnlearnButton:SetWidth(32)
      SkillDetailStatusBarUnlearnButton:SetHeight(32)

      SkillDetailStatusBarUnlearnButton.icon = SkillDetailStatusBarUnlearnButton:CreateTexture(nil, "ARTWORK")
      SkillDetailStatusBarUnlearnButton.icon:SetPoint("LEFT", 7, 5)
      SkillDetailStatusBarUnlearnButton.icon:SetWidth(16)
      SkillDetailStatusBarUnlearnButton.icon:SetHeight(16)
      SkillDetailStatusBarUnlearnButton.icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    end
  end

  do -- honor tab
    CreateBackdrop(HonorFrame, nil, nil, .75)
    HonorFrame.backdrop:SetPoint("TOPLEFT", 10, -12)
    HonorFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 76)
    StripTextures(HonorFrame)

    HonorFrameProgressBar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    CreateBackdrop(HonorFrameProgressBar)
    HonorFrameProgressBar:SetHeight(24)
  end

  do -- tabs
    local CharacterFrame = _G["PaperDollFrame"]

    hooksecurefunc("PetTab_Update", function()
      CharacterFrameTab1:SetPoint("TOPLEFT", CharacterFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))

      for i=1, 5 do
        local tab = _G["CharacterFrameTab"..i]
        SkinTab(tab)
        tab.backdrop:SetFrameLevel(1)

        if i ~= 1 then
          local lastTab = _G["CharacterFrameTab"..(i-1)]
          if i == 3 and not HasPetUI() then
            lastTab = _G["CharacterFrameTab"..(i-2)]
          end

          tab:ClearAllPoints()
          tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
        end
      end
    end, true)
  end
end)
