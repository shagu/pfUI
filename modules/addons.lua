pfUI:RegisterModule("addons", function ()
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

  -- addon window
  pfUI.addons = CreateFrame("Frame", "pfAddons", UIParent)
  pfUI.addons:SetFrameStrata("DIALOG")
  pfUI.addons:SetHeight(490)
  pfUI.addons:SetWidth(420)
  pfUI.addons:SetPoint("CENTER", 0,0)
  pfUI.addons:EnableMouseWheel(1)
  pfUI.addons:SetMovable(true)
  pfUI.addons:EnableMouse(true)
  pfUI.addons:SetScript("OnMouseDown", function() this:StartMoving() end)
  pfUI.addons:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)
  pfUI.addons:Hide()

  CreateBackdrop(pfUI.addons, nil, true, .75)

  pfUI.addons:SetScript("OnHide", function()
    UIDropDownMenu_ClearAll(this.profile.dropdown)
    if this.hasChanged then
      pfUI.gui:Reload()
      this.hasChanged = nil
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

  -- addons profile
  local function GetSelectedAddonsList()
    local selected_addons = {}
    for i, frame in ipairs(pfUI.addons.list) do
      if frame.input:GetChecked() then
        table.insert(selected_addons, frame.aname)
      end
    end
    return selected_addons
  end

  local function SetAddonProfile(profile)
    UIDropDownMenu_SetText(profile, pfUI.addons.profile.dropdown)

    -- create new profile if not existing
    if not pfUI_addon_profiles[profile] then
      pfUI_addon_profiles[profile] = GetSelectedAddonsList()
    end

    -- load profile
    local selected_list = pfUI_addon_profiles[profile]
    for i=1, GetNumAddOns() do
      local active = false
      local f = pfUI.addons.list[i]

      for i_i, n in ipairs(selected_list) do
        if f.aname == n then
          active = true
          break
        end
      end

      if active then
        if not f.input:GetChecked() then
          f.input:Click()
        end
      else
        if f.input:GetChecked() then
          f.input:Click()
        end
      end
    end
  end

  -- addon profiles
  pfUI.addons.profile = CreateFrame("Frame", "pfAddonListProfile", pfUI.addons)
  pfUI.addons.profile:SetScript("OnShow", function()
    pfUI_addon_profiles[T["Current"]] = GetSelectedAddonsList()
    UIDropDownMenu_SetText(T["Current"], pfUI.addons.profile.dropdown)
  end)

  pfUI.addons.profile:SetPoint("TOP", pfUI.addons, "TOP", 0, -34)
  pfUI.addons.profile:SetHeight(37)
  pfUI.addons.profile:SetWidth(410)
  CreateBackdrop(pfUI.addons.profile, nil, true)

  -- addon profile: title
  pfUI.addons.profile.caption = pfUI.addons.profile:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.addons.profile.caption:SetFontObject(GameFontWhite)
  pfUI.addons.profile.caption:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
  pfUI.addons.profile.caption:SetPoint("TOPLEFT", 10, -12)
  pfUI.addons.profile.caption:SetText(T["Addon Profile"])

  -- addon profile: dropdown
  pfUI.addons.profile.dropdown = CreateFrame("Frame", "pfAddonListProfileList", pfUI.addons.profile, "UIDropDownMenuTemplate")
  pfUI.addons.profile.dropdown:ClearAllPoints()
  pfUI.addons.profile.dropdown:SetPoint("TOPRIGHT", -51, -5)
  SkinDropDown(pfUI.addons.profile.dropdown)
  UIDropDownMenu_SetWidth(220, pfUI.addons.profile.dropdown)
  UIDropDownMenu_SetButtonWidth(220, pfUI.addons.profile.dropdown)
  UIDropDownMenu_Initialize(pfUI.addons.profile.dropdown, function()
    local info = {}
    for name, list in pairs(pfUI_addon_profiles) do
      info.text = name
      info.checked = false
      info.func = function()
        UIDropDownMenu_SetSelectedID(pfUI.addons.profile.dropdown, this:GetID(), 0)
        SetAddonProfile(this:GetText())
      end
      UIDropDownMenu_AddButton(info)
    end
  end)

  -- addon profile: create
  pfUI.addons.profile.create = CreateFrame("Button", "pfAddonListProfileCreate", pfUI.addons.profile, "UIPanelButtonTemplate")
  CreateBackdrop(pfUI.addons.profile.create, nil, true)
  SkinButton(pfUI.addons.profile.create)
  pfUI.addons.profile.create:SetWidth(25)
  pfUI.addons.profile.create:SetHeight(25)
  pfUI.addons.profile.create:SetPoint("LEFT", pfUI.addons.profile.dropdown.backdrop, "RIGHT", 35, 0)
  pfUI.addons.profile.create:GetFontString():SetPoint("CENTER", 1, 0)
  pfUI.addons.profile.create:SetText("+")
  pfUI.addons.profile.create:SetTextColor(.5,1,.5,1)
  pfUI.addons.profile.create:SetScript("OnClick", function()
    CreateQuestionDialog(T["Please enter a name for the new profile."],
    function()
      local profile_name = this:GetParent().input:GetText()
      local bad = string.gsub(profile_name,"([%w%s]+)","")
      if bad ~= "" then
        message("\"" .. bad .. "\" " .. T["is not allowed in profile name"])
      else
        SetAddonProfile(profile_name)
      end
    end, false, true)
  end)

  -- addon profile: delete
  pfUI.addons.profile.delete = CreateFrame("Button", "pfAddonListProfileDelete", pfUI.addons.profile, "UIPanelButtonTemplate")
  CreateBackdrop(pfUI.addons.profile.delete, nil, true)
  SkinButton(pfUI.addons.profile.delete)
  pfUI.addons.profile.delete:SetWidth(25)
  pfUI.addons.profile.delete:SetHeight(25)
  pfUI.addons.profile.delete:SetPoint("LEFT", pfUI.addons.profile.dropdown.backdrop, "RIGHT", 5, 0)
  pfUI.addons.profile.delete:GetFontString():SetPoint("CENTER", 0, 0)
  pfUI.addons.profile.delete:SetText("-")
  pfUI.addons.profile.delete:SetTextColor(1,.5,.5,1)
  pfUI.addons.profile.delete:SetScript("OnClick", function()
    local profile_name = UIDropDownMenu_GetText(pfUI.addons.profile.dropdown)
    if profile_name then
      CreateQuestionDialog(T["Delete profile"] .. " '|cff33ffcc" .. profile_name .. "|r'?", function()
        pfUI_addon_profiles[profile_name] = nil
        SetAddonProfile(T["Current"])
      end)
    end
  end)

  -- addon list: scroll frame
  pfUI.addons.scroll = CreateScrollFrame("pfAddonListScroll", pfUI.addons)
  pfUI.addons.scroll:SetHeight(400)
  pfUI.addons.scroll:SetWidth(400)
  pfUI.addons.scroll:SetPoint("BOTTOM", 0, 10)

  pfUI.addons.scroll.backdrop = CreateFrame("Frame", nil, pfUI.addons.scroll)
  pfUI.addons.scroll.backdrop:SetFrameLevel(1)
  pfUI.addons.scroll.backdrop:SetPoint("TOPLEFT", pfUI.addons.scroll, "TOPLEFT", -5, 5)
  pfUI.addons.scroll.backdrop:SetPoint("BOTTOMRIGHT", pfUI.addons.scroll, "BOTTOMRIGHT", 5, -5)
  CreateBackdrop(pfUI.addons.scroll.backdrop, nil, true)

  -- addon list: scroll parent
  pfUI.addons.list = CreateScrollChild("pfAddonList", pfUI.addons.scroll)
  pfUI.addons.list:RegisterEvent("ADDON_LOADED")
  pfUI.addons.list:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.addons.list:SetHeight(GetNumAddOns() * 25 + 26)

  pfUI.addons.list:SetScript("OnEvent", function()
    for i=1, GetNumAddOns() do
      local aname, atitle, anote = GetAddOnInfo(i)

      -- basic frame
      if not pfUI.addons.list[i] then
        pfUI.addons.list[i] = CreateFrame("Button", nil, pfUI.addons.list)
        local frame = pfUI.addons.list[i]
        frame.aname = aname

        frame:SetWidth(350)
        frame:SetHeight(25)
        frame:SetPoint("TOPLEFT", 25, i * -25)

        frame:SetBackdrop(pfUI.backdrop_hover)
        frame:SetBackdropBorderColor(1,1,1,.04)

        frame:EnableMouse(1)
        frame:SetScript("OnEnter", function()
          this:SetBackdropBorderColor(1,1,1,.08)
        end)

        frame:SetScript("OnLeave", function()
          this:SetBackdropBorderColor(1,1,1,.04)
        end)

        frame:SetScript("OnClick", function()
          this.input:Click()
        end)

        -- caption
        frame.caption = frame:CreateFontString("Status", "LOW", "GameFontNormal")
        frame.caption:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
        frame.caption:SetPoint("LEFT", frame, "LEFT", 2, 0)
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
        frame.input:SetBackdropBorderColor(.3,.3,.3,1)
        frame.input:SetWidth(14)
        frame.input:SetHeight(14)
        frame.input:SetPoint("RIGHT" , -5, 1)
        frame.input:SetID(i)
        frame.input:SetScript("OnClick", function ()
          if this:GetChecked() then
            EnableAddOn(this:GetID())
          else
            DisableAddOn(this:GetID())
          end
          pfUI.addons.hasChanged = true
          local profile_name = UIDropDownMenu_GetText(pfUI.addons.profile.dropdown) or T["Current"]
          pfUI_addon_profiles[profile_name] = GetSelectedAddonsList()
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

  -- show only frames in visible range
  function pfUI.addons.scroll:ShowVisibleRange()
    local top_index, bottom_index, range
    range = floor(pfUI.addons.scroll:GetHeight() / 25)
    top_index = floor(pfUI.addons.scroll:GetVerticalScroll() / 25) > 0 and floor(pfUI.addons.scroll:GetVerticalScroll() / 25) or 1
    bottom_index = top_index + range
    for i=1, GetNumAddOns() do
      if i >= top_index and i <= bottom_index then
        pfUI.addons.list[i]:Show()
      else
        pfUI.addons.list[i]:Hide()
      end
    end
  end


end)
