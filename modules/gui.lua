pfUI:RegisterModule("gui", function ()
  pfUI.gui = CreateFrame("Frame",nil,UIParent)

  pfUI.gui:RegisterEvent("PLAYER_ENTERING_WORLD");

  pfUI.gui:SetFrameStrata("DIALOG")
  pfUI.gui:SetWidth(480)
  pfUI.gui:SetHeight(420)
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
  pfUI.gui.reloadDialog.yes:SetHeight(20) -- width, height
  pfUI.gui.reloadDialog.yes:SetPoint("BOTTOMLEFT", 20,15)
  pfUI.gui.reloadDialog.yes:SetText("Yes")
  pfUI.gui.reloadDialog.yes:SetScript("OnClick", function()
    pfUI.gui.settingChanged = nil
    ReloadUI();
  end)

  pfUI.gui.reloadDialog.no = CreateFrame("Button", "pfReloadNo", pfUI.gui.reloadDialog, "UIPanelButtonTemplate")
  pfUI.gui.reloadDialog.no:SetWidth(100)
  pfUI.gui.reloadDialog.no:SetHeight(20) -- width, height
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
      }

    if not pfUI.gitter then
      pfUI.gitter = CreateFrame("Frame", nil, UIParent)
      pfUI.gitter:SetAllPoints(WorldFrame)
      pfUI.gitter:SetFrameStrata("BACKGROUND")

      local size = 1
      local width = GetScreenWidth()
      local ratio = width / GetScreenHeight()
      local height = GetScreenHeight() * ratio

      local wStep = width / 128
      local hStep = height / 128

      for i = 0, 128 do
        local tx = pfUI.gitter:CreateTexture(nil, 'BACKGROUND')
        if i == 128 / 2 then
          tx:SetTexture(.2, 1, .8)
        else
          tx:SetTexture(0, 0, 0)
        end
        tx:SetPoint("TOPLEFT", pfUI.gitter, "TOPLEFT", i*wStep - (size/2), 0)
        tx:SetPoint('BOTTOMRIGHT', pfUI.gitter, 'BOTTOMLEFT', i*wStep + (size/2), 0)
      end

      local height = GetScreenHeight()

      for i = 0, 128 do
        local tx = pfUI.gitter:CreateTexture(nil, 'BACKGROUND')
        tx:SetTexture(.2, 1, .8)
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

    if pfUI.gitter:IsShown() then
      pfUI.gitter:Hide()
    else
      pfUI.gitter:Show()
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
        frame.drag.text = frame.drag:CreateFontString("Status", "LOW", "GameFontNormal")
        frame.drag.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
        frame.drag.text:ClearAllPoints()
        frame.drag.text:SetAllPoints(frame.drag)
        frame.drag.text:SetPoint("CENTER", 0, 0)
        frame.drag.text:SetFontObject(GameFontWhite)
        frame.drag.text:SetText(strsub(frame:GetName(),3))
        frame.drag:SetAlpha(1)
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
    local elements = { pfUI.gui.global, pfUI.gui.uf , pfUI.gui.bar, pfUI.gui.panel, pfUI.gui.tooltip,
                       pfUI.gui.castbar, pfUI.gui.thirdparty, pfUI.gui.chat, pfUI.gui.nameplates }

    for _, hide in pairs(elements) do
      hide:Hide()
    end
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
    frame:SetWidth(400)
    frame:SetHeight(420)

    frame:SetBackdrop(pfUI.backdrop)
    frame:SetBackdropColor(0,0,0,.50);
    frame:SetPoint("RIGHT",0,0)

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

  function pfUI.gui:CreateConfig(parent, caption, category, config)
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

    -- input field
    frame.input = CreateFrame("EditBox", nil, frame)
    frame.input:SetTextColor(.2,1.1,1)
    frame.input:SetJustifyH("RIGHT")

    frame.input:SetWidth(100)
    frame.input:SetHeight(20)
    frame.input:SetPoint("TOPRIGHT" , 0, 0)
    frame.input:SetFontObject(GameFontNormal)
    frame.input:SetAutoFocus(false)
    frame.input:SetText(category[config])
    frame.category = category
    frame.config = config
    frame.input:SetScript("OnEscapePressed", function(self)
      this:ClearFocus()
    end)

    frame.input:SetScript("OnEditFocusLost", function(self)
      this:GetParent().category[this:GetParent().config] = this:GetText()
      pfUI.gui.settingChanged = true
    end)

    return frame
  end

  -- [[ config section ]] --

  -- global
  pfUI.gui.global = pfUI.gui:CreateConfigTab("Global Settings")
  pfUI.gui:CreateConfig(pfUI.gui.global, "Fontsize", pfUI_config.global, "font_size")

  -- unitframes
  pfUI.gui.uf = pfUI.gui:CreateConfigTab("UnitFrame Settings")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Animation speed", pfUI_config.unitframes, "animation_speed")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Show portrait", pfUI_config.unitframes, "portrait")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Buff size", pfUI_config.unitframes, "buff_size")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Debuff size", pfUI_config.unitframes, "debuff_size")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Layout", pfUI_config.unitframes, "layout")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Player width", pfUI_config.unitframes.player, "width")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Player height", pfUI_config.unitframes.player, "height")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Player powerbar height", pfUI_config.unitframes.player, "pheight")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Target width", pfUI_config.unitframes.target, "width")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Target height", pfUI_config.unitframes.target, "height")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Target powerbar height", pfUI_config.unitframes.target, "pheight")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe", pfUI_config.unitframes.raid, "clickcast")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe (Shift)", pfUI_config.unitframes.raid, "clickcast_shift")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe (Alt)", pfUI_config.unitframes.raid, "clickcast_alt")
  pfUI.gui:CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe (Ctrl)", pfUI_config.unitframes.raid, "clickcast_ctrl")

  -- actionbar
  pfUI.gui.bar = pfUI.gui:CreateConfigTab("ActionBar Settings")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Icon Size", pfUI_config.bars, "icon_size")
  pfUI.gui:CreateConfig(pfUI.gui.bar, "Border", pfUI_config.bars, "border")

  -- panels
  pfUI.gui.panel = pfUI.gui:CreateConfigTab("Panel Settings")
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Left Panel: Left", pfUI_config.panel.left, "left")
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Left Panel: Center", pfUI_config.panel.left, "center")
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Left Panel: Right", pfUI_config.panel.left, "right")
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Right Panel: Left", pfUI_config.panel.right, "left")
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Right Panel: Center", pfUI_config.panel.right, "center")
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Right Panel: Right", pfUI_config.panel.right, "right")
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Other Panel: Minimap", pfUI_config.panel.other, "minimap")
  pfUI.gui:CreateConfig(pfUI.gui.panel, "Always show XP and Reputation Bar", pfUI_config.panel.xp, "showalways")

  -- tooltip
  pfUI.gui.tooltip = pfUI.gui:CreateConfigTab("Tooltip Settings")
  pfUI.gui:CreateConfig(pfUI.gui.tooltip, "Tooltip Position:", pfUI_config.tooltip, "position")

  -- castbar
  pfUI.gui.castbar = pfUI.gui:CreateConfigTab("Castbar Settings")
  pfUI.gui:CreateConfig(pfUI.gui.castbar, "Hide blizzards castbar:", pfUI_config.castbar.player, "hide_blizz")

  -- chat
  pfUI.gui.chat = pfUI.gui:CreateConfigTab("Chat Settings")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp in chat:", pfUI_config.chat.text, "time")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp format:", pfUI_config.chat.text, "timeformat")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp brackets:", pfUI_config.chat.text, "timebracket")
  pfUI.gui:CreateConfig(pfUI.gui.chat, "Timestamp color:", pfUI_config.chat.text, "timecolor")

  -- nameplates
  pfUI.gui.nameplates = pfUI.gui:CreateConfigTab("Nameplate Settings")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Show castbars:", pfUI_config.nameplates, "showcastbar")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Show debuffs:", pfUI_config.nameplates, "showdebuffs")
  pfUI.gui:CreateConfig(pfUI.gui.nameplates, "Enable Clickthrough:", pfUI_config.nameplates, "clickthrough")

  -- thirdparty
  pfUI.gui.thirdparty = pfUI.gui:CreateConfigTab("Thirdparty Addons")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "DPSMate:", pfUI_config.thirdparty.dpsmate, "enable")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "WIM:", pfUI_config.thirdparty.wim, "enable")
  pfUI.gui:CreateConfig(pfUI.gui.thirdparty, "HealComm:", pfUI_config.thirdparty.healcomm, "enable")

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
  pfUI.gui.unlockFrames = pfUI.gui:CreateConfigTab("Unlock Frames", "bottom", function()
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
