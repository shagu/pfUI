pfUI:RegisterModule("addons", function ()
  pfUI.addons = CreateFrame("Frame", "pfAddons", UIParent)
  pfUI.addons:SetFrameStrata("DIALOG")
  pfUI.addons:SetHeight(450)
  pfUI.addons:SetWidth(420)
  pfUI.addons:SetPoint("CENTER", 0,0)
  pfUI.addons:EnableMouseWheel(1)
  pfUI.addons:SetMovable(true)
  pfUI.addons:EnableMouse(true)
  pfUI.addons:SetScript("OnMouseDown", function() pfUI.addons:StartMoving() end)
  pfUI.addons:SetScript("OnMouseUp", function() pfUI.addons:StopMovingOrSizing() end)
  pfUI.addons:Hide()

  CreateBackdrop(pfUI.addons, nil, true, .75)

  pfUI.addons:SetScript("OnHide", function()
    if pfUI.addons.hasChanged then
      pfUI.gui:Reload()
      pfUI.addons.hasChanged = nil
    end
  end)

  tinsert(UISpecialFrames,"pfAddons")

  pfUI.addons.caption = pfUI.addons:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.addons.caption:SetFont(pfUI.font_default, C.global.font_size + 4, "OUTLINE")
  pfUI.addons.caption:SetTextColor(.2, 1, .8, 1)
  pfUI.addons.caption:SetPoint("TOP", 0, -10)
  pfUI.addons.caption:SetJustifyH("LEFT")
  pfUI.addons.caption:SetText(T["Addon List"])

  pfUI.addons.close = CreateFrame("Button", "pfBagClose", pfUI.addons)
  pfUI.addons.close:SetPoint("TOPRIGHT", -C.appearance.border.default*2,-C.appearance.border.default*2 )
  CreateBackdrop(pfUI.addons.close)
  pfUI.addons.close:SetHeight(15)
  pfUI.addons.close:SetWidth(15)
  pfUI.addons.close.texture = pfUI.addons.close:CreateTexture("pfBagClose")
  pfUI.addons.close.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\close")
  pfUI.addons.close.texture:ClearAllPoints()
  pfUI.addons.close.texture:SetPoint("TOPLEFT", pfUI.addons.close, "TOPLEFT", 4, -4)
  pfUI.addons.close.texture:SetPoint("BOTTOMRIGHT", pfUI.addons.close, "BOTTOMRIGHT", -4, 4)
  pfUI.addons.close.texture:SetVertexColor(1,.25,.25,1)
  pfUI.addons.close:SetScript("OnEnter", function ()
    CreateBackdrop(pfUI.addons.close)
    pfUI.addons.close.backdrop:SetBackdropBorderColor(1,.25,.25,1)
  end)

  pfUI.addons.close:SetScript("OnLeave", function ()
    CreateBackdrop(pfUI.addons.close)
  end)

  pfUI.addons.close:SetScript("OnClick", function()
    pfUI.addons:Hide()
  end)

  pfUI.addons.scroll = CreateScrollFrame("pfAddonListScroll", pfUI.addons)
  pfUI.addons.scroll:SetHeight(400)
  pfUI.addons.scroll:SetWidth(400)
  pfUI.addons.scroll:SetPoint("BOTTOM", 0, 10)

  pfUI.addons.scroll.backdrop = CreateFrame("Frame", nil, pfUI.addons.scroll)
  pfUI.addons.scroll.backdrop:SetFrameLevel(1)
  pfUI.addons.scroll.backdrop:SetPoint("TOPLEFT", pfUI.addons.scroll, "TOPLEFT", -5, 5)
  pfUI.addons.scroll.backdrop:SetPoint("BOTTOMRIGHT", pfUI.addons.scroll, "BOTTOMRIGHT", 5, -5)
  CreateBackdrop(pfUI.addons.scroll.backdrop, nil, true)

  pfUI.addons.list = CreateScrollChild("pfAddonList", pfUI.addons.scroll)
  pfUI.addons.list:RegisterEvent("ADDON_LOADED")
  pfUI.addons.list:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.addons.list:SetHeight(GetNumAddOns() * 25)

  pfUI.addons.list:SetScript("OnEvent", function()
    for i=1, GetNumAddOns() do
      local aname, atitle, anote = GetAddOnInfo(i)

      -- basic frame
      if not pfUI.addons.list[i] then
        pfUI.addons.list[i] = CreateFrame("Frame", nil, pfUI.addons.list)
        local frame = pfUI.addons.list[i]

        frame:SetWidth(350)
        frame:SetHeight(25)
        frame:SetBackdrop(pfUI.backdrop_underline)
        frame:SetBackdropBorderColor(.1,.1,.1,1)
        frame:SetPoint("TOPLEFT", 25, i * -25)

        -- caption
        frame.caption = frame:CreateFontString("Status", "LOW", "GameFontNormal")
        frame.caption:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
        frame.caption:SetAllPoints(frame)
        frame.caption:SetFontObject(GameFontWhite)
        frame.caption:SetJustifyH("LEFT")
        frame.caption:SetText(atitle)

        -- input field
        frame.input = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        frame.input:SetFrameLevel(3)
        frame.input:SetNormalTexture("")
        frame.input:SetPushedTexture("")
        frame.input:SetHighlightTexture("")
        CreateBackdrop(frame.input, nil, true)
        --frame.input:SetBackdrop(pfUI.backdrop)
        frame.input:SetBackdropBorderColor(.3,.3,.3,1)
        frame.input:SetWidth(14)
        frame.input:SetHeight(14)
        frame.input:SetPoint("TOPRIGHT" , 0, -4)
        frame.input:SetID(i)
        frame.input:SetScript("OnClick", function ()
          if this:GetChecked() then
            EnableAddOn(this:GetID())
          else
            DisableAddOn(this:GetID())
          end
          pfUI.addons.hasChanged = true
        end)
      end

      if IsAddOnLoaded(i) then
        pfUI.addons.list[i].input:SetChecked()
        pfUI.addons.list[i].caption:SetAlpha(1)
      else
        pfUI.addons.list[i].caption:SetAlpha(.5)
      end
    end
  end)

  -- add main menu button
  local pfUIAddonButton = CreateFrame("Button", "GameMenuButtonPFUIAddOns", GameMenuFrame, "GameMenuButtonTemplate")
  pfUIAddonButton:SetPoint("TOP", 0, -32)
  pfUIAddonButton:SetText(T["AddOns"])
  pfUIAddonButton:SetScript("OnClick", function()
    pfUI.addons:Show()
    HideUIPanel(GameMenuFrame)
  end)
  SkinButton(pfUIAddonButton)

  local point, relativeTo, relativePoint, xOffset, yOffset = GameMenuButtonOptions:GetPoint()
  GameMenuButtonOptions:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset - 22)
  GameMenuFrame:SetHeight(GameMenuFrame:GetHeight()+22)

end)
