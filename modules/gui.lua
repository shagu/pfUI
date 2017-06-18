pfUI:RegisterModule("gui", function ()
  -- innner padding
  local spacing = 25

  local function Createtabs(parent, align, outside)
    local f = CreateFrame("Frame", nil, parent)

    f:SetPoint("TOPLEFT", parent, "TOPLEFT", -5, 5)
    f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 5, -5)

    -- setup env
    f.childs = { }
    f.buttons = { }
    f.align = align
    f.outside = outside
    f.bottomcount = 1

    -- Create Child Frame
    f.CreateChildFrame = function(self, title, bwidth, bheight, bottom, static)
      -- setup env
      local childcount = table.getn(self.childs) + 1
      local button_width = bwidth or 150
      local button_height = bheight or 20
      local border = 4

      -- create tab button
      local b = CreateFrame("Button", "pfConfig" .. title .. "Button", self, "UIPanelButtonTemplate")
      b:SetHeight(button_height)
      b:SetWidth(button_width)
      b:SetID(childcount)

      if not self.align or self.align == "LEFT" then
        local outside = self.outside and -2 * border - button_width or 0
        if bottom then
          b:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", border + outside, (self.bottomcount-1) * (button_height) + (self.bottomcount * border) )
        else
          b:SetPoint("TOPLEFT", self, "TOPLEFT", border + outside, -(childcount-1) * (button_height) - (childcount * border) )
        end
      elseif self.align == "TOP" then
        local outside = self.outside and 2 * border + button_height or 0
        b:SetPoint("TOPLEFT", self, "TOPLEFT", (childcount-1) * (button_width) + (childcount * border) + (self.outside and -border), -border + outside )
      end

      SkinButton(b,.2,1,.8)
      b:SetText(title)

      if childcount ~= 1 then
        b:SetTextColor(.5,.5,.5)
      else
        b:SetTextColor(.2,1,.8)
      end

      b:SetScript("OnClick", function()
        for k,v in pairs(self.childs) do
          v:Hide()
        end
        self.childs[this:GetID()]:Show()

        for k,v in pairs(self.buttons) do
          v.active = false
          v:SetTextColor(.5,.5,.5)
        end
        self.buttons[this:GetID()]:SetTextColor(.2,1,.8)
      end)

      self.buttons[childcount] = b
      self.bottomcount = bottom and self.bottomcount + 1 or self.bottomcount

      -- create child frame
      local child = CreateFrame("ScrollFrame", "pfConfig" .. title .. "Frame", self)
      if childcount ~= 1 then child:Hide() end

      if not self.align or self.align == "LEFT" then
        child:SetPoint("TOPLEFT", self, "TOPLEFT", button_width + 2*border + 5, -border -5)
        child:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -border -5 , border + 5)
      elseif self.align == "TOP" then
        if self.outside then
          child:SetPoint("TOPLEFT", self, "TOPLEFT", 5, -5)
          child:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -5, 5)
        end
      end

      local backdrop = CreateFrame("Frame", nil, child)
      backdrop:SetFrameLevel(1)
      backdrop:SetPoint("TOPLEFT", child, "TOPLEFT", -5, 5)
      backdrop:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", 5, -5)
      CreateBackdrop(backdrop, nil, true)

      if not static then
        child:EnableMouseWheel(1)

        child.deco_up = CreateFrame("Frame", nil, child)
        child.deco_up:SetPoint("TOPLEFT", child, "TOPLEFT", -4, 4)
        child.deco_up:SetPoint("BOTTOMRIGHT", child, "TOPRIGHT", 4, -spacing)
        child.deco_up.fader = child.deco_up:CreateTexture("OVERLAY")
        child.deco_up.fader:SetTexture(1,1,1,1)
        child.deco_up.fader:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 1)
        child.deco_up.fader:SetAllPoints(child.deco_up)

        child.deco_up_indicator = CreateFrame("Frame", nil, child.deco_up)
        child.deco_up_indicator:Hide()
        child.deco_up_indicator:SetPoint("TOP", child.deco_up, "TOP", 0, -6)
        child.deco_up_indicator:SetHeight(12)
        child.deco_up_indicator:SetWidth(12)
        child.deco_up_indicator.modifier = 0.03
        child.deco_up_indicator:SetScript("OnUpdate", function()
          local alpha = this:GetAlpha()
          if alpha >= .75 then
            this.modifier = -0.03
          elseif alpha <= .25 then
            this.modifier = 0.03
          end

          this:SetAlpha(alpha + this.modifier)
        end)

        child.deco_up_indicator.tex = child.deco_up_indicator:CreateTexture("OVERLAY")
        child.deco_up_indicator.tex:SetTexture("Interface\\AddOns\\pfUI\\img\\up")
        child.deco_up_indicator.tex:SetAllPoints(child.deco_up_indicator)

        child.deco_down = CreateFrame("Frame", nil, child)
        child.deco_down:SetPoint("BOTTOMLEFT", child, "BOTTOMLEFT", -4, -4)
        child.deco_down:SetPoint("TOPRIGHT", child, "BOTTOMRIGHT", 4, spacing)
        child.deco_down.fader = child.deco_down:CreateTexture("OVERLAY")
        child.deco_down.fader:SetTexture(1,1,1,1)
        child.deco_down.fader:SetGradientAlpha("VERTICAL", 0, 0, 0, 1, 0, 0, 0, 0)
        child.deco_down.fader:SetAllPoints(child.deco_down)

        child.deco_down_indicator = CreateFrame("Frame", nil, child.deco_down)
        child.deco_down_indicator:Hide()
        child.deco_down_indicator:SetPoint("BOTTOM", child.deco_down, "BOTTOM", 0, 6)
        child.deco_down_indicator:SetHeight(12)
        child.deco_down_indicator:SetWidth(12)
        child.deco_down_indicator.modifier = 0.03

        child.deco_down_indicator:SetScript("OnUpdate", function()
          local alpha = this:GetAlpha()
          if alpha >= .75 then
            this.modifier = -0.03
          elseif alpha <= .25 then
            this.modifier = 0.03
          end

          this:SetAlpha(alpha + this.modifier)
        end)

        child.deco_down_indicator.tex = child.deco_down_indicator:CreateTexture("OVERLAY")
        child.deco_down_indicator.tex:SetTexture("Interface\\AddOns\\pfUI\\img\\down")
        child.deco_down_indicator.tex:SetAllPoints(child.deco_down_indicator)

        child.UpdateScrollState = function(self)
          -- Update Scroll Indicators: Hide/Show if required.
          local current = floor(self:GetVerticalScroll())
          local max = floor(self:GetVerticalScrollRange() + spacing)

          if current > 0 then
            self.deco_up_indicator:Show()
          else
            self.deco_up_indicator:Hide()
          end

          if max > spacing and current < max then
            self.deco_down_indicator:Show()
          else
            self.deco_down_indicator:Hide()
          end
        end


        child:SetScript("OnMouseWheel", function()
          local current = this:GetVerticalScroll()
          local new = current + arg1*-25
          local max = this:GetVerticalScrollRange() + spacing

          if max > spacing then

            if new < 0 then
              this:SetVerticalScroll(0)
            elseif new > max then
              this:SetVerticalScroll(max)
            else
              this:SetVerticalScroll(new)
            end
          end

          this:UpdateScrollState()
        end)

        local scrollchild = CreateFrame("Frame", "pfConfig" .. title .. "ScrollChild", child)

        -- dummy values required
        scrollchild:SetWidth(1)
        scrollchild:SetHeight(1)
        scrollchild:SetAllPoints(child)

        child:SetScrollChild(scrollchild)

        -- OnShow is fired too early, postpone to the first frame draw
        scrollchild:SetScript("OnUpdate", function()
          child:UpdateScrollState()
          this:SetScript("OnUpdate", nil)
        end)

        scrollchild.button = b
        table.insert(self.childs, child)
        return scrollchild
      else
        child.button = b
        table.insert(self.childs, child)
        return child
      end
    end

    return f
  end

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
            info.text = k
            info.checked = false
            info.func = function()
              UIDropDownMenu_SetSelectedID(frame.input, this:GetID(), 0)
              if category[config] ~= this:GetText() then
                pfUI.gui.settingChanged = true
                category[config] = this:GetText()
              end
            end

            UIDropDownMenu_AddButton(info)
            if category[config] == k then
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

  local function DelayChangedSettings()
    if pfUI.gui.settingChanged then
      pfUI.gui.settingChangedDelayed = true
    end
    pfUI.gui.settingChanged = nil
  end

  pfUI.gui = CreateFrame("Frame", "pfConfigGUI", UIParent)
  pfUI.gui:Hide()
  pfUI.gui:SetWidth(640)
  pfUI.gui:SetHeight(480)
  pfUI.gui:SetFrameStrata("DIALOG")
  pfUI.gui:SetPoint("CENTER", 0, 0)
  table.insert(UISpecialFrames, "pfConfigGUI")

  function pfUI.gui:Reload()
    CreateQuestionDialog("Some settings need to reload the UI to take effect.\nDo you want to reloadUI now?",
      function()
        pfUI.gui.settingChanged = nil
        ReloadUI()
      end)
  end

  pfUI.gui:SetScript("OnShow",function()
    if pfUI.gui.settingChangedDelayed then
      pfUI.gui.settingChanged = true
      pfUI.gui.settingChangedDelayed = nil
    end

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

  -- dropdown menu items
  local txtValues = { "none", "unit", "name", "level", "class",  "health", "healthmax", "healthperc",
  "healthmiss", "healthdyn", "power", "powermax", "powerperc", "powermiss", "powerdyn" }

  local dropdown_selection_fonts = { "BigNoodleTitling", "Continuum", "DieDieDie", "Expressway", "Homespun", "Myriad-Pro", "PT-Sans-Narrow-Bold", "PT-Sans-Narrow-Regular" }
  local dropdown_num_actionbar_buttons = BarLayoutOptions(NUM_ACTIONBAR_BUTTONS)
  local dropdown_num_shapeshift_slots = BarLayoutOptions(NUM_SHAPESHIFT_SLOTS)
  local dropdown_num_pet_action_slots = BarLayoutOptions(NUM_PET_ACTION_SLOTS)
  local dropdown_panel_values = { "time", "fps", "exp", "gold", "friends", "guild", "durability", "zone", "combat", "ammo", "soulshard", "none" }

  -- main tab frame
  pfUI.gui.tabs = Createtabs(pfUI.gui, "LEFT")
  pfUI.gui.tabs:SetPoint("TOPLEFT", pfUI.gui, "TOPLEFT", 0, -25)
  pfUI.gui.tabs:SetPoint("BOTTOMRIGHT", pfUI.gui, "BOTTOMRIGHT", 0, 0)


  -- [[ Settings ]]
  pfUI.gui.tabs.settings = pfUI.gui.tabs:CreateChildFrame("Settings", nil, nil, nil, true)
  pfUI.gui.tabs.settings.tabs = Createtabs(pfUI.gui.tabs.settings, "TOP", true)

  -- >> Global
  pfUI.gui.tabs.settings.tabs.general = pfUI.gui.tabs.settings.tabs:CreateChildFrame("General", 70)
  pfUI.gui.tabs.settings.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Enable Region Compatible Font", C.global, "force_region", "checkbox")
      CreateConfig(this, "Standard Text Font", C.global, "font_default", "dropdown", dropdown_selection_fonts)
      CreateConfig(this, "Standard Text Font Size", C.global, "font_size")
      CreateConfig(this, "Unit Frame Text Font", C.global, "font_unit", "dropdown", dropdown_selection_fonts)
      CreateConfig(this, "Unit Frame Text Size", C.global, "font_unit_size")
      CreateConfig(this, "Scrolling Combat Text Font", C.global, "font_combat", "dropdown", dropdown_selection_fonts)
      CreateConfig(this, "Enable Pixel Perfect (Native Resolution)", C.global, "pixelperfect", "checkbox")
      CreateConfig(this, "Enable Offscreen Frame Positions", C.global, "offscreen", "checkbox")
      CreateConfig(this, "Enable Single Line UIErrors", C.global, "errors_limit", "checkbox")
      CreateConfig(this, "Disable All UIErrors", C.global, "errors_hide", "checkbox")

      -- Delete / Reset
      CreateConfig(this, "Delete / Reset", nil, nil, "header")

      CreateConfig(this, "|cffff5555EVERYTHING", C.global, "profile", "button", function()
        CreateQuestionDialog("Do you really want to reset |cffffaaaaEVERYTHING|r?\n\nThis will reset:\n - Current Configuration\n - Current Frame Positions\n - Firstrun Wizard\n - Addon Cache\n - Saved Profiles",
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

      CreateConfig(this, "Cache", C.global, "profile", "button", function()
        CreateQuestionDialog("Do you really want to reset the Cache?",
          function()
            _G["pfUI_playerDB"] = {}
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end, true)

      CreateConfig(this, "Firstrun", C.global, "profile", "button", function()
        CreateQuestionDialog("Do you really want to reset the Firstrun Wizard Settings?",
          function()
            _G["pfUI_init"] = {}
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end, true)

      CreateConfig(this, "Configuration", C.global, "profile", "button", function()
        CreateQuestionDialog("Do you really want to reset your configuration?\nThis also includes frame positions",
          function()
            _G["pfUI_config"] = {}
            pfUI:LoadConfig()
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end, true)


      -- Profiles
      CreateConfig(this, "Profile", nil, nil, "header")
      local values = {}
      for name, config in pairs(pfUI_profiles) do table.insert(values, name) end

      local function pfUpdateProfiles()
        local values = {}
        for name, config in pairs(pfUI_profiles) do table.insert(values, name) end
        pfUIDropDownMenuProfile.values = values
        pfUIDropDownMenuProfile.Refresh()
      end

      CreateConfig(this, "Select profile", C.global, "profile", "dropdown", values, false, "Profile")

      -- load profile
      CreateConfig(this, "Load profile", C.global, "profile", "button", function()
        if C.global.profile and pfUI_profiles[C.global.profile] then
          CreateQuestionDialog("Load profile '|cff33ffcc" .. C.global.profile .. "|r'?", function()
            local selp = C.global.profile
            _G["pfUI_config"] = CopyTable(pfUI_profiles[C.global.profile])
            C.global.profile = selp
            ReloadUI()
          end)
        end
      end)

      -- delete profile
      CreateConfig(this, "Delete profile", C.global, "profile", "button", function()
        if C.global.profile and pfUI_profiles[C.global.profile] then
          CreateQuestionDialog("Delete profile '|cff33ffcc" .. C.global.profile .. "|r'?", function()
            pfUI_profiles[C.global.profile] = nil
            pfUpdateProfiles()
            this:GetParent():Hide()
          end)
        end
      end, true)

      -- save profile
      CreateConfig(this, "Save profile", C.global, "profile", "button", function()
        if C.global.profile and pfUI_profiles[C.global.profile] then
          CreateQuestionDialog("Save current settings to profile '|cff33ffcc" .. C.global.profile .. "|r'?", function()
            if pfUI_profiles[C.global.profile] then
              pfUI_profiles[C.global.profile] = CopyTable(C)
            end
            this:GetParent():Hide()
          end)
        end
      end, true)

      -- create profile
      CreateConfig(this, "Create Profile", C.global, "profile", "button", function()
        CreateQuestionDialog("Please enter a name for the new profile.\nExisting profiles sharing the same name will be overwritten.",
        function()
          local profile = this:GetParent().input:GetText()
          local bad = string.gsub(profile,"([%w%s]+)","")
          if bad~="" then
            message('Cannot create profile: \"'..bad..'\"' .. " is not allowed in profile name")
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
  pfUI.gui.tabs.settings.tabs.appearance = pfUI.gui.tabs.settings.tabs:CreateChildFrame("Appearance", 70)
  pfUI.gui.tabs.settings.tabs.appearance:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Background Color", C.appearance.border, "background", "color")
      CreateConfig(this, "Border Color", C.appearance.border, "color", "color")
      CreateConfig(this) -- spacer
      CreateConfig(this, "Global Border Size", C.appearance.border, "default")
      CreateConfig(this, "Action Bar Border Size", C.appearance.border, "actionbars")
      CreateConfig(this, "Unit Frame Border Size", C.appearance.border, "unitframes")
      CreateConfig(this, "Panel Border Size", C.appearance.border, "panels")
      CreateConfig(this, "Chat Border Size", C.appearance.border, "chat")
      CreateConfig(this, "Bags Border Size", C.appearance.border, "bags")
      this.setup = true
    end
  end)

  -- >> Cooldown
  pfUI.gui.tabs.settings.tabs.cooldown = pfUI.gui.tabs.settings.tabs:CreateChildFrame("Cooldown", 70)
  pfUI.gui.tabs.settings.tabs.cooldown:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Cooldown Color (Less than 3 Sec)", C.appearance.cd, "lowcolor", "color")
      CreateConfig(this, "Cooldown Color (Seconds)", C.appearance.cd, "normalcolor", "color")
      CreateConfig(this, "Cooldown Color (Minutes)", C.appearance.cd, "minutecolor", "color")
      CreateConfig(this, "Cooldown Color (Hours)", C.appearance.cd, "hourcolor", "color")
      CreateConfig(this, "Cooldown Color (Days)", C.appearance.cd, "daycolor", "color")
      CreateConfig(this, "Cooldown Text Threshold", C.appearance.cd, "threshold")
      CreateConfig(this, "Cooldown Text Font Size", C.appearance.cd, "font_size")
      this.setup = true
    end
  end)


  -- [[ UnitFrames ]]
  pfUI.gui.tabs.uf = pfUI.gui.tabs:CreateChildFrame("Unit Frames", nil, nil, nil, true)
  pfUI.gui.tabs.uf.tabs = Createtabs(pfUI.gui.tabs.uf, "TOP", true)

  -- >> General
  pfUI.gui.tabs.uf.tabs.general = pfUI.gui.tabs.uf.tabs:CreateChildFrame("General", 70)
  pfUI.gui.tabs.uf.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Disable pfUI Unit Frames", C.unitframes, "disable", "checkbox")
      CreateConfig(this, "Enable Pastel Colors", C.unitframes, "pastel", "checkbox")
      CreateConfig(this, "Enable Custom Color Health Bars", C.unitframes, "custom", "checkbox")
      CreateConfig(this, "Custom Health Bar Color", C.unitframes, "customcolor", "color")
      CreateConfig(this, "Enable Custom Color Health Bar Background", C.unitframes, "custombg", "checkbox")
      CreateConfig(this, "Custom Health Bar Background Color", C.unitframes, "custombgcolor", "color")
      CreateConfig(this, "Healthbar Animation Speed", C.unitframes, "animation_speed")
      CreateConfig(this, "Portrait Alpha", C.unitframes, "portraitalpha")
      CreateConfig(this, "Always Use 2D Portraits", C.unitframes, "always2dportrait", "checkbox")
      CreateConfig(this, "Enable 2D Portraits As Fallback", C.unitframes, "portraittexture", "checkbox")
      CreateConfig(this, "Unit Frame Layout", C.unitframes, "layout", "dropdown", { "default", "tukui" })
      CreateConfig(this, "Aggressive 40y-Range Check (Will break stuff)", C.unitframes, "rangecheck", "checkbox")
      CreateConfig(this, "40y-Range Check Interval", C.unitframes, "rangechecki")
      CreateConfig(this, "Combopoint Size", C.unitframes, "combosize")
      CreateConfig(this, "Abbreviate Numbers (4200 -> 4.2k)", C.unitframes, "abbrevnum", "checkbox")
      CreateConfig(this, "Show PvP Icon", C.unitframes.player, "showPVP", "checkbox")
      CreateConfig(this, "Enable Energy Ticks", C.unitframes.player, "energy", "checkbox")
      this.setup = true
    end
  end)

  -- >> Player
  pfUI.gui.tabs.uf.tabs.player = pfUI.gui.tabs.uf.tabs:CreateChildFrame("Player", 70)
  pfUI.gui.tabs.uf.tabs.player:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Display Player Frame", C.unitframes.player, "visible", "checkbox")
      CreateConfig(this, "Portrait Position", C.unitframes.player, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, "Health Bar Width", C.unitframes.player, "width")
      CreateConfig(this, "Health Bar Height", C.unitframes.player, "height")
      CreateConfig(this, "Power Bar Height", C.unitframes.player, "pheight")
      CreateConfig(this, "Spacing", C.unitframes.player, "pspace")
      CreateConfig(this, "Buff Position", C.unitframes.player, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Buff Size", C.unitframes.player, "buffsize")
      CreateConfig(this, "Buff Limit", C.unitframes.player, "bufflimit")
      CreateConfig(this, "Buffs Per Row", C.unitframes.player, "buffperrow")
      CreateConfig(this, "Debuff Position", C.unitframes.player, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Debuff Size", C.unitframes.player, "debuffsize")
      CreateConfig(this, "Debuff Limit", C.unitframes.player, "debufflimit")
      CreateConfig(this, "Debuffs Per Row", C.unitframes.player, "debuffperrow")
      CreateConfig(this, "Invert Health Bar", C.unitframes.player, "invert_healthbar", "checkbox")
      CreateConfig(this, "Enable Buff Indicators", C.unitframes.player, "buff_indicator", "checkbox")
      CreateConfig(this, "Enable Debuff Indicators", C.unitframes.player, "debuff_indicator", "checkbox")
      CreateConfig(this, "Enable Clickcast", C.unitframes.player, "clickcast", "checkbox")
      CreateConfig(this, "Enable Range Fading", C.unitframes.player, "faderange", "checkbox")
      CreateConfig(this, "Left Text", C.unitframes.player, "txtleft", "dropdown", txtValues)
      CreateConfig(this, "Center Text", C.unitframes.player, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, "Right Text", C.unitframes.player, "txtright", "dropdown", txtValues)
      CreateConfig(this, "Enable Health Color in Text", C.unitframes.player, "healthcolor", "checkbox")
      CreateConfig(this, "Enable Power Color in Text", C.unitframes.player, "powercolor", "checkbox")
      CreateConfig(this, "Enable Level Color in Text", C.unitframes.player, "levelcolor", "checkbox")
      CreateConfig(this, "Enable Class Color in Text", C.unitframes.player, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Target
  pfUI.gui.tabs.uf.tabs.target = pfUI.gui.tabs.uf.tabs:CreateChildFrame("Target", 70)
  pfUI.gui.tabs.uf.tabs.target:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Display Target Frame", C.unitframes.target, "visible", "checkbox")
      CreateConfig(this, "Enable Target Switch Animation", C.unitframes.target, "animation", "checkbox")
      CreateConfig(this, "Portrait Position", C.unitframes.target, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, "Health Bar Width", C.unitframes.target, "width")
      CreateConfig(this, "Health Bar Height", C.unitframes.target, "height")
      CreateConfig(this, "Power Bar Height", C.unitframes.target, "pheight")
      CreateConfig(this, "Spacing", C.unitframes.target, "pspace")
      CreateConfig(this, "Buff Position", C.unitframes.target, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Buff Size", C.unitframes.target, "buffsize")
      CreateConfig(this, "Buff Limit", C.unitframes.target, "bufflimit")
      CreateConfig(this, "Buffs Per Row", C.unitframes.target, "buffperrow")
      CreateConfig(this, "Debuff Position", C.unitframes.target, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Debuff Size", C.unitframes.target, "debuffsize")
      CreateConfig(this, "Debuff Limit", C.unitframes.target, "debufflimit")
      CreateConfig(this, "Debuffs Per Row", C.unitframes.target, "debuffperrow")
      CreateConfig(this, "Invert Health Bar", C.unitframes.target, "invert_healthbar", "checkbox")
      CreateConfig(this, "Enable Buff Indicators", C.unitframes.target, "buff_indicator", "checkbox")
      CreateConfig(this, "Enable Debuff Indicators", C.unitframes.target, "debuff_indicator", "checkbox")
      CreateConfig(this, "Enable Clickcast", C.unitframes.target, "clickcast", "checkbox")
      CreateConfig(this, "Enable Range Fading", C.unitframes.target, "faderange", "checkbox")
      CreateConfig(this, "Left Text", C.unitframes.target, "txtleft", "dropdown", txtValues)
      CreateConfig(this, "Center Text", C.unitframes.target, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, "Right Text", C.unitframes.target, "txtright", "dropdown", txtValues)
      CreateConfig(this, "Enable Health Color in Text", C.unitframes.target, "healthcolor", "checkbox")
      CreateConfig(this, "Enable Power Color in Text", C.unitframes.target, "powercolor", "checkbox")
      CreateConfig(this, "Enable Level Color in Text", C.unitframes.target, "levelcolor", "checkbox")
      CreateConfig(this, "Enable Class Color in Text", C.unitframes.target, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Target-Target
  pfUI.gui.tabs.uf.tabs.targettarget = pfUI.gui.tabs.uf.tabs:CreateChildFrame("Target-Target", 70)
  pfUI.gui.tabs.uf.tabs.targettarget:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Display Target of Target Frame", C.unitframes.ttarget, "visible", "checkbox")
      CreateConfig(this, "Portrait Position", C.unitframes.ttarget, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, "Health Bar Width", C.unitframes.ttarget, "width")
      CreateConfig(this, "Health Bar Height", C.unitframes.ttarget, "height")
      CreateConfig(this, "Power Bar Height", C.unitframes.ttarget, "pheight")
      CreateConfig(this, "Spacing", C.unitframes.ttarget, "pspace")
      CreateConfig(this, "Buff Position", C.unitframes.ttarget, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Buff Size", C.unitframes.ttarget, "buffsize")
      CreateConfig(this, "Buff Limit", C.unitframes.ttarget, "bufflimit")
      CreateConfig(this, "Buffs Per Row", C.unitframes.ttarget, "buffperrow")
      CreateConfig(this, "Debuff Position", C.unitframes.ttarget, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Debuff Size", C.unitframes.ttarget, "debuffsize")
      CreateConfig(this, "Debuff Limit", C.unitframes.ttarget, "debufflimit")
      CreateConfig(this, "Debuffs Per Row", C.unitframes.ttarget, "debuffperrow")
      CreateConfig(this, "Invert Health Bar", C.unitframes.ttarget, "invert_healthbar", "checkbox")
      CreateConfig(this, "Enable Buff Indicators", C.unitframes.ttarget, "buff_indicator", "checkbox")
      CreateConfig(this, "Enable Debuff Indicators", C.unitframes.ttarget, "debuff_indicator", "checkbox")
      CreateConfig(this, "Enable Clickcast", C.unitframes.ttarget, "clickcast", "checkbox")
      CreateConfig(this, "Enable Range Fading", C.unitframes.ttarget, "faderange", "checkbox")
      CreateConfig(this, "Left Text", C.unitframes.ttarget, "txtleft", "dropdown", txtValues)
      CreateConfig(this, "Center Text", C.unitframes.ttarget, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, "Right Text", C.unitframes.ttarget, "txtright", "dropdown", txtValues)
      CreateConfig(this, "Enable Health Color in Text", C.unitframes.ttarget, "healthcolor", "checkbox")
      CreateConfig(this, "Enable Power Color in Text", C.unitframes.ttarget, "powercolor", "checkbox")
      CreateConfig(this, "Enable Level Color in Text", C.unitframes.ttarget, "levelcolor", "checkbox")
      CreateConfig(this, "Enable Class Color in Text", C.unitframes.ttarget, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Pet
  pfUI.gui.tabs.uf.tabs.pet = pfUI.gui.tabs.uf.tabs:CreateChildFrame("Pet", 70)
  pfUI.gui.tabs.uf.tabs.pet:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Display Pet Frame", C.unitframes.player, "visible", "checkbox")
      CreateConfig(this, "Portrait Position", C.unitframes.pet, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, "Health Bar Width", C.unitframes.pet, "width")
      CreateConfig(this, "Health Bar Height", C.unitframes.pet, "height")
      CreateConfig(this, "Power Bar Height", C.unitframes.pet, "pheight")
      CreateConfig(this, "Spacing", C.unitframes.pet, "pspace")
      CreateConfig(this, "Buff Position", C.unitframes.pet, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Buff Size", C.unitframes.pet, "buffsize")
      CreateConfig(this, "Buff Limit", C.unitframes.pet, "bufflimit")
      CreateConfig(this, "Buffs Per Row", C.unitframes.pet, "buffperrow")
      CreateConfig(this, "Debuff Position", C.unitframes.pet, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Debuff Size", C.unitframes.pet, "debuffsize")
      CreateConfig(this, "Debuff Limit", C.unitframes.pet, "debufflimit")
      CreateConfig(this, "Debuffs Per Row", C.unitframes.pet, "debuffperrow")
      CreateConfig(this, "Invert Health Bar", C.unitframes.pet, "invert_healthbar", "checkbox")
      CreateConfig(this, "Enable Buff Indicators", C.unitframes.pet, "buff_indicator", "checkbox")
      CreateConfig(this, "Enable Debuff Indicators", C.unitframes.pet, "debuff_indicator", "checkbox")
      CreateConfig(this, "Enable Clickcast", C.unitframes.pet, "clickcast", "checkbox")
      CreateConfig(this, "Enable Range Fading", C.unitframes.pet, "faderange", "checkbox")
      CreateConfig(this, "Left Text", C.unitframes.pet, "txtleft", "dropdown", txtValues)
      CreateConfig(this, "Center Text", C.unitframes.pet, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, "Right Text", C.unitframes.pet, "txtright", "dropdown", txtValues)
      CreateConfig(this, "Enable Health Color in Text", C.unitframes.pet, "healthcolor", "checkbox")
      CreateConfig(this, "Enable Power Color in Text", C.unitframes.pet, "powercolor", "checkbox")
      CreateConfig(this, "Enable Level Color in Text", C.unitframes.pet, "levelcolor", "checkbox")
      CreateConfig(this, "Enable Class Color in Text", C.unitframes.pet, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Focus
  pfUI.gui.tabs.uf.tabs.focus = pfUI.gui.tabs.uf.tabs:CreateChildFrame("Focus", 70)
  pfUI.gui.tabs.uf.tabs.focus:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Display Focus Frame", C.unitframes.focus, "visible", "checkbox")
      CreateConfig(this, "Portrait Position", C.unitframes.focus, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, "Health Bar Width", C.unitframes.focus, "width")
      CreateConfig(this, "Health Bar Height", C.unitframes.focus, "height")
      CreateConfig(this, "Power Bar Height", C.unitframes.focus, "pheight")
      CreateConfig(this, "Spacing", C.unitframes.focus, "pspace")
      CreateConfig(this, "Buff Position", C.unitframes.focus, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Buff Size", C.unitframes.focus, "buffsize")
      CreateConfig(this, "Buff Limit", C.unitframes.focus, "bufflimit")
      CreateConfig(this, "Buffs Per Row", C.unitframes.focus, "buffperrow")
      CreateConfig(this, "Debuff Position", C.unitframes.focus, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Debuff Size", C.unitframes.focus, "debuffsize")
      CreateConfig(this, "Debuff Limit", C.unitframes.focus, "debufflimit")
      CreateConfig(this, "Debuffs Per Row", C.unitframes.focus, "debuffperrow")
      CreateConfig(this, "Invert Health Bar", C.unitframes.focus, "invert_healthbar", "checkbox")
      CreateConfig(this, "Enable Buff Indicators", C.unitframes.focus, "buff_indicator", "checkbox")
      CreateConfig(this, "Enable Debuff Indicators", C.unitframes.focus, "debuff_indicator", "checkbox")
      CreateConfig(this, "Enable Clickcast", C.unitframes.focus, "clickcast", "checkbox")
      CreateConfig(this, "Enable Range Fading", C.unitframes.focus, "faderange", "checkbox")
      CreateConfig(this, "Left Text", C.unitframes.focus, "txtleft", "dropdown", txtValues)
      CreateConfig(this, "Center Text", C.unitframes.focus, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, "Right Text", C.unitframes.focus, "txtright", "dropdown", txtValues)
      CreateConfig(this, "Enable Health Color in Text", C.unitframes.focus, "healthcolor", "checkbox")
      CreateConfig(this, "Enable Power Color in Text", C.unitframes.focus, "powercolor", "checkbox")
      CreateConfig(this, "Enable Level Color in Text", C.unitframes.focus, "levelcolor", "checkbox")
      CreateConfig(this, "Enable Class Color in Text", C.unitframes.focus, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- [[ GroupFrames ]]
  pfUI.gui.tabs.gf = pfUI.gui.tabs:CreateChildFrame("Group Frames", nil, nil, nil, true)
  pfUI.gui.tabs.gf.tabs = Createtabs(pfUI.gui.tabs.gf, "TOP", true)

  -- >> General
  pfUI.gui.tabs.gf.tabs.general = pfUI.gui.tabs.gf.tabs:CreateChildFrame("General", 70)
  pfUI.gui.tabs.gf.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Show Hots as Buff Indicators", C.unitframes, "show_hots", "checkbox")
      CreateConfig(this, "Show Hots of all Classes", C.unitframes, "all_hots", "checkbox")
      CreateConfig(this, "Show Procs as Buff Indicators", C.unitframes, "show_procs", "checkbox")
      CreateConfig(this, "Show Procs of all Classes", C.unitframes, "all_procs", "checkbox")
      CreateConfig(this, "Only Show Indicators for Dispellable Debuffs", C.unitframes, "debuffs_class", "checkbox")
      CreateConfig(this, "Clickcast Spells", nil, nil, "header")
      CreateConfig(this, "Click Action", C.unitframes, "clickcast", nil, nil, nil, nil, "STRING")
      CreateConfig(this, "Shift-Click Action", C.unitframes, "clickcast_shift", nil, nil, nil, nil, "STRING")
      CreateConfig(this, "Alt-Click Action", C.unitframes, "clickcast_alt", nil, nil, nil, nil, "STRING")
      CreateConfig(this, "Ctrl-Click Action", C.unitframes, "clickcast_ctrl", nil, nil, nil, nil, "STRING")
      this.setup = true
    end
  end)

  -- >> Raid
  pfUI.gui.tabs.gf.tabs.raid = pfUI.gui.tabs.gf.tabs:CreateChildFrame("Raid", 70)
  pfUI.gui.tabs.gf.tabs.raid:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Display Raid Frames", C.unitframes.raid, "visible", "checkbox")
      CreateConfig(this, "Portrait Position", C.unitframes.raid, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, "Health Bar Width", C.unitframes.raid, "width")
      CreateConfig(this, "Health Bar Height", C.unitframes.raid, "height")
      CreateConfig(this, "Power Bar Height", C.unitframes.raid, "pheight")
      CreateConfig(this, "Spacing", C.unitframes.raid, "pspace")
      CreateConfig(this, "Buff Position", C.unitframes.raid, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Buff Size", C.unitframes.raid, "buffsize")
      CreateConfig(this, "Buff Limit", C.unitframes.raid, "bufflimit")
      CreateConfig(this, "Buffs Per Row", C.unitframes.raid, "buffperrow")
      CreateConfig(this, "Debuff Position", C.unitframes.raid, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Debuff Size", C.unitframes.raid, "debuffsize")
      CreateConfig(this, "Debuff Limit", C.unitframes.raid, "debufflimit")
      CreateConfig(this, "Debuffs Per Row", C.unitframes.raid, "debuffperrow")
      CreateConfig(this, "Invert Health Bar", C.unitframes.raid, "invert_healthbar", "checkbox")
      CreateConfig(this, "Enable Buff Indicators", C.unitframes.raid, "buff_indicator", "checkbox")
      CreateConfig(this, "Enable Debuff Indicators", C.unitframes.raid, "debuff_indicator", "checkbox")
      CreateConfig(this, "Enable Clickcast", C.unitframes.raid, "clickcast", "checkbox")
      CreateConfig(this, "Enable Range Fading", C.unitframes.raid, "faderange", "checkbox")
      CreateConfig(this, "Left Text", C.unitframes.raid, "txtleft", "dropdown", txtValues)
      CreateConfig(this, "Center Text", C.unitframes.raid, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, "Right Text", C.unitframes.raid, "txtright", "dropdown", txtValues)
      CreateConfig(this, "Enable Health Color in Text", C.unitframes.raid, "healthcolor", "checkbox")
      CreateConfig(this, "Enable Power Color in Text", C.unitframes.raid, "powercolor", "checkbox")
      CreateConfig(this, "Enable Level Color in Text", C.unitframes.raid, "levelcolor", "checkbox")
      CreateConfig(this, "Enable Class Color in Text", C.unitframes.raid, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Group
  pfUI.gui.tabs.gf.tabs.group = pfUI.gui.tabs.gf.tabs:CreateChildFrame("Group", 70)
  pfUI.gui.tabs.gf.tabs.group:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Display Group Frames", C.unitframes.group, "visible", "checkbox")
      CreateConfig(this, "Portrait Position", C.unitframes.group, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, "Health Bar Width", C.unitframes.group, "width")
      CreateConfig(this, "Health Bar Height", C.unitframes.group, "height")
      CreateConfig(this, "Power Bar Height", C.unitframes.group, "pheight")
      CreateConfig(this, "Spacing", C.unitframes.group, "pspace")
      CreateConfig(this, "Buff Position", C.unitframes.group, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Buff Size", C.unitframes.group, "buffsize")
      CreateConfig(this, "Buff Limit", C.unitframes.group, "bufflimit")
      CreateConfig(this, "Buffs Per Row", C.unitframes.group, "buffperrow")
      CreateConfig(this, "Debuff Position", C.unitframes.group, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Debuff Size", C.unitframes.group, "debuffsize")
      CreateConfig(this, "Debuff Limit", C.unitframes.group, "debufflimit")
      CreateConfig(this, "Debuffs Per Row", C.unitframes.group, "debuffperrow")
      CreateConfig(this, "Invert Health Bar", C.unitframes.group, "invert_healthbar", "checkbox")
      CreateConfig(this, "Enable Buff Indicators", C.unitframes.group, "buff_indicator", "checkbox")
      CreateConfig(this, "Enable Debuff Indicators", C.unitframes.group, "debuff_indicator", "checkbox")
      CreateConfig(this, "Enable Clickcast", C.unitframes.group, "clickcast", "checkbox")
      CreateConfig(this, "Enable Range Fading", C.unitframes.group, "faderange", "checkbox")
      CreateConfig(this, "Left Text", C.unitframes.group, "txtleft", "dropdown", txtValues)
      CreateConfig(this, "Center Text", C.unitframes.group, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, "Right Text", C.unitframes.group, "txtright", "dropdown", txtValues)
      CreateConfig(this, "Hide Group Frames When In A Raid", C.unitframes.group, "hide_in_raid", "checkbox")
      CreateConfig(this, "Enable Health Color in Text", C.unitframes.group, "healthcolor", "checkbox")
      CreateConfig(this, "Enable Power Color in Text", C.unitframes.group, "powercolor", "checkbox")
      CreateConfig(this, "Enable Level Color in Text", C.unitframes.group, "levelcolor", "checkbox")
      CreateConfig(this, "Enable Class Color in Text", C.unitframes.group, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Group-Target
  pfUI.gui.tabs.gf.tabs.grouptarget = pfUI.gui.tabs.gf.tabs:CreateChildFrame("Group-Target", 70)
  pfUI.gui.tabs.gf.tabs.grouptarget:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Display Group Target Frames", C.unitframes.grouptarget, "visible", "checkbox")
      CreateConfig(this, "Portrait Position", C.unitframes.grouptarget, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, "Health Bar Width", C.unitframes.grouptarget, "width")
      CreateConfig(this, "Health Bar Height", C.unitframes.grouptarget, "height")
      CreateConfig(this, "Power Bar Height", C.unitframes.grouptarget, "pheight")
      CreateConfig(this, "Spacing", C.unitframes.grouptarget, "pspace")
      CreateConfig(this, "Buff Position", C.unitframes.grouptarget, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Buff Size", C.unitframes.grouptarget, "buffsize")
      CreateConfig(this, "Buff Limit", C.unitframes.grouptarget, "bufflimit")
      CreateConfig(this, "Buffs Per Row", C.unitframes.grouptarget, "buffperrow")
      CreateConfig(this, "Debuff Position", C.unitframes.grouptarget, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Debuff Size", C.unitframes.grouptarget, "debuffsize")
      CreateConfig(this, "Debuff Limit", C.unitframes.grouptarget, "debufflimit")
      CreateConfig(this, "Debuffs Per Row", C.unitframes.grouptarget, "debuffperrow")
      CreateConfig(this, "Invert Health Bar", C.unitframes.grouptarget, "invert_healthbar", "checkbox")
      CreateConfig(this, "Enable Buff Indicators", C.unitframes.grouptarget, "buff_indicator", "checkbox")
      CreateConfig(this, "Enable Debuff Indicators", C.unitframes.grouptarget, "debuff_indicator", "checkbox")
      CreateConfig(this, "Enable Clickcast", C.unitframes.grouptarget, "clickcast", "checkbox")
      CreateConfig(this, "Enable Range Fading", C.unitframes.grouptarget, "faderange", "checkbox")
      CreateConfig(this, "Left Text", C.unitframes.grouptarget, "txtleft", "dropdown", txtValues)
      CreateConfig(this, "Center Text", C.unitframes.grouptarget, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, "Right Text", C.unitframes.grouptarget, "txtright", "dropdown", txtValues)
      CreateConfig(this, "Enable Health Color in Text", C.unitframes.grouptarget, "healthcolor", "checkbox")
      CreateConfig(this, "Enable Power Color in Text", C.unitframes.grouptarget, "powercolor", "checkbox")
      CreateConfig(this, "Enable Level Color in Text", C.unitframes.grouptarget, "levelcolor", "checkbox")
      CreateConfig(this, "Enable Class Color in Text", C.unitframes.grouptarget, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Group-Pet
  pfUI.gui.tabs.gf.tabs.grouppet = pfUI.gui.tabs.gf.tabs:CreateChildFrame("Group-Pet", 70)
  pfUI.gui.tabs.gf.tabs.grouppet:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Display Group Pet Frames", C.unitframes.grouppet, "visible", "checkbox")
      CreateConfig(this, "Portrait Position", C.unitframes.grouppet, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, "Health Bar Width", C.unitframes.grouppet, "width")
      CreateConfig(this, "Health Bar Height", C.unitframes.grouppet, "height")
      CreateConfig(this, "Power Bar Height", C.unitframes.grouppet, "pheight")
      CreateConfig(this, "Spacing", C.unitframes.grouppet, "pspace")
      CreateConfig(this, "Buff Position", C.unitframes.grouppet, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Buff Size", C.unitframes.grouppet, "buffsize")
      CreateConfig(this, "Buff Limit", C.unitframes.grouppet, "bufflimit")
      CreateConfig(this, "Buffs Per Row", C.unitframes.grouppet, "buffperrow")
      CreateConfig(this, "Debuff Position", C.unitframes.grouppet, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, "Debuff Size", C.unitframes.grouppet, "debuffsize")
      CreateConfig(this, "Debuff Limit", C.unitframes.grouppet, "debufflimit")
      CreateConfig(this, "Debuffs Per Row", C.unitframes.grouppet, "debuffperrow")
      CreateConfig(this, "Invert Health Bar", C.unitframes.grouppet, "invert_healthbar", "checkbox")
      CreateConfig(this, "Enable Buff Indicators", C.unitframes.grouppet, "buff_indicator", "checkbox")
      CreateConfig(this, "Enable Debuff Indicators", C.unitframes.grouppet, "debuff_indicator", "checkbox")
      CreateConfig(this, "Enable Clickcast", C.unitframes.grouppet, "clickcast", "checkbox")
      CreateConfig(this, "Enable Range Fading", C.unitframes.grouppet, "faderange", "checkbox")
      CreateConfig(this, "Left Text", C.unitframes.grouppet, "txtleft", "dropdown", txtValues)
      CreateConfig(this, "Center Text", C.unitframes.grouppet, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, "Right Text", C.unitframes.grouppet, "txtright", "dropdown", txtValues)
      CreateConfig(this, "Enable Health Color in Text", C.unitframes.grouppet, "healthcolor", "checkbox")
      CreateConfig(this, "Enable Power Color in Text", C.unitframes.grouppet, "powercolor", "checkbox")
      CreateConfig(this, "Enable Level Color in Text", C.unitframes.grouppet, "levelcolor", "checkbox")
      CreateConfig(this, "Enable Class Color in Text", C.unitframes.grouppet, "classcolor", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Combat ]]
  pfUI.gui.tabs.combat = pfUI.gui.tabs:CreateChildFrame("Combat", nil, nil, nil, true)
  pfUI.gui.tabs.combat.tabs = Createtabs(pfUI.gui.tabs.combat, "TOP", true)

  -- >> General
  pfUI.gui.tabs.combat.tabs.general = pfUI.gui.tabs.combat.tabs:CreateChildFrame("Combat", 70)
  pfUI.gui.tabs.combat.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Enable Combat Glow Effects On Screen Edges", C.appearance.infight, "screen", "checkbox")
      CreateConfig(this, "Enable Combat Glow Effects On Unit Frames", C.appearance.infight, "common", "checkbox")
      CreateConfig(this, "Enable Combat Glow Effects On Group Frames", C.appearance.infight, "group", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Bags & Bank ]]
  pfUI.gui.tabs.bags = pfUI.gui.tabs:CreateChildFrame("Bags & Bank", nil, nil, nil, true)
  pfUI.gui.tabs.bags.tabs = Createtabs(pfUI.gui.tabs.bags, "TOP", true)

  -- >> General
  pfUI.gui.tabs.bags.tabs.general = pfUI.gui.tabs.bags.tabs:CreateChildFrame("Bags & Bank", 70)
  pfUI.gui.tabs.bags.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Disable Item Quality Color For \"Common\" Items", C.appearance.bags, "borderlimit", "checkbox")
      CreateConfig(this, "Enable Item Quality Color For Equipment Only", C.appearance.bags, "borderonlygear", "checkbox")
      CreateConfig(this, "Auto Sell Grey Items", C.global, "autosell", "checkbox")
      CreateConfig(this, "Auto Repair Items", C.global, "autorepair", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Loot ]]
  pfUI.gui.tabs.loot = pfUI.gui.tabs:CreateChildFrame("Loot", nil, nil, nil, true)
  pfUI.gui.tabs.loot.tabs = Createtabs(pfUI.gui.tabs.loot, "TOP", true)

  -- >> General
  pfUI.gui.tabs.loot.tabs.general = pfUI.gui.tabs.loot.tabs:CreateChildFrame("Loot", 70)
  pfUI.gui.tabs.loot.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Enable Auto-Resize Loot Frame", C.loot, "autoresize", "checkbox")
      CreateConfig(this, "Disable Loot Confirmation Dialog (Without Group)", C.loot, "autopickup", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Minimap ]]
  pfUI.gui.tabs.minimap = pfUI.gui.tabs:CreateChildFrame("Minimap", nil, nil, nil, true)
  pfUI.gui.tabs.minimap.tabs = Createtabs(pfUI.gui.tabs.minimap, "TOP", true)

  -- >> General
  pfUI.gui.tabs.minimap.tabs.general = pfUI.gui.tabs.minimap.tabs:CreateChildFrame("Minimap", 70)
  pfUI.gui.tabs.minimap.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Enable Zone Text On Minimap Mouseover", C.appearance.minimap, "mouseoverzone", "checkbox")
      CreateConfig(this, "Disable Minimap Buffs", C.global, "hidebuff", "checkbox")
      CreateConfig(this, "Disable Minimap Weapon Buffs", C.global, "hidewbuff", "checkbox")
      CreateConfig(this, "Show PvP Icon", C.unitframes.player, "showPVPMinimap", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Actionbar ]]
  pfUI.gui.tabs.actionbar = pfUI.gui.tabs:CreateChildFrame("Actionbar", nil, nil, nil, true)
  pfUI.gui.tabs.actionbar.tabs = Createtabs(pfUI.gui.tabs.actionbar, "TOP", true)

  -- >> General
  pfUI.gui.tabs.actionbar.tabs.general = pfUI.gui.tabs.actionbar.tabs:CreateChildFrame("General", 70)
  pfUI.gui.tabs.actionbar.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Icon Size", C.bars, "icon_size")
      CreateConfig(this, "Enable Action Bar Backgrounds", C.bars, "background", "checkbox")
      CreateConfig(this, "Enable Range Display On Hotkeys", C.bars, "glowrange", "checkbox")
      CreateConfig(this, "Range Display Color", C.bars, "rangecolor", "color")
      CreateConfig(this, "Show Macro Text", C.bars, "showmacro", "checkbox")
      CreateConfig(this, "Show Hotkey Text", C.bars, "showkeybind", "checkbox")
      CreateConfig(this, "Enable Range Based Auto Paging (Hunter)", C.bars, "hunterbar", "checkbox")
      this.setup = true
    end
  end)

  -- >> Autohide
  pfUI.gui.tabs.actionbar.tabs.autohide = pfUI.gui.tabs.actionbar.tabs:CreateChildFrame("Autohide", 70)
  pfUI.gui.tabs.actionbar.tabs.autohide:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Seconds Until Action Bars Autohide", C.bars, "hide_time")
      CreateConfig(this, "Enable Autohide For BarActionMain", C.bars, "hide_actionmain", "checkbox")
      CreateConfig(this, "Enable Autohide For BarBottomLeft", C.bars, "hide_bottomleft", "checkbox")
      CreateConfig(this, "Enable Autohide For BarBottomRight", C.bars, "hide_bottomright", "checkbox")
      CreateConfig(this, "Enable Autohide For BarRight", C.bars, "hide_right", "checkbox")
      CreateConfig(this, "Enable Autohide For BarTwoRight", C.bars, "hide_tworight", "checkbox")
      CreateConfig(this, "Enable Autohide For BarShapeShift", C.bars, "hide_shapeshift", "checkbox")
      CreateConfig(this, "Enable Autohide For BarPet", C.bars, "hide_pet", "checkbox")
      this.setup = true
    end
  end)

  -- >> Layout
  pfUI.gui.tabs.actionbar.tabs.layout = pfUI.gui.tabs.actionbar.tabs:CreateChildFrame("Layout", 70)
  pfUI.gui.tabs.actionbar.tabs.layout:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Main Actionbar (ActionMain)", C.bars.actionmain, "formfactor", "dropdown", dropdown_num_actionbar_buttons)
      CreateConfig(this, "Second Actionbar (BottomLeft)", C.bars.bottomleft, "formfactor", "dropdown", dropdown_num_actionbar_buttons)
      CreateConfig(this, "Left Actionbar (BottomRight)", C.bars.bottomright, "formfactor", "dropdown", dropdown_num_actionbar_buttons)
      CreateConfig(this, "Right Actionbar (Right)", C.bars.right, "formfactor", "dropdown", dropdown_num_actionbar_buttons)
      CreateConfig(this, "Vertical Actionbar (TwoRight)", C.bars.tworight, "formfactor", "dropdown", dropdown_num_actionbar_buttons)
      CreateConfig(this, "Shapeshift Bar (BarShapeShift)", C.bars.shapeshift, "formfactor", "dropdown", dropdown_num_shapeshift_slots)
      CreateConfig(this, "Pet Bar (BarPet)", C.bars.pet, "formfactor", "dropdown", dropdown_num_pet_action_slots)
      this.setup = true
    end
  end)


  -- [[ Panel ]]
  pfUI.gui.tabs.panel = pfUI.gui.tabs:CreateChildFrame("Panel", nil, nil, nil, true)
  pfUI.gui.tabs.panel.tabs = Createtabs(pfUI.gui.tabs.panel, "TOP", true)

  -- >> General
  pfUI.gui.tabs.panel.tabs.general = pfUI.gui.tabs.panel.tabs:CreateChildFrame("Panel", 70)
  pfUI.gui.tabs.panel.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Use Unit Fonts", C.panel, "use_unitfonts", "checkbox")
      CreateConfig(this, "Left Panel: Left", C.panel.left, "left", "dropdown", dropdown_panel_values)
      CreateConfig(this, "Left Panel: Center", C.panel.left, "center", "dropdown", dropdown_panel_values)
      CreateConfig(this, "Left Panel: Right", C.panel.left, "right", "dropdown", dropdown_panel_values)
      CreateConfig(this, "Right Panel: Left", C.panel.right, "left", "dropdown", dropdown_panel_values)
      CreateConfig(this, "Right Panel: Center", C.panel.right, "center", "dropdown", dropdown_panel_values)
      CreateConfig(this, "Right Panel: Right", C.panel.right, "right", "dropdown", dropdown_panel_values)
      CreateConfig(this, "Other Panel: Minimap", C.panel.other, "minimap", "dropdown", dropdown_panel_values)
      CreateConfig(this, "Always Show Experience And Reputation Bar", C.panel.xp, "showalways", "checkbox")
      CreateConfig(this, "Enable Micro Bar", C.panel.micro, "enable", "checkbox")
      CreateConfig(this, "Enable 24h Clock", C.global, "twentyfour", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Tooltip ]]
  pfUI.gui.tabs.tooltip = pfUI.gui.tabs:CreateChildFrame("Tooltip", nil, nil, nil, true)
  pfUI.gui.tabs.tooltip.tabs = Createtabs(pfUI.gui.tabs.tooltip, "TOP", true)

  -- >> General
  pfUI.gui.tabs.tooltip.tabs.general = pfUI.gui.tabs.tooltip.tabs:CreateChildFrame("Tooltip", 70)
  pfUI.gui.tabs.tooltip.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Tooltip Position", C.tooltip, "position", "dropdown", { "bottom", "chat", "cursor" })
      CreateConfig(this, "Enable Extended Guild Information", C.tooltip, "extguild", "checkbox")
      CreateConfig(this, "Custom Transparency", C.tooltip, "alpha")
      CreateConfig(this, "Always Show Item Comparison", C.tooltip.compare, "showalways", "checkbox")
      CreateConfig(this, "Always Show Extended Vendor Values", C.tooltip.vendor, "showalways", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Castbar ]]
  pfUI.gui.tabs.castbar = pfUI.gui.tabs:CreateChildFrame("Castbar", nil, nil, nil, true)
  pfUI.gui.tabs.castbar.tabs = Createtabs(pfUI.gui.tabs.castbar, "TOP", true)

  -- >> General
  pfUI.gui.tabs.castbar.tabs.general = pfUI.gui.tabs.castbar.tabs:CreateChildFrame("Castbar", 70)
  pfUI.gui.tabs.castbar.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Use Unit Fonts", C.castbar, "use_unitfonts", "checkbox")
      CreateConfig(this, "Casting Color", C.appearance.castbar, "castbarcolor", "color")
      CreateConfig(this, "Channeling Color", C.appearance.castbar, "channelcolor", "color")
      CreateConfig(this, "Disable Blizzard Castbar", C.castbar.player, "hide_blizz", "checkbox")
      CreateConfig(this, "Disable pfUI Player Castbar", C.castbar.player, "hide_pfui", "checkbox")
      CreateConfig(this, "Disable pfUI Target Castbar", C.castbar.target, "hide_pfui", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Chat ]]
  pfUI.gui.tabs.chat = pfUI.gui.tabs:CreateChildFrame("Chat", nil, nil, nil, true)
  pfUI.gui.tabs.chat.tabs = Createtabs(pfUI.gui.tabs.chat, "TOP", true)

  -- >> General
  pfUI.gui.tabs.chat.tabs.general = pfUI.gui.tabs.chat.tabs:CreateChildFrame("General", 70)
  pfUI.gui.tabs.chat.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Enable \"Loot & Spam\" Chat Window", C.chat.right, "enable", "checkbox")
      CreateConfig(this, "Inputbox Width", C.chat.text, "input_width")
      CreateConfig(this, "Inputbox Height", C.chat.text, "input_height")
      CreateConfig(this, "Enable Timestamps", C.chat.text, "time", "checkbox")
      CreateConfig(this, "Timestamp Format", C.chat.text, "timeformat", nil, nil, nil, nil, "STRING")
      CreateConfig(this, "Timestamp Brackets", C.chat.text, "timebracket", nil, nil, nil, nil, "STRING")
      CreateConfig(this, "Timestamp Color", C.chat.text, "timecolor", "color")
      CreateConfig(this, "Hide Channel Names", C.chat.text, "channelnumonly", "checkbox")
      CreateConfig(this, "Enable URL Detection", C.chat.text, "detecturl", "checkbox")
      CreateConfig(this, "Enable Class Colors", C.chat.text, "classcolor", "checkbox")
      CreateConfig(this, "Left Chat Width", C.chat.left, "width")
      CreateConfig(this, "Left Chat Height", C.chat.left, "height")
      CreateConfig(this, "Right Chat Width", C.chat.right, "width")
      CreateConfig(this, "Right Chat Height", C.chat.right, "height")
      CreateConfig(this, "Enable Right Chat Window", C.chat.right, "alwaysshow", "checkbox")
      CreateConfig(this, "Enable Chat Dock", C.chat.global, "tabdock", "checkbox")
      CreateConfig(this, "Enable Custom Colors", C.chat.global, "custombg", "checkbox")
      CreateConfig(this, "Chat Background Color", C.chat.global, "background", "color")
      CreateConfig(this, "Chat Border Color", C.chat.global, "border", "color")
      CreateConfig(this, "Enable Custom Incoming Whispers Layout", C.chat.global, "whispermod", "checkbox")
      CreateConfig(this, "Incoming Whispers Color", C.chat.global, "whisper", "color")
      CreateConfig(this, "Enable Sticky Chat", C.chat.global, "sticky", "checkbox")
      CreateConfig(this, "Enable Chat Fade", C.chat.global, "fadeout", "checkbox")
      CreateConfig(this, "Seconds Before Chat Fade", C.chat.global, "fadetime")
      this.setup = true
    end
  end)


  -- [[ Nameplates ]]
  pfUI.gui.tabs.nameplates = pfUI.gui.tabs:CreateChildFrame("Nameplates", nil, nil, nil, true)
  pfUI.gui.tabs.nameplates.tabs = Createtabs(pfUI.gui.tabs.nameplates, "TOP", true)

  -- General
  pfUI.gui.tabs.nameplates.tabs.general = pfUI.gui.tabs.nameplates.tabs:CreateChildFrame("Nameplates", 70)
  pfUI.gui.tabs.nameplates.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "Use Unit Fonts", C.nameplates, "use_unitfonts", "checkbox")
      CreateConfig(this, "Enable Castbars", C.nameplates, "showcastbar", "checkbox")
      CreateConfig(this, "Enable Spellname", C.nameplates, "spellname", "checkbox")
      CreateConfig(this, "Enable Debuffs", C.nameplates, "showdebuffs", "checkbox")
      CreateConfig(this, "Enable Clickthrough", C.nameplates, "clickthrough", "checkbox")
      CreateConfig(this, "Enable Mouselook With Right Click", C.nameplates, "rightclick", "checkbox")
      CreateConfig(this, "Right Click Auto Attack Threshold", C.nameplates, "clickthreshold")
      CreateConfig(this, "Enable Class Colors On Enemies", C.nameplates, "enemyclassc", "checkbox")
      CreateConfig(this, "Enable Class Colors On Friends", C.nameplates, "friendclassc", "checkbox")
      CreateConfig(this, "Raid Icon Size", C.nameplates, "raidiconsize")
      CreateConfig(this, "Show Players Only", C.nameplates, "players", "checkbox")
      CreateConfig(this, "Show Health Points", C.nameplates, "showhp", "checkbox")
      CreateConfig(this, "Vertical Position", C.nameplates, "vpos")
      CreateConfig(this, "Nameplate Width", C.nameplates, "width")
      CreateConfig(this, "Healthbar Height", C.nameplates, "heighthealth")
      CreateConfig(this, "Castbar Height", C.nameplates, "heightcast")
      this.setup = true
    end
  end)


  -- [[ Thirdparty ]]
  pfUI.gui.tabs.thirdparty = pfUI.gui.tabs:CreateChildFrame("Thirdparty", nil, nil, nil, true)
  pfUI.gui.tabs.thirdparty.tabs = Createtabs(pfUI.gui.tabs.thirdparty, "TOP", true)

  -- >> General
  pfUI.gui.tabs.thirdparty.tabs.general = pfUI.gui.tabs.thirdparty.tabs:CreateChildFrame("Thirdparty", 70)
  pfUI.gui.tabs.thirdparty.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, "DPSMate", C.thirdparty.dpsmate, "enable", "checkbox")
      CreateConfig(this, "WIM", C.thirdparty.wim, "enable", "checkbox")
      CreateConfig(this, "HealComm", C.thirdparty.healcomm, "enable", "checkbox")
      CreateConfig(this, "CleanUp", C.thirdparty.cleanup, "enable", "checkbox")
      CreateConfig(this, "KLH Threat Meter", C.thirdparty.ktm, "enable", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Modules ]]
  pfUI.gui.tabs.modules = pfUI.gui.tabs:CreateChildFrame("Modules", nil, nil, nil, true)
  pfUI.gui.tabs.modules.tabs = Createtabs(pfUI.gui.tabs.modules, "TOP", true)

  -- General
  pfUI.gui.tabs.modules.tabs.general = pfUI.gui.tabs.modules.tabs:CreateChildFrame("Modules", 70)
  pfUI.gui.tabs.modules.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      for i,m in pairs(pfUI.modules) do
        if m ~= "gui" then
          -- create disabled entry if not existing and display
          pfUI:UpdateConfig("disabled", nil, m, "0")
          CreateConfig(this, "Disable Module: " .. m, C.disabled, m, "checkbox")
        end
      end
      this.setup = true
    end
  end)

  -- [[ Close ]]
  pfUI.gui.tabs.close = pfUI.gui.tabs:CreateChildFrame("Close", nil, nil, "BOTTOM")
  pfUI.gui.tabs.close.button:SetScript("OnClick", function()
    pfUI.gui:Hide()
  end)

  -- [[ Unlock ]]
  pfUI.gui.tabs.unlock = pfUI.gui.tabs:CreateChildFrame("Unlock", nil, nil, "BOTTOM")
  pfUI.gui.tabs.unlock.button:SetScript("OnClick", function()
    DelayChangedSettings()
    pfUI.unlock:UnlockFrames()
  end)

  -- [[ Hoverbind ]]
  pfUI.gui.tabs.hoverbind = pfUI.gui.tabs:CreateChildFrame("Hoverbind", nil, nil, "BOTTOM")
  pfUI.gui.tabs.hoverbind.button:SetScript("OnClick", function()
    if pfUI.hoverbind then
      DelayChangedSettings()
      pfUI.hoverbind:Show()
    end
  end)


end)
