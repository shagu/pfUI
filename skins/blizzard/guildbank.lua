pfUI:RegisterSkin("Guild Bank", "tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  HookAddonOrVariable("Blizzard_GuildBankUI", function()
    do -- GuildBankFrame
      StripTextures(GuildBankFrame)
      CreateBackdrop(GuildBankFrame, nil, nil, .75)
      CreateBackdropShadow(GuildBankFrame)
      GuildBankFrame.backdrop:SetPoint("TOPLEFT", 10, -30)
      GuildBankFrame.backdrop:SetPoint("BOTTOMRIGHT", 0, 4)
      GuildBankFrame:SetHitRectInsets(10,0,30,4)
      EnableMovable(GuildBankFrame)

      SkinCloseButton(GetNoNameObject(GuildBankFrame, "Button", nil, "UI-Panel-MinimizeButton-Up"), GuildBankFrame.backdrop, -6, -6)

      GuildBankEmblemFrame:ClearAllPoints()
      GuildBankEmblemFrame:SetPoint("BOTTOM", GuildBankFrame.backdrop, "TOP", -70, 0)

      for i = 1, 4 do
        local tab = _G["GuildBankFrameTab"..i]
        local lastTab = _G["GuildBankFrameTab"..(i-1)]
        tab:ClearAllPoints()
        if lastTab then
          tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
          else
          tab:SetPoint("TOPLEFT", GuildBankFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
        end
        SkinTab(tab)
      end
      for i = 1, 6 do
        local frame = _G["GuildBankTab"..i]
        local button = _G["GuildBankTab"..i.."Button"]
        local lastbutton = _G["GuildBankTab"..(i-1).."Button"]
        local texture = _G["GuildBankTab"..i.."ButtonIconTexture"]

        StripTextures(frame)
        SkinButton(button, nil, nil, nil, texture)

        button:ClearAllPoints()
        if lastbutton then
          button:SetPoint("TOP", lastbutton, "BOTTOM", 0, - (border + (border == 1 and 1 or 2) + bpad))
          else
          button:SetPoint("TOPLEFT", 6, -60)
        end

        function button.SetChecked(self, checked)
          if checked then
            self.locked = true
            self:SetBackdropBorderColor(1,1,1)
            else
            self.locked = false
            self:SetBackdropBorderColor(GetStringColor(pfUI_config.appearance.border.color))
          end
        end
      end

      for i = 1, NUM_GUILDBANK_COLUMNS do
        local column = _G["GuildBankColumn"..i]
        StripTextures(column)
        for j = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
          local slot = _G["GuildBankColumn"..i.."Button"..j]
          SkinButton(slot, nil, nil, nil, _G[slot:GetName().."IconTexture"], true)
        end
      end

      hooksecurefunc("GuildBankFrame_Update", function()
        if GuildBankFrame.mode ~= "bank" then return end

        for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
          local index = math.fmod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
          if index == 0 then index = NUM_SLOTS_PER_GUILDBANK_GROUP end
          local column = ceil((i-.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
          local slot = _G["GuildBankColumn"..column.."Button"..index]
          local tab = GetCurrentGuildBankTab()
          local link = GetGuildBankItemLink(tab, i)
          if link then
            local r,g,b = GetItemQualityColor(select(3, GetItemInfo(link)))
            slot:SetBackdropBorderColor(r,g,b,1)
          else
            slot:SetBackdropBorderColor(GetStringColor(pfUI_config.appearance.border.color))
          end
        end
      end)

      SkinButton(GuildBankFrameDepositButton)
      SkinButton(GuildBankFrameWithdrawButton)
      GuildBankFrameWithdrawButton:ClearAllPoints()
      GuildBankFrameWithdrawButton:SetPoint("RIGHT", GuildBankFrameDepositButton, "LEFT", -2*bpad, 0)

      SkinButton(GuildBankInfoSaveButton)
      GuildBankInfoScrollFrameScrollBar:Hide()
    end

    do -- GuildBankPopupFrame
      StripTextures(GuildBankPopupFrame)
      CreateBackdrop(GuildBankPopupFrame, nil, nil, .75)
      CreateBackdropShadow(GuildBankPopupFrame)
      GuildBankPopupFrame.backdrop:SetPoint("TOPLEFT", 0, -6)
      GuildBankPopupFrame.backdrop:SetPoint("BOTTOMRIGHT", -26, 26)
      GuildBankPopupFrame:SetHitRectInsets(0,26,6,26)

      GuildBankPopupFrame.backdrop:SetPoint("TOPLEFT", GuildBankFrame.backdrop, "TOPRIGHT", 2*border, 0)

      GuildBankPopupEditBox:DisableDrawLayer("BACKGROUND")
      CreateBackdrop(GuildBankPopupEditBox)

      StripTextures(GuildBankPopupScrollFrame)
      CreateBackdrop(GuildBankPopupScrollFrame)
      SkinScrollbar(GuildBankPopupScrollFrameScrollBar)
      GuildBankPopupScrollFrame:ClearAllPoints()
      GuildBankPopupScrollFrame:SetPoint("TOPLEFT", GuildBankPopupEditBox, "BOTTOMLEFT", -11, -14)
      GuildBankPopupScrollFrame:SetWidth(182)
      GuildBankPopupScrollFrame:SetHeight(178)

      for i = 1, 16 do
        local slot = _G["GuildBankPopupButton"..i]
        StripTextures(slot)
        SkinButton(slot, nil, nil, nil, _G["GuildBankPopupButton"..i.."Icon"], true)
      end

      GuildBankPopupButton1:ClearAllPoints()
      GuildBankPopupButton1:SetPoint("TOPLEFT", GuildBankPopupScrollFrame, "TOPLEFT", 4, -4)

      SkinButton(GuildBankPopupCancelButton)
      SkinButton(GuildBankPopupOkayButton)
      GuildBankPopupOkayButton:ClearAllPoints()
      GuildBankPopupOkayButton:SetPoint("RIGHT", GuildBankPopupCancelButton, "LEFT", -2*bpad, 0)
    end
  end)
end)
