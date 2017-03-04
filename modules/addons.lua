pfUI:RegisterModule("addons", function ()
  -- dialog
  pfUI.addons = CreateFrame("Frame", "pfAddons", UIParent)
  pfUI.addons:SetHeight(400)
  pfUI.addons:SetWidth(400)
  pfUI.addons:SetPoint("CENTER", 0,0)
  pfUI.addons:EnableMouseWheel(1)
  CreateBackdrop(pfUI.addons, nil, nil, .8)
  pfUI.addons:SetMovable(true)
  pfUI.addons:EnableMouse(true)
  pfUI.addons:SetScript("OnMouseDown",function()
    pfUI.addons:StartMoving()
  end)

  pfUI.addons:SetScript("OnMouseUp",function()
    pfUI.addons:StopMovingOrSizing()
  end)
  pfUI.addons:Hide()
  pfUI.addons:SetScript("OnHide", function()
    if pfUI.addons.hasChanged then
      pfUI.gui:Reload()
      pfUI.addons.hasChanged = nil
    end
  end)
  tinsert(UISpecialFrames,"pfAddons")

  -- title
  pfUI.addons.caption = pfUI.addons:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.addons.caption:SetFont(pfUI.font_default, C.global.font_size + 4, "OUTLINE")
  pfUI.addons.caption:SetTextColor(.2, 1, .8, 1)
  pfUI.addons.caption:SetPoint("TOP", 0, -10)
  pfUI.addons.caption:SetJustifyH("LEFT")
  pfUI.addons.caption:SetText("Addon List")

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

  -- list
  pfUI.addons.list = CreateFrame("Frame", "pfAddonList", pfUI.addons)
  pfUI.addons.list:RegisterEvent("ADDON_LOADED")
  pfUI.addons.list:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.addons.list:SetHeight(GetNumAddOns() * 25)
  pfUI.addons.list:SetWidth(350)
  pfUI.addons.list:SetPoint("CENTER", 0,0)
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
        frame:SetPoint("TOPLEFT", 12.5, i * -25 + 25)

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

  pfUI.addons.scroll = CreateFrame("ScrollFrame", "pfAddonListScroll", pfUI.addons)
  pfUI.addons.scroll:SetHeight(350)
  pfUI.addons.scroll:SetWidth(375)
  pfUI.addons.scroll:SetPoint("BOTTOM", 0, 10)
  pfUI.addons.scroll:EnableMouseWheel(1)

  pfUI.addons.scroll:SetScript("OnMouseWheel", function()
    local current = pfUI.addons.scroll:GetVerticalScroll()
    local new = current + arg1*-20
    local max = pfUI.addons.scroll:GetVerticalScrollRange()
    if new > -20 and new < max + 20 then
      pfUI.addons.scroll:SetVerticalScroll(new)
    end

    if new < 0 then pfUI.addons.scroll:SetVerticalScroll(0) end
    if new > max then pfUI.addons.scroll:SetVerticalScroll(max) end
  end)

  pfUI.addons.scroll:SetScrollChild(pfUI.addons.list)
  pfUI.addons.scroll:SetVerticalScroll(0)

  function pfUI.addons.scroll:UpdateScrollState()
    local current = ceil(pfUI.addons.scroll:GetVerticalScroll())
    local max = ceil(pfUI.addons.scroll:GetVerticalScrollRange())
    pfUI.addons.deco.up:Show()
    pfUI.addons.deco.down:Show()

    if max > 20 then
      if current < max then
        pfUI.addons.deco.down.visible = 1
        pfUI.addons.deco.down:Show()
        pfUI.addons.deco.down:SetAlpha(.2)
      end
      if current > 5 then
          pfUI.addons.deco.up.visible = 1
          pfUI.addons.deco.up:Show()
          pfUI.addons.deco.up:SetAlpha(.2)
      end
      if current > max - 5 then
        pfUI.addons.deco.down.visible = 0
      end
      if current < 5 then
        pfUI.addons.deco.up.visible = 0
      end
    else
      pfUI.addons.deco.up.visible = 0
      pfUI.addons.deco.down.visible = 0
    end
  end

  -- [[ config section ]] --
  pfUI.addons.deco = CreateFrame("Frame", nil, pfUI.addons)
  pfUI.addons.deco:ClearAllPoints()
  pfUI.addons.deco:SetPoint("TOPLEFT", pfUI.addons.scroll, "TOPLEFT", -5, 5)
  pfUI.addons.deco:SetPoint("BOTTOMRIGHT", pfUI.addons.scroll, "BOTTOMRIGHT", 5, -5)
  CreateBackdrop(pfUI.addons.deco, nil, nil, .8)

  pfUI.addons.deco.up = CreateFrame("Frame", nil, pfUI.addons.deco)
  pfUI.addons.deco.up:SetPoint("TOPLEFT", pfUI.addons.scroll, "TOPLEFT", -5, 5)
  pfUI.addons.deco.up:SetPoint("TOPRIGHT", pfUI.addons.scroll, "TOPRIGHT", 5, -5)
  pfUI.addons.deco.up:SetHeight(16)
  pfUI.addons.deco.up:SetAlpha(0)
  pfUI.addons.deco.up.visible = 0
  pfUI.addons.deco.up.texture = pfUI.addons.deco.up:CreateTexture()
  pfUI.addons.deco.up.texture:SetAllPoints()
  pfUI.addons.deco.up.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\gradient_up")
  pfUI.addons.deco.up.texture:SetVertexColor(.2,1,.8)
  pfUI.addons.deco.up:SetScript("OnUpdate", function()
    pfUI.addons.scroll:UpdateScrollState()
    if pfUI.addons.deco.up.visible == 0 and pfUI.addons.deco.up:GetAlpha() > 0 then
      pfUI.addons.deco.up:SetAlpha(pfUI.addons.deco.up:GetAlpha() - 0.01)
    elseif pfUI.addons.deco.up.visible == 0 and pfUI.addons.deco.up:GetAlpha() <= 0 then
      pfUI.addons.deco.up:Hide()
    end

    if pfUI.addons.deco.up.visible == 1 and pfUI.addons.deco.up:GetAlpha() > .15 then
      pfUI.addons.deco.up:SetAlpha(pfUI.addons.deco.up:GetAlpha() - 0.01)
    end
  end)

  pfUI.addons.deco.down = CreateFrame("Frame", nil, pfUI.addons.deco)
  pfUI.addons.deco.down:SetPoint("BOTTOMLEFT", pfUI.addons.scroll, "BOTTOMLEFT", -5, -5)
  pfUI.addons.deco.down:SetPoint("BOTTOMRIGHT", pfUI.addons.scroll, "BOTTOMRIGHT", 5, 5)
  pfUI.addons.deco.down:SetHeight(16)
  pfUI.addons.deco.down:SetHeight(16)
  pfUI.addons.deco.down:SetWidth(pfUI.addons.deco:GetWidth())
  pfUI.addons.deco.down:SetAlpha(0)
  pfUI.addons.deco.down.visible = 0
  pfUI.addons.deco.down.texture = pfUI.addons.deco.down:CreateTexture()
  pfUI.addons.deco.down.texture:SetAllPoints()
  pfUI.addons.deco.down.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\gradient_down")
  pfUI.addons.deco.down.texture:SetVertexColor(.2,1,.8)
  pfUI.addons.deco.down:SetScript("OnUpdate", function()
    pfUI.addons.scroll:UpdateScrollState()
    if pfUI.addons.deco.down.visible == 0 and pfUI.addons.deco.down:GetAlpha() > 0 then
      pfUI.addons.deco.down:SetAlpha(pfUI.addons.deco.down:GetAlpha() - 0.01)
    elseif pfUI.addons.deco.down.visible == 0 and pfUI.addons.deco.down:GetAlpha() <= 0 then
      pfUI.addons.deco.down:Hide()
    end

    if pfUI.addons.deco.down.visible == 1 and pfUI.addons.deco.down:GetAlpha() > .15 then
      pfUI.addons.deco.down:SetAlpha(pfUI.addons.deco.down:GetAlpha() - 0.01)
    end
  end)
end)
