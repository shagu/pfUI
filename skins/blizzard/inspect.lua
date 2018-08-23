pfUI:RegisterSkin("Inspect", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  HookAddonOrVariable("Blizzard_InspectUI", function()
    StripTextures(InspectFrame, true)
  	CreateBackdrop(InspectFrame, nil, nil, .75)
    InspectFrame.backdrop:SetPoint("TOPLEFT", 10, -12)
  	InspectFrame.backdrop:SetPoint("BOTTOMRIGHT", -31, 75)

    SkinCloseButton(InspectFrameCloseButton)
    StripTextures(InspectPaperDollFrame)

    InspectModelRotateLeftButton:Hide()
    InspectModelRotateRightButton:Hide()
    EnableClickRotate(InspectModelFrame)

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
  		local texture = _G["Inspect"..slot.."IconTexture"]
      texture:SetTexCoord(.08, .92, .08, .92)
      texture:ClearAllPoints()
      texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
      texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)

      StripTextures(frame)
      CreateBackdrop(frame)

      frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
      frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
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

  	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function()
      UpdateSlots()
      QueueFunction(UpdateSlots)
    end)

  	-- honor tab
  	StripTextures(InspectHonorFrame)
    CreateBackdrop(InspectHonorFrameProgressBar)
  	InspectHonorFrameProgressBar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    InspectHonorFrameProgressBar:SetHeight(24)

    -- tabs
    InspectFrameTab1:ClearAllPoints()
    InspectFrameTab1:SetPoint("TOPLEFT", InspectFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
    for i = 1, 2 do
      local tab = _G["InspectFrameTab"..i]
      local lastTab = _G["InspectFrameTab"..(i-1)]
      if lastTab then
        tab:ClearAllPoints()
        tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
      end
      SkinTab(tab)
    end
  end)
end)
