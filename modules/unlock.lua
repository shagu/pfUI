pfUI:RegisterModule("unlock", function ()
  -- grouped frames
  local clusters = {
    -- Name            Shift  Ctrl
    { "pfCombo",          5       },
    { "pfRaid",           40,   5 },
    { "pfGroup",          4       },
    { "pfLootRollFrame",  4       },
  }

  -- frame labels and their config section relation
  local frame_configs = {
    -- unitframes
    ["Player"]        = { "uf", "player" },
    ["Target"]        = { "uf", "target" },
    ["TargetTarget"]  = { "uf", "ttarget" },
    ["Pet"]           = { "uf", "pet" },
    ["PetTarget"]     = { "uf", "ptarget" },
    ["Focus"]         = { "uf", "focus" },

    -- combopoints
    ["Combo%d"]       = { "uf", "general" },

    -- groupframes
    ["Raid%d"]        = { "gf", "raid" },
    ["Raid%d%d"]      = { "gf", "raid" },
    ["Group%d"]       = { "gf", "group" },
    ["Party%dTarget"] = { "gf", "grouptarget" },
    ["PartyPet%d"]    = { "gf", "grouppet" },

    -- chat
    ["ChatLeft"]      = { "chat", "general" },
    ["ChatRight"]     = { "chat", "general" },
    ["ChatInputBox"]  = { "chat", "general" },

    -- loot
    ["LootRollFrame%d"] = { "loot", "general" },

    -- panel
    ["PanelLeft"]      = { "panel", "general" },
    ["PanelRight"]     = { "panel", "general" },
    ["PanelMinimap"]   = { "panel", "general" },
    ["PanelMicroButton"] = { "panel", "general" },

    -- actionbar
    ["BarActionMain"]  = { "actionbar", "general" },
    ["BarBottomLeft"]  = { "actionbar", "general" },
    ["BarBottomRight"] = { "actionbar", "general" },
    ["BarRight"]       = { "actionbar", "general" },
    ["BarTwoRight"]    = { "actionbar", "general" },
    ["BarShapeShift"]  = { "actionbar", "general" },

    -- castbar
    ["TargetCastbar"]  = { "castbar", "general" },
    ["PlayerCastbar"]  = { "castbar", "general" },

    -- minimap
    ["Minimap"]        = { "minimap", "general" },
    ["UITracking"]     = { "minimap", "general" },

    -- buffs
    ["BuffFrame"]        = { "buffs", "general" },
    ["DebuffFrame"]     = { "buffs", "general" },
  }

  local function GetFrames()
    -- Return frames based on Ctrl and Shift state
    -- 'this'   [frame]       the base frame
    -- return   [list]        all frames that should be selected

    local frame = this.frame
    local frames = { frame }

    if IsShiftKeyDown() or IsControlKeyDown() then
      -- search and add clustered frames
      for id, cluster in pairs(clusters) do
        local len = strlen(cluster[1])
        if strsub(frame:GetName(),0,len) == cluster[1] then
          if IsShiftKeyDown() and cluster[2] then
            for i = 1, cluster[2] do
              if _G[cluster[1] .. i] ~= frame then
                table.insert(frames, _G[cluster[1] .. i])
              end
            end
          elseif IsControlKeyDown() and cluster[3] then
            local id = tonumber(strsub(frame:GetName(),len+1,len+2))

            local b = 1
            for i = cluster[3]+1, cluster[2], cluster[3] do
              b = ( id >= i ) and i or b
            end

            for i = b, b + cluster[3] - 1 do
              if _G[cluster[1] .. i] ~= frame then
                table.insert(frames, _G[cluster[1] .. i])
              end
            end
          end
        end
      end
    end

    return frames
  end

  local function SaveScale(frame, scale)
    frame:SetScale(scale)

    if not C.position[frame:GetName()] then
      C.position[frame:GetName()] = {}
    end
    C.position[frame:GetName()]["scale"] = scale

    frame.drag.text:SetText(T["Scale"] .. ": " .. scale)
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

  local function SavePosition(frame)
    local _, _, _, xpos, ypos = frame:GetPoint()
    if not C.position[frame:GetName()] then
      C.position[frame:GetName()] = {}
    end

    C.position[frame:GetName()]["xpos"] = round(xpos)
    C.position[frame:GetName()]["ypos"] = round(ypos)

    UpdateMovable(frame)
  end

  local function DrawGrid()
    local grid = CreateFrame("Frame", this:GetName() .. "Grid", pfUI.unlock)
    grid:SetAllPoints(this)

    local size = 1
    local line = {}

    local width = GetScreenWidth()
    local height = GetScreenHeight()

    local ratio = width / GetScreenHeight()
    local rheight = GetScreenHeight() * ratio

    local wStep = width / 128
    local hStep = rheight / 128

    -- vertical lines
    for i = 0, 128 do
      if i == 128 / 2 then
        line = grid:CreateTexture(nil, 'BORDER')
        line:SetTexture(.1, .5, .4)
      else
        line = grid:CreateTexture(nil, 'BACKGROUND')
        line:SetTexture(0, 0, 0, .5)
      end
      line:SetPoint("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0)
      line:SetPoint('BOTTOMRIGHT', grid, 'BOTTOMLEFT', i*wStep + (size/2), 0)
    end

    -- horizontal lines
    for i = 1, floor(height/hStep) do
      if i == floor(height/hStep / 2) then
        line = grid:CreateTexture(nil, 'BORDER')
        line:SetTexture(.1, .5, .4)
      else
        line = grid:CreateTexture(nil, 'BACKGROUND')
        line:SetTexture(0, 0, 0)
      end

      line:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(i*hStep) + (size/2))
      line:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(i*hStep + size/2))
    end

    return grid
  end

  local function GetConfigTable(dlabel)
    local cat, conf = nil, nil
    for label, config in pairs(frame_configs) do
      if string.gsub(dlabel, label, "") == "" then
        cat, conf = config[1], config[2]
      end
    end

    return cat, conf
  end

  local function OpenConfigDialog(category, view)
    if pfUI.gui.tabs[category] and pfUI.gui.tabs[category].tabs[view] then
      pfUI.gui:Show()
      pfUI.gui.tabs[category].button:Click()
      pfUI.gui.tabs[category].tabs[view].button:Click()
    end
  end

  local function UpdateDockValues()
    if not pfUI.unlock.dock:IsShown() then return end

    local dock = pfUI.unlock.dock
    local drag = dock.parent
    local frame = drag.frame

    -- update dock position
    SetAutoPoint(dock, drag, tonumber(pfUI_config.appearance.border.default)*2+2)

    -- update dock entries
    dock.title:SetText(drag.label)
    if pfUI_config["position"] and pfUI_config["position"][drag.fname] and pfUI_config["position"][drag.fname]["xpos"] then
      dock.xcoord:SetText(pfUI_config["position"][drag.fname]["xpos"])
      dock.ycoord:SetText(pfUI_config["position"][drag.fname]["ypos"])
      dock.reset:SetText(T["Reset"])

      dock.up:Enable()
      dock.down:Enable()
      dock.left:Enable()
      dock.right:Enable()

      dock.up.texture:SetVertexColor(1,.8,0)
      dock.down.texture:SetVertexColor(1,.8,0)
      dock.left.texture:SetVertexColor(1,.8,0)
      dock.right.texture:SetVertexColor(1,.8,0)
    else
      dock.reset:SetText(T["Unlock"])
      dock.xcoord:SetText(T["N/A"])
      dock.ycoord:SetText(T["N/A"])

      dock.up:Disable()
      dock.down:Disable()
      dock.left:Disable()
      dock.right:Disable()

      dock.up.texture:SetVertexColor(.4,.4,.4)
      dock.down.texture:SetVertexColor(.4,.4,.4)
      dock.left.texture:SetVertexColor(.4,.4,.4)
      dock.right.texture:SetVertexColor(.4,.4,.4)
    end

    -- update config button
    local cat, conf = GetConfigTable(drag.label)
    if cat and conf then
      dock.config:Enable()
    else
      dock.config:Disable()
    end
  end

  local function SetDockToFrame(frame)
    if pfUI.unlock.dock.parent then
      -- reset previous border color
      CreateBackdrop(pfUI.unlock.dock.parent, nil, nil, .8)
    end

    -- add the new frame
    pfUI.unlock.dock.parent = frame

    if frame then
      pfUI.unlock.dock.parent.backdrop:SetBackdropBorderColor(.2,1,.8,1)
      pfUI.unlock.dock:Show()
      UpdateDockValues()
    else
      pfUI.unlock.dock:Hide()
    end
  end

  local function DraggerOnMouseWheel()
    local frame = this.frame
    local scale = round(frame:GetScale() + arg1/10, 1)

    pfUI.unlock.selection = GetFrames()
    for id, frame in pairs(pfUI.unlock.selection) do
      SaveScale(frame, scale)
    end

    -- repaint hackfix for panels
    if pfUI.panel and pfUI.chat then
      pfUI.panel.left:SetScale(pfUI.chat.left:GetScale())
      pfUI.panel.right:SetScale(pfUI.chat.right:GetScale())
    end

    if frame.OnMove then frame:OnMove() end
    QueueFunction(UpdateDockValues)
  end

  local function DraggerOnMouseDown()
    if arg1 == "MiddleButton" then return end
    if arg1 == "RightButton" then
      if pfUI.unlock.dock.parent == this and pfUI.unlock.dock:IsShown() then
        SetDockToFrame(nil)
      else
        SetDockToFrame(this)
      end
      return
    end
    local frame = this.frame

    pfUI.unlock.selection = GetFrames()

    for id, frame in pairs(pfUI.unlock.selection) do
      frame:StartMoving()
      frame:StopMovingOrSizing()
      frame.drag.backdrop:SetBackdropBorderColor(.2,1,.8,1)
    end

    local _, _, _, xpos, ypos = frame:GetPoint()
    frame.oldPos = { xpos, ypos }
    frame:StartMoving()

    if frame.OnMove then frame:OnMove() end
  end

  local function DraggerOnMouseUp()
    if arg1 == "MiddleButton" then return end
    if arg1 == "RightButton" then return end

    local frame = this.frame
    local name = this.fname

    frame:StopMovingOrSizing()

    local _, _, _, xpos, ypos = frame:GetPoint()
    local diffxpos = frame.oldPos[1] - xpos
    local diffypos = frame.oldPos[2] - ypos

    for id, frame in pairs(pfUI.unlock.selection) do
      CreateBackdrop(frame.drag, nil, nil, .8)
      if frame:GetName() ~= name then
        local _, _, _, xpos, ypos = frame:GetPoint()
        frame:SetPoint("TOPLEFT", xpos - diffxpos, ypos - diffypos)
      end
      SavePosition(frame)
    end

    this.backdrop:SetBackdropBorderColor(1,1,1,1)
    UpdateDockValues()
  end

  local function DraggerOnClick()
    pfUI.unlock.selection = GetFrames()
    for id, frame in pairs(pfUI.unlock.selection) do
      pfUI_config["position"][frame:GetName()] = nil
      frame:ClearAllPoints()
      UpdateMovable(frame)
    end
    UpdateDockValues()
  end

  local function DraggerOnEnter()
    if pfUI.unlock.dock.parent ~= this then
      this.backdrop:SetBackdropBorderColor(1,1,1,1)
    end
  end

  local function DraggerOnLeave()
    if pfUI.unlock.dock.parent ~= this then
      CreateBackdrop(this, nil, nil, .8)
    end
  end

  local function CreateDragger(f)
    local fname = f:GetName()
    local label = string.sub(fname, 1, 2) == "pf" and strsub(fname,3) or fname

    local d = CreateFrame("Button", fname .. "Drag", f)
    d:RegisterForClicks("MiddleButtonUp")
    d:SetAllPoints(f)
    d:SetFrameStrata("DIALOG")
    d:SetAlpha(1)
    d:EnableMouseWheel(1)

    d.text = d:CreateFontString("Status", "LOW", "GameFontNormal")
    d.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
    d.text:ClearAllPoints()
    d.text:SetAllPoints(d)
    d.text:SetPoint("CENTER", 0, 0)
    d.text:SetFontObject(GameFontWhite)

    d.frame = f
    d.fname = fname
    d.label = label

    if d:GetHeight() > (2 * d:GetWidth()) then
      label = strvertical(label)
    end

    d.text:SetText(label)

    d:SetScript("OnMouseWheel", DraggerOnMouseWheel)
    d:SetScript("OnMouseDown", DraggerOnMouseDown)
    d:SetScript("OnMouseUp", DraggerOnMouseUp)
    d:SetScript("OnClick", DraggerOnClick)
    d:SetScript("OnEnter", DraggerOnEnter)
    d:SetScript("OnLeave", DraggerOnLeave)

    CreateBackdrop(d, nil, nil, .8)
    return d
  end

  table.insert(UISpecialFrames, "pfUnlock")
  pfUI.unlock = CreateFrame("Button", "pfUnlock", UIParent)
  pfUI.unlock.selection = {}
  pfUI.unlock:Hide()
  pfUI.unlock:SetAllPoints(WorldFrame)
  pfUI.unlock:SetFrameStrata("BACKGROUND")
  pfUI.unlock:SetScript("OnClick", function()
    this:Hide()
  end)

  pfUI.unlock:SetScript("OnShow", function()
    this.grid = this.grid or DrawGrid()

    for name, frame in pairs(pfUI.movables) do
      local frame = frame or _G[name]

      if not frame:IsShown() then frame.hideLater = true end
      frame.drag = frame.drag or CreateDragger(frame)
      frame:SetMovable(true)
      frame.drag:Show()
      frame:Show()
    end

    local txt = T["|cff33ffccUnlock Mode|r\nThis mode allows you to move frames by dragging them using the mouse cursor. Frames can be scaled by scrolling up and down.\nTo scale multiple frames at once (eg. raidframes), hold down the shift key while scrolling. Click into an empty space to go back to the pfUI menu."]
    CreateInfoBox(txt, 15, pfUI.unlock)
    pfUI.gui:Hide()
  end)

  pfUI.unlock:SetScript("OnHide", function()
    for name, frame in pairs(pfUI.movables) do
      local frame = frame or _G[name]

      if frame.hideLater == true then frame:Hide() end
      frame:StopMovingOrSizing()
      frame:SetMovable(false)
      frame.drag:Hide()
      UpdateMovable(frame)
    end

    SetDockToFrame(nil)
    pfUI.unlock:Hide()
    pfUI.gui:Show()
  end)

  -- dock frame
  pfUI.unlock.dock = CreateFrame("Button", "pfUnlockDock", pfUI.unlock)
  pfUI.unlock.dock:SetWidth(140)
  pfUI.unlock.dock:SetHeight(140)
  pfUI.unlock.dock:SetFrameStrata("FULLSCREEN_DIALOG")
  pfUI.unlock.dock:Hide()
  CreateBackdrop(pfUI.unlock.dock)

  -- title
  pfUI.unlock.dock.title = pfUI.unlock.dock:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.unlock.dock.title:SetTextColor(1,1,1,1)
  pfUI.unlock.dock.title:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
  pfUI.unlock.dock.title:SetJustifyH("left")
  pfUI.unlock.dock.title:SetPoint("TOP", 0, -5)

  -- x coordinates
  pfUI.unlock.dock.xcoordcap = pfUI.unlock.dock:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.unlock.dock.xcoordcap:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
  pfUI.unlock.dock.xcoordcap:SetJustifyH("LEFT")
  pfUI.unlock.dock.xcoordcap:SetPoint("TOPLEFT", 5, -33)
  pfUI.unlock.dock.xcoordcap:SetText("X:")
  pfUI.unlock.dock.xcoord = CreateFrame("EditBox", nil, pfUI.unlock.dock)
  pfUI.unlock.dock.xcoord:SetTextInsets(5, 5, 5, 5)
  pfUI.unlock.dock.xcoord:SetJustifyH("CENTER")
  pfUI.unlock.dock.xcoord:SetWidth(45)
  pfUI.unlock.dock.xcoord:SetHeight(18)
  pfUI.unlock.dock.xcoord:SetPoint("TOPLEFT", pfUI.unlock.dock, "TOPLEFT", 20, -30)
  pfUI.unlock.dock.xcoord:SetFontObject(GameFontNormal)
  pfUI.unlock.dock.xcoord:SetAutoFocus(false)

  pfUI.unlock.dock.xcoord:SetScript("OnEscapePressed", function(self)
    if tonumber(this:GetText()) then
      local frame = pfUI.unlock.dock.parent.frame
      local xpos = tonumber(pfUI.unlock.dock.xcoord:GetText())
      local ypos = tonumber(pfUI.unlock.dock.ycoord:GetText())

      frame:SetPoint("TOPLEFT", xpos, ypos)
      SavePosition(frame)
    else
      UpdateDockValues()
    end
    this:ClearFocus()
  end)

  pfUI.unlock.dock.xcoord:SetScript("OnTextChanged", function(self)
    if tonumber(this:GetText()) then
      this:SetTextColor(1,1,1,1)
    else
      this:SetTextColor(1,.3,.3,1)
    end
  end)

  CreateBackdrop(pfUI.unlock.dock.xcoord, nil, true)

  -- y coordinates
  pfUI.unlock.dock.ycoordcap = pfUI.unlock.dock:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.unlock.dock.ycoordcap:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
  pfUI.unlock.dock.ycoordcap:SetText("Y:")
  pfUI.unlock.dock.ycoordcap:SetJustifyH("LEFT")
  pfUI.unlock.dock.ycoordcap:SetPoint("TOPLEFT", 75, -33)
  pfUI.unlock.dock.ycoord = CreateFrame("EditBox", nil, pfUI.unlock.dock)
  pfUI.unlock.dock.ycoord:SetTextInsets(5, 5, 5, 5)
  pfUI.unlock.dock.ycoord:SetJustifyH("CENTER")
  pfUI.unlock.dock.ycoord:SetWidth(45)
  pfUI.unlock.dock.ycoord:SetHeight(18)
  pfUI.unlock.dock.ycoord:SetPoint("TOPLEFT", pfUI.unlock.dock, "TOPLEFT", 90, -30)
  pfUI.unlock.dock.ycoord:SetFontObject(GameFontNormal)
  pfUI.unlock.dock.ycoord:SetAutoFocus(false)

  pfUI.unlock.dock.ycoord:SetScript("OnEscapePressed", function(self)
    if tonumber(this:GetText()) then
      local frame = pfUI.unlock.dock.parent.frame
      local xpos = tonumber(pfUI.unlock.dock.xcoord:GetText())
      local ypos = tonumber(pfUI.unlock.dock.ycoord:GetText())

      frame:SetPoint("TOPLEFT", xpos, ypos)
      SavePosition(frame)
    else
      UpdateDockValues()
    end
    this:ClearFocus()
  end)

  pfUI.unlock.dock.ycoord:SetScript("OnTextChanged", function(self)
    if tonumber(this:GetText()) then
      this:SetTextColor(1,1,1,1)
    else
      this:SetTextColor(1,.3,.3,1)
    end
  end)

  CreateBackdrop(pfUI.unlock.dock.ycoord, nil, true)

  -- reset button
  pfUI.unlock.dock.reset = CreateFrame("Button", "pfDragDockReset", pfUI.unlock.dock, "UIPanelButtonTemplate")
  pfUI.unlock.dock.reset:SetHeight(18)
  pfUI.unlock.dock.reset:SetPoint("TOPLEFT", 5, -55)
  pfUI.unlock.dock.reset:SetPoint("TOPRIGHT", -5, -55)
  pfUI.unlock.dock.reset:SetScript("OnClick", function()
    local frame = pfUI.unlock.dock.parent.frame

    if this:GetText() == T["Reset"] then
      pfUI_config["position"][frame:GetName()] = nil
      frame:ClearAllPoints()
      UpdateMovable(frame)
    else
      frame:StartMoving()
      frame:StopMovingOrSizing()
      SavePosition(frame)
    end
    QueueFunction(SetDockToFrame, pfUI.unlock.dock.parent)
  end)
  SkinButton(pfUI.unlock.dock.reset,.2,1,.8)

  -- move left
  pfUI.unlock.dock.left = CreateFrame("Button", "pfDragDockPosUp", pfUI.unlock.dock, "UIPanelButtonTemplate")
  pfUI.unlock.dock.left:SetHeight(18)
  pfUI.unlock.dock.left:SetWidth(18)
  pfUI.unlock.dock.left:SetPoint("TOP", -50, -80)
  pfUI.unlock.dock.left.texture = pfUI.unlock.dock.left:CreateTexture("arrow")
  pfUI.unlock.dock.left.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\left")
  pfUI.unlock.dock.left.texture:ClearAllPoints()
  pfUI.unlock.dock.left.texture:SetPoint("TOPLEFT", pfUI.unlock.dock.left, "TOPLEFT", 4, -2)
  pfUI.unlock.dock.left.texture:SetPoint("BOTTOMRIGHT", pfUI.unlock.dock.left, "BOTTOMRIGHT", -4, 2)
  pfUI.unlock.dock.left:SetScript("OnClick", function()
    local frame = pfUI.unlock.dock.parent.frame
    local _, _, _, xpos, ypos = frame:GetPoint()
    frame:SetPoint("TOPLEFT", xpos - 1, ypos)
    SavePosition(frame)
    UpdateDockValues()
  end)
  SkinButton(pfUI.unlock.dock.left,.2,1,.8)

  -- move right
  pfUI.unlock.dock.right = CreateFrame("Button", "pfDragDockPosUp", pfUI.unlock.dock, "UIPanelButtonTemplate")
  pfUI.unlock.dock.right:SetHeight(18)
  pfUI.unlock.dock.right:SetWidth(18)
  pfUI.unlock.dock.right:SetPoint("TOP", -25, -80)
  pfUI.unlock.dock.right.texture = pfUI.unlock.dock.right:CreateTexture("arrow")
  pfUI.unlock.dock.right.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\right")
  pfUI.unlock.dock.right.texture:ClearAllPoints()
  pfUI.unlock.dock.right.texture:SetPoint("TOPLEFT", pfUI.unlock.dock.right, "TOPLEFT", 4, -2)
  pfUI.unlock.dock.right.texture:SetPoint("BOTTOMRIGHT", pfUI.unlock.dock.right, "BOTTOMRIGHT", -4, 2)
  pfUI.unlock.dock.right:SetScript("OnClick", function()
    local frame = pfUI.unlock.dock.parent.frame
    local _, _, _, xpos, ypos = frame:GetPoint()
    frame:SetPoint("TOPLEFT", xpos + 1, ypos)
    SavePosition(frame)
    UpdateDockValues()
  end)
  SkinButton(pfUI.unlock.dock.right,.2,1,.8)

  -- move up
  pfUI.unlock.dock.up = CreateFrame("Button", "pfDragDockPosUp", pfUI.unlock.dock, "UIPanelButtonTemplate")
  pfUI.unlock.dock.up:SetHeight(18)
  pfUI.unlock.dock.up:SetWidth(18)
  pfUI.unlock.dock.up:SetPoint("TOP", 25, -80)
  pfUI.unlock.dock.up.texture = pfUI.unlock.dock.up:CreateTexture("arrow")
  pfUI.unlock.dock.up.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\up")
  pfUI.unlock.dock.up.texture:ClearAllPoints()
  pfUI.unlock.dock.up.texture:SetPoint("TOPLEFT", pfUI.unlock.dock.up, "TOPLEFT", 4, -2)
  pfUI.unlock.dock.up.texture:SetPoint("BOTTOMRIGHT", pfUI.unlock.dock.up, "BOTTOMRIGHT", -4, 2)
  pfUI.unlock.dock.up:SetScript("OnClick", function()
    local frame = pfUI.unlock.dock.parent.frame
    local _, _, _, xpos, ypos = frame:GetPoint()
    frame:SetPoint("TOPLEFT", xpos, ypos + 1)
    SavePosition(frame)
    UpdateDockValues()
  end)
  SkinButton(pfUI.unlock.dock.up,.2,1,.8)

  -- move down
  pfUI.unlock.dock.down = CreateFrame("Button", "pfDragDockPosUp", pfUI.unlock.dock, "UIPanelButtonTemplate")
  pfUI.unlock.dock.down:SetHeight(18)
  pfUI.unlock.dock.down:SetWidth(18)
  pfUI.unlock.dock.down:SetPoint("TOP", 50, -80)
  pfUI.unlock.dock.down.texture = pfUI.unlock.dock.down:CreateTexture("arrow")
  pfUI.unlock.dock.down.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\down")
  pfUI.unlock.dock.down.texture:ClearAllPoints()
  pfUI.unlock.dock.down.texture:SetPoint("TOPLEFT", pfUI.unlock.dock.down, "TOPLEFT", 4, -2)
  pfUI.unlock.dock.down.texture:SetPoint("BOTTOMRIGHT", pfUI.unlock.dock.down, "BOTTOMRIGHT", -4, 2)
  pfUI.unlock.dock.down:SetScript("OnClick", function()
    local frame = pfUI.unlock.dock.parent.frame
    local _, _, _, xpos, ypos = frame:GetPoint()
    frame:SetPoint("TOPLEFT", xpos, ypos - 1)
    SavePosition(frame)
    UpdateDockValues()
  end)
  SkinButton(pfUI.unlock.dock.down,.2,1,.8)

  -- open config
  pfUI.unlock.dock.config = CreateFrame("Button", "pfDragDockConfigOpen", pfUI.unlock.dock, "UIPanelButtonTemplate")
  pfUI.unlock.dock.config:SetHeight(18)
  pfUI.unlock.dock.config:SetPoint("BOTTOMLEFT", 5, 5)
  pfUI.unlock.dock.config:SetPoint("BOTTOMRIGHT", -5, 5)
  pfUI.unlock.dock.config:SetText(T["Configure"])
  pfUI.unlock.dock.config:SetScript("OnClick", function()
    local cat, conf = GetConfigTable(pfUI.unlock.dock.parent.label)
    if cat and conf then OpenConfigDialog(cat, conf) end
  end)
  SkinButton(pfUI.unlock.dock.config,.2,1,.8)
end)
