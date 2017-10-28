pfUI:RegisterModule("gui", function ()
  local function CreateConfig(parent, caption, category, config, widget, values, skip, named, type)
    -- parent object placement
    if parent.objectCount == nil then
      parent.objectCount = 1
    elseif not skip then
      parent.objectCount = parent.objectCount + 1
      parent.lineCount = 1
    end

    if skip then
      if parent.lineCount == nil then
        parent.lineCount = 1
      end

      if skip then
        parent.lineCount = parent.lineCount + 1
      end
    end

    if not caption then return end

    -- basic frame
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(420)
    frame:SetHeight(25)
    frame:SetPoint("TOPLEFT", 25, parent.objectCount * -25)
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function()
      this:SetBackdropBorderColor(1,1,1,.3)
    end)

    frame:SetScript("OnLeave", function()
      this:SetBackdropBorderColor(1,1,1,.15)
    end)

    if not widget or (widget and widget ~= "button") then

      frame:SetBackdrop(pfUI.backdrop_underline)
      frame:SetBackdropBorderColor(1,1,1,.15)

      -- caption
      frame.caption = frame:CreateFontString("Status", "LOW", "GameFontNormal")
      frame.caption:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
      frame.caption:SetAllPoints(frame)
      frame.caption:SetFontObject(GameFontWhite)
      frame.caption:SetJustifyH("LEFT")
      frame.caption:SetText(caption)
    end

    frame.configCategory = category
    frame.configEntry = config

    frame.category = category
    frame.config = config

    if widget == "color" then
      -- color picker
      frame.color = CreateFrame("Button", nil, frame)
      frame.color:SetWidth(24)
      frame.color:SetHeight(12)
      CreateBackdrop(frame.color)
      frame.color:SetPoint("TOPRIGHT" , 0, -4)
      frame.color.prev = frame.color.backdrop:CreateTexture("OVERLAY")
      frame.color.prev:SetAllPoints(frame.color)

      local cr, cg, cb, ca = strsplit(",", category[config])
      if not cr or not cg or not cb or not ca then
        cr, cg, cb, ca = 1, 1, 1, 1
      end
      frame.color.prev:SetTexture(cr,cg,cb,ca)

      frame.color:SetScript("OnClick", function()
        local cr, cg, cb, ca = strsplit(",", category[config])
        if not cr or not cg or not cb or not ca then
          cr, cg, cb, ca = 1, 1, 1, 1
        end
        local preview = this.prev

        function ColorPickerFrame.func()
          local r,g,b = ColorPickerFrame:GetColorRGB()
          local a = 1 - OpacitySliderFrame:GetValue()

          r = round(r, 1)
          g = round(g, 1)
          b = round(b, 1)
          a = round(a, 1)

          preview:SetTexture(r,g,b,a)

          if not this:GetParent():IsShown() then
            category[config] = r .. "," .. g .. "," .. b .. "," .. a
            pfUI.gui.settingChanged = true
          end
        end

        function ColorPickerFrame.cancelFunc()
          preview:SetTexture(cr,cg,cb,ca)
        end

        ColorPickerFrame.opacityFunc = ColorPickerFrame.func
        ColorPickerFrame.element = this
        ColorPickerFrame.opacity = 1 - ca
        ColorPickerFrame.hasOpacity = 1
        ColorPickerFrame:SetColorRGB(cr,cg,cb)
        ColorPickerFrame:SetFrameStrata("DIALOG")
        ShowUIPanel(ColorPickerFrame)
      end)
    end

    if widget == "warning" then
      CreateBackdrop(frame, nil, true)
      frame:SetBackdropBorderColor(1,.5,.5)
      frame:SetHeight(50)
      frame:SetPoint("TOPLEFT", 25, parent.objectCount * -35)
      parent.objectCount = parent.objectCount + 2
      frame.caption:SetJustifyH("CENTER")
      frame.caption:SetJustifyV("CENTER")
    end

    if widget == "header" then
      frame:SetBackdrop(nil)
      frame:SetHeight(40)
      parent.objectCount = parent.objectCount + 1
      frame.caption:SetJustifyH("LEFT")
      frame.caption:SetJustifyV("BOTTOM")
      frame.caption:SetTextColor(.2,1,.8,1)
      frame.caption:SetAllPoints(frame)
    end

    -- use text widget (default)
    if not widget or widget == "text" then
      -- input field
      frame.input = CreateFrame("EditBox", nil, frame)
      frame.input:SetTextColor(.2,1,.8,1)
      frame.input:SetJustifyH("RIGHT")

      frame.input:SetWidth(100)
      frame.input:SetHeight(16)
      frame.input:SetPoint("TOPRIGHT" , 0, -2)
      frame.input:SetFontObject(GameFontNormal)
      frame.input:SetAutoFocus(false)
      frame.input:SetText(category[config])
      frame.input:SetScript("OnEscapePressed", function(self)
        this:ClearFocus()
      end)

      frame.input:SetScript("OnTextChanged", function(self)
        if ( type and type ~= "number" ) or tonumber(this:GetText()) then
          if this:GetText() ~= this:GetParent().category[this:GetParent().config] then pfUI.gui.settingChanged = true end
          this:SetTextColor(.2,1,.8,1)
          this:GetParent().category[this:GetParent().config] = this:GetText()
        else
          this:SetTextColor(1,.3,.3,1)
        end
      end)
    end

    -- use button widget
    if widget == "button" then
      frame.button = CreateFrame("Button", "pfButton", frame, "UIPanelButtonTemplate")
      CreateBackdrop(frame.button, nil, true)
      SkinButton(frame.button)
      frame.button:SetWidth(100)
      frame.button:SetHeight(20)
      frame.button:SetPoint("TOPRIGHT", -(parent.lineCount-1) * 105, -5)
      frame.button:SetText(caption)
      frame.button:SetTextColor(1,1,1,1)
      frame.button:SetScript("OnClick", values)
    end

    -- use checkbox widget
    if widget == "checkbox" then
      -- input field
      frame.input = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
      frame.input:SetNormalTexture("")
      frame.input:SetPushedTexture("")
      frame.input:SetHighlightTexture("")
      CreateBackdrop(frame.input, nil, true)
      frame.input:SetWidth(14)
      frame.input:SetHeight(14)
      frame.input:SetPoint("TOPRIGHT" , 0, -4)
      frame.input:SetScript("OnClick", function ()
        if this:GetChecked() then
          this:GetParent().category[this:GetParent().config] = "1"
        else
          this:GetParent().category[this:GetParent().config] = "0"
        end
        pfUI.gui.settingChanged = true
      end)

      if category[config] == "1" then frame.input:SetChecked() end
    end

    -- use dropdown widget
    if widget == "dropdown" and values then
      if not pfUI.gui.ddc then pfUI.gui.ddc = 1 else pfUI.gui.ddc = pfUI.gui.ddc + 1 end
      local name = pfUI.gui.ddc
      if named then name = named end

      frame.input = CreateFrame("Frame", "pfUIDropDownMenu" .. name, frame, "UIDropDownMenuTemplate")
      frame.input:ClearAllPoints()
      frame.input:SetPoint("TOPRIGHT" , 20, 3)
      frame.input:Show()
      frame.input.point = "TOPRIGHT"
      frame.input.relativePoint = "BOTTOMRIGHT"
      frame.input.values = values

      frame.input.Refresh = function()
        local function CreateValues()
          local info = {}
          for i, k in pairs(frame.input.values) do
            -- get human readable
            local value, text = strsplit(":", k)
            text = text or value

            info.text = text
            info.checked = false
            info.func = function()
              UIDropDownMenu_SetSelectedID(frame.input, this:GetID(), 0)
              if category[config] ~= value then
                pfUI.gui.settingChanged = true
                category[config] = value
              end
            end

            UIDropDownMenu_AddButton(info)
            if category[config] == value then
              frame.input.current = i
            end
          end
        end

        UIDropDownMenu_Initialize(frame.input, CreateValues)
      end

      frame.input:Refresh()

      UIDropDownMenu_SetWidth(120, frame.input)
      UIDropDownMenu_SetButtonWidth(125, frame.input)
      UIDropDownMenu_JustifyText("RIGHT", frame.input)
      UIDropDownMenu_SetSelectedID(frame.input, frame.input.current)

      for i,v in ipairs({frame.input:GetRegions()}) do
        if v.SetTexture then v:Hide() end
        if v.SetTextColor then v:SetTextColor(.2,1,.8) end
        if v.SetBackdrop then CreateBackdrop(v) end
      end
    end

    return frame
  end

  pfUI.gui = CreateFrame("Frame", "pfConfigGUI", UIParent)
  pfUI.gui:Hide()
  pfUI.gui:SetWidth(640)
  pfUI.gui:SetHeight(480)
  pfUI.gui:SetFrameStrata("DIALOG")
  pfUI.gui:SetPoint("CENTER", 0, 0)
  table.insert(UISpecialFrames, "pfConfigGUI")

  function pfUI.gui:Reload()
    CreateQuestionDialog(T["Some settings need to reload the UI to take effect.\nDo you want to reloadUI now?"],
      function()
        pfUI.gui.settingChanged = nil
        ReloadUI()
      end)
  end

  pfUI.gui:SetScript("OnShow",function()
    pfUI.gui.settingChanged = pfUI.gui.delaySettingChanged
    pfUI.gui.delaySettingChanged = nil

    -- exit unlock mode
    if pfUI.unlock and pfUI.unlock:IsShown() then
      pfUI.unlock:Hide()
    end

    -- exit hoverbind mode
    if pfUI.hoverbind and pfUI.hoverbind:IsShown() then
      pfUI.hoverbind:Hide()
    end
  end)

  pfUI.gui:SetScript("OnHide",function()
    if ColorPickerFrame and ColorPickerFrame:IsShown() then
      ColorPickerFrame:Hide()
    end

    if pfUI.gui.settingChanged then
      pfUI.gui:Reload()
    end
    pfUI.gui:Hide()
  end)


  CreateBackdrop(pfUI.gui, nil, true, 0.75)

  pfUI.gui:SetMovable(true)
  pfUI.gui:EnableMouse(true)
  pfUI.gui:SetScript("OnMouseDown",function()
    this:StartMoving()
  end)

  pfUI.gui:SetScript("OnMouseUp",function()
    this:StopMovingOrSizing()
  end)

  -- gui decorations
  pfUI.gui.title = pfUI.gui:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.title:SetFontObject(GameFontWhite)
  pfUI.gui.title:SetPoint("TOPLEFT", pfUI.gui, "TOPLEFT", 5, -8)
  pfUI.gui.title:SetWidth(73)
  pfUI.gui.title:SetJustifyH("RIGHT")
  pfUI.gui.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\DieDieDie.ttf", 16)
  pfUI.gui.title:SetText("|cff33ffccpf|rUI")

  pfUI.gui.version = pfUI.gui:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.version:SetFontObject(GameFontWhite)
  pfUI.gui.version:SetPoint("TOPLEFT", pfUI.gui, "TOPLEFT", 82, -8)
  pfUI.gui.version:SetWidth(75)
  pfUI.gui.version:SetJustifyH("LEFT")
  pfUI.gui.version:SetFont("Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf", 12)
  pfUI.gui.version:SetText("|caaaaaaaav" .. pfUI.version.string)

  pfUI.gui.close = CreateFrame("Button", "pfQuestionDialogClose", pfUI.gui)
  pfUI.gui.close:SetPoint("TOPRIGHT", -5, -5)
  pfUI.api.CreateBackdrop(pfUI.gui.close)
  pfUI.gui.close:SetHeight(12)
  pfUI.gui.close:SetWidth(12)
  pfUI.gui.close.texture = pfUI.gui.close:CreateTexture("pfQuestionDialogCloseTex")
  pfUI.gui.close.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\close")
  pfUI.gui.close.texture:ClearAllPoints()
  pfUI.gui.close.texture:SetAllPoints(pfUI.gui.close)
  pfUI.gui.close.texture:SetVertexColor(1,.25,.25,1)
  pfUI.gui.close:SetScript("OnEnter", function ()
    this.backdrop:SetBackdropBorderColor(1,.25,.25,1)
  end)

  pfUI.gui.close:SetScript("OnLeave", function ()
    pfUI.api.CreateBackdrop(this)
  end)

  pfUI.gui.close:SetScript("OnClick", function()
   this:GetParent():Hide()
  end)

  -- initialize dropdown menus
  pfUI.gui.dropdowns = { }

  pfUI.gui.dropdowns.languages = {
    -- "deDE:German",
    -- "enGB:British English",
    "enUS:English",
    --"esES:Spanish (European)",
    --"esMX:Spanish (Latin American)",
    "frFR:French",
    "koKR:Korean",
    "ruRU:Russian",
    "zhCN:Chinese (simplified; China)",
    "zhTW:Chinese (traditional; Taiwan)",
    -- http://wowprogramming.com/docs/api/GetLocale
  }

  -- dropdown menu items
  pfUI.gui.dropdowns.fonts = {
    "Interface\\AddOns\\pfUI\\fonts\\BigNoodleTitling.ttf:BigNoodleTitling",
    "Interface\\AddOns\\pfUI\\fonts\\Continuum.ttf:Continuum",
    "Interface\\AddOns\\pfUI\\fonts\\DieDieDie.ttf:DieDieDie",
    "Interface\\AddOns\\pfUI\\fonts\\Expressway.ttf:Expressway",
    "Interface\\AddOns\\pfUI\\fonts\\Homespun.ttf:Homespun",
    "Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf:Myriad-Pro",
    "Interface\\AddOns\\pfUI\\fonts\\PT-Sans-Narrow-Bold.ttf:PT-Sans-Narrow-Bold",
    "Interface\\AddOns\\pfUI\\fonts\\PT-Sans-Narrow-Regular.ttf:PT-Sans-Narrow-Regular"
  }

  -- add locale dependent client fonts to the list
  if GetLocale() == "enUS" or GetLocale() == "frFR" or GetLocale() == "deDE" or GetLocale() == "ruRU" then
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\ARIALN.TTF:ARIALN")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\FRIZQT__.TTF:FRIZQT")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\MORPHEUS.TTF:MORPHEUS")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\SKURRI.TTF:SKURRI")
  elseif GetLocale() == "koKR" then
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\2002.TTF:2002")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\2002B.TTF:2002B")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\ARIALN.TTF:ARIALN")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\FRIZQT__.TTF:FRIZQT")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\K_Damage.TTF:K_Damage")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\K_Pagetext.TTF:K_Pagetext")
  elseif GetLocale() == "zhCN" then
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\ARIALN.TTF:ARIALN")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\FRIZQT__.TTF:FRIZQT")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\FZBWJW.TTF:FZBWJW")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\FZJZJW.TTF:FZJZJW")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\FZLBJW.TTF:FZLBJW")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\FZXHJW.TTF:FZXHJW")
    table.insert(pfUI.gui.dropdowns.fonts, "Fonts\\FZXHLJW.TTF:FZXHLJW")
  end

  pfUI.gui.dropdowns.uf_animationspeed = {
    "1:" .. T["Instant"],
    "2:" .. T["Very Fast"],
    "3:" .. T["Fast"],
    "5:" .. T["Medium"],
    "8:" .. T["Slow"],
    "13:" .. T["Very Slow"],
  }

  pfUI.gui.dropdowns.uf_portrait_position = {
    "bar:" .. T["Healthbar Embedded"],
    "left:" .. T["Left"],
    "right:" .. T["Right"],
    "off:" .. T["Disabled"]
  }

  pfUI.gui.dropdowns.uf_buff_position = {
    "top:" .. T["Top"],
    "bottom:" .. T["Bottom"],
    "off:" .. T["Disabled"]
  }

  pfUI.gui.dropdowns.uf_layout = {
    "default:" .. T["Default"],
    "tukui:TukUI"
  }

  pfUI.gui.dropdowns.uf_texts = {
    "none:" .. T["Disable"],
    "unit:" .. T["Unit String"],
    "name:" .. T["Name"],
    "level:" .. T["Level"],
    "class:" .. T["Class"],
    "healthdyn:" .. T["Health - Auto"],
    "health:" .. T["Health - Current"],
    "healthmax:" .. T["Health - Max"],
    "healthperc:" .. T["Health - Percentage"],
    "healthmiss:" .. T["Health - Missing"],
    "healthminmax:" .. T["Health - Min/Max"],
    "powerdyn:" .. T["Mana - Auto"],
    "power:" .. T["Mana - Current"],
    "powermax:" .. T["Mana - Max"],
    "powerperc:" .. T["Mana - Percentage"],
    "powermiss:" .. T["Mana - Missing"],
    "powerminmax:" .. T["Mana - Min/Max"],
  }

  pfUI.gui.dropdowns.panel_values = {
    "none:" .. T["Disable"],
    "time:" .. T["Clock"],
    "fps:" .. T["FPS & Ping"],
    "exp:" .. T["XP Percentage"],
    "gold:" .. T["Gold"],
    "friends:" .. T["Friends Online"],
    "guild:" .. T["Guild Online"],
    "durability:" .. T["Item Durability"],
    "zone:" .. T["Zone Name"],
    "combat:" .. T["Combat Timer"],
    "ammo:" .. T["Ammo Counter"],
    "soulshard:" .. T["Soulshard Counter"],
    "bagspace:" .. T["Bagspace"]
  }

  pfUI.gui.dropdowns.tooltip_position = {
    "bottom:" .. T["Bottom"],
    "chat:" .. T["Dodge"],
    "cursor:" .. T["Cursor"]
  }

  pfUI.gui.dropdowns.gmserver_text = {
    "elysium:" .. T["Elysium Based Core"],
  }

  pfUI.gui.dropdowns.minimap_cords_position = {
    "topleft:" .. T["Top Left"],
    "topright:" .. T["Top Right"],
    "bottomleft:" .. T["Bottom Left"],
    "bottomright:" .. T["Bottom Right"],
    "off:" .. T["Disabled"]
  }

  pfUI.gui.dropdowns.num_actionbar_buttons = BarLayoutOptions(NUM_ACTIONBAR_BUTTONS)
  pfUI.gui.dropdowns.num_shapeshift_slots = BarLayoutOptions(NUM_SHAPESHIFT_SLOTS)
  pfUI.gui.dropdowns.num_pet_action_slots = BarLayoutOptions(NUM_PET_ACTION_SLOTS)

  -- main tab frame
  pfUI.gui.tabs = CreateTabFrame(pfUI.gui, "LEFT")
  pfUI.gui.tabs:SetPoint("TOPLEFT", pfUI.gui, "TOPLEFT", 0, -25)
  pfUI.gui.tabs:SetPoint("BOTTOMRIGHT", pfUI.gui, "BOTTOMRIGHT", 0, 0)


  -- [[ Settings ]]
  pfUI.gui.tabs.settings = pfUI.gui.tabs:CreateTabChild(T["Settings"], nil, nil, nil, true)
  pfUI.gui.tabs.settings.tabs = CreateTabFrame(pfUI.gui.tabs.settings, "TOP", true)

  -- >> Global
  pfUI.gui.tabs.settings.tabs.general = pfUI.gui.tabs.settings.tabs:CreateTabChild(T["General"], 70)
  pfUI.gui.tabs.settings.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Language"], C.global, "language", "dropdown", pfUI.gui.dropdowns.languages)
      CreateConfig(this, T["Enable Region Compatible Font"], C.global, "force_region", "checkbox")
      CreateConfig(this, T["Standard Text Font"], C.global, "font_default", "dropdown", pfUI.gui.dropdowns.fonts)
      CreateConfig(this, T["Standard Text Font Size"], C.global, "font_size")
      CreateConfig(this, T["Unit Frame Text Font"], C.global, "font_unit", "dropdown", pfUI.gui.dropdowns.fonts)
      CreateConfig(this, T["Unit Frame Text Size"], C.global, "font_unit_size")
      CreateConfig(this, T["Scrolling Combat Text Font"], C.global, "font_combat", "dropdown", pfUI.gui.dropdowns.fonts)
      CreateConfig(this, T["Enable Pixel Perfect (Native Resolution)"], C.global, "pixelperfect", "checkbox")
      CreateConfig(this, T["Enable Offscreen Frame Positions"], C.global, "offscreen", "checkbox")
      CreateConfig(this, T["Enable Single Line UIErrors"], C.global, "errors_limit", "checkbox")
      CreateConfig(this, T["Disable All UIErrors"], C.global, "errors_hide", "checkbox")

      -- Delete / Reset
      CreateConfig(this, T["Delete / Reset"], nil, nil, "header")

      CreateConfig(this, T["|cffff5555EVERYTHING"], C.global, "profile", "button", function()
        CreateQuestionDialog(T["Do you really want to reset |cffffaaaaEVERYTHING|r?\n\nThis will reset:\n - Current Configuration\n - Current Frame Positions\n - Firstrun Wizard\n - Addon Cache\n - Saved Profiles"],
          function()
            _G["pfUI_init"] = {}
            _G["pfUI_config"] = {}
            _G["pfUI_playerDB"] = {}
            _G["pfUI_profiles"] = {}
            pfUI:LoadConfig()
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end)

      CreateConfig(this, T["Cache"], C.global, "profile", "button", function()
        CreateQuestionDialog(T["Do you really want to reset the Cache?"],
          function()
            _G["pfUI_playerDB"] = {}
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end, true)

      CreateConfig(this, T["Firstrun"], C.global, "profile", "button", function()
        CreateQuestionDialog(T["Do you really want to reset the Firstrun Wizard Settings?"],
          function()
            _G["pfUI_init"] = {}
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end, true)

      CreateConfig(this, T["Configuration"], C.global, "profile", "button", function()
        CreateQuestionDialog(T["Do you really want to reset your configuration?\nThis also includes frame positions"],
          function()
            _G["pfUI_config"] = {}
            pfUI:LoadConfig()
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end, true)


      -- Profiles
      CreateConfig(this, T["Profile"], nil, nil, "header")
      local values = {}
      for name, config in pairs(pfUI_profiles) do table.insert(values, name) end

      local function pfUpdateProfiles()
        local values = {}
        for name, config in pairs(pfUI_profiles) do table.insert(values, name) end
        pfUIDropDownMenuProfile.values = values
        pfUIDropDownMenuProfile.Refresh()
      end

      CreateConfig(this, T["Select profile"], C.global, "profile", "dropdown", values, false, "Profile")

      -- load profile
      CreateConfig(this, T["Load profile"], C.global, "profile", "button", function()
        if C.global.profile and pfUI_profiles[C.global.profile] then
          CreateQuestionDialog(T["Load profile"] .. " '|cff33ffcc" .. C.global.profile .. "|r'?", function()
            local selp = C.global.profile
            _G["pfUI_config"] = CopyTable(pfUI_profiles[C.global.profile])
            C.global.profile = selp
            ReloadUI()
          end)
        end
      end)

      -- delete profile
      CreateConfig(this, T["Delete profile"], C.global, "profile", "button", function()
        if C.global.profile and pfUI_profiles[C.global.profile] then
          CreateQuestionDialog(T["Delete profile"] .. " '|cff33ffcc" .. C.global.profile .. "|r'?", function()
            pfUI_profiles[C.global.profile] = nil
            pfUpdateProfiles()
            this:GetParent():Hide()
          end)
        end
      end, true)

      -- save profile
      CreateConfig(this, T["Save profile"], C.global, "profile", "button", function()
        if C.global.profile and pfUI_profiles[C.global.profile] then
          CreateQuestionDialog(T["Save current settings to profile"] .. " '|cff33ffcc" .. C.global.profile .. "|r'?", function()
            if pfUI_profiles[C.global.profile] then
              pfUI_profiles[C.global.profile] = CopyTable(C)
            end
            this:GetParent():Hide()
          end)
        end
      end, true)

      -- create profile
      CreateConfig(this, T["Create Profile"], C.global, "profile", "button", function()
        CreateQuestionDialog(T["Please enter a name for the new profile.\nExisting profiles sharing the same name will be overwritten."],
        function()
          local profile = this:GetParent().input:GetText()
          local bad = string.gsub(profile,"([%w%s]+)","")
          if bad~="" then
            message("\"" .. bad .. "\" " .. T["is not allowed in profile name"])
          else
            profile = (string.gsub(profile,"^%s*(.-)%s*$", "%1"))
            if profile and profile ~= "" then
              pfUI_profiles[profile] = CopyTable(C)
              pfUpdateProfiles()
              this:GetParent():Hide()
            end
          end
        end, false, true)
      end, true)

      this.setup = true
    end
  end)

  -- >> Appearance
  pfUI.gui.tabs.settings.tabs.appearance = pfUI.gui.tabs.settings.tabs:CreateTabChild(T["Appearance"], 70)
  pfUI.gui.tabs.settings.tabs.appearance:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Background Color"], C.appearance.border, "background", "color")
      CreateConfig(this, T["Border Color"], C.appearance.border, "color", "color")
      CreateConfig(this) -- spacer
      CreateConfig(this, T["Global Border Size"], C.appearance.border, "default")
      CreateConfig(this, T["Action Bar Border Size"], C.appearance.border, "actionbars")
      CreateConfig(this, T["Unit Frame Border Size"], C.appearance.border, "unitframes")
      CreateConfig(this, T["Panel Border Size"], C.appearance.border, "panels")
      CreateConfig(this, T["Chat Border Size"], C.appearance.border, "chat")
      CreateConfig(this, T["Bags Border Size"], C.appearance.border, "bags")
      this.setup = true
    end
  end)

  -- >> Cooldown
  pfUI.gui.tabs.settings.tabs.cooldown = pfUI.gui.tabs.settings.tabs:CreateTabChild(T["Cooldown"], 70)
  pfUI.gui.tabs.settings.tabs.cooldown:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Cooldown Color (Less than 3 Sec)"], C.appearance.cd, "lowcolor", "color")
      CreateConfig(this, T["Cooldown Color (Seconds)"], C.appearance.cd, "normalcolor", "color")
      CreateConfig(this, T["Cooldown Color (Minutes)"], C.appearance.cd, "minutecolor", "color")
      CreateConfig(this, T["Cooldown Color (Hours)"], C.appearance.cd, "hourcolor", "color")
      CreateConfig(this, T["Cooldown Color (Days)"], C.appearance.cd, "daycolor", "color")
      CreateConfig(this, T["Cooldown Text Threshold"], C.appearance.cd, "threshold")
      CreateConfig(this, T["Cooldown Text Font Size"], C.appearance.cd, "font_size")
      CreateConfig(this, T["Display Debuff Durations"], C.appearance.cd, "debuffs", "checkbox")
      this.setup = true
    end
  end)

  -- >> GM-Mode
  pfUI.gui.tabs.settings.tabs.gm = pfUI.gui.tabs.settings.tabs:CreateTabChild(T["GM-Mode"], 70)
  pfUI.gui.tabs.settings.tabs.gm:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Disable GM-Mode"], C.gm, "disable", "checkbox")
      CreateConfig(this, T["Selected Core"], C.gm, "server", "dropdown", pfUI.gui.dropdowns.gmserver_text)

      this.setup = true
    end
  end)


  -- [[ UnitFrames ]]
  pfUI.gui.tabs.uf = pfUI.gui.tabs:CreateTabChild(T["Unit Frames"], nil, nil, nil, true)
  pfUI.gui.tabs.uf.tabs = CreateTabFrame(pfUI.gui.tabs.uf, "TOP", true)

  -- >> General
  pfUI.gui.tabs.uf.tabs.general = pfUI.gui.tabs.uf.tabs:CreateTabChild(T["General"], 70)
  pfUI.gui.tabs.uf.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Disable pfUI Unit Frames"], C.unitframes, "disable", "checkbox")
      CreateConfig(this, T["Enable Pastel Colors"], C.unitframes, "pastel", "checkbox")
      CreateConfig(this, T["Enable Custom Color Health Bars"], C.unitframes, "custom", "checkbox")
      CreateConfig(this, T["Custom Health Bar Color"], C.unitframes, "customcolor", "color")
      CreateConfig(this, T["Enable Custom Color Health Bar Background"], C.unitframes, "custombg", "checkbox")
      CreateConfig(this, T["Custom Health Bar Background Color"], C.unitframes, "custombgcolor", "color")
      CreateConfig(this, T["Healthbar Animation Speed"], C.unitframes, "animation_speed", "dropdown", pfUI.gui.dropdowns.uf_animationspeed)
      CreateConfig(this, T["Portrait Alpha"], C.unitframes, "portraitalpha")
      CreateConfig(this, T["Always Use 2D Portraits"], C.unitframes, "always2dportrait", "checkbox")
      CreateConfig(this, T["Enable 2D Portraits As Fallback"], C.unitframes, "portraittexture", "checkbox")
      CreateConfig(this, T["Unit Frame Layout"], C.unitframes, "layout", "dropdown", pfUI.gui.dropdowns.uf_layout)
      CreateConfig(this, T["Aggressive 40y-Range Check (Will break stuff)"], C.unitframes, "rangecheck", "checkbox")
      CreateConfig(this, T["40y-Range Check Interval"], C.unitframes, "rangechecki")
      CreateConfig(this, T["Combopoint Size"], C.unitframes, "combosize")
      CreateConfig(this, T["Abbreviate Numbers (4200 -> 4.2k)"], C.unitframes, "abbrevnum", "checkbox")
      CreateConfig(this, T["Show PvP Icon"], C.unitframes.player, "showPVP", "checkbox")
      CreateConfig(this, T["Enable Energy Ticks"], C.unitframes.player, "energy", "checkbox")
      this.setup = true
    end
  end)

  -- >> Player
  pfUI.gui.tabs.uf.tabs.player = pfUI.gui.tabs.uf.tabs:CreateTabChild(T["Player"], 70)
  pfUI.gui.tabs.uf.tabs.player:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Display Player Frame"], C.unitframes.player, "visible", "checkbox")
      CreateConfig(this, T["Portrait Position"], C.unitframes.player, "portrait", "dropdown", pfUI.gui.dropdowns.uf_portrait_position)
      CreateConfig(this, T["Health Bar Width"], C.unitframes.player, "width")
      CreateConfig(this, T["Health Bar Height"], C.unitframes.player, "height")
      CreateConfig(this, T["Power Bar Height"], C.unitframes.player, "pheight")
      CreateConfig(this, T["Spacing"], C.unitframes.player, "pspace")
      CreateConfig(this, T["Buff Position"], C.unitframes.player, "buffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Buff Size"], C.unitframes.player, "buffsize")
      CreateConfig(this, T["Buff Limit"], C.unitframes.player, "bufflimit")
      CreateConfig(this, T["Buffs Per Row"], C.unitframes.player, "buffperrow")
      CreateConfig(this, T["Debuff Position"], C.unitframes.player, "debuffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Debuff Size"], C.unitframes.player, "debuffsize")
      CreateConfig(this, T["Debuff Limit"], C.unitframes.player, "debufflimit")
      CreateConfig(this, T["Debuffs Per Row"], C.unitframes.player, "debuffperrow")
      CreateConfig(this, T["Invert Health Bar"], C.unitframes.player, "invert_healthbar", "checkbox")
      CreateConfig(this, T["Enable Buff Indicators"], C.unitframes.player, "buff_indicator", "checkbox")
      CreateConfig(this, T["Enable Debuff Indicators"], C.unitframes.player, "debuff_indicator", "checkbox")
      CreateConfig(this, T["Enable Clickcast"], C.unitframes.player, "clickcast", "checkbox")
      CreateConfig(this, T["Enable Range Fading"], C.unitframes.player, "faderange", "checkbox")
      CreateConfig(this, T["Show Tooltip On Mouseover"], C.unitframes.player, "showtooltip", "checkbox")
      CreateConfig(this, T["Enable Health Color in Text"], C.unitframes.player, "healthcolor", "checkbox")
      CreateConfig(this, T["Enable Power Color in Text"], C.unitframes.player, "powercolor", "checkbox")
      CreateConfig(this, T["Enable Level Color in Text"], C.unitframes.player, "levelcolor", "checkbox")
      CreateConfig(this, T["Enable Class Color in Text"], C.unitframes.player, "classcolor", "checkbox")
      CreateConfig(this, T["Health Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.player, "txthpleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.player, "txthpcenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.player, "txthpright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Power Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.player, "txtpowerleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.player, "txtpowercenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.player, "txtpowerright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      this.setup = true
    end
  end)

  -- >> Target
  pfUI.gui.tabs.uf.tabs.target = pfUI.gui.tabs.uf.tabs:CreateTabChild(T["Target"], 70)
  pfUI.gui.tabs.uf.tabs.target:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Display Target Frame"], C.unitframes.target, "visible", "checkbox")
      CreateConfig(this, T["Enable Target Switch Animation"], C.unitframes.target, "animation", "checkbox")
      CreateConfig(this, T["Portrait Position"], C.unitframes.target, "portrait", "dropdown", pfUI.gui.dropdowns.uf_portrait_position)
      CreateConfig(this, T["Health Bar Width"], C.unitframes.target, "width")
      CreateConfig(this, T["Health Bar Height"], C.unitframes.target, "height")
      CreateConfig(this, T["Power Bar Height"], C.unitframes.target, "pheight")
      CreateConfig(this, T["Spacing"], C.unitframes.target, "pspace")
      CreateConfig(this, T["Buff Position"], C.unitframes.target, "buffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Buff Size"], C.unitframes.target, "buffsize")
      CreateConfig(this, T["Buff Limit"], C.unitframes.target, "bufflimit")
      CreateConfig(this, T["Buffs Per Row"], C.unitframes.target, "buffperrow")
      CreateConfig(this, T["Debuff Position"], C.unitframes.target, "debuffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Debuff Size"], C.unitframes.target, "debuffsize")
      CreateConfig(this, T["Debuff Limit"], C.unitframes.target, "debufflimit")
      CreateConfig(this, T["Debuffs Per Row"], C.unitframes.target, "debuffperrow")
      CreateConfig(this, T["Invert Health Bar"], C.unitframes.target, "invert_healthbar", "checkbox")
      CreateConfig(this, T["Enable Buff Indicators"], C.unitframes.target, "buff_indicator", "checkbox")
      CreateConfig(this, T["Enable Debuff Indicators"], C.unitframes.target, "debuff_indicator", "checkbox")
      CreateConfig(this, T["Enable Clickcast"], C.unitframes.target, "clickcast", "checkbox")
      CreateConfig(this, T["Enable Range Fading"], C.unitframes.target, "faderange", "checkbox")
      CreateConfig(this, T["Show Tooltip On Mouseover"], C.unitframes.target, "showtooltip", "checkbox")
      CreateConfig(this, T["Enable Health Color in Text"], C.unitframes.target, "healthcolor", "checkbox")
      CreateConfig(this, T["Enable Power Color in Text"], C.unitframes.target, "powercolor", "checkbox")
      CreateConfig(this, T["Enable Level Color in Text"], C.unitframes.target, "levelcolor", "checkbox")
      CreateConfig(this, T["Enable Class Color in Text"], C.unitframes.target, "classcolor", "checkbox")
      CreateConfig(this, T["Health Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.target, "txthpleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.target, "txthpcenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.target, "txthpright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Power Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.target, "txtpowerleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.target, "txtpowercenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.target, "txtpowerright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      this.setup = true
    end
  end)

  -- >> Target-Target
  pfUI.gui.tabs.uf.tabs.targettarget = pfUI.gui.tabs.uf.tabs:CreateTabChild(T["Target-Target"], 70)
  pfUI.gui.tabs.uf.tabs.targettarget:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Display Target of Target Frame"], C.unitframes.ttarget, "visible", "checkbox")
      CreateConfig(this, T["Portrait Position"], C.unitframes.ttarget, "portrait", "dropdown", pfUI.gui.dropdowns.uf_portrait_position)
      CreateConfig(this, T["Health Bar Width"], C.unitframes.ttarget, "width")
      CreateConfig(this, T["Health Bar Height"], C.unitframes.ttarget, "height")
      CreateConfig(this, T["Power Bar Height"], C.unitframes.ttarget, "pheight")
      CreateConfig(this, T["Spacing"], C.unitframes.ttarget, "pspace")
      CreateConfig(this, T["Buff Position"], C.unitframes.ttarget, "buffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Buff Size"], C.unitframes.ttarget, "buffsize")
      CreateConfig(this, T["Buff Limit"], C.unitframes.ttarget, "bufflimit")
      CreateConfig(this, T["Buffs Per Row"], C.unitframes.ttarget, "buffperrow")
      CreateConfig(this, T["Debuff Position"], C.unitframes.ttarget, "debuffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Debuff Size"], C.unitframes.ttarget, "debuffsize")
      CreateConfig(this, T["Debuff Limit"], C.unitframes.ttarget, "debufflimit")
      CreateConfig(this, T["Debuffs Per Row"], C.unitframes.ttarget, "debuffperrow")
      CreateConfig(this, T["Invert Health Bar"], C.unitframes.ttarget, "invert_healthbar", "checkbox")
      CreateConfig(this, T["Enable Buff Indicators"], C.unitframes.ttarget, "buff_indicator", "checkbox")
      CreateConfig(this, T["Enable Debuff Indicators"], C.unitframes.ttarget, "debuff_indicator", "checkbox")
      CreateConfig(this, T["Enable Clickcast"], C.unitframes.ttarget, "clickcast", "checkbox")
      CreateConfig(this, T["Enable Range Fading"], C.unitframes.ttarget, "faderange", "checkbox")
      CreateConfig(this, T["Show Tooltip On Mouseover"], C.unitframes.ttarget, "showtooltip", "checkbox")
      CreateConfig(this, T["Enable Health Color in Text"], C.unitframes.ttarget, "healthcolor", "checkbox")
      CreateConfig(this, T["Enable Power Color in Text"], C.unitframes.ttarget, "powercolor", "checkbox")
      CreateConfig(this, T["Enable Level Color in Text"], C.unitframes.ttarget, "levelcolor", "checkbox")
      CreateConfig(this, T["Enable Class Color in Text"], C.unitframes.ttarget, "classcolor", "checkbox")
      CreateConfig(this, T["Health Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.ttarget, "txthpleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.ttarget, "txthpcenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.ttarget, "txthpright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Power Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.ttarget, "txtpowerleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.ttarget, "txtpowercenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.ttarget, "txtpowerright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      this.setup = true
    end
  end)

  -- >> Pet
  pfUI.gui.tabs.uf.tabs.pet = pfUI.gui.tabs.uf.tabs:CreateTabChild(T["Pet"], 70)
  pfUI.gui.tabs.uf.tabs.pet:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Display Pet Frame"], C.unitframes.pet, "visible", "checkbox")
      CreateConfig(this, T["Portrait Position"], C.unitframes.pet, "portrait", "dropdown", pfUI.gui.dropdowns.uf_portrait_position)
      CreateConfig(this, T["Health Bar Width"], C.unitframes.pet, "width")
      CreateConfig(this, T["Health Bar Height"], C.unitframes.pet, "height")
      CreateConfig(this, T["Power Bar Height"], C.unitframes.pet, "pheight")
      CreateConfig(this, T["Spacing"], C.unitframes.pet, "pspace")
      CreateConfig(this, T["Buff Position"], C.unitframes.pet, "buffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Buff Size"], C.unitframes.pet, "buffsize")
      CreateConfig(this, T["Buff Limit"], C.unitframes.pet, "bufflimit")
      CreateConfig(this, T["Buffs Per Row"], C.unitframes.pet, "buffperrow")
      CreateConfig(this, T["Debuff Position"], C.unitframes.pet, "debuffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Debuff Size"], C.unitframes.pet, "debuffsize")
      CreateConfig(this, T["Debuff Limit"], C.unitframes.pet, "debufflimit")
      CreateConfig(this, T["Debuffs Per Row"], C.unitframes.pet, "debuffperrow")
      CreateConfig(this, T["Invert Health Bar"], C.unitframes.pet, "invert_healthbar", "checkbox")
      CreateConfig(this, T["Enable Buff Indicators"], C.unitframes.pet, "buff_indicator", "checkbox")
      CreateConfig(this, T["Enable Debuff Indicators"], C.unitframes.pet, "debuff_indicator", "checkbox")
      CreateConfig(this, T["Enable Clickcast"], C.unitframes.pet, "clickcast", "checkbox")
      CreateConfig(this, T["Enable Range Fading"], C.unitframes.pet, "faderange", "checkbox")
      CreateConfig(this, T["Show Tooltip On Mouseover"], C.unitframes.pet, "showtooltip", "checkbox")
      CreateConfig(this, T["Enable Health Color in Text"], C.unitframes.pet, "healthcolor", "checkbox")
      CreateConfig(this, T["Enable Power Color in Text"], C.unitframes.pet, "powercolor", "checkbox")
      CreateConfig(this, T["Enable Level Color in Text"], C.unitframes.pet, "levelcolor", "checkbox")
      CreateConfig(this, T["Enable Class Color in Text"], C.unitframes.pet, "classcolor", "checkbox")
      CreateConfig(this, T["Health Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.pet, "txthpleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.pet, "txthpcenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.pet, "txthpright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Power Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.pet, "txtpowerleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.pet, "txtpowercenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.pet, "txtpowerright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      this.setup = true
    end
  end)

  -- >> Focus
  pfUI.gui.tabs.uf.tabs.focus = pfUI.gui.tabs.uf.tabs:CreateTabChild(T["Focus"], 70)
  pfUI.gui.tabs.uf.tabs.focus:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Display Focus Frame"], C.unitframes.focus, "visible", "checkbox")
      CreateConfig(this, T["Portrait Position"], C.unitframes.focus, "portrait", "dropdown", pfUI.gui.dropdowns.uf_portrait_position)
      CreateConfig(this, T["Health Bar Width"], C.unitframes.focus, "width")
      CreateConfig(this, T["Health Bar Height"], C.unitframes.focus, "height")
      CreateConfig(this, T["Power Bar Height"], C.unitframes.focus, "pheight")
      CreateConfig(this, T["Spacing"], C.unitframes.focus, "pspace")
      CreateConfig(this, T["Buff Position"], C.unitframes.focus, "buffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Buff Size"], C.unitframes.focus, "buffsize")
      CreateConfig(this, T["Buff Limit"], C.unitframes.focus, "bufflimit")
      CreateConfig(this, T["Buffs Per Row"], C.unitframes.focus, "buffperrow")
      CreateConfig(this, T["Debuff Position"], C.unitframes.focus, "debuffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Debuff Size"], C.unitframes.focus, "debuffsize")
      CreateConfig(this, T["Debuff Limit"], C.unitframes.focus, "debufflimit")
      CreateConfig(this, T["Debuffs Per Row"], C.unitframes.focus, "debuffperrow")
      CreateConfig(this, T["Invert Health Bar"], C.unitframes.focus, "invert_healthbar", "checkbox")
      CreateConfig(this, T["Enable Buff Indicators"], C.unitframes.focus, "buff_indicator", "checkbox")
      CreateConfig(this, T["Enable Debuff Indicators"], C.unitframes.focus, "debuff_indicator", "checkbox")
      CreateConfig(this, T["Enable Clickcast"], C.unitframes.focus, "clickcast", "checkbox")
      CreateConfig(this, T["Enable Range Fading"], C.unitframes.focus, "faderange", "checkbox")
      CreateConfig(this, T["Show Tooltip On Mouseover"], C.unitframes.focus, "showtooltip", "checkbox")
      CreateConfig(this, T["Enable Health Color in Text"], C.unitframes.focus, "healthcolor", "checkbox")
      CreateConfig(this, T["Enable Power Color in Text"], C.unitframes.focus, "powercolor", "checkbox")
      CreateConfig(this, T["Enable Level Color in Text"], C.unitframes.focus, "levelcolor", "checkbox")
      CreateConfig(this, T["Enable Class Color in Text"], C.unitframes.focus, "classcolor", "checkbox")
      CreateConfig(this, T["Health Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.focus, "txthpleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.focus, "txthpcenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.focus, "txthpright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Power Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.focus, "txtpowerleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.focus, "txtpowercenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.focus, "txtpowerright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      this.setup = true
    end
  end)

  -- [[ GroupFrames ]]
  pfUI.gui.tabs.gf = pfUI.gui.tabs:CreateTabChild(T["Group Frames"], nil, nil, nil, true)
  pfUI.gui.tabs.gf.tabs = CreateTabFrame(pfUI.gui.tabs.gf, "TOP", true)

  -- >> General
  pfUI.gui.tabs.gf.tabs.general = pfUI.gui.tabs.gf.tabs:CreateTabChild(T["General"], 70)
  pfUI.gui.tabs.gf.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Show Self in Group Frames"], C.unitframes, "selfingroup", "checkbox")
      CreateConfig(this, T["Hide Group Frames While In Raid"], C.unitframes.group, "hide_in_raid", "checkbox")
      CreateConfig(this, T["Use Raid Frames To Display Group Members"], C.unitframes, "raidforgroup", "checkbox")
      CreateConfig(this, T["Show Hots as Buff Indicators"], C.unitframes, "show_hots", "checkbox")
      CreateConfig(this, T["Show Hots of all Classes"], C.unitframes, "all_hots", "checkbox")
      CreateConfig(this, T["Show Procs as Buff Indicators"], C.unitframes, "show_procs", "checkbox")
      CreateConfig(this, T["Show Procs of all Classes"], C.unitframes, "all_procs", "checkbox")
      CreateConfig(this, T["Buff Indicator Size"], C.unitframes, "indicator_size")
      CreateConfig(this, T["Only Show Indicators for Dispellable Debuffs"], C.unitframes, "debuffs_class", "checkbox")
      CreateConfig(this, T["Clickcast Spells"], nil, nil, "header")
      CreateConfig(this, T["Click Action"], C.unitframes, "clickcast", nil, nil, nil, nil, "STRING")
      CreateConfig(this, T["Shift-Click Action"], C.unitframes, "clickcast_shift", nil, nil, nil, nil, "STRING")
      CreateConfig(this, T["Alt-Click Action"], C.unitframes, "clickcast_alt", nil, nil, nil, nil, "STRING")
      CreateConfig(this, T["Ctrl-Click Action"], C.unitframes, "clickcast_ctrl", nil, nil, nil, nil, "STRING")
      this.setup = true
    end
  end)

  -- >> Raid
  pfUI.gui.tabs.gf.tabs.raid = pfUI.gui.tabs.gf.tabs:CreateTabChild(T["Raid"], 70)
  pfUI.gui.tabs.gf.tabs.raid:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Display Raid Frames"], C.unitframes.raid, "visible", "checkbox")
      CreateConfig(this, T["Portrait Position"], C.unitframes.raid, "portrait", "dropdown", pfUI.gui.dropdowns.uf_portrait_position)
      CreateConfig(this, T["Health Bar Width"], C.unitframes.raid, "width")
      CreateConfig(this, T["Health Bar Height"], C.unitframes.raid, "height")
      CreateConfig(this, T["Power Bar Height"], C.unitframes.raid, "pheight")
      CreateConfig(this, T["Spacing"], C.unitframes.raid, "pspace")
      CreateConfig(this, T["Buff Position"], C.unitframes.raid, "buffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Buff Size"], C.unitframes.raid, "buffsize")
      CreateConfig(this, T["Buff Limit"], C.unitframes.raid, "bufflimit")
      CreateConfig(this, T["Buffs Per Row"], C.unitframes.raid, "buffperrow")
      CreateConfig(this, T["Debuff Position"], C.unitframes.raid, "debuffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Debuff Size"], C.unitframes.raid, "debuffsize")
      CreateConfig(this, T["Debuff Limit"], C.unitframes.raid, "debufflimit")
      CreateConfig(this, T["Debuffs Per Row"], C.unitframes.raid, "debuffperrow")
      CreateConfig(this, T["Invert Health Bar"], C.unitframes.raid, "invert_healthbar", "checkbox")
      CreateConfig(this, T["Enable Buff Indicators"], C.unitframes.raid, "buff_indicator", "checkbox")
      CreateConfig(this, T["Enable Debuff Indicators"], C.unitframes.raid, "debuff_indicator", "checkbox")
      CreateConfig(this, T["Enable Clickcast"], C.unitframes.raid, "clickcast", "checkbox")
      CreateConfig(this, T["Enable Range Fading"], C.unitframes.raid, "faderange", "checkbox")
      CreateConfig(this, T["Show Tooltip On Mouseover"], C.unitframes.raid, "showtooltip", "checkbox")
      CreateConfig(this, T["Enable Health Color in Text"], C.unitframes.raid, "healthcolor", "checkbox")
      CreateConfig(this, T["Enable Power Color in Text"], C.unitframes.raid, "powercolor", "checkbox")
      CreateConfig(this, T["Enable Level Color in Text"], C.unitframes.raid, "levelcolor", "checkbox")
      CreateConfig(this, T["Enable Class Color in Text"], C.unitframes.raid, "classcolor", "checkbox")
      CreateConfig(this, T["Health Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.raid, "txthpleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.raid, "txthpcenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.raid, "txthpright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Power Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.raid, "txtpowerleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.raid, "txtpowercenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.raid, "txtpowerright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      this.setup = true
    end
  end)

  -- >> Group
  pfUI.gui.tabs.gf.tabs.group = pfUI.gui.tabs.gf.tabs:CreateTabChild(T["Group"], 70)
  pfUI.gui.tabs.gf.tabs.group:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Display Group Frames"], C.unitframes.group, "visible", "checkbox")
      CreateConfig(this, T["Portrait Position"], C.unitframes.group, "portrait", "dropdown", pfUI.gui.dropdowns.uf_portrait_position)
      CreateConfig(this, T["Health Bar Width"], C.unitframes.group, "width")
      CreateConfig(this, T["Health Bar Height"], C.unitframes.group, "height")
      CreateConfig(this, T["Power Bar Height"], C.unitframes.group, "pheight")
      CreateConfig(this, T["Spacing"], C.unitframes.group, "pspace")
      CreateConfig(this, T["Buff Position"], C.unitframes.group, "buffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Buff Size"], C.unitframes.group, "buffsize")
      CreateConfig(this, T["Buff Limit"], C.unitframes.group, "bufflimit")
      CreateConfig(this, T["Buffs Per Row"], C.unitframes.group, "buffperrow")
      CreateConfig(this, T["Debuff Position"], C.unitframes.group, "debuffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Debuff Size"], C.unitframes.group, "debuffsize")
      CreateConfig(this, T["Debuff Limit"], C.unitframes.group, "debufflimit")
      CreateConfig(this, T["Debuffs Per Row"], C.unitframes.group, "debuffperrow")
      CreateConfig(this, T["Invert Health Bar"], C.unitframes.group, "invert_healthbar", "checkbox")
      CreateConfig(this, T["Enable Buff Indicators"], C.unitframes.group, "buff_indicator", "checkbox")
      CreateConfig(this, T["Enable Debuff Indicators"], C.unitframes.group, "debuff_indicator", "checkbox")
      CreateConfig(this, T["Enable Clickcast"], C.unitframes.group, "clickcast", "checkbox")
      CreateConfig(this, T["Enable Range Fading"], C.unitframes.group, "faderange", "checkbox")
      CreateConfig(this, T["Show Tooltip On Mouseover"], C.unitframes.group, "showtooltip", "checkbox")
      CreateConfig(this, T["Enable Health Color in Text"], C.unitframes.group, "healthcolor", "checkbox")
      CreateConfig(this, T["Enable Power Color in Text"], C.unitframes.group, "powercolor", "checkbox")
      CreateConfig(this, T["Enable Level Color in Text"], C.unitframes.group, "levelcolor", "checkbox")
      CreateConfig(this, T["Enable Class Color in Text"], C.unitframes.group, "classcolor", "checkbox")
      CreateConfig(this, T["Health Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.group, "txthpleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.group, "txthpcenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.group, "txthpright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Power Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.group, "txtpowerleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.group, "txtpowercenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.group, "txtpowerright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      this.setup = true
    end
  end)

  -- >> Group-Target
  pfUI.gui.tabs.gf.tabs.grouptarget = pfUI.gui.tabs.gf.tabs:CreateTabChild(T["Group-Target"], 70)
  pfUI.gui.tabs.gf.tabs.grouptarget:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Display Group Target Frames"], C.unitframes.grouptarget, "visible", "checkbox")
      CreateConfig(this, T["Portrait Position"], C.unitframes.grouptarget, "portrait", "dropdown", pfUI.gui.dropdowns.uf_portrait_position)
      CreateConfig(this, T["Health Bar Width"], C.unitframes.grouptarget, "width")
      CreateConfig(this, T["Health Bar Height"], C.unitframes.grouptarget, "height")
      CreateConfig(this, T["Power Bar Height"], C.unitframes.grouptarget, "pheight")
      CreateConfig(this, T["Spacing"], C.unitframes.grouptarget, "pspace")
      CreateConfig(this, T["Buff Position"], C.unitframes.grouptarget, "buffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Buff Size"], C.unitframes.grouptarget, "buffsize")
      CreateConfig(this, T["Buff Limit"], C.unitframes.grouptarget, "bufflimit")
      CreateConfig(this, T["Buffs Per Row"], C.unitframes.grouptarget, "buffperrow")
      CreateConfig(this, T["Debuff Position"], C.unitframes.grouptarget, "debuffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Debuff Size"], C.unitframes.grouptarget, "debuffsize")
      CreateConfig(this, T["Debuff Limit"], C.unitframes.grouptarget, "debufflimit")
      CreateConfig(this, T["Debuffs Per Row"], C.unitframes.grouptarget, "debuffperrow")
      CreateConfig(this, T["Invert Health Bar"], C.unitframes.grouptarget, "invert_healthbar", "checkbox")
      CreateConfig(this, T["Enable Buff Indicators"], C.unitframes.grouptarget, "buff_indicator", "checkbox")
      CreateConfig(this, T["Enable Debuff Indicators"], C.unitframes.grouptarget, "debuff_indicator", "checkbox")
      CreateConfig(this, T["Enable Clickcast"], C.unitframes.grouptarget, "clickcast", "checkbox")
      CreateConfig(this, T["Enable Range Fading"], C.unitframes.grouptarget, "faderange", "checkbox")
      CreateConfig(this, T["Show Tooltip On Mouseover"], C.unitframes.grouptarget, "showtooltip", "checkbox")
      CreateConfig(this, T["Enable Health Color in Text"], C.unitframes.grouptarget, "healthcolor", "checkbox")
      CreateConfig(this, T["Enable Power Color in Text"], C.unitframes.grouptarget, "powercolor", "checkbox")
      CreateConfig(this, T["Enable Level Color in Text"], C.unitframes.grouptarget, "levelcolor", "checkbox")
      CreateConfig(this, T["Enable Class Color in Text"], C.unitframes.grouptarget, "classcolor", "checkbox")
      CreateConfig(this, T["Health Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.grouptarget, "txthpleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.grouptarget, "txthpcenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.grouptarget, "txthpright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Power Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.grouptarget, "txtpowerleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.grouptarget, "txtpowercenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.grouptarget, "txtpowerright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      this.setup = true
    end
  end)

  -- >> Group-Pet
  pfUI.gui.tabs.gf.tabs.grouppet = pfUI.gui.tabs.gf.tabs:CreateTabChild(T["Group-Pet"], 70)
  pfUI.gui.tabs.gf.tabs.grouppet:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Display Group Pet Frames"], C.unitframes.grouppet, "visible", "checkbox")
      CreateConfig(this, T["Portrait Position"], C.unitframes.grouppet, "portrait", "dropdown", pfUI.gui.dropdowns.uf_portrait_position)
      CreateConfig(this, T["Health Bar Width"], C.unitframes.grouppet, "width")
      CreateConfig(this, T["Health Bar Height"], C.unitframes.grouppet, "height")
      CreateConfig(this, T["Power Bar Height"], C.unitframes.grouppet, "pheight")
      CreateConfig(this, T["Spacing"], C.unitframes.grouppet, "pspace")
      CreateConfig(this, T["Buff Position"], C.unitframes.grouppet, "buffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Buff Size"], C.unitframes.grouppet, "buffsize")
      CreateConfig(this, T["Buff Limit"], C.unitframes.grouppet, "bufflimit")
      CreateConfig(this, T["Buffs Per Row"], C.unitframes.grouppet, "buffperrow")
      CreateConfig(this, T["Debuff Position"], C.unitframes.grouppet, "debuffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
      CreateConfig(this, T["Debuff Size"], C.unitframes.grouppet, "debuffsize")
      CreateConfig(this, T["Debuff Limit"], C.unitframes.grouppet, "debufflimit")
      CreateConfig(this, T["Debuffs Per Row"], C.unitframes.grouppet, "debuffperrow")
      CreateConfig(this, T["Invert Health Bar"], C.unitframes.grouppet, "invert_healthbar", "checkbox")
      CreateConfig(this, T["Enable Buff Indicators"], C.unitframes.grouppet, "buff_indicator", "checkbox")
      CreateConfig(this, T["Enable Debuff Indicators"], C.unitframes.grouppet, "debuff_indicator", "checkbox")
      CreateConfig(this, T["Enable Clickcast"], C.unitframes.grouppet, "clickcast", "checkbox")
      CreateConfig(this, T["Enable Range Fading"], C.unitframes.grouppet, "faderange", "checkbox")
      CreateConfig(this, T["Show Tooltip On Mouseover"], C.unitframes.grouppet, "showtooltip", "checkbox")
      CreateConfig(this, T["Enable Health Color in Text"], C.unitframes.grouppet, "healthcolor", "checkbox")
      CreateConfig(this, T["Enable Power Color in Text"], C.unitframes.grouppet, "powercolor", "checkbox")
      CreateConfig(this, T["Enable Level Color in Text"], C.unitframes.grouppet, "levelcolor", "checkbox")
      CreateConfig(this, T["Enable Class Color in Text"], C.unitframes.grouppet, "classcolor", "checkbox")
      CreateConfig(this, T["Health Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.grouppet, "txthpleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.grouppet, "txthpcenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.grouppet, "txthpright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Power Bar Texts"], nil, nil, "header")
      CreateConfig(this, T["Left Text"], C.unitframes.grouppet, "txtpowerleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Center Text"], C.unitframes.grouppet, "txtpowercenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
      CreateConfig(this, T["Right Text"], C.unitframes.grouppet, "txtpowerright", "dropdown", pfUI.gui.dropdowns.uf_texts)
      this.setup = true
    end
  end)


  -- [[ Combat ]]
  pfUI.gui.tabs.combat = pfUI.gui.tabs:CreateTabChild(T["Combat"], nil, nil, nil, true)
  pfUI.gui.tabs.combat.tabs = CreateTabFrame(pfUI.gui.tabs.combat, "TOP", true)

  -- >> General
  pfUI.gui.tabs.combat.tabs.general = pfUI.gui.tabs.combat.tabs:CreateTabChild(T["Combat"], 70)
  pfUI.gui.tabs.combat.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Enable Combat Glow Effects On Screen Edges"], C.appearance.infight, "screen", "checkbox")
      CreateConfig(this, T["Enable Combat Glow Effects On Unit Frames"], C.appearance.infight, "common", "checkbox")
      CreateConfig(this, T["Enable Combat Glow Effects On Group Frames"], C.appearance.infight, "group", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Bags & Bank ]]
  pfUI.gui.tabs.bags = pfUI.gui.tabs:CreateTabChild(T["Bags & Bank"], nil, nil, nil, true)
  pfUI.gui.tabs.bags.tabs = CreateTabFrame(pfUI.gui.tabs.bags, "TOP", true)

  -- >> General
  pfUI.gui.tabs.bags.tabs.general = pfUI.gui.tabs.bags.tabs:CreateTabChild(T["Bags & Bank"], 70)
  pfUI.gui.tabs.bags.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Disable Item Quality Color For \"Common\" Items"], C.appearance.bags, "borderlimit", "checkbox")
      CreateConfig(this, T["Enable Item Quality Color For Equipment Only"], C.appearance.bags, "borderonlygear", "checkbox")
      CreateConfig(this, T["Auto Sell Grey Items"], C.global, "autosell", "checkbox")
      CreateConfig(this, T["Auto Repair Items"], C.global, "autorepair", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Loot ]]
  pfUI.gui.tabs.loot = pfUI.gui.tabs:CreateTabChild(T["Loot"], nil, nil, nil, true)
  pfUI.gui.tabs.loot.tabs = CreateTabFrame(pfUI.gui.tabs.loot, "TOP", true)

  -- >> General
  pfUI.gui.tabs.loot.tabs.general = pfUI.gui.tabs.loot.tabs:CreateTabChild(T["Loot"], 70)
  pfUI.gui.tabs.loot.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Enable Auto-Resize Loot Frame"], C.loot, "autoresize", "checkbox")
      CreateConfig(this, T["Disable Loot Confirmation Dialog (Without Group)"], C.loot, "autopickup", "checkbox")
      CreateConfig(this, T["Enable Loot Window On MouseCursor"], C.loot, "mousecursor", "checkbox")
      CreateConfig(this, T["Enable Advanced Master Loot Menu"], C.loot, "advancedloot", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Minimap ]]
  pfUI.gui.tabs.minimap = pfUI.gui.tabs:CreateTabChild(T["Minimap"], nil, nil, nil, true)
  pfUI.gui.tabs.minimap.tabs = CreateTabFrame(pfUI.gui.tabs.minimap, "TOP", true)

  -- >> General
  pfUI.gui.tabs.minimap.tabs.general = pfUI.gui.tabs.minimap.tabs:CreateTabChild(T["Minimap"], 70)
  pfUI.gui.tabs.minimap.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Enable Zone Text On Minimap Mouseover"], C.appearance.minimap, "mouseoverzone", "checkbox")
      CreateConfig(this, T["Coordinates Location"], C.appearance.minimap, "coordsloc", "dropdown", pfUI.gui.dropdowns.minimap_cords_position)
      CreateConfig(this, T["Disable Minimap Buffs"], C.global, "hidebuff", "checkbox")
      CreateConfig(this, T["Disable Minimap Weapon Buffs"], C.global, "hidewbuff", "checkbox")
      CreateConfig(this, T["Show PvP Icon"], C.unitframes.player, "showPVPMinimap", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Actionbar ]]
  pfUI.gui.tabs.actionbar = pfUI.gui.tabs:CreateTabChild(T["Actionbar"], nil, nil, nil, true)
  pfUI.gui.tabs.actionbar.tabs = CreateTabFrame(pfUI.gui.tabs.actionbar, "TOP", true)

  -- >> General
  pfUI.gui.tabs.actionbar.tabs.general = pfUI.gui.tabs.actionbar.tabs:CreateTabChild(T["General"], 70)
  pfUI.gui.tabs.actionbar.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Icon Size"], C.bars, "icon_size")
      CreateConfig(this, T["Enable Action Bar Backgrounds"], C.bars, "background", "checkbox")
      CreateConfig(this, T["Enable Range Display On Hotkeys"], C.bars, "glowrange", "checkbox")
      CreateConfig(this, T["Range Display Color"], C.bars, "rangecolor", "color")
      CreateConfig(this, T["Show Macro Text"], C.bars, "showmacro", "checkbox")
      CreateConfig(this, T["Show Hotkey Text"], C.bars, "showkeybind", "checkbox")
      CreateConfig(this, T["Enable Range Based Auto Paging (Hunter)"], C.bars, "hunterbar", "checkbox")
      this.setup = true
    end
  end)

  -- >> Autohide
  pfUI.gui.tabs.actionbar.tabs.autohide = pfUI.gui.tabs.actionbar.tabs:CreateTabChild(T["Autohide"], 70)
  pfUI.gui.tabs.actionbar.tabs.autohide:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Seconds Until Action Bars Autohide"], C.bars, "hide_time")
      CreateConfig(this, T["Enable Autohide For BarActionMain"], C.bars, "hide_actionmain", "checkbox")
      CreateConfig(this, T["Enable Autohide For BarBottomLeft"], C.bars, "hide_bottomleft", "checkbox")
      CreateConfig(this, T["Enable Autohide For BarBottomRight"], C.bars, "hide_bottomright", "checkbox")
      CreateConfig(this, T["Enable Autohide For BarRight"], C.bars, "hide_right", "checkbox")
      CreateConfig(this, T["Enable Autohide For BarTwoRight"], C.bars, "hide_tworight", "checkbox")
      CreateConfig(this, T["Enable Autohide For BarShapeShift"], C.bars, "hide_shapeshift", "checkbox")
      CreateConfig(this, T["Enable Autohide For BarPet"], C.bars, "hide_pet", "checkbox")
      this.setup = true
    end
  end)

  -- >> Layout
  pfUI.gui.tabs.actionbar.tabs.layout = pfUI.gui.tabs.actionbar.tabs:CreateTabChild(T["Layout"], 70)
  pfUI.gui.tabs.actionbar.tabs.layout:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Main Actionbar (ActionMain)"], C.bars.actionmain, "formfactor", "dropdown", pfUI.gui.dropdowns.num_actionbar_buttons)
      CreateConfig(this, T["Second Actionbar (BottomLeft)"], C.bars.bottomleft, "formfactor", "dropdown", pfUI.gui.dropdowns.num_actionbar_buttons)
      CreateConfig(this, T["Left Actionbar (BottomRight)"], C.bars.bottomright, "formfactor", "dropdown", pfUI.gui.dropdowns.num_actionbar_buttons)
      CreateConfig(this, T["Right Actionbar (Right)"], C.bars.right, "formfactor", "dropdown", pfUI.gui.dropdowns.num_actionbar_buttons)
      CreateConfig(this, T["Vertical Actionbar (TwoRight)"], C.bars.tworight, "formfactor", "dropdown", pfUI.gui.dropdowns.num_actionbar_buttons)
      CreateConfig(this, T["Shapeshift Bar (BarShapeShift)"], C.bars.shapeshift, "formfactor", "dropdown", pfUI.gui.dropdowns.num_shapeshift_slots)
      CreateConfig(this, T["Pet Bar (BarPet)"], C.bars.pet, "formfactor", "dropdown", pfUI.gui.dropdowns.num_pet_action_slots)
      this.setup = true
    end
  end)


  -- [[ Panel ]]
  pfUI.gui.tabs.panel = pfUI.gui.tabs:CreateTabChild(T["Panel"], nil, nil, nil, true)
  pfUI.gui.tabs.panel.tabs = CreateTabFrame(pfUI.gui.tabs.panel, "TOP", true)

  -- >> General
  pfUI.gui.tabs.panel.tabs.general = pfUI.gui.tabs.panel.tabs:CreateTabChild(T["Panel"], 70)
  pfUI.gui.tabs.panel.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Use Unit Fonts"], C.panel, "use_unitfonts", "checkbox")
      CreateConfig(this, T["Left Panel: Left"], C.panel.left, "left", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(this, T["Left Panel: Center"], C.panel.left, "center", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(this, T["Left Panel: Right"], C.panel.left, "right", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(this, T["Right Panel: Left"], C.panel.right, "left", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(this, T["Right Panel: Center"], C.panel.right, "center", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(this, T["Right Panel: Right"], C.panel.right, "right", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(this, T["Other Panel: Minimap"], C.panel.other, "minimap", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(this, T["Always Show Experience And Reputation Bar"], C.panel.xp, "showalways", "checkbox")
      CreateConfig(this, T["Only Count Bagspace On Regular Bags"], C.panel.bag, "ignorespecial", "checkbox")
      CreateConfig(this, T["Enable Micro Bar"], C.panel.micro, "enable", "checkbox")
      CreateConfig(this, T["Enable 24h Clock"], C.global, "twentyfour", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Tooltip ]]
  pfUI.gui.tabs.tooltip = pfUI.gui.tabs:CreateTabChild(T["Tooltip"], nil, nil, nil, true)
  pfUI.gui.tabs.tooltip.tabs = CreateTabFrame(pfUI.gui.tabs.tooltip, "TOP", true)

  -- >> General
  pfUI.gui.tabs.tooltip.tabs.general = pfUI.gui.tabs.tooltip.tabs:CreateTabChild(T["Tooltip"], 70)
  pfUI.gui.tabs.tooltip.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Tooltip Position"], C.tooltip, "position", "dropdown", pfUI.gui.dropdowns.tooltip_position)
      CreateConfig(this, T["Enable Extended Guild Information"], C.tooltip, "extguild", "checkbox")
      CreateConfig(this, T["Custom Transparency"], C.tooltip, "alpha")
      CreateConfig(this, T["Always Show Item Comparison"], C.tooltip.compare, "showalways", "checkbox")
      CreateConfig(this, T["Always Show Extended Vendor Values"], C.tooltip.vendor, "showalways", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Castbar ]]
  pfUI.gui.tabs.castbar = pfUI.gui.tabs:CreateTabChild(T["Castbar"], nil, nil, nil, true)
  pfUI.gui.tabs.castbar.tabs = CreateTabFrame(pfUI.gui.tabs.castbar, "TOP", true)

  -- >> General
  pfUI.gui.tabs.castbar.tabs.general = pfUI.gui.tabs.castbar.tabs:CreateTabChild(T["Castbar"], 70)
  pfUI.gui.tabs.castbar.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Use Unit Fonts"], C.castbar, "use_unitfonts", "checkbox")
      CreateConfig(this, T["Casting Color"], C.appearance.castbar, "castbarcolor", "color")
      CreateConfig(this, T["Channeling Color"], C.appearance.castbar, "channelcolor", "color")
      CreateConfig(this, T["Disable Blizzard Castbar"], C.castbar.player, "hide_blizz", "checkbox")
      CreateConfig(this, T["Disable pfUI Player Castbar"], C.castbar.player, "hide_pfui", "checkbox")
      CreateConfig(this, T["Disable pfUI Target Castbar"], C.castbar.target, "hide_pfui", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Chat ]]
  pfUI.gui.tabs.chat = pfUI.gui.tabs:CreateTabChild(T["Chat"], nil, nil, nil, true)
  pfUI.gui.tabs.chat.tabs = CreateTabFrame(pfUI.gui.tabs.chat, "TOP", true)

  -- >> General
  pfUI.gui.tabs.chat.tabs.general = pfUI.gui.tabs.chat.tabs:CreateTabChild(T["General"], 70)
  pfUI.gui.tabs.chat.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Enable \"Loot & Spam\" Chat Window"], C.chat.right, "enable", "checkbox")
      CreateConfig(this, T["Inputbox Width"], C.chat.text, "input_width")
      CreateConfig(this, T["Inputbox Height"], C.chat.text, "input_height")
      CreateConfig(this, T["Enable Timestamps"], C.chat.text, "time", "checkbox")
      CreateConfig(this, T["Timestamp Format"], C.chat.text, "timeformat", nil, nil, nil, nil, "STRING")
      CreateConfig(this, T["Timestamp Brackets"], C.chat.text, "timebracket", nil, nil, nil, nil, "STRING")
      CreateConfig(this, T["Timestamp Color"], C.chat.text, "timecolor", "color")
      CreateConfig(this, T["Hide Channel Names"], C.chat.text, "channelnumonly", "checkbox")
      CreateConfig(this, T["Enable URL Detection"], C.chat.text, "detecturl", "checkbox")
      CreateConfig(this, T["Enable Class Colors"], C.chat.text, "classcolor", "checkbox")
      CreateConfig(this, T["Left Chat Width"], C.chat.left, "width")
      CreateConfig(this, T["Left Chat Height"], C.chat.left, "height")
      CreateConfig(this, T["Right Chat Width"], C.chat.right, "width")
      CreateConfig(this, T["Right Chat Height"], C.chat.right, "height")
      CreateConfig(this, T["Enable Right Chat Window"], C.chat.right, "alwaysshow", "checkbox")
      CreateConfig(this, T["Hide Combat Log"], C.chat.global, "combathide", "checkbox")
      CreateConfig(this, T["Enable Chat Dock Background"], C.chat.global, "tabdock", "checkbox")
      CreateConfig(this, T["Only Show Chat Dock On Mouseover"], C.chat.global, "tabmouse", "checkbox")
      CreateConfig(this, T["Enable Chat Tab Flashing"], C.chat.global, "chatflash", "checkbox")
      CreateConfig(this, T["Enable Custom Colors"], C.chat.global, "custombg", "checkbox")
      CreateConfig(this, T["Chat Background Color"], C.chat.global, "background", "color")
      CreateConfig(this, T["Chat Border Color"], C.chat.global, "border", "color")
      CreateConfig(this, T["Enable Custom Incoming Whispers Layout"], C.chat.global, "whispermod", "checkbox")
      CreateConfig(this, T["Incoming Whispers Color"], C.chat.global, "whisper", "color")
      CreateConfig(this, T["Enable Sticky Chat"], C.chat.global, "sticky", "checkbox")
      CreateConfig(this, T["Enable Chat Fade"], C.chat.global, "fadeout", "checkbox")
      CreateConfig(this, T["Seconds Before Chat Fade"], C.chat.global, "fadetime")
      CreateConfig(this, T["Mousewheel Scroll Speed"], C.chat.global, "scrollspeed")
      this.setup = true
    end
  end)


  -- [[ Nameplates ]]
  pfUI.gui.tabs.nameplates = pfUI.gui.tabs:CreateTabChild(T["Nameplates"], nil, nil, nil, true)
  pfUI.gui.tabs.nameplates.tabs = CreateTabFrame(pfUI.gui.tabs.nameplates, "TOP", true)

  -- General
  pfUI.gui.tabs.nameplates.tabs.general = pfUI.gui.tabs.nameplates.tabs:CreateTabChild(T["Nameplates"], 70)
  pfUI.gui.tabs.nameplates.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["Use Unit Fonts"], C.nameplates, "use_unitfonts", "checkbox")
      CreateConfig(this, T["Enable Castbars"], C.nameplates, "showcastbar", "checkbox")
      CreateConfig(this, T["Enable Spellname"], C.nameplates, "spellname", "checkbox")
      CreateConfig(this, T["Enable Debuffs"], C.nameplates, "showdebuffs", "checkbox")
      CreateConfig(this, T["Enable Clickthrough"], C.nameplates, "clickthrough", "checkbox")
      CreateConfig(this, T["Enable Overlap"], C.nameplates, "overlap", "checkbox")
      CreateConfig(this, T["Enable Mouselook With Right Click"], C.nameplates, "rightclick", "checkbox")
      CreateConfig(this, T["Right Click Auto Attack Threshold"], C.nameplates, "clickthreshold")
      CreateConfig(this, T["Enable Class Colors On Enemies"], C.nameplates, "enemyclassc", "checkbox")
      CreateConfig(this, T["Enable Class Colors On Friends"], C.nameplates, "friendclassc", "checkbox")
      CreateConfig(this, T["Raid Icon Size"], C.nameplates, "raidiconsize")
      CreateConfig(this, T["Show Players Only"], C.nameplates, "players", "checkbox")
      CreateConfig(this, T["Hide Critters"], C.nameplates, "critters", "checkbox")
      CreateConfig(this, T["Show Health Points"], C.nameplates, "showhp", "checkbox")
      CreateConfig(this, T["Vertical Position"], C.nameplates, "vpos")
      CreateConfig(this, T["Nameplate Width"], C.nameplates, "width")
      CreateConfig(this, T["Healthbar Height"], C.nameplates, "heighthealth")
      CreateConfig(this, T["Castbar Height"], C.nameplates, "heightcast")
      CreateConfig(this, T["Enable Combo Point Display"], C.nameplates, "cpdisplay", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Thirdparty ]]
  pfUI.gui.tabs.thirdparty = pfUI.gui.tabs:CreateTabChild(T["Thirdparty"], nil, nil, nil, true)
  pfUI.gui.tabs.thirdparty.tabs = CreateTabFrame(pfUI.gui.tabs.thirdparty, "TOP", true)

  -- >> General
  pfUI.gui.tabs.thirdparty.tabs.general = pfUI.gui.tabs.thirdparty.tabs:CreateTabChild(T["Thirdparty"], 70)
  pfUI.gui.tabs.thirdparty.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, T["DPSMate (Skin)"], C.thirdparty.dpsmate, "skin", "checkbox")
      CreateConfig(this, T["DPSMate (Dock)"], C.thirdparty.dpsmate, "dock", "checkbox")
      CreateConfig(this, T["SWStats (Skin)"], C.thirdparty.swstats, "skin", "checkbox")
      CreateConfig(this, T["SWStats (Dock)"], C.thirdparty.swstats, "dock", "checkbox")
      CreateConfig(this, T["KLH Threat Meter (Skin)"], C.thirdparty.ktm, "skin", "checkbox")
      CreateConfig(this, T["KLH Threat Meter (Dock)"], C.thirdparty.ktm, "dock", "checkbox")
      CreateConfig(this, T["WIM"], C.thirdparty.wim, "enable", "checkbox")
      CreateConfig(this, T["HealComm"], C.thirdparty.healcomm, "enable", "checkbox")
      CreateConfig(this, T["CleanUp"], C.thirdparty.cleanup, "enable", "checkbox")
      CreateConfig(this, T["FlightMap"], C.thirdparty.flightmap, "enable", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Modules ]]
  pfUI.gui.tabs.modules = pfUI.gui.tabs:CreateTabChild(T["Modules"], nil, nil, nil, true)
  pfUI.gui.tabs.modules.tabs = CreateTabFrame(pfUI.gui.tabs.modules, "TOP", true)

  -- General
  pfUI.gui.tabs.modules.tabs.general = pfUI.gui.tabs.modules.tabs:CreateTabChild(T["Modules"], 70)
  pfUI.gui.tabs.modules.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      for i,m in pairs(pfUI.modules) do
        if m ~= "gui" then
          -- create disabled entry if not existing and display
          pfUI:UpdateConfig("disabled", nil, m, "0")
          CreateConfig(this, T["Disable Module"] .. " " .. m, C.disabled, m, "checkbox")
        end
      end
      this.setup = true
    end
  end)

  -- [[ Close ]]
  pfUI.gui.tabs.close = pfUI.gui.tabs:CreateTabChild(T["Close"], nil, nil, "BOTTOM")
  pfUI.gui.tabs.close.button:SetScript("OnClick", function()
    pfUI.gui:Hide()
  end)

  -- [[ Unlock ]]
  pfUI.gui.tabs.unlock = pfUI.gui.tabs:CreateTabChild(T["Unlock"], nil, nil, "BOTTOM")
  pfUI.gui.tabs.unlock.button:SetScript("OnClick", function()
    pfUI.gui.delaySettingChanged = pfUI.gui.settingChanged
    pfUI.gui.settingChanged = nil
    pfUI.unlock:UnlockFrames()
  end)

  -- [[ Hoverbind ]]
  pfUI.gui.tabs.hoverbind = pfUI.gui.tabs:CreateTabChild(T["Hoverbind"], nil, nil, "BOTTOM")
  pfUI.gui.tabs.hoverbind.button:SetScript("OnClick", function()
    if pfUI.hoverbind then
      pfUI.gui.delaySettingChanged = pfUI.gui.settingChanged
      pfUI.gui.settingChanged = nil
      pfUI.hoverbind:Show()
    end
  end)


end)
