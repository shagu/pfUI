pfUI:RegisterModule("gui", function ()
  pfUI.gui = CreateFrame("Frame",nil,UIParent)

  pfUI.gui:RegisterEvent("PLAYER_ENTERING_WORLD");

  pfUI.gui:SetFrameStrata("DIALOG")
  pfUI.gui:SetWidth(480)
  pfUI.gui:SetHeight(320)
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

  function pfUI.gui.SwitchTab(frame)
    local elements = { pfUI.gui.global, pfUI.gui.uf }
    for _, hide in pairs(elements) do
      hide:Hide()
    end
    frame:Show()
  end

  function pfUI.gui.CreateConfig(parent, caption, category, config)
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
    frame.caption:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 12, "OUTLINE")
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
      this:GetParent().category[this:GetParent().config] = this:GetText()
      this:ClearFocus()
    end)

    return frame
  end

  function pfUI.gui.UnlockFrames()
    -- don't call it "grid" to avoid confusion with grid (addon) module
    pfUI.gitter = CreateFrame("Frame", nil, UIParent)
    pfUI.gitter:SetFrameStrata("BACKGROUND")
    pfUI.gitter:SetPoint("TOPLEFT", 0, 0, "TOPLEFT")
    pfUI.gitter:SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT")
    pfUI.gitter:SetBackdrop(pfUI.backdrop_gitter)
    pfUI.gitter:SetBackdropColor(0,0,0,1)

    local movable = { pfUI.minimap, pfUI.chat.left, pfUI.chat.right,
      pfUI.uf.player, pfUI.uf.target, pfUI.uf.targettarget, pfUI.uf.pet,
      pfUI.bars.shapeshift, pfUI.bars.bottomleft, pfUI.bars.bottomright,
      pfUI.bars.vertical, pfUI.bars.pet, pfUI.bars.bottom }

    for _,frame in pairs(movable) do
      local frame = frame
      frame:Show()
      frame:SetMovable(true)

      frame.drag = CreateFrame("Frame", nil, frame)
      frame.drag:SetAllPoints(frame)
      frame.drag:SetFrameStrata("DIALOG")
      frame.drag.bg = frame.drag:CreateTexture()
      frame.drag.bg:SetAllPoints(frame.drag)
      frame.drag.bg:SetTexture(.2,1,.8,1)
      frame.drag:SetAlpha(.25)
      frame.drag:EnableMouse(true)

      frame.drag:SetScript("OnMouseDown",function()
          frame:StartMoving()
        end)

      frame.drag:SetScript("OnMouseUp",function()
          frame:StopMovingOrSizing()
        end)
    end
  end

  -- Global Settings
  pfUI.gui.global = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.global:SetWidth(400)
  pfUI.gui.global:SetHeight(320)

  pfUI.gui.global:SetBackdrop(pfUI.backdrop)
  pfUI.gui.global:SetBackdropColor(0,0,0,.50);
  pfUI.gui.global:SetPoint("RIGHT",0,0)

  pfUI.gui.global.switch = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.global.switch:ClearAllPoints()
  pfUI.gui.global.switch:SetWidth(80)
  pfUI.gui.global.switch:SetHeight(20)
  pfUI.gui.global.switch:SetPoint("TOPLEFT", 0, 0)
  pfUI.gui.global.switch:SetBackdrop(pfUI.backdrop)
  pfUI.gui.global.switch.text = pfUI.gui.global.switch:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.global.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 9, "OUTLINE")
  pfUI.gui.global.switch.text:ClearAllPoints()
  pfUI.gui.global.switch.text:SetAllPoints(pfUI.gui.global.switch)
  pfUI.gui.global.switch.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.global.switch.text:SetFontObject(GameFontWhite)
  pfUI.gui.global.switch.text:SetText("Global")
  pfUI.gui.global.switch:SetScript("OnClick", function()
      pfUI.gui.SwitchTab(pfUI.gui.global)
    end)

  pfUI.gui.global.title = pfUI.gui.global:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.global.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 12, "OUTLINE")
  pfUI.gui.global.title:SetPoint("TOP", 0, -10)
  pfUI.gui.global.title:SetFontObject(GameFontWhite)
  pfUI.gui.global.title:SetText("Global Settings")

  -- UnitFrame settings
  pfUI.gui.uf = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.uf:SetWidth(400)
  pfUI.gui.uf:SetHeight(320)

  pfUI.gui.uf:SetBackdrop(pfUI.backdrop)
  pfUI.gui.uf:SetBackdropColor(0,0,0,.50);
  pfUI.gui.uf:SetPoint("RIGHT",0,0)

  pfUI.gui.uf.switch = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.uf.switch:ClearAllPoints()
  pfUI.gui.uf.switch:SetWidth(80)
  pfUI.gui.uf.switch:SetHeight(20)
  pfUI.gui.uf.switch:SetPoint("TOPLEFT", 0, -20)
  pfUI.gui.uf.switch:SetBackdrop(pfUI.backdrop)
  pfUI.gui.uf.switch.text = pfUI.gui.uf.switch:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.uf.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 9, "OUTLINE")
  pfUI.gui.uf.switch.text:ClearAllPoints()
  pfUI.gui.uf.switch.text:SetAllPoints(pfUI.gui.uf.switch)
  pfUI.gui.uf.switch.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.uf.switch.text:SetFontObject(GameFontWhite)
  pfUI.gui.uf.switch.text:SetText("UnitFrames")
  pfUI.gui.uf.switch:SetScript("OnClick", function()
      pfUI.gui.SwitchTab(pfUI.gui.uf)
    end)

  pfUI.gui.uf.title = pfUI.gui.uf:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.uf.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 12, "OUTLINE")
  pfUI.gui.uf.title:SetPoint("TOP", 0, -10)
  pfUI.gui.uf.title:SetFontObject(GameFontWhite)
  pfUI.gui.uf.title:SetText("UnitFrame Settings")

  pfUI.gui.CreateConfig(pfUI.gui.uf, "Animation speed", pfUI_config.unitframes, "animation_speed")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Buff size", pfUI_config.unitframes, "buff_size")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Debuff size", pfUI_config.unitframes, "debuff_size")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Layout", pfUI_config.unitframes, "layout")

  pfUI.gui.CreateConfig(pfUI.gui.uf, "Player width", pfUI_config.unitframes.player, "width")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Player height", pfUI_config.unitframes.player, "height")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Player powerbar height", pfUI_config.unitframes.player, "pheight")

  pfUI.gui.CreateConfig(pfUI.gui.uf, "Target width", pfUI_config.unitframes.target, "width")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Target height", pfUI_config.unitframes.target, "height")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Target powerbar height", pfUI_config.unitframes.target, "pheight")


  -- Unlock Frames
  pfUI.gui.unlockFrames = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.unlockFrames:ClearAllPoints()
  pfUI.gui.unlockFrames:SetWidth(80)
  pfUI.gui.unlockFrames:SetHeight(20)
  pfUI.gui.unlockFrames:SetPoint("BOTTOMLEFT", 0, 0)
  pfUI.gui.unlockFrames:SetBackdrop(pfUI.backdrop)
  pfUI.gui.unlockFrames.text = pfUI.gui.unlockFrames:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.unlockFrames.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 9, "OUTLINE")
  pfUI.gui.unlockFrames.text:ClearAllPoints()
  pfUI.gui.unlockFrames.text:SetAllPoints(pfUI.gui.unlockFrames)
  pfUI.gui.unlockFrames.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.unlockFrames.text:SetFontObject(GameFontWhite)
  pfUI.gui.unlockFrames.text:SetText("Unlock Frames")
  pfUI.gui.unlockFrames:SetScript("OnClick", function()
      pfUI.gui.UnlockFrames()
    end)

  -- Switch to default View: global
  pfUI.gui.SwitchTab(pfUI.gui.global)
end)
