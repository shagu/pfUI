pfUI:RegisterSkin("Inspect", "vanilla", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

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

      for _, slot in pairs(slots) do
        local frame = _G["Inspect"..slot]
        StripTextures(frame)
        CreateBackdrop(frame)
        SetAllPointsOffset(frame.backdrop, frame, 2)

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
            local _, _, link = string.find(link, "(item:%d+:%d+:%d+:%d+)");
            local _, _, quality = GetItemInfo(link)

            if not quality then
              retry = true
            else
              slot.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))

              if ShaguScore then
                if not slot.scoreText then
                  slot.scoreText = slot:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                  slot.scoreText:SetFont(pfUI.font_default, 12, "OUTLINE")
                  slot.scoreText:SetPoint("BOTTOMRIGHT", 0, 0)
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
