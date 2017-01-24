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
    pfUI.api:CreateQuestionDialog("有些设置需要重新加载UI生效。\n您要重新载入UI吗？",
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

    pfUI.info:ShowInfoBox("|cff33ffcc解锁模式|r\n" ..
      "此模式允许您通过使用鼠标光标拖动框架来移动框架。 " ..
      "可以通过向上和向下滚动来移动框架。\n还可以同时移动多个框架 (如：团队框架), " ..
      "在滚动时按住shift键。 单击空白处以返回到pfUI菜单", 15, pfUI.gitter)

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
          frame.drag.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
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
    frame.switch.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
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
      frame.title:SetFont(pfUI.font_default, pfUI_config.global.font_size + 2, "OUTLINE")
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
      frame.caption:SetFont(pfUI.font_default, pfUI_config.global.font_size + 2, "OUTLINE")
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
  pfUI.gui.global = pfUI.gui:CreateConfigTab("全局设置")
  local values = { "arial", "homespun", "diediedie" }
  pfUI.gui:CreateConfig(pfUI.gui.global, "跟随分辨率自动缩放UI", pfUI_config.global, "pixelperfect", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "字号", pfUI_config.global, "font_size")
  pfUI.gui:CreateConfig(pfUI.gui.global, "默认字体", pfUI_config.global, "font_default", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.global, "框体字体", pfUI_config.global, "font_square", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.global, "战斗字体", pfUI_config.global, "font_combat", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.global, "强制兼容中文字体", pfUI_config.global, "force_region", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "仅列出一行错误", pfUI_config.global, "errors_limit", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "禁用错误", pfUI_config.global, "errors_hide", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "隐藏系统Buff图标", pfUI_config.global, "hidebuff", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.global, "隐藏武器Buff图标", pfUI_config.global, "hidewbuff", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.global, "配置文件", nil, nil, "header")
  local values = {}
  for name, config in pairs(pfUI_profiles) do table.insert(values, name) end

  local function pfUpdateProfiles()
    local values = {}
    for name, config in pairs(pfUI_profiles) do table.insert(values, name) end
    pfUIDropDownMenuProfile.values = values
    pfUIDropDownMenuProfile.Refresh()
  end

  pfUI.gui:CreateConfig(pfUI.gui.global, "选择配置文件", pfUI_config.global, "profile", "dropdown", values, false, "Profile")

  -- load profile
  pfUI.gui:CreateConfig(pfUI.gui.global, "加载配置文件", pfUI_config.global, "profile", "button", function()
    if pfUI_config.global.profile and pfUI_profiles[pfUI_config.global.profile] then
      pfUI.api:CreateQuestionDialog("加载配置文件 '|cff33ffcc" .. pfUI_config.global.profile .. "|r'?", function()
        local selp = pfUI_config.global.profile
        pfUI_config = pfUI.api.CopyTable(pfUI_profiles[pfUI_config.global.profile])
        pfUI_config.global.profile = selp
        ReloadUI()
      end)
    end
  end)

  -- delete profile
  pfUI.gui:CreateConfig(pfUI.gui.global, "删除配置文件", pfUI_config.global, "profile", "button", function()
    if pfUI_config.global.profile and pfUI_profiles[pfUI_config.global.profile] then
      pfUI.api:CreateQuestionDialog("删除配置文件 '|cff33ffcc" .. pfUI_config.global.profile .. "|r'?", function()
        pfUI_profiles[pfUI_config.global.profile] = nil
        pfUpdateProfiles()
        this:GetParent():Hide()
      end)
    end
  end, true)

  -- save profile
  pfUI.gui:CreateConfig(pfUI.gui.global, "保存配置文件", pfUI_config.global, "profile", "button", function()
    if pfUI_config.global.profile and pfUI_profiles[pfUI_config.global.profile] then
      pfUI.api:CreateQuestionDialog("把现有设置保存到 '|cff33ffcc" .. pfUI_config.global.profile .. "|r'?", function()
        if pfUI_profiles[pfUI_config.global.profile] then
          pfUI_profiles[pfUI_config.global.profile] = pfUI.api.CopyTable(pfUI_config)
        end
        this:GetParent():Hide()
      end)
    end
  end, true)

  -- create profile
  pfUI.gui:CreateConfig(pfUI.gui.global, "新建配置文件", pfUI_config.global, "profile", "button", function()
    pfUI.api:CreateQuestionDialog("请输入新建配置文件名，相同名字将会自动覆盖。",
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
  pfUI.gui.appearance = pfUI.gui:CreateConfigTab("外观设置")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "背景颜色", pfUI_config.appearance.border, "background", "color")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "边框颜色", pfUI_config.appearance.border, "color", "color")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "边框设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "默认边框大小", pfUI_config.appearance.border, "default")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "动作条边框大小", pfUI_config.appearance.border, "actionbars")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "头像框架大小", pfUI_config.appearance.border, "unitframes")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "小队框架大小", pfUI_config.appearance.border, "groupframes")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "团队框架大小", pfUI_config.appearance.border, "raidframes")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "面板边框大小", pfUI_config.appearance.border, "panels")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "聊天框架大小", pfUI_config.appearance.border, "chat")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "背包边框大小", pfUI_config.appearance.border, "bags")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "冷却时间设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "冷却时间颜色（分）", pfUI_config.appearance.cd, "mincolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "冷却时间颜色（时）", pfUI_config.appearance.cd, "hourcolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "冷却时间颜色（天）", pfUI_config.appearance.cd, "daycolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "冷却时间文字大小", pfUI_config.appearance.cd, "threshold")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "施法条设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "施法条颜色", pfUI_config.appearance.castbar, "castbarcolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "施法条空白处颜色", pfUI_config.appearance.castbar, "channelcolor", "color")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "战斗相关设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "全屏显示战斗报警", pfUI_config.appearance.infight, "screen", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "仅在头像上显示战斗报警", pfUI_config.appearance.infight, "common", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "在小队显示战斗报警", pfUI_config.appearance.infight, "group", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "背包和银行设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "只显示\"普通品质\"以上的物品", pfUI_config.appearance.bags, "borderlimit", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "只显示装备", pfUI_config.appearance.bags, "borderonlygear", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.appearance, "拾取设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.appearance, "自动调整拾取框大小", pfUI_config.appearance.loot, "autoresize", "checkbox")

  -- modules
  pfUI.gui.modules = pfUI.gui:CreateConfigTab("高级单元")
  pfUI.gui:CreateConfig(pfUI.gui.modules, "|cffff5555注意：|cffffaaaa如果你不知道该如何禁用，请不要随便设置，有可能会造成插件错误等问题。如发现不可恢复的\n错误，请删除WOW根目录下的WTF文件夹|r", nil, nil, "warning")
  for i,m in pairs(pfUI.modules) do
    if m ~= "gui" then
      -- create disabled entry if not existing and display
      pfUI:UpdateConfig("disabled", nil, m, "0")
      pfUI.gui:CreateConfig(pfUI.gui.modules, "Disable " .. m, pfUI_config.disabled, m, "checkbox")
    end
  end

  -- unitframes
  pfUI.gui.uf = pfUI.gui:CreateConfigTab("头像美化增强")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "基本设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "禁用头像增强", pfUI_config.unitframes, "disable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "头像颜色变柔", pfUI_config.unitframes, "pastel", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "启用自定义生命条颜色", pfUI_config.unitframes, "custom", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "自定义生命条颜色", pfUI_config.unitframes, "customcolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "头像动画速度", pfUI_config.unitframes, "animation_speed")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "显示头像动画", pfUI_config.unitframes, "portraitalpha")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "2D图像作为备选", pfUI_config.unitframes, "portraittexture", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "Buff调整", pfUI_config.unitframes, "buff_size")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Debuff调整", pfUI_config.unitframes, "debuff_size")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "样式", pfUI_config.unitframes, "layout", "dropdown", { "default", "tukui" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "所有头像都可选中", pfUI_config.unitframes, "globalclick", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "玩家设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "玩家头像位置", pfUI_config.unitframes.player, "portrait", "dropdown", { "bar", "left", "right", "off" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "玩家头像宽度调整", pfUI_config.unitframes.player, "width")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "玩家头像高度调整", pfUI_config.unitframes.player, "height")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "玩家能量值高度调整", pfUI_config.unitframes.player, "pheight")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "玩家能量值与头像间距调整", pfUI_config.unitframes.player, "pspace")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "显示PVP图标", pfUI_config.unitframes.player, "showPVP", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "在小地图上平铺PVP图标", pfUI_config.unitframes.player, "showPVPMinimap", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Buff位置", pfUI_config.unitframes.player, "buffs", "dropdown", { "top", "bottom", "hide"})
  pfUI.gui:CreateConfig(pfUI.gui.uf, "显示能量刻度", pfUI_config.unitframes.player, "energy", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "目标设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "目标头像位置", pfUI_config.unitframes.target, "portrait", "dropdown", { "bar", "left", "right", "off" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "启用目标切换动画", pfUI_config.unitframes.target, "animation", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "目标头像宽度调整", pfUI_config.unitframes.target, "width")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "目标头像高度调整", pfUI_config.unitframes.target, "height")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "目标能量值高度调整", pfUI_config.unitframes.target, "pheight")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "目标能量值与头像间距调整", pfUI_config.unitframes.target, "pspace")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Buff位置", pfUI_config.unitframes.target, "buffs", "dropdown", { "top", "bottom", "hide"})

  pfUI.gui:CreateConfig(pfUI.gui.uf, "小队设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "小队头像位置", pfUI_config.unitframes.group, "portrait", "dropdown", { "bar", "left", "right", "off" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "小队能量值间距调整", pfUI_config.unitframes.group, "pspace")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "在团队模式下隐藏小队框架", pfUI_config.unitframes.group, "hide_in_raid", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "可以点击施法", pfUI_config.unitframes.group, "clickcast", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "通过小队加Buff", pfUI_config.unitframes.group, "raid_buffs", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "通过小队解除Debuff", pfUI_config.unitframes.group, "raid_debuffs", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "团队设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "团队能量值间距调整", pfUI_config.unitframes.raid, "pspace")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "团队框架生命值反相显示", pfUI_config.unitframes.raid, "invert_healthbar", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "团队模式下显示掉的血量", pfUI_config.unitframes.raid, "show_missing", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "团队框架上点击施法", pfUI_config.unitframes.raid, "clickcast")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "团队框架上按Shift施法", pfUI_config.unitframes.raid, "clickcast_shift")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "团队框架上按Alt施法", pfUI_config.unitframes.raid, "clickcast_alt")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "团队框架上按Ctrl施法", pfUI_config.unitframes.raid, "clickcast_ctrl")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "显示自己的Buff", pfUI_config.unitframes.raid, "buffs_buffs", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "显示持续治疗", pfUI_config.unitframes.raid, "buffs_hots", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "显示自己的风怒", pfUI_config.unitframes.raid, "buffs_procs", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "仅不显示自己的持续治疗", pfUI_config.unitframes.raid, "buffs_classonly", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "团队框架上显示Debuff", pfUI_config.unitframes.raid, "debuffs_enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "仅不显示自己的Debuff", pfUI_config.unitframes.raid, "debuffs_class", "checkbox")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "其他设置", nil, nil, "header")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "目标的目标头像位置", pfUI_config.unitframes.ttarget, "portrait", "dropdown", { "bar", "left", "right", "off" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "目标的目标能量值间距调整", pfUI_config.unitframes.ttarget, "pspace")

  pfUI.gui:CreateConfig(pfUI.gui.uf, "宠物的头像位置", pfUI_config.unitframes.pet, "portrait", "dropdown", { "bar", "left", "right", "off" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "宠物能量值间距调整", pfUI_config.unitframes.pet, "pspace")

  -- actionbar
  pfUI.gui.bar = pfUI.gui:CreateConfigTab("动作条")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "图标大小", pfUI_config.bars, "icon_size")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "显示动作条背景图案", pfUI_config.bars, "background", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "使用颜色指示技能使用距离", pfUI_config.bars, "glowrange", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "技能使用距离颜色", pfUI_config.bars, "rangecolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "自动隐藏动作条延时", pfUI_config.bars, "hide_time")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "自动隐藏主动作条", pfUI_config.bars, "hide_bottom", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "自动隐藏左下方动作条", pfUI_config.bars, "hide_bottomleft", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "自动隐藏右下方动作条", pfUI_config.bars, "hide_bottomright", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "自动隐藏右边动作条", pfUI_config.bars, "hide_vertical", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "自动隐藏姿态条", pfUI_config.bars, "hide_shapeshift", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "自动隐藏宠物动作条", pfUI_config.bars, "hide_pet", "checkbox")

  -- panels
  pfUI.gui.panel = pfUI.gui:CreateConfigTab("聊天框架附加内容")
  local values = { "时间", "延迟", "经验", "金钱", "好友", "公会", "耐久", "地区", "无" }
  pfUI.gui:CreateConfig(pfUI.gui.panel, "左侧面板：左侧", pfUI_config.panel.left, "left", "dropdown", values )
  pfUI.gui:CreateConfig(pfUI.gui.panel, "左侧面板：中部", pfUI_config.panel.left, "center", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "左侧面板：右侧", pfUI_config.panel.left, "right", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "右侧面板：左侧", pfUI_config.panel.right, "left", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "右侧面板：中部", pfUI_config.panel.right, "center", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "右侧面板：右侧", pfUI_config.panel.right, "right", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "小地图上显示", pfUI_config.panel.other, "minimap", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "总是显示经验或者声望", pfUI_config.panel.xp, "showalways", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.panel, "显示菜单", pfUI_config.panel.micro, "enable", "checkbox")

  -- tooltip
  pfUI.gui.tooltip = pfUI.gui:CreateConfigTab("鼠标提示框")
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "提示框位置", pfUI_config.tooltip, "position", "dropdown", { "底部", "聊天框", "跟随鼠标" })
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "显示扩展的公会信息", pfUI_config.tooltip, "extguild", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "自定义透明度", pfUI_config.tooltip, "alpha")
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "始终显示装备比较", pfUI_config.tooltip.compare, "showalways", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "总是显示扩展出售价值", pfUI_config.tooltip.vendor, "showalways", "checkbox")

  -- castbar
  pfUI.gui.castbar = pfUI.gui:CreateConfigTab("施法条")
  pfUI.gui:CreateConfig(pfUI.gui.castbar, "隐藏系统施法条", pfUI_config.castbar.player, "hide_blizz", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.castbar, "隐藏玩家施法条", pfUI_config.castbar.player, "hide_pfui", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.castbar, "隐藏目标施法条", pfUI_config.castbar.target, "hide_pfui", "checkbox")

  -- chat
  pfUI.gui.chat = pfUI.gui:CreateConfigTab("对话窗口")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "启用 \"China Chat\" 聊天窗口", pfUI_config.chat.right, "enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "文字输入框宽度", pfUI_config.chat.text, "input_width")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "文字输入框高度", pfUI_config.chat.text, "input_height")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "对话框显示时间戳", pfUI_config.chat.text, "time", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "时间戳格式", pfUI_config.chat.text, "timeformat")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "时间戳括弧", pfUI_config.chat.text, "timebracket")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "时间戳颜色", pfUI_config.chat.text, "timecolor", "color")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "左侧对话框宽度", pfUI_config.chat.left, "width")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "左侧对话框高度", pfUI_config.chat.left, "height")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "右侧对话框宽度", pfUI_config.chat.right, "width")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "右侧对话框高度", pfUI_config.chat.right, "height")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "将聊天窗口显示为面板", pfUI_config.chat.global, "tabdock", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "使用自定义聊天窗口颜色:", pfUI_config.chat.global, "custombg", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "对话框背景颜色", pfUI_config.chat.global, "background", "color")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "对话框边颜色", pfUI_config.chat.global, "border", "color")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "更改传入密语的布局", pfUI_config.chat.global, "whispermod", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "密语颜色设置", pfUI_config.chat.global, "whisper", "color")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "使用粘性聊天（记住最后一个频道）:", pfUI_config.chat.global, "sticky", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "淡出旧的聊天消息", pfUI_config.chat.global, "fadeout", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "聊天记录淡出时间", pfUI_config.chat.global, "fadetime")

  -- nameplates
  pfUI.gui.nameplates = pfUI.gui:CreateConfigTab("姓名板")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "显示施法条", pfUI_config.nameplates, "showcastbar", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "显示技能名称", pfUI_config.nameplates, "spellname", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "显示Debuff", pfUI_config.nameplates, "showdebuffs", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "取消点击姓名板选取目标", pfUI_config.nameplates, "clickthrough", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "启动右键移动镜头", pfUI_config.nameplates, "rightclick", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "镜头移动速度", pfUI_config.nameplates, "clickthreshold")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "显示敌人职业颜色", pfUI_config.nameplates, "enemyclassc", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "显示友军职业颜色", pfUI_config.nameplates, "friendclassc", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "团队图标大小", pfUI_config.nameplates, "raidiconsize")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "仅显示玩家自己", pfUI_config.nameplates, "players", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "显示生命值", pfUI_config.nameplates, "showhp", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "垂直偏移", pfUI_config.nameplates, "vpos")

  -- thirdparty
  pfUI.gui.thirdparty = pfUI.gui:CreateConfigTab("其他插件接口")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "DPSMate:", pfUI_config.thirdparty.dpsmate, "enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "WIM:", pfUI_config.thirdparty.wim, "enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "HealComm:", pfUI_config.thirdparty.healcomm, "enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "CleanUp:", pfUI_config.thirdparty.cleanup, "enable", "checkbox")

  -- [[ bottom section ]] --

  -- Hide GUI
  pfUI.gui.hideGUI = pfUI.gui:CreateConfigTab("关闭", "bottom", function()
    if pfUI.gui.settingChanged then
      pfUI.gui:Reload()
    end
    if pfUI.gitter and pfUI.gitter:IsShown() then pfUI.gui:UnlockFrames() end
    pfUI.gui:Hide()
  end)

  -- Unlock Frames
  pfUI.gui.unlockFrames = pfUI.gui:CreateConfigTab("解锁重排", "bottom", function()
      pfUI.gui.UnlockFrames()
  end)

  -- Hoverbind
  pfUI.gui.hoverBind = pfUI.gui:CreateConfigTab("悬停热键绑定", "bottom", function()
      pfUI.gui.HoverBind()
  end)

  -- Reset Cache
  pfUI.gui.resetCache = pfUI.gui:CreateConfigTab("重置缓存", "bottom", function()
    pfUI.api:CreateQuestionDialog("你真的要重置缓存吗？",
      function()
        pfUI_playerDB = {}
        this:GetParent():Hide()
        pfUI.gui:Reload()
      end)
  end)

  -- Reset Frames
  pfUI.gui.resetFrames = pfUI.gui:CreateConfigTab("重置当前用户设置", "bottom", function()
    pfUI.api:CreateQuestionDialog("你真的要重置当前用户设置吗？",
      function()
        pfUI_config["position"] = {}
        this:GetParent():Hide()
        pfUI.gui:Reload()
      end)
  end)

  -- Reset Chat
  pfUI.gui.resetChat = pfUI.gui:CreateConfigTab("重置聊天框设置", "bottom", function()
    pfUI.api:CreateQuestionDialog("你真的要重置聊天框设置吗？",
      function()
        pfUI_init = {}
        this:GetParent():Hide()
        pfUI.gui:Reload()
      end)
  end)

  -- Reset Config
  pfUI.gui.resetConfig = pfUI.gui:CreateConfigTab("复位配置", "bottom", function()
    pfUI.api:CreateQuestionDialog("您确定要重置您的配置吗？\n这还包括框架位置设置",
      function()
        pfUI_config = {}
        pfUI:LoadConfig()
        this:GetParent():Hide()
        pfUI.gui:Reload()
      end)
  end)

  -- Reset All
  pfUI.gui.resetAll = pfUI.gui:CreateConfigTab("全部重置", "bottom", function()
    pfUI.api:CreateQuestionDialog("你真的想要重置 |cffffaaaa所有配置|r?\n这包括配置，框架位置，冷却设置，\n 缓存文件, 个人设置等一切配置！",
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
