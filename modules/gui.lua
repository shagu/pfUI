pfUI:RegisterModule("gui", function ()
  pfUI.gui = CreateFrame("Frame",nil,UIParent)

  pfUI.gui:RegisterEvent("PLAYER_ENTERING_WORLD");

  pfUI.gui:SetFrameStrata("DIALOG")
  pfUI.gui:SetWidth(480)
  pfUI.gui:SetHeight(360)
  pfUI.gui:Hide()

  pfUI.gui:SetBackdrop(pfUI.backdrop)
  pfUI.gui:SetBackdropColor(0,0,0,.75);
  pfUI.gui:SetPoint("CENTER",0,0)
  pfUI.gui:SetMovable(true)
  pfUI.gui:EnableMouse(true)
  pfUI.gui:SetScript("OnMouseDown",function()
    pfUI.gui:StartMoving()
  end)

  pfUI.gui:SetScript("OnMouseUp",function()
    pfUI.gui:StopMovingOrSizing()
  end)

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

  pfUI.gui.reloadDialog = CreateFrame("Frame","pfReloadDiag",UIParent)
  pfUI.gui.reloadDialog:SetFrameStrata("TOOLTIP")
  pfUI.gui.reloadDialog:SetWidth(300)
  pfUI.gui.reloadDialog:SetHeight(100)
  pfUI.gui.reloadDialog:Hide()
  tinsert(UISpecialFrames, "pfReloadDiag")

  pfUI.gui.reloadDialog:SetBackdrop(pfUI.backdrop)
  pfUI.gui.reloadDialog:SetPoint("CENTER",0,0)

  pfUI.gui.reloadDialog.text = pfUI.gui.reloadDialog:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.reloadDialog.text:SetFontObject(GameFontWhite)
  pfUI.gui.reloadDialog.text:SetPoint("TOP", 0, -15)
  pfUI.gui.reloadDialog.text:SetText("Some settings need to reload the UI to take effect.\nDo you want to reloadUI now?")

  pfUI.gui.reloadDialog.yes = CreateFrame("Button", "pfReloadYes", pfUI.gui.reloadDialog, "UIPanelButtonTemplate")
  pfUI.gui.reloadDialog.yes:SetBackdrop(pfUI.backdrop)
  pfUI.gui.reloadDialog.yes:SetWidth(100)
  pfUI.gui.reloadDialog.yes:SetHeight(20)
  pfUI.gui.reloadDialog.yes:SetPoint("BOTTOMLEFT", 20,15)
  pfUI.gui.reloadDialog.yes:SetText("Yes")
  pfUI.gui.reloadDialog.yes:SetScript("OnClick", function()
    pfUI.gui.settingChanged = nil
    ReloadUI();
  end)

  pfUI.gui.reloadDialog.no = CreateFrame("Button", "pfReloadNo", pfUI.gui.reloadDialog, "UIPanelButtonTemplate")
  pfUI.gui.reloadDialog.no:SetWidth(100)
  pfUI.gui.reloadDialog.no:SetHeight(20)
  pfUI.gui.reloadDialog.no:SetPoint("BOTTOMRIGHT", -20,15)
  pfUI.gui.reloadDialog.no:SetText("No")
  pfUI.gui.reloadDialog.no:SetScript("OnClick", function()
    pfUI.gui.reloadDialog:Hide()
  end)

  function pfUI.gui.UnlockFrames()
    local movable = { pfUI.minimap, pfUI.chat.left, pfUI.chat.right,
      pfUI.uf.player, pfUI.uf.target, pfUI.uf.targettarget, pfUI.uf.pet,
      pfUI.bars.shapeshift, pfUI.bars.bottomleft, pfUI.bars.bottomright,
      pfUI.bars.vertical, pfUI.bars.pet, pfUI.bars.bottom, pfUI.panel.minimap,
      pfUI.uf.group[1], pfUI.uf.group[2], pfUI.uf.group[3], pfUI.uf.group[4],
      pfUI.uf.raid[1], pfUI.uf.raid[2], pfUI.uf.raid[3], pfUI.uf.raid[4], pfUI.uf.raid[5],
      pfUI.uf.raid[6], pfUI.uf.raid[7], pfUI.uf.raid[8], pfUI.uf.raid[9], pfUI.uf.raid[10],
      pfUI.uf.raid[11], pfUI.uf.raid[12], pfUI.uf.raid[13], pfUI.uf.raid[14], pfUI.uf.raid[15],
      pfUI.uf.raid[16], pfUI.uf.raid[17], pfUI.uf.raid[18], pfUI.uf.raid[19], pfUI.uf.raid[20],
      pfUI.uf.raid[21], pfUI.uf.raid[22], pfUI.uf.raid[23], pfUI.uf.raid[24], pfUI.uf.raid[25],
      pfUI.uf.raid[26], pfUI.uf.raid[27], pfUI.uf.raid[28], pfUI.uf.raid[29], pfUI.uf.raid[30],
      pfUI.uf.raid[31], pfUI.uf.raid[32], pfUI.uf.raid[33], pfUI.uf.raid[34], pfUI.uf.raid[35],
      pfUI.uf.raid[36], pfUI.uf.raid[37], pfUI.uf.raid[38], pfUI.uf.raid[39], pfUI.uf.raid[40],
      pfUI.chat.editbox,
      }

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

    pfUI.info:ShowInfoBox("|cff33ffccUnlock Mode|r\nThis mode allows you to move frames by dragging them using the mouse cursor. Frames can be scaled by scrolling up and down.\nTo scale multiple frames at once (eg. raidframes), hold down the shift key while scrolling. Click into an empty space to go back to the pfUI menu.", 15, pfUI.gitter)

    if pfUI.gitter:IsShown() then
      pfUI.gitter:Hide()
      pfUI.gui:Show()
    else
      pfUI.gitter:Show()
      pfUI.gui:Hide()
    end

    for _,frame in pairs(movable) do
      local frame = frame
      if not frame:IsShown() then
        frame.hideLater = true
      end

      if not frame.drag then
        frame.drag = CreateFrame("Frame", nil, frame)
        frame.drag:SetAllPoints(frame)
        frame.drag:SetFrameStrata("DIALOG")
        frame.drag:SetBackdrop(pfUI.backdrop_col)
        frame.drag:SetBackdropBorderColor(.2, 1, .8)
        frame.drag:SetBackdropColor(1,1,1,.75)
        frame.drag:EnableMouseWheel(1)
        frame.drag.text = frame.drag:CreateFontString("Status", "LOW", "GameFontNormal")
        frame.drag.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
        frame.drag.text:ClearAllPoints()
        frame.drag.text:SetAllPoints(frame.drag)
        frame.drag.text:SetPoint("CENTER", 0, 0)
        frame.drag.text:SetFontObject(GameFontWhite)
        frame.drag.text:SetText(strsub(frame:GetName(),3))
        frame.drag:SetAlpha(1)

        frame.drag:SetScript("OnMouseWheel", function()
          local scale = round(frame:GetScale() + arg1/10, 1)

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
          else
            pfUI.gui:SaveScale(frame, scale)
          end
        end)
      end

      frame.drag:SetScript("OnMouseDown",function()
          frame:StartMoving()
        end)

      frame.drag:SetScript("OnMouseUp",function()
          frame:StopMovingOrSizing()
          _, _, _, xpos, ypos = frame:GetPoint()

          if not pfUI_config.position[frame:GetName()] then
            pfUI_config.position[frame:GetName()] = {}
          end

          pfUI_config.position[frame:GetName()]["xpos"] = xpos
          pfUI_config.position[frame:GetName()]["ypos"] = ypos
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

  function pfUI.gui:SwitchTab(frame)
    local elements = { pfUI.gui.global, pfUI.gui.modules, pfUI.gui.uf , pfUI.gui.bar, pfUI.gui.panel,
      pfUI.gui.tooltip, pfUI.gui.castbar, pfUI.gui.thirdparty, pfUI.gui.chat, pfUI.gui.nameplates }

    for _, hide in pairs(elements) do
      hide:Hide()
      hide.switch:SetBackdropBorderColor(1,1,1)
      hide.switch:SetBackdrop(pfUI.backdrop)
    end
    pfUI.gui.scroll:SetScrollChild(frame)
    pfUI.gui.scroll:UpdateScrollState()
    pfUI.gui.scroll:SetVerticalScroll(0)
    frame.switch:SetBackdrop(pfUI.backdrop_col)
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
    frame:SetWidth(100)
    frame:SetHeight(100)

    frame.switch = CreateFrame("Button", nil, pfUI.gui)
    frame.switch:ClearAllPoints()
    frame.switch:SetWidth(80)
    frame.switch:SetHeight(20)

    if bottom then
      frame.switch:SetPoint("BOTTOMLEFT", 0, pfUI.gui.tabBottom * 20)
    else
      frame.switch:SetPoint("TOPLEFT", 0, -pfUI.gui.tabTop * 20)
    end
    frame.switch:SetBackdrop(pfUI.backdrop)
    frame.switch.text = frame.switch:CreateFontString("Status", "LOW", "GameFontNormal")
    frame.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
    frame.switch.text:ClearAllPoints()
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
      frame.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
      frame.title:SetPoint("TOP", 0, -10)
      frame.title:SetFontObject(GameFontWhite)
      frame.title:SetText(text)
    end

    return frame
  end

  function pfUI.gui:CreateConfig(parent, caption, category, config, widget, values)
    -- parent object placement
    if parent.objectCount == nil then
      parent.objectCount = 1
    else
      parent.objectCount = parent.objectCount + 1
    end

    -- basic frame
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(350)
    frame:SetHeight(25)
    frame:SetBackdrop(pfUI.backdrop_underline)
    frame:SetBackdropBorderColor(1,1,1,.25)
    frame:SetPoint("TOPLEFT", 25, parent.objectCount * -25)

    -- caption
    frame.caption = frame:CreateFontString("Status", "LOW", "GameFontNormal")
    frame.caption:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
    frame.caption:SetAllPoints(frame)
    frame.caption:SetFontObject(GameFontWhite)
    frame.caption:SetJustifyH("LEFT")
    frame.caption:SetText(caption)
    frame.configCategory = category
    frame.configEntry = config

    frame.category = category
    frame.config = config

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

      frame.input:SetScript("OnEditFocusLost", function(self)
        this:GetParent().category[this:GetParent().config] = this:GetText()
        pfUI.gui.settingChanged = true
      end)
    end

    -- use checkbox widget
    if widget == "checkbox" then
      -- input field
      frame.input = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
      frame.input:SetNormalTexture("")
      frame.input:SetPushedTexture("")
      frame.input:SetHighlightTexture("")
      frame.input:SetBackdrop(pfUI.backdrop)
      frame.input:SetWidth(14)
      frame.input:SetHeight(14)
      frame.input:SetPoint("TOPRIGHT" , 0, -4)
--      frame.input:SetText(category[config])
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
      frame.input = CreateFrame("Frame", "pfUIDropDownMenu" .. pfUI.gui.ddc, frame, "UIDropDownMenuTemplate")
      frame.input:ClearAllPoints()
      frame.input:SetPoint("TOPRIGHT" , 20, 3)
      frame.input:Show()
      frame.input.point = "TOPRIGHT"
      frame.input.relativePoint = "BOTTOMRIGHT"

      local function createValues()
        local info = {}
        for i, k in pairs(values) do
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

      UIDropDownMenu_Initialize(frame.input, createValues)
      UIDropDownMenu_SetWidth(120, frame.input);
      UIDropDownMenu_SetButtonWidth(125, frame.input)
      UIDropDownMenu_JustifyText("RIGHT", frame.input)
      UIDropDownMenu_SetSelectedID(frame.input, frame.input.current)

      for i,v in ipairs({frame.input:GetRegions()}) do
        if v.SetTexture then v:Hide() end
        if v.SetTextColor then v:SetTextColor(.2,1,.8) end
        if v.SetBackdrop then v:SetBackdrop(pfUI.backdrop) end
      end
    end

    return frame
  end

  -- [[ config section ]] --
  pfUI.gui.deco = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.deco:ClearAllPoints()
  pfUI.gui.deco:SetPoint("TOPLEFT", pfUI.gui, "TOPLEFT", 80,0)
  pfUI.gui.deco:SetPoint("BOTTOMRIGHT", pfUI.gui, "BOTTOMRIGHT", 0,0)
  pfUI.gui.deco:SetBackdrop(pfUI.backdrop)
  pfUI.gui.deco:SetBackdropColor(0,0,0,.50);

  pfUI.gui.deco.up = CreateFrame("Frame", nil, pfUI.gui.deco)
  pfUI.gui.deco.up:SetPoint("TOPRIGHT", 0,0)
  pfUI.gui.deco.up:SetHeight(16)
  pfUI.gui.deco.up:SetWidth(400)
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

    if pfUI.gui.deco.up.visible == 1 and pfUI.gui.deco.up:GetAlpha() > .15 then
      pfUI.gui.deco.up:SetAlpha(pfUI.gui.deco.up:GetAlpha() - 0.01)
    end
  end)

  pfUI.gui.deco.down = CreateFrame("Frame", nil, pfUI.gui.deco)
  pfUI.gui.deco.down:SetPoint("BOTTOMRIGHT", 0,0)
  pfUI.gui.deco.down:SetHeight(16)
  pfUI.gui.deco.down:SetWidth(400)
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

    if pfUI.gui.deco.down.visible == 1 and pfUI.gui.deco.down:GetAlpha() > .15 then
      pfUI.gui.deco.down:SetAlpha(pfUI.gui.deco.down:GetAlpha() - 0.01)
    end
  end)

  pfUI.gui.scroll = CreateFrame("ScrollFrame", nil, pfUI.gui)
  pfUI.gui.scroll:ClearAllPoints()
  pfUI.gui.scroll:SetPoint("TOPLEFT", pfUI.gui, "TOPLEFT", 80,-10)
  pfUI.gui.scroll:SetPoint("BOTTOMRIGHT", pfUI.gui, "BOTTOMRIGHT", 0,10)
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
    local new = current + arg1*-10
    local max = pfUI.gui.scroll:GetVerticalScrollRange() + 10
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
  pfUI.gui:CreateConfig(pfUI.gui.global, "Fontsize", pfUI_config.global, "font_size")

  -- modules
  pfUI.gui.modules = pfUI.gui:CreateConfigTab("Modules")
  for i,m in pairs(pfUI.modules) do
    -- create disabled entry if not existing and display
    pfUI:UpdateConfig("disabled", nil, m, "0")
    pfUI.gui:CreateConfig(pfUI.gui.modules, "Disable " .. m, pfUI_config.disabled, m, "checkbox")
  end

  -- unitframes
  pfUI.gui.uf = pfUI.gui:CreateConfigTab("UnitFrames")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Animation speed", pfUI_config.unitframes, "animation_speed")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Show portrait", pfUI_config.unitframes, "portrait", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Buff size", pfUI_config.unitframes, "buff_size")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Debuff size", pfUI_config.unitframes, "debuff_size")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Layout", pfUI_config.unitframes, "layout", "dropdown", { "default", "tukui" })
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Player width", pfUI_config.unitframes.player, "width")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Player height", pfUI_config.unitframes.player, "height")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Player powerbar height", pfUI_config.unitframes.player, "pheight")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Show PvP Icon", pfUI_config.unitframes.player, "showPVP", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Align PvP Icon to Minimap", pfUI_config.unitframes.player, "showPVPMinimap", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Target width", pfUI_config.unitframes.target, "width")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Target height", pfUI_config.unitframes.target, "height")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Target powerbar height", pfUI_config.unitframes.target, "pheight")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Hide group while in raid", pfUI_config.unitframes.group, "hide_in_raid", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Invert Raid-healthbar", pfUI_config.unitframes.raid, "invert_healthbar", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Show missing HP on raidframes", pfUI_config.unitframes.raid, "show_missing", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe", pfUI_config.unitframes.raid, "clickcast")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe (Shift)", pfUI_config.unitframes.raid, "clickcast_shift")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe (Alt)", pfUI_config.unitframes.raid, "clickcast_alt")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe (Ctrl)", pfUI_config.unitframes.raid, "clickcast_ctrl")

  -- actionbar
  pfUI.gui.bar = pfUI.gui:CreateConfigTab("ActionBar")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Icon Size", pfUI_config.bars, "icon_size")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Border", pfUI_config.bars, "border")

  -- panels
  pfUI.gui.panel = pfUI.gui:CreateConfigTab("Panel")
  local values = { "time", "fps", "exp", "gold", "friends", "guild", "durability", "zone" }
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Left Panel: Left", pfUI_config.panel.left, "left", "dropdown", values )
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Left Panel: Center", pfUI_config.panel.left, "center", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Left Panel: Right", pfUI_config.panel.left, "right", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Right Panel: Left", pfUI_config.panel.right, "left", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Right Panel: Center", pfUI_config.panel.right, "center", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Right Panel: Right", pfUI_config.panel.right, "right", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Other Panel: Minimap", pfUI_config.panel.other, "minimap", "dropdown", values)
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Always show XP and Reputation Bar", pfUI_config.panel.xp, "showalways", "checkbox")

  -- tooltip
  pfUI.gui.tooltip = pfUI.gui:CreateConfigTab("Tooltip")
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "Tooltip Position:", pfUI_config.tooltip, "position", "dropdown", { "bottom", "chat", "cursor" })

  -- castbar
  pfUI.gui.castbar = pfUI.gui:CreateConfigTab("Castbar")
  pfUI.gui:CreateConfig(pfUI.gui.castbar, "Hide blizzards castbar:", pfUI_config.castbar.player, "hide_blizz", "checkbox")

  -- chat
  pfUI.gui.chat = pfUI.gui:CreateConfigTab("Chat")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Chat inputbox width:", pfUI_config.chat.text, "input_width")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Chat inputbox height:", pfUI_config.chat.text, "input_height")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp in chat:", pfUI_config.chat.text, "time", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp format:", pfUI_config.chat.text, "timeformat")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp brackets:", pfUI_config.chat.text, "timebracket")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp color:", pfUI_config.chat.text, "timecolor")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Left chat height:", pfUI_config.chat.left, "height")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Right chat height:", pfUI_config.chat.right, "height")

  -- nameplates
  pfUI.gui.nameplates = pfUI.gui:CreateConfigTab("Nameplates")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Show castbars:", pfUI_config.nameplates, "showcastbar", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Show debuffs:", pfUI_config.nameplates, "showdebuffs", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Enable Clickthrough:", pfUI_config.nameplates, "clickthrough", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Raidicon size:", pfUI_config.nameplates, "raidiconsize")

  -- thirdparty
  pfUI.gui.thirdparty = pfUI.gui:CreateConfigTab("Thirdparty")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "DPSMate:", pfUI_config.thirdparty.dpsmate, "enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "WIM:", pfUI_config.thirdparty.wim, "enable", "checkbox")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "HealComm:", pfUI_config.thirdparty.healcomm, "enable", "checkbox")

  -- [[ bottom section ]] --

  -- Hide GUI
  pfUI.gui.hideGUI = pfUI.gui:CreateConfigTab("Close", "bottom", function()
    if pfUI.gui.settingChanged then
      pfUI.gui.reloadDialog:Show()
    end
    if pfUI.gitter and pfUI.gitter:IsShown() then pfUI.gui:UnlockFrames() end
    pfUI.gui:Hide()
  end)

  -- Unlock Frames
  pfUI.gui.unlockFrames = pfUI.gui:CreateConfigTab("Unlock", "bottom", function()
      pfUI.gui.UnlockFrames()
  end)

  -- Reset Frames
  pfUI.gui.resetFrames = pfUI.gui:CreateConfigTab("Reset Positions", "bottom", function()
      pfUI_config["position"] = {}
      pfUI.gui.reloadDialog:Show()
  end)

  -- Reset Chat
  pfUI.gui.resetChat = pfUI.gui:CreateConfigTab("Reset Chat", "bottom", function()
      pfUI_init["chat"] = nil
      pfUI.gui.reloadDialog:Show()
  end)

  -- Reset Player Cache
  pfUI.gui.resetCache = pfUI.gui:CreateConfigTab("Reset Player Cache", "bottom", function()
      pfUI_playerDB = {}
      pfUI.gui.reloadDialog:Show()
  end)


  -- Reset All
  pfUI.gui.resetAll = pfUI.gui:CreateConfigTab("Reset All", "bottom", function()
    pfUI_init = {}
    pfUI_config = {}
    pfUI:LoadConfig()
    pfUI.gui.reloadDialog:Show()
  end)

  -- Switch to default View: global
  pfUI.gui:SwitchTab(pfUI.gui.global)
end)
