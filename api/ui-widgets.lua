-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

do -- statusbars
  local animations = {}
  local stepsize, val
  local width, height, point

  local animate = CreateFrame("Frame", "pfStatusBarAnimation", UIParent)
  animate:SetScript("OnUpdate", function()
    stepsize = tonumber(pfUI_config.unitframes.animation_speed)

    for bar in pairs(animations) do
      if not bar.val_ or abs(bar.val_ - bar.val) < stepsize or bar.instant then
        bar:DisplayValue(bar.val)
      elseif bar.val ~= bar.val_ then
        bar:DisplayValue(bar.val_ + min((bar.val-bar.val_) / stepsize, max(bar.val-bar.val_, 30 / GetFramerate())))
      end
    end
  end)

  local handlers = {
    ["DisplayValue"] = function(self, val)
      val = val > self.max and self.max or val
      val = val < self.min and self.min or val

      -- remove animation queue
      if val == self.val_ then
        animations[self] = nil
      end

      -- set current visible value
      self.val_ = val

      if self.mode == "vertical" then
        height = self:GetHeight()
        if pfUI.expansion == "vanilla" then height = height / self:GetEffectiveScale() end
        point = height / (self.max - self.min) * (val - self.min)

        -- keep values in limits
        point = math.min(height, point)
        point = math.max(0, point)

        -- set point to zero if value and max is zero
        if val == 0 then point = 0 end

        -- set status bar position/size
        self.bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, - height + point)
        self.bar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)

        -- set background bar position/size
        self.bg:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
        self.bg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, point)
      else
        width = self:GetWidth()
        if pfUI.expansion == "vanilla" then width = width / self:GetEffectiveScale() end
        point = width / (self.max - self.min) * (val - self.min)

        -- keep values in limits
        point = math.min(width, point)
        point = math.max(0, point)

        -- set point to zero if value and max is zero
        if val == 0 then point = 0 end

        -- set status bar position/size
        self.bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
        self.bar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", - width + point, 0)

        -- set background bar position/size
        self.bg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
        self.bg:SetPoint("TOPLEFT", self, "TOPLEFT", point, 0)
      end
    end,

    ["SetMinMaxValues"] = function(self, smin, smax, smooth)
      -- smoothen the transition by keeping the value at the same percentage as before
      if smooth and self.max and self.max > 0 and smax > 0 and self.max ~= smax then
        self.val_ = (self.val_ or self.val) / self.max * smax
      end

      self.min, self.max = smin, smax
      self:DisplayValue(self.val_ or self.val)
    end,

    ["SetValue"] = function(self, val)
      self.val = val or 0

      -- start animation on difference
      if self.val_ ~= self.val then
        animations[self] = true
      end
    end,

    ["SetStatusBarTexture"] = function(self, r, g, b, a)
      self.bar:SetTexture(r, g, b, a)
    end,

    ["SetStatusBarColor"] = function(self, r, g, b, a)
      self.bar:SetVertexColor(r, g, b, a)
    end,

    ["SetStatusBarBackgroundTexture"] = function(self, r, g, b, a)
      self.bg:SetTexture(r, g, b, a)
    end,

    ["SetStatusBarBackgroundColor"] = function(self, r, g, b, a)
      self.bg:SetVertexColor(r, g, b, a)
    end,

    ["SetOrientation"] = function(self, mode)
      self.mode = strlower(mode)
    end,
  }

  function pfUI.api.CreateStatusBar(name, parent)
    local f = CreateFrame("Button", name, parent)
    f:EnableMouse(nil)

    f.bar = f:CreateTexture(nil, "NORMAL")
    f.bar:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    f.bar:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)

    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    f.bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)

    -- set some default values
    f.min, f.max, f.val = 0, 100, 0

    -- add all handler functions to the object
    for name, func in pairs(handlers) do
      f[name] = func
    end

    return f
  end
end

do -- dropdown
  local _, class = UnitClass("player")
  local color = RAID_CLASS_COLORS[class]

  local function ListEntryOnShow()
    if this.parent.id == this.id then
      this.icon:Show()
    else
      this.icon:Hide()
    end
  end

  local function ListEntryOnClick()
    this.parent:SetSelection(this.id)

    if this.parent.mode == "MULTISELECT" then
      this.parent:ShowMenu()
    else
      this.parent:HideMenu()
    end

    if this.parent.menu[this.id].func then
      this.parent.menu[this.id].func()
    end
  end

  local function ListEntryOnEnter()
    this.hover:Show()
  end

  local function ListEntryOnLeave()
    this.hover:Hide()
  end

  local function ListButtonOnClick()
    if this.ToggleMenu then
      this:ToggleMenu()
    else
      this:GetParent():ToggleMenu()
    end
  end

  local function MenuOnUpdate()
    if not MouseIsOver(this, 100, -100, -100, 100) then
      this.button:HideMenu()
    end
  end

  local function ListButtonOnEnter()
    this.button:SetBackdropBorderColor(this.button.cr,this.button.cg,this.button.cb,(this.button.ca or 1))
  end

  local function ListButtonOnLeave()
    this.button:SetBackdropBorderColor(this.button.rr,this.button.rg,this.button.rb,(this.button.ra or 1))
  end

  local handlers = {
    ["SetSelection"] = function(self, id)
      if id and self.menu and self.menu[id] then
        self.text:SetText(self.menu[id].text)
        self.id = id
      end
    end,
    ["SetSelectionByText"] = function(self, name)
      self:UpdateMenu()
      for id, entry in pairs(self.menu) do
        if entry.text == name then
          self:SetSelection(id)
          return true
        end
      end

      self.text:SetText(name)
      return nil
    end,
    ["GetSelection"] = function(self)
      self:UpdateMenu()
      if self.menu and self.menu[self.id] then
        return self.id, self.menu[self.id].text, self.menu[self.id].func
      end
    end,
    ["SetMenu"] = function(self, menu)
      if type(menu) == "function" then
        self.menu = menu()
        self.menufunc = menu
      else
        self.menu = menu
        self.menufunc = nil
      end
    end,
    ["GetMenu"] = function(self)
      self:UpdateMenu()
      return self.menu
    end,
    ["ShowMenu"] = function(self)
      self:UpdateMenu()
      self.menuframe:SetFrameLevel(self:GetFrameLevel() + 8)
      self.menuframe:SetHeight(table.getn(self.menu)*20+4)
      self.menuframe:Show()
    end,
    ["HideMenu"] = function(self)
      self.menuframe:Hide()
    end,
    ["ToggleMenu"] = function(self)
      if self.menuframe:IsShown() then
        self:HideMenu()
      else
        self:ShowMenu()
      end
    end,
    ["UpdateMenu"] = function(self)
      -- run/reload menu function if available
      if self.menufunc then self.menu = self.menufunc() end
      if not self.menu then return end

      -- set caption to the current value
      self.text:SetText(self.menu[self.id] and self.menu[self.id].text or "")

      -- refresh menu buttons
      for id, element in pairs(self.menuframe.elements) do
        element:Hide()
      end

      for id, data in pairs(self.menu) do
        self:CreateMenuEntry(id)
      end
    end,
    ["CreateMenuEntry"] = function(self, id)
      if not self.menu[id] then return end

      local frame, entry
      for count, existing in pairs(self.menuframe.elements) do
        if not existing:IsShown() then
          frame = existing
          entry = count
          break
        end
      end

      if not frame and not entry then
        entry = table.getn(self.menuframe.elements) + 1
        frame = CreateFrame("Button", nil, self.menuframe)
        frame:SetFrameStrata("FULLSCREEN")
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", self.menuframe, "TOPLEFT", 2, -(entry-1)*20-2)
        frame:SetPoint("TOPRIGHT", self.menuframe, "TOPRIGHT", -2, -(entry-1)*20-2)
        frame:SetHeight(20)
        frame.parent = self

        frame.icon = frame:CreateTexture(nil, "OVERLAY")
        frame.icon:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
        frame.icon:SetHeight(16)
        frame.icon:SetWidth(16)
        frame.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")

        frame.text = frame:CreateFontString(nil, "OVERLAY")
        frame.text:SetFontObject(GameFontWhite)
        frame.text:SetFont(pfUI.font_default, pfUI_config.global.font_size-1, "OUTLINE")
        frame.text:SetJustifyH("RIGHT")
        frame.text:SetPoint("LEFT", frame, "LEFT", 2, 0)
        frame.text:SetPoint("RIGHT", frame.icon, "LEFT", -2, 0)

        frame.hover = frame:CreateTexture(nil, "BACKGROUND")
        frame.hover:SetAllPoints(frame)
        frame.hover:SetTexture(.4,.4,.4,.4)
        frame.hover:Hide()

        table.insert(self.menuframe.elements, frame)
      end

      frame.id = id
      frame.text:SetText(self.menu[id].text)

      frame:SetScript("OnShow",  ListEntryOnShow)
      frame:SetScript("OnClick", ListEntryOnClick)
      frame:SetScript("OnEnter", ListEntryOnEnter)
      frame:SetScript("OnLeave", ListEntryOnLeave)
      frame:Show()
    end,
  }
  function pfUI.api.CreateDropDownButton(name, parent)
    local frame = CreateFrame("Button", name, parent)
    frame:SetScript("OnEnter", ListButtonOnEnter)
    frame:SetScript("OnLeave", ListButtonOnLeave)
    frame:SetScript("OnClick", ListButtonOnClick)
    frame:SetHeight(20)
    frame.id = nil

    CreateBackdrop(frame, nil, true)

    local button = CreateFrame("Button", nil, frame)
    button:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
    button:SetWidth(16)
    button:SetHeight(16)
    button:SetScript("OnClick", ListButtonOnClick)
    SkinArrowButton(button, "down")
    button.icon:SetVertexColor(1,.9,.1)

    local text = frame:CreateFontString(nil, "OVERLAY")
    text:SetFontObject(GameFontWhite)
    text:SetFont(pfUI.font_default, pfUI_config.global.font_size-1, "OUTLINE")
    text:SetPoint("RIGHT", button, "LEFT", -4, 0)
    text:SetJustifyH("RIGHT")

    local menuframe = CreateFrame("Frame", tostring(frame).."menu", parent)
    menuframe.button = frame
    menuframe.elements = {}
    menuframe:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
    menuframe:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 2)
    menuframe:SetScript("OnUpdate", MenuOnUpdate)
    menuframe:Hide()
    CreateBackdrop(menuframe, nil, true)

    for name, func in pairs(handlers) do
      frame[name] = func
    end

    frame.menuframe = menuframe
    frame.button = button
    frame.text = text

    return frame
  end
end

function pfUI.api.CreateTabChild(self, title, bwidth, bheight, bottom, static)
  -- create tab button
  local b = CreateFrame("Button", "pfConfig" .. title .. "Button", self, "UIPanelButtonTemplate")
  b:SetText(title)

  -- setup env
  local childcount = table.getn(self.childs) + 1
  local button_width = bwidth
  local button_height = bheight or 20
  local border = 4

  if not button_width then
    button_width = 150
  elseif button_width == true then
    button_width = _G["pfConfig" .. title .. "ButtonText"]:GetStringWidth() + 4 * border
  end

  -- set dimensions
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
    local prev_button = self.buttons[getn(self.buttons)]
    if prev_button then
      b:SetPoint("TOPLEFT", prev_button, "TOPRIGHT", border, 0)
    else
      b:SetPoint("TOPLEFT", self, "TOPLEFT", border + (self.outside and -border), -border + outside )
    end
  end

  SkinButton(b,.2,1,.8)

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
  local child, scrollchild = nil, nil
  if not static then
    child = CreateScrollFrame("pfConfig" .. title .. "Frame", self)
    scrollchild = CreateScrollChild("pfConfig" .. title .. "ScrollChild", child)
  else
    child = CreateFrame("Frame", "pfConfig" .. title .. "Frame", self)
  end

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

  CreateBackdrop(child)
  SetAllPointsOffset(child.backdrop, child, -5,5)

  local ret = scrollchild or child
  ret.button = b
  table.insert(self.childs, child)
  return ret
end

function pfUI.api.CreateTabFrame(parent, align, outside)
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
  f.CreateTabChild = pfUI.api.CreateTabChild

  return f
end

function pfUI.api.CreateScrollFrame(name, parent)
  local f = CreateFrame("ScrollFrame", name, parent)

  -- create slider
  f.slider = CreateFrame("Slider", nil, f)
  f.slider:SetOrientation('VERTICAL')
  f.slider:SetPoint("TOPLEFT", f, "TOPRIGHT", -7, 0)
  f.slider:SetPoint("BOTTOMRIGHT", 0, 0)
  f.slider:SetThumbTexture(pfUI.media["img:col"])
  f.slider.thumb = f.slider:GetThumbTexture()
  f.slider.thumb:SetHeight(50)
  f.slider.thumb:SetTexture(.3,1,.8,.5)

  f.slider:SetScript("OnValueChanged", function()
    f:SetVerticalScroll(this:GetValue())
    f.UpdateScrollState()
  end)

  f.UpdateScrollState = function()
    f.slider:SetMinMaxValues(0, f:GetVerticalScrollRange())
    f.slider:SetValue(f:GetVerticalScroll())

    local m = f:GetHeight()+f:GetVerticalScrollRange()
    local v = f:GetHeight()
    local ratio = v / m

    if ratio < 1 then
      local size = math.floor(v * ratio)
      f.slider.thumb:SetHeight(size)
      f.slider:Show()
    else
      f.slider:Hide()
    end
  end

  f.Scroll = function(self, step)
    local step = step or 0

    local current = f:GetVerticalScroll()
    local max = f:GetVerticalScrollRange()
    local new = current - step

    if new >= max then
      f:SetVerticalScroll(max)
    elseif new <= 0 then
      f:SetVerticalScroll(0)
    else
      f:SetVerticalScroll(new)
    end

    f:UpdateScrollState()
  end

  f:EnableMouseWheel(1)
  f:SetScript("OnMouseWheel", function()
    this:Scroll(arg1*10)
  end)

  return f
end

function pfUI.api.CreateScrollChild(name, parent)
  local f = CreateFrame("Frame", name, parent)

  -- dummy values required
  f:SetWidth(1)
  f:SetHeight(1)
  f:SetAllPoints(parent)

  parent:SetScrollChild(f)

  f:SetScript("OnUpdate", function()
    this:GetParent():UpdateScrollState()
  end)

  return f
end

-- [ CreateTextBox ]
-- Creates and returns a default pfUI skinned EditBox
function pfUI.api.CreateTextBox(name, parent)
  local f = CreateFrame("EditBox", name, parent)
  f:SetScript("OnEscapePressed", function() this:ClearFocus() end)
  f:SetAutoFocus(false)
  f:SetTextInsets(5, 5, 5, 5)
  f:SetFontObject(GameFontNormal)
  CreateBackdrop(f, nil, true)
  return f
end

-- [ EnableClickRotate ]
-- Enables Modelframes to be rotated by click-drag
-- 'frame'    [frame]         the modelframe that should be used
function pfUI.api.EnableClickRotate(frame)
  frame:EnableMouse(true)
  HookScript(frame, "OnUpdate", function()
    if this.rotate then
      local x,_ = GetCursorPosition()
      if this.curx > x then
        this.rotation = this.rotation - abs(x-this.curx) * 0.025
      elseif this.curx < x then
        this.rotation = this.rotation + abs(x-this.curx) * 0.025
      end
      this:SetRotation(this.rotation)
      this.curx, this.cury = x, y
    end
  end)

  HookScript(frame, "OnMouseDown", function()
    if arg1 == "LeftButton" then
      this.rotate = true
      this.curx, this.cury = GetCursorPosition()
    end
  end)

  HookScript(frame, "OnMouseUp", function()
    this.rotate, this.curx, this.cury = nil, nil, nil
  end)
end

local function SetHighlightEnter()
  if this.locked then return end
  (this.backdrop or this):SetBackdropBorderColor(this.cr,this.cg,this.cb,(this.ca or 1))
end

local function SetHighlightLeave()
  if this.locked then return end
  (this.backdrop or this):SetBackdropBorderColor(this.rr,this.rg,this.rb,(this.ra or 1))
end

function pfUI.api.SetHighlight(frame, cr, cg, cb)
  if not frame then return end
  if not cr or not cg or not cb then
    local _, class = UnitClass("player")
    local color = RAID_CLASS_COLORS[class]
    cr, cg, cb = color.r , color.g, color.b
  end

  frame.cr, frame.cg, frame.cb = cr, cg, cb, ca
  frame.rr, frame.rg, frame.rb, frame.ra = GetStringColor(pfUI_config.appearance.border.color)

  if not frame.pfEnterLeave then
    if not frame.HookScript then frame.HookScript = HookScript end
    local enter, leave = frame:GetScript("OnEnter"), frame:GetScript("OnLeave")

    if enter then
      frame:HookScript("OnEnter", SetHighlightEnter)
    else
      frame:SetScript("OnEnter", SetHighlightEnter)
    end

    if leave then
      frame:HookScript("OnLeave", SetHighlightLeave)
    else
      frame:SetScript("OnLeave", SetHighlightLeave)
    end

    frame.pfEnterLeave = true
  end
end

function pfUI.api.HandleIcon(frame, icon)
  if not frame or not icon then return end

  SetAllPointsOffset(icon, frame, 3)
  icon:SetTexCoord(.08, .92, .08, .92)
end

-- [ Skin Button ]
-- Applies pfUI skin to buttons:
-- 'button'            [frame/string]  the button that should be skinned.
-- 'cr'                [int]           mouseover color (red), defaults to classcolor.
-- 'cg'                [int]           mouseover color (green), defaults to classcolor.
-- 'cb'                [int]           mouseover color (blue), defaults to classcolor.
-- 'icon'              [texture]       the button icon that should be skinned.
-- 'disableHighlight'  [bool]          disable mouseover highlight.
function pfUI.api.SkinButton(button, cr, cg, cb, icon, disableHighlight)
  local b = _G[button]
  if not b then b = button end
  if not b then return end
  if not cr or not cg or not cb then
    local _, class = UnitClass("player")
    local color = RAID_CLASS_COLORS[class]
    cr, cg, cb = color.r , color.g, color.b
  end
  pfUI.api.CreateBackdrop(b, nil, true)
  b:SetNormalTexture("")
  b:SetHighlightTexture("")
  b:SetPushedTexture("")
  b:SetDisabledTexture("")

  if b.SetCheckedTexture and b:GetCheckedTexture() then
    b:GetCheckedTexture():SetTexture(cr, cg, cb, .25)
  end

  if not disableHighlight then
    SetHighlight(b, cr, cg, cb)
  end

  if icon then
    HandleIcon(b, icon)
    b:SetPushedTexture(nil)
  end

  b:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")

  b.LockHighlight = function()
    b:SetBackdropBorderColor(cr,cg,cb,1)
    b.locked = true
  end

  b.UnlockHighlight = function()
    if not MouseIsOver(b) then
      b:SetBackdropBorderColor(GetStringColor(pfUI_config.appearance.border.color))
    end
    b.locked = false
  end
end

-- [ Skin Collapse Button ]
-- Applies pfUI skin to collapse/expand buttons:
-- 'button'   [frame/string]  the button that should be skinned.
function pfUI.api.SkinCollapseButton(button, all)
  local b = _G[button]
  if not b then b = button end
  if not b then return end
  local name = b:GetName() .. "CollapseButton"
  local size = 10

  b.icon = _G[name] or CreateFrame("Button", name, b)
  if all then size = 14 end
  b.icon:SetWidth(size)
  b.icon:SetHeight(size)
  b.icon:SetPoint("LEFT", 2, 2)
  CreateBackdrop(b.icon)
  b.icon.text = b.icon:CreateFontString(nil, "OVERLAY")
  b.icon.text:SetFontObject(GameFontWhite)
  b.icon.text:SetPoint("CENTER", -1, 0)
  b:SetNormalTexture(nil)
  b.SetNormalTexture = function(self, tex)
    if not tex or tex == "" then
      self.icon:Hide()
    else
      self.icon.text:SetText(strfind(tex, "MinusButton") and "-" or "+")
      self.icon:Show()
    end
  end

  local highlight = _G[b:GetName().."Highlight"]
  if highlight then
    highlight:SetTexture("")
    highlight.SetTexture = function(self, tex) return end
  end
end

-- [ Skin Rotate Button]
-- Applies pfUI skin to rotation buttons like in character pane:
-- 'button'     [frame/string]  the button that should be skinned.
function pfUI.api.SkinRotateButton(button)
  pfUI.api.CreateBackdrop(button)

  local _, class = UnitClass("player")
  local color = RAID_CLASS_COLORS[class]
  local cr, cg, cb = color.r , color.g, color.b

  button:SetWidth(button:GetWidth() - 18)
  button:SetHeight(button:GetHeight() - 18)

  button:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)
  button:GetPushedTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

  button:GetHighlightTexture():SetTexture(cr, cg, cb, .25)

  button:GetPushedTexture():SetAllPoints(button:GetNormalTexture())
  button:GetHighlightTexture():SetAllPoints(button:GetNormalTexture())
end

-- [ Skin Close Button ]
-- Applies pfUI close skin to buttons and can also be positioned
-- 'button'      [frame]    the button that should be skinned.
-- 'parentFrame' [frame]    will anchor to the top right of the parent.
-- 'offsetX'     [integer]  offsets the button horizontally
-- 'offsetY'     [integer]  offsets the button vertically
function pfUI.api.SkinCloseButton(button, parentFrame, offsetX, offsetY)
  if not button then return end

  SkinButton(button, 1, .25, .25)

  button:SetWidth(15)
  button:SetHeight(15)

  if parentFrame then
    button:ClearAllPoints()
    button:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", offsetX, offsetY)
  end

  button.texture = button:CreateTexture("pfQuestionDialogCloseTex")
  button.texture:SetTexture(pfUI.media["img:close"])
  button.texture:ClearAllPoints()
  button.texture:SetAllPoints(button)
  button.texture:SetVertexColor(1,.25,.25,1)
end

function pfUI.api.SkinArrowButton(button, dir, size)
  if not button then return end

  SkinButton(button)

  button:SetHitRectInsets(-3,-3,-3,-3)

  button:SetNormalTexture(nil)
  button:SetPushedTexture(nil)
  button:SetHighlightTexture(nil)
  button:SetDisabledTexture(nil)

  if size then
    button:SetWidth(size)
    button:SetHeight(size)
  end

  if not button.icon then
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAlpha(.8)
    SetAllPointsOffset(button.icon, button, 3)
  end

  button.icon:SetTexture(pfUI.media["img:"..dir])

  if not button.pficonfade then
    local button, state = button, nil
    button.pficonfade = CreateFrame("Frame", nil, button)
    button.pficonfade:SetScript("OnUpdate", function()
      if state == button:IsEnabled() then return end
      state = button:IsEnabled()

      if state > 0 then
        button.icon:SetVertexColor(.8,.8,.8,1)
      else
        button.icon:SetVertexColor(.2,.2,.2,1)
      end
    end)
  end
end

function pfUI.api.SkinScrollbar(frame, always)
  local parent = frame:GetParent()
  local name = frame:GetName()
  local up = _G[name .. "ScrollUpButton"]
  local down = _G[name .. "ScrollDownButton"]
  local thumb = frame:GetThumbTexture()

  pfUI.api.SkinArrowButton(up, "up")
  pfUI.api.SkinArrowButton(down, "down")

  if not frame.bg then
    frame.bg = CreateFrame("Frame", nil, frame)
    frame.bg:SetPoint("TOPLEFT", up, "BOTTOMLEFT", 0, -3)
    frame.bg:SetPoint("BOTTOMRIGHT", down, "TOPRIGHT", 0, 3)
    CreateBackdrop(frame.bg, nil, true)
  end

  if not frame.thumb then
    thumb:SetTexture(nil)
    frame.thumb = frame.bg:CreateTexture(nil, "ARTWORK")
    frame.thumb:SetTexture(.8,.8,.8,.8)
    frame.thumb:SetPoint("TOPLEFT", thumb, "TOPLEFT", 1, -4)
    frame.thumb:SetPoint("BOTTOMRIGHT", thumb, "BOTTOMRIGHT", -1, 4)
  end

  -- always show parent frame
  if always then
    RunOOC(function()
      if not parent.HookScript then parent.HookScript = HookScript end
      parent:HookScript("OnHide", function() this:Show() end)
    end)
  end
end

-- [ CenterFrame ]
-- Clears points and centers a frame
-- 'frame'           [frame] the frame that should be centered.
-- 'relativeFrame'   [frame] frame that should be used for centering if not use ui parent.
function pfUI.api.CenterFrame(frame, relativeFrame)
  frame:ClearAllPoints()
  if relativeFrame then
    frame:SetPoint("CENTER", relativeFrame, "CENTER", 0, 0)
  else
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  end
end

-- [ StripTextures ]
-- Strips all textures off a frame.
-- 'frame'     [frame]   the frame that should be stripped.
-- 'layer'     [string]  texture layer.
function pfUI.api.StripTextures(frame, hide, layer)
  if not frame then return end
  for _,v in ipairs({frame:GetRegions()}) do
    if v.SetTexture then
      local check = true
      if layer and v:GetDrawLayer() ~= layer then check = false end

      if check then
        if hide then
          v:Hide()
        else
          v:SetTexture(nil)
        end
      end
    end
  end
end

function pfUI.api.SetAllPointsOffset(frame, parent, offset)
  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", offset, -offset)
  frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, offset)
end

function pfUI.api.SkinCheckbox(frame, size)
  if not frame then return end
  frame:SetNormalTexture("")
  frame:SetPushedTexture("")
  frame:SetHighlightTexture("")
  if size then
    frame:SetWidth(size)
    frame:SetHeight(size)
  end
  CreateBackdrop(frame)
  SetAllPointsOffset(frame.backdrop, frame, 4)

  if frame.backdrop_border then
    -- make sure the blizzard border doesn't overlap the checkmark
    frame.backdrop_border:SetFrameLevel(frame.backdrop:GetFrameLevel())
  end
end

function pfUI.api.SkinDropDown(frame, cr, cg, cb, useSmall)
  if not frame then return end
  StripTextures(frame)
  CreateBackdrop(frame)
  frame.backdrop:SetPoint("TOPLEFT", 15, -1)
  frame.backdrop:SetPoint("BOTTOMRIGHT", -15, 6)

  local button = _G[frame:GetName() .. "Button"]
  button:SetNormalTexture(nil)
  button:SetPushedTexture(nil)
  button:SetHighlightTexture(nil)
  button:SetDisabledTexture(nil)
  button:SetAllPoints(frame.backdrop)

  CreateBackdrop(button)

  button.backdrop:ClearAllPoints()
  button.backdrop:SetWidth(18)
  button.backdrop:SetHeight(18)
  button.backdrop:SetPoint("RIGHT", frame.backdrop, "RIGHT", -2, 0)

  if not button.icon then
    button.icon = button:CreateTexture(nil, "OVERLAY")
    button.icon:SetTexture(pfUI.media["img:down"])
    button.icon:SetVertexColor(1,.9,.1)
    button.icon:SetAlpha(.8)
    SetAllPointsOffset(button.icon, button.backdrop, 5)
  end

  if not cr or not cg or not cb then
    local _, class = UnitClass("player")
    local color = RAID_CLASS_COLORS[class]
    cr, cg, cb = color.r , color.g, color.b
  end

  SetHighlight(button, cr, cg, cb)

  if not useSmall then
    -- fix small width
    button:Click() -- open list
    local list_width = DropDownList1:GetWidth()
    if frame:GetWidth() < list_width then
      UIDropDownMenu_SetWidth(list_width, frame)
    end
    CloseDropDownMenus()
  end

  local funcc = button:GetScript("OnClick")
  button:SetScript("OnClick", function()
    if funcc then funcc() end
    local DropDownListWidth = DropDownList1:GetWidth()
    local DropDownFrameWidth = frame.backdrop:GetWidth()
    if DropDownListWidth < DropDownFrameWidth then
      local diff = DropDownFrameWidth - DropDownListWidth
      DropDownList1:SetWidth(DropDownList1:GetWidth() + diff)
      for i=1, UIDROPDOWNMENU_MAXBUTTONS do
        _G["DropDownList1Button" .. i]:SetWidth(_G["DropDownList1Button" .. i]:GetWidth() + diff)
      end
    end

    DropDownList1:SetPoint("TOPLEFT", frame.backdrop, "BOTTOMLEFT", 0, -4)
  end)

  frame.button = button
end

function pfUI.api.SkinTab(frame, fixed)
  frame:SetHeight(20)
  StripTextures(frame)
  CreateBackdrop(frame)

  if not fixed then
    frame:SetScript("OnShow", function()
      this:SetWidth(this:GetTextWidth() + 20)
      if this.GetFontString and this:GetFontString() then
        this:GetFontString():SetPoint("CENTER", 0, 0)
      end
    end)
  end
end

function pfUI.api.SkinSlider(frame)
  local orientation = frame:GetOrientation()
  local thumb = frame:GetThumbTexture()

  CreateBackdrop(frame, nil, true)
  thumb:SetTexture(1, .82, 0)

  for i,region in ipairs({frame:GetRegions()}) do
    if region:GetObjectType() == 'FontString' then
      local point, anchor, anchorPoint, x, y = region:GetPoint()
      if orientation == 'VERTICAL' then
        if string.find(anchorPoint, "TOP") then -- top text
          region:ClearAllPoints()
          region:SetPoint("BOTTOM", anchor, "TOP", 0, 4)
        elseif string.find(anchorPoint, "BOTTOM") then -- bottom text
          region:ClearAllPoints()
          region:SetPoint("TOP", anchor, "BOTTOM", 0, -4)
        end
        anchor:SetHeight(anchor:GetHeight() - 4)
      else
        if string.find(anchorPoint, 'BOTTOM') then
          region:SetPoint(point, anchor, anchorPoint, x, y - 6)
        elseif string.find(anchorPoint, 'TOP') then
          region:SetPoint(point, anchor, anchorPoint, x, y + 2)
        end
      end
    end
  end

  if orientation == 'VERTICAL' then
    frame:SetWidth(10)
    thumb:SetHeight(22)
    thumb:SetWidth(frame:GetWidth())
  else
    frame:SetHeight(10)
    thumb:SetHeight(frame:GetHeight())
    thumb:SetWidth(17)
  end
end

-- [ Question Dialog ]
-- Creates a pfUI user dialog popup:
-- 'text'       [string]        text that will be displayed.
-- 'yes'        [function]      function that is triggered on 'Okay' button.
-- 'no'         [function]      function that is triggered on 'Cancel' button.
-- 'editbox'    [bool]          if set, a inputfield will be shown. it can be.
--                              accessed with "GetParent().input".
function pfUI.api.CreateQuestionDialog(text, yes, no, editbox, onclose)
  -- do not allow multiple instances of question dialogs
  if _G["pfQuestionDialog"] and _G["pfQuestionDialog"]:IsShown() then
    _G["pfQuestionDialog"]:Hide()
    _G["pfQuestionDialog"] = nil
    return
  end

  local yes, no = yes, no
  local yescap, nocap = YES, NO

  if yes and type(yes) == "table" then
    yescap = yes[1]
    yes = yes[2]
  end

  if no and type(no) == "table" then
    nocap = no[1]
    no = no[2]
  end

  if not text then text = "Are you sure?" end

  local rawborder, border = GetBorderSize()
  local padding = 15

  -- frame
  local question = CreateFrame("Frame", "pfQuestionDialog", UIParent)
  question:ClearAllPoints()
  question:SetPoint("CENTER", 0, 0)
  question:SetFrameStrata("TOOLTIP")
  question:SetMovable(true)
  question:EnableMouse(true)
  question:RegisterForDrag("LeftButton")
  question:SetScript("OnDragStart",function()
    this:StartMoving()
  end)

  question:SetScript("OnDragStop",function()
    this:StopMovingOrSizing()
  end)

  question:SetScript("OnHide", onclose)

  pfUI.api.CreateBackdrop(question, nil, nil, .85)
  pfUI.api.CreateBackdropShadow(question)

  -- text
  question.text = question:CreateFontString("Status", "LOW", "GameFontNormal")
  question.text:SetFontObject(GameFontWhite)
  question.text:SetPoint("TOPLEFT", question, "TOPLEFT", padding, -padding)
  question.text:SetPoint("TOPRIGHT", question, "TOPRIGHT", -padding, -padding)
  question.text:SetText(text)

  -- editbox
  if editbox then
    question.input = CreateFrame("EditBox", "pfQuestionDialogEdit", question)
    pfUI.api.CreateBackdrop(question.input)
    question.input:SetTextColor(.2,1,.8,1)
    question.input:SetJustifyH("CENTER")
    question.input:SetAutoFocus(false)
    question.input:SetPoint("TOPLEFT", question.text, "BOTTOMLEFT", border, -padding)
    question.input:SetPoint("TOPRIGHT", question.text, "BOTTOMRIGHT", -border, -padding)
    question.input:SetHeight(20)

    question.input:SetFontObject(GameFontNormal)
    question.input:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    question.input:SetAutoFocus(true)
  end

  -- buttons
  question.yes = CreateFrame("Button", "pfQuestionDialogYes", question, "UIPanelButtonTemplate")
  pfUI.api.SkinButton(question.yes)
  question.yes:SetWidth(100)
  question.yes:SetHeight(22)
  question.yes:SetText(yescap)
  question.yes:SetScript("OnClick", function()
    if yes then yes() end
    this:GetParent():Hide()
  end)

  if question.input then
    question.yes:SetPoint("TOPRIGHT", question.input, "BOTTOM", -3*border, -padding)
  else
    question.yes:SetPoint("TOPRIGHT", question.text, "BOTTOM", -3*border, -padding)
  end

  question.no = CreateFrame("Button", "pfQuestionDialogNo", question, "UIPanelButtonTemplate")
  pfUI.api.SkinButton(question.no)
  question.no:SetWidth(100)
  question.no:SetHeight(22)
  question.no:SetText(nocap)
  question.no:SetScript("OnClick", function()
    if no then no() end
    this:GetParent():Hide()
  end)

  if question.input then
    question.no:SetPoint("TOPLEFT", question.input, "BOTTOM", 3*border, -padding)
  else
    question.no:SetPoint("TOPLEFT", question.text, "BOTTOM", 3*border, -padding)
  end

  question.close = CreateFrame("Button", "pfQuestionDialogClose", question)
  question.close:SetPoint("TOPRIGHT", -border, -border)
  pfUI.api.CreateBackdrop(question.close)
  question.close:SetHeight(10)
  question.close:SetWidth(10)
  question.close.texture = question.close:CreateTexture("pfQuestionDialogCloseTex")
  question.close.texture:SetTexture(pfUI.media["img:close"])
  question.close.texture:ClearAllPoints()
  question.close.texture:SetAllPoints(question.close)
  question.close.texture:SetVertexColor(1,.25,.25,1)
  question.close:SetScript("OnEnter", function ()
    this.backdrop:SetBackdropBorderColor(1,.25,.25,1)
  end)

  question.close:SetScript("OnLeave", function ()
    pfUI.api.CreateBackdrop(this)
  end)

  question.close:SetScript("OnClick", function()
   this:GetParent():Hide()
  end)

  -- resize window
  local textspace = question.text:GetHeight() + padding
  local inputspace = 0
  if question.input then inputspace = question.input:GetHeight() + padding end
  local buttonspace = question.no:GetHeight() + padding
  question:SetHeight(textspace + inputspace + buttonspace + padding)

  local width = 200

  -- delay the auto sizing, to make sure the font rendering happened
  question:SetScript("OnUpdate", function()
    if question.text:GetStringWidth() > width then width = question.text:GetStringWidth() end
    question:SetWidth( width + 2*padding)
    this:SetScript("OnUpdate", nil)
  end)
end


-- [ Question Dialog ]
-- Creates a pfUI infobox popup window:
-- 'text'       [string]        text that will be displayed.
-- 'time'       [number]        time in seconds till the popup will be faded
-- 'parent'     [frame]         frame which will be used as parent for the dialog (defaults to UIParent)
-- 'height'     [number]        manual height of the popup (defaults to 100)
function pfUI.api.CreateInfoBox(text, time, parent, height)
  if not text then return end
  if not time then time = 5 end
  if not parent then parent = UIParent end
  if not height then height = 100 end

  local infobox = pfInfoBox
  if not infobox then
    infobox = CreateFrame("Button", "pfInfoBox", UIParent)
    infobox:Hide()

    infobox:SetScript("OnUpdate", function()
      local time = infobox.lastshow + infobox.duration - GetTime()
      infobox.timeout:SetValue(time)

      if GetTime() > infobox.lastshow + infobox.duration then
        infobox:SetAlpha(infobox:GetAlpha()-0.05)

        if infobox:GetAlpha() <= 0.1 then
          infobox:Hide()
          infobox:SetAlpha(1)
        end
      elseif MouseIsOver(this) then
        this:SetAlpha(max(0.4, this:GetAlpha() - .1))
      else
        this:SetAlpha(min(1, this:GetAlpha() + .1))
      end
    end)

    infobox:SetScript("OnClick", function()
      this:Hide()
    end)

    infobox.text = infobox:CreateFontString("Status", "HIGH", "GameFontNormal")
    infobox.text:ClearAllPoints()
    infobox.text:SetFontObject(GameFontWhite)

    infobox.timeout = CreateFrame("StatusBar", nil, infobox)
    infobox.timeout:SetStatusBarTexture(pfUI.media["img:bar"])
    infobox.timeout:SetStatusBarColor(.3,1,.8,1)

    infobox:ClearAllPoints()
    infobox.text:SetAllPoints(infobox)
    infobox.text:SetFont(pfUI.font_default, 14, "OUTLINE")

    pfUI.api.CreateBackdrop(infobox)
    infobox:SetPoint("TOP", 0, -25)

    infobox.timeout:ClearAllPoints()
    infobox.timeout:SetPoint("TOPLEFT", infobox, "TOPLEFT", 3, -3)
    infobox.timeout:SetPoint("TOPRIGHT", infobox, "TOPRIGHT", -3, 3)
    infobox.timeout:SetHeight(2)
  end

  infobox.text:SetText(text)
  infobox.timeout:SetMinMaxValues(0, time)
  infobox.timeout:SetValue(time)

  infobox.duration = time
  infobox.lastshow = GetTime()

  infobox:SetWidth(infobox.text:GetStringWidth() + 50)
  infobox:SetParent(parent)
  infobox:SetHeight(height)

  infobox:SetFrameStrata("FULLSCREEN_DIALOG")
  infobox:Show()
end

function pfUI.api.SkinMoneyInputFrame(frame)
  local gold_editbox = _G[frame:GetName().."Gold"]
  StripTextures(gold_editbox, true, "BACKGROUND")
  CreateBackdrop(gold_editbox, nil, true)
  local goldIcon = GetNoNameObject(gold_editbox, "Texture", nil, "MoneyIcons")
  goldIcon:Show()
  goldIcon:ClearAllPoints()
  goldIcon:SetPoint("LEFT", gold_editbox, "RIGHT", 2, 0)

  local silver_editbox = _G[frame:GetName().."Silver"]
  StripTextures(silver_editbox, true, "BACKGROUND")
  CreateBackdrop(silver_editbox, nil, true)
  silver_editbox:ClearAllPoints()
  silver_editbox:SetPoint("LEFT", goldIcon, "RIGHT", 2, 0)
  local silverIcon = GetNoNameObject(silver_editbox, "Texture", nil, "MoneyIcons")
  silverIcon:Show()
  silverIcon:ClearAllPoints()
  silverIcon:SetPoint("LEFT", silver_editbox, "RIGHT", 2, 0)

  local copper_editbox = _G[frame:GetName().."Copper"]
  StripTextures(copper_editbox, true, "BACKGROUND")
  CreateBackdrop(copper_editbox, nil, true)
  copper_editbox:ClearAllPoints()
  copper_editbox:SetPoint("LEFT", silverIcon, "RIGHT", 2, 0)
  local copperIcon = GetNoNameObject(copper_editbox, "Texture", nil, "MoneyIcons")
  copperIcon:Show()
  copperIcon:ClearAllPoints()
  copperIcon:SetPoint("LEFT", copper_editbox, "RIGHT", 2, 0)
end
