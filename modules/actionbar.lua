pfUI:RegisterModule("actionbar", "vanilla:tbc", function ()
  local _, class = UnitClass("player")
  local color = RAID_CLASS_COLORS[class]
  local cr, cg, cb = color.r , color.g, color.b
  local er, eg, eb, ea = GetStringColor(pfUI_config.appearance.border.color)

  local backdrop_highlight = { edgeFile = pfUI.media["img:glow"], edgeSize = 8 }
  local showgrid = 0
  local showgrid_pet = 0
  local rawborder, border = GetBorderSize("actionbars")
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  local eventcache = { } -- contains a list of events that shall be processed later -> [event] = true
  local updatecache = { } -- contains a list of buttons slots that shall be refreshed later -> [slot] = true
  local buttoncache = { } -- contains a list of all buttons ever created -> [slot] = frame

  local petvisibility = "[pet] show; hide"

  -- try to assume based on the current mouse positions if a button drag
  -- should happen even if action-on-key-down is used. By that replace the
  -- cast events by reverting the active buttons to the old mouse-up state.
  local drag_await
  local drag_active
  local function AssumeButtonDrag()
    -- skip during combat
    if InCombatLockdown and InCombatLockdown() then return end

    -- skip if keydown press is not enabled
    if C.bars.keydown ~= "1" then return end

    -- skip if always shift-drag is not enabled
    if C.bars.shiftdrag ~= "1" then return end

    if drag_await and not drag_active and IsShiftKeyDown() then
      drag_active = true
      -- set all buttons to regular on release clicks
      for id, button in pairs(buttoncache) do
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
      end
    elseif drag_active and not IsShiftKeyDown() then
      drag_active = nil
      -- set all buttons back to their defaults
      for id, button in pairs(buttoncache) do
        button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
      end
    end
  end

  -- hide blizzard bars
  local function kill(f, killshow)
    if f.Show and killshow then f.Show = function() return end end
    if f.UnregisterAllEvents then f:UnregisterAllEvents() end
    if f.Hide then f:Hide() end
  end

  -- also abbreviate mouse buttons
  local OrigGetBindingText = GetBindingText
  local function GetBindingText(msg, mod, abbrev)
    local txt = OrigGetBindingText(msg, mod, abbrev)
    if abbrev then
      txt = string.gsub(txt, _G[string.format("%s%s", mod, "BUTTON3")], "MB3")
      txt = string.gsub(txt, _G[string.format("%s%s", mod, "BUTTON4")], "MB4")
      txt = string.gsub(txt, _G[string.format("%s%s", mod, "BUTTON5")], "MB5")
      txt = string.gsub(txt, _G[string.format("%s%s", mod, "MOUSEWHEELDOWN")], "MWD")
      txt = string.gsub(txt, _G[string.format("%s%s", mod, "MOUSEWHEELUP")], "MWU")
    end
    return txt
  end

  kill(MainMenuBar)

  local blizzard_elements = { MultiBarBottomLeft,
    MultiBarBottomRight, MultiBarLeft, MultiBarRight }
  for _, f in pairs(blizzard_elements) do
    kill(f, true)
  end

  -- enable all possible actionbar pages
  SetActionBarToggles(0, 0, 0, 0)
  _G.SHOW_MULTI_ACTIONBAR_1 = nil
  _G.SHOW_MULTI_ACTIONBAR_2 = nil
  _G.SHOW_MULTI_ACTIONBAR_3 = nil
  _G.SHOW_MULTI_ACTIONBAR_4 = nil

  -- events that provide special updater functions
  local special_events = {
    ["ACTIONBAR_UPDATE_COOLDOWN"] = true,
    ["ACTIONBAR_UPDATE_USABLE"] = true,
    ["ACTIONBAR_UPDATE_STATE"] = true,
  }

  -- events that are shared across all buttons
  local global_events = {
    -- slot/button updates
    ["PLAYER_ENTERING_WORLD"] = true,
    ["ACTIONBAR_SLOT_CHANGED"] = true,
    ["UPDATE_BINDINGS"] = true,
    ["ACTIONBAR_PAGE_CHANGED"] = true,
    ["UPDATE_BONUS_ACTIONBAR"] = true,
    ["CRAFT_SHOW"] = true,
    ["CRAFT_CLOSE"] = true,
    ["TRADE_SKILL_SHOW"] = true,
    ["TRADE_SKILL_CLOSE"] = true,
    ["PLAYER_ENTER_COMBAT"] = true,
    ["PLAYER_LEAVE_COMBAT"] = true,
    -- cooldown updates
    ["UNIT_INVENTORY_CHANGED"] = true,
    -- auto repeat action
    ["START_AUTOREPEAT_SPELL"] = true,
    ["STOP_AUTOREPEAT_SPELL"] = true,
  }

  -- events that are used for the aura/shapeshift bar
  local aura_events = {
    ["UPDATE_SHAPESHIFT_FORMS"] = true,
    ["PLAYER_AURAS_CHANGED"] = true,
  }

  -- events that are used for the pet bar
  local pet_events = {
    ["PLAYER_CONTROL_LOST"] = true,
    ["PLAYER_CONTROL_GAINED"] = true,
    ["PLAYER_FARSIGHT_FOCUS_CHANGED"] = true,
    ["UNIT_PET"] = true,
    ["PET_BAR_UPDATE"] = true,
    ["PET_BAR_UPDATE_COOLDOWN"] = true,
  }

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

  local function ButtonDrag(self)
    -- skip during combat
    if InCombatLockdown and InCombatLockdown() then return end

    local self = self or this

    if _G.LOCK_ACTIONBAR == "1" and not (pfUI_config.bars.shiftdrag == "1" and IsShiftKeyDown()) then return end

    if self.bar == 12 then
      PickupPetAction(self.id)
    else
      PickupAction(self.id)
    end
  end

  local function ButtonDragStop(self)
    -- skip during combat
    if InCombatLockdown and InCombatLockdown() then return end

    local self = self or this

    if MacroFrame_SaveMacro then
      MacroFrame_SaveMacro()
    end

    if self.bar == 12 then
      PickupPetAction(self.id)
    else
      PlaceAction(self.id)
    end
  end

  local mouse
  local function ButtonAnimate(self)
    local self = self or this
    mouse = arg1 and not keystate

    -- trigger action animation
    if ( pfUI_config.bars.keydown == "1" and keystate == "down" ) or (pfUI_config.bars.keydown == "0" and keystate == "up" ) or self.bar == 11 or mouse then
      if C.bars.animmode == "keypress" and ( self:GetAlpha() > .1  or C.bars.animalways == "1" ) then
        self.animation.active = 0
        self.animation:Show()
      end
    end

    -- handle button highlight
    if keystate == "down" then
      self.highlight:Show()
    elseif not MouseIsOver(self) then
      self.highlight:Hide()
    end
  end

  local function ButtonClick(self)
    local self = self or this

    local grid = self.bar == 12 and showgrid_pet or showgrid
    local mouse = arg1 and not keystate
    local keystate = keystate
    local slfcast = C.bars.altself == "1" and IsAltKeyDown() and true or self.slfcast
    slfcast = C.bars.rightself == "1" and arg1 and arg1 == "RightButton" and true or slfcast
    self.slfcast = nil

    if ( pfUI_config.bars.keydown == "1" and keystate == "down" and not drag_active ) or (pfUI_config.bars.keydown == "0" and keystate == "up" or drag_active ) or self.bar == 11 or mouse then
      if self.bar == 11 then
        CastShapeshiftForm(self.id)
      elseif grid == 1 then
        if self.bar == 12 then
          PickupPetAction(self.id)
        else
          PickupAction(self.id)
        end
      elseif self.bar == 12 then
        if arg1 == "LeftButton" then
          if IsPetAttackActive(self.id) then
            PetStopAttack()
          else
            CastPetAction(self.id)
          end
        else
          TogglePetAutocast(self.id)
        end
      else
        if MacroFrame_SaveMacro then
          MacroFrame_SaveMacro()
        end

        UseAction(self.id, nil, slfcast)
      end
    end
  end

  local function ButtonMacroScan(self)
    if self.bar > 10 then return end
    if not self.scanmacro then return end
    if pfUI.bars.skip_macro then return end

    local macro = GetActionText(self.id)
    self.spellslot = nil
    self.booktype = nil
    if macro then
      local slot = GetMacroIndexByName(macro)
      local name, _, body = GetMacroInfo(slot)

      if name and body then
        local match

        for line in gfind(body, "[^%\n]+") do
          _, _, match = string.find(line, '^#showtooltip (.+)')

          -- skip any further manual macro scanning on
          -- gameclients with native macro spell detection
          if pfUI.client > 11200 and match then
            self.spellslot = nil
            self.booktype = nil
            return
          end

          -- allow the user to disable the scan
          if match and strfind(match, "disable") then
            return
          end

          if not match then
            -- add support to specify custom tooltips via:
            --  /run --showtooltip SPELLNAME
            _, _, match = string.find(line, '%-%-showtooltip (.+)')
          end

          if not match then
            _, _, match = string.find(line, '^/cast (.+)')
          end

          if not match then
            _, _, match = string.find(line, '^/pfcast (.+)')
          end

          if not match then
            _, _, match = string.find(line, '^/pfmouse (.+)')
          end

          if not match then
            _, _, match = string.find(line, 'CastSpellByName%(%"(.+)%"%)')
          end

          if match then
            local _, _, spell, rank = string.find(match, '(.+)%((.+)%)')
            spell = spell or match
            self.spellslot, self.booktype = libspell.GetSpellIndex(spell, rank)

            if self.spellslot and self.spellslot > 0 then return end
          end
        end
      end
    end
  end

  local function ButtonEnter(self)
    local self = self or this

    -- indicate that dragging could get enabled
    drag_await = true

    GameTooltip:ClearLines()
    GameTooltip_SetDefaultAnchor(GameTooltip, self)

    if self.bar == 11 then
      GameTooltip:SetShapeshift(self.id)
    elseif self.bar == 12 then
      local name, _, _, token = GetPetActionInfo(self.id)
      if token then
        GameTooltip:AddLine(_G[name])
        GameTooltip:Show()
      else
        GameTooltip:SetPetAction(self.id)
      end
    elseif self.spellslot and self.booktype then
      GameTooltip:SetSpell(self.spellslot, self.booktype)
    else
      GameTooltip:SetAction(self.id)
    end

    self.highlight:Show()
  end

  local function ButtonLeave(self)
    local self = self or this

    -- no longer wait for a drag event
    drag_await = nil

    self.highlight:Hide()
    GameTooltip:Hide()
  end

  local start, duration, enable, castable, autocast, token
  local grid, sid, id, bar, active, texture, _
  local function ButtonSlotUpdate(self)
    if not self then return end
    local self = self or this
    sid = self.id -- 1 to 120

    -- reset shared variables
    castable, autocast, token = nil, nil, nil

    -- set the own ID for compatibility to some vanilla addons
    if pfUI.client <= 11200 then self:SetID(self.id) end

    grid = self.bar == 12 and showgrid_pet or showgrid

    if self.bar == 11 then
      -- stance button
      bar = self.bar
      id = sid
      texture, _, active = GetShapeshiftFormInfo(id)
    elseif self.bar == 12 then
      -- pet button
      bar = self.bar
      id = sid
      _, _, texture, token, active, castable, autocast = GetPetActionInfo(id)
      texture = token and _G[texture] or texture
    else
      active = IsCurrentAction(sid) or IsAutoRepeatAction(sid)
      texture = GetActionTexture(sid)
      bar = GetActiveBar()
      id = self.bar == 1 and self.slot or sid-((self.bar)-1)*12
    end

    -- overwrite with spell macro texture where possible
    if self.spellslot and self.booktype then
      texture = GetSpellTexture(self.spellslot, self.booktype)
    end

    if not self.showempty and self.backdrop and not texture and grid == 0 then
      self.backdrop:Hide()
      self.hide = true
    else
      self.backdrop:Show()
      self.hide = nil
    end

    -- active border
    if active then
      if C.bars.animmode == "statechange" and not self.active:IsShown() then
        self.animation.active = 0
        self.animation:Show()
      end

      self.backdrop:SetBackdropBorderColor(cr,cg,cb,1)
      self.active:Show()
    else
      self.backdrop:SetBackdropBorderColor(er,eg,eb,ea)
      self.active:Hide()
    end

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
      if C.bars["bar"..self.bar] and C.bars["bar"..self.bar].showmacro == "1" then
        self.macro:SetText(GetActionText(sid))
      else
        self.macro:SetText("")
      end
    end

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
        self.autocast:SetAlpha(self:GetAlpha() * 0.10)
      else
        self.autocast:Hide()
      end

      if castable and C.bars.showcastable == "1" then
        self.autocastable:Show()
      else
        self.autocastable:Hide()
      end
    end

    -- keybinds
    if not self.hide and self.bar == 1 and self.bar ~= 11 and self.bar ~= 12 then
      self.keybind:SetText(GetBindingText(GetBindingKey("ACTIONBUTTON"..id), "KEY_", 1))
    elseif not self.hide and buttontypes[self.bar] then
      self.keybind:SetText(GetBindingText(GetBindingKey(buttontypes[self.bar]..id), "KEY_", 1))
    else
      self.keybind:SetText("")
    end
  end

  local sid, usable, oom, _
  local function ButtonUsableUpdate(self)
    local self = self or this
    sid = self.id -- 1 to 120

    if self.bar == 11 then
      _, _, _, usable = GetShapeshiftFormInfo(sid)
    elseif self.bar == 12 then
      usable = true
    else
      usable, oom = IsUsableAction(sid)
    end

    -- update usable [out-of-range = 1, oom = 2, not-usable = 3, default = 0]
    if self.outofrange and C.bars.glowrange == "1" then
      if self.vertexstate ~= 1 then
        self.icon:SetVertexColor(self.rangeColor[1], self.rangeColor[2], self.rangeColor[3], self.rangeColor[4])
        self.vertexstate = 1
      end
    elseif oom and C.bars.showoom == "1" then
      if self.vertexstate ~= 2 then
        self.icon:SetVertexColor(self.oomColor[1], self.oomColor[2], self.oomColor[3], self.oomColor[4])
        self.vertexstate = 2
      end
    elseif not usable and C.bars.showna == "1" then
      if self.vertexstate ~= 3 then
        self.icon:SetVertexColor(self.naColor[1], self.naColor[2], self.naColor[3], self.naColor[4])
        self.vertexstate = 3
      end
    else
      if self.vertexstate ~= 0 then
        self.icon:SetVertexColor(1, 1, 1, 1)
        self.vertexstate = 0
      end
    end
  end

  local function ButtonRangeUpdate(self)
    local self = self or this

    -- update range display
    if C.bars.glowrange == "1" and self.bar ~= 11 and self.bar ~= 12 and HasAction(self.id) and ActionHasRange(self.id) and IsActionInRange(self.id) == 0 then
      if not self.outofrange then
        self.outofrange = true
        ButtonUsableUpdate(self)
      end
    elseif self.outofrange then
      self.outofrange = nil
      ButtonUsableUpdate(self)
    end
  end

  local start, duration, enable
  local function ButtonCooldownUpdate(button)
    if not button then return end

    if button.bar == 11 then
      start, duration, enable = GetShapeshiftFormCooldown(button.id)
    elseif button.bar == 12 then
      start, duration, enable = GetPetActionCooldown(button.id)
    elseif button.spellslot and button.booktype then
      start, duration = GetSpellCooldown(button.spellslot, button.booktype)
      enable = 1
    else
      start, duration, enable = GetActionCooldown(button.id)
    end

    CooldownFrame_SetTimer(button.cd, start, duration, enable)
  end

  local _, active
  local function ButtonIsActiveUpdate(button)
    if not button then return end

    if button.bar == 11 then
      _, _, active, _ = GetShapeshiftFormInfo(button.id)
    elseif button.bar == 12 then
      _, _, _, _, active, _, _ = GetPetActionInfo(button.id)
    else
      active = IsCurrentAction(button.id) or IsAutoRepeatAction(button.id)
    end

    -- active border
    if active then
      if not button.border_active then
        button.backdrop:SetBackdropBorderColor(cr,cg,cb,1)
        button.border_active = true
      end

      button.active:Show()
    else
      if button.border_active then
        button.backdrop:SetBackdropBorderColor(er,eg,eb,ea)
        button.border_active = nil
      end

      button.active:Hide()
    end
  end


  local function ButtonFullUpdate(button)
    if not button then return end

    ButtonMacroScan(button)
    ButtonSlotUpdate(button)
    ButtonRangeUpdate(button)
    ButtonUsableUpdate(button)
    ButtonCooldownUpdate(button)
    ButtonIsActiveUpdate(button)
  end

  local function BarsEvent(self)
    local self = self or this

    -- refresh only specific slots
    if event == "ACTIONBAR_SLOT_CHANGED" and arg1 and arg1 ~= 0 then
      updatecache[arg1] = true
      return
    end

    -- run special refresh functions on next update
    if special_events[event] then
      eventcache[event] = true
      return
    end

    -- handle aura events
    if aura_events[event] then
      for j=1,12 do
        if self[11] and self[11][j] then
          updatecache[self[11][j].slot] = true
        end
      end
      return
    end

    -- handle pet events
    if pet_events[event] then
      for j=1,12 do
        if self[12] and self[12][j] then
          updatecache[self[12][j].slot] = true
        end
      end
      return
    end

    -- handle global events
    for id in pairs(buttoncache) do
      updatecache[id] = true
    end
  end

  local self, button, unlock
  local function BarsUpdate(self)
    self = self or this

    -- update buttons whenever a button drag is assumed
    AssumeButtonDrag()

    if pfUI.unlock then
      -- update all bars when entering unlock
      if pfUI.unlock:IsShown() ~= unlock then
        pfUI.bars:UpdateConfig()
        unlock = pfUI.unlock:IsShown()
      end
    end

    -- run cached usable usable actions
    if eventcache["ACTIONBAR_UPDATE_USABLE"] then
      eventcache["ACTIONBAR_UPDATE_USABLE"] = nil
      for id, button in pairs(buttoncache) do
        ButtonUsableUpdate(button)
      end
    end

    -- run cached cooldown events
    if eventcache["ACTIONBAR_UPDATE_COOLDOWN"] then
      eventcache["ACTIONBAR_UPDATE_COOLDOWN"] = nil
      for id, button in pairs(buttoncache) do
        ButtonCooldownUpdate(button)
      end
    end

    -- run cached action state events
    if eventcache["ACTIONBAR_UPDATE_STATE"] then
      eventcache["ACTIONBAR_UPDATE_STATE"] = nil
      for id, button in pairs(buttoncache) do
        ButtonIsActiveUpdate(button)
      end
    end

    for id in pairs(updatecache) do
      -- run updates based on slot
      pfUI.bars.ButtonFullUpdate(buttoncache[id])

      -- run updates on paging actionbar if required
      for i=1,12 do
        if pfUI.bars[1][i].id == id then
          pfUI.bars.ButtonFullUpdate(pfUI.bars[1][i])
        end
      end

      -- clear update cache
      updatecache[id] = nil
    end

    if ( this.tick or .2) > GetTime() then return else this.tick = GetTime() + .2 end

    for id, button in pairs(buttoncache) do
      if button:IsShown() then ButtonRangeUpdate(button) end
    end
  end

  -- create the main event and update handler for pfUI actionbars
  local bars = CreateFrame("Frame", "pfActionBar", UIParent)
  for event in pairs(special_events) do bars:RegisterEvent(event) end
  for event in pairs(global_events) do bars:RegisterEvent(event) end
  for event in pairs(aura_events) do bars:RegisterEvent(event) end
  for event in pairs(pet_events) do bars:RegisterEvent(event) end

  -- refresh actionbar buttons on event
  bars:SetScript("OnEvent", BarsEvent)

  -- update actionbar buttons
  bars:SetScript("OnUpdate", BarsUpdate)

  -- enable bar paging via secure functions
  local function ButtonSwitch(self, att, value)
    if att == "state-parent" then
      local action = SecureButton_GetModifiedAttribute(self, "action", SecureStateChild_GetEffectiveButton(self)) or self.id
      if self.id == action then return end
      updatecache[self.slot] = true
      self.id = action
    end
  end

  local function EnablePaging(bar)
    if pfUI.client <= 11200 then
      if not bar.pager then
        bar.pager = CreateFrame("Frame")
        bar.pager:RegisterEvent("PLAYER_ENTERING_WORLD")
        bar.pager:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
        bar.pager:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
        bar.pager:SetScript("OnEvent", function()
          for i=1, 10 do -- reload pageable bars
            local pageable = C.bars["bar"..i] and C.bars["bar"..i].pageable == "1" and true or nil
            _G.VIEWABLE_ACTION_BAR_PAGES[i] = pageable
          end

          local active = GetActiveBar()
          for i=1,12 do
            local id = i + (active-1)*12
            bar[i].id = id
            updatecache[i] = true
          end
        end)
      end
    else
      -- append paging enabled bars to the filter list
      for i=1,12 do bar[i]:SetScript("OnAttributeChanged", ButtonSwitch) end

      -- fill all possible page states
      local page, pages = nil, {}
      while not pages[6] do
        for i=1, 6 do
          page = i == 1 and 1 or C.bars["bar"..i] and C.bars["bar"..i].pageable == "1" and i
          if page then table.insert(pages, page) end
        end
      end

      bar:SetAttribute("statemap-page", "$input")
      bar:SetAttribute("state", (bar:GetAttribute("state-page") or 1))

      -- prio posses bar
      bar.filter = "[bonusbar: 5] 11;"

      -- set bar 8 for druid stealth if enabled
      local prowl = class == "DRUID" and C.bars["druidstealth"] == "1" and "8" or "7"

      -- write default pages
      for state, page in pairs(pages) do
        if page ~= 1 then -- skip page 1 as it is supposed to stay dynamic for stances
          bar.filter = string.format("%s[actionbar: %s] %s; ", bar.filter, state, page)
        end
      end

      -- write page driver conditions
      bar.filter = string.format("%s[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] %s; [bonusbar:2] 10; [bonusbar:3] 9; [bonusbar:4] 10; 1", bar.filter, prowl)

      -- prepend pagemaster states if enabled
      if C.bars.pagemaster == "1" then
        for mod, page in pairs({ ["shift"] = "6", ["ctrl"] = "5", ["alt"] = "3" }) do
          bar.filter = string.format("[modifier:%s] %s;", mod, page) .. bar.filter
        end
      end

      -- enable page driver conditions
      RegisterStateDriver(bar, "page", bar.filter)
      SecureStateHeader_Refresh(bar)
    end
  end

  local function SwitchBar(bar)
    if _G.CURRENT_ACTIONBAR_PAGE ~= bar then
      _G.CURRENT_ACTIONBAR_PAGE = bar
      ChangeActionBarPage(bar)
    end
  end

  local cat, stealth
  local function IsCatStealth()
    if class ~= "DRUID" then return nil end
    cat, stealth = nil, nil

    for i = 0, 31 do
      local texture = GetPlayerBuffTexture(i)
      if not texture then break end

      -- catform icon detected
      if strfind(texture, "Ability_Druid_CatForm") then
        if stealth then return true end
        cat = true
      end

      -- stealth icon detected
      if strfind(texture, "Ability_Ambush") then
        if cat then return true end
        stealth = true
      end
    end
    return nil
  end

  -- pagemaster / meta page switch
  if pfUI.expansion == "vanilla" then
    local prowl, shift, ctrl, alt, default = 8, 6, 5, 3, 1

    -- set temporary pagemaster bindings keybinds
    if C.bars.pagemaster == "1" then
      local modifier = { "ALT", "SHIFT", "CTRL" }
      local buttons = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "+", "=", "´" }
      local current = CURRENT_ACTIONBAR_PAGE
      bars.pagemaster = bars.pagemaster or CreateFrame("Frame", "pfPageMaster", UIParent)
      bars.pagemaster:RegisterEvent("PLAYER_ENTERING_WORLD")
      bars.pagemaster:SetScript("OnEvent", function()
        for _,mod in pairs(modifier) do
          for _,but in pairs(buttons) do
            SetBinding(mod.."-"..but)
          end
        end
      end)
    end

    -- setup page switch frame
    local pageswitch = CreateFrame("Frame", "pfActionBarPageSwitch", UIParent)
    pageswitch:SetScript("OnUpdate", function()
      -- switch actionbar page depending on meta key that is pressed
      if C.bars.pagemastershift == "1" and IsShiftKeyDown() then
        SwitchBar(shift)
        return
      elseif C.bars.pagemasterctrl == "1" and IsControlKeyDown() then
        SwitchBar(ctrl)
        return
      elseif C.bars.pagemasteralt == "1" and IsAltKeyDown() then
        SwitchBar(alt)
        return
      elseif C.bars.pagemasteralt == "1" or C.bars.pagemasterctrl == "1" or C.bars.pagemastershift == "1" then
        SwitchBar(default)
      end

      -- switch actionbar page if druid stealth is detected
      if C.bars.druidstealth == "1" then
        local stealth = IsCatStealth()
        if stealth and _G.CURRENT_ACTIONBAR_PAGE == 1 then
          SwitchBar(prowl)
        elseif not stealth and _G.CURRENT_ACTIONBAR_PAGE == 8 then
          SwitchBar(default)
        end
      end
    end)
  end

  local function CreateActionButton(parent, bar, button)
    -- load config
    local size = C.bars["bar"..bar].icon_size
    local font = pfUI.media[C.bars.font]
    local font_offset = tonumber(C.bars.font_offset)

    local macro_size = tonumber(C.bars.macro_size)
    local macro_color = { strsplit(",", C.bars.macro_color) }

    local count_size = tonumber(C.bars.count_size)
    local count_color = { strsplit(",", C.bars.count_color) }

    local bind_size = tonumber(C.bars.bind_size)
    local bind_color = { strsplit(",", C.bars.bind_color) }

    local cd_size = tonumber(C.bars.cd_size)

    local showempty = C.bars["bar"..bar].showempty
    local showmacro = C.bars["bar"..bar].showmacro
    local showkybind = C.bars["bar"..bar].showkeybind
    local showcount = C.bars["bar"..bar].showcount

    -- sanitize font sizes
    if macro_size == 0 then macro_size = 1 end
    if count_size == 0 then macro_size = 1 end
    if bind_size == 0 then macro_size = 1 end
    if cd_size == 0 then cd_size = nil end

    local button_name = "pfActionBar" .. barnames[bar] .. "Button" .. button

    local id = (bar-1)*12+button
    local exists = _G[button_name] and true or nil
    local f = _G[button_name] or CreateFrame("Button", button_name, parent, ACTIONBAR_SECURE_TEMPLATE_BUTTON)

    -- no button available, create a new one
    if not exists then
      -- prepare the button for vanilla
      if not f.HookScript then
        f.HookScript = HookScript
        f:SetScript("OnClick", ButtonClick)
      end

      if bar ~= 11 then
        f:RegisterForDrag("LeftButton", "RightButton")
        f:SetScript("OnDragStart", ButtonDrag)
        f:SetScript("OnReceiveDrag", ButtonDragStop)
      end

      -- add mouseovers
      f:SetScript("OnEnter", ButtonEnter)
      f:SetScript("OnLeave", ButtonLeave)

      -- add click animation handler
      f:HookScript("OnClick", ButtonAnimate)
      f.id = id

      -- set a static slot
      f.slot = id

      -- cooldown
      f.cd = CreateFrame(COOLDOWN_FRAME_TYPE, f:GetName() .. "Cooldown", f, "CooldownFrameTemplate")
      f.cd.pfCooldownStyleAnimation = 1
      f.cd.pfCooldownType = "NOGCD"
      f.cd.pfCooldownSize = cd_size

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

      -- add to buttoncache
      buttoncache[id] = f
    end

    -- set required attributes for regular tbc buttons
    if pfUI.client > 11200 then
      if bar == 11 then
        f:SetAttribute("type", "spell")
        f:SetAttribute('spell', select(2, GetShapeshiftFormInfo(button)))
      elseif bar == 12 then
        f:SetAttribute("type1", "pet")
        f:SetAttribute("action1", button)
        f:SetAttribute("type2", "macro")
        f:SetAttribute("macrotext2", "/click PetActionButton".. button .. " RightButton")
      else
        bars[bar]:SetAttribute("addchild", f)
        f:SetAttribute("type", "action")
        f:SetAttribute("action", id)
        f:SetAttribute("checkselfcast", true)
        f:SetAttribute("useparent-unit", true)
        f:SetAttribute("useparent-statebutton", true)

        for state = 0, 11 do -- add custom states
          local action = ((state == 0 and bar or state)-1)*12+button
          f:SetAttribute(string.format("*type-S%d", state), "action")
          f:SetAttribute(string.format("*type-S%dRight", state), "action")
          f:SetAttribute(string.format("*action-S%d", state), action)
          f:SetAttribute(string.format("*action-S%dRight", state), action)
          if C.bars.rightself == "1" then
            f:SetAttribute(string.format("*unit-S%dRight", state), "player")
          else
            f:SetAttribute(string.format("*unit-S%dRight", state), nil)
          end
        end
      end
    end

    -- set keydown option
    if C.bars.keydown == "1" then
      f:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    else
      f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end

    -- set animation
    f.animation:SetScript("OnUpdate", button_animations[C.bars.animation])

    -- pet autocast
    if bar == 12 then
      f.autocast:SetScale(C.bars["bar"..bar].icon_size / 25)
      f.autocast:SetAlpha(.10)
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
    f.keybind:SetNonSpaceWrap(false)

    -- item count options
    if showcount == "1" then f.count:Show() else f.count:Hide() end
    SetAllPointsOffset(f.count, f, font_offset, -font_offset)
    f.count:SetFont(font, count_size, "OUTLINE")
    f.count:SetTextColor(unpack(count_color))
    f.count:SetJustifyH("RIGHT")
    f.count:SetJustifyV("BOTTOM")

    -- macro spell scan
    if C.bars.macroscan == "0" then
      f.scanmacro, f.spellslot, f.booktype = nil, nil, nil
    else
      f.scanmacro = true
    end

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
    CreateBackdrop(f, border)

    return f
  end

  local function CreateActionBar(i)
    -- load config
    local buttonbasename = "pfActionBar" .. barnames[i] .. "Button"
    local enable = C.bars["bar"..i].enable
    local size = C.bars["bar"..i].icon_size
    local spacing = C.bars["bar"..i].spacing
    local background = C.bars["bar"..i].background
    local formfactor = C.bars["bar"..i].formfactor
    local autohide = C.bars["bar"..i].autohide
    local hide_time = C.bars["bar"..i].hide_time
    local hide_combat = C.bars["bar"..i].hide_combat == "1" and true or nil

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

    -- the stored layout is invalid, temporary fallback
    if not pfGridmath[buttons][BarLayoutFormfactor(formfactor)] then
      formfactor = BarLayoutOptions(buttons)[1]
    end

    local font = pfUI.font_unit
    local font_size = C.global.font_unit_size

    local realsize = size+border*2

    -- create frame
    local init = not bars[i]
    bars[i] = bars[i] or CreateFrame("Frame", "pfActionBar" .. barnames[i], UIParent, ACTIONBAR_SECURE_TEMPLATE_BAR)
    bars[i]:SetID(i)

    -- autohide
    if autohide == "1" then
      EnableAutohide(bars[i], tonumber(hide_time), hide_combat)
    else
      DisableAutohide(bars[i])
    end

    -- apply visible settings
    if enable == "1" then
      -- handle pet bar
      if i == 12 then
        if pfUI.client > 11200 then
          if InCombatLockdown and InCombatLockdown() then
            -- don't process those events during combat
          else
            -- set state driver for pet bars
            bars[i]:SetAttribute("unit", "pet")
            local visibility = pfUI.unlock and pfUI.unlock:IsShown() and "show" or petvisibility
            if bars[i].visibility ~= visibility then
              RegisterStateDriver(bars[i], 'visibility', visibility)
              bars[i].visibility = visibility
            end
          end
        else
          -- only show when pet actions exists
          if PetHasActionBar() or pfUI.unlock and pfUI.unlock:IsShown() then
            bars[i]:Show()
          else
            bars[i]:Hide()
          end

          -- show/hide petbar on petbar updates
          if init then
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
          end
        end

      -- handle shapeshift bar
      elseif i == 11 then
        -- only show when shapeshifts exist
        if GetNumShapeshiftForms() > 0 then
          bars[i]:Show()
        else
          bars[i]:Hide()
        end

        -- update shapeshift bar when amount of spells changes
        if init then
          bars[i]:RegisterEvent("PLAYER_ENTERING_WORLD")
          bars[i]:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
          bars[i]:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
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
        end

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

      BarButtonAnchor(bars[i][j], buttonbasename, j, buttons, formfactor, size, border, spacing)
      bars[i][j]:ClearAllPoints()
      bars[i][j]:SetPoint(unpack(bars[i][j]._anchor))
      bars[i][j]:Show()

      if i > 10 then
        bars[i][j].id = j
      end

      -- refresh button
      updatecache[bars[i][j].slot] = true
    end

    for j=buttons+1,12 do
      if bars[i][j] then
        bars[i][j]:Hide()
      end
    end

    -- add up to 0-11 button parent states to each bar
    if i <= 10 and pfUI.client > 11200 then
      bars[i]:SetAttribute("statebutton", "0:S0;1:S1;2:S2;3:S3;4:S4;5:S5;6:S6;7:S7;8:S8;9:S9;10:S10;11:S11;")
      bars[i]:SetAttribute("statebutton2", "0:S0Right;1:S1Right;2:S2Right;3:S3Right;4:S4Right;5:S5Right;6:S6Right;7:S7Right;8:S8Right;9:S9Right;10:S10Right;11:S11Right;")
    end

    -- enable paging for the first actionbar
    if i == 1 then
      EnablePaging(bars[i])
    end

    -- adjust actionbar size
    BarLayoutSize(bars[i], buttons, formfactor, size, border, spacing)
    bars[i]:SetWidth(bars[i]._size[1])
    bars[i]:SetHeight(bars[i]._size[2])
    bars[i]:ClearAllPoints()
    if i == 1 then -- main
      bars[i]:SetPoint("BOTTOM", 0, 2*border)
    elseif i == 3 then -- left
      bars[i]:SetPoint("BOTTOMLEFT", bars[1], "BOTTOMRIGHT", 3*border, 0)
    elseif i == 4 then -- vertical
      bars[i]:SetPoint("RIGHT", -2*border, 0)
    elseif i == 5 then -- right
      bars[i]:SetPoint("BOTTOMRIGHT", bars[1], "BOTTOMLEFT", -3*border, 0)
    elseif i == 6 then -- top
      bars[i]:SetPoint("BOTTOM", bars[1], "TOP", 0, -spacing)
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
      CreateBackdrop(bars[i], border)
      CreateBackdropShadow(bars[i])
      bars[i].backdrop:Show()
    elseif bars[i].backdrop then
      bars[i].backdrop:Hide()
    end

    -- share backdrop of main and top actionbar
    if bars[6] and bars[1] then
      bars[6].OnMove = bars[6].OnMove or function()
        bars[1].mergedBackdrop = bars[1].mergedBackdrop or CreateFrame("Frame", nil, UIParent)
        bars[1].mergedBackdrop:SetPoint("TOPLEFT", bars[6], "TOPLEFT", 0, 0)
        bars[1].mergedBackdrop:SetPoint("BOTTOMRIGHT", bars[1], "BOTTOMRIGHT", 0, 0)
        CreateBackdrop(bars[1].mergedBackdrop)

        local _, anchor, _ = bars[6]:GetPoint()
        if anchor == bars[1] and C.bars.bar1.enable == "1"
          and C.bars.bar1.enable == "1" and C.bars.bar6.enable == "1"
          and C.bars.bar1.background == "1" and C.bars.bar6.background == "1"
          and C.bars.bar1.autohide == "0" and C.bars.bar6.autohide == "0"
          and C.bars.bar1.icon_size == C.bars.bar6.icon_size
          and C.bars.bar1.spacing == C.bars.bar6.spacing
          and C.bars.bar1.formfactor == C.bars.bar6.formfactor
          and C.bars.bar1.buttons == C.bars.bar6.buttons
        then
          bars[1].mergedBackdrop:Show()
          bars[1].backdrop:Hide()
          bars[6].backdrop:Hide()
        else
          bars[1].mergedBackdrop:Hide()

          if C.bars.bar1.background == "1" and bars[1].backdrop then
            bars[1].backdrop:Show()
          end

          if C.bars.bar6.background == "1" and bars[6].backdrop then
            bars[6].backdrop:Show()
          end
        end
      end
      bars[6].OnMove()
    end
  end

  -- create actionbars
  pfUI.bars = bars
  pfUI.bars.update = updatecache
  pfUI.bars.buttons = buttoncache
  pfUI.bars.ButtonFullUpdate = ButtonFullUpdate
  pfUI.bars.ButtonEnter = ButtonEnter
  pfUI.bars.ButtonLeave = ButtonLeave

  pfUI.bars.UpdateGrid = function(self, state, typ)
    if not typ then
      showgrid = state

      for id in pairs(buttoncache) do
        updatecache[id] = true
      end
    elseif typ == "PET" then
      showgrid_pet = state
      for slot=133,142 do
        updatecache[slot] = true
      end
    end
  end

  pfUI.bars.UpdateConfig = function(self)
    for i=1,12 do
      CreateActionBar(i)
    end
  end

  pfUI.bars:UpdateConfig()

  -- Localize custom keybinds for additional actionbars (see Bindings.xml)
  local names = {
    ["PAGING"] = T["Paging Actionbar"],
    ["STANCEONE"] = T["Stance Bar 1"],
    ["STANCETWO"] = T["Stance Bar 2"],
    ["STANCETHREE"] = T["Stance Bar 3"],
    ["STANCEFOUR"] = T["Stance Bar 4"],
  }

  for name, loc in pairs(names) do
    _G["BINDING_HEADER_PFBAR"..name] = T["Action Bar"] .. " " .. loc
    for i=1,12 do
      _G["BINDING_NAME_PF" .. name .. i] = loc .. " " .. T["Button"] .. " " .. i
    end
  end

  -- Map Keybinds to button clicks
  function _G.pfActionButton(slot, slfcast, opt)
    if ChatFrameEditBox:IsShown() then return end

    local bar, button = 1, slot

    -- determine the proper bar and button
    if opt and blizzbarmapping[opt] then
      bar = blizzbarmapping[opt]
    elseif slot > 12 then
      bar, button = ceil(slot/12), mod(slot, 12)
      button = button == 0 and 12 or button
    end

    local frame = bars[bar][button]
    if frame then
      frame.slfcast = slfcast
      frame:Click()
    end
  end

  -- Set keybinds to all actionbuttons
  if pfUI.client <= 11200 then
    -- In order to be able to reuse already defined keybinds, we need to remap
    -- existing button functions to pfUI. We need to get rid of the blizzard calls
    -- to avoid having them call texture changes and errors due to missing buttons
    _G.ActionButtonDown = pfActionButton
    _G.ActionButtonUp = pfActionButton
    _G.BonusActionButtonDown = function(slot) pfActionButton(slot, nil, "BonusActionBar") end
    _G.BonusActionButtonUp = function(slot) pfActionButton(slot, nil, "BonusActionBar") end
    _G.MultiActionButtonDown = function(bar, slot, slf) pfActionButton(slot, slf, bar) end
    _G.MultiActionButtonUp = function(bar, slot, slf) pfActionButton(slot, slf, bar) end
    _G.ShapeshiftBar_ChangeForm = function(slot) pfActionButton(slot, nil, "ShapeShiftBar") end
  else
    local bindwraps = {
      ["ACTIONBUTTON%d"] = 1,
      ["SHAPESHIFTBUTTON%d"] = 11, -- ShapeShiftBar
      ["BONUSACTIONBUTTON%d"] = 12, -- BonusActionBar
      ["MULTIACTIONBAR1BUTTON%d"] = 6, -- MultiBarBottomLeft
      ["MULTIACTIONBAR2BUTTON%d"] = 5, -- MultiBarBottomRight
      ["MULTIACTIONBAR3BUTTON%d"] = 3, -- MultiBarRight
      ["MULTIACTIONBAR4BUTTON%d"] = 4, -- MultiBarLeft
      ["PFPAGING%d"] = 2,
      ["PFSTANCEONE%d"] = 7,
      ["PFSTANCETWO%d"] = 8,
      ["PFSTANCETHREE%d"] = 9,
      ["PFSTANCEFOUR%d"] = 10,
    }

    -- rebind all existing bindings to our own buttons
    local keybinder = CreateFrame("Frame")
    keybinder:RegisterEvent("UPDATE_BINDINGS")
    keybinder:SetScript("OnEvent", function()
      for name, bar in pairs(bindwraps) do
        for i=1,12 do
          local key = GetBindingKey(format(name, i))
          local button = bars[bar][i]
          if key and button then
            SetOverrideBindingClick(button, false, key, button:GetName(), 'LeftButton')
          end
        end
      end
    end)
  end

  -- handle drag-drop grid
  local grid = CreateFrame("Frame")
  grid:RegisterEvent("ACTIONBAR_SHOWGRID")
  grid:RegisterEvent("ACTIONBAR_HIDEGRID")
  grid:RegisterEvent("PET_BAR_SHOWGRID")
  grid:RegisterEvent("PET_BAR_HIDEGRID")

  grid:SetScript("OnEvent", function()
    if event == "ACTIONBAR_SHOWGRID" then
      pfUI.bars:UpdateGrid(1)
    elseif event == "ACTIONBAR_HIDEGRID" then
      pfUI.bars:UpdateGrid(0)
    elseif event == "PET_BAR_SHOWGRID" then
      pfUI.bars:UpdateGrid(1, "PET")
    elseif event == "PET_BAR_HIDEGRID" then
      pfUI.bars:UpdateGrid(0, "PET")
    end
  end)

  -- reagent counter
  if C.bars.reagents == "1" then
    local reagent_slots = { }
    local reagent_counts = { }
    local reagent_capture = SPELL_REAGENTS.."(.+)"
    local scanner = libtipscan:GetScanner("actionbar")

    local UpdateSlot = function(slot)
      local texture = GetActionTexture(slot)

      -- update buttons that previously had an reagent
      if reagent_slots[slot] and not HasAction(slot) then
        reagent_slots[slot] = nil
        updatecache[slot] = true
      end

      -- search for reagent requirements
      if HasAction(slot) then
        scanner:SetAction(slot)
        local _, reagents = scanner:Find(reagent_capture)

        -- remove reagent counts if existing
        reagents = reagents and string.gsub(reagents, " %((.+)%)", "")

        -- update on reagent requirement changes
        if reagents and reagent_slots[slot] ~= reagents then
          reagent_counts[reagents] = reagent_counts[reagents] or 0
          reagent_slots[slot] = reagents
          updatecache[slot] = true
        end
      end
    end

    local reagentcounter = CreateFrame("Frame", "pfReagentCounter", UIParent)
    reagentcounter:RegisterEvent("PLAYER_ENTERING_WORLD")
    reagentcounter:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    reagentcounter:RegisterEvent("BAG_UPDATE")
    reagentcounter:SetScript("OnEvent", function()
      if event == "BAG_UPDATE" then
        this.event = true
      else
        this.scan = 1
      end
    end)

    -- limit events to one per second and smoothen action scanning
    reagentcounter:SetScript("OnUpdate", function()
      -- scan one action slot per frame
      if this.scan and this.scan <= 120 then
        UpdateSlot(this.scan)
        this.scan = this.scan + 1
      end

      -- trigger reagent count updates after action scans
      if this.scan and this.scan >= 120 then
        this.event = true
        this.scan = nil
      end

      -- queue events to fire only once per second
      if not this.event then return end
      if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

      -- scan for all reagent item counts
      for item in pairs(reagent_counts) do
        reagent_counts[item] = GetItemCount(item)
      end

      -- update all actionbar buttons
      for slot in pairs(reagent_slots) do
        updatecache[slot] = true
      end

      -- remove event trigger
      this.event = nil
    end)

    function IsReagentAction(slot)
      return reagent_slots[slot] and true or nil
    end

    function GetReagentCount(slot)
      return reagent_counts[reagent_slots[slot]]
    end
  end
end)
