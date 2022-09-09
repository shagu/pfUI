pfUI:RegisterSkin("KeyBindings", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  HookAddonOrVariable("Blizzard_BindingUI", function()
    StripTextures(KeyBindingFrame)
    CreateBackdrop(KeyBindingFrame, nil, nil, .75)
    CreateBackdropShadow(KeyBindingFrame)

    KeyBindingFrame.backdrop:SetPoint("TOPLEFT", 2, 10)
    KeyBindingFrame.backdrop:SetPoint("BOTTOMRIGHT", -42, 10)
    KeyBindingFrame:SetHitRectInsets(2,42,10,10)
    EnableMovable(KeyBindingFrame)

    SkinScrollbar(KeyBindingFrameScrollFrameScrollBar)

    SkinCheckbox(KeyBindingFrameCharacterButton)

    SkinButton(KeyBindingFrameDefaultButton)
    SkinButton(KeyBindingFrameCancelButton)

    SkinButton(KeyBindingFrameOkayButton)
    SkinButton(KeyBindingFrameOkayButton)
    KeyBindingFrameOkayButton:ClearAllPoints()
    KeyBindingFrameOkayButton:SetPoint("RIGHT", KeyBindingFrameCancelButton, "LEFT", -2*bpad, 0)

    SkinButton(KeyBindingFrameUnbindButton)
    SkinButton(KeyBindingFrameUnbindButton)
    KeyBindingFrameUnbindButton:ClearAllPoints()
    KeyBindingFrameUnbindButton:SetPoint("RIGHT", KeyBindingFrameOkayButton, "LEFT", -2*bpad, 0)

    for key = 1, KEY_BINDINGS_DISPLAYED do
      for btn = 1, 2 do
        local button = _G["KeyBindingFrameBinding"..key.."Key"..btn.."Button"]
        StripTextures(button)
        SkinButton(button)
        button:SetScript("OnMouseDown", function() end)
        button:SetScript("OnMouseUp", function() end)
      end
    end
  end)
end)
