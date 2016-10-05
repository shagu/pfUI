pfUI:RegisterModule("buff", function ()
  pfUI.buff = CreateFrame("Frame")
  pfUI.buff:RegisterEvent("PLAYER_AURAS_CHANGED")
  pfUI.buff:RegisterEvent("UNIT_INVENTORY_CHANGED")
  pfUI.buff:RegisterEvent("UNIT_AURA")
  pfUI.buff:RegisterEvent("UNIT_MODEL_CHANGED")
  pfUI.buff:SetScript("OnEvent", function ()
    pfUI.buff:UpdateSkin()
  end)

  -- weapon enchant stacks
  TempEnchant1.stacks = TempEnchant1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  TempEnchant1.stacks:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
  TempEnchant1.stacks:SetTextColor(1,1,1,1)
  TempEnchant1.stacks:ClearAllPoints()
  TempEnchant1.stacks:SetAllPoints(TempEnchant1)
  TempEnchant1.stacks:SetJustifyH("RIGHT")
  TempEnchant1.stacks:SetJustifyV("BOTTOM")
  TempEnchant2.stacks = TempEnchant2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  TempEnchant2.stacks:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
  TempEnchant2.stacks:SetTextColor(1,1,1,1)
  TempEnchant2.stacks:ClearAllPoints()
  TempEnchant2.stacks:SetAllPoints(TempEnchant2)
  TempEnchant2.stacks:SetJustifyH("RIGHT")
  TempEnchant2.stacks:SetJustifyV("BOTTOM")

  -- This hack is used to update the border again and again up to 10 seconds.
  -- On a reload the item rarity can not be detected instantly. It requries
  -- some seconds after the correct border color will be shown.
  pfUI.buff.lastUpdate = 0
  pfUI.buff.updateInterval = .05
  pfUI.buff:SetScript("OnUpdate", function()
    if pfUI.buff.lastUpdate + pfUI.buff.updateInterval < GetTime() then
      pfUI.buff:UpdateSkin()
      pfUI.buff.lastUpdate = GetTime()
      pfUI.buff.updateInterval = pfUI.buff.updateInterval + pfUI.buff.updateInterval
    end
    if pfUI.buff.updateInterval > 10 then
      pfUI.buff:Hide()
    end
  end)

  function pfUI.buff:UpdateSkin()
    -- buff positions
    TemporaryEnchantFrame:ClearAllPoints()
    TemporaryEnchantFrame:SetPoint("TOPRIGHT", pfUI.minimap, "TOPLEFT", -25,0)

    -- weapon enchants
    for _,buff in pairs ({TempEnchant1,TempEnchant2}) do
      local icon = getglobal(buff:GetName().."Icon");
      local border = getglobal(buff:GetName().."Border")
      local _, _, mainhand, _, _, offhand = GetWeaponEnchantInfo()

      if buff then
        buff:SetBackdrop({
          bgFile = icon:GetTexture(), tile = false, tileSize = 16,
          edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
          insets = { left = 0, right = 0, top = 0, bottom = 0}
        })
        border:Hide()
      end

      if buff:GetID() == 16 then
        local link = GetInventoryItemLink("player", 16)
        local _, _, itemLink = string.find(link, "(item:%d+:%d+:%d+:%d+)");
        local _, _, itemRarity, itemLevel, _, _, _, itemEquipLoc, _ = GetItemInfo(itemLink)
        if itemRarity then buff:SetBackdropBorderColor(GetItemQualityColor(itemRarity)) end

        if mainhand and mainhand > 0 then
          buff.stacks:SetText(mainhand)
          buff.stacks:Show()
        else
          buff.stacks:Hide()
        end
      elseif buff:GetID() == 17 then
        local link = GetInventoryItemLink("player", 17)
        local _, _, itemLink = string.find(link, "(item:%d+:%d+:%d+:%d+)");
        local _, _, itemRarity, itemLevel, _, _, _, itemEquipLoc, _ = GetItemInfo(itemLink)
        if itemRarity then buff:SetBackdropBorderColor(GetItemQualityColor(itemRarity)) end
        if offhand and offhand > 0 then
          buff.stacks:SetText(offhand)
          buff.stacks:Show()
        else
          buff.stacks:Hide()
        end
      end
    end

    -- buffs
    for i=0,15,1 do
      local buff = getglobal("BuffButton" .. i)
      local icon = getglobal(buff:GetName().."Icon");
      local border = getglobal(buff:GetName().."Border")
      if border then
        buff:SetBackdrop({
          bgFile = icon:GetTexture(), tile = false, tileSize = 16,
          edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
          insets = { left = 0, right = 0, top = 0, bottom = 0}
        })
        buff:SetBackdropBorderColor(border:GetVertexColor())
        border:Hide()
      else
        buff:SetBackdrop({
          bgFile = icon:GetTexture(), tile = false, tileSize = 16,
          edgeFile = "Interface\\AddOns\\pfUI\\img\\border", edgeSize = 8,
          insets = { left = 0, right = 0, top = 0, bottom = 0}
        })
      end
    end
  end
end)
