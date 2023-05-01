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
}

pfUI:RegisterSkin("Inspect", "tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  HookAddonOrVariable("Blizzard_InspectUI", function()
    CreateBackdrop(InspectFrame, nil, nil, .75)
    CreateBackdropShadow(InspectFrame)

    InspectFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
    InspectFrame.backdrop:SetPoint("BOTTOMRIGHT", -30, 72)
    InspectFrame:SetHitRectInsets(10,30,10,72)
    EnableMovable("InspectFrame", "Blizzard_InspectUI", INSPECTFRAME_SUBFRAMES)

    SkinCloseButton(InspectFrameCloseButton, InspectFrame.backdrop, -6, -6)

    InspectFrame:DisableDrawLayer("ARTWORK")

    InspectNameText:ClearAllPoints()
    InspectNameText:SetPoint("TOP", InspectFrame.backdrop, "TOP", 0, -10)
    InspectGuildText:Show()
    InspectGuildText:ClearAllPoints()
    InspectGuildText:SetPoint("TOP", InspectLevelText, "BOTTOM", 0, -1)

    for i = 1, 3 do
      local tab = _G["InspectFrameTab"..i]
      local lastTab = _G["InspectFrameTab"..(i-1)]
      tab:ClearAllPoints()
      if lastTab then
        tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
    else
        tab:SetPoint("TOPLEFT", InspectFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
      end
      SkinTab(tab)
    end

    do -- Character Tab
      StripTextures(InspectPaperDollFrame)

      EnableClickRotate(InspectModelFrame)
      InspectModelRotateLeftButton:Hide()
      InspectModelRotateRightButton:Hide()

      for _, slot in pairs(slots) do
        local frame = _G["Inspect"..slot]
        SkinButton(frame, nil, nil, nil, _G["Inspect"..slot.."IconTexture"], true)
      end

      hooksecurefunc("InspectPaperDollFrame_OnShow", function()
        local guild, title = GetGuildInfo(InspectFrame.unit)
        local text = guild and format(TEXT(GUILD_TITLE_TEMPLATE), title, guild) or ""
        InspectGuildText:SetText(text)
      end)

      hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
        local unit = InspectFrame.unit
        local link = GetInventoryItemLink(unit, button:GetID())
        if link then
          local quality = select(3, GetItemInfo(link))
          button:SetBackdropBorderColor(GetItemQualityColor(quality))
        else
          button:SetBackdropBorderColor(pfUI.cache.er, pfUI.cache.eg, pfUI.cache.eb, pfUI.cache.ea)
        end
      end)
    end

    do -- PVP Tab
      StripTextures(InspectPVPFrame)
    end

    do -- Talent Tab
      StripTextures(InspectTalentFrame)
      InspectTalentFrameCancelButton:Hide()
      InspectTalentFrameCloseButton:Hide()

      InspectTalentFrameSpentPoints:ClearAllPoints()
      InspectTalentFrameSpentPoints:SetPoint("BOTTOMRIGHT", InspectTalentFrame, "BOTTOMRIGHT", 0, 83)

      StripTextures(InspectTalentFrameScrollFrame)
      SkinScrollbar(InspectTalentFrameScrollFrameScrollBar)

      for i = 1, MAX_NUM_TALENTS do
        local talent = _G["InspectTalentFrameTalent"..i]
        if talent then
          StripTextures(talent)
          SkinButton(talent, nil, nil, nil, _G["InspectTalentFrameTalent"..i.."IconTexture"])

          _G["InspectTalentFrameTalent"..i.."Rank"]:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
        end
      end

      for i = 1, 3 do
        local tab = _G["InspectTalentFrameTab"..i]
        local lastTab = _G["InspectTalentFrameTab"..(i-1)]
        tab:ClearAllPoints()
        if lastTab then
          tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
        else
          tab:SetPoint("TOPLEFT", 70, -50)
        end
        SkinTab(tab)
      end
    end
  end)
end)

pfUI:RegisterSkin("Inspect", "vanilla", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  HookAddonOrVariable("Blizzard_InspectUI", function()
    local cache = {}

    CreateBackdrop(InspectFrame, nil, nil, .75)
    CreateBackdropShadow(InspectFrame)

    InspectFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
    InspectFrame.backdrop:SetPoint("BOTTOMRIGHT", -30, 72)
    InspectFrame:SetHitRectInsets(10,30,10,72)
    EnableMovable("InspectFrame", "Blizzard_InspectUI", INSPECTFRAME_SUBFRAMES)

    SkinCloseButton(InspectFrameCloseButton, InspectFrame.backdrop, -6, -6)

    InspectFrame:DisableDrawLayer("ARTWORK")

    InspectNameText:ClearAllPoints()
    InspectNameText:SetPoint("TOP", InspectFrame.backdrop, "TOP", 0, -10)

    SkinTab(InspectFrameTab1)
    InspectFrameTab1:ClearAllPoints()
    InspectFrameTab1:SetPoint("TOPLEFT", InspectFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
    SkinTab(InspectFrameTab2)
    InspectFrameTab2:ClearAllPoints()
    InspectFrameTab2:SetPoint("LEFT", InspectFrameTab1, "RIGHT", border*2 + 1, 0)

    do -- Character Tab
      StripTextures(InspectPaperDollFrame)

      EnableClickRotate(InspectModelFrame)
      InspectModelRotateLeftButton:Hide()
      InspectModelRotateRightButton:Hide()

      for _, slot in pairs(slots) do
        local frame = _G["Inspect"..slot]
        StripTextures(frame)
        CreateBackdrop(frame)
        SetAllPointsOffset(frame.backdrop, frame, 0)

        HandleIcon(frame.backdrop, _G["Inspect"..slot.."IconTexture"])

        local funce = frame:GetScript("OnEnter")
        frame:SetScript("OnEnter", function()
          local bid = this:GetID()
          if not GetInventoryItemLink(InspectFrame.unit, this:GetID()) and this.hasItem then
            GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
            GameTooltip:SetHyperlink("item:"..cache[bid]["id"])
            GameTooltip:Show()
          else
            funce()
          end
        end)
      end

      local function UpdateSlots()
        if not InspectFrame.unit then return end

        local guild, title, rank = GetGuildInfo(InspectFrame.unit)
        if guild then
          InspectGuildText:SetPoint("TOP", InspectLevelText, "BOTTOM", 0, -1)
          InspectGuildText:SetText(format(TEXT(GUILD_TITLE_TEMPLATE), title, guild))
          InspectGuildText:Show()
        else
          InspectGuildText:SetText("")
          InspectGuildText:Hide()
        end

        for i, vslot in pairs(slots) do
          local id = GetInventorySlotInfo(vslot)
          local link = GetInventoryItemLink(InspectFrame.unit, id)
          local slot = _G["Inspect" .. vslot]
          local retry = false

          if link and slot.hasItem then
            local _, _, link = string.find(link, "(item:%d+:%d+:%d+:%d+)")
            local _, _, quality = GetItemInfo(link)

            if not quality then
              retry = true
            else
              slot.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))

              if ShaguScore then
                if not slot.scoreText then
                  slot.scoreText = slot:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                  slot.scoreText:SetFont(pfUI.font_default, 12, "OUTLINE")
                  slot.scoreText:SetPoint("TOPRIGHT", 0, 0)
                end

                local r,g,b = GetItemQualityColor(quality)
                local _, _, itemID = string.find(link, "item:(%d+):%d+:%d+:%d+")
                local itemLevel = ShaguScore.Database[tonumber(itemID)] or 0
                local score = ShaguScore:Calculate(vslot, quality, itemLevel)
                if score and score > 0 then
                  slot.scoreText:SetText(score)
                  slot.scoreText:SetTextColor(r, g, b)
                else
                  slot.scoreText:SetText("")
                end
              end
            end
          elseif slot.hasItem then
            retry = true
          else
            CreateBackdrop(slot)
            SetAllPointsOffset(slot.backdrop, slot, 0)
            if slot.scoreText then
              slot.scoreText:SetText("")
            end
          end

          if retry == true and InspectFrame.unit then
            QueueFunction(UpdateSlots)
          end
        end
      end

      hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
        local bid = button:GetID()
        local link = GetInventoryItemLink(InspectFrame.unit, bid)
        if link then
          local _,_,itemID = string.find(link, 'item:(%d+)')
          cache[bid] = cache[bid] or {}
          cache[bid]["id"] = itemID
          cache[bid]["tex"] = GetInventoryItemTexture(InspectFrame.unit, button:GetID())
          cache[bid]["count"] = GetInventoryItemCount(InspectFrame.unit, button:GetID())
          cache[bid]["name"] = UnitName(InspectFrame.unit)
        elseif cache[bid] and UnitName(InspectFrame.unit) == cache[bid].name then
          -- restore cache information
          SetItemButtonTexture(button, cache[bid]["tex"])
          SetItemButtonCount(button, cache[bid]["count"])
          button.hasItem = 1
        end

        UpdateSlots()
        QueueFunction(UpdateSlots)
      end, 1)
    end

    do -- Honor Tab
      StripTextures(InspectHonorFrame)

      CreateBackdrop(InspectHonorFrameProgressBar)
      InspectHonorFrameProgressBar:SetStatusBarTexture(pfUI.media["img:bar"])
      InspectHonorFrameProgressBar:SetHeight(24)
    end
  end)
end)
