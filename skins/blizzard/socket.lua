pfUI:RegisterSkin("Item Socketing", "tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  HookAddonOrVariable("Blizzard_ItemSocketingUI", function()
    StripTextures(ItemSocketingFrame)
    CreateBackdrop(ItemSocketingFrame, nil, nil, .75)
    CreateBackdropShadow(ItemSocketingFrame)
    ItemSocketingFrame.backdrop:SetPoint("TOPLEFT", 8, -14)
    ItemSocketingFrame.backdrop:SetPoint("BOTTOMRIGHT", -4, 28)
    ItemSocketingFrame:SetHitRectInsets(8,4,14,28)
    EnableMovable(ItemSocketingFrame)

    SkinCloseButton(ItemSocketingCloseButton, ItemSocketingFrame.backdrop, -6, -6)

    ItemSocketingFrame:DisableDrawLayer("BACKGROUND")

    StripTextures(ItemSocketingScrollFrame)
    CreateBackdrop(ItemSocketingScrollFrame)
    ItemSocketingScrollFrame:ClearAllPoints()
    ItemSocketingScrollFrame:SetPoint("TOPLEFT", 32, -70)
    ItemSocketingScrollFrame.backdrop:SetPoint("TOPLEFT", 0, 10)
    ItemSocketingScrollFrame.backdrop:SetPoint("BOTTOMRIGHT", 0, -10)
    SkinScrollbar(ItemSocketingScrollFrameScrollBar)
    ItemSocketingScrollFrameScrollBar:ClearAllPoints()
    ItemSocketingScrollFrameScrollBar:SetPoint("TOPLEFT", ItemSocketingScrollFrame.backdrop, "TOPRIGHT", 6, -16)
    ItemSocketingScrollFrameScrollBar:SetPoint("BOTTOMLEFT", ItemSocketingScrollFrame.backdrop, "BOTTOMRIGHT", 6, 16)
    SkinButton(ItemSocketingSocketButton)
    for i = 1, MAX_NUM_SOCKETS do
      local btn = _G["ItemSocketingSocket"..i]
      StripTextures(btn)
      SkinButton(btn, nil, nil, nil, _G["ItemSocketingSocket"..i.."IconTexture"], true)
    end
    local orig = ItemSocketingSocket1.SetPoint
    ItemSocketingSocket1.SetPoint = function(self,a,b,c,x,y)
      orig(self,a,b,c,x-10,y+15)
    end
  end)
end)
