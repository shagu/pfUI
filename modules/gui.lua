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
  pfUI.gui.tabs.settings = pfUI.gui.tabs:CreateChildFrame(pf_St, nil, nil, nil, true)
  pfUI.gui.tabs.settings.tabs = Createtabs(pfUI.gui.tabs.settings, "TOP", true)

  -- >> Global
  pfUI.gui.tabs.settings.tabs.general = pfUI.gui.tabs.settings.tabs:CreateChildFrame(pf_General, 70)
  pfUI.gui.tabs.settings.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_ERC, C.global, "force_region", "checkbox")
      CreateConfig(this, pf_STF, C.global, "font_default", "dropdown", dropdown_selection_fonts)
      CreateConfig(this, pf_STFS, C.global, "font_size")
      CreateConfig(this, pf_UFTF, C.global, "font_unit", "dropdown", dropdown_selection_fonts)
      CreateConfig(this, pf_UFTS, C.global, "font_unit_size")
      CreateConfig(this, pf_SCTF, C.global, "font_combat", "dropdown", dropdown_selection_fonts)
      CreateConfig(this, pf_EPP, C.global, "pixelperfect", "checkbox")
      CreateConfig(this, pf_EOFP, C.global, "offscreen", "checkbox")
      CreateConfig(this, pf_ESLU, C.global, "errors_limit", "checkbox")
      CreateConfig(this, pf_DAU, C.global, "errors_hide", "checkbox")

      -- Delete / Reset
      CreateConfig(this, pf_DR, nil, nil, "header")

      CreateConfig(this, pf_EVERYTHING, C.global, "profile", "button", function()
        CreateQuestionDialog(pf_EVERYTHINGMSG,
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

      CreateConfig(this, pf_CACHE, C.global, "profile", "button", function()
        CreateQuestionDialog(pf_CACHEMSG,
          function()
            _G["pfUI_playerDB"] = {}
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end, true)

      CreateConfig(this, pf_Firstrun, C.global, "profile", "button", function()
        CreateQuestionDialog(pf_FirstrunMSG,
          function()
            _G["pfUI_init"] = {}
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end, true)

      CreateConfig(this, pf_Configuration, C.global, "profile", "button", function()
        CreateQuestionDialog(pf_ConfigurationMSG,
          function()
            _G["pfUI_config"] = {}
            pfUI:LoadConfig()
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end, true)


      -- Profiles
      CreateConfig(this, pf_Profile, nil, nil, "header")
      local values = {}
      for name, config in pairs(pfUI_profiles) do table.insert(values, name) end

      local function pfUpdateProfiles()
        local values = {}
        for name, config in pairs(pfUI_profiles) do table.insert(values, name) end
        pfUIDropDownMenuProfile.values = values
        pfUIDropDownMenuProfile.Refresh()
      end

      CreateConfig(this, pf_SProfile, C.global, "profile", "dropdown", values, false, "Profile")

      -- load profile
      CreateConfig(this, pf_LProfile, C.global, "profile", "button", function()
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
      CreateConfig(this, pf_DProfile, C.global, "profile", "button", function()
        if C.global.profile and pfUI_profiles[C.global.profile] then
          CreateQuestionDialog("Delete profile '|cff33ffcc" .. C.global.profile .. "|r'?", function()
            pfUI_profiles[C.global.profile] = nil
            pfUpdateProfiles()
            this:GetParent():Hide()
          end)
        end
      end, true)

      -- save profile
      CreateConfig(this, pf_SSProfile, C.global, "profile", "button", function()
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
      CreateConfig(this, pf_CProfile, C.global, "profile", "button", function()
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
  pfUI.gui.tabs.settings.tabs.appearance = pfUI.gui.tabs.settings.tabs:CreateChildFrame(pf_Appearance, 70)
  pfUI.gui.tabs.settings.tabs.appearance:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_Background_Color, C.appearance.border, "background", "color")
      CreateConfig(this, pf_Border_Color, C.appearance.border, "color", "color")
      CreateConfig(this) -- spacer
      CreateConfig(this, pf_Global_Border_Size, C.appearance.border, "default")
      CreateConfig(this, pf_Action_Bar_Border_Size, C.appearance.border, "actionbars")
      CreateConfig(this, pf_Unit_Frame_Border_Size, C.appearance.border, "unitframes")
      CreateConfig(this, pf_Panel_Border_Size, C.appearance.border, "panels")
      CreateConfig(this, pf_Chat_Border_Size, C.appearance.border, "chat")
      CreateConfig(this, pf_Bags_Border_Size, C.appearance.border, "bags")
      this.setup = true
    end
  end)

  -- >> Cooldown
  pfUI.gui.tabs.settings.tabs.cooldown = pfUI.gui.tabs.settings.tabs:CreateChildFrame(pf_CD, 70)
  pfUI.gui.tabs.settings.tabs.cooldown:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_CDCL, C.appearance.cd, "lowcolor", "color")
      CreateConfig(this, pf_CDCS, C.appearance.cd, "normalcolor", "color")
      CreateConfig(this, pf_CDCM, C.appearance.cd, "minutecolor", "color")
      CreateConfig(this, pf_CDCH, C.appearance.cd, "hourcolor", "color")
      CreateConfig(this, pf_CDCD, C.appearance.cd, "daycolor", "color")
      CreateConfig(this, pf_CDTT, C.appearance.cd, "threshold")
      this.setup = true
    end
  end)


  -- [[ UnitFrames ]]
  pfUI.gui.tabs.uf = pfUI.gui.tabs:CreateChildFrame(pf_Unit_Frames, nil, nil, nil, true)
  pfUI.gui.tabs.uf.tabs = Createtabs(pfUI.gui.tabs.uf, "TOP", true)

  -- >> General
  pfUI.gui.tabs.uf.tabs.general = pfUI.gui.tabs.uf.tabs:CreateChildFrame(pf_General, 70)
  pfUI.gui.tabs.uf.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_DPUF, C.unitframes, "disable", "checkbox")
      CreateConfig(this, pf_EPC, C.unitframes, "pastel", "checkbox")
      CreateConfig(this, pf_ECCHB, C.unitframes, "custom", "checkbox")
      CreateConfig(this, pf_CHBC, C.unitframes, "customcolor", "color")
      CreateConfig(this, pf_ECCHBB, C.unitframes, "custombg", "checkbox")
      CreateConfig(this, pf_CHBBC, C.unitframes, "custombgcolor", "color")
      CreateConfig(this, pf_HAS, C.unitframes, "animation_speed")
      CreateConfig(this, pf_P_A, C.unitframes, "portraitalpha")
      CreateConfig(this, pf_E2PAF, C.unitframes, "portraittexture", "checkbox")
      CreateConfig(this, pf_UF_L, C.unitframes, "layout", "dropdown", { "default", "tukui" })
      CreateConfig(this, pf_A4RC, C.unitframes, "rangecheck", "checkbox")
      CreateConfig(this, pf_4CI, C.unitframes, "rangechecki")
      CreateConfig(this, pf_C_Z, C.unitframes, "combosize")
      CreateConfig(this, pf_A_N, C.unitframes, "abbrevnum", "checkbox")
      CreateConfig(this, pf_S_PVP, C.unitframes.player, "showPVP", "checkbox")
      CreateConfig(this, pf_EET, C.unitframes.player, "energy", "checkbox")
      this.setup = true
    end
  end)

  -- >> Player
  pfUI.gui.tabs.uf.tabs.player = pfUI.gui.tabs.uf.tabs:CreateChildFrame(pf_PLAYER, 70)
  pfUI.gui.tabs.uf.tabs.player:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_Dis_PF, C.unitframes.player, "visible", "checkbox")
      CreateConfig(this, pf_P_P, C.unitframes.player, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, pf_HP_WIDTH, C.unitframes.player, "width")
      CreateConfig(this, pf_HP_HEIGHT, C.unitframes.player, "height")
      CreateConfig(this, pf_MP_HEIGHT, C.unitframes.player, "pheight")
      CreateConfig(this, pf_Spacing, C.unitframes.player, "pspace")
      CreateConfig(this, pf_BUFF_P, C.unitframes.player, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_BUFF_S, C.unitframes.player, "buffsize")
      CreateConfig(this, pf_BUFF_L, C.unitframes.player, "bufflimit")
      CreateConfig(this, pf_BUFF_P_R, C.unitframes.player, "buffperrow")
      CreateConfig(this, pf_DEBUFF_P, C.unitframes.player, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_DEBUFF_S, C.unitframes.player, "debuffsize")
      CreateConfig(this, pf_DEBUFF_L, C.unitframes.player, "debufflimit")
      CreateConfig(this, pf_DEBUFF_P_R, C.unitframes.player, "debuffperrow")
      CreateConfig(this, pf_I_H_B, C.unitframes.player, "invert_healthbar", "checkbox")
      CreateConfig(this, pf_E_BUFF_I, C.unitframes.player, "buff_indicator", "checkbox")
      CreateConfig(this, pf_E_DEBUFF_I, C.unitframes.player, "debuff_indicator", "checkbox")
      CreateConfig(this, pf_E_CC, C.unitframes.player, "clickcast", "checkbox")
      CreateConfig(this, pf_ERF, C.unitframes.player, "faderange", "checkbox")
      CreateConfig(this, pf_L_T, C.unitframes.player, "txtleft", "dropdown", txtValues)
      CreateConfig(this, pf_C_T, C.unitframes.player, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, pf_R_T, C.unitframes.player, "txtright", "dropdown", txtValues)
      CreateConfig(this, pf_E_HCIT, C.unitframes.player, "healthcolor", "checkbox")
      CreateConfig(this, pf_E_PCIT, C.unitframes.player, "powercolor", "checkbox")
      CreateConfig(this, pf_E_LCIT, C.unitframes.player, "levelcolor", "checkbox")
      CreateConfig(this, pf_E_CCIT, C.unitframes.player, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Target
  pfUI.gui.tabs.uf.tabs.target = pfUI.gui.tabs.uf.tabs:CreateChildFrame(pf_TARGET, 70)
  pfUI.gui.tabs.uf.tabs.target:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_DIS_TF, C.unitframes.target, "visible", "checkbox")
      CreateConfig(this, pf_E_TSA, C.unitframes.target, "animation", "checkbox")
      CreateConfig(this, pf_P_P, C.unitframes.target, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, pf_HP_WIDTH, C.unitframes.target, "width")
      CreateConfig(this, pf_HP_HEIGHT, C.unitframes.target, "height")
      CreateConfig(this, pf_MP_HEIGHT, C.unitframes.target, "pheight")
      CreateConfig(this, pf_Spacing, C.unitframes.target, "pspace")
      CreateConfig(this, pf_BUFF_P, C.unitframes.target, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_BUFF_S, C.unitframes.target, "buffsize")
      CreateConfig(this, pf_BUFF_L, C.unitframes.target, "bufflimit")
      CreateConfig(this, pf_BUFF_P_R, C.unitframes.target, "buffperrow")
      CreateConfig(this, pf_DEBUFF_P, C.unitframes.target, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_DEBUFF_S, C.unitframes.target, "debuffsize")
      CreateConfig(this, pf_DEBUFF_L, C.unitframes.target, "debufflimit")
      CreateConfig(this, pf_DEBUFF_P_R, C.unitframes.target, "debuffperrow")
      CreateConfig(this, pf_I_H_B, C.unitframes.target, "invert_healthbar", "checkbox")
      CreateConfig(this, pf_E_BUFF_I, C.unitframes.target, "buff_indicator", "checkbox")
      CreateConfig(this, pf_E_DEBUFF_I, C.unitframes.target, "debuff_indicator", "checkbox")
      CreateConfig(this, pf_E_CC, C.unitframes.target, "clickcast", "checkbox")
      CreateConfig(this, pf_ERF, C.unitframes.target, "faderange", "checkbox")
      CreateConfig(this, pf_L_T, C.unitframes.target, "txtleft", "dropdown", txtValues)
      CreateConfig(this, pf_C_T, C.unitframes.target, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, pf_R_T, C.unitframes.target, "txtright", "dropdown", txtValues)
      CreateConfig(this, pf_E_HCIT, C.unitframes.target, "healthcolor", "checkbox")
      CreateConfig(this, pf_E_PCIT, C.unitframes.target, "powercolor", "checkbox")
      CreateConfig(this, pf_E_LCIT, C.unitframes.target, "levelcolor", "checkbox")
      CreateConfig(this, pf_E_CCIT, C.unitframes.target, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Target-Target
  pfUI.gui.tabs.uf.tabs.targettarget = pfUI.gui.tabs.uf.tabs:CreateChildFrame(pf_TARGET_TARGET, 70)
  pfUI.gui.tabs.uf.tabs.targettarget:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_DIS_TOTF, C.unitframes.ttarget, "visible", "checkbox")
      CreateConfig(this, pf_P_P, C.unitframes.ttarget, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, pf_HP_WIDTH, C.unitframes.ttarget, "width")
      CreateConfig(this, pf_HP_HEIGHT, C.unitframes.ttarget, "height")
      CreateConfig(this, pf_MP_HEIGHT, C.unitframes.ttarget, "pheight")
      CreateConfig(this, pf_Spacing, C.unitframes.ttarget, "pspace")
      CreateConfig(this, pf_BUFF_P, C.unitframes.ttarget, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_BUFF_S, C.unitframes.ttarget, "buffsize")
      CreateConfig(this, pf_BUFF_L, C.unitframes.ttarget, "bufflimit")
      CreateConfig(this, pf_BUFF_P_R, C.unitframes.ttarget, "buffperrow")
      CreateConfig(this, pf_DEBUFF_P, C.unitframes.ttarget, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_DEBUFF_S, C.unitframes.ttarget, "debuffsize")
      CreateConfig(this, pf_DEBUFF_L, C.unitframes.ttarget, "debufflimit")
      CreateConfig(this, pf_DEBUFF_P_R, C.unitframes.ttarget, "debuffperrow")
      CreateConfig(this, pf_I_H_B, C.unitframes.ttarget, "invert_healthbar", "checkbox")
      CreateConfig(this, pf_E_BUFF_I, C.unitframes.ttarget, "buff_indicator", "checkbox")
      CreateConfig(this, pf_E_DEBUFF_I, C.unitframes.ttarget, "debuff_indicator", "checkbox")
      CreateConfig(this, pf_E_CC, C.unitframes.ttarget, "clickcast", "checkbox")
      CreateConfig(this, pf_ERF, C.unitframes.ttarget, "faderange", "checkbox")
      CreateConfig(this, pf_L_T, C.unitframes.ttarget, "txtleft", "dropdown", txtValues)
      CreateConfig(this, pf_C_T, C.unitframes.ttarget, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, pf_R_T, C.unitframes.ttarget, "txtright", "dropdown", txtValues)
      CreateConfig(this, pf_E_HCIT, C.unitframes.ttarget, "healthcolor", "checkbox")
      CreateConfig(this, pf_E_PCIT, C.unitframes.ttarget, "powercolor", "checkbox")
      CreateConfig(this, pf_E_LCIT, C.unitframes.ttarget, "levelcolor", "checkbox")
      CreateConfig(this, pf_E_CCIT, C.unitframes.ttarget, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Pet
  pfUI.gui.tabs.uf.tabs.pet = pfUI.gui.tabs.uf.tabs:CreateChildFrame(pf_PET, 70)
  pfUI.gui.tabs.uf.tabs.pet:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_DIS_PF, C.unitframes.player, "visible", "checkbox")
      CreateConfig(this, pf_P_P, C.unitframes.pet, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, pf_HP_WIDTH, C.unitframes.pet, "width")
      CreateConfig(this, pf_HP_HEIGHT, C.unitframes.pet, "height")
      CreateConfig(this, pf_MP_HEIGHT, C.unitframes.pet, "pheight")
      CreateConfig(this, pf_Spacing, C.unitframes.pet, "pspace")
      CreateConfig(this, pf_BUFF_P, C.unitframes.pet, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_BUFF_S, C.unitframes.pet, "buffsize")
      CreateConfig(this, pf_BUFF_L, C.unitframes.pet, "bufflimit")
      CreateConfig(this, pf_BUFF_P_R, C.unitframes.pet, "buffperrow")
      CreateConfig(this, pf_DEBUFF_P, C.unitframes.pet, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_DEBUFF_S, C.unitframes.pet, "debuffsize")
      CreateConfig(this, pf_DEBUFF_L, C.unitframes.pet, "debufflimit")
      CreateConfig(this, pf_DEBUFF_P_R, C.unitframes.pet, "debuffperrow")
      CreateConfig(this, pf_I_H_B, C.unitframes.pet, "invert_healthbar", "checkbox")
      CreateConfig(this, pf_E_BUFF_I, C.unitframes.pet, "buff_indicator", "checkbox")
      CreateConfig(this, pf_E_DEBUFF_I, C.unitframes.pet, "debuff_indicator", "checkbox")
      CreateConfig(this, pf_E_CC, C.unitframes.pet, "clickcast", "checkbox")
      CreateConfig(this, pf_ERF, C.unitframes.pet, "faderange", "checkbox")
      CreateConfig(this, pf_L_T, C.unitframes.pet, "txtleft", "dropdown", txtValues)
      CreateConfig(this, pf_C_T, C.unitframes.pet, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, pf_R_T, C.unitframes.pet, "txtright", "dropdown", txtValues)
      CreateConfig(this, pf_E_HCIT, C.unitframes.pet, "healthcolor", "checkbox")
      CreateConfig(this, pf_E_PCIT, C.unitframes.pet, "powercolor", "checkbox")
      CreateConfig(this, pf_E_LCIT, C.unitframes.pet, "levelcolor", "checkbox")
      CreateConfig(this, pf_E_CCIT, C.unitframes.pet, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Focus
  pfUI.gui.tabs.uf.tabs.focus = pfUI.gui.tabs.uf.tabs:CreateChildFrame(pf_FOCUS, 70)
  pfUI.gui.tabs.uf.tabs.focus:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_DIS_FF, C.unitframes.focus, "visible", "checkbox")
      CreateConfig(this, pf_P_P, C.unitframes.focus, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, pf_HP_WIDTH, C.unitframes.focus, "width")
      CreateConfig(this, pf_HP_HEIGHT, C.unitframes.focus, "height")
      CreateConfig(this, pf_MP_HEIGHT, C.unitframes.focus, "pheight")
      CreateConfig(this, pf_Spacing, C.unitframes.focus, "pspace")
      CreateConfig(this, pf_BUFF_P, C.unitframes.focus, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_BUFF_S, C.unitframes.focus, "buffsize")
      CreateConfig(this, pf_BUFF_L, C.unitframes.focus, "bufflimit")
      CreateConfig(this, pf_BUFF_P_R, C.unitframes.focus, "buffperrow")
      CreateConfig(this, pf_DEBUFF_P, C.unitframes.focus, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_DEBUFF_S, C.unitframes.focus, "debuffsize")
      CreateConfig(this, pf_DEBUFF_L, C.unitframes.focus, "debufflimit")
      CreateConfig(this, pf_DEBUFF_P_R, C.unitframes.focus, "debuffperrow")
      CreateConfig(this, pf_I_H_B, C.unitframes.focus, "invert_healthbar", "checkbox")
      CreateConfig(this, pf_E_BUFF_I, C.unitframes.focus, "buff_indicator", "checkbox")
      CreateConfig(this, pf_E_DEBUFF_I, C.unitframes.focus, "debuff_indicator", "checkbox")
      CreateConfig(this, pf_E_CC, C.unitframes.focus, "clickcast", "checkbox")
      CreateConfig(this, pf_ERF, C.unitframes.focus, "faderange", "checkbox")
      CreateConfig(this, pf_L_T, C.unitframes.focus, "txtleft", "dropdown", txtValues)
      CreateConfig(this, pf_C_T, C.unitframes.focus, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, pf_R_T, C.unitframes.focus, "txtright", "dropdown", txtValues)
      CreateConfig(this, pf_E_HCIT, C.unitframes.focus, "healthcolor", "checkbox")
      CreateConfig(this, pf_E_PCIT, C.unitframes.focus, "powercolor", "checkbox")
      CreateConfig(this, pf_E_LCIT, C.unitframes.focus, "levelcolor", "checkbox")
      CreateConfig(this, pf_E_CCIT, C.unitframes.focus, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- [[ GroupFrames ]]
  pfUI.gui.tabs.gf = pfUI.gui.tabs:CreateChildFrame(pf_GROUP_FRAME, nil, nil, nil, true)
  pfUI.gui.tabs.gf.tabs = Createtabs(pfUI.gui.tabs.gf, "TOP", true)

  -- >> General
  pfUI.gui.tabs.gf.tabs.general = pfUI.gui.tabs.gf.tabs:CreateChildFrame(pf_General, 70)
  pfUI.gui.tabs.gf.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_SHABI, C.unitframes, "show_hots", "checkbox")
      CreateConfig(this, pf_SHOAC, C.unitframes, "all_hots", "checkbox")
      CreateConfig(this, pf_SPABI, C.unitframes, "show_procs", "checkbox")
      CreateConfig(this, pf_SPOAC, C.unitframes, "all_procs", "checkbox")
      CreateConfig(this, pf_OSIFDD, C.unitframes, "debuffs_class", "checkbox")
      CreateConfig(this, pf_CC_S, nil, nil, "header")
      CreateConfig(this, pf_CLICK_ACTION, C.unitframes, "clickcast", nil, nil, nil, nil, "STRING")
      CreateConfig(this, pf_SHIFT_CA, C.unitframes, "clickcast_shift", nil, nil, nil, nil, "STRING")
      CreateConfig(this, pf_ALT_CA, C.unitframes, "clickcast_alt", nil, nil, nil, nil, "STRING")
      CreateConfig(this, pf_CTRL_CA, C.unitframes, "clickcast_ctrl", nil, nil, nil, nil, "STRING")
      this.setup = true
    end
  end)

  -- >> Raid
  pfUI.gui.tabs.gf.tabs.raid = pfUI.gui.tabs.gf.tabs:CreateChildFrame(pf_RAID, 70)
  pfUI.gui.tabs.gf.tabs.raid:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_DIS_RF, C.unitframes.raid, "visible", "checkbox")
      CreateConfig(this, pf_P_P, C.unitframes.raid, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, pf_HP_WIDTH, C.unitframes.raid, "width")
      CreateConfig(this, pf_HP_HEIGHT, C.unitframes.raid, "height")
      CreateConfig(this, pf_MP_HEIGHT, C.unitframes.raid, "pheight")
      CreateConfig(this, pf_Spacing, C.unitframes.raid, "pspace")
      CreateConfig(this, pf_BUFF_P, C.unitframes.raid, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_BUFF_S, C.unitframes.raid, "buffsize")
      CreateConfig(this, pf_BUFF_L, C.unitframes.raid, "bufflimit")
      CreateConfig(this, pf_BUFF_P_R, C.unitframes.raid, "buffperrow")
      CreateConfig(this, pf_DEBUFF_P, C.unitframes.raid, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_DEBUFF_S, C.unitframes.raid, "debuffsize")
      CreateConfig(this, pf_DEBUFF_L, C.unitframes.raid, "debufflimit")
      CreateConfig(this, pf_DEBUFF_P_R, C.unitframes.raid, "debuffperrow")
      CreateConfig(this, pf_I_H_B, C.unitframes.raid, "invert_healthbar", "checkbox")
      CreateConfig(this, pf_E_BUFF_I, C.unitframes.raid, "buff_indicator", "checkbox")
      CreateConfig(this, pf_E_DEBUFF_I, C.unitframes.raid, "debuff_indicator", "checkbox")
      CreateConfig(this, pf_E_CC, C.unitframes.raid, "clickcast", "checkbox")
      CreateConfig(this, pf_ERF, C.unitframes.raid, "faderange", "checkbox")
      CreateConfig(this, pf_L_T, C.unitframes.raid, "txtleft", "dropdown", txtValues)
      CreateConfig(this, pf_C_T, C.unitframes.raid, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, pf_R_T, C.unitframes.raid, "txtright", "dropdown", txtValues)
      CreateConfig(this, pf_E_HCIT, C.unitframes.raid, "healthcolor", "checkbox")
      CreateConfig(this, pf_E_PCIT, C.unitframes.raid, "powercolor", "checkbox")
      CreateConfig(this, pf_E_LCIT, C.unitframes.raid, "levelcolor", "checkbox")
      CreateConfig(this, pf_E_CCIT, C.unitframes.raid, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Group
  pfUI.gui.tabs.gf.tabs.group = pfUI.gui.tabs.gf.tabs:CreateChildFrame(pf_GROUP, 70)
  pfUI.gui.tabs.gf.tabs.group:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_DIS_GF, C.unitframes.group, "visible", "checkbox")
      CreateConfig(this, pf_P_P, C.unitframes.group, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, pf_HP_WIDTH, C.unitframes.group, "width")
      CreateConfig(this, pf_HP_HEIGHT, C.unitframes.group, "height")
      CreateConfig(this, pf_MP_HEIGHT, C.unitframes.group, "pheight")
      CreateConfig(this, pf_Spacing, C.unitframes.group, "pspace")
      CreateConfig(this, pf_BUFF_P, C.unitframes.group, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_BUFF_S, C.unitframes.group, "buffsize")
      CreateConfig(this, pf_BUFF_L, C.unitframes.group, "bufflimit")
      CreateConfig(this, pf_BUFF_P_R, C.unitframes.group, "buffperrow")
      CreateConfig(this, pf_DEBUFF_P, C.unitframes.group, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_DEBUFF_S, C.unitframes.group, "debuffsize")
      CreateConfig(this, pf_DEBUFF_L, C.unitframes.group, "debufflimit")
      CreateConfig(this, pf_DEBUFF_P_R, C.unitframes.group, "debuffperrow")
      CreateConfig(this, pf_I_H_B, C.unitframes.group, "invert_healthbar", "checkbox")
      CreateConfig(this, pf_E_BUFF_I, C.unitframes.group, "buff_indicator", "checkbox")
      CreateConfig(this, pf_E_DEBUFF_I, C.unitframes.group, "debuff_indicator", "checkbox")
      CreateConfig(this, pf_E_CC, C.unitframes.group, "clickcast", "checkbox")
      CreateConfig(this, pf_ERF, C.unitframes.group, "faderange", "checkbox")
      CreateConfig(this, pf_L_T, C.unitframes.group, "txtleft", "dropdown", txtValues)
      CreateConfig(this, pf_C_T, C.unitframes.group, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, pf_R_T, C.unitframes.group, "txtright", "dropdown", txtValues)
      CreateConfig(this, pf_HIDE_IN_RAID, C.unitframes.group, "hide_in_raid", "checkbox")
      CreateConfig(this, pf_E_HCIT, C.unitframes.group, "healthcolor", "checkbox")
      CreateConfig(this, pf_E_PCIT, C.unitframes.group, "powercolor", "checkbox")
      CreateConfig(this, pf_E_LCIT, C.unitframes.group, "levelcolor", "checkbox")
      CreateConfig(this, pf_E_CCIT, C.unitframes.group, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Group-Target
  pfUI.gui.tabs.gf.tabs.grouptarget = pfUI.gui.tabs.gf.tabs:CreateChildFrame(pf_GROUP_TARGET, 70)
  pfUI.gui.tabs.gf.tabs.grouptarget:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_DIS_GTF, C.unitframes.grouptarget, "visible", "checkbox")
      CreateConfig(this, pf_P_P, C.unitframes.grouptarget, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, pf_HP_WIDTH, C.unitframes.grouptarget, "width")
      CreateConfig(this, pf_HP_HEIGHT, C.unitframes.grouptarget, "height")
      CreateConfig(this, pf_MP_HEIGHT, C.unitframes.grouptarget, "pheight")
      CreateConfig(this, pf_Spacing, C.unitframes.grouptarget, "pspace")
      CreateConfig(this, pf_BUFF_P, C.unitframes.grouptarget, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_BUFF_S, C.unitframes.grouptarget, "buffsize")
      CreateConfig(this, pf_BUFF_L, C.unitframes.grouptarget, "bufflimit")
      CreateConfig(this, pf_BUFF_P_R, C.unitframes.grouptarget, "buffperrow")
      CreateConfig(this, pf_DEBUFF_P, C.unitframes.grouptarget, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_DEBUFF_S, C.unitframes.grouptarget, "debuffsize")
      CreateConfig(this, pf_DEBUFF_L, C.unitframes.grouptarget, "debufflimit")
      CreateConfig(this, pf_DEBUFF_P_R, C.unitframes.grouptarget, "debuffperrow")
      CreateConfig(this, pf_I_H_B, C.unitframes.grouptarget, "invert_healthbar", "checkbox")
      CreateConfig(this, pf_E_BUFF_I, C.unitframes.grouptarget, "buff_indicator", "checkbox")
      CreateConfig(this, pf_E_DEBUFF_I, C.unitframes.grouptarget, "debuff_indicator", "checkbox")
      CreateConfig(this, pf_E_CC, C.unitframes.grouptarget, "clickcast", "checkbox")
      CreateConfig(this, pf_ERF, C.unitframes.grouptarget, "faderange", "checkbox")
      CreateConfig(this, pf_L_T, C.unitframes.grouptarget, "txtleft", "dropdown", txtValues)
      CreateConfig(this, pf_C_T, C.unitframes.grouptarget, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, pf_R_T, C.unitframes.grouptarget, "txtright", "dropdown", txtValues)
      CreateConfig(this, pf_E_HCIT, C.unitframes.grouptarget, "healthcolor", "checkbox")
      CreateConfig(this, pf_E_PCIT, C.unitframes.grouptarget, "powercolor", "checkbox")
      CreateConfig(this, pf_E_LCIT, C.unitframes.grouptarget, "levelcolor", "checkbox")
      CreateConfig(this, pf_E_CCIT, C.unitframes.grouptarget, "classcolor", "checkbox")
      this.setup = true
    end
  end)

  -- >> Group-Pet
  pfUI.gui.tabs.gf.tabs.grouppet = pfUI.gui.tabs.gf.tabs:CreateChildFrame(pf_GROUP_PET, 70)
  pfUI.gui.tabs.gf.tabs.grouppet:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_DIS_GPT, C.unitframes.grouppet, "visible", "checkbox")
      CreateConfig(this, pf_P_P, C.unitframes.grouppet, "portrait", "dropdown", { "bar", "left", "right", "off" })
      CreateConfig(this, pf_HP_WIDTH, C.unitframes.grouppet, "width")
      CreateConfig(this, pf_HP_HEIGHT, C.unitframes.grouppet, "height")
      CreateConfig(this, pf_MP_HEIGHT, C.unitframes.grouppet, "pheight")
      CreateConfig(this, pf_Spacing, C.unitframes.grouppet, "pspace")
      CreateConfig(this, pf_BUFF_P, C.unitframes.grouppet, "buffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_BUFF_S, C.unitframes.grouppet, "buffsize")
      CreateConfig(this, pf_BUFF_L, C.unitframes.grouppet, "bufflimit")
      CreateConfig(this, pf_BUFF_P_R, C.unitframes.grouppet, "buffperrow")
      CreateConfig(this, pf_DEBUFF_P, C.unitframes.grouppet, "debuffs", "dropdown", { "top", "bottom", "off"})
      CreateConfig(this, pf_DEBUFF_S, C.unitframes.grouppet, "debuffsize")
      CreateConfig(this, pf_DEBUFF_L, C.unitframes.grouppet, "debufflimit")
      CreateConfig(this, pf_DEBUFF_P_R, C.unitframes.grouppet, "debuffperrow")
      CreateConfig(this, pf_I_H_B, C.unitframes.grouppet, "invert_healthbar", "checkbox")
      CreateConfig(this, pf_E_BUFF_I, C.unitframes.grouppet, "buff_indicator", "checkbox")
      CreateConfig(this, pf_E_DEBUFF_I, C.unitframes.grouppet, "debuff_indicator", "checkbox")
      CreateConfig(this, pf_E_CC, C.unitframes.grouppet, "clickcast", "checkbox")
      CreateConfig(this, pf_ERF, C.unitframes.grouppet, "faderange", "checkbox")
      CreateConfig(this, pf_L_T, C.unitframes.grouppet, "txtleft", "dropdown", txtValues)
      CreateConfig(this, pf_C_T, C.unitframes.grouppet, "txtcenter", "dropdown", txtValues)
      CreateConfig(this, pf_R_T, C.unitframes.grouppet, "txtright", "dropdown", txtValues)
      CreateConfig(this, pf_E_HCIT, C.unitframes.grouppet, "healthcolor", "checkbox")
      CreateConfig(this, pf_E_PCIT, C.unitframes.grouppet, "powercolor", "checkbox")
      CreateConfig(this, pf_E_LCIT, C.unitframes.grouppet, "levelcolor", "checkbox")
      CreateConfig(this, pf_E_CCIT, C.unitframes.grouppet, "classcolor", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Combat ]]
  pfUI.gui.tabs.combat = pfUI.gui.tabs:CreateChildFrame(pf_COMBAT, nil, nil, nil, true)
  pfUI.gui.tabs.combat.tabs = Createtabs(pfUI.gui.tabs.combat, "TOP", true)

  -- >> General
  pfUI.gui.tabs.combat.tabs.general = pfUI.gui.tabs.combat.tabs:CreateChildFrame(pf_COMBAT, 70)
  pfUI.gui.tabs.combat.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_COMBAT_FULL, C.appearance.infight, "screen", "checkbox")
      CreateConfig(this, pf_COMBAT_UF, C.appearance.infight, "common", "checkbox")
      CreateConfig(this, pf_COMBAT_GROUP, C.appearance.infight, "group", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Bags & Bank ]]
  pfUI.gui.tabs.bags = pfUI.gui.tabs:CreateChildFrame(pf_BAG_BANK, nil, nil, nil, true)
  pfUI.gui.tabs.bags.tabs = Createtabs(pfUI.gui.tabs.bags, "TOP", true)

  -- >> General
  pfUI.gui.tabs.bags.tabs.general = pfUI.gui.tabs.bags.tabs:CreateChildFrame(pf_BAG_BANK, 70)
  pfUI.gui.tabs.bags.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_DIS_IQC, C.appearance.bags, "borderlimit", "checkbox")
      CreateConfig(this, pf_ENABLE_IQC, C.appearance.bags, "borderonlygear", "checkbox")
      CreateConfig(this, pf_AUTO_SELL, C.global, "autosell", "checkbox")
      CreateConfig(this, pf_AUTO_REPAIR, C.global, "autorepair", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Loot ]]
  pfUI.gui.tabs.loot = pfUI.gui.tabs:CreateChildFrame(pf_LOOT, nil, nil, nil, true)
  pfUI.gui.tabs.loot.tabs = Createtabs(pfUI.gui.tabs.loot, "TOP", true)

  -- >> General
  pfUI.gui.tabs.loot.tabs.general = pfUI.gui.tabs.loot.tabs:CreateChildFrame(pf_LOOT, 70)
  pfUI.gui.tabs.loot.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_ENABLE_ALF, C.loot, "autoresize", "checkbox")
      CreateConfig(this, pf_DIS_LOOT, C.loot, "autopickup", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Minimap ]]
  pfUI.gui.tabs.minimap = pfUI.gui.tabs:CreateChildFrame(pf_MINIMAP, nil, nil, nil, true)
  pfUI.gui.tabs.minimap.tabs = Createtabs(pfUI.gui.tabs.minimap, "TOP", true)

  -- >> General
  pfUI.gui.tabs.minimap.tabs.general = pfUI.gui.tabs.minimap.tabs:CreateChildFrame(pf_MINIMAP, 70)
  pfUI.gui.tabs.minimap.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_ENABLE_ZONE, C.appearance.minimap, "mouseoverzone", "checkbox")
      CreateConfig(this, pf_DIS_MINI_BUFF, C.global, "hidebuff", "checkbox")
      CreateConfig(this, pf_DIS_MINI_W_BUFF, C.global, "hidewbuff", "checkbox")
      CreateConfig(this, pf_SHOW_PVP, C.unitframes.player, "showPVPMinimap", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Actionbar ]]
  pfUI.gui.tabs.actionbar = pfUI.gui.tabs:CreateChildFrame(pf_ACTIONBAR, nil, nil, nil, true)
  pfUI.gui.tabs.actionbar.tabs = Createtabs(pfUI.gui.tabs.actionbar, "TOP", true)

  -- >> General
  pfUI.gui.tabs.actionbar.tabs.general = pfUI.gui.tabs.actionbar.tabs:CreateChildFrame(pf_General, 70)
  pfUI.gui.tabs.actionbar.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_ICON_S, C.bars, "icon_size")
      CreateConfig(this, pf_ENABLE_ABB, C.bars, "background", "checkbox")
      CreateConfig(this, pf_ENABLE_RDOH, C.bars, "glowrange", "checkbox")
      CreateConfig(this, pf_RDC, C.bars, "rangecolor", "color")
      CreateConfig(this, pf_SHOW_MACRO_T, C.bars, "showmacro", "checkbox")
      CreateConfig(this, pf_SHOW_HOTKEY_T, C.bars, "showkeybind", "checkbox")
      CreateConfig(this, pf_ENABLE_RBAP, C.bars, "hunterbar", "checkbox")
      this.setup = true
    end
  end)

  -- >> Autohide
  pfUI.gui.tabs.actionbar.tabs.autohide = pfUI.gui.tabs.actionbar.tabs:CreateChildFrame(pf_AUTOHIDE, 70)
  pfUI.gui.tabs.actionbar.tabs.autohide:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_AUTOHIDE_TIME, C.bars, "hide_time")
      CreateConfig(this, pf_AUTOHIDE_MAIN, C.bars, "hide_actionmain", "checkbox")
      CreateConfig(this, pf_AUTOHIDE_B_LEFT, C.bars, "hide_bottomleft", "checkbox")
      CreateConfig(this, pf_AUTOHIDE_B_RIGHT, C.bars, "hide_bottomright", "checkbox")
      CreateConfig(this, pf_AUTOHIDE_RIGHT, C.bars, "hide_right", "checkbox")
      CreateConfig(this, pf_AUTOHIDE_RIGHT2, C.bars, "hide_tworight", "checkbox")
      CreateConfig(this, pf_AUTOHIDE_SHAPESHIFT, C.bars, "hide_shapeshift", "checkbox")
      CreateConfig(this, pf_AUTOHIDE_PET, C.bars, "hide_pet", "checkbox")
      this.setup = true
    end
  end)

  -- >> Layout
  pfUI.gui.tabs.actionbar.tabs.layout = pfUI.gui.tabs.actionbar.tabs:CreateChildFrame(pf_LAYOUT, 70)
  pfUI.gui.tabs.actionbar.tabs.layout:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_M_AB, C.bars.actionmain, "formfactor", "dropdown", dropdown_num_actionbar_buttons)
      CreateConfig(this, pf_BL_AB, C.bars.bottomleft, "formfactor", "dropdown", dropdown_num_actionbar_buttons)
      CreateConfig(this, pf_BR_AB, C.bars.bottomright, "formfactor", "dropdown", dropdown_num_actionbar_buttons)
      CreateConfig(this, pf_R_AB, C.bars.right, "formfactor", "dropdown", dropdown_num_actionbar_buttons)
      CreateConfig(this, pf_R2_AB, C.bars.tworight, "formfactor", "dropdown", dropdown_num_actionbar_buttons)
      CreateConfig(this, pf_SS_AB, C.bars.shapeshift, "formfactor", "dropdown", dropdown_num_shapeshift_slots)
      CreateConfig(this, pf_PET_AB, C.bars.pet, "formfactor", "dropdown", dropdown_num_pet_action_slots)
      this.setup = true
    end
  end)


  -- [[ Panel ]]
  pfUI.gui.tabs.panel = pfUI.gui.tabs:CreateChildFrame(pf_PANEL, nil, nil, nil, true)
  pfUI.gui.tabs.panel.tabs = Createtabs(pfUI.gui.tabs.panel, "TOP", true)

  -- >> General
  pfUI.gui.tabs.panel.tabs.general = pfUI.gui.tabs.panel.tabs:CreateChildFrame(pf_PANEL, 70)
  pfUI.gui.tabs.panel.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_U_N_F, C.panel, "use_unitfonts", "checkbox")
      CreateConfig(this, pf_LP_L, C.panel.left, "left", "dropdown", dropdown_panel_values)
      CreateConfig(this, pf_LP_C, C.panel.left, "center", "dropdown", dropdown_panel_values)
      CreateConfig(this, pf_LP_R, C.panel.left, "right", "dropdown", dropdown_panel_values)
      CreateConfig(this, pf_RP_L, C.panel.right, "left", "dropdown", dropdown_panel_values)
      CreateConfig(this, pf_RP_C, C.panel.right, "center", "dropdown", dropdown_panel_values)
      CreateConfig(this, pf_RP_R, C.panel.right, "right", "dropdown", dropdown_panel_values)
      CreateConfig(this, pf_OP_MAP, C.panel.other, "minimap", "dropdown", dropdown_panel_values)
      CreateConfig(this, pf_ALWAYS_SHOW, C.panel.xp, "showalways", "checkbox")
      CreateConfig(this, pf_ENABLE_MICRO, C.panel.micro, "enable", "checkbox")
      CreateConfig(this, pf_TIME24, C.global, "twentyfour", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Tooltip ]]
  pfUI.gui.tabs.tooltip = pfUI.gui.tabs:CreateChildFrame(pf_TOOTIP, nil, nil, nil, true)
  pfUI.gui.tabs.tooltip.tabs = Createtabs(pfUI.gui.tabs.tooltip, "TOP", true)

  -- >> General
  pfUI.gui.tabs.tooltip.tabs.general = pfUI.gui.tabs.tooltip.tabs:CreateChildFrame(pf_TOOTIP, 70)
  pfUI.gui.tabs.tooltip.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_TOOTIP_P, C.tooltip, "position", "dropdown", { "bottom", "chat", "cursor" })
      CreateConfig(this, pf_ENABLE_GUILD, C.tooltip, "extguild", "checkbox")
      CreateConfig(this, pf_CUSTOM_T, C.tooltip, "alpha")
      CreateConfig(this, pf_ALWAYS_SHOW_ITEM, C.tooltip.compare, "showalways", "checkbox")
      CreateConfig(this, pf_SHOW_SELL_VALUES, C.tooltip.vendor, "showalways", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Castbar ]]
  pfUI.gui.tabs.castbar = pfUI.gui.tabs:CreateChildFrame(pf_CASTBAR, nil, nil, nil, true)
  pfUI.gui.tabs.castbar.tabs = Createtabs(pfUI.gui.tabs.castbar, "TOP", true)

  -- >> General
  pfUI.gui.tabs.castbar.tabs.general = pfUI.gui.tabs.castbar.tabs:CreateChildFrame(pf_CASTBAR, 70)
  pfUI.gui.tabs.castbar.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_U_N_F, C.castbar, "use_unitfonts", "checkbox")
      CreateConfig(this, pf_CASTING_COLOR, C.appearance.castbar, "castbarcolor", "color")
      CreateConfig(this, pf_BACK_COLOR, C.appearance.castbar, "channelcolor", "color")
      CreateConfig(this, pf_DIS_BZ_C, C.castbar.player, "hide_blizz", "checkbox")
      CreateConfig(this, pf_DIS_P_C, C.castbar.player, "hide_pfui", "checkbox")
      CreateConfig(this, pf_DIS_T_C, C.castbar.target, "hide_pfui", "checkbox")
      this.setup = true
    end
  end)


  -- [[ Chat ]]
  pfUI.gui.tabs.chat = pfUI.gui.tabs:CreateChildFrame(pf_CHAT, nil, nil, nil, true)
  pfUI.gui.tabs.chat.tabs = Createtabs(pfUI.gui.tabs.chat, "TOP", true)

  -- >> General
  pfUI.gui.tabs.chat.tabs.general = pfUI.gui.tabs.chat.tabs:CreateChildFrame(pf_General, 70)
  pfUI.gui.tabs.chat.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_ENABLE_L_C, C.chat.right, "enable", "checkbox")
      CreateConfig(this, pf_INPUT_W, C.chat.text, "input_width")
      CreateConfig(this, pf_INPUT_H, C.chat.text, "input_height")
      CreateConfig(this, pf_ENABLE_TIME, C.chat.text, "time", "checkbox")
      CreateConfig(this, pf_TIME_FORMAT, C.chat.text, "timeformat", nil, nil, nil, nil, "STRING")
      CreateConfig(this, pf_TIME_BRACKETS, C.chat.text, "timebracket", nil, nil, nil, nil, "STRING")
      CreateConfig(this, pf_TIME_COLOR, C.chat.text, "timecolor", "color")
      CreateConfig(this, pf_HIDE_CHANNEL, C.chat.text, "channelnumonly", "checkbox")
      CreateConfig(this, pf_URL, C.chat.text, "detecturl", "checkbox")
      CreateConfig(this, pf_CLASS_COLOR, C.chat.text, "classcolor", "checkbox")
      CreateConfig(this, pf_CHAT_L_W, C.chat.left, "width")
      CreateConfig(this, pf_CHAT_L_H, C.chat.left, "height")
      CreateConfig(this, pf_CHAT_R_W, C.chat.right, "width")
      CreateConfig(this, pf_CHAT_R_H, C.chat.right, "height")
      CreateConfig(this, pf_ENABLE_R_CHAT, C.chat.right, "alwaysshow", "checkbox")
      CreateConfig(this, pf_CHAT_DOCK, C.chat.global, "tabdock", "checkbox")
      CreateConfig(this, pf_ENABLE_CUSTOM_COLOR, C.chat.global, "custombg", "checkbox")
      CreateConfig(this, pf_CHAT_BACKGROUND, C.chat.global, "background", "color")
      CreateConfig(this, pf_CHAT_BORDER_COLOR, C.chat.global, "border", "color")
      CreateConfig(this, pf_ENABLE_WHISPERS, C.chat.global, "whispermod", "checkbox")
      CreateConfig(this, pf_I_WHISPERS_COLOR, C.chat.global, "whisper", "color")
      CreateConfig(this, pf_ENABLE_S_CHAT, C.chat.global, "sticky", "checkbox")
      CreateConfig(this, pf_ENABLE_CHAT_FADE, C.chat.global, "fadeout", "checkbox")
      CreateConfig(this, pf_CHAT_FADE_TIME, C.chat.global, "fadetime")
      this.setup = true
    end
  end)


  -- [[ Nameplates ]]
  pfUI.gui.tabs.nameplates = pfUI.gui.tabs:CreateChildFrame(pf_NAMEPLATES, nil, nil, nil, true)
  pfUI.gui.tabs.nameplates.tabs = Createtabs(pfUI.gui.tabs.nameplates, "TOP", true)

  -- General
  pfUI.gui.tabs.nameplates.tabs.general = pfUI.gui.tabs.nameplates.tabs:CreateChildFrame(pf_NAMEPLATES, 70)
  pfUI.gui.tabs.nameplates.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      CreateConfig(this, pf_U_N_F, C.nameplates, "use_unitfonts", "checkbox")
      CreateConfig(this, pf_ENABLE_CASTBARS, C.nameplates, "showcastbar", "checkbox")
      CreateConfig(this, pf_SPELLNAME, C.nameplates, "spellname", "checkbox")
      CreateConfig(this, pf_N_DEBUFFS, C.nameplates, "showdebuffs", "checkbox")
      CreateConfig(this, pf_ENABLE_CLICK, C.nameplates, "clickthrough", "checkbox")
      CreateConfig(this, pf_MOUSELOOK, C.nameplates, "rightclick", "checkbox")
      CreateConfig(this, pf_RIGHT_AUTO_AT, C.nameplates, "clickthreshold")
      CreateConfig(this, pf_CLASS_COL_O_E, C.nameplates, "enemyclassc", "checkbox")
      CreateConfig(this, pf_CLASS_COL_O_F, C.nameplates, "friendclassc", "checkbox")
      CreateConfig(this, pf_RAID_I_S, C.nameplates, "raidiconsize")
      CreateConfig(this, pf_SHOW_PLAYERS_O, C.nameplates, "players", "checkbox")
      CreateConfig(this, pf_SHOW_HP, C.nameplates, "showhp", "checkbox")
      CreateConfig(this, pf_VERICAL_POS, C.nameplates, "vpos")
      CreateConfig(this, pf_NAMEPLATE_W, C.nameplates, "width")
      CreateConfig(this, pf_HP_H, C.nameplates, "heighthealth")
      CreateConfig(this, pf_CASTBAR_H, C.nameplates, "heightcast")
      this.setup = true
    end
  end)


  -- [[ Thirdparty ]]
  pfUI.gui.tabs.thirdparty = pfUI.gui.tabs:CreateChildFrame(pf_THIRDPARTY, nil, nil, nil, true)
  pfUI.gui.tabs.thirdparty.tabs = Createtabs(pfUI.gui.tabs.thirdparty, "TOP", true)

  -- >> General
  pfUI.gui.tabs.thirdparty.tabs.general = pfUI.gui.tabs.thirdparty.tabs:CreateChildFrame(pf_THIRDPARTY, 70)
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
  pfUI.gui.tabs.modules = pfUI.gui.tabs:CreateChildFrame(pf_MODULES, nil, nil, nil, true)
  pfUI.gui.tabs.modules.tabs = Createtabs(pfUI.gui.tabs.modules, "TOP", true)

  -- General
  pfUI.gui.tabs.modules.tabs.general = pfUI.gui.tabs.modules.tabs:CreateChildFrame(pf_MODULES, 70)
  pfUI.gui.tabs.modules.tabs.general:SetScript("OnShow", function()
    if not this.setup then
      for i,m in pairs(pfUI.modules) do
        if m ~= "gui" then
          -- create disabled entry if not existing and display
          pfUI:UpdateConfig("disabled", nil, m, "0")
          CreateConfig(this, pf_DISABLE .. m, C.disabled, m, "checkbox")
        end
      end
      this.setup = true
    end
  end)

  -- [[ Close ]]
  pfUI.gui.tabs.close = pfUI.gui.tabs:CreateChildFrame(pf_CLOSE, nil, nil, "BOTTOM")
  pfUI.gui.tabs.close.button:SetScript("OnClick", function()
    pfUI.gui:Hide()
  end)

  -- [[ Unlock ]]
  pfUI.gui.tabs.unlock = pfUI.gui.tabs:CreateChildFrame(pf_UNLOCK, nil, nil, "BOTTOM")
  pfUI.gui.tabs.unlock.button:SetScript("OnClick", function()
    DelayChangedSettings()
    pfUI.unlock:UnlockFrames()
  end)

  -- [[ Hoverbind ]]
  pfUI.gui.tabs.hoverbind = pfUI.gui.tabs:CreateChildFrame(pf_HOVERBIND, nil, nil, "BOTTOM")
  pfUI.gui.tabs.hoverbind.button:SetScript("OnClick", function()
    if pfUI.hoverbind then
      DelayChangedSettings()
      pfUI.hoverbind:Show()
    end
  end)


end)