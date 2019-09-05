pfUI:RegisterSkin("Books", "vanilla:tbc", function ()
  StripTextures(ItemTextFrame)
  CreateBackdrop(ItemTextFrame, nil, nil, .75)
  CreateBackdropShadow(ItemTextFrame)

  ItemTextFrame.backdrop:SetPoint("TOPLEFT", 12, -12)
  ItemTextFrame.backdrop:SetPoint("BOTTOMRIGHT", -30, 72)
  ItemTextFrame:SetHitRectInsets(12,30,12,72)
  EnableMovable(ItemTextFrame)

  SkinCloseButton(ItemTextCloseButton, ItemTextFrame.backdrop, -6, -6)

  ItemTextScrollFrame:SetWidth(292)
  ItemTextPageText:SetWidth(282)
  ItemTextPageText:ClearAllPoints()
  ItemTextPageText:SetPoint("TOPLEFT", 4, -15)

  ItemTextTitleText:ClearAllPoints()
  ItemTextTitleText:SetPoint("TOP", ItemTextFrame.backdrop, "TOP", 0, -10)

  StripTextures(ItemTextScrollFrame)
  CreateBackdrop(ItemTextScrollFrame, nil, true, .75)
  SkinScrollbar(ItemTextScrollFrameScrollBar)
  ItemTextScrollFrame:ClearAllPoints()
  ItemTextScrollFrame:SetPoint("TOPRIGHT", -66, -46)

  -- add new background
  local bg = ItemTextScrollFrame:CreateTexture(nil, "BORDER")
  bg:SetAllPoints()
  bg:SetTexCoord(.1,1,0,1)
  bg:SetTexture("Interface\\Stationery\\StationeryTest1")

  -- assign material backgrounds to the default one
  ItemTextMaterialTopLeft.SetTexture = function(self, texture)
    bg:SetTexture(texture)
  end

  ItemTextMaterialTopLeft.Hide = function()
    bg:SetTexture("Interface\\Stationery\\StationeryTest1")
  end

  -- disable meterial backgrounds
  ItemTextMaterialTopLeft.Show = function() return end
  ItemTextMaterialTopRight.Show = function() return end
  ItemTextMaterialBotLeft.Show = function() return end
  ItemTextMaterialBotRight.Show = function() return end
  ItemTextMaterialTopLeft:Hide()
  ItemTextMaterialTopRight:Hide()
  ItemTextMaterialBotLeft:Hide()
  ItemTextMaterialBotRight:Hide()

  ItemTextCurrentPage:ClearAllPoints()
  ItemTextCurrentPage:SetPoint("TOP", ItemTextScrollFrame, "BOTTOM", 0, -10)
  local orig_SetText = ItemTextCurrentPage.SetText
  ItemTextCurrentPage.SetText = function(self, text)
    text = format(PAGE_NUMBER, text)
    orig_SetText(self, text)
  end

  ItemTextCurrentPage:SetFontObject("GameFontWhite")
  SkinArrowButton(ItemTextPrevPageButton, "left", 18)
  ItemTextPrevPageButton:ClearAllPoints()
  ItemTextPrevPageButton:SetPoint("TOPLEFT", ItemTextScrollFrame, "BOTTOMLEFT", 0, -6)
  SkinArrowButton(ItemTextNextPageButton, "right", 18)
  ItemTextNextPageButton:ClearAllPoints()
  ItemTextNextPageButton:SetPoint("TOPRIGHT", ItemTextScrollFrame, "BOTTOMRIGHT", 0, -6)

  ItemTextNextPageButton.Show = function(self) self:Enable() end
  ItemTextNextPageButton.Hide = function(self) self:Disable() end
  ItemTextPrevPageButton.Show = function(self) self:Enable() end
  ItemTextPrevPageButton.Hide = function(self) self:Disable() end

  do -- do not hide the scrollbar
    ItemTextScrollFrame:Show()
    ItemTextScrollFrameScrollBar:Show()
    ItemTextScrollFrameScrollBarScrollUpButton:Show()
    ItemTextScrollFrameScrollBarScrollDownButton:Show()

    ItemTextScrollFrame.Show = function(self) end
    ItemTextScrollFrame.Hide = function(self) end
    ItemTextScrollFrameScrollBar.Show = function(self) self.thumb:Show() end
    ItemTextScrollFrameScrollBar.Hide = function(self) self.thumb:Hide() end
    ItemTextScrollFrameScrollBarScrollUpButton.Show = function(self) if self:GetParent():GetValue() ~= 0 then self:Enable() end end
    ItemTextScrollFrameScrollBarScrollUpButton.Hide = function(self) self:Disable() end
    ItemTextScrollFrameScrollBarScrollDownButton.Show = function(self) self:Enable() end
    ItemTextScrollFrameScrollBarScrollDownButton.Hide = function(self) self:Disable() end

    local first
    HookScript(ItemTextFrame, "OnShow", function()
      if not first then -- it is necessary to update the scrollbar when you first open the frame
        ItemTextScrollFrameScrollBar:Show()
        ItemTextScrollFrameScrollBar:Hide()
        ItemTextScrollFrameScrollBarScrollUpButton:Show()
        ItemTextScrollFrameScrollBarScrollUpButton:Hide()
        ItemTextScrollFrameScrollBarScrollDownButton:Show()
        ItemTextScrollFrameScrollBarScrollDownButton:Hide()
        first = true
      end
    end)
  end

  CreateBackdrop(ItemTextStatusBar, nil, true)
  ItemTextStatusBar:DisableDrawLayer("OVERLAY")
  ItemTextStatusBar:SetStatusBarTexture(pfUI.media["img:bar"])
  ItemTextStatusBar:SetHeight(12)
  ItemTextStatusBar:ClearAllPoints()
  ItemTextStatusBar:SetPoint("BOTTOM", ItemTextScrollFrame, "BOTTOM", 0, 50)
end)
