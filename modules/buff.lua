pfUI:RegisterModule("buff", function ()
  pfUI.buff = CreateFrame("Frame")
  pfUI.buff:RegisterEvent("PLAYER_AURAS_CHANGED")
  pfUI.buff:RegisterEvent("UNIT_INVENTORY_CHANGED")
  pfUI.buff:RegisterEvent("UNIT_AURA")
  pfUI.buff:RegisterEvent("UNIT_MODEL_CHANGED")
  pfUI.buff:SetScript("OnEvent", function ()
    if event == "UNIT_AURA" and arg1 ~= "player" then return end
    pfUI.buff:UpdateSkin()
  end)

  -- weapon enchant stacks
  TempEnchant1.stacks = TempEnchant1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  TempEnchant1.stacks:SetFont(pfUI.font_default, 14, "OUTLINE")
  TempEnchant1.stacks:SetTextColor(1,1,1,1)
  TempEnchant1.stacks:ClearAllPoints()
  TempEnchant1.stacks:SetAllPoints(TempEnchant1)
  TempEnchant1.stacks:SetJustifyH("RIGHT")
  TempEnchant1.stacks:SetJustifyV("BOTTOM")
  TempEnchant2.stacks = TempEnchant2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  TempEnchant2.stacks:SetFont(pfUI.font_default, 14, "OUTLINE")
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
    TemporaryEnchantFrame:SetPoint("TOPRIGHT", pfUI.minimap or Minimap, "TOPLEFT", -25,0)

    if C.global.hidewbuff == "1" then
      TemporaryEnchantFrame:Hide()
      BuffFrame:SetPoint("TOPRIGHT", pfUI.minimap or Minimap, "TOPLEFT", -25,0)
    else
      -- weapon enchants
      for _,buff in pairs ({TempEnchant1,TempEnchant2}) do
        local icon = _G[buff:GetName().."Icon"]
        local border = _G[buff:GetName().."Border"]
        local text = _G[buff:GetName().."Duration"]
        text:SetPoint("TOP", buff, "BOTTOM", 0 , -C.appearance.border.default*2)

        local _, _, mainhand, _, _, offhand = GetWeaponEnchantInfo()
        if buff then
          CreateBackdrop(buff)
          icon:SetTexCoord(.08, .92, .08, .92)
          border:Hide()
        end

        if buff:GetID() == 16 then
          local link = GetInventoryItemLink("player", 16)
          if not link then break end
          local _, _, itemLink = string.find(link, "(item:%d+:%d+:%d+:%d+)")
          local _, _, itemRarity, itemLevel, _, _, _, itemEquipLoc, _ = GetItemInfo(itemLink)
          if itemRarity then buff.backdrop:SetBackdropBorderColor(GetItemQualityColor(itemRarity)) end

          if mainhand and mainhand > 0 then
            buff.stacks:SetText(mainhand)
            buff.stacks:Show()
          else
            buff.stacks:Hide()
          end
        elseif buff:GetID() == 17 then
          local link = GetInventoryItemLink("player", 17)
          if not link then break end
          local _, _, itemLink = string.find(link, "(item:%d+:%d+:%d+:%d+)")
          local _, _, itemRarity, itemLevel, _, _, _, itemEquipLoc, _ = GetItemInfo(itemLink)
          if itemRarity then buff.backdrop:SetBackdropBorderColor(GetItemQualityColor(itemRarity)) end
          if offhand and offhand > 0 then
            buff.stacks:SetText(offhand)
            buff.stacks:Show()
          else
            buff.stacks:Hide()
          end
        end
      end
    end

    if C.global.hidebuff == "1" then
      BuffFrame:Hide()
    else
      -- buffs
      for i=0,32 do
        local buff = _G["BuffButton" .. i]
        if buff then
          local icon = _G[buff:GetName().."Icon"]
          local border = _G[buff:GetName().."Border"]
          local text = _G[buff:GetName().."Duration"]

          if i < 8 and i > 0 then
            buff:SetPoint("TOPRIGHT", _G["BuffButton" .. i-1], "TOPLEFT", -7, 0)
          elseif i < 16 and i > 8 then
              buff:SetPoint("TOPRIGHT", _G["BuffButton" .. i-1], "TOPLEFT", -7, 0)
          elseif i > 16 then
            buff:SetPoint("TOPRIGHT", _G["BuffButton" .. i-1], "TOPLEFT", -7, 0)
          end
          CreateBackdrop(buff)
          text:SetPoint("TOP", buff, "BOTTOM", 0 , -C.appearance.border.default*2)
          icon:SetTexCoord(.08, .92, .08, .92)
          if border then
            buff.backdrop:SetBackdropBorderColor(border:GetVertexColor())
            border:Hide()
          end
        end
      end
    end
  end
end)
