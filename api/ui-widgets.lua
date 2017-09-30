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
