-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

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

  local backdrop = CreateFrame("Frame", nil, child)
  backdrop:SetFrameLevel(1)
  backdrop:SetPoint("TOPLEFT", child, "TOPLEFT", -5, 5)
  backdrop:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", 5, -5)
  CreateBackdrop(backdrop, nil, true)

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
  local br, bg, bb, ba = pfUI.api.GetStringColor(pfUI_config.appearance.border.background)
  f.Scroll = function(self, step)
    local current = self:GetVerticalScroll()
    local new = current + step*-25
    local max = self:GetVerticalScrollRange() + 25

    if max > 25 then
      if new < 0 then
        self:SetVerticalScroll(0)
      elseif new > max then
        self:SetVerticalScroll(max)
      else
        self:SetVerticalScroll(new)
      end
    end

    self:UpdateScrollState()
  end

  f:EnableMouseWheel(1)

  f.deco_up = CreateFrame("Frame", nil, f)
  f.deco_up:SetPoint("TOPLEFT", f, "TOPLEFT", -4, 4)
  f.deco_up:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 4, -25)

  f.deco_up.fader = f.deco_up:CreateTexture("OVERLAY")
  f.deco_up.fader:SetTexture(1,1,1,1)
  f.deco_up.fader:SetGradientAlpha("VERTICAL", br, bg, bb, 0, br, bg, bb, 1)
  f.deco_up.fader:SetAllPoints(f.deco_up)

  f.deco_up_indicator = CreateFrame("Button", nil, f.deco_up)
  f.deco_up_indicator:SetFrameLevel(128)
  f.deco_up_indicator:Hide()
  f.deco_up_indicator:SetPoint("TOP", f.deco_up, "TOP", 0, -6)
  f.deco_up_indicator:SetHeight(12)
  f.deco_up_indicator:SetWidth(12)
  f.deco_up_indicator.modifier = 0.03
  f.deco_up_indicator:SetScript("OnClick", function()
    local f = this:GetParent():GetParent()
    f:Scroll(3)
  end)

  f.deco_up_indicator:SetScript("OnUpdate", function()
    local alpha = this:GetAlpha()
    local fpsmod = GetFramerate() / 30

    if alpha >= .75 then
      this.modifier = -0.03 / fpsmod
    elseif alpha <= .25 then
      this.modifier = 0.03  / fpsmod
    end

    this:SetAlpha(alpha + this.modifier)
  end)

  f.deco_up_indicator.tex = f.deco_up_indicator:CreateTexture("OVERLAY")
  f.deco_up_indicator.tex:SetTexture("Interface\\AddOns\\pfUI\\img\\up")
  f.deco_up_indicator.tex:SetAllPoints(f.deco_up_indicator)

  f.deco_down = CreateFrame("Frame", nil, f)
  f.deco_down:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", -4, -4)
  f.deco_down:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT", 4, 25)

  f.deco_down.fader = f.deco_down:CreateTexture("OVERLAY")
  f.deco_down.fader:SetTexture(1,1,1,1)
  f.deco_down.fader:SetGradientAlpha("VERTICAL", br, bg, bb, 1, br, bg, bb, 0)
  f.deco_down.fader:SetAllPoints(f.deco_down)

  f.deco_down_indicator = CreateFrame("Button", nil, f.deco_down)
  f.deco_down_indicator:SetFrameLevel(128)
  f.deco_down_indicator:Hide()
  f.deco_down_indicator:SetPoint("BOTTOM", f.deco_down, "BOTTOM", 0, 6)
  f.deco_down_indicator:SetHeight(12)
  f.deco_down_indicator:SetWidth(12)
  f.deco_down_indicator.modifier = 0.03
  f.deco_down_indicator:SetScript("OnClick", function()
    local f = this:GetParent():GetParent()
    f:Scroll(-3)
  end)

  f.deco_down_indicator:SetScript("OnUpdate", function()
    local alpha = this:GetAlpha()
    local fpsmod = GetFramerate() / 30

    if alpha >= .75 then
      this.modifier = -0.03 / fpsmod
    elseif alpha <= .25 then
      this.modifier = 0.03 / fpsmod
    end

    this:SetAlpha(alpha + this.modifier)
  end)

  f.deco_down_indicator.tex = f.deco_down_indicator:CreateTexture("OVERLAY")
  f.deco_down_indicator.tex:SetTexture("Interface\\AddOns\\pfUI\\img\\down")
  f.deco_down_indicator.tex:SetAllPoints(f.deco_down_indicator)

  f.UpdateScrollState = function(self)
    -- Update Scroll Indicators: Hide/Show if required.
    local current = floor(self:GetVerticalScroll())
    local max = floor(self:GetVerticalScrollRange() + 25)

    if current > 0 then
      self.deco_up_indicator:Show()
    else
      self.deco_up_indicator:Hide()
    end

    if max > 25 and current < max then
      self.deco_down_indicator:Show()
      self.deco_down_indicator:SetAlpha(.75)
    else
      self.deco_down_indicator:Hide()
    end
  end

  f:SetScript("OnMouseWheel", function()
    this:Scroll(arg1)
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

  -- OnShow is fired too early, postpone to the first frame draw
  f:SetScript("OnUpdate", function()
    this:GetParent():UpdateScrollState()
    this:SetScript("OnUpdate", nil)
  end)

  return f
end

-- [ EnableClickRotate ]
-- Enables Modelframes to be rotated by click-drag
-- 'frame'    [frame]         the modelframe that should be used
function pfUI.api.EnableClickRotate(frame)
  frame:EnableMouse(true)
  frame:SetScript("OnUpdate", function()
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

  frame:SetScript("OnMouseDown", function()
    if arg1 == "LeftButton" then
      this.rotate = true
      this.curx, this.cury = GetCursorPosition()
    end
  end)

  frame:SetScript("OnMouseUp", function()
    this.rotate, this.curx, this.cury = nil, nil, nil
  end)
end

-- [ Skin Button ]
-- Applies pfUI skin to buttons:
-- 'button'     [frame/string]  the button that should be skinned.
-- 'cr'         [int]           mouseover color (red), defaults to classcolor.
-- 'cg'         [int]           mouseover color (green), defaults to classcolor.
-- 'cb'         [int]           mouseover color (blue), defaults to classcolor.
function pfUI.api.SkinButton(button, cr, cg, cb)
  local b = getglobal(button)
  if not b then b = button end
  if not b then return end
  if not cr or not cg or not cb then
    _, class = UnitClass("player")
    local color = RAID_CLASS_COLORS[class]
    cr, cg, cb = color.r , color.g, color.b
  end
  pfUI.api.CreateBackdrop(b, nil, true)
  b:SetNormalTexture(nil)
  b:SetHighlightTexture(nil)
  b:SetPushedTexture(nil)
  b:SetDisabledTexture(nil)
  local funce = b:GetScript("OnEnter")
  local funcl = b:GetScript("OnLeave")
  b:SetScript("OnEnter", function()
    if funce then funce() end
    pfUI.api.CreateBackdrop(b, nil, true)
    b:SetBackdropBorderColor(cr,cg,cb,1)
  end)
  b:SetScript("OnLeave", function()
    if funcl then funcl() end
    pfUI.api.CreateBackdrop(b, nil, true)
  end)
  b:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
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

  button:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65);
  button:GetPushedTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65);

  button:GetHighlightTexture():SetTexture(cr, cg, cb, .25);

  button:GetPushedTexture():SetAllPoints(button:GetNormalTexture());
  button:GetHighlightTexture():SetAllPoints(button:GetNormalTexture());
end

-- [ Skin Close Button ]
-- Applies pfUI close skin to buttons and can also be positioned
-- 'button'      [frame]    the button that should be skinned.
-- 'parentFrame' [frame]    will anchor to the top right of the parent.
-- 'offsetX'     [integer]  offsets the button horizontally
-- 'offsetY'     [integer]  offsets the button vertically
function pfUI.api.SkinCloseButton(button, parentFrame, offsetX, offsetY)
  SkinButton(button)

  button:SetWidth(15)
  button:SetHeight(15)

  if parentFrame then
    button:ClearAllPoints()
    button:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", offsetX, offsetY)
  end

  button.texture = button:CreateTexture("pfQuestionDialogCloseTex")
  button.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\close")
  button.texture:ClearAllPoints()
  button.texture:SetAllPoints(button)
  button.texture:SetVertexColor(1,.25,.25,1)
end

function pfUI.api.SkinArrowButton(button, dir)
  SkinButton(button)

  button:SetHitRectInsets(-3,-3,-3,-3)

  button:SetNormalTexture(nil)
  button:SetPushedTexture(nil)
  button:SetHighlightTexture(nil)
  button:SetDisabledTexture(nil)

  if not button.icon then
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetTexture("Interface\\AddOns\\pfUI\\img\\" .. dir)
    button.icon:SetAlpha(.8)
    SetAllPointsOffset(button.icon, button, 3)
  end

  if not button.pfScripted then
    local enable = button.Enable
    local disable = button.Disable

    button.Enable = function(self)
      if enable then enable(self) end
      self.icon:SetVertexColor(.8,.8,.8,1)
    end

    button.Disable = function(self)
      if disable then disable(self) end
      self.icon:SetVertexColor(.2,.2,.2,1)
    end

    button.pfScripted = true
  end
end

function pfUI.api.SkinScrollbar(frame, parent)
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
  if parent then
    parent:Show()
    parent.Hide = function(self) frame.thumb:Hide() end
    parent.Show = function(self) frame.thumb:Show() end
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
-- 'frame'     [frame]  the frame that should be stripped.
function pfUI.api.StripTextures(frame, hide)
  for i,v in ipairs({frame:GetRegions()}) do
    if v.SetTexture then
      v:SetTexture(nil)
      if hide then
        v:Hide()
      end
    end
  end
end

function pfUI.api.SetAllPointsOffset(frame, parent, offset)
  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", offset, -offset)
  frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, offset)
end

function pfUI.api.SkinCheckbox(frame)
  frame:SetNormalTexture("")
  frame:SetPushedTexture("")
  frame:SetHighlightTexture("")
  frame:SetWidth(18)
  frame:SetHeight(18)
  CreateBackdrop(frame)
  frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
  frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
end

function pfUI.api.SkinDropDown(frame)
  CreateBackdrop(frame)
  frame.backdrop:SetPoint("TOPLEFT", 15, -1)
  frame.backdrop:SetPoint("BOTTOMRIGHT", -15, 6)

  for i,v in ipairs({frame:GetRegions()}) do
    if v.SetTexture then v:Hide() end
  end

  local button = _G[frame:GetName() .. "Button"]
  button:SetNormalTexture(nil)
  button:SetPushedTexture(nil)
  button:SetHighlightTexture(nil)
  button:SetDisabledTexture(nil)

  CreateBackdrop(button)
  button.backdrop:ClearAllPoints()
  button.backdrop:SetWidth(18)
  button.backdrop:SetHeight(18)
  button.backdrop:SetPoint("RIGHT", button, "RIGHT", -2, 0)

  if not button.icon then
    StripTextures(button)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetTexture("Interface\\AddOns\\pfUI\\img\\down")
    button.icon:SetAlpha(.8)
    SetAllPointsOffset(button.icon, button.backdrop, 5)
  end

  if not cr or not cg or not cb then
    _, class = UnitClass("player")
    local color = RAID_CLASS_COLORS[class]
    cr, cg, cb = color.r , color.g, color.b
  end

  local funce = button:GetScript("OnEnter")
  button:SetScript("OnEnter", function()
    if funce then funce() end
    this.backdrop:SetBackdropBorderColor(cr,cg,cb,1)
  end)

  local funcl = button:GetScript("OnLeave")
  button:SetScript("OnLeave", function()
    if funcl then funcl() end
    this.backdrop:SetBackdropBorderColor(pfUI.api.GetStringColor(pfUI_config.appearance.border.color))
  end)

  local funcc = button:GetScript("OnClick")
  button:SetScript("OnClick", function()
    if funcc then funcc() end
    UIDropDownMenu_JustifyText("RIGHT", this:GetParent())
    DropDownList1:SetPoint("TOPLEFT", this:GetParent().backdrop, "BOTTOMLEFT", 0, -4)
    DropDownList1:SetPoint("TOPRIGHT", this:GetParent().backdrop, "BOTTOMRIGHT", 0, -4)
    CreateBackdrop(DropDownList1Backdrop, nil, true, .8)
    DropDownList1.maxWidth = this:GetWidth() > 80 and this:GetWidth() or 80

    for i=1, UIDROPDOWNMENU_MAXBUTTONS do
      _G["DropDownList1Button" .. i]:SetWidth(DropDownList1.maxWidth)
    end
  end)
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

-- [ GetCloseButton ]
-- Get the close button from a frame.
-- 'frame'     [frame]  the frame that should be searched for the button.
function pfUI.api.GetCloseButton(frame)
  for i,v in ipairs({frame:GetChildren()}) do
    if v.GetObjectType and v:GetObjectType() == "Button" and v.GetNormalTexture and v:GetNormalTexture() then
      if v:GetNormalTexture().GetTexture and v:GetNormalTexture():GetTexture() == "Interface\\Buttons\\UI-Panel-MinimizeButton-Up" then
        return v
      end
    end
  end
  return nil
end

-- [ Question Dialog ]
-- Creates a pfUI user dialog popup:
-- 'text'       [string]        text that will be displayed.
-- 'yes'        [function]      function that is triggered on 'Okay' button.
-- 'no'         [function]      function that is triggered on 'Cancel' button.
-- 'editbox'    [bool]          if set, a inputfield will be shown. it can be.
--                              accessed with "GetParent().input".
function pfUI.api.CreateQuestionDialog(text, yes, no, editbox)
  -- do not allow multiple instances of question dialogs
  if pfQuestionDialog and pfQuestionDialog:IsShown() then
    pfQuestionDialog:Hide()
    pfQuestionDialog = nil
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

  local border = tonumber(pfUI_config.appearance.border.default)
  local padding = 15

  -- frame
  local question = CreateFrame("Frame", "pfQuestionDialog", UIParent)
  question:ClearAllPoints()
  question:SetPoint("CENTER", 0, 0)
  question:SetFrameStrata("TOOLTIP")
  question:SetMovable(true)
  question:EnableMouse(true)
  question:SetScript("OnMouseDown",function()
    this:StartMoving()
  end)

  question:SetScript("OnMouseUp",function()
    this:StopMovingOrSizing()
  end)
  pfUI.api.CreateBackdrop(question, nil, nil, .85)

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
  question.close.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\close")
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
  if question.text:GetStringWidth() > 200 then width = question.text:GetStringWidth() end
  question:SetWidth( width + 2*padding)
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
    infobox.timeout:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
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
