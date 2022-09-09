pfUI:RegisterSkin("Arena Registrar", "tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  do -- ArenaRegistrarFrame
    StripTextures(ArenaRegistrarFrame)
    StripTextures(ArenaRegistrarGreetingFrame)
    CreateBackdrop(ArenaRegistrarFrame, nil, nil, .75)
    CreateBackdropShadow(ArenaRegistrarFrame)

    ArenaRegistrarFrame.backdrop:SetPoint("TOPLEFT", 14, -18)
    ArenaRegistrarFrame.backdrop:SetPoint("BOTTOMRIGHT", -28, 66)
    ArenaRegistrarFrame:SetHitRectInsets(14,28,18,66)
    EnableMovable(ArenaRegistrarFrame)

    SkinCloseButton(ArenaRegistrarFrameCloseButton, ArenaRegistrarFrame.backdrop, -6, -6)

    ArenaRegistrarFrame:DisableDrawLayer("BACKGROUND")

    ArenaRegistrarFrameNpcNameText:ClearAllPoints()
    ArenaRegistrarFrameNpcNameText:SetPoint("TOP", ArenaRegistrarFrame.backdrop, "TOP", 0, -10)

    SkinButton(ArenaRegistrarFrameGoodbyeButton)
    SkinButton(ArenaRegistrarFrameCancelButton)
    SkinButton(ArenaRegistrarFramePurchaseButton)

    ArenaRegistrarCostLabel:SetFontObject("GameFontWhite")
    ArenaRegistrarFrameEditBox:DisableDrawLayer("BACKGROUND")
    CreateBackdrop(ArenaRegistrarFrameEditBox, nil, nil, 1)
    ArenaRegistrarFrameEditBox:SetHeight(16)

    local bg = ArenaRegistrarFrame:CreateTexture(nil, "LOW")
    bg:SetTexCoord(.1,1,0,1)
    bg:SetTexture("Interface\\Stationery\\StationeryTest1")
    bg:SetPoint("TOPLEFT", 23, -81)
    bg:SetPoint("BOTTOMRIGHT", -40, 100)
  end

  do -- PVPBannerFrame
    StripTextures(PVPBannerFrame)
    CreateBackdrop(PVPBannerFrame, nil, nil, .75)
    CreateBackdropShadow(PVPBannerFrame)

    PVPBannerFrame.backdrop:SetPoint("TOPLEFT", 10, -12)
    PVPBannerFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
    PVPBannerFrame:SetHitRectInsets(10,32,12,72)
    EnableMovable(PVPBannerFrame)

    SkinCloseButton(PVPBannerFrameCloseButton, PVPBannerFrame.backdrop, -6, -6)

    PVPBannerFrame:DisableDrawLayer("BACKGROUND")

    PVPBannerFrameNameText:ClearAllPoints()
    PVPBannerFrameNameText:SetPoint("TOP", ArenaRegistrarFrame.backdrop, "TOP", 0, -10)
    PVPBannerFrameGreetingText:ClearAllPoints()
    PVPBannerFrameGreetingText:SetPoint("TOP", PVPBannerFrameNameText, "TOP", 0, -10)

    PVPBannerFrameCustomizationBorder:Hide()
    PVPBannerFrameCustomization1:ClearAllPoints()
    PVPBannerFrameCustomization1:SetPoint("TOPLEFT", PVPBannerFrameCustomizationBorder, "TOPLEFT", 48, -45)
    for i = 1, 2 do
      local frame = _G["PVPBannerFrameCustomization"..i]
      StripTextures(frame)
      CreateBackdrop(frame, nil, true)
      frame:SetHeight(25)

      local left = _G["PVPBannerFrameCustomization"..i.."LeftButton"]
      StripTextures(left)
      SkinArrowButton(left, "left", 25)
      left:ClearAllPoints()
      left:SetPoint("LEFT", 0, 0)

      local right = _G["PVPBannerFrameCustomization"..i.."RightButton"]
      StripTextures(right)
      SkinArrowButton(right, "right", 25)
      right:ClearAllPoints()
      right:SetPoint("RIGHT", 0, 0)

      local text = _G["PVPBannerFrameCustomization"..i.."Text"]
      text:ClearAllPoints()
      text:SetPoint("CENTER", 0, 0)
    end

    local width = PVPBannerFrameCustomization2:GetWidth()
    for i = 1, 3 do
      local btn = _G["PVPColorPickerButton"..i]
      local prev = _G["PVPColorPickerButton"..(i-1)]

      SkinButton(btn)
      btn:SetWidth(width)
      btn:ClearAllPoints()
      if prev then
        btn:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -5)
      else
        btn:SetPoint("TOPLEFT", PVPBannerFrameCustomization2, "BOTTOMLEFT", 0, -5)
      end
    end

    local PVPBannerFrameCancelButton
    do -- fix Blizzard bug. A button with the same name is created twice.
      for k,v in ipairs({PVPBannerFrameCustomizationFrame:GetChildren()}) do
        if v:GetName() == "PVPBannerFrameCancelButton" then v:Hide() end -- This is the wrong and broken button.
      end

      for k,v in ipairs({PVPBannerFrame:GetChildren()}) do
        if v:GetName() == "PVPBannerFrameCancelButton" then PVPBannerFrameCancelButton = v end
      end
    end

    SkinButton(PVPBannerFrameSaveButton)

    SkinButton(PVPBannerFrameCancelButton)
    PVPBannerFrameCancelButton:ClearAllPoints()
    PVPBannerFrameCancelButton:SetPoint("TOPRIGHT", PVPColorPickerButton3, "BOTTOMRIGHT", 0, -10)
    SkinButton(PVPBannerFrameAcceptButton)
    PVPBannerFrameAcceptButton:ClearAllPoints()
    PVPBannerFrameAcceptButton:SetPoint("RIGHT", PVPBannerFrameCancelButton, "LEFT", -2*bpad, 0)
  end
end)
