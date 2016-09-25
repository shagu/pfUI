pfUI:RegisterModule("buff", function ()
  pfUI.buff = CreateFrame("Frame")

  -- weapon enchant (main hand)
  pfUI.buff.mainHand = CreateFrame("Frame", nil, UIParent)
  pfUI.buff.mainHand.stacks = pfUI.buff.mainHand:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  pfUI.buff.mainHand.stacks:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
  pfUI.buff.mainHand.stacks:SetTextColor(1,1,1,1)
  pfUI.buff.mainHand.stacks:ClearAllPoints()
  pfUI.buff.mainHand.stacks:SetPoint("TOPLEFT", pfUI.buff.mainHand ,"TOPLEFT", 2, -2)
  pfUI.buff.mainHand.stacks:SetPoint("BOTTOMRIGHT", pfUI.buff.mainHand ,"BOTTOMRIGHT", -2, 2)
  pfUI.buff.mainHand.stacks:SetJustifyH("RIGHT")
  pfUI.buff.mainHand.stacks:SetJustifyV("BOTTOM")

  -- weapon enchant (off hand)
  pfUI.buff.offHand = CreateFrame("Frame", nil, UIParent)
  pfUI.buff.offHand.stacks = pfUI.buff.offHand:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  pfUI.buff.offHand.stacks:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
  pfUI.buff.offHand.stacks:SetTextColor(1,1,1,1)
  pfUI.buff.offHand.stacks:ClearAllPoints()
  pfUI.buff.offHand.stacks:SetPoint("TOPLEFT", pfUI.buff.offHand ,"TOPLEFT", 2, -2)
  pfUI.buff.offHand.stacks:SetPoint("BOTTOMRIGHT", pfUI.buff.offHand ,"BOTTOMRIGHT", -2, 2)
  pfUI.buff.offHand.stacks:SetJustifyH("RIGHT")
  pfUI.buff.offHand.stacks:SetJustifyV("BOTTOM")

  -- hook buff update
  if not Hook_BuffButton_OnUpdate then
    Hook_BuffButton_OnUpdate = BuffButton_OnUpdate
  end

  function BuffButton_OnUpdate (arg1)
    TemporaryEnchantFrame:ClearAllPoints()
    TemporaryEnchantFrame:SetPoint("TOPRIGHT", pfUI.minimap, "TOPLEFT", -25,0)

    local buff = this
    local icon = getglobal(buff:GetName().."Icon");
    local border = getglobal(buff:GetName().."Border")

    if border then
      buff:SetBackdrop({
        bgFile = icon:GetTexture(), tile = false, tileSize = pfUI_config.unitframes.buff_size,
        edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0}
      })
      buff:SetBackdropBorderColor(border:GetVertexColor())
      border:Hide()
    else
      buff:SetBackdrop({
        bgFile = icon:GetTexture(), tile = false, tileSize = pfUI_config.unitframes.buff_size,
        edgeFile = "Interface\\AddOns\\pfUI\\img\\border", edgeSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0}
      })
    end
    Hook_BuffButton_OnUpdate(arg1)
  end

  -- hook weapon update
  if not Hook_BuffFrame_Enchant_OnUpdate then
    Hook_BuffFrame_Enchant_OnUpdate = BuffFrame_Enchant_OnUpdate
  end

  function BuffFrame_Enchant_OnUpdate (arg1)
    TemporaryEnchantFrame:ClearAllPoints()
    TemporaryEnchantFrame:SetPoint("TOPRIGHT", pfUI.minimap, "TOPLEFT", -25,0)

    for _,frame in pairs ({TempEnchant1,TempEnchant2}) do
      local buff = frame
      local icon = getglobal(buff:GetName().."Icon");
      local border = getglobal(buff:GetName().."Border")
      local _, _, mainhand, _, _, offhand = GetWeaponEnchantInfo()

      if buff then
        buff:SetBackdrop({
          bgFile = icon:GetTexture(), tile = false, tileSize = pfUI_config.unitframes.buff_size,
          edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
          insets = { left = 0, right = 0, top = 0, bottom = 0}
        })
        border:Hide()
      end

      if mainhand then
        if buff:GetID() == 16 then
          local link = GetInventoryItemLink("player", 16)
          local _, _, itemLink = string.find(link, "(item:%d+:%d+:%d+:%d+)");
          local _, _, itemRarity, itemLevel, _, _, _, itemEquipLoc, _ = GetItemInfo(itemLink)

          if itemRarity then
            buff:SetBackdropBorderColor(GetItemQualityColor(itemRarity))
          end

          if mainhand > 0 then
            pfUI.buff.mainHand.stacks:SetText(mainhand)
            pfUI.buff.mainHand:SetAllPoints(buff)
            pfUI.buff.mainHand:Show()
          end
        end
      else
        pfUI.buff.mainHand:Hide()
      end

      if offhand then
        if buff:GetID() == 17 then
          local link = GetInventoryItemLink("player", 17)
          local _, _, itemLink = string.find(link, "(item:%d+:%d+:%d+:%d+)");
          local _, _, itemRarity, itemLevel, _, _, _, itemEquipLoc, _ = GetItemInfo(itemLink)

          if itemRarity then
            buff:SetBackdropBorderColor(GetItemQualityColor(itemRarity))
          end
          if offhand > 0 then
            pfUI.buff.offHand.stacks:SetText(offhand)
            pfUI.buff.offHand:SetAllPoints(buff)
            pfUI.buff.offHand:Show()
          end
        end
      else
        pfUI.buff.offHand:Hide()
      end
    end
    Hook_BuffFrame_Enchant_OnUpdate(arg1)
  end
end)
