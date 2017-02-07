pfUI:RegisterModule("gui", function ()
  local default_border = tonumber(pfUI_config.appearance.border.default)

  pfUI.gui = CreateFrame("Frame",nil,UIParent)

  pfUI.gui:RegisterEvent("PLAYER_ENTERING_WORLD")

  pfUI.gui:SetFrameStrata("DIALOG")
  pfUI.gui:SetWidth(500)
  pfUI.gui:SetHeight(500)
  pfUI.gui:Hide()

  pfUI.api:CreateBackdrop(pfUI.gui, nil, nil, .8)
  pfUI.gui:SetPoint("CENTER",0,0)
  pfUI.gui:SetMovable(true)
  pfUI.gui:EnableMouse(true)
  pfUI.gui:SetScript("OnMouseDown",function()
    pfUI.gui:StartMoving()
  end)

  pfUI.gui:SetScript("OnMouseUp",function()
    pfUI.gui:StopMovingOrSizing()
  end)

  pfUI.gui:SetScript("OnHide",function()
    if ColorPickerFrame and ColorPickerFrame:IsShown() then
      ColorPickerFrame:Hide()
    end
  end)

  function pfUI.gui:Reload()
    pfUI.api:CreateQuestionDialog("Some settings need to reload the UI to take effect.\nDo you want to reloadUI now?",
      function()
        pfUI.gui.settingChanged = nil
        ReloadUI()
      end)
  end

  function pfUI.gui:SaveScale(frame, scale)
    frame:SetScale(scale)

    if not pfUI_config.position[frame:GetName()] then
      pfUI_config.position[frame:GetName()] = {}
    end
    pfUI_config.position[frame:GetName()]["scale"] = scale

    frame.drag.text:SetText("Scale: " .. scale)
    frame.drag.text:SetAlpha(1)

    frame.drag:SetScript("OnUpdate", function()
      this.text:SetAlpha(this.text:GetAlpha() -0.05)
      if this.text:GetAlpha() < 0.1 then
        this.text:SetText(strsub(this:GetParent():GetName(),3))
        this.text:SetAlpha(1)
        this:SetScript("OnUpdate", function() return end)
      end
    end)
  end

  function pfUI.gui.HoverBind()
    pfUI.gui:Hide()
    if pfUI.hoverbind then
      pfUI.hoverbind:Show()
    end
  end

  function pfUI.gui.UnlockFrames()
    if not pfUI.gitter then
      pfUI.gitter = CreateFrame("Button", nil, UIParent)
      pfUI.gitter:SetAllPoints(WorldFrame)
      pfUI.gitter:SetFrameStrata("BACKGROUND")
      pfUI.gitter:SetScript("OnClick", function()
        pfUI.gui.UnlockFrames()
      end)

      local size = 1
      local width = GetScreenWidth()
      local ratio = width / GetScreenHeight()
      local height = GetScreenHeight() * ratio

      local wStep = width / 128
      local hStep = height / 128

      for i = 0, 128 do
        local tx = pfUI.gitter:CreateTexture(nil, 'BACKGROUND')
        if i == 128 / 2 then
          tx:SetTexture(.1, .5, .4)
        else
          tx:SetTexture(0, 0, 0)
        end
        tx:SetPoint("TOPLEFT", pfUI.gitter, "TOPLEFT", i*wStep - (size/2), 0)
        tx:SetPoint('BOTTOMRIGHT', pfUI.gitter, 'BOTTOMLEFT', i*wStep + (size/2), 0)
      end

      local height = GetScreenHeight()

      for i = 0, 128 do
        local tx = pfUI.gitter:CreateTexture(nil, 'BACKGROUND')
        tx:SetTexture(.1, .5, .4)
        tx:SetPoint("TOPLEFT", pfUI.gitter, "TOPLEFT", 0, -(height/2) + (size/2))
        tx:SetPoint('BOTTOMRIGHT', pfUI.gitter, 'TOPRIGHT', 0, -(height/2 + size/2))
      end

      for i = 1, floor((height/2)/hStep) do
        local tx = pfUI.gitter:CreateTexture(nil, 'BACKGROUND')
        tx:SetTexture(0, 0, 0)

        tx:SetPoint("TOPLEFT", pfUI.gitter, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
        tx:SetPoint('BOTTOMRIGHT', pfUI.gitter, 'TOPRIGHT', 0, -(height/2+i*hStep + size/2))

        tx = pfUI.gitter:CreateTexture(nil, 'BACKGROUND')
        tx:SetTexture(0, 0, 0)

        tx:SetPoint("TOPLEFT", pfUI.gitter, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
        tx:SetPoint('BOTTOMRIGHT', pfUI.gitter, 'TOPRIGHT', 0, -(height/2-i*hStep + size/2))
      end

      pfUI.gitter:Hide()
    end

    pfUI.info:ShowInfoBox("|cff33ffccUnlock Mode|r\n" ..
      "This mode allows you to move frames by dragging them using the mouse cursor. " ..
      "Frames can be scaled by scrolling up and down.\nTo scale multiple frames at once (eg. raidframes), " ..
      "hold down the shift key while scrolling. Click into an empty space to go back to the pfUI menu.", 15, pfUI.gitter)

    if pfUI.gitter:IsShown() then
      pfUI.gitter:Hide()
      pfUI.gui:Show()
    else
      pfUI.gitter:Show()
      pfUI.gui:Hide()
    end

    for _,frame in pairs(pfUI.movables) do
      local frame = getglobal(frame)

      if frame then
        if not frame:IsShown() then
          frame.hideLater = true
        end

        if not frame.drag then
          frame.drag = CreateFrame("Frame", nil, frame)
          frame.drag:SetAllPoints(frame)
          frame.drag:SetFrameStrata("DIALOG")
          pfUI.api:CreateBackdrop(frame.drag, nil, nil, .8)
          frame.drag.backdrop:SetBackdropBorderColor(.2, 1, .8)
          frame.drag:EnableMouseWheel(1)
          frame.drag.text = frame.drag:CreateFontString("Status", "LOW", "GameFontNormal")
          frame.drag.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, STANDARD_TEXT_FONT_FLAGS)
          frame.drag.text:ClearAllPoints()
          frame.drag.text:SetAllPoints(frame.drag)
          frame.drag.text:SetPoint("CENTER", 0, 0)
          frame.drag.text:SetFontObject(GameFontWhite)
          local label = (strsub(frame:GetName(),3))
          if frame.drag:GetHeight() > (2 * frame.drag:GetWidth()) then
            label = pfUI.api.strvertical(label)
          end
          frame.drag.text:SetText(label)
          frame.drag:SetAlpha(1)

          frame.drag:SetScript("OnMouseWheel", function()
            local scale = pfUI.api.round(frame:GetScale() + arg1/10, 1)

            if IsShiftKeyDown() and strsub(frame:GetName(),0,6) == "pfRaid" then
              for i=1,40 do
                local frame = getglobal("pfRaid" .. i)
                pfUI.gui:SaveScale(frame, scale)
              end
            elseif IsShiftKeyDown() and strsub(frame:GetName(),0,7) == "pfGroup" then
              for i=1,4 do
                local frame = getglobal("pfGroup" .. i)
                pfUI.gui:SaveScale(frame, scale)
              end
            elseif IsShiftKeyDown() and strsub(frame:GetName(),0,15) == "pfLootRollFrame" then
              for i=1,4 do
                local frame = getglobal("pfLootRollFrame" .. i)
                pfUI.gui:SaveScale(frame, scale)
              end
            else
              pfUI.gui:SaveScale(frame, scale)
            end

            -- repaint hackfix for panels
            if pfUI.panel and pfUI.chat then
              pfUI.panel.left:SetScale(pfUI.chat.left:GetScale())
              pfUI.panel.right:SetScale(pfUI.chat.right:GetScale())
            end

            if frame.OnMove then frame:OnMove() end
          end)
        end

        frame.drag:SetScript("OnMouseDown",function()
          if IsShiftKeyDown() then
            if strsub(frame:GetName(),0,6) == "pfRaid" then
              for i=1,40 do
                local cframe = getglobal("pfRaid" .. i)
                cframe:StartMoving()
                cframe:StopMovingOrSizing()
                cframe.drag.backdrop:SetBackdropBorderColor(1,1,1,1)
              end
            end
            if strsub(frame:GetName(),0,7) == "pfGroup" then
              for i=1,4 do
                local cframe = getglobal("pfGroup" .. i)
                cframe:StartMoving()
                cframe:StopMovingOrSizing()
                cframe.drag.backdrop:SetBackdropBorderColor(1,1,1,1)
              end
            end
            if strsub(frame:GetName(),0,15) == "pfLootRollFrame" then
              for i=1,4 do
                local cframe = getglobal("pfLootRollFrame" .. i)
                cframe:StartMoving()
                cframe:StopMovingOrSizing()
                cframe.drag.backdrop:SetBackdropBorderColor(1,1,1,1)
              end
            end
            _, _, _, xpos, ypos = frame:GetPoint()
            frame.oldPos = { xpos, ypos }
          else
            frame.oldPos = nil
          end
          frame.drag.backdrop:SetBackdropBorderColor(1,1,1,1)
          frame:StartMoving()
          if frame.OnMove then frame:OnMove() end
        end)

        frame.drag:SetScript("OnMouseUp",function()
            frame:StopMovingOrSizing()
            _, _, _, xpos, ypos = frame:GetPoint()
            frame.drag.backdrop:SetBackdropBorderColor(.2,1,.8,1)

            if frame.oldPos then
              local diffxpos = frame.oldPos[1] - xpos
              local diffypos = frame.oldPos[2] - ypos

              if strsub(frame:GetName(),0,6) == "pfRaid" then
                for i=1,40 do
                  local cframe = getglobal("pfRaid" .. i)
                  cframe.drag.backdrop:SetBackdropBorderColor(.2,1,.8,1)
                  if cframe:GetName() ~= frame:GetName() then
                    local _, _, _, xpos, ypos = cframe:GetPoint()
                    cframe:SetPoint("TOPLEFT", xpos - diffxpos, ypos - diffypos)

                    local _, _, _, xpos, ypos = cframe:GetPoint()

                    if not pfUI_config.position[cframe:GetName()] then
                      pfUI_config.position[cframe:GetName()] = {}
                    end

                    pfUI_config.position[cframe:GetName()]["xpos"] = xpos
                    pfUI_config.position[cframe:GetName()]["ypos"] = ypos
                  end
                end
              elseif strsub(frame:GetName(),0,7) == "pfGroup" then
                for i=1,4 do
                  local cframe = getglobal("pfGroup" .. i)
                  cframe.drag.backdrop:SetBackdropBorderColor(.2,1,.8,1)
                  if cframe:GetName() ~= frame:GetName() then
                    local _, _, _, xpos, ypos = cframe:GetPoint()
                    cframe:SetPoint("TOPLEFT", xpos - diffxpos, ypos - diffypos)

                    local _, _, _, xpos, ypos = cframe:GetPoint()

                    if not pfUI_config.position[cframe:GetName()] then
                      pfUI_config.position[cframe:GetName()] = {}
                    end

                    pfUI_config.position[cframe:GetName()]["xpos"] = xpos
                    pfUI_config.position[cframe:GetName()]["ypos"] = ypos
                  end
                end
              elseif strsub(frame:GetName(),0,15) == "pfLootRollFrame" then
                for i=1,4 do
                  local cframe = getglobal("pfLootRollFrame" .. i)
                  cframe.drag.backdrop:SetBackdropBorderColor(.2,1,.8,1)
                  if cframe:GetName() ~= frame:GetName() then
                    local _, _, _, xpos, ypos = cframe:GetPoint()
                    cframe:SetPoint("TOPLEFT", xpos - diffxpos, ypos - diffypos)

                    local _, _, _, xpos, ypos = cframe:GetPoint()

                    if not pfUI_config.position[cframe:GetName()] then
                      pfUI_config.position[cframe:GetName()] = {}
                    end

                    pfUI_config.position[cframe:GetName()]["xpos"] = xpos
                    pfUI_config.position[cframe:GetName()]["ypos"] = ypos
                  end
                end
              end
            end

            if not pfUI_config.position[frame:GetName()] then
              pfUI_config.position[frame:GetName()] = {}
            end

            pfUI_config.position[frame:GetName()]["xpos"] = xpos
            pfUI_config.position[frame:GetName()]["ypos"] = ypos
            pfUI.gui.settingChanged = true
        end)

        if pfUI.gitter:IsShown() then
          frame:SetMovable(true)
          frame.drag:EnableMouse(true)
          frame.drag:Show()
          frame:Show()
        else
          frame:SetMovable(false)
          frame.drag:EnableMouse(false)
          frame.drag:Hide()
          if frame.hideLater == true then
            frame:Hide()
          end
        end
      end
    end
  end

  function pfUI.gui:SwitchTab(frame)
    local elements = {
      pfUI.gui.global, pfUI.gui.appearance, pfUI.gui.modules, pfUI.gui.uf,
      pfUI.gui.bar, pfUI.gui.panel, pfUI.gui.tooltip, pfUI.gui.castbar,
      pfUI.gui.thirdparty, pfUI.gui.chat, pfUI.gui.nameplates,
    }

    for _, hide in pairs(elements) do
      hide:Hide()
      pfUI.api:CreateBackdrop(hide.switch, nil, true)
    end
    pfUI.gui.scroll:SetScrollChild(frame)
    pfUI.gui.scroll:UpdateScrollState()
    pfUI.gui.scroll:SetVerticalScroll(0)
    pfUI.api:CreateBackdrop(frame.switch, nil, true)
    frame.switch:SetBackdropBorderColor(.2,1,.8)
    frame:Show()
  end

  function pfUI.gui:CreateConfigTab(text, bottom, func)
    -- automatically place buttons
    if not bottom then
      if not pfUI.gui.tabTop then
        pfUI.gui.tabTop = 0
      else
        pfUI.gui.tabTop = pfUI.gui.tabTop + 1
      end
    else
      if not pfUI.gui.tabBottom then
        pfUI.gui.tabBottom = 0
      else
        pfUI.gui.tabBottom = pfUI.gui.tabBottom + 1
      end
    end

    local frame = CreateFrame("Frame", nil, pfUI.gui)
    frame:SetWidth(pfUI.gui:GetWidth() - 3*default_border - 100)
    frame:SetHeight(100)

    frame.switch = CreateFrame("Button", nil, pfUI.gui)
    frame.switch:ClearAllPoints()
    frame.switch:SetWidth(100)
    frame.switch:SetHeight(22)

    if bottom then
      frame.switch:SetPoint("BOTTOMLEFT", default_border, pfUI.gui.tabBottom * (22 + default_border) + default_border)
    else
      frame.switch:SetPoint("TOPLEFT", default_border, -pfUI.gui.tabTop* (22 + default_border) -default_border)
    end
    pfUI.api:CreateBackdrop(frame.switch, nil, true)
    frame.switch.text = frame.switch:CreateFontString("Status", "LOW", "GameFontNormal")
    frame.switch.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, STANDARD_TEXT_FONT_FLAGS)
    frame.switch.text:SetAllPoints(frame.switch)
    frame.switch.text:SetPoint("CENTER", 0, 0)
    frame.switch.text:SetFontObject(GameFontWhite)
    frame.switch.text:SetText(text)

    -- replace by user defined function
    if not func then
      frame.switch:SetScript("OnClick", function() pfUI.gui:SwitchTab(frame) end)
    else
      frame.switch:SetScript("OnClick", func)
    end

    -- do not show title on bottom buttons
    if not bottom and not func then
      frame.title = frame:CreateFontString("Status", "LOW", "GameFontNormal")
      frame.title:SetFont(pfUI.font_default, pfUI_config.global.font_size + 2, STANDARD_TEXT_FONT_FLAGS)
      frame.title:SetPoint("TOP", 0, -10)
      frame.title:SetTextColor(.2,1,.8)
      frame.title:SetText(text)
    end

    return frame
  end

  function pfUI.gui:CreateConfig(parent, caption, category, config, widget, values, skip, named)
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

    -- basic frame
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(350)
    frame:SetHeight(25)
    frame:SetPoint("TOPLEFT", 25, parent.objectCount * -25)

    if not widget or (widget and widget ~= "button") then

      frame:SetBackdrop(pfUI.backdrop_underline)
      frame:SetBackdropBorderColor(1,1,1,.25)

      -- caption
      frame.caption = frame:CreateFontString("Status", "LOW", "GameFontNormal")
      frame.caption:SetFont(pfUI.font_default, pfUI_config.global.font_size + 2, STANDARD_TEXT_FONT_FLAGS)
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
      frame.color:SetWidth(12)
      frame.color:SetHeight(12)
      pfUI.api:CreateBackdrop(frame.color)
      frame.color:SetPoint("TOPRIGHT" , 0, -4)
      frame.color.prev = frame.color.backdrop:CreateTexture("OVERLAY")
      frame.color.prev:SetAllPoints(frame.color)

      local cr, cg, cb, ca = pfUI.api.strsplit(",", category[config])
      if not cr or not cg or not cb or not ca then
        cr, cg, cb, ca = 1, 1, 1, 1
      end
      frame.color.prev:SetTexture(cr,cg,cb,ca)

      frame.color:SetScript("OnClick", function()
        local cr, cg, cb, ca = pfUI.api.strsplit(",", category[config])
        if not cr or not cg or not cb or not ca then
          cr, cg, cb, ca = 1, 1, 1, 1
        end
        local preview = this.prev

        function ColorPickerFrame.func()
          local r,g,b = ColorPickerFrame:GetColorRGB()
          local a = 1 - OpacitySliderFrame:GetValue()

          r = pfUI.api.round(r, 1)
          g = pfUI.api.round(g, 1)
          b = pfUI.api.round(b, 1)
          a = pfUI.api.round(a, 1)

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
      pfUI.api:CreateBackdrop(frame, nil, true)
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
      frame.input:SetHeight(20)
      frame.input:SetPoint("TOPRIGHT" , 0, 0)
      frame.input:SetFontObject(GameFontNormal)
      frame.input:SetAutoFocus(false)
      frame.input:SetText(category[config])
      frame.input:SetScript("OnEscapePressed", function(self)
        this:ClearFocus()
      end)

      frame.input:SetScript("OnTextChanged", function(self)
        this:GetParent().category[this:GetParent().config] = this:GetText()
      end)

      frame.input:SetScript("OnEditFocusGained", function(self)
        pfUI.gui.settingChanged = true
      end)
    end

    -- use button widget
    if widget == "button" then
      frame.button = CreateFrame("Button", "pfButton", frame, "UIPanelButtonTemplate")
      pfUI.api:CreateBackdrop(frame.button, nil, true)
      pfUI.api:SkinButton(frame.button)
      frame.button:SetWidth(85)
      frame.button:SetHeight(20)
      frame.button:SetPoint("TOPRIGHT", -(parent.lineCount-1) * 90, -5)
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
      pfUI.api:CreateBackdrop(frame.input, nil, true)
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
        if v.SetBackdrop then pfUI.api:CreateBackdrop(v) end
      end
    end

    return frame
  end

  -- [[ config section ]] --
  pfUI.gui.deco = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.deco:ClearAllPoints()
  pfUI.gui.deco:SetPoint("TOPLEFT", pfUI.gui, "TOPLEFT", 4*default_border + 100,-2*default_border)
  pfUI.gui.deco:SetPoint("BOTTOMRIGHT", pfUI.gui, "BOTTOMRIGHT", -2*default_border,2*default_border)
  pfUI.api:CreateBackdrop(pfUI.gui.deco, nil, nil, .8)

  pfUI.gui.deco.up = CreateFrame("Frame", nil, pfUI.gui.deco)
  pfUI.gui.deco.up:SetPoint("TOPLEFT", pfUI.gui.deco, "TOPLEFT", 0,0)
  pfUI.gui.deco.up:SetPoint("TOPRIGHT", pfUI.gui.deco, "TOPRIGHT", 0,0)
  pfUI.gui.deco.up:SetHeight(16)
  pfUI.gui.deco.up:SetAlpha(0)
  pfUI.gui.deco.up.visible = 0
  pfUI.gui.deco.up.texture = pfUI.gui.deco.up:CreateTexture()
  pfUI.gui.deco.up.texture:SetAllPoints()
  pfUI.gui.deco.up.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\gradient_up")
  pfUI.gui.deco.up.texture:SetVertexColor(.2,1,.8)
  pfUI.gui.deco.up:SetScript("OnUpdate", function()
    pfUI.gui.scroll:UpdateScrollState()
    if pfUI.gui.deco.up.visible == 0 and pfUI.gui.deco.up:GetAlpha() > 0 then
      pfUI.gui.deco.up:SetAlpha(pfUI.gui.deco.up:GetAlpha() - 0.01)
    elseif pfUI.gui.deco.up.visible == 0 and pfUI.gui.deco.up:GetAlpha() <= 0 then
      pfUI.gui.deco.up:Hide()
    end
  end)

  pfUI.gui.deco.down = CreateFrame("Frame", nil, pfUI.gui.deco)
  pfUI.gui.deco.down:SetPoint("BOTTOMLEFT", pfUI.gui.deco, "BOTTOMLEFT", 0,0)
  pfUI.gui.deco.down:SetPoint("BOTTOMRIGHT", pfUI.gui.deco, "BOTTOMRIGHT", 0,0)
  pfUI.gui.deco.down:SetHeight(16)
  pfUI.gui.deco.down:SetAlpha(0)
  pfUI.gui.deco.down.visible = 0
  pfUI.gui.deco.down.texture = pfUI.gui.deco.down:CreateTexture()
  pfUI.gui.deco.down.texture:SetAllPoints()
  pfUI.gui.deco.down.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\gradient_down")
  pfUI.gui.deco.down.texture:SetVertexColor(.2,1,.8)
  pfUI.gui.deco.down:SetScript("OnUpdate", function()
    pfUI.gui.scroll:UpdateScrollState()
    if pfUI.gui.deco.down.visible == 0 and pfUI.gui.deco.down:GetAlpha() > 0 then
      pfUI.gui.deco.down:SetAlpha(pfUI.gui.deco.down:GetAlpha() - 0.01)
    elseif pfUI.gui.deco.down.visible == 0 and pfUI.gui.deco.down:GetAlpha() <= 0 then
      pfUI.gui.deco.down:Hide()
    end
  end)

  pfUI.gui.scroll = CreateFrame("ScrollFrame", nil, pfUI.gui)
  pfUI.gui.scroll:ClearAllPoints()
  pfUI.gui.scroll:SetPoint("TOPLEFT", pfUI.gui, "TOPLEFT", 2*default_border + 100,-10)
  pfUI.gui.scroll:SetPoint("BOTTOMRIGHT", pfUI.gui, "BOTTOMRIGHT", -default_border,10)
  pfUI.gui.scroll:EnableMouseWheel(1)
  function pfUI.gui.scroll:UpdateScrollState()
    local current = ceil(pfUI.gui.scroll:GetVerticalScroll())
    local max = ceil(pfUI.gui.scroll:GetVerticalScrollRange() + 10)
    pfUI.gui.deco.up:Show()
    pfUI.gui.deco.down:Show()
    if max > 20 then
      if current < max then
        pfUI.gui.deco.down.visible = 1
        pfUI.gui.deco.down:Show()
        pfUI.gui.deco.down:SetAlpha(.2)
      end
      if current > 5 then
          pfUI.gui.deco.up.visible = 1
          pfUI.gui.deco.up:Show()
          pfUI.gui.deco.up:SetAlpha(.2)
      end
      if current > max - 5 then
        pfUI.gui.deco.down.visible = 0
      end
      if current < 5 then
        pfUI.gui.deco.up.visible = 0
      end
    else
      pfUI.gui.deco.up.visible = 0
      pfUI.gui.deco.down.visible = 0
    end
  end

  pfUI.gui.scroll:SetScript("OnMouseWheel", function()
    local current = pfUI.gui.scroll:GetVerticalScroll()
    local new = current + arg1*-25
    local max = pfUI.gui.scroll:GetVerticalScrollRange() + 25
    if max > 31 then
      if new < 0 then
          pfUI.gui.scroll:SetVerticalScroll(0)
          pfUI.gui.deco.up:SetAlpha(.3)
      elseif new > max then
        pfUI.gui.scroll:SetVerticalScroll(max)
        pfUI.gui.deco.down:SetAlpha(.3)
      else
        pfUI.gui.scroll:SetVerticalScroll(new)
      end
    end
    pfUI.gui.scroll:UpdateScrollState()
  end)

  -- global
  pfUI.gui.global = pfUI.gui:CreateConfigTab("Global Settings")
  local values = { "PT_Sans_Narrow", "Expressway", "diediedie" }
  pfUI.gui:CreateConfig(pfUI.gui.global, "Use Pixelperfect (native resolution) scaling", pfUI_config.global, "pixelperfect", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "Allow frames to be placed offscreen", pfUI_config.global, "offscreen", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "Fontsize", pfUI_config.global, "font_size")
  pfUI.gui:CreateConfig(pfUI.gui.global, "Default Font", pfUI_config.global, "font_default", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.global, "Square Font", pfUI_config.global, "font_square", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.global, "Combat Font", pfUI_config.global, "font_combat", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.global, "Force region compatible font", pfUI_config.global, "force_region", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "Limit UIErrors to one line", pfUI_config.global, "errors_limit", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "Disable UIErrors", pfUI_config.global, "errors_hide", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "Hide Buffs", pfUI_config.global, "hidebuff", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "Hide Weapon Buffs", pfUI_config.global, "hidewbuff", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "Use 24h Clock", pfUI_config.global, "twentyfour", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.global, "Profile", nil, nil, "header")
  local values = {}
  for name, config in pairs(pfUI_profiles) do table.insert(values, name) end

  local function pfUpdateProfiles()
    local values = {}
    for name, config in pairs(pfUI_profiles) do table.insert(values, name) end
    pfUIDropDownMenuProfile.values = values
    pfUIDropDownMenuProfile.Refresh()
  end

  pfUI.gui:CreateConfig(pfUI.gui.global, "Select profile", pfUI_config.global, "profile", "dropdown", values, false, "Profile")

  -- load profile
  pfUI.gui:CreateConfig(pfUI.gui.global, "Load profile", pfUI_config.global, "profile", "button", function()
    if pfUI_config.global.profile and pfUI_profiles[pfUI_config.global.profile] then
      pfUI.api:CreateQuestionDialog("Load profile '|cff33ffcc" .. pfUI_config.global.profile .. "|r'?", function()
        local selp = pfUI_config.global.profile
        pfUI_config = pfUI.api.CopyTable(pfUI_profiles[pfUI_config.global.profile])
        pfUI_config.global.profile = selp
        ReloadUI()
      end)
    end
  end)

  -- delete profile
  pfUI.gui:CreateConfig(pfUI.gui.global, "Delete profile", pfUI_config.global, "profile", "button", function()
    if pfUI_config.global.profile and pfUI_profiles[pfUI_config.global.profile] then
      pfUI.api:CreateQuestionDialog("Delete profile '|cff33ffcc" .. pfUI_config.global.profile .. "|r'?", function()
        pfUI_profiles[pfUI_config.global.profile] = nil
        pfUpdateProfiles()
        this:GetParent():Hide()
      end)
    end
  end, true)

  -- save profile
  pfUI.gui:CreateConfig(pfUI.gui.global, "Save profile", pfUI_config.global, "profile", "button", function()
    if pfUI_config.global.profile and pfUI_profiles[pfUI_config.global.profile] then
      pfUI.api:CreateQuestionDialog("Save current settings to profile '|cff33ffcc" .. pfUI_config.global.profile .. "|r'?", function()
        if pfUI_profiles[pfUI_config.global.profile] then
          pfUI_profiles[pfUI_config.global.profile] = pfUI.api.CopyTable(pfUI_config)
        end
        this:GetParent():Hide()
      end)
    end
  end, true)

  -- create profile
  pfUI.gui:CreateConfig(pfUI.gui.global, "Create Profile", pfUI_config.global, "profile", "button", function()
    pfUI.api:CreateQuestionDialog("Please enter a name for the new profile.\nExisting profiles sharing the same name will be overwritten.",
    function()
      local profile = this:GetParent().input:GetText()
      local bad = string.gsub(profile,"([%w%s]+)","")
      if bad~="" then
        message('Cannot create profile: \"'..bad..'\"' .. " is not allowed in profile name")
      else
        profile = (string.gsub(profile,"^%s*(.-)%s*$", "%1"))
        if profile and profile ~= "" then
          pfUI_profiles[profile] = pfUI.api.CopyTable(pfUI_config)
          pfUpdateProfiles()
          this:GetParent():Hide()
        end
      end
    end, false, true)
  end, true)

  -- appearance
  pfUI.gui.appearance = pfUI.gui:CreateConfigTab("Appearance")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Background Color", pfUI_config.appearance.border, "background", "color")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Border Color", pfUI_config.appearance.border, "color", "color")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Border", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Default Bordersize", pfUI_config.appearance.border, "default")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Actionbar Bordersize", pfUI_config.appearance.border, "actionbars")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "UnitFrame Bordersize", pfUI_config.appearance.border, "unitframes")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "GroupFrame Bordersize", pfUI_config.appearance.border, "groupframes")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "RaidFrame Bordersize", pfUI_config.appearance.border, "raidframes")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Panel Bordersize", pfUI_config.appearance.border, "panels")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Chat Bordersize", pfUI_config.appearance.border, "chat")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Bags Bordersize", pfUI_config.appearance.border, "bags")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Cooldown", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Cooldown color (Minutes)", pfUI_config.appearance.cd, "mincolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Cooldown color (Hours)", pfUI_config.appearance.cd, "hourcolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Cooldown color (Days)", pfUI_config.appearance.cd, "daycolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Cooldown text threshold", pfUI_config.appearance.cd, "threshold")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Castbar", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Castbar color", pfUI_config.appearance.castbar, "castbarcolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Castbar color (Channeling)", pfUI_config.appearance.castbar, "channelcolor", "color")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Combat", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Show combat glow effect on screen edges", pfUI_config.appearance.infight, "screen", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Show combat glow effect on common unit frames", pfUI_config.appearance.infight, "common", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Show combat glow effect on group frames", pfUI_config.appearance.infight, "group", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Bags & Bank", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Only show borders for quality above \"common\"", pfUI_config.appearance.bags, "borderlimit", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Only show borders for equipment", pfUI_config.appearance.bags, "borderonlygear", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Loot", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Auto-resize Lootframe", pfUI_config.appearance.loot, "autoresize", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Minimap", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "Show zone name on mouseover", pfUI_config.appearance.minimap, "mouseoverzone", "checkbox")

  -- modules
  pfUI.gui.modules = pfUI.gui:CreateConfigTab("Modules")
  for i,m in pairs(pfUI.modules) do
    if m ~= "gui" then
      -- create disabled entry if not existing and display
      pfUI:UpdateConfig("disabled", nil, m, "0")
      pfUI.gui:CreateConfig(pfUI.gui.modules, "Disable " .. m, pfUI_config.disabled, m, "checkbox")
    end
  end

  -- unitframes
  pfUI.gui.uf = pfUI.gui:CreateConfigTab("UnitFrames")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Settings", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Disable pfUI-UnitFrames", pfUI_config.unitframes, "disable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Use pastel colors", pfUI_config.unitframes, "pastel", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Use custom color for healthbars", pfUI_config.unitframes, "custom", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Custom healthbar color", pfUI_config.unitframes, "customcolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Animation speed", pfUI_config.unitframes, "animation_speed")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Portrait Alpha on Bars", pfUI_config.unitframes, "portraitalpha")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Use 2D Portraits as fallback", pfUI_config.unitframes, "portraittexture", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "Buff size", pfUI_config.unitframes, "buff_size")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Debuff size", pfUI_config.unitframes, "debuff_size")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Layout", pfUI_config.unitframes, "layout", "dropdown", { "default", "tukui" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Enable Clickcast for all frames", pfUI_config.unitframes, "globalclick", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "Player", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Portrait position", pfUI_config.unitframes.player, "portrait", "dropdown", { "bar", "left", "right", "off" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Health width", pfUI_config.unitframes.player, "width")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Health height", pfUI_config.unitframes.player, "height")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Powerbar height", pfUI_config.unitframes.player, "pheight")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Element spacing", pfUI_config.unitframes.player, "pspace")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Show PvP Icon", pfUI_config.unitframes.player, "showPVP", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Align PvP Icon to Minimap", pfUI_config.unitframes.player, "showPVPMinimap", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Buff position", pfUI_config.unitframes.player, "buffs", "dropdown", { "top", "bottom", "hide"})
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Show energy ticks", pfUI_config.unitframes.player, "energy", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "Target", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Portrait position", pfUI_config.unitframes.target, "portrait", "dropdown", { "bar", "left", "right", "off" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Enable target switch animation", pfUI_config.unitframes.target, "animation", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Health width", pfUI_config.unitframes.target, "width")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Health height", pfUI_config.unitframes.target, "height")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Powerbar height", pfUI_config.unitframes.target, "pheight")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Element spacing", pfUI_config.unitframes.target, "pspace")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Buff position", pfUI_config.unitframes.target, "buffs", "dropdown", { "top", "bottom", "hide"})

  pfUI.gui:CreateConfig(pfUI.gui.uf, "Group", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Portrait position", pfUI_config.unitframes.group, "portrait", "dropdown", { "bar", "left", "right", "off" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Element spacing", pfUI_config.unitframes.group, "pspace")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Hide group while in raid", pfUI_config.unitframes.group, "hide_in_raid", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Enable Clickcast", pfUI_config.unitframes.group, "clickcast", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Enable Raidframe's buff behaviour for Group", pfUI_config.unitframes.group, "raid_buffs", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Enable Raidframe's debuff behaviour for Group", pfUI_config.unitframes.group, "raid_debuffs", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "Raid", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Element spacing", pfUI_config.unitframes.raid, "pspace")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Invert Raid-healthbar", pfUI_config.unitframes.raid, "invert_healthbar", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Show missing HP on raidframes", pfUI_config.unitframes.raid, "show_missing", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast", pfUI_config.unitframes.raid, "clickcast")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast (Shift)", pfUI_config.unitframes.raid, "clickcast_shift")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast (Alt)", pfUI_config.unitframes.raid, "clickcast_alt")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast (Ctrl)", pfUI_config.unitframes.raid, "clickcast_ctrl")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Show my buffs", pfUI_config.unitframes.raid, "buffs_buffs", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Show hots", pfUI_config.unitframes.raid, "buffs_hots", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Show my procs", pfUI_config.unitframes.raid, "buffs_procs", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Only display hots of my class", pfUI_config.unitframes.raid, "buffs_classonly", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Show Debuff indicators", pfUI_config.unitframes.raid, "debuffs_enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Only display Debuffs for my class", pfUI_config.unitframes.raid, "debuffs_class", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "Other", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "TargetTarget Portrait position", pfUI_config.unitframes.ttarget, "portrait", "dropdown", { "bar", "left", "right", "off" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "TargetTarget element spacing", pfUI_config.unitframes.ttarget, "pspace")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "Pet Portrait position", pfUI_config.unitframes.pet, "portrait", "dropdown", { "bar", "left", "right", "off" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Pet element spacing", pfUI_config.unitframes.pet, "pspace")

  -- actionbar
  pfUI.gui.bar = pfUI.gui:CreateConfigTab("ActionBar")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Icon Size", pfUI_config.bars, "icon_size")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Show actionbar backgrounds", pfUI_config.bars, "background", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Use colored icon as range indicator", pfUI_config.bars, "glowrange", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Range indicator Color", pfUI_config.bars, "rangecolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Range based auto paging (Hunter)", pfUI_config.bars, "hunterbar", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.bar, "Seconds to wait until hide bars", pfUI_config.bars, "hide_time")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Autohide main actionbar", pfUI_config.bars, "hide_actionmain", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Autohide bottomleft actionbar", pfUI_config.bars, "hide_bottomleft", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Autohide bottomright actionbar", pfUI_config.bars, "hide_bottomright", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Autohide right actionbar", pfUI_config.bars, "hide_right", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Autohide 2nd right actionbar", pfUI_config.bars, "hide_tworight", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Autohide shapeshift actionbar", pfUI_config.bars, "hide_shapeshift", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Autohide pet actionbar", pfUI_config.bars, "hide_pet", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.bar, "Bar Layouts", nil, nil, "header")
  local values = pfUI.api:BarLayoutOptions(NUM_ACTIONBAR_BUTTONS)
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Default Actionbar [ActionMain]", pfUI_config.bars.actionmain, "formfactor", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Second Actionbar [BottomLeft]", pfUI_config.bars.bottomleft, "formfactor", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Left Actionbar [BottomRight]", pfUI_config.bars.bottomright, "formfactor", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Right Actionbar [Right]", pfUI_config.bars.right, "formfactor", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Vertical Actionbar [TwoRight]", pfUI_config.bars.tworight, "formfactor", "dropdown", values)
  local values = pfUI.api:BarLayoutOptions(NUM_SHAPESHIFT_SLOTS)
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Shapeshift Bar", pfUI_config.bars.shapeshift, "formfactor", "dropdown", values)
  local values = pfUI.api:BarLayoutOptions(NUM_PET_ACTION_SLOTS)
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Pet Bar", pfUI_config.bars.pet, "formfactor", "dropdown", values)

  -- panels
  pfUI.gui.panel = pfUI.gui:CreateConfigTab("Panel")
  local values = { "time", "fps", "exp", "gold", "friends", "guild", "durability", "zone", "combat", "none" }
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Left Panel: Left", pfUI_config.panel.left, "left", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Left Panel: Center", pfUI_config.panel.left, "center", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Left Panel: Right", pfUI_config.panel.left, "right", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Right Panel: Left", pfUI_config.panel.right, "left", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Right Panel: Center", pfUI_config.panel.right, "center", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Right Panel: Right", pfUI_config.panel.right, "right", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Other Panel: Minimap", pfUI_config.panel.other, "minimap", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Always show XP and Reputation Bar", pfUI_config.panel.xp, "showalways", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Show Menubar", pfUI_config.panel.micro, "enable", "checkbox")

  -- tooltip
  pfUI.gui.tooltip = pfUI.gui:CreateConfigTab("Tooltip")
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "Tooltip Position:", pfUI_config.tooltip, "position", "dropdown", { "bottom", "chat", "cursor" })
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "Show extended guild information:", pfUI_config.tooltip, "extguild", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "Custom Transparency", pfUI_config.tooltip, "alpha")
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "Always show comparison:", pfUI_config.tooltip.compare, "showalways", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "Always show extended vendor values:", pfUI_config.tooltip.vendor, "showalways", "checkbox")

  -- castbar
  pfUI.gui.castbar = pfUI.gui:CreateConfigTab("Castbar")
  pfUI.gui:CreateConfig(pfUI.gui.castbar, "Hide blizzards castbar:", pfUI_config.castbar.player, "hide_blizz", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.castbar, "Hide pfUI player castbar:", pfUI_config.castbar.player, "hide_pfui", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.castbar, "Hide pfUI target castbar:", pfUI_config.castbar.target, "hide_pfui", "checkbox")

  -- chat
  pfUI.gui.chat = pfUI.gui:CreateConfigTab("Chat")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Enable \"Loot & Spam\" Chat window:", pfUI_config.chat.right, "enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Chat inputbox width:", pfUI_config.chat.text, "input_width")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Chat inputbox height:", pfUI_config.chat.text, "input_height")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp in chat:", pfUI_config.chat.text, "time", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp format:", pfUI_config.chat.text, "timeformat")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp brackets:", pfUI_config.chat.text, "timebracket")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp color:", pfUI_config.chat.text, "timecolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Use class colors for known players:", pfUI_config.chat.text, "classcolor", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Left chat width:", pfUI_config.chat.left, "width")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Left chat height:", pfUI_config.chat.left, "height")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Right chat width:", pfUI_config.chat.right, "width")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Right chat height:", pfUI_config.chat.right, "height")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Always show right chat pane:", pfUI_config.chat.right, "alwaysshow", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Display chat-tab dock as panel:", pfUI_config.chat.global, "tabdock", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Use custom colors for chats:", pfUI_config.chat.global, "custombg", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Chat Background color:", pfUI_config.chat.global, "background", "color")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Chat Border color:", pfUI_config.chat.global, "border", "color")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Change layout of incoming whispers:", pfUI_config.chat.global, "whispermod", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Color of incoming whispers:", pfUI_config.chat.global, "whisper", "color")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Use sticky chat (remember last channel):", pfUI_config.chat.global, "sticky", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Fade old chat messages:", pfUI_config.chat.global, "fadeout", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Time in seconds until the chat gets faded:", pfUI_config.chat.global, "fadetime")

  -- nameplates
  pfUI.gui.nameplates = pfUI.gui:CreateConfigTab("Nameplates")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Show castbars:", pfUI_config.nameplates, "showcastbar", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Show spellname:", pfUI_config.nameplates, "spellname", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Show debuffs:", pfUI_config.nameplates, "showdebuffs", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Enable Clickthrough:", pfUI_config.nameplates, "clickthrough", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Enable MouseLook on right-clicks:", pfUI_config.nameplates, "rightclick", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Rightclick threshold:", pfUI_config.nameplates, "clickthreshold")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Show class colors on enemies:", pfUI_config.nameplates, "enemyclassc", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Show class colors on friends:", pfUI_config.nameplates, "friendclassc", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Raidicon size:", pfUI_config.nameplates, "raidiconsize")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Show Players only:", pfUI_config.nameplates, "players", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Show Healthpoints:", pfUI_config.nameplates, "showhp", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Vertical position:", pfUI_config.nameplates, "vpos")

  -- thirdparty
  pfUI.gui.thirdparty = pfUI.gui:CreateConfigTab("Thirdparty")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "DPSMate:", pfUI_config.thirdparty.dpsmate, "enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "WIM:", pfUI_config.thirdparty.wim, "enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "HealComm:", pfUI_config.thirdparty.healcomm, "enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "CleanUp:", pfUI_config.thirdparty.cleanup, "enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "KLH Threat Meter:", pfUI_config.thirdparty.ktm, "enable", "checkbox")

  -- [[ bottom section ]] --

  -- Hide GUI
  pfUI.gui.hideGUI = pfUI.gui:CreateConfigTab("Close", "bottom", function()
    if pfUI.gui.settingChanged then
      pfUI.gui:Reload()
    end
    if pfUI.gitter and pfUI.gitter:IsShown() then pfUI.gui:UnlockFrames() end
    pfUI.gui:Hide()
  end)

  -- Unlock Frames
  pfUI.gui.unlockFrames = pfUI.gui:CreateConfigTab("Unlock", "bottom", function()
      pfUI.gui.UnlockFrames()
  end)

  -- Hoverbind
  pfUI.gui.hoverBind = pfUI.gui:CreateConfigTab("Hover Keybind", "bottom", function()
      pfUI.gui.HoverBind()
  end)

  -- Reset Cache
  pfUI.gui.resetCache = pfUI.gui:CreateConfigTab("Reset Cache", "bottom", function()
    pfUI.api:CreateQuestionDialog("Do you really want to reset the Cache?",
      function()
        pfUI_playerDB = {}
        this:GetParent():Hide()
        pfUI.gui:Reload()
      end)
  end)

  -- Reset Frames
  pfUI.gui.resetFrames = pfUI.gui:CreateConfigTab("Reset Positions", "bottom", function()
    pfUI.api:CreateQuestionDialog("Do you really want to reset the Frame Positions?",
      function()
        pfUI_config["position"] = {}
        this:GetParent():Hide()
        pfUI.gui:Reload()
      end)
  end)

  -- Reset Chat
  pfUI.gui.resetChat = pfUI.gui:CreateConfigTab("Reset Firstrun", "bottom", function()
    pfUI.api:CreateQuestionDialog("Do you really want to reset the Firstrun Wizard Settings?",
      function()
        pfUI_init = {}
        this:GetParent():Hide()
        pfUI.gui:Reload()
      end)
  end)

  -- Reset Config
  pfUI.gui.resetConfig = pfUI.gui:CreateConfigTab("Reset Config", "bottom", function()
    pfUI.api:CreateQuestionDialog("Do you really want to reset your configuration?\nThis also includes frame positions",
      function()
        pfUI_config = {}
        pfUI:LoadConfig()
        this:GetParent():Hide()
        pfUI.gui:Reload()
      end)
  end)

  -- Reset All
  pfUI.gui.resetAll = pfUI.gui:CreateConfigTab("Reset All", "bottom", function()
    pfUI.api:CreateQuestionDialog("Do you really want to reset |cffffaaaaEVERYTHING|r?\nThis includes configuration, frame positions, firstrun settings,\n player cache, profiles and just EVERYTHING!",
      function()
        pfUI_init = {}
        pfUI_config = {}
        pfUI_playerDB = {}
        pfUI_profiles = {}
        pfUI:LoadConfig()
        this:GetParent():Hide()
        pfUI.gui:Reload()
      end)
  end)

  -- Switch to default View: global
  pfUI.gui:SwitchTab(pfUI.gui.global)
end)
