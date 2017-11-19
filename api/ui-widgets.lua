-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

function pfUI.api.CreateTabChild(self, title, bwidth, bheight, bottom, static)
  -- setup env
  local childcount = table.getn(self.childs) + 1
  local button_width = bwidth or 150
  local button_height = bheight or 20
  local border = 4

  -- create tab button
  local b = CreateFrame("Button", "pfConfig" .. title .. "Button", self, "UIPanelButtonTemplate")
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
    b:SetPoint("TOPLEFT", self, "TOPLEFT", (childcount-1) * (button_width) + (childcount * border) + (self.outside and -border), -border + outside )
  end

  SkinButton(b,.2,1,.8)
  b:SetText(title)

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
  f.deco_up.fader:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 1)
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
  f.deco_down.fader:SetGradientAlpha("VERTICAL", 0, 0, 0, 1, 0, 0, 0, 0)
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
function pfUI.api.StripTextures(frame)
  for i,v in ipairs({frame:GetRegions()}) do
    if v.SetTexture then v:SetTexture("") end
  end
end

function pfUI.api.SkinBackdropOffset(frame, offset)
  StripTextures(frame)
  CreateBackdrop(frame, nil, nil, .0)
  local offsetBorder = -3
  if offset then offsetBorder = offset end 
  frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -offsetBorder, offsetBorder)
  frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", offsetBorder, -offsetBorder)
end

function pfUI.api.SkinCheckbox(frame, offset)
  frame:SetNormalTexture("")
  frame:SetPushedTexture("")
  frame:SetHighlightTexture("")
  CreateBackdrop(frame, nil, nil, .0)
  local offsetBorder = -5
  if offset then offsetBorder = offset end 
  frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -offsetBorder, offsetBorder)
  frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", offsetBorder, -offsetBorder)
  frame:SetHitRectInsets(-offsetBorder,-offsetBorder,-offsetBorder,-offsetBorder)
end

function pfUI.api.SkinDropDown(frame, offsetX, offsetY)
  StripTextures(frame)
  CreateBackdrop(frame, nil, nil, .0)
  local offsetXBorder = -16
  if offsetX then offsetXBorder = offsetX end 
  local offsetYBorder = -4
  if offsetY then offsetYBorder = offsetY end 
  frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -offsetXBorder, offsetYBorder)
  frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", offsetXBorder, -offsetYBorder)
  frame:SetHitRectInsets(-offsetXBorder, -offsetXBorder, -offsetYBorder, -offsetYBorder)
  local text = _G[frame:GetName().."Text"]
  text:SetPoint("TOPLEFT", frame.backdrop, "TOPLEFT")
  text:SetPoint("BOTTOMRIGHT", frame.backdrop, "BOTTOMRIGHT")
  local button = _G[frame:GetName().."Button"]
  button:ClearAllPoints()
  button:SetPoint("RIGHT", frame.backdrop, "RIGHT", -4, 0)
  button:SetHeight(16)
  button:SetWidth(16)
  local arrow = button:CreateTexture()
  arrow:SetTexture("Interface\\AddOns\\pfUI\\img\\down")
  arrow:SetAllPoints(button)
  button:SetNormalTexture(arrow)
  local arrowHighlighted = button:CreateTexture()
  arrowHighlighted:SetTexture("Interface\\AddOns\\pfUI\\img\\down")
  arrowHighlighted:SetAllPoints(button)
  button:SetHighlightTexture(arrowHighlighted)
  local arrowPushed = button:CreateTexture()
  arrowPushed:SetTexture("Interface\\AddOns\\pfUI\\img\\down")
  arrowPushed:SetAllPoints(button)
  button:SetPushedTexture(arrowPushed)
  local arrowDisabled = button:CreateTexture()
  arrowDisabled:SetTexture("Interface\\AddOns\\pfUI\\img\\down")
  arrowDisabled:SetAllPoints(button)
  arrowDisabled:SetVertexColor(0.2, 0.2, 0.2)
  button:SetDisabledTexture(arrowDisabled)
end

function pfUI.api.SkinTabBottom(frame)
  StripTextures(frame)
  CreateBackdrop(frame, nil, nil, 0.8, pfUI.backdrop_no_top)
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
