pfUI:RegisterModule("gui", 20400, function ()
  local Reload, U, PrepareDropDownButton, CreateConfig, CreateTabFrame, CreateArea, CreateGUIEntry, EntryUpdate

  -- "searchDB" gets populated when CreateConfig is called. The table holds
  -- information about the title, its parent buttons and the frame itself:
  --   searchDB[tostring(frame)][-1] = frame
  --                             [0] = caption
  --                           [1-X] = parent buttons
  local searchDB = {}

  do -- Core Functions/Variables
    function Reload()
      CreateQuestionDialog(T["Some settings need to reload the UI to take effect.\nDo you want to reload now?"], function()
        pfUI.gui.settingChanged = nil
        ReloadUI()
      end)
    end

    U = setmetatable({}, { __index = function(tab,key)
      local ufunc
      if pfUI[key] and pfUI[key].UpdateConfig then
        ufunc = function() return pfUI[key]:UpdateConfig() end
      elseif pfUI.uf and pfUI.uf[key] and pfUI.uf[key].UpdateConfig then
        ufunc = function() return pfUI.uf[key]:UpdateConfig() end
      end
      if ufunc then
        rawset(tab,key,ufunc)
        return ufunc
      end
    end})

    function PrepareDropDownButton(index)
      if index > _G.UIDROPDOWNMENU_MAXBUTTONS then
        for i=1,3 do
          local name = "DropDownList" .. i .. "Button" .. index
          local parent = _G["DropDownList" .. i]
          _G.UIDROPDOWNMENU_MAXBUTTONS = index
          _G[name] = CreateFrame("Button", name, parent, "UIDropDownMenuButtonTemplate")
          _G[name]:SetID(index)
        end
      end
    end

    function EntryUpdate()
      if MouseIsOver(this) and not this.over then
        this.tex:Show()
        this.over = true
      elseif not MouseIsOver(this) and this.over then
        this.tex:Hide()
        this.over = nil
      end
    end

    function CreateConfig(ufunc, caption, category, config, widget, values, skip, named, type)
      -- this object placement
      if this.objectCount == nil then
        this.objectCount = 0
      elseif not skip then
        this.objectCount = this.objectCount + 1
        this.lineCount = 1
      end

      if skip then
        if this.lineCount == nil then
          this.lineCount = 1
        end

        if skip then
          this.lineCount = this.lineCount + 1
        end
      end

      if not caption then return end

      -- basic frame
      local frame = CreateFrame("Frame", nil, this)
      frame:SetWidth(this.parent:GetRight()-this.parent:GetLeft()-20)
      frame:SetHeight(22)
      frame:SetPoint("TOPLEFT", this, "TOPLEFT", 5, (this.objectCount*-23)-5)

      -- populate search index
      if caption and this and this.GetParent and widget ~= "button" and widget ~= "header" then
        local id = tostring(frame)

        searchDB[id] = searchDB[id] or { }
        searchDB[id][0] = caption
        searchDB[id][-1] = frame

        -- scrollchild scrollframe  Area        Area        Btton
        -- this        .parent      :GetParent():GetParent().button
        -- this        .parent      :GetParent().button
        local scrollframe = this.parent
        while scrollframe.GetParent and scrollframe:GetParent() and scrollframe:GetParent().button do
          table.insert(searchDB[id], scrollframe:GetParent().button)
          scrollframe = scrollframe:GetParent()
        end
      end

      if not widget or (widget and widget ~= "button") then

        if widget ~= "header" then
          frame:SetScript("OnUpdate", EntryUpdate)
          frame.tex = frame:CreateTexture(nil, "BACKGROUND")
          frame.tex:SetTexture(1,1,1,.05)
          frame.tex:SetAllPoints()
          frame.tex:Hide()
        end

        if not ufunc and widget ~= "header" and C.gui.reloadmarker == "1" then
          caption = caption .. " [|cffffaaaa!|r]"
        end

        -- caption
        frame.caption = frame:CreateFontString("Status", "LOW", "GameFontWhite")
        frame.caption:SetFont(pfUI.font_default, C.global.font_size)
        frame.caption:SetPoint("LEFT", frame, "LEFT", 3, 1)
        frame.caption:SetJustifyH("LEFT")
        frame.caption:SetText(caption)
      end

      if category == "CVAR" then
        category = {}
        category[config] = tostring(GetCVar(config))
        ufunc = function()
          SetCVar(this:GetParent().config, this:GetParent().category[config])
        end
      end

      if category == "GVAR" then
        category = {}
        category[config] = tostring(_G[config] or 0)

        local U = ufunc

        ufunc = function()
          UIOptionsFrame_Load()
          _G[config] = this:GetChecked() and 1 or nil
          UIOptionsFrame_Save()
          if U then
            U()
          end
        end
      end

      if category == "UVAR" then
        category = {}
        category[config] = _G[config]

        local U = ufunc

        ufunc = function()
          _G[config] = this:GetChecked() and "1" or "0"
          if U then
            U()
          end
        end
      end

      frame.category = category
      frame.config = config

      if widget == "color" then
        -- color picker
        frame.color = CreateFrame("Button", nil, frame)
        frame.color:SetWidth(24)
        frame.color:SetHeight(12)
        CreateBackdrop(frame.color)
        frame.color:SetPoint("RIGHT" , -5, 1)
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
              if ufunc then ufunc() else pfUI.gui.settingChanged = true end
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

        -- hide shadows on wrong stratas
        if frame.color.backdrop_shadow then
          frame.color.backdrop_shadow:Hide()
        end
      end

      if widget == "warning" then
        CreateBackdrop(frame, nil, true)
        frame:SetBackdropBorderColor(1,.5,.5)
        frame:SetHeight(50)
        frame:SetPoint("TOPLEFT", 25, this.objectCount * -35)
        this.objectCount = this.objectCount + 2
        frame.caption:SetJustifyH("CENTER")
        frame.caption:SetJustifyV("CENTER")
      end

      if widget == "header" then
        frame:SetBackdrop(nil)
        frame:SetHeight(40)
        this.objectCount = this.objectCount + 1
        frame.caption:SetJustifyH("LEFT")
        frame.caption:SetJustifyV("BOTTOM")
        frame.caption:SetTextColor(.2,1,.8,1)
        frame.caption:SetAllPoints(frame)
      end

      -- use text widget (default)
      if not widget or widget == "text" then
        -- input field
        frame.input = CreateFrame("EditBox", nil, frame)
        CreateBackdrop(frame.input, nil, true)
        frame.input:SetTextInsets(5, 5, 5, 5)
        frame.input:SetTextColor(.2,1,.8,1)
        frame.input:SetJustifyH("RIGHT")

        frame.input:SetWidth(100)
        frame.input:SetHeight(18)
        frame.input:SetPoint("RIGHT" , -3, 0)
        frame.input:SetFontObject(GameFontNormal)
        frame.input:SetAutoFocus(false)
        frame.input:SetText(category[config])
        frame.input:SetScript("OnEscapePressed", function(self)
          this:ClearFocus()
        end)

        frame.input:SetScript("OnTextChanged", function(self)
          if ( type and type ~= "number" ) or tonumber(this:GetText()) then
            if this:GetText() ~= this:GetParent().category[this:GetParent().config] then
              this:GetParent().category[this:GetParent().config] = this:GetText()
              if ufunc then ufunc() else pfUI.gui.settingChanged = true end
            end
            this:SetTextColor(.2,1,.8,1)
          else
            this:SetTextColor(1,.3,.3,1)
          end
        end)

        -- hide shadows on wrong stratas
        if frame.input.backdrop_shadow then
          frame.input.backdrop_shadow:Hide()
        end
      end

      -- use button widget
      if widget == "button" then
        frame.button = CreateFrame("Button", "pfButton", frame, "UIPanelButtonTemplate")
        CreateBackdrop(frame.button, nil, true)
        SkinButton(frame.button)
        frame.button:SetWidth(100)
        frame.button:SetHeight(20)
        frame.button:SetPoint("TOPRIGHT", -(this.lineCount-1) * 105, -5)
        frame.button:SetText(caption)
        frame.button:SetTextColor(1,1,1,1)
        frame.button:SetScript("OnClick", values)

        -- hide shadows on wrong stratas
        if frame.button.backdrop_shadow then
          frame.button.backdrop_shadow:Hide()
        end
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
        frame.input:SetPoint("RIGHT" , -5, 1)
        frame.input:SetScript("OnClick", function ()
          if this:GetChecked() then
            this:GetParent().category[this:GetParent().config] = "1"
          else
            this:GetParent().category[this:GetParent().config] = "0"
          end

          if ufunc then ufunc() else pfUI.gui.settingChanged = true end
        end)

        if category[config] == "1" then frame.input:SetChecked() end

        -- hide shadows on wrong stratas
        if frame.input.backdrop_shadow then
          frame.input.backdrop_shadow:Hide()
        end
      end

      -- use dropdown widget
      if widget == "dropdown" and values then
        if not pfUI.gui.ddc then pfUI.gui.ddc = 1 else pfUI.gui.ddc = pfUI.gui.ddc + 1 end
        local name = pfUI.gui.ddc
        if named then name = named end

        frame.input = CreateFrame("Frame", "pfUIDropDownMenu" .. name, frame, "UIDropDownMenuTemplate")
        frame.input:ClearAllPoints()
        frame.input:SetPoint("RIGHT", 16, -3)

        UIDropDownMenu_SetWidth(160, frame.input)
        UIDropDownMenu_SetButtonWidth(160, frame.input)
        UIDropDownMenu_JustifyText("RIGHT", frame.input)
        UIDropDownMenu_Initialize(frame.input, function()
          local info = {}
          frame.input.values = _G.type(values)=="function" and values() or values
          for i, k in pairs(frame.input.values) do
            -- create new dropdown buttons when we reach the limit
            PrepareDropDownButton(i)

            -- get human readable
            local value, text = strsplit(":", k)
            text = text or value

            info.text = text
            info.checked = false
            info.func = function()
              UIDropDownMenu_SetSelectedID(frame.input, this:GetID(), 0)
              UIDropDownMenu_SetText(this:GetText(), frame.input)
              if category[config] ~= value then
                category[config] = value
                if ufunc then ufunc() else pfUI.gui.settingChanged = true end
              end
            end

            UIDropDownMenu_AddButton(info)
            if category[config] == value then
              frame.input.current = i
            end
          end
        end)
        UIDropDownMenu_SetSelectedID(frame.input, frame.input.current)

        SkinDropDown(frame.input)
        frame.input.backdrop:Hide()
        frame.input.button.icon:SetParent(frame.input.button.backdrop)

        -- hide shadows on wrong stratas
        if frame.input.backdrop_shadow then
          frame.input.backdrop_shadow:Hide()
          frame.input.button.backdrop_shadow:Hide()
        end
      end

      -- use list widget
      if widget == "list" then
        if not pfUI.gui.ddc then pfUI.gui.ddc = 1 else pfUI.gui.ddc = pfUI.gui.ddc + 1 end
        local name = pfUI.gui.ddc
        if named then name = named end

        frame.input = CreateFrame("Frame", "pfUIDropDownMenu" .. name, frame, "UIDropDownMenuTemplate")
        frame.input:ClearAllPoints()
        frame.input:SetPoint("RIGHT" , -22, -3)
        frame.category = category
        frame.config = config

        frame.input.Refresh = function()
          local function CreateValues()
            for i, val in pairs({strsplit("#", category[config])}) do
              -- create new dropdown buttons when we reach the limit
              PrepareDropDownButton(i)

              UIDropDownMenu_AddButton({
                ["text"] = val,
                ["checked"] = false,
                ["func"] = function()
                  UIDropDownMenu_SetSelectedID(frame.input, this:GetID(), 0)
                end
              })
            end
          end

          UIDropDownMenu_Initialize(frame.input, CreateValues)
          UIDropDownMenu_SetText("", frame.input)
        end

        frame.input:Refresh()

        UIDropDownMenu_SetWidth(160, frame.input)
        UIDropDownMenu_SetButtonWidth(160, frame.input)
        UIDropDownMenu_JustifyText("RIGHT", frame.input)
        UIDropDownMenu_SetSelectedID(frame.input, frame.input.current)

        SkinDropDown(frame.input)
        frame.input.backdrop:Hide()
        frame.input.button.icon:SetParent(frame.input.button.backdrop)

        frame.add = CreateFrame("Button", "pfUIDropDownMenu" .. name .. "Add", frame, "UIPanelButtonTemplate")
        SkinButton(frame.add)
        frame.add:SetWidth(18)
        frame.add:SetHeight(18)
        frame.add:SetPoint("RIGHT", -21, 0)
        frame.add:GetFontString():SetPoint("CENTER", 1, 0)
        frame.add:SetText("+")
        frame.add:SetTextColor(.5,1,.5,1)
        frame.add:SetScript("OnClick", function()
          CreateQuestionDialog(T["New entry:"], function()
              category[config] = category[config] .. "#" .. this:GetParent().input:GetText()
            end, false, true)
        end)

        frame.del = CreateFrame("Button", "pfUIDropDownMenu" .. name .. "Del", frame, "UIPanelButtonTemplate")
        SkinButton(frame.del)
        frame.del:SetWidth(18)
        frame.del:SetHeight(18)
        frame.del:SetPoint("RIGHT", -2, 0)
        frame.del:GetFontString():SetPoint("CENTER", 1, 0)
        frame.del:SetText("-")
        frame.del:SetTextColor(1,.5,.5,1)
        frame.del:SetScript("OnClick", function()
          local sel = UIDropDownMenu_GetSelectedID(frame.input)
          local newconf = ""
          for id, val in pairs({strsplit("#", category[config])}) do
            if id ~= sel then newconf = newconf .. "#" .. val end
          end
          category[config] = newconf
          frame.input:Refresh()
        end)

        -- hide shadows on wrong stratas
        if frame.input.backdrop_shadow then
          frame.input.backdrop_shadow:Hide()
          frame.input.button.backdrop_shadow:Hide()
          frame.add.backdrop_shadow:Hide()
          frame.del.backdrop_shadow:Hide()
        end
      end

      return frame
    end

    local TabFrameOnMouseDown = function()
      pfUI.gui.search:ClearFocus()
    end

    local TabFrameOnClick = function()
      if this.area:IsShown() then
        return
      else
        -- hide all others
        for id, name in pairs(this.parent) do
          if type(name) == "table" and name.area and id ~= "parent" then
            name.area:Hide()
          end
        end
        this.area:Show()
      end
    end

    local width, height = 130, 20
    function CreateTabFrame(parent, title)
      if not parent.area.count then parent.area.count = 0 end

      local f = CreateFrame("Button", nil, parent.area)
      f:SetPoint("TOPLEFT", parent.area, "TOPLEFT", 0, -parent.area.count*height)
      f:SetPoint("BOTTOMRIGHT", parent.area, "TOPLEFT", width, -(parent.area.count+1)*height)
      f.parent = parent

      f:SetScript("OnMouseDown", TabFrameOnMouseDown)
      f:SetScript("OnClick", TabFrameOnClick)

      -- background
      f.bg = f:CreateTexture(nil, "BACKGROUND")
      f.bg:SetAllPoints()

      -- text
      f.text = f:CreateFontString(nil, "LOW", "GameFontWhite")
      f.text:SetFont(pfUI.font_default, C.global.font_size)
      f.text:SetAllPoints()
      f.text:SetText(title)

      -- U element count
      parent.area.count = parent.area.count + 1

      return f
    end

    function CreateArea(parent, title, func)
      -- create drawarea
      local f = CreateFrame("Frame", nil, parent.area)
      f:SetPoint("TOPLEFT", parent.area, "TOPLEFT", width, 0)
      f:SetPoint("BOTTOMRIGHT", parent.area, "BOTTOMRIGHT", 0, 0)

      if not parent.firstarea then
        parent.firstarea = true
      else
        f:Hide()
      end

      f.button = parent[title]

      f.bg = f:CreateTexture(nil, "BACKGROUND")
      f.bg:SetTexture(1,1,1,.05)
      f.bg:SetAllPoints()

      f:SetScript("OnShow", function()
        this.indexed = true
        this.button.text:SetTextColor(.2,1,.8,1)
        this.button.bg:SetTexture(1,1,1,1)
        this.button.bg:SetGradientAlpha("HORIZONTAL", 0,0,0,0,  1,1,1,.05)
      end)

      f:SetScript("OnHide", function()
        this.button.text:SetTextColor(1,1,1,1)
        this.button.bg:SetTexture(0,0,0,0)
      end)

      -- are we a frame with contents?
      if func then
        f.scroll = CreateScrollFrame(nil, f)
        SetAllPointsOffset(f.scroll, f, 2)
        f.scroll.content = CreateScrollChild(nil, f.scroll)
        f.scroll.content.parent = f.scroll
        f.scroll.content:SetScript("OnShow", function()
          if not this.setup then
            func()
            this.setup = true
          end
        end)
      end

      return f
    end

    function CreateGUIEntry(parent, title, populate)
      -- create main menu if not yet exists
      if not pfUI.gui.frames[parent] then
        pfUI.gui.frames[parent] = CreateTabFrame(pfUI.gui.frames, parent)
        if title then
          pfUI.gui.frames[parent].area = CreateArea(pfUI.gui.frames, parent, nil)
        else
          -- populate area when no submenus are given
          pfUI.gui.frames[parent].area = CreateArea(pfUI.gui.frames, parent, populate)
          return
        end
      end

      -- create submenus when title was given
      if title and not pfUI.gui.frames[parent][title] then
        pfUI.gui.frames[parent][title] = CreateTabFrame(pfUI.gui.frames[parent], title)
        pfUI.gui.frames[parent][title].area = CreateArea(pfUI.gui.frames[parent], title, populate)
      end
    end
  end

  do -- GUI Frame
    -- main frame
    pfUI.gui = CreateFrame("Frame", "pfConfigGUI", UIParent)
    pfUI.gui:SetMovable(true)
    pfUI.gui:EnableMouse(true)
    pfUI.gui:SetWidth(720)
    pfUI.gui:SetHeight(480)
    pfUI.gui:SetFrameStrata("DIALOG")
    pfUI.gui:SetPoint("CENTER", 0, 0)
    pfUI.gui:Hide()

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

    pfUI.gui:SetScript("OnMouseDown",function()
      this:StartMoving()
    end)

    pfUI.gui:SetScript("OnMouseUp",function()
      this:StopMovingOrSizing()
    end)

    CreateBackdrop(pfUI.gui, nil, true, .85)
    table.insert(UISpecialFrames, "pfConfigGUI")

    -- make some locals available to thirdparty
    pfUI.gui.Reload = Reload
    pfUI.gui.CreateConfig = CreateConfig
    pfUI.gui.CreateGUIEntry = CreateGUIEntry
    pfUI.gui.UpdaterFunctions = U

    -- decorations
    pfUI.gui.title = pfUI.gui:CreateFontString("Status", "LOW", "GameFontNormal")
    pfUI.gui.title:SetFontObject(GameFontWhite)
    pfUI.gui.title:SetPoint("TOPLEFT", pfUI.gui, "TOPLEFT", 8, -8)
    pfUI.gui.title:SetJustifyH("LEFT")
    pfUI.gui.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\Hooge.ttf", 10)
    pfUI.gui.title:SetText("|cff33ffccpf|rUI")

    pfUI.gui.version = pfUI.gui:CreateFontString("Status", "LOW", "GameFontNormal")
    pfUI.gui.version:SetFontObject(GameFontWhite)
    pfUI.gui.version:SetPoint("LEFT", pfUI.gui.title, "RIGHT", 0, 0)
    pfUI.gui.version:SetJustifyH("LEFT")
    pfUI.gui.version:SetFont("Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf", 10)
    pfUI.gui.version:SetText("|cff555555[|r" .. pfUI.version.string.. "|cff555555]|r")

    pfUI.gui.close = CreateFrame("Button", "pfQuestionDialogClose", pfUI.gui)
    pfUI.gui.close:SetPoint("TOPRIGHT", -7, -7)
    pfUI.api.CreateBackdrop(pfUI.gui.close)
    pfUI.gui.close:SetHeight(10)
    pfUI.gui.close:SetWidth(10)
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

    -- root layer
    pfUI.gui.frames = {}
    pfUI.gui.frames.area = CreateFrame("Frame", nil, pfUI.gui)
    pfUI.gui.frames.area:SetPoint("TOPLEFT", 7, -25)
    pfUI.gui.frames.area:SetPoint("BOTTOMRIGHT", -7, 37)
    CreateBackdrop(pfUI.gui.frames.area)

    -- unlock
    pfUI.gui.unlock = CreateFrame("Button", nil, pfUI.gui)
    pfUI.gui.unlock:SetPoint("TOPLEFT", pfUI.gui.frames.area.backdrop, "BOTTOMLEFT", 0, -5)
    pfUI.gui.unlock:SetWidth(110)
    pfUI.gui.unlock:SetHeight(25)
    pfUI.gui.unlock:SetText(T["Unlock"])
    pfUI.gui.unlock:SetScript("OnClick", function()
      if pfUI.unlock then pfUI.unlock:Show() end
    end)
    SkinButton(pfUI.gui.unlock)

    -- hoverbind
    pfUI.gui.hoverbind = CreateFrame("Button", nil, pfUI.gui)
    pfUI.gui.hoverbind:SetPoint("LEFT", pfUI.gui.unlock, "RIGHT", 5, 0)
    pfUI.gui.hoverbind:SetWidth(110)
    pfUI.gui.hoverbind:SetHeight(25)
    pfUI.gui.hoverbind:SetText(T["Hoverbind"])
    pfUI.gui.hoverbind:SetScript("OnClick", function()
      if pfUI.hoverbind then pfUI.hoverbind:Show() end
    end)

    SkinButton(pfUI.gui.hoverbind)

    -- share
    pfUI.gui.share = CreateFrame("Button", nil, pfUI.gui)
    pfUI.gui.share:SetPoint("LEFT", pfUI.gui.hoverbind, "RIGHT", 5, 0)
    pfUI.gui.share:SetWidth(110)
    pfUI.gui.share:SetHeight(25)
    pfUI.gui.share:SetText(T["Share"])
    pfUI.gui.share:SetScript("OnClick", function()
      if pfShare then
        pfShare:Show()
        pfShareExport:Click()
      end
    end)
    SkinButton(pfUI.gui.share)

    -- searchbar
    local function SearchEntryClick()
      -- clear search focus
      pfUI.gui.search:ClearFocus()

      -- open submenus
      for i=table.getn(this.obj),1,-1 do
        this.obj[i]:Click()
      end

      -- highlight matched entry
      if not this.obj[-1].highlight then
        this.obj[-1].highlight = this.obj[-1]:CreateTexture(nil, "OVERLAY")
        this.obj[-1].highlight:SetAllPoints()
        this.obj[-1].highlight:SetTexture(.2,1,.8,.2)
      end
      this.obj[-1].highlight:Show()
    end

    local function CreateSearchEntry(parent, i)
      local f = CreateFrame("Button", nil, parent)
      f:SetPoint("TOPLEFT", 5, -5 + (i-1)*-25)
      f:SetWidth(565)
      f:SetHeight(20)
      f:SetScript("OnClick", SearchEntryClick)
      f:SetScript("OnUpdate", EntryUpdate)

      f.text = f:CreateFontString("Status", "LOW", "GameFontWhite")
      f.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
      f.text:SetAllPoints()
      f.text:SetJustifyH("LEFT")
      f.text:SetJustifyV("CENTER")
      f.text:SetTextColor(.5,.5,.5)

      f.tex = f:CreateTexture(nil, "BACKGROUND")
      f.tex:SetTexture(1,1,1,.05)
      f.tex:SetAllPoints()
      f.tex:Hide()

      return f
    end

    pfUI.gui.search = CreateFrame("EditBox", nil, pfUI.gui)
    pfUI.gui.search:SetPoint("LEFT", pfUI.gui.share, "RIGHT", 5, 0)
    pfUI.gui.search:SetPoint("TOPRIGHT", pfUI.gui.frames.area.backdrop, "BOTTOMRIGHT", 0, -5)
    pfUI.gui.search:SetHeight(25)
    pfUI.gui.search:SetAutoFocus(false)
    pfUI.gui.search:SetTextInsets(5, 5, 5, 5)
    pfUI.gui.search:SetTextColor(.2,1,.8,1)
    pfUI.gui.search:SetJustifyH("CENTER")
    pfUI.gui.search:SetFontObject(GameFontNormal)
    pfUI.gui.search:SetText(T["Search"] .. "...")
    CreateBackdrop(pfUI.gui.search, nil, true)

    pfUI.gui.search:SetScript("OnEscapePressed", function()
      this:ClearFocus()
      if this:GetText() == "" then
        this:SetText(T["Search"].."...")
      end
    end)

    pfUI.gui.search:SetScript("OnTextChanged", function()
      if this:GetText() == T["Search"].."..." then return end
      local defval = "["..T["Search"].."]"

      -- initialize search window
      CreateGUIEntry(defval, nil, function() end)
      pfUI.gui.frames[defval]:Click()

      local scroll = pfUI.gui.frames[defval].area.scroll.content
      local parent = pfUI.gui.frames[defval].area.scroll
      scroll.results = scroll.results or {}

      for i=1,table.getn(scroll.results) do
        scroll.results[i]:Hide()
        if scroll.results[i].obj and scroll.results[i].obj[-1].highlight then
          scroll.results[i].obj[-1].highlight:Hide()
        end
      end

      if strlen(this:GetText()) < 1 then return end

      local i = 1
      local search = strlower(this:GetText())
      for name, obj in pairs(searchDB) do
        local title = obj[0] and strlower(obj[0])
        if strfind(title, search) then
          -- build caption string
          local caption = ""
          for x=table.getn(obj),1,-1 do
            caption = caption .. "|cff33ffcc" .. obj[x].text:GetText() .. "|r » "
          end
          caption = caption .. "|cffffffff" .. obj[0]

          -- build search entry button
          scroll.results[i] = scroll.results[i] or CreateSearchEntry(scroll, i)
          scroll.results[i].obj = obj
          scroll.results[i].text:SetText(caption)
          scroll.results[i]:Show()

          i = i + 1
        end
      end

      -- reload scroll frames
      scroll:Hide()
      scroll:SetHeight(i * 25 )
      scroll:Show()
      parent:SetScrollChild(scroll)
      QueueFunction(function()
        parent:SetVerticalScroll(0)
        parent:UpdateScrollState()
        parent:Scroll()
      end)
    end)

    pfUI.gui.search:SetScript("OnEditFocusGained", function(self)
      if this:GetText() == T["Search"] .. "..." then this:SetText("") end
      if this.indexed then return end
      -- Trigger "OnShow" for each subpage to initialize search index
      for name, frame in pairs(pfUI.gui.frames) do
        if type(frame) == "table" and frame.area and name ~= "parent" then
          frame.area:Show()

          for name, frame in pairs(pfUI.gui.frames[name]) do
            if type(frame) == "table" and frame.area and name ~= "parent" and not frame.area.indexed then
              frame.area:Show()
              frame.area:Hide()
            end
          end

          frame.area:Hide()
        end
      end
      this.indexed = true
    end)
  end

  do -- DropDown Menus
    -- [[ Static Dropdowns ]] --
    pfUI.gui.dropdowns = {
      ["languages"] = {
        -- "deDE:German",
        -- "enGB:British English",
        "enUS:English",
        "esES:Spanish",
        --"esMX:Spanish (Latin American)",
        "frFR:French",
        "koKR:Korean",
        "ruRU:Russian",
        "zhCN:Chinese (simplified; China)",
        "zhTW:Chinese (traditional; Taiwan)",
        -- http://wowprogramming.com/docs/api/GetLocale
      },
      ["fonts"] = {
        "Interface\\AddOns\\pfUI\\fonts\\BigNoodleTitling.ttf:BigNoodleTitling",
        "Interface\\AddOns\\pfUI\\fonts\\Continuum.ttf:Continuum",
        "Interface\\AddOns\\pfUI\\fonts\\DieDieDie.ttf:DieDieDie",
        "Interface\\AddOns\\pfUI\\fonts\\Expressway.ttf:Expressway",
        "Interface\\AddOns\\pfUI\\fonts\\Homespun.ttf:Homespun",
        "Interface\\AddOns\\pfUI\\fonts\\Hooge.ttf:Hooge",
        "Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf:Myriad-Pro",
        "Interface\\AddOns\\pfUI\\fonts\\PT-Sans-Narrow-Bold.ttf:PT-Sans-Narrow-Bold",
        "Interface\\AddOns\\pfUI\\fonts\\PT-Sans-Narrow-Regular.ttf:PT-Sans-Narrow-Regular"
      },
      ["scaling"] = {
        "0:" .. T["Off"],
        "4:" .. T["Huge (PixelPerfect)"],
        "5:" .. T["Large"],
        "6:" .. T["Medium"],
        "7:" .. T["Small"],
        "8:" .. T["Tiny (PixelPerfect)"],
      },
      ["orientation"] = {
        "HORIZONTAL:" .. T["Horizontal"],
        "VERTICAL:" .. T["Vertical"],
      },
      ["uf_animationspeed"] = {
        "1:" .. T["Instant"],
        "2:" .. T["Very Fast"],
        "3:" .. T["Fast"],
        "5:" .. T["Medium"],
        "8:" .. T["Slow"],
        "13:" .. T["Very Slow"],
      },
      ["uf_bartexture"] = {
        "Interface\\AddOns\\pfUI\\img\\bar:pfUI",
        "Interface\\AddOns\\pfUI\\img\\bar_tukui:TukUI",
        "Interface\\AddOns\\pfUI\\img\\bar_elvui:ElvUI",
        "Interface\\AddOns\\pfUI\\img\\bar_gradient:Gradient",
        "Interface\\AddOns\\pfUI\\img\\bar_striped:Striped",
        "Interface\\TargetingFrame\\UI-StatusBar:Wow Status",
        "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar:Wow Skill"
      },
      ["uf_rangecheckinterval"] = {
        "1:" .. T["Very Fast"],
        "2:" .. T["Fast"],
        "4:" .. T["Medium"],
        "8:" .. T["Slow"],
        "16:" .. T["Very Slow"],
      },
      ["uf_powerbar_position"] = {
        "TOPLEFT:" .. T["Left"],
        "TOP:" .. T["Center"],
        "TOPRIGHT:" .. T["Right"]
      },
      ["uf_portrait_position"] = {
        "bar:" .. T["Healthbar Embedded"],
        "left:" .. T["Left"],
        "right:" .. T["Right"],
        "off:" .. T["Disabled"]
      },
      ["uf_buff_position"] = {
        "TOPLEFT:" .. T["Top Left"],
        "TOPRIGHT:" .. T["Top Right"],
        "BOTTOMLEFT:" .. T["Bottom Left"],
        "BOTTOMRIGHT:" .. T["Bottom Right"],
        "off:" .. T["Disabled"]
      },
      ["uf_debuff_indicator"] = {
        "0:" .. T["Disabled"],
        "1:" .. T["Legacy"],
        "2:" .. T["Glow"],
        "3:" .. T["Square"],
        "4:" .. T["Icon"]
      },
      ["uf_debuff_indicator_size"] = {
        ".10:10%",
        ".25:25%",
        ".35:35%",
        ".50:50%",
        ".65:65%",
        ".75:75%",
        ".90:90%",
      },
      ["uf_overheal"] = {
        "0:0%",
        "10:10%",
        "20:20%",
        "30:30%",
        "40:40%",
        "50:50%",
        "60:60%",
        "70:70%",
        "80:80%",
        "90:90%",
        "100:100%",
      },
      ["uf_layout"] = {
        "default:" .. T["Default"],
        "tukui:TukUI"
      },
      ["uf_color"] = {
        "0:" .. T["Class"],
        "1:" .. T["Custom"],
        "2:" .. T["Health"],
      },
      ["uf_texts"] = {
        "none:" .. T["Disable"],
        "unit:" .. T["Unit String"],
        "name:" .. T["Name"],
        "nameshort:" .. T["Name (Short)"],
        "level:" .. T["Level"],
        "class:" .. T["Class"],
        "namehealth:" .. T["Name | Health Missing"],
        "shortnamehealth:" .. T["Name (Short) | Health Missing"],
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
      },
      ["panel_values"] = {
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
      },
      ["tooltip_position"] = {
        "bottom:" .. T["Bottom"],
        "chat:" .. T["Dodge"],
        "cursor:" .. T["Cursor"],
        "free:" .. T["Custom"]
      },
      ["tooltip_align"] = {
        "native:" .. T["Native"],
        "top:" .. T["Top"],
        "left:" .. T["Left"],
        "right:" .. T["Right"]
      },
      ["gmserver_text"] = {
        "elysium:" .. T["Elysium Based Core"],
      },
      ["buffbarfilter"] = {
        "none:"      .. T["None"],
        "whitelist:" .. T["Whitelist"],
        "blacklist:" .. T["Blacklist"],
      },
      ["buffbarsort"] = {
        "asc:" .. T["Ascending"],
        "desc:" .. T["Descending"],
      },
      ["minimap_cords_position"] = {
        "topleft:" .. T["Top Left"],
        "topright:" .. T["Top Right"],
        "bottomleft:" .. T["Bottom Left"],
        "bottomright:" .. T["Bottom Right"],
        "off:" .. T["Disabled"]
      },
      ["positions"] = {
        "TOPLEFT:" .. T["Top Left"],
        "TOP:" .. T["Top"],
        "TOPRIGHT:" .. T["Top Right"],
        "LEFT:" .. T["Left"],
        "CENTER:" .. T["Center"],
        "RIGHT:" .. T["Right"],
        "BOTTOMLEFT:" .. T["Bottom Left"],
        "BOTTOM:" .. T["Bottom"],
        "BOTTOMRIGHT:" .. T["Bottom Right"],
      },
      ["actionbuttonanimations"] = {
        "none:" .. T["None"],
        "zoomfade:" .. T["Zoom & Fade"],
        "shrinkreturn:" .. T["Shrink & Return"],
        "elasticzoom:" .. T["Elastic Zoom"],
        "wobblezoom:" .. T["Wobble Zoom"],
      },
      ["actionbarbuttons"] = {
        "1","2","3","4","5","6","7","8","9","10","11","12"
      },
      ["addonbuttons_position"] = {
        "bottom:" .. T["Bottom"],
        "left:" .. T["Left"],
        "top:" .. T["Top"],
        "right:" .. T["Right"]
      },
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

    pfUI.gui.dropdowns.loot_rarity = {}
    for i=0, getn(_G.ITEM_QUALITY_COLORS)-2  do
      local entry = string.format("%d:%s", i, string.format("%s%s%s", _G.ITEM_QUALITY_COLORS[i].hex, _G[string.format("ITEM_QUALITY%d_DESC",i)], FONT_COLOR_CODE_CLOSE))
      table.insert(pfUI.gui.dropdowns.loot_rarity, entry)
    end

    pfUI.gui.dropdowns.screenshot_battle = {
      "0:".._G.NONE,
      "1:"..T["Won"],
      "2:"..T["Ended"],
    }
    pfUI.gui.dropdowns.screenshot_loot = {"0:".._G.NONE}
    for i=3, 5 do
      local entry = string.format("%d:%s", i, string.format("%s%s%s", _G.ITEM_QUALITY_COLORS[i].hex, _G[string.format("ITEM_QUALITY%d_DESC",i)], FONT_COLOR_CODE_CLOSE))
        table.insert(pfUI.gui.dropdowns.screenshot_loot, entry)
    end
  end

  do -- Generate Config UI
    CreateGUIEntry(T["About"], nil, function()
      -- read data
      local lang = T["Unknown"]
      for _, entry in pairs(pfUI.gui.dropdowns.languages) do
        local short, full = strsplit(":", entry)
        if short == C.global.language then
          lang = full
        end
      end

      -- draw pfUI logo
      local function draw(p, fx, fy, tx, ty, r, g, b, a)
        local t = p:CreateTexture(nil, "OVERLAY")
        t:SetTexture(r,g,b,a)
        t:SetPoint("TOPLEFT", fx, fy)
        t:SetPoint("BOTTOMRIGHT", p, "TOPLEFT", tx, ty)
      end

      local x, y, p = 250, 55, 10  -- startx, starty, pencilsize
      draw(this, x,     -y-2*p, x+p,      -y-7*p, .2, 1, .8, 1)
      draw(this, x+p,   -y-2*p, x+2*p,    -y-3*p, .2, 1, .8, 1)
      draw(this, x+p,   -y-4*p, x+2*p,    -y-5*p, .2, 1, .8, 1)
      draw(this, x+2*p, -y,     x+3*p,    -y-5*p, .2, 1, .8, 1)
      draw(this, x+3*p, -y,     x+4*p,    -y-1*p, .2, 1, .8, 1)
      draw(this, x+p,   -y-2*p, x+4*p,    -y-3*p, .2, 1, .8, 1)
      draw(this, x+4*p, -y,     x+5*p,    -y-5*p, 1,  1, 1,  1)
      draw(this, x+5*p, -y-4*p, x+5*p+p,  -y-5*p, 1,  1, 1,  1)
      draw(this, x+6*p, -y,     x+7*p,    -y-p,   1,  1, 1,  1)
      draw(this, x+6*p, -y-2*p, x+7*p,    -y-5*p, 1,  1, 1,  1)

      -- version
      this.versionc = this:CreateFontString("Status", "LOW", "GameFontWhite")
      this.versionc:SetFont(pfUI.font_default, C.global.font_size)
      this.versionc:SetPoint("TOPLEFT", 200, -170)
      this.versionc:SetWidth(200)
      this.versionc:SetJustifyH("LEFT")
      this.versionc:SetText(T["Version"] .. ":")

      this.version = this:CreateFontString("Status", "LOW", "GameFontWhite")
      this.version:SetFont(pfUI.font_default, C.global.font_size)
      this.version:SetPoint("TOPRIGHT", 375, -170)
      this.version:SetWidth(200)
      this.version:SetJustifyH("RIGHT")

      this.update = this:CreateFontString("Status", "LOW", "GameFontWhite")
      this.update:SetFont(pfUI.font_default, C.global.font_size)
      this.update:SetPoint("TOPLEFT", 200, -140)
      this.update:SetPoint("TOPRIGHT", 375, -140)
      this.update:SetJustifyH("CENTER")
      this.update:SetTextColor(.2,1,.8)

      this.screenc = this:CreateFontString("Status", "LOW", "GameFontWhite")
      this.screenc:SetFont(pfUI.font_default, C.global.font_size)
      this.screenc:SetPoint("TOPLEFT", 200, -200)
      this.screenc:SetWidth(200)
      this.screenc:SetJustifyH("LEFT")
      this.screenc:SetText(T["Resolution"] .. ":")

      this.screen = this:CreateFontString("Status", "LOW", "GameFontWhite")
      this.screen:SetFont(pfUI.font_default, C.global.font_size)
      this.screen:SetPoint("TOPRIGHT", 375, -200)
      this.screen:SetWidth(200)
      this.screen:SetJustifyH("RIGHT")

      this.scalec = this:CreateFontString("Status", "LOW", "GameFontWhite")
      this.scalec:SetFont(pfUI.font_default, C.global.font_size)
      this.scalec:SetPoint("TOPLEFT", 200, -220)
      this.scalec:SetWidth(200)
      this.scalec:SetJustifyH("LEFT")
      this.scalec:SetText(T["Scaling"] .. ":")

      this.scale = this:CreateFontString("Status", "LOW", "GameFontWhite")
      this.scale:SetFont(pfUI.font_default, C.global.font_size)
      this.scale:SetPoint("TOPRIGHT", 375, -220)
      this.scale:SetWidth(200)
      this.scale:SetJustifyH("RIGHT")

      this.clientc = this:CreateFontString("Status", "LOW", "GameFontWhite")
      this.clientc:SetFont(pfUI.font_default, C.global.font_size)
      this.clientc:SetPoint("TOPLEFT", 200, -250)
      this.clientc:SetWidth(200)
      this.clientc:SetJustifyH("LEFT")
      this.clientc:SetText(T["Gameclient"] .. ":")

      this.client = this:CreateFontString("Status", "LOW", "GameFontWhite")
      this.client:SetFont(pfUI.font_default, C.global.font_size)
      this.client:SetPoint("TOPRIGHT", 375, -250)
      this.client:SetWidth(200)
      this.client:SetJustifyH("RIGHT")

      this.langc = this:CreateFontString("Status", "LOW", "GameFontWhite")
      this.langc:SetFont(pfUI.font_default, C.global.font_size)
      this.langc:SetPoint("TOPLEFT", 200, -270)
      this.langc:SetWidth(200)
      this.langc:SetJustifyH("LEFT")
      this.langc:SetText(T["Language"] .. ":")
      this.lang = this:CreateFontString("Status", "LOW", "GameFontWhite")
      this.lang:SetFont(pfUI.font_default, C.global.font_size)
      this.lang:SetPoint("TOPRIGHT", 375, -270)
      this.lang:SetWidth(200)
      this.lang:SetJustifyH("RIGHT")

      -- info updater
      local f = CreateFrame("Frame", nil, this)
      f:SetScript("OnUpdate", function()
        if ( this.tick or 0) > GetTime() then return else this.tick = GetTime() + 1 end

        local parent = this:GetParent()
        local localversion  = tonumber(pfUI.version.major*10000 + pfUI.version.minor*100 + pfUI.version.fix)
        local remoteversion = tonumber(pfUI_init.updateavailable) or 0
        if localversion < remoteversion then
          parent.update:SetText("|cffffffff[|r!|cffffffff] " .. T["A new version is available"])
        end

        parent.version:SetText(pfUI.version.string)
        parent.screen:SetText(GetCVar("gxResolution"))
        parent.scale:SetText(round(UIParent:GetEffectiveScale(),2))
        parent.client:SetText(GetBuildInfo() .. " (" .. GetLocale() .. ")")
        parent.lang:SetText(lang)
      end)

      local discord = CreateFrame("Button", nil, this)
      discord:SetPoint("TOPLEFT", 150, -335)
      discord:SetWidth(125)
      discord:SetHeight(20)
      discord:SetText(T["Join Discord"])
      discord:SetScript("OnClick", function()
        pfUI.chat.urlcopy.CopyText("https://discord.gg/QTRKanu")
      end)
      SkinButton(discord)

      local website = CreateFrame("Button", nil, this)
      website:SetPoint("TOPLEFT", 300, -335)
      website:SetWidth(125)
      website:SetHeight(20)
      website:SetText(T["Website"])
      website:SetScript("OnClick", function()
        pfUI.chat.urlcopy.CopyText("https://shagu.org/pfUI")
      end)
      SkinButton(website)
    end)

    CreateGUIEntry(T["Settings"], T["General"], function()
      local header = CreateConfig(nil, T["Profile"], nil, nil, "header")
      header:GetParent().objectCount = header:GetParent().objectCount - 1
      header:SetHeight(20)

      local values = {}
      for name, config in pairs(pfUI_profiles) do table.insert(values, name) end

      local function ReloadProfiles()
        local oldval = UIDropDownMenu_GetText(pfUIDropDownMenuProfile)
        local values = {}
        local exists

        for name, config in pairs(pfUI_profiles) do
          table.insert(values, name)
          if name == oldval then
            exists = true
          end
        end

        if not exists then
          UIDropDownMenu_SetText("", pfUIDropDownMenuProfile)
          UIDropDownMenu_SetSelectedID(pfUIDropDownMenuProfile, 0, 0)
        end

        return values
      end

      CreateConfig(function() return end, T["Select profile"], C.global, "profile", "dropdown", ReloadProfiles, false, "Profile")

      -- load profile
      CreateConfig(nil, T["Load profile"], C.global, "profile", "button", function()
        if C.global.profile and pfUI_profiles[C.global.profile] then
          CreateQuestionDialog(T["Load profile"] .. " '|cff33ffcc" .. C.global.profile .. "|r'?", function()
            local selp = C.global.profile
            _G["pfUI_config"] = CopyTable(pfUI_profiles[C.global.profile])
            pfUI:LoadConfig()
            C.global.profile = selp
            ReloadUI()
          end)
        end
      end)

      -- delete profile
      CreateConfig(nil, T["Delete profile"], C.global, "profile", "button", function()
        if C.global.profile and pfUI_profiles[C.global.profile] then
          CreateQuestionDialog(T["Delete profile"] .. " '|cff33ffcc" .. C.global.profile .. "|r'?", function()
            pfUI_profiles[C.global.profile] = nil
            ReloadProfiles()
            this:GetParent():Hide()
          end)
        end
      end, true)

      -- save profile
      CreateConfig(nil, T["Save profile"], C.global, "profile", "button", function()
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
      CreateConfig(nil, T["Create Profile"], C.global, "profile", "button", function()
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
              this:GetParent():Hide()
              ReloadProfiles()
            end
          end
        end, false, true)
      end, true)

      CreateConfig(nil, T["Settings"], nil, nil, "header")
      CreateConfig(nil, T["Language"], C.global, "language", "dropdown", pfUI.gui.dropdowns.languages)
      CreateConfig(nil, T["Enable Region Compatible Font"], C.global, "force_region", "checkbox")
      CreateConfig(nil, T["Standard Text Font"], C.global, "font_default", "dropdown", pfUI.gui.dropdowns.fonts)
      CreateConfig(nil, T["Standard Text Font Size"], C.global, "font_size")
      CreateConfig(nil, T["Unit Frame Text Font"], C.global, "font_unit", "dropdown", pfUI.gui.dropdowns.fonts)
      CreateConfig(nil, T["Unit Frame Text Size"], C.global, "font_unit_size")
      CreateConfig(nil, T["Scrolling Combat Text Font"], C.global, "font_combat", "dropdown", pfUI.gui.dropdowns.fonts)
      CreateConfig(U["pixelperfect"], T["Enable UI-Scale"], C.global, "pixelperfect", "dropdown", pfUI.gui.dropdowns.scaling)
      CreateConfig(nil, T["Enable Offscreen Frame Positions"], C.global, "offscreen", "checkbox")
      CreateConfig(nil, T["Enable Single Line UIErrors"], C.global, "errors_limit", "checkbox")
      CreateConfig(nil, T["Disable All UIErrors"], C.global, "errors_hide", "checkbox")
      CreateConfig(nil, T["Highlight Settings That Require Reload"], C.gui, "reloadmarker", "checkbox")

      -- Delete / Reset
      CreateConfig(nil, T["Delete / Reset"], nil, nil, "header")
      CreateConfig(nil, T["|cffff5555EVERYTHING"], C.global, "profile", "button", function()
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

      CreateConfig(nil, T["Configuration"], C.global, "profile", "button", function()
        CreateQuestionDialog(T["Do you really want to reset your configuration?\nThis also includes frame positions"],
          function()
            _G["pfUI_config"] = {}
            _G["pfUI_init"] = {}
            pfUI:LoadConfig()
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end, true)

      CreateConfig(nil, T["Cache"], C.global, "profile", "button", function()
        CreateQuestionDialog(T["Do you really want to reset the Cache?"],
          function()
            _G["pfUI_playerDB"] = {}
            this:GetParent():Hide()
            pfUI.gui:Reload()
          end)
      end, true)

      CreateConfig(nil, T["Firstrun"], C.global, "profile", "button", function()
        _G["pfUI_init"] = {}
        pfUI.gui:Hide()
        pfUI.firstrun:NextStep()
      end, true)
    end)

    CreateGUIEntry(T["Settings"], T["Appearance"], function()
      CreateConfig(nil, T["Background Color"], C.appearance.border, "background", "color")
      CreateConfig(nil, T["Border Color"], C.appearance.border, "color", "color")
      CreateConfig(U["mapreveal"], T["Map Reveal Color"], C.appearance.worldmap, "mapreveal_color", "color")
      CreateConfig(nil) -- spacer
      CreateConfig(nil, T["Enable Frame Shadow"], C.appearance.border, "shadow", "checkbox")
      CreateConfig(nil, T["Frame Shadow Intensity"], C.appearance.border, "shadow_intensity", "dropdown", pfUI.gui.dropdowns.uf_debuff_indicator_size)
      CreateConfig(nil) -- spacer
      CreateConfig(nil, T["Global Border Size"], C.appearance.border, "default")
      CreateConfig(nil, T["Action Bar Border Size"], C.appearance.border, "actionbars")
      CreateConfig(nil, T["Unit Frame Border Size"], C.appearance.border, "unitframes")
      CreateConfig(nil, T["Panel Border Size"], C.appearance.border, "panels")
      CreateConfig(nil, T["Chat Border Size"], C.appearance.border, "chat")
      CreateConfig(nil, T["Bags Border Size"], C.appearance.border, "bags")
      CreateConfig(nil) -- spacer
      CreateConfig(nil, T["Enable Combat Glow Effects On Screen Edges"], C.appearance.infight, "screen", "checkbox")
    end)

    CreateGUIEntry(T["Settings"], T["Cooldown"], function()
      CreateConfig(nil, T["Cooldown Color (Less than 3 Sec)"], C.appearance.cd, "lowcolor", "color")
      CreateConfig(nil, T["Cooldown Color (Seconds)"], C.appearance.cd, "normalcolor", "color")
      CreateConfig(nil, T["Cooldown Color (Minutes)"], C.appearance.cd, "minutecolor", "color")
      CreateConfig(nil, T["Cooldown Color (Hours)"], C.appearance.cd, "hourcolor", "color")
      CreateConfig(nil, T["Cooldown Color (Days)"], C.appearance.cd, "daycolor", "color")
      CreateConfig(nil, T["Cooldown Text Threshold"], C.appearance.cd, "threshold")
      CreateConfig(nil, T["Cooldown Text Font Size"], C.appearance.cd, "font_size")
      CreateConfig(nil, T["Display Debuff Durations"], C.appearance.cd, "debuffs", "checkbox")
      CreateConfig(nil, T["Enable Durations On Blizzard Frames"], C.appearance.cd, "blizzard", "checkbox")
      CreateConfig(nil, T["Enable Durations On Foreign Frames"], C.appearance.cd, "foreign", "checkbox")
    end)

    CreateGUIEntry(T["Settings"], T["Screenshot"], function()
      CreateConfig(nil, T["Timer In Minutes"], C.screenshot, "interval")
      CreateConfig(nil, T["Level Up"], C.screenshot, "levelup", "checkbox")
      CreateConfig(nil, T["PvP Rank"], C.screenshot, "pvprank", "checkbox")
      CreateConfig(nil, T["Reputation Level"], C.screenshot, "faction", "checkbox")
      CreateConfig(nil, T["Honorable Kill"], C.screenshot, "hk", "checkbox")
      CreateConfig(nil, T["Battleground Statistics"], C.screenshot, "battleground", "dropdown", pfUI.gui.dropdowns.screenshot_battle)
      CreateConfig(nil, T["Item Looted"], C.screenshot, "loot", "dropdown", pfUI.gui.dropdowns.screenshot_loot)
      CreateConfig(nil, T["Options"], nil, nil, "header")
      CreateConfig(nil, T["Show Description"], C.screenshot, "caption", "checkbox")
      CreateConfig(nil, T["Description Font"], C.screenshot, "caption_font", "dropdown", pfUI.gui.dropdowns.fonts)
      CreateConfig(nil, T["Description Font Size"], C.screenshot, "caption_size")
      CreateConfig(nil, T["Hide All UI Elements"], C.screenshot, "hideui", "checkbox")
    end)

    CreateGUIEntry(T["Settings"], T["GM-Mode"], function()
      CreateConfig(nil, T["Disable GM-Mode"], C.gm, "disable", "checkbox")
      CreateConfig(nil, T["Selected Core"], C.gm, "server", "dropdown", pfUI.gui.dropdowns.gmserver_text)
    end)

    CreateGUIEntry(T["Unit Frames"], T["General"], function()
      CreateConfig(nil, T["Disable pfUI Unit Frames"], C.unitframes, "disable", "checkbox")
      CreateConfig(nil, T["Healthbar Animation Speed"], C.unitframes, "animation_speed", "dropdown", pfUI.gui.dropdowns.uf_animationspeed)
      CreateConfig(nil, T["Portrait Alpha"], C.unitframes, "portraitalpha")
      CreateConfig(nil, T["Always Use 2D Portraits"], C.unitframes, "always2dportrait", "checkbox")
      CreateConfig(nil, T["Enable 2D Portraits As Fallback"], C.unitframes, "portraittexture", "checkbox")
      CreateConfig(nil, T["Unit Frame Layout"], C.unitframes, "layout", "dropdown", pfUI.gui.dropdowns.uf_layout)
      CreateConfig(nil, T["Enable 40y-Range Check"], C.unitframes, "rangecheck", "checkbox")
      CreateConfig(nil, T["Range Check Interval"], C.unitframes, "rangechecki", "dropdown", pfUI.gui.dropdowns.uf_rangecheckinterval)
      CreateConfig(nil, T["Combopoint Size"], C.unitframes, "combosize")
      CreateConfig(nil, T["Abbreviate Numbers (4200 -> 4.2k)"], C.unitframes, "abbrevnum", "checkbox")
      CreateConfig(nil, T["Show Resting"], C.unitframes.player, "showRest", "checkbox")
      CreateConfig(nil, T["Enable Energy Ticks"], C.unitframes.player, "energy", "checkbox")

      CreateConfig(U[c], T["Colors"], nil, nil, "header")
      CreateConfig(nil, T["Enable Pastel Colors"], C.unitframes, "pastel", "checkbox")
      CreateConfig(nil, T["Health Bar Color"], C.unitframes, "custom", "dropdown", pfUI.gui.dropdowns.uf_color)
      CreateConfig(nil, T["Custom Health Bar Color"], C.unitframes, "customcolor", "color")
      CreateConfig(nil, T["Use Custom Color On Full Health"], C.unitframes, "customfullhp", "checkbox")
      CreateConfig(nil, T["Enable Custom Color Health Bar Background"], C.unitframes, "custombg", "checkbox")
      CreateConfig(nil, T["Custom Health Bar Background Color"], C.unitframes, "custombgcolor", "color")
      CreateConfig(nil, T["Mana Color"], C.unitframes, "manacolor", "color")
      CreateConfig(nil, T["Rage Color"], C.unitframes, "ragecolor", "color")
      CreateConfig(nil, T["Energy Color"], C.unitframes, "energycolor", "color")
      CreateConfig(nil, T["Focus Color"], C.unitframes, "focuscolor", "color")
    end)

    CreateGUIEntry(T["Group Frames"], T["General"], function()
      CreateConfig(nil, T["Use Raid Frames To Display Group Members"], C.unitframes, "raidforgroup", "checkbox")
      CreateConfig(nil, T["Always Show Self In Raid Frames"], C.unitframes, "selfinraid", "checkbox")
      CreateConfig(nil, T["Show Self In Group Frames"], C.unitframes, "selfingroup", "checkbox")
      CreateConfig(nil, T["Hide Group Frames While In Raid"], C.unitframes.group, "hide_in_raid", "checkbox")
      CreateConfig(nil, T["Show Hots as Buff Indicators"], C.unitframes, "show_hots", "checkbox")
      CreateConfig(nil, T["Show Hots of all Classes"], C.unitframes, "all_hots", "checkbox")
      CreateConfig(nil, T["Show Procs as Buff Indicators"], C.unitframes, "show_procs", "checkbox")
      CreateConfig(nil, T["Show Totems as Buff Indicators"], C.unitframes, "show_totems", "checkbox")
      CreateConfig(nil, T["Show Procs of all Classes"], C.unitframes, "all_procs", "checkbox")
      CreateConfig(nil, T["Buff Indicator Size"], C.unitframes, "indicator_size")
      CreateConfig(nil, T["Only Show Indicators for Dispellable Debuffs"], C.unitframes, "debuffs_class", "checkbox")
      CreateConfig(nil, T["Clickcast Spells"], nil, nil, "header")
      CreateConfig(nil, T["Click Action"], C.unitframes, "clickcast", nil, nil, nil, nil, "STRING")
      CreateConfig(nil, T["Shift-Click Action"], C.unitframes, "clickcast_shift", nil, nil, nil, nil, "STRING")
      CreateConfig(nil, T["Alt-Click Action"], C.unitframes, "clickcast_alt", nil, nil, nil, nil, "STRING")
      CreateConfig(nil, T["Ctrl-Click Action"], C.unitframes, "clickcast_ctrl", nil, nil, nil, nil, "STRING")
    end)

    -- Shared Unit- and Groupframes
    local unitframeSettings = {
      ["uf"] = {
        --      config,     text
        [1] = { "player",   T["Player"] },
        [2] = { "target",   T["Target"] },
        [3] = { "ttarget",  T["Target-Target"]},
        [4] = { "pet",      T["Pet"] },
        [5] = { "ptarget",  T["Pet-Target"]},
        [6] = { "focus",    T["Focus"] },
      },

      ["gf"] = {
        --      config,         text
        [1] = { "raid",         T["Raid"] },
        [2] = { "group",        T["Group"] },
        [3] = { "grouptarget",  T["Group-Target"]},
        [4] = { "grouppet",     T["Group-Pet"] },
      }
    }

    for label in pairs(unitframeSettings) do
      for id, data in pairs(unitframeSettings[label]) do
        local c = data[1]
        local t = data[2]

        CreateGUIEntry(label == "uf" and T["Unit Frames"] or T["Group Frames"], t, function()
          -- link Update tables
          U.ttarget     = U["targettarget"]
          U.ptarget     = U["pettarget"]
          U.grouptarget = U["group"]
          U.grouppet    = U["group"]

          -- build config entries
          CreateConfig(U[c], T["Display Frame"] .. ": " .. t, C.unitframes[c], "visible", "checkbox")
          CreateConfig(U[c], T["Enable Mouseover Tooltip"], C.unitframes[c], "showtooltip", "checkbox")
          CreateConfig(U[c], T["Enable Clickcast"], C.unitframes[c], "clickcast", "checkbox")
          CreateConfig(U[c], T["Enable Range Fading"], C.unitframes[c], "faderange", "checkbox")
          CreateConfig(U[c], T["Enable Aggro Glow"], C.unitframes[c], "glowaggro", "checkbox")
          CreateConfig(U[c], T["Enable Combat Glow"], C.unitframes[c], "glowcombat", "checkbox")
          CreateConfig(U[c], T["Portrait Position"], C.unitframes[c], "portrait", "dropdown", pfUI.gui.dropdowns.uf_portrait_position)
          CreateConfig(U[c], T["Status Bar Texture"], C.unitframes[c], "bartexture", "dropdown", pfUI.gui.dropdowns.uf_bartexture)
          CreateConfig(U[c], T["UnitFrame Spacing"], C.unitframes[c], "pspace")
          CreateConfig(U[c], T["Show PvP-Flag"], C.unitframes[c], "showPVP", "checkbox")
          CreateConfig(U[c], T["Show Loot Icon"], C.unitframes[c], "looticon", "checkbox")
          CreateConfig(U[c], T["Show Leader Icon"], C.unitframes[c], "leadericon", "checkbox")
          CreateConfig(U[c], T["Show Raid Mark"], C.unitframes[c], "raidicon", "checkbox")
          CreateConfig(U[c], T["Raid Mark Size"], C.unitframes[c], "raidiconsize")
          CreateConfig(U[c], T["Show Class Buff Indicators"], C.unitframes[c], "buff_indicator", "checkbox")
          CreateConfig(U[c], T["Display Overheal"], C.unitframes[c], "overhealperc", "dropdown", pfUI.gui.dropdowns.uf_overheal)

          CreateConfig(U[c], T["Healthbar"], nil, nil, "header")
          CreateConfig(U[c], T["Health Bar Width"], C.unitframes[c], "width")
          CreateConfig(U[c], T["Health Bar Height"], C.unitframes[c], "height")
          CreateConfig(U[c], T["Left Text"], C.unitframes[c], "txthpleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
          CreateConfig(U[c], T["Center Text"], C.unitframes[c], "txthpcenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
          CreateConfig(U[c], T["Right Text"], C.unitframes[c], "txthpright", "dropdown", pfUI.gui.dropdowns.uf_texts)
          CreateConfig(U[c], T["Invert Health Bar"], C.unitframes[c], "invert_healthbar", "checkbox")
          CreateConfig(U[c], T["Enable Vertical Health Bar"], C.unitframes[c], "verticalbar", "checkbox")

          CreateConfig(U[c], T["Powerbar"], nil, nil, "header")
          CreateConfig(U[c], T["Power Bar Height"], C.unitframes[c], "pheight")
          CreateConfig(U[c], T["Power Bar Width"], C.unitframes[c], "pwidth")
          CreateConfig(U[c], T["Left Text"], C.unitframes[c], "txtpowerleft", "dropdown", pfUI.gui.dropdowns.uf_texts)
          CreateConfig(U[c], T["Center Text"], C.unitframes[c], "txtpowercenter", "dropdown", pfUI.gui.dropdowns.uf_texts)
          CreateConfig(U[c], T["Right Text"], C.unitframes[c], "txtpowerright", "dropdown", pfUI.gui.dropdowns.uf_texts)
          CreateConfig(U[c], T["Power Bar Anchor"], C.unitframes[c], "panchor", "dropdown", pfUI.gui.dropdowns.uf_powerbar_position)

          CreateConfig(U[c], T["Combat Text"], nil, nil, "header")
          CreateConfig(U[c], T["Show Combat Text"], C.unitframes[c], "hitindicator", "checkbox")
          CreateConfig(U[c], T["Combat Text Font"], C.unitframes[c], "hitindicatorfont", "dropdown", pfUI.gui.dropdowns.fonts)
          CreateConfig(U[c], T["Combat Text Size"], C.unitframes[c], "hitindicatorsize")

          CreateConfig(U[c], T["Text Colors"], nil, nil, "header")
          CreateConfig(U[c], T["Automatic Health Text Color"], C.unitframes[c], "healthcolor", "checkbox")
          CreateConfig(U[c], T["Automatic Power Text Color"], C.unitframes[c], "powercolor", "checkbox")
          CreateConfig(U[c], T["Automatic Level Text Color"], C.unitframes[c], "levelcolor", "checkbox")
          CreateConfig(U[c], T["Automatic Class Text Color"], C.unitframes[c], "classcolor", "checkbox")

          CreateConfig(U[c], T["Debuff Indicators"], nil, nil, "header")
          CreateConfig(U[c], T["Debuff Indicator Display"], C.unitframes[c], "debuff_indicator", "dropdown", pfUI.gui.dropdowns.uf_debuff_indicator)
          CreateConfig(U[c], T["Debuff Indicator Position"], C.unitframes[c], "debuff_ind_pos", "dropdown", pfUI.gui.dropdowns.positions)
          CreateConfig(U[c], T["Debuff Indicator Size"], C.unitframes[c], "debuff_ind_size", "dropdown", pfUI.gui.dropdowns.uf_debuff_indicator_size)

          CreateConfig(U[c], T["Buffs"], nil, nil, "header")
          CreateConfig(U[c], T["Buff Position"], C.unitframes[c], "buffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
          CreateConfig(U[c], T["Buff Size"], C.unitframes[c], "buffsize")
          CreateConfig(U[c], T["Buff Limit"], C.unitframes[c], "bufflimit")
          CreateConfig(U[c], T["Buffs Per Row"], C.unitframes[c], "buffperrow")

          CreateConfig(U[c], T["Debuffs"], nil, nil, "header")
          CreateConfig(U[c], T["Debuff Position"], C.unitframes[c], "debuffs", "dropdown", pfUI.gui.dropdowns.uf_buff_position)
          CreateConfig(U[c], T["Debuff Size"], C.unitframes[c], "debuffsize")
          CreateConfig(U[c], T["Debuff Limit"], C.unitframes[c], "debufflimit")
          CreateConfig(U[c], T["Debuffs Per Row"], C.unitframes[c], "debuffperrow")

          CreateConfig(U[c], T["Overwrite Colors"], nil, nil, "header")
          CreateConfig(U[c], T["Inherit Default Colors"], C.unitframes[c], "defcolor", "checkbox")
          CreateConfig(U[c], T["Health Bar Color"], C.unitframes[c], "custom", "dropdown", pfUI.gui.dropdowns.uf_color)
          CreateConfig(U[c], T["Custom Health Bar Color"], C.unitframes[c], "customcolor", "color")
          CreateConfig(U[c], T["Use Custom Color On Full Health"], C.unitframes[c], "customfullhp", "checkbox")
          CreateConfig(U[c], T["Custom Health Bar Background Color"], C.unitframes[c], "custombgcolor", "color")
          CreateConfig(U[c], T["Use Custom Color Health Bar Background"], C.unitframes[c], "custombg", "checkbox")
          CreateConfig(U[c], T["Mana Color"], C.unitframes[c], "manacolor", "color")
          CreateConfig(U[c], T["Rage Color"], C.unitframes[c], "ragecolor", "color")
          CreateConfig(U[c], T["Energy Color"], C.unitframes[c], "energycolor", "color")
          CreateConfig(U[c], T["Focus Color"], C.unitframes[c], "focuscolor", "color")
        end)
      end
    end

    CreateGUIEntry(T["Bags & Bank"], nil, function()
      CreateConfig(nil, T["Disable Item Quality Color For \"Common\" Items"], C.appearance.bags, "borderlimit", "checkbox")
      CreateConfig(nil, T["Enable Item Quality Color For Equipment Only"], C.appearance.bags, "borderonlygear", "checkbox")
      CreateConfig(nil, T["Highlight Unusable Items"], C.appearance.bags, "unusable", "checkbox")
      CreateConfig(nil, T["Unusable Item Color"], C.appearance.bags, "unusable_color", "color")
      CreateConfig(nil, T["Enable Movable Bags"], C.appearance.bags, "movable", "checkbox")
      CreateConfig(nil, T["Hide Chat When Bags Are Opened"], C.appearance.bags, "hidechat", "checkbox")
      CreateConfig(nil, T["Bagslots Per Row"], C.appearance.bags, "bagrowlength")
      CreateConfig(nil, T["Bankslots Per Row"], C.appearance.bags, "bankrowlength")
      CreateConfig(nil, T["Item Slot Size"], C.appearance.bags, "icon_size")
      CreateConfig(nil, T["Auto Sell Grey Items"], C.global, "autosell", "checkbox")
      CreateConfig(nil, T["Auto Repair Items"], C.global, "autorepair", "checkbox")
    end)

    CreateGUIEntry(T["Loot"], nil, function()
      CreateConfig(nil, T["Enable Auto-Resize Loot Frame"], C.loot, "autoresize", "checkbox")
      CreateConfig(nil, T["Disable Loot Confirmation Dialog (Without Group)"], C.loot, "autopickup", "checkbox")
      CreateConfig(nil, T["Enable Loot Window On MouseCursor"], C.loot, "mousecursor", "checkbox")
      CreateConfig(nil, T["Enable Advanced Master Loot Menu"], C.loot, "advancedloot", "checkbox")
      CreateConfig(nil, T["Random Roll Announcement Rarity"], C.loot, "rollannouncequal", "dropdown", pfUI.gui.dropdowns.loot_rarity)
      CreateConfig(nil, T["Detailed Random Roll Announcement"], C.loot, "rollannounce", "checkbox")
      CreateConfig(nil, T["Use Item Rarity Color For Loot-Roll Timer"], C.loot, "raritytimer", "checkbox")
    end)

    CreateGUIEntry(T["Minimap"], T["Minimap"], function()
      CreateConfig(nil, T["Enable Zone Text On Minimap Mouseover"], C.appearance.minimap, "mouseoverzone", "checkbox")
      CreateConfig(nil, T["Coordinates Location"], C.appearance.minimap, "coordsloc", "dropdown", pfUI.gui.dropdowns.minimap_cords_position)
      CreateConfig(nil, T["Show PvP Icon"], C.unitframes.player, "showPVPMinimap", "checkbox")
      CreateConfig(nil, T["Show Inactive Tracking"], C.appearance.minimap, "tracking_pulse", "checkbox")
      CreateConfig(nil, T["Tracking Icon Size"], C.appearance.minimap, "tracking_size")
    end)

    CreateGUIEntry(T["Minimap"], T["Addon Buttons"], function()
      CreateConfig(nil,               T["Enable Addon Button Frame"], C.abuttons, "enable", "checkbox")
      CreateConfig(U["addonbuttons"], T["Addon Buttons Panel Position"], C.abuttons, "position", "dropdown", pfUI.gui.dropdowns.addonbuttons_position)
      CreateConfig(U["addonbuttons"], T["Show Addon Buttons On Login"], C.abuttons, "showdefault", "checkbox")
      CreateConfig(U["addonbuttons"], T["Number Of Buttons Per Row/Column"], C.abuttons, "rowsize")
      CreateConfig(U["addonbuttons"], T["Button Spacing"], C.abuttons, "spacing")
      CreateConfig(U["addonbuttons"], T["Hide When Entering Combat"], C.abuttons, "hideincombat", "checkbox")
    end)

    CreateGUIEntry(T["Buffs"], T["Buff/Debuff Icons"], function()
      CreateConfig(U["buff"], T["Enable Buff Display"], C.buffs, "buffs", "checkbox")
      CreateConfig(U["buff"], T["Enable Debuff Display"], C.buffs, "debuffs", "checkbox")
      CreateConfig(U["buff"], T["Enable Weapon Buff Display"], C.buffs, "weapons", "checkbox")
      CreateConfig(U["buff"], T["Seperate Weapon Buffs"], C.buffs, "separateweapons", "checkbox")
      CreateConfig(U["buff"], T["Buff Size"], C.buffs, "size")
      CreateConfig(U["buff"], T["Buff Spacing"], C.buffs, "spacing")
      CreateConfig(U["buff"], T["Number Of Weapon Buffs Per Row"], C.buffs, "wepbuffrowsize")
      CreateConfig(U["buff"], T["Number Of Buffs Per Row"], C.buffs, "buffrowsize")
      CreateConfig(U["buff"], T["Number Of Debuffs Per Row"], C.buffs, "debuffrowsize")
      CreateConfig(U["buff"], T["Show Duration Inside Buff"], C.buffs, "textinside", "checkbox")
      CreateConfig(U["buff"], T["Buff Font Size"], C.buffs, "fontsize")
    end)

    CreateGUIEntry(T["Buffs"], T["Player Buff Bar"], function()
      CreateConfig(nil, T["Enable Bar"], C.buffbar.pbuff, "enable", "checkbox")
      CreateConfig(nil, T["Use Unit Fonts"], C.buffbar.pbuff, "use_unitfonts", "checkbox")
      CreateConfig(nil, T["Sort Order"], C.buffbar.pbuff, "sort", "dropdown", pfUI.gui.dropdowns.buffbarsort)
      CreateConfig(nil, T["Background Color"], C.buffbar.pbuff, "color", "color")
      CreateConfig(nil, T["Border Color"], C.buffbar.pbuff, "bordercolor", "color")
      CreateConfig(nil, T["Text Color"], C.buffbar.pbuff, "textcolor", "color")
      CreateConfig(nil, T["Automatic Background Color"], C.buffbar.pbuff, "dtypebg", "checkbox")
      CreateConfig(nil, T["Automatic Border Color"], C.buffbar.pbuff, "dtypeborder", "checkbox")
      CreateConfig(nil, T["Automatic Text Color"], C.buffbar.pbuff, "dtypetext", "checkbox")
      CreateConfig(nil, T["Color Buff Stacks"], C.buffbar.pbuff, "colorstacks", "checkbox")
      CreateConfig(nil, T["Buffbar Width"], C.buffbar.pbuff, "width")
      CreateConfig(nil, T["Buffbar Height"], C.buffbar.pbuff, "height")
      CreateConfig(nil, T["Filter Mode"], C.buffbar.pbuff, "filter", "dropdown", pfUI.gui.dropdowns.buffbarfilter)
      CreateConfig(nil, T["Time Threshold"], C.buffbar.pbuff, "threshold")
      CreateConfig(nil, T["Whitelist"], C.buffbar.pbuff, "whitelist", "list")
      CreateConfig(nil, T["Blacklist"], C.buffbar.pbuff, "blacklist", "list")
    end)

    CreateGUIEntry(T["Buffs"], T["Player Debuff Bar"], function()
      CreateConfig(nil, T["Enable Bar"], C.buffbar.pdebuff, "enable", "checkbox")
      CreateConfig(nil, T["Use Unit Fonts"], C.buffbar.pdebuff, "use_unitfonts", "checkbox")
      CreateConfig(nil, T["Sort Order"], C.buffbar.pdebuff, "sort", "dropdown", pfUI.gui.dropdowns.buffbarsort)
      CreateConfig(nil, T["Background Color"], C.buffbar.pdebuff, "color", "color")
      CreateConfig(nil, T["Border Color"], C.buffbar.pdebuff, "bordercolor", "color")
      CreateConfig(nil, T["Text Color"], C.buffbar.pdebuff, "textcolor", "color")
      CreateConfig(nil, T["Automatic Background Color"], C.buffbar.pdebuff, "dtypebg", "checkbox")
      CreateConfig(nil, T["Automatic Border Color"], C.buffbar.pdebuff, "dtypeborder", "checkbox")
      CreateConfig(nil, T["Automatic Text Color"], C.buffbar.pdebuff, "dtypetext", "checkbox")
      CreateConfig(nil, T["Color Debuff Stacks"], C.buffbar.pdebuff, "colorstacks", "checkbox")
      CreateConfig(nil, T["Buffbar Width"], C.buffbar.pdebuff, "width")
      CreateConfig(nil, T["Buffbar Height"], C.buffbar.pdebuff, "height")
      CreateConfig(nil, T["Filter Mode"], C.buffbar.pdebuff, "filter", "dropdown", pfUI.gui.dropdowns.buffbarfilter)
      CreateConfig(nil, T["Time Threshold"], C.buffbar.pdebuff, "threshold")
      CreateConfig(nil, T["Whitelist"], C.buffbar.pdebuff, "whitelist", "list")
      CreateConfig(nil, T["Blacklist"], C.buffbar.pdebuff, "blacklist", "list")
    end)

    CreateGUIEntry(T["Buffs"], T["Target Debuff Bar"], function()
      CreateConfig(nil, T["Enable Bar"], C.buffbar.tdebuff, "enable", "checkbox")
      CreateConfig(nil, T["Use Unit Fonts"], C.buffbar.tdebuff, "use_unitfonts", "checkbox")
      CreateConfig(nil, T["Sort Order"], C.buffbar.tdebuff, "sort", "dropdown", pfUI.gui.dropdowns.buffbarsort)
      CreateConfig(nil, T["Background Color"], C.buffbar.tdebuff, "color", "color")
      CreateConfig(nil, T["Border Color"], C.buffbar.tdebuff, "bordercolor", "color")
      CreateConfig(nil, T["Text Color"], C.buffbar.tdebuff, "textcolor", "color")
      CreateConfig(nil, T["Automatic Background Color"], C.buffbar.tdebuff, "dtypebg", "checkbox")
      CreateConfig(nil, T["Automatic Border Color"], C.buffbar.tdebuff, "dtypeborder", "checkbox")
      CreateConfig(nil, T["Automatic Text Color"], C.buffbar.tdebuff, "dtypetext", "checkbox")
      CreateConfig(nil, T["Color Debuff Stacks"], C.buffbar.tdebuff, "colorstacks", "checkbox")
      CreateConfig(nil, T["Buffbar Width"], C.buffbar.tdebuff, "width")
      CreateConfig(nil, T["Buffbar Height"], C.buffbar.tdebuff, "height")
      CreateConfig(nil, T["Filter Mode"], C.buffbar.tdebuff, "filter", "dropdown", pfUI.gui.dropdowns.buffbarfilter)
      CreateConfig(nil, T["Time Threshold"], C.buffbar.tdebuff, "threshold")
      CreateConfig(nil, T["Whitelist"], C.buffbar.tdebuff, "whitelist", "list")
      CreateConfig(nil, T["Blacklist"], C.buffbar.tdebuff, "blacklist", "list")
    end)

    CreateGUIEntry(T["Actionbar"], T["General"], function()
      CreateConfig(U["bars"], T["Trigger Actions On Key Down"], C.bars, "keydown", "checkbox")
      CreateConfig(U["bars"], T["Alt Self Cast For All Hotkeys"], C.bars, "altself", "checkbox")
      CreateConfig(U["bars"], T["Button Animation"], C.bars, "animation", "dropdown", pfUI.gui.dropdowns.actionbuttonanimations)
      CreateConfig(U["bars"], T["Show Animation On Hidden Bars"], C.bars, "animalways", "checkbox")
      CreateConfig(U["bars"], T["Highlight Equipped Items"], C.bars, "showequipped", "checkbox")
      CreateConfig(U["bars"], T["Equipped Item Color"], C.bars, "eqcolor", "color")
      CreateConfig(U["bars"], T["Highlight Out Of Range Spells"], C.bars, "glowrange", "checkbox")
      CreateConfig(U["bars"], T["Out Of Range Color"], C.bars, "rangecolor", "color")
      CreateConfig(U["bars"], T["Highlight Out Of Mana Spells"], C.bars, "showoom", "checkbox")
      CreateConfig(U["bars"], T["Out Of Mana Color"], C.bars, "oomcolor", "color")
      CreateConfig(U["bars"], T["Highlight Not Usable Spells"], C.bars, "showna", "checkbox")
      CreateConfig(U["bars"], T["Not Usable Color"], C.bars, "nacolor", "color")
      CreateConfig(U["bars"], T["Lock Actionbars"], "UVAR", "LOCK_ACTIONBAR", "checkbox")
      CreateConfig(U["bars"], T["Always Allow Drag Via Shift Key"], C.bars, "shiftdrag", "checkbox")

      CreateConfig(nil, T["Font Options"], nil, nil, "header")
      CreateConfig(U["bars"], T["Font"], C.bars, "font", "dropdown", pfUI.gui.dropdowns.fonts)
      CreateConfig(U["bars"], T["Font Padding"], C.bars, "font_offset")
      CreateConfig(U["bars"], T["Macro Text Size"], C.bars, "macro_size")
      CreateConfig(U["bars"], T["Macro Text Color"], C.bars, "macro_color", "color")
      CreateConfig(U["bars"], T["Item Count Text Size"], C.bars, "count_size")
      CreateConfig(U["bars"], T["Item Count Text Color"], C.bars, "count_color", "color")
      CreateConfig(U["bars"], T["Keybind Text Size"], C.bars, "bind_size")
      CreateConfig(U["bars"], T["Keybind Text Color"], C.bars, "bind_color", "color")

      CreateConfig(nil, T["Auto Paging"], nil, nil, "header")
      CreateConfig(nil, T["Switch Pages On Meta Key Press"], C.bars, "pagemaster", "checkbox")
      CreateConfig(nil, T["Range Based Hunter Paging"], C.bars, "hunterbar", "checkbox")
    end)

    -- Shared Actionbar Settings
    local barnames = {
      -- default
      {1, T["Main Actionbar"]},
      {6, T["Top Actionbar"]},
      {5, T["Left Actionbar"]},
      {3, T["Right Actionbar"]},
      {4, T["Vertical Actionbar"]},

      -- special
      {2, T["Paging Actionbar"]},
      {7, T["Stance Bar 1"]},
      {8, T["Stance Bar 2"]},
      {9, T["Stance Bar 3"]},
      {10, T["Stance Bar 4"]},

      -- class
      {11, T["Shapeshift Bar"]},
      {12, T["Pet Actionbar"]},
    }

    for _, data in pairs(barnames) do
      local id, caption = data[1], data[2]
      local formfactors = function()
        return BarLayoutOptions(tonumber(C.bars["bar"..id].buttons) or id < 11 and NUM_ACTIONBAR_BUTTONS or id > 11 and NUM_SHAPESHIFT_SLOTS or NUM_PET_ACTION_SLOTS)
      end

      CreateGUIEntry(T["Actionbar"], caption, function()
        CreateConfig(U["bars"], T["Enable"], C.bars["bar"..id], "enable", "checkbox")

        if id ~= 11 and id ~= 12 then
          CreateConfig(U["bars"], T["Buttons"], C.bars["bar"..id], "buttons", "dropdown", pfUI.gui.dropdowns.actionbarbuttons)
          if id ~= 1 then
            CreateConfig(U["bars"], T["Pageable"], C.bars["bar"..id], "pageable", "checkbox")
          end
        end

        if id == 12 then
          CreateConfig(U["bars"], T["Auto-Castable Action Indicator"], C.bars, "showcastable", "checkbox")
        end

        CreateConfig(U["bars"], T["Icon Size"], C.bars["bar"..id], "icon_size")
        CreateConfig(U["bars"], T["Spacing"], C.bars["bar"..id], "spacing", "dropdown", pfUI.gui.dropdowns.actionbarbuttons)
        CreateConfig(U["bars"], T["Layout"], C.bars["bar"..id], "formfactor", "dropdown", formfactors)
        CreateConfig(U["bars"], T["Bar Background"], C.bars["bar"..id], "background", "checkbox")
        CreateConfig(U["bars"], T["Show Hotkey Text"], C.bars["bar"..id], "showkeybind", "checkbox")

        if id ~= 11 and id ~= 12 then
          CreateConfig(U["bars"], T["Show Macro Text"], C.bars["bar"..id], "showmacro", "checkbox")
          CreateConfig(U["bars"], T["Show Item Count Text"], C.bars["bar"..id], "showcount", "checkbox")
        end

        if id ~= 11 then
          CreateConfig(U["bars"], T["Show Empty Buttons"], C.bars["bar"..id], "showempty", "checkbox")
        end

        CreateConfig(U["bars"], T["Enable Autohide"], C.bars["bar"..id], "autohide", "checkbox")
        CreateConfig(U["bars"], T["Autohide Timeout"], C.bars["bar"..id], "hide_time")
      end)
    end

    CreateGUIEntry(T["Panel"], T["General"], function()
      CreateConfig(nil, T["Use Unit Fonts"], C.panel, "use_unitfonts", "checkbox")
      CreateConfig(nil, T["Left Panel: Left"], C.panel.left, "left", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(nil, T["Left Panel: Center"], C.panel.left, "center", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(nil, T["Left Panel: Right"], C.panel.left, "right", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(nil, T["Right Panel: Left"], C.panel.right, "left", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(nil, T["Right Panel: Center"], C.panel.right, "center", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(nil, T["Right Panel: Right"], C.panel.right, "right", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(nil, T["Other Panel: Minimap"], C.panel.other, "minimap", "dropdown", pfUI.gui.dropdowns.panel_values)
      CreateConfig(nil, T["Only Count Bagspace On Regular Bags"], C.panel.bag, "ignorespecial", "checkbox")
      CreateConfig(nil, T["Enable Micro Bar"], C.panel.micro, "enable", "checkbox")
      CreateConfig(nil, T["Enable 24h Clock"], C.global, "twentyfour", "checkbox")
      CreateConfig(nil, T["Servertime"], C.global, "servertime", "checkbox")

      CreateConfig(nil, T["Experience Bar"], nil, nil, "header")
      CreateConfig(nil, T["Always Show"], C.panel.xp, "xp_always", "checkbox")
      CreateConfig(nil, T["Hide Timeout"], C.panel.xp, "xp_timeout")
      CreateConfig(nil, T["Width"], C.panel.xp, "xp_width")
      CreateConfig(nil, T["Height"], C.panel.xp, "xp_height")
      CreateConfig(nil, T["Orientation"], C.panel.xp, "xp_mode", "dropdown", pfUI.gui.dropdowns.orientation)

      CreateConfig(nil, T["Reputation Bar"], nil, nil, "header")
      CreateConfig(nil, T["Always Show"], C.panel.xp, "rep_always", "checkbox")
      CreateConfig(nil, T["Hide Timeout"], C.panel.xp, "rep_timeout")
      CreateConfig(nil, T["Width"], C.panel.xp, "rep_width")
      CreateConfig(nil, T["Height"], C.panel.xp, "rep_height")
      CreateConfig(nil, T["Orientation"], C.panel.xp, "rep_mode", "dropdown", pfUI.gui.dropdowns.orientation)
    end)

    CreateGUIEntry(T["Panel"], T["Auto Hide"], function()
      CreateConfig(nil, T["Enable Autohide For Left Chat Panel"], C.panel, "hide_leftchat", "checkbox")
      CreateConfig(nil, T["Enable Autohide For Right Chat Panel"], C.panel, "hide_rightchat", "checkbox")
      CreateConfig(nil, T["Enable Autohide For Minimap Panel"], C.panel, "hide_minimap", "checkbox")
      CreateConfig(nil, T["Enable Autohide For Microbar Panel"], C.panel, "hide_microbar", "checkbox")
    end)

    CreateGUIEntry(T["Tooltip"], nil, function()
      CreateConfig(nil, T["Tooltip Position"], C.tooltip, "position", "dropdown", pfUI.gui.dropdowns.tooltip_position)
      CreateConfig(nil, T["Cursor Tooltip Align"], C.tooltip, "cursoralign", "dropdown", pfUI.gui.dropdowns.tooltip_align)
      CreateConfig(nil, T["Cursor Tooltip Offset"], C.tooltip, "cursoroffset")
      CreateConfig(nil, T["Enable Extended Guild Information"], C.tooltip, "extguild", "checkbox")
      CreateConfig(nil, T["Custom Transparency"], C.tooltip, "alpha")
      CreateConfig(nil, T["Compare Item Base Stats"], C.tooltip.compare, "basestats", "checkbox")
      CreateConfig(nil, T["Always Show Item Comparison"], C.tooltip.compare, "showalways", "checkbox")
      CreateConfig(nil, T["Always Show Extended Vendor Values"], C.tooltip.vendor, "showalways", "checkbox")
    end)

    CreateGUIEntry(T["Castbar"], nil, function()
      CreateConfig(nil, T["Use Unit Fonts"], C.castbar, "use_unitfonts", "checkbox")
      CreateConfig(nil, T["Casting Color"], C.appearance.castbar, "castbarcolor", "color")
      CreateConfig(nil, T["Channeling Color"], C.appearance.castbar, "channelcolor", "color")
      CreateConfig(nil, T["Castbar Texture"], C.appearance.castbar, "texture", "dropdown", pfUI.gui.dropdowns.uf_bartexture)
      CreateConfig(nil, T["Disable Blizzard Castbar"], C.castbar.player, "hide_blizz", "checkbox")

      CreateConfig(nil, T["Player Castbar"], nil, nil, "header")
      CreateConfig(nil, T["Show Spell Icon"], C.castbar.player, "showicon", "checkbox")
      CreateConfig(nil, T["Show Lag"], C.castbar.player, "showlag", "checkbox")
      CreateConfig(nil, T["Castbar Width"], C.castbar.player, "width")
      CreateConfig(nil, T["Castbar Height"], C.castbar.player, "height")
      CreateConfig(nil, T["Disable Player Castbar"], C.castbar.player, "hide_pfui", "checkbox")

      CreateConfig(nil, T["Target Castbar"], nil, nil, "header")
      CreateConfig(nil, T["Show Spell Icon"], C.castbar.target, "showicon", "checkbox")
      CreateConfig(nil, T["Show Lag"], C.castbar.target, "showlag", "checkbox")
      CreateConfig(nil, T["Castbar Width"], C.castbar.target, "width")
      CreateConfig(nil, T["Castbar Height"], C.castbar.target, "height")
      CreateConfig(nil, T["Disable Target Castbar"], C.castbar.target, "hide_pfui", "checkbox")

      CreateConfig(nil, T["Focus Castbar"], nil, nil, "header")
      CreateConfig(nil, T["Show Spell Icon"], C.castbar.focus, "showicon", "checkbox")
      CreateConfig(nil, T["Show Lag"], C.castbar.focus, "showlag", "checkbox")
      CreateConfig(nil, T["Castbar Width"], C.castbar.focus, "width")
      CreateConfig(nil, T["Castbar Height"], C.castbar.focus, "height")
      CreateConfig(nil, T["Disable Focus Castbar"], C.castbar.focus, "hide_pfui", "checkbox")
    end)

    CreateGUIEntry(T["Chat"], nil, function()
      CreateConfig(nil, T["Enable \"Loot & Spam\" Chat Window"], C.chat.right, "enable", "checkbox")
      CreateConfig(nil, T["Inputbox Width"], C.chat.text, "input_width")
      CreateConfig(nil, T["Inputbox Height"], C.chat.text, "input_height")
      CreateConfig(nil, T["Enable Text Shadow"], C.chat.text, "outline", "checkbox")
      CreateConfig(nil, T["Show Items On Mouseover"], C.chat.text, "mouseover", "checkbox")
      CreateConfig(nil, T["Chat Default Brackets"], C.chat.text, "bracket", nil, nil, nil, nil, "STRING")
      CreateConfig(nil, T["Enable Timestamps"], C.chat.text, "time", "checkbox")
      CreateConfig(nil, T["Timestamp Format"], C.chat.text, "timeformat", nil, nil, nil, nil, "STRING")
      CreateConfig(nil, T["Timestamp Brackets"], C.chat.text, "timebracket", nil, nil, nil, nil, "STRING")
      CreateConfig(nil, T["Timestamp Color"], C.chat.text, "timecolor", "color")
      CreateConfig(nil, T["Hide Channel Names"], C.chat.text, "channelnumonly", "checkbox")
      CreateConfig(nil, T["Generate Playerlinks"], C.chat.text, "playerlinks", "checkbox")
      CreateConfig(nil, T["Enable URL Detection"], C.chat.text, "detecturl", "checkbox")
      CreateConfig(nil, T["Enable Class Colors"], C.chat.text, "classcolor", "checkbox")
      CreateConfig(nil, T["Colorize Unknown Classes"], C.chat.text, "tintunknown", "checkbox")
      CreateConfig(nil, T["Unknown Class Color"], C.chat.text, "unknowncolor", "color")
      CreateConfig(nil, T["Left Chat Width"], C.chat.left, "width")
      CreateConfig(nil, T["Left Chat Height"], C.chat.left, "height")
      CreateConfig(nil, T["Right Chat Width"], C.chat.right, "width")
      CreateConfig(nil, T["Right Chat Height"], C.chat.right, "height")
      CreateConfig(nil, T["Enable Right Chat Window"], C.chat.right, "alwaysshow", "checkbox")
      CreateConfig(nil, T["Hide Combat Log"], C.chat.global, "combathide", "checkbox")
      CreateConfig(nil, T["Enable Chat Dock Background"], C.chat.global, "tabdock", "checkbox")
      CreateConfig(nil, T["Only Show Chat Dock On Mouseover"], C.chat.global, "tabmouse", "checkbox")
      CreateConfig(nil, T["Enable Chat Tab Flashing"], C.chat.global, "chatflash", "checkbox")
      CreateConfig(nil, T["Enable Custom Colors"], C.chat.global, "custombg", "checkbox")
      CreateConfig(nil, T["Chat Background Color"], C.chat.global, "background", "color")
      CreateConfig(nil, T["Chat Border Color"], C.chat.global, "border", "color")
      CreateConfig(nil, T["Enable Custom Incoming Whispers Layout"], C.chat.global, "whispermod", "checkbox")
      CreateConfig(nil, T["Incoming Whispers Color"], C.chat.global, "whisper", "color")
      CreateConfig(nil, T["Enable Sticky Chat"], C.chat.global, "sticky", "checkbox")
      CreateConfig(nil, T["Enable Chat Fade"], C.chat.global, "fadeout", "checkbox")
      CreateConfig(nil, T["Seconds Before Chat Fade"], C.chat.global, "fadetime")
      CreateConfig(nil, T["Mousewheel Scroll Speed"], C.chat.global, "scrollspeed")
      CreateConfig(nil, T["Enable Chat Bubbles"], "CVAR", "chatBubbles", "checkbox")
      CreateConfig(nil, T["Enable Party Chat Bubbles"], "CVAR", "chatBubblesParty", "checkbox")
      CreateConfig(nil, T["Chat Bubble Transparency"], C.chat.bubbles, "alpha")
    end)

    CreateGUIEntry(T["Nameplates"], nil, function()
      CreateConfig(nil, T["Use Unit Fonts"], C.nameplates, "use_unitfonts", "checkbox")
      CreateConfig(nil, T["Enable Castbars"], C.nameplates, "showcastbar", "checkbox")
      CreateConfig(nil, T["Enable Spellname"], C.nameplates, "spellname", "checkbox")
      CreateConfig(nil, T["Enable Debuffs"], C.nameplates, "showdebuffs", "checkbox")
      CreateConfig(nil, T["Enable Clickthrough"], C.nameplates, "clickthrough", "checkbox")
      CreateConfig(nil, T["Legacy Click Handlers (Breaks Vertical Position and Overlap)"], C.nameplates, "legacy", "checkbox")
      CreateConfig(nil, T["Enable Overlap"], C.nameplates, "overlap", "checkbox")
      CreateConfig(nil, T["Enable Mouselook With Right Click"], C.nameplates, "rightclick", "checkbox")
      CreateConfig(nil, T["Right Click Auto Attack Threshold"], C.nameplates, "clickthreshold")
      CreateConfig(nil, T["Enable Class Colors On Enemies"], C.nameplates, "enemyclassc", "checkbox")
      CreateConfig(nil, T["Enable Class Colors On Friends"], C.nameplates, "friendclassc", "checkbox")
      CreateConfig(nil, T["Raid Icon Size"], C.nameplates, "raidiconsize")
      CreateConfig(nil, T["Show Players Only"], C.nameplates, "players", "checkbox")
      CreateConfig(nil, T["Hide Critters"], C.nameplates, "critters", "checkbox")
      CreateConfig(nil, T["Hide Totems"], C.nameplates, "totems", "checkbox")
      CreateConfig(nil, T["Show Health Points"], C.nameplates, "showhp", "checkbox")
      CreateConfig(nil, T["Vertical Position"], C.nameplates, "vpos")
      CreateConfig(nil, T["Nameplate Width"], C.nameplates, "width")
      CreateConfig(nil, T["Healthbar Height"], C.nameplates, "heighthealth")
      CreateConfig(nil, T["Castbar Height"], C.nameplates, "heightcast")
      CreateConfig(nil, T["Enable Combo Point Display"], C.nameplates, "cpdisplay", "checkbox")
      CreateConfig(nil, T["Highlight Target Nameplate"], C.nameplates, "targethighlight", "checkbox")
      CreateConfig(nil, T["Draw Glow Around Target Nameplate"], C.nameplates, "targetglow", "checkbox")
      CreateConfig(nil, T["Glow Color Around Target Nameplate"], C.nameplates, "glowcolor", "color")
      CreateConfig(nil, T["Zoom Target Nameplate"], C.nameplates, "targetzoom", "checkbox")
      CreateConfig(nil, T["Inactive Nameplate Alpha"], C.nameplates, "notargalpha")
      CreateConfig(nil, T["Healthbar Texture"], C.nameplates, "healthtexture", "dropdown", pfUI.gui.dropdowns.uf_bartexture)

    end)

    CreateGUIEntry(T["Thirdparty"], T["Integrations"], function()
      CreateConfig(nil, T["Show Meters By Default"], C.thirdparty, "showmeter", "checkbox")
      CreateConfig(nil, T["Use Chat Colors for Meters"], C.thirdparty, "chatbg", "checkbox")
      CreateConfig(nil, "DPSMate (" .. T["Skin"] .. ")", C.thirdparty.dpsmate, "skin", "checkbox")
      CreateConfig(nil, "DPSMate (" .. T["Dock"] .. ")", C.thirdparty.dpsmate, "dock", "checkbox")
      CreateConfig(nil, "SWStats (" .. T["Skin"] .. ")", C.thirdparty.swstats, "skin", "checkbox")
      CreateConfig(nil, "SWStats (" .. T["Dock"] .. ")", C.thirdparty.swstats, "dock", "checkbox")
      CreateConfig(nil, "KLH Threat Meter (" .. T["Skin"] .. ")", C.thirdparty.ktm, "skin", "checkbox")
      CreateConfig(nil, "KLH Threat Meter (" .. T["Dock"] .. ")", C.thirdparty.ktm, "dock", "checkbox")
      CreateConfig(nil, "WIM", C.thirdparty.wim, "enable", "checkbox")
      CreateConfig(nil, "HealComm", C.thirdparty.healcomm, "enable", "checkbox")
      CreateConfig(nil, "SortBags", C.thirdparty.sortbags, "enable", "checkbox")
      CreateConfig(nil, "MrPlow", C.thirdparty.mrplow, "enable", "checkbox")
      CreateConfig(nil, "FlightMap", C.thirdparty.flightmap, "enable", "checkbox")
      CreateConfig(nil, "TheoryCraft", C.thirdparty.theorycraft, "enable", "checkbox")
      CreateConfig(nil, "SuperMacro", C.thirdparty.supermacro, "enable", "checkbox")
      CreateConfig(nil, "AtlasLoot", C.thirdparty.atlasloot, "enable", "checkbox")
      CreateConfig(nil, "MyRolePlay", C.thirdparty.myroleplay, "enable", "checkbox")
      CreateConfig(nil, "DruidManaBar", C.thirdparty.druidmana, "enable", "checkbox")
      CreateConfig(nil, "NoteIt", C.thirdparty.noteit, "enable", "checkbox")
    end)

    CreateGUIEntry(T["Components"], T["Modules"], function()
      table.sort(pfUI.modules)
      for i,m in pairs(pfUI.modules) do
        if m ~= "gui" then
          -- create disabled entry if not existing and display
          pfUI:UpdateConfig("disabled", nil, m, "0")
          CreateConfig(nil, T["Disable Module"] .. " " .. m, C.disabled, m, "checkbox")
        end
      end
    end)

    CreateGUIEntry(T["Components"], T["Skins"], function()
      table.sort(pfUI.skins)
      for i,m in pairs(pfUI.skins) do
        -- create disabled entry if not existing and display
        pfUI:UpdateConfig("disabled", nil, "skin_" .. m, "0")
        CreateConfig(nil, T["Disable Skin"] .. " " .. m, C.disabled, "skin_" .. m, "checkbox")
      end
    end)
  end
end)
