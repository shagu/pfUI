pfUI:RegisterSkin("Popup Dialogs", "vanilla:tbc", function ()
  for i = 1, STATICPOPUP_NUMDIALOGS do
    -- Compatibility
    local money = _G["StaticPopup"..i.."MoneyInputFrame"]
    if money then -- tbc
      SkinMoneyInputFrame(money)
    end


    local dialog = _G["StaticPopup"..i]
    CreateBackdrop(dialog, nil, true, .75)
    CreateBackdropShadow(dialog)

    SkinCloseButton(_G[dialog:GetName().."CloseButton"], dialog, -6, -6)

    SkinButton(_G[dialog:GetName().."Button1"])
    SkinButton(_G[dialog:GetName().."Button2"])

    local editbox = _G[dialog:GetName().."EditBox"]
    editbox:DisableDrawLayer("BACKGROUND")
    CreateBackdrop(editbox)
    editbox:SetHeight(18)

    local wide_editbox = _G[dialog:GetName().."WideEditBox"]
    wide_editbox:DisableDrawLayer("BACKGROUND")
    CreateBackdrop(wide_editbox)
    wide_editbox:SetHeight(18)
    wide_editbox:ClearAllPoints()
    wide_editbox:SetPoint("BOTTOM", 0, 45)
  end
end)
