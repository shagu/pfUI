pfUI:RegisterModule("unlock", function ()
  local clusters = {
    -- Name            Shift  Ctrl
    { "pfCombo",          5       },
    { "pfRaid",           40,   5 },
    { "pfGroup",          4       },
    { "pfLootRollFrame",  4       },
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
    local grid = CreateFrame("Frame", this:GetName() .. "Grid", this)
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
  end

  local function DraggerOnMouseDown()
    if arg1 == "MiddleButton" then return end
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
    pfUI.unlock.settingChanged = true
  end

  local function DraggerOnClick()
    pfUI.unlock.selection = GetFrames()
    for id, frame in pairs(pfUI.unlock.selection) do
      pfUI_config["position"][frame:GetName()] = nil
      frame:ClearAllPoints()
      UpdateMovable(frame)
    end
  end

  local function DraggerOnEnter()
    this.backdrop:SetBackdropBorderColor(1,1,1,1)
  end

  local function DraggerOnLeave()
    CreateBackdrop(this, nil, nil, .8)
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

    pfUI.unlock:Hide()
    pfUI.gui:Show()
  end)

  function pfUI.unlock:UnlockFrames()
    local txt = T["|cff33ffccUnlock Mode|r\nThis mode allows you to move frames by dragging them using the mouse cursor. Frames can be scaled by scrolling up and down.\nTo scale multiple frames at once (eg. raidframes), hold down the shift key while scrolling. Click into an empty space to go back to the pfUI menu."]
    CreateInfoBox(txt, 15, pfUI.unlock)

    pfUI.unlock:Show()
    pfUI.gui:Hide()
  end

  table.insert(UISpecialFrames, "pfUnlock")
end)
