pfUI:RegisterModule("actionbar", function ()
  local _, class = UnitClass("player")
  local color = RAID_CLASS_COLORS[class]
  local cr, cg, cb = color.r , color.g, color.b

  local backdrop_highlight = { edgeFile = "Interface\\AddOns\\pfUI\\img\\glow", edgeSize = 8 }
  local showgrid = 0

  -- hide blizzard bars
  local function kill(f, killshow)
    if f.Show and killshow then f.Show = function() return end end
    if f.UnregisterAllEvents then f:UnregisterAllEvents() end
    if f.Hide then f:Hide() end
  end

  kill(MainMenuBar)

  local blizzard_elements = { MultiBarBottomLeft,
    MultiBarBottomRight, MultiBarLeft, MultiBarRight }
  for _, f in pairs(blizzard_elements) do
    kill(f, true)
  end

  local bars = { }
  local buttontypes = {
    -- blizzard keybinds
    [3] = "MULTIACTIONBAR3BUTTON",
    [4] = "MULTIACTIONBAR4BUTTON",
    [5] = "MULTIACTIONBAR2BUTTON",
    [6] = "MULTIACTIONBAR1BUTTON",
    [11] = "SHAPESHIFTBUTTON",
    [12] = "BONUSACTIONBUTTON",
    -- additional keybinds
    [2] = "PFPAGING",
    [7] = "PFSTANCEONE",
    [8] = "PFSTANCETWO",
    [9] = "PFSTANCETHREE",
    [10] = "PFSTANCEFOUR",
  }

  local blizzbarmapping = {
    ["MultiBarRight"] = 3,
    ["MultiBarLeft"] = 4,
    ["MultiBarBottomRight"] = 5,
    ["MultiBarBottomLeft"] = 6,
    ["ShapeShiftBar"] = 11,
    ["BonusActionBar"] = 12,
  }

  local barnames = {
    [1] = "Main",
    [2] = "Paging",
    [3] = "Right",
    [4] = "Vertical",
    [5] = "Left",
    [6] = "Top",
    [7] = "StanceBar1",
    [8] = "StanceBar2",
    [9] = "StanceBar3",
    [10] = "StanceBar4",
    [11] = "Stances",
    [12] = "Pet",
  }

  local button_animations = {
    ["none"] = function()
      this.active = nil
      this:Hide()
    end,
    ["zoomfade"] = function()
      if this.active == 0 then
        -- init animation
        this:SetWidth(this.parent:GetWidth())
        this:SetHeight(this.parent:GetHeight())
        this:SetScale(this.parent:GetScale())
        this.tex:SetTexture(this.parent.icon:GetTexture())
        this.tex:SetVertexColor(this.parent.icon:GetVertexColor())
        this:SetAlpha(1)
        this.active = 1
        return
      elseif this.active == 1 then
        -- run animation
        local fade = 30/GetFramerate()*0.05
        this:SetAlpha(this:GetAlpha() - fade)
        this:SetScale(this:GetScale() + fade)
        if this:GetAlpha() > 0 then return end
      end

      -- stop animation
      this.active = nil
      this:Hide()
    end,
    ["shrinkreturn"] = function()
      if this.active == 0 then
        -- init animation
        this:SetWidth(this.parent:GetWidth())
        this:SetHeight(this.parent:GetHeight())
        this:SetScale(this.parent:GetScale())
        this.tex:SetTexture(this.parent.icon:GetTexture())
        this.tex:SetVertexColor(this.parent.icon:GetVertexColor())
        this:SetAlpha(1)
        this.parent.icon:Hide()
        this.active = 1
        this.time = 0
        return
      elseif this.active == 1 then
        -- run animation
        this.time = this.time + 30/GetFramerate()*0.1
        local fade = 1 -math.exp(-this.time)*math.sin(this.time*math.pi)
        this:SetAlpha(fade)
        this:SetScale(fade)
        if this.time < 1 then return end
      end

      -- stop animation
      this.active = nil
      this:Hide()
      this.parent.icon:Show()
    end,
    ["elasticzoom"] = function()
      if this.active == 0 then
        -- init animation
        this:SetWidth(this.parent:GetWidth())
        this:SetHeight(this.parent:GetHeight())
        this:SetScale(this.parent:GetScale())
        this.tex:SetTexture(this.parent.icon:GetTexture())
        this.tex:SetVertexColor(this.parent.icon:GetVertexColor())
        this:SetAlpha(1)
        this.parent.icon:Hide()
        this.active = 1
        this.time = 0
        return
      elseif this.active == 1 then
        -- run animation
        this.time = this.time + 30/GetFramerate()*0.03
        local fade = 1 -math.exp(-this.time*6)*math.sin(this.time*4*math.pi)
        this:SetAlpha(fade)
        this:SetScale(fade)
        if this.time < 1 then return end
      end

      -- stop animation
      this.active = nil
      this:Hide()
      this.parent.icon:Show()
    end,
    ["wobblezoom"] = function()
      if this.active == 0 then
        -- init animation
        this:SetWidth(this.parent:GetWidth())
        this:SetHeight(this.parent:GetHeight())
        this:SetScale(this.parent:GetScale())
        this.tex:SetTexture(this.parent.icon:GetTexture())
        this.tex:SetVertexColor(this.parent.icon:GetVertexColor())
        this:SetAlpha(1)
        this.parent.icon:Hide()
        this.active = 1
        this.time = 0
        return
      elseif this.active == 1 then
        -- run animation
        this.time = this.time + 30/GetFramerate()*0.02
        local fade = 1 -math.exp(-this.time*6)*math.sin(this.time*10*math.pi)
        this:SetAlpha(fade)
        this:SetScale(fade)
        if this.time < 1 then return end
      end

      -- stop animation
      this.active = nil
      this:Hide()
      this.parent.icon:Show()
    end,
  }

  local function GetActiveBar()
    if CURRENT_ACTIONBAR_PAGE == 1 and GetBonusBarOffset() ~= 0 then
      return NUM_ACTIONBAR_PAGES + GetBonusBarOffset()
    else
      return CURRENT_ACTIONBAR_PAGE
    end
  end

  local function SwitchBar(bar)
    if _G.CURRENT_ACTIONBAR_PAGE ~= bar then
      _G.CURRENT_ACTIONBAR_PAGE = bar
      ChangeActionBarPage()
    end
  end

  local function ButtonRefresh(self)
    local self = self or this
    local id, bar, active, texture
    local sid = self:GetID() -- 1 to 120

    local usable, oom
    local start, duration, enable
    local castable, autocast

    -- abort as early as possible on regular state update
    if event == "ACTIONBAR_UPDATE_STATE" and self.bar ~= 11 and self.bar ~= 12 then
      if IsCurrentAction(sid) then
        self.backdrop:SetBackdropBorderColor(cr,cg,cb,1)
        self.active:Show()
      else
        CreateBackdrop(self)
        self.active:Hide()
      end
      return
    end

    if self.bar == 11 then
      -- stance button
      id = sid
      bar = self.bar
      texture, _, active, usable = GetShapeshiftFormInfo(id)
      oom = nil
      start, duration, enable = GetShapeshiftFormCooldown(sid)
    elseif self.bar == 12 then
      -- pet button
      local token
      id = sid
      _, _, texture, token, active, castable, autocast = GetPetActionInfo(id)
      texture = token and _G[texture] or texture
      usable, oom = true, nil
      start, duration, enable = GetPetActionCooldown(sid)
    else
      active = IsCurrentAction(sid)
      texture = GetActionTexture(sid)
      id = sid - (self.bar-1)*12
      bar = GetActiveBar()
      usable, oom = IsUsableAction(sid)
      start, duration, enable = GetActionCooldown(sid)
    end

    if not self.showempty and self.backdrop and not texture and showgrid == 0 then
      self.backdrop:Hide()
    else
      self.backdrop:Show()
    end

    -- update cooldown
    CooldownFrame_SetTimer(self.cd, start, duration, enable)

    -- don't go further on those events
    if event == "ACTIONBAR_UPDATE_COOLDOWN" then return end

    if self.bar ~= 11 and self.bar ~= 12 then
      -- update consumables
      if IsConsumableAction(sid) then
        self.count:SetText(GetActionCount(sid))
      elseif IsReagentAction and IsReagentAction(sid) then
        self.count:SetText(GetReagentCount(sid))
      else
        self.count:SetText(nil)
      end

      -- equipped item
      if IsEquippedAction(sid) and C.bars.showequipped == "1" then
        self.equipped:Show()
      else
        self.equipped:Hide()
      end

      -- update macro text
      self.macro:SetText(GetActionText(sid))
    end

    -- update usable
    if self.outofrange and C.bars.glowrange == "1" then
      self.icon:SetVertexColor(self.rangeColor[1], self.rangeColor[2], self.rangeColor[3], self.rangeColor[4])
    elseif oom and C.bars.showoom == "1" then
      self.icon:SetVertexColor(self.oomColor[1], self.oomColor[2], self.oomColor[3], self.oomColor[4])
    elseif not usable and C.bars.showna == "1" then
      self.icon:SetVertexColor(self.naColor[1], self.naColor[2], self.naColor[3], self.naColor[4])
    else
      self.icon:SetVertexColor(1, 1, 1, 1)
    end

    -- don't go further on those events
    if event == "ACTIONBAR_UPDATE_USABLE" or event == "UPDATE_INVENTORY_ALERTS"	then return end

    -- icon
    if texture ~= self.texture then
      self.icon:SetTexture(texture)
      self.texture = texture
    end

    -- handle pet bar quirks
    if self.bar == 12 then
      -- desaturate disabled petbar
      self.icon:SetDesaturated(not GetPetActionsUsable())

      -- display autocast
      if autocast then
        self.autocast:Show()
      else
        self.autocast:Hide()
      end

      if castable and C.bars.showcastable == "1" then
        self.autocastable:Show()
      else
        self.autocastable:Hide()
      end
    end

    -- active border
    if active then
      self.backdrop:SetBackdropBorderColor(cr,cg,cb,1)
      self.active:Show()
    else
      CreateBackdrop(self)
      self.active:Hide()
    end

    -- keybinds
    if self.bar == bar and self.bar ~= 11 and self.bar ~= 12 then
      self.keybind:SetText(GetBindingText(GetBindingKey("ACTIONBUTTON"..id), "KEY_", 1))
    elseif buttontypes[self.bar] then
      self.keybind:SetText(GetBindingText(GetBindingKey(buttontypes[self.bar]..id), "KEY_", 1))
    else
      self.keybind:SetText("")
    end
  end

  local function ButtonUpdate(self)
    local self = self or this

    -- trigger update
    if self.forceupdate then
      self.forceupdate = nil
      self:GetScript("OnEvent")()
    end

    -- throttle to run once per .1 seconds
    if ( self.tick or 1) > GetTime() then return else self.tick = GetTime() + .1 end

    local sid = self:GetID()

    -- update range display
    if C.bars.glowrange == "1" and self.bar ~= 11 and self.bar ~= 12 and HasAction(sid) and ActionHasRange(sid) and IsActionInRange(sid) == 0 then
      if not self.outofrange then
        self.outofrange = true
        self.forceupdate = true
      end
    elseif self.outofrange then
      self.outofrange = nil
      self.forceupdate = true
    end
  end

  local function ButtonDrag(self)
    local self = self or this

    if _G.LOCK_ACTIONBAR == "1" and not IsShiftKeyDown() then return end

    if self.bar == 12 then
      PickupPetAction(self:GetID())
    else
      PickupAction(self:GetID())
    end
  end

  local function ButtonDragStop(self)
    local self = self or this

    if self.bar == 12 then
      PickupPetAction(self:GetID())
    else
      PlaceAction(self:GetID())
    end
  end

  local function ButtonClick(self)
    local self = self or this

    -- trigger effect
    self.animation.active = 0
    self.animation:Show()

    if self.bar == 11 then
      CastShapeshiftForm(self:GetID())
    elseif showgrid == 1 then
      PickupAction(self:GetID())
    elseif self.bar == 12 then
      if arg1 == "LeftButton" then
        if IsPetAttackActive(self:GetID()) then
          PetStopAttack()
        else
          CastPetAction(self:GetID())
        end
      else
        TogglePetAutocast(self:GetID())
      end
    else
      UseAction(self:GetID())
    end
  end

  local function ButtonEnter(self)
    local self = self or this

    GameTooltip:ClearLines()
    GameTooltip_SetDefaultAnchor(GameTooltip, self)

    if self.bar == 11 then
      GameTooltip:SetShapeshift(self:GetID())
    elseif self.bar == 12 then
      local name, _, _, token = GetPetActionInfo(self:GetID())
      if token then
        GameTooltip:AddLine(_G[name])
        GameTooltip:Show()
      else
        GameTooltip:SetPetAction(self:GetID())
      end
    else
      GameTooltip:SetAction(self:GetID())
    end

    self.highlight:Show()
  end

  local function ButtonLeave(self)
    local self = self or this

    self.highlight:Hide()
    GameTooltip:Hide()
  end

  local function CreateActionButton(parent, bar, button)
    -- load config
    local size = C.bars["bar"..bar].icon_size
    local font = C.bars.font
    local font_offset = tonumber(C.bars.font_offset)

    local macro_size = tonumber(C.bars.macro_size)
    local macro_color = { strsplit(",", C.bars.macro_color) }

    local count_size = tonumber(C.bars.count_size)
    local count_color = { strsplit(",", C.bars.count_color) }

    local bind_size = tonumber(C.bars.bind_size)
    local bind_color = { strsplit(",", C.bars.bind_color) }

    local showempty = C.bars["bar"..bar].showempty
    local showmacro = C.bars["bar"..bar].showmacro
    local showkybind = C.bars["bar"..bar].showkeybind
    local showcount = C.bars["bar"..bar].showcount

    -- sanitize font sizes
    if macro_size == 0 then macro_size = 1 end
    if count_size == 0 then macro_size = 1 end
    if bind_size == 0 then macro_size = 1 end

    local button_name = "pfActionBar" .. barnames[bar] .. "Button" .. button

    local id = (bar-1)*12+button
    local exists = _G[button_name] and true or nil
    local f = _G[button_name] or CreateFrame("Button", button_name, parent)

    if not exists then
      -- no button available, create a new one
      f:RegisterForClicks("LeftButtonUp", "RightButtonUp")

      -- slot/button updates
      f:RegisterEvent("PLAYER_ENTERING_WORLD")
      f:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
      f:RegisterEvent("UPDATE_BINDINGS")
      f:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
      f:RegisterEvent("ACTIONBAR_UPDATE_STATE")
      f:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
      f:RegisterEvent("CRAFT_SHOW")
      f:RegisterEvent("CRAFT_CLOSE")
      f:RegisterEvent("TRADE_SKILL_SHOW")
      f:RegisterEvent("TRADE_SKILL_CLOSE")
      f:RegisterEvent("PLAYER_ENTER_COMBAT")
      f:RegisterEvent("PLAYER_LEAVE_COMBAT")

      -- cooldown updates
      f:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
      f:RegisterEvent("UPDATE_INVENTORY_ALERTS")
      f:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
      f:RegisterEvent("UNIT_INVENTORY_CHANGED")

      -- show/hide grid
      f:RegisterEvent("ACTIONBAR_SHOWGRID")
      f:RegisterEvent("ACTIONBAR_HIDEGRID")

      if bar ~= 11 then
        f:RegisterForDrag("LeftButton", "RightButton")
        f:SetScript("OnDragStart", ButtonDrag)
        f:SetScript("OnReceiveDrag", ButtonDragStop)
      end

      if bar == 11 then
        f:RegisterEvent("PLAYER_AURAS_CHANGED")
      end

      if bar == 12 then
        f:RegisterEvent("PLAYER_CONTROL_LOST")
        f:RegisterEvent("PLAYER_CONTROL_GAINED")
        f:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
        f:RegisterEvent("UNIT_PET")
        f:RegisterEvent("UNIT_FLAGS")
        f:RegisterEvent("UNIT_AURA")
        f:RegisterEvent("PET_BAR_UPDATE")
        f:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
      end

      f:SetScript("OnEvent", ButtonRefresh)
      f:SetScript("OnClick", ButtonClick)
      f:SetScript("OnEnter", ButtonEnter)
      f:SetScript("OnLeave", ButtonLeave)
      f:SetScript("OnUpdate", ButtonUpdate)

      f:SetID(id)

      -- cooldown
      f.cd = CreateFrame(COOLDOWN_FRAME_TYPE, f:GetName() .. "Cooldown", f, "CooldownFrameTemplate")
      f.cd.pfCooldownType = "NOGCD"

      -- icon
      f.icon = f:CreateTexture(button_name .. "Icon", "BACKGROUND")
      f.icon:SetTexCoord(.08, .92, .08, .92)
      f.icon:SetAllPoints()

      -- animation
      f.animation = CreateFrame("Frame", button_name .. "Animation", f)
      f.animation.parent = f
      f.animation:SetPoint("CENTER", 0, 0)
      f.animation:Hide()
      f.animation.tex = f.animation:CreateTexture(button_name .. "AnimationTexture", "BACKGROUND")
      f.animation.tex:SetTexCoord(.08, .92, .08, .92)
      f.animation.tex:SetAllPoints()

      if bar ~= 11 and bar ~= 12 then
        -- equipped item
        f.equipped = f:CreateTexture(nil, "BORDER")
        f.equipped:SetAllPoints()
        f.equipped:Hide()
      elseif bar == 12 then
        f.autocast = CreateFrame("Model", nil, f)
        f.autocast:SetAllPoints()
        f.autocast:SetModel("Interface\\Buttons\\UI-AutoCastButton.mdx")
        f.autocast:SetSequence(0)
        f.autocast:SetSequenceTime(0, 0)
        f.autocast:Hide()

        f.autocastable = f:CreateTexture(nil, "BORDER")
        f.autocastable:SetAllPoints()
        f.autocastable:SetTexture("Interface\\Buttons\\UI-AutoCastableOverlay")
        f.autocastable:SetTexCoord(.25, .75, .25, .75)
      end

      -- macro
      f.macro = f:CreateFontString(button_name .. "Name", "LOW", "GameFontNormal")

      -- keybind
      f.keybind = f:CreateFontString(nil, "LOW", "GameFontNormal")

      -- itemcount
      f.count = f:CreateFontString(button_name .. "Count", "LOW", "GameFontNormal")

      -- highlight
      f.highlight = CreateFrame("Frame", nil, f)
      f.highlight:SetBackdrop(backdrop_highlight)
      f.highlight:SetBackdropBorderColor(1,1,1,.8)
      f.highlight:SetAllPoints()
      f.highlight:Hide()

      -- active
      f.active = CreateFrame("Frame", nil, f)
      f.active:SetBackdrop(backdrop_highlight)
      f.active:SetBackdropBorderColor(1,1,.5,1)
      f.active:SetAllPoints()
      f.active:Hide()
    end

    -- set animation
    f.animation:SetScript("OnUpdate", button_animations[C.bars.animation])

    -- pet autocast
    if bar == 12 then
      f.autocast:SetScale(C.bars["bar"..bar].icon_size / 25)
      f.autocast:SetAlpha(.05)
    end

    -- macro options
    if showmacro == "1" then f.macro:Show() else f.macro:Hide() end
    SetAllPointsOffset(f.macro, f, font_offset, -font_offset)
    f.macro:SetFont(font, macro_size, "OUTLINE")
    f.macro:SetTextColor(unpack(macro_color))
    f.macro:SetJustifyH("LEFT")
    f.macro:SetJustifyV("BOTTOM")

    -- keybind options
    if showkybind == "1" then f.keybind:Show() else f.keybind:Hide() end
    SetAllPointsOffset(f.keybind, f, font_offset, -font_offset)
    f.keybind:SetFont(font, bind_size, "OUTLINE")
    f.keybind:SetTextColor(unpack(bind_color))
    f.keybind:SetJustifyH("RIGHT")
    f.keybind:SetJustifyV("TOP")

    -- item count options
    if showcount == "1" then f.count:Show() else f.count:Hide() end
    SetAllPointsOffset(f.count, f, font_offset, -font_offset)
    f.count:SetFont(font, count_size, "OUTLINE")
    f.count:SetTextColor(unpack(count_color))
    f.count:SetJustifyH("RIGHT")
    f.count:SetJustifyV("BOTTOM")

    -- range glow color
    f.rangeColor = { strsplit(",", C.bars.rangecolor) }

    -- out of mana color
    f.oomColor = { strsplit(",", C.bars.oomcolor) }

    -- not usable color
    f.naColor = { strsplit(",", C.bars.nacolor) }

    -- equipped color
    if f.equipped then
      f.equipped:SetTexture(strsplit(",", C.bars.eqcolor))
    end

    -- general appearance
    f.showempty = showempty == "1" and true or nil
    f:SetHeight(size)
    f:SetWidth(size)
    CreateBackdrop(f)

    return f
  end

  local function CreateActionBar(i)
    -- load config
    local buttonbasename = "pfActionBar" .. barnames[i] .. "Button"
    local enable = C.bars["bar"..i].enable
    local size = C.bars["bar"..i].icon_size
    local background = C.bars["bar"..i].background
    local formfactor = C.bars["bar"..i].formfactor
    local autohide = C.bars["bar"..i].autohide
    local hide_time = C.bars["bar"..i].hide_time

    local buttons = tonumber(C.bars["bar"..i].buttons) or 12
    if i == 11 and bars[i] then -- shapeshift buttons
      buttons = GetNumShapeshiftForms()
    elseif i == 12 and bars[i] then -- pet buttons
      buttons = NUM_PET_ACTION_SLOTS
    elseif i == 12 or i == 11 then
      -- Fallback to 10 buttons on shapeshift and petbar during initialization.
      -- This lets us load bars that aren't yet available for your class or level.
      buttons = 10
    end

    -- don't process empty bars
    if buttons == 0 then
      bars[i]:Hide()
      return
    end

    -- we changed bar size and stored layout is invalid, fallback
    if not pfGridmath[buttons][BarLayoutFormfactor(formfactor)] then
      formfactor = BarLayoutOptions(buttons)[1]
      C.bars["bar"..i].formfactor = formfactor
    end

    local border = C.appearance.border.default
    if C.appearance.border.actionbars ~= "-1" then
      border = C.appearance.border.actionbars
    end

    local font = pfUI.font_unit
    local font_size = C.global.font_unit_size

    local realsize = size+border*2

    -- create frame
    bars[i] = bars[i] or CreateFrame("Frame", "pfActionBar" .. barnames[i], UIParent)
    bars[i]:SetID(i)

    -- autohide
    if autohide == "1" then
      EnableAutohide(bars[i], tonumber(hide_time))
    else
      DisableAutohide(bars[i])
    end

    -- apply visible settings
    if enable == "1" then
      -- handle pet bar
      if i == 12 then
        -- only show when pet actions exists
        if PetHasActionBar() then
          bars[i]:Show()
        else
          bars[i]:Hide()
        end

        -- show/hide petbar on petbar updates
        bars[i]:RegisterEvent("PET_BAR_UPDATE")
        bars[i]:SetScript("OnEvent", function()
          -- hide obsolete buttons
          for i=1, NUM_PET_ACTION_SLOTS do
           if not PetHasActionBar() and bars[12][i] then
             bars[12][i]:Hide()
           end
          end
          -- refresh layout
          CreateActionBar(12)
        end)

      -- handle shapeshift bar
      elseif i == 11 then
        -- only show when shapeshifts exist
        if GetNumShapeshiftForms() > 0 then
          bars[i]:Show()
        else
          bars[i]:Hide()
        end

        -- update shapeshift bar when amount of spells changes
        bars[i]:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
        bars[i]:SetScript("OnEvent", function()
          local count = GetNumShapeshiftForms()
          if count ~= this.lastCount then
            this.lastCount = count

            -- hide obsolete buttons
            for i=1, NUM_SHAPESHIFT_SLOTS do
              if i > GetNumShapeshiftForms() and bars[11][i] then
                bars[11][i]:Hide()
              end
            end

            -- create new buttons and refresh layout
            CreateActionBar(11)
          end
        end)

      -- regular bars
      else
        bars[i]:Show()
      end

    elseif enable == "0" then
      bars[i]:UnregisterAllEvents()
      bars[i]:Hide()
    end

    -- create action buttons
    local maxbuttons = (i == 11 or i == 12) and 10 or 12
    for j=1,maxbuttons do
      bars[i][j] = CreateActionButton(bars[i], i, j)
      bars[i][j].bar = i

      BarButtonAnchor(bars[i][j], buttonbasename, j, buttons, formfactor, size, border)
      bars[i][j]:ClearAllPoints()
      bars[i][j]:SetPoint(unpack(bars[i][j]._anchor))
      bars[i][j]:Show()

      if i > 10 then
        bars[i][j]:SetID(j)
      end

      -- refresh button
      bars[i][j].forceupdate = true
    end

    for j=buttons+1,12 do
      if bars[i][j] then
        bars[i][j]:Hide()
      end
    end

    -- adjust actionbar size
    BarLayoutSize(bars[i], buttons, formfactor, size, border)
    bars[i]:SetWidth(bars[i]._size[1])
    bars[i]:SetHeight(bars[i]._size[2])
    bars[i]:ClearAllPoints()
    if i == 1 then -- main
      bars[i]:SetPoint("BOTTOM", 0, 2*border)
    elseif i == 3 then -- left
      bars[i]:SetPoint("BOTTOMLEFT", bars[1], "BOTTOMRIGHT", 3*border, 0)
    elseif i == 4 then -- vertical
      bars[i]:SetPoint("RIGHT", -3*border, 0)
    elseif i == 5 then -- right
      bars[i]:SetPoint("BOTTOMRIGHT", bars[1], "BOTTOMLEFT", -3*border, 0)
    elseif i == 6 then -- top
      bars[i]:SetPoint("BOTTOM", bars[1], "TOP", 0, border)
    elseif i == 11 then -- stances
      bars[i]:SetPoint("BOTTOM", bars[6], "TOP", 0, 3*border)
    elseif i == 12 then -- pet
      bars[i]:SetPoint("BOTTOM", bars[6], "TOP", 0, 3*border)
    else -- others
      bars[i]:SetPoint("TOP", 0, -i*50)
    end

    UpdateMovable(bars[i])

    -- apply backdrop settings
    if background == "1" then
      CreateBackdrop(bars[i])
      bars[i].backdrop:Show()

      -- share backdrop of main and top actionbar
      if i == 6 then
        bars[6].OnMove = bars[6].OnMove or function()
          local _, a, _ = bars[6]:GetPoint()
          if a == bars[1] and C.bars.bar1.enable == "1"
            and C.bars.bar1.background == "1" and C.bars.bar6.background == "1"
            and C.bars.bar1.autohide == "0" and C.bars.bar6.autohide == "0"
            and C.bars.bar1.icon_size == C.bars.bar6.icon_size
            and C.bars.bar1.formfactor == C.bars.bar6.formfactor
            and C.bars.bar1.buttons == C.bars.bar6.buttons
          then
            bars[1].backdrop:ClearAllPoints()
            bars[1].backdrop:SetPoint("BOTTOMRIGHT", bars[1], "BOTTOMRIGHT", border-1, -border+1)
            bars[1].backdrop:SetPoint("TOPLEFT", bars[6].backdrop, "TOPLEFT", 0, 0)
            bars[6].backdrop:Hide()
          else
            if C.bars.bar1.background == "1" then
              -- create/reset bar1 backdrop if required
              CreateBackdrop(bars[1])
              bars[1].backdrop:ClearAllPoints()
              bars[1].backdrop:SetPoint("BOTTOMRIGHT", bars[1], "BOTTOMRIGHT", border-1, -border+1)
              bars[1].backdrop:SetPoint("TOPLEFT", bars[1], "TOPLEFT", -border+1, border-1)
            end

            if C.bars.bar6.background == "1" then
              bars[6].backdrop:Show()
            end
          end
        end

        bars[i].OnMove()
      end
    else
      if bars[i].backdrop then
        bars[i].backdrop:Hide()
      end

      if bars[i].shadow then
        bars[i].shadow:Hide()
      end
    end
  end

  -- create actionbars
  pfUI.bars = bars

  function pfUI.bars:UpdateConfig()
    for i=1,12 do
      CreateActionBar(i)
    end
  end
  pfUI.bars:UpdateConfig()

  -- helper function to update by slot
  local function RefreshSlot(slot)
    local bar, button = ceil(slot/12), mod(slot, 12)
    button = button == 0 and 12 or button
    bars[bar][button].forceupdate = true
  end

  -- custom pagings
  local function pagelimits()
    local min, max = 10, 1
    for i=1, 10 do
      if C.bars["bar"..i] and C.bars["bar"..i].pageable == "1" then
        min = min > i and i or min
        max = max < i and i or max
      end
    end

    return min, max
  end

  -- Localize custom keybinds for additional actionbars (see Bindings.xml)
  local names = {
    ["PAGING"] = "Paging",
    ["STANCEONE"] = "Stance 1",
    ["STANCETWO"] = "Stance 2",
    ["STANCETHREE"] = "Stance 3",
    ["STANCEFOUR"] = "Stance 4",
  }

  for name, loc in pairs(names) do
    _G["BINDING_HEADER_PFBAR"..name] = T["Action Bar"] .. " " .. loc
    for i=1,12 do
      _G["BINDING_NAME_PF" .. name .. i] = loc .. " " .. T["Button"] .. " " .. i
    end
  end

  -- combined button trigger
  function _G.pfActionButton(slot, slf, opt)
    local bar, button = 1, slot

    local slf = C.bars.altself == "1" and IsAltKeyDown() and true or slf

    -- determine the proper bar and button
    if opt and blizzbarmapping[opt] then
      bar = blizzbarmapping[opt]
    elseif slot > 12 then
      bar, button = ceil(slot/12), mod(slot, 12)
      button = button == 0 and 12 or button
    end

    local frame = bars[bar][button]
    if not frame then return end
    local action = frame:GetID()

    if ( pfUI_config.bars.keydown == "1" and keystate == "down" ) or (pfUI_config.bars.keydown == "0" and keystate == "up" ) or bar == 11 then
      -- trigger animation
      if frame:GetAlpha() > 0.1 then
        frame.animation.active = 0
        frame.animation:Show()
      end

      -- clear highlight
      if not MouseIsOver(frame) then frame.highlight:Hide() end

      -- trigger action
      if bar == 12 then
        CastPetAction(action)
      elseif bar == 11 then
        CastShapeshiftForm(action)
      else
        UseAction(action, nil, slf)
      end
    elseif keystate == "down" then
      -- show highlight
      frame.highlight:Show()
    end
  end

  -- In order to be able to reuse already defined keybinds, we need to remap
  -- existing button functions to pfUI (does it break other addon hooks? maybe.)
  -- But we need to get rid of the blizzard calls to avoid having them call
  -- unnecessary texture changes and errors due to missing buttons and such
  _G.ActionButtonDown = pfActionButton
  _G.ActionButtonUp = pfActionButton
  _G.BonusActionButtonDown = function(slot) pfActionButton(slot, nil, "BonusActionBar") end
  _G.BonusActionButtonUp = function(slot) pfActionButton(slot, nil, "BonusActionBar") end
  _G.MultiActionButtonDown = function(bar, slot, slf) pfActionButton(slot, slf, bar) end
  _G.MultiActionButtonUp = function(bar, slot, slf) pfActionButton(slot, slf, bar) end
  _G.ShapeshiftBar_ChangeForm = function(slot) pfActionButton(slot, nil, "ShapeShiftBar") end

  function _G.ActionBar_PageUp()
    local min, max = pagelimits()
    local bar = _G.CURRENT_ACTIONBAR_PAGE + 1
    if bar > max then bar = min end

    for newbar=bar, 10, 1 do
      if C.bars["bar"..newbar] and C.bars["bar"..newbar].pageable == "1" then
        SwitchBar(newbar)
        return
      end
    end
  end

  function _G.ActionBar_PageDown()
    local min, max = pagelimits()
    local bar = _G.CURRENT_ACTIONBAR_PAGE - 1
    if bar < min then bar = max end

    for newbar=bar, 1, -1 do
      if C.bars["bar"..newbar] and C.bars["bar"..newbar].pageable == "1" then
        SwitchBar(newbar)
        return
      end
    end
  end

  -- enable paging on the first actionbar
  local pager = CreateFrame("Frame")
  pager:RegisterEvent("PLAYER_ENTERING_WORLD")
  pager:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
  pager:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
  pager:SetScript("OnEvent", function()
    bar = GetActiveBar()

    for i=1,12 do
      id = i + (bar-1)*12
      bars[1][i].bar = bar
      bars[1][i]:SetID(id)
      bars[1][i].forceupdate = true
    end
  end)

  -- handle drag-drop grid
  local grid = CreateFrame("Frame")
  grid:RegisterEvent("ACTIONBAR_SHOWGRID")
  grid:RegisterEvent("ACTIONBAR_HIDEGRID")
  grid:SetScript("OnEvent", function()
    if event == "ACTIONBAR_SHOWGRID" then
      showgrid = 1
    else
      showgrid = 0
    end
  end)

  -- reagent counter
  local reagent_slots = { }
  local reagent_counts = { }
  local reagent_textureslots = { }
  local reagent_capture = SPELL_REAGENTS.."(.+)"
  local scanner = libtipscan:GetScanner("actionbar")
  local reagentcounter = CreateFrame("Frame", "pfReagentCounter", UIParent)
  reagentcounter:RegisterEvent("PLAYER_ENTERING_WORLD")
  reagentcounter:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
  reagentcounter:RegisterEvent("BAG_UPDATE")
  reagentcounter:SetScript("OnEvent", function()
    if event == "BAG_UPDATE" then
      this.event = true
    else
      for slot = 1, 120 do
        local texture = GetActionTexture(slot)

        -- update buttons that previously had an reagent
        if reagent_slots[slot] and not texture then
          reagent_textureslots[slot] = nil
          reagent_slots[slot] = nil
          RefreshSlot(slot)
        end

        -- search for reagents on buttons with different icon
        if reagent_textureslots[slot] ~= texture then
          if HasAction(slot) then
            reagent_textureslots[slot] = texture
            scanner:SetAction(slot)
            local _, reagents = scanner:Find(reagent_capture)
            if reagents then
              reagent_slots[slot] = reagents
              reagent_counts[reagents] = reagent_counts[reagents] or 0
              RefreshSlot(slot)
            end
          end
        end
      end
    end
  end)

  -- limit bag events to one per second
  reagentcounter:SetScript("OnUpdate", function()
    if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

    if this.event then
      for item in pairs(reagent_counts) do
        reagent_counts[item] = GetItemCount(item)
      end
      for slot in pairs(reagent_slots) do
        RefreshSlot(slot)
      end

      this.event = nil
    end
  end)

  function IsReagentAction(slot)
    return reagent_slots[slot] and true or nil
  end

  function GetReagentCount(slot)
    return reagent_counts[reagent_slots[slot]]
  end

  -- pagemaster / meta page switch
  if C.bars.pagemaster == "1" then
    local modifier = { "ALT", "SHIFT", "CTRL" }
    local buttons = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "+", "=", "´" }
    local shift, ctrl, alt, default = 6, 5, 3, 1
    local current = CURRENT_ACTIONBAR_PAGE

    local pagemaster = CreateFrame("Frame", "pfPageMaster", UIParent)
    pagemaster:RegisterEvent("PLAYER_ENTERING_WORLD")
    pagemaster:SetScript("OnEvent", function()
      for _,mod in pairs(modifier) do
        for _,but in pairs(buttons) do
          SetBinding(mod.."-"..but)
        end
      end
    end)

    pagemaster:SetScript("OnUpdate", function()
      if IsShiftKeyDown() then
        SwitchBar(shift)
      elseif IsControlKeyDown() then
        SwitchBar(ctrl)
      elseif IsAltKeyDown() then
        SwitchBar(alt)
      else
        SwitchBar(default)
      end
    end)
  end
end)
