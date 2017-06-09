pfUI:RegisterModule("actionbar", function ()
  local default_border = C.appearance.border.default
  if C.appearance.border.actionbars ~= "-1" then
    default_border = C.appearance.border.actionbars
  end

  -- override wow ui functions
  function _G.ActionButton_ShowGrid(button)
    if not button then button = this end
    button.showgrid = button.showgrid + 1
    button:Show()
  end

  function _G.ActionButton_HideGrid(button)
    if not button then button = this end
    button.showgrid = button.showgrid - 1

    if button.showgrid == 0 and not HasAction(ActionButton_GetPagedID(button)) then
      button:Hide()
    end
  end

  function _G.MultiActionBar_ShowAllGrids()
    for _, bar in pairs({ "MultiBarBottomLeft", "MultiBarBottomRight",
    "MultiBarRight", "MultiBarLeft", "BonusAction", "Action" }) do
      MultiActionBar_UpdateGrid(bar, 1)
    end
  end

  function _G.MultiActionBar_HideAllGrids()
    for _, bar in pairs({ "MultiBarBottomLeft", "MultiBarBottomRight",
    "MultiBarRight", "MultiBarLeft", "BonusAction", "Action" }) do
      MultiActionBar_UpdateGrid(bar)
    end
  end

  hooksecurefunc("ShowBonusActionBar", function()
    if pfActionBar then pfActionBar:Hide() end
    if pfBonusBar then pfBonusBar:Show() end
  end)

  hooksecurefunc("HideBonusActionBar", function()
    if pfActionBar then pfActionBar:Show() end
    if pfBonusBar then pfBonusBar:Hide() end
  end)

  if C.bars.glowrange == "1" then

    function _G.ActionButton_UpdateUsable()
      if pfScanActive then return end

      local icon = getglobal(this:GetName().."Icon");
      local normalTexture = getglobal(this:GetName().."NormalTexture");
      local isUsable, notEnoughMana = IsUsableAction(ActionButton_GetPagedID(this));
      if ( isUsable ) then
        icon:SetVertexColor(1.0, 1.0, 1.0);
        normalTexture:SetVertexColor(1.0, 1.0, 1.0);
      elseif ( notEnoughMana ) then
        icon:SetVertexColor(0.5, 0.5, 1.0);
        normalTexture:SetVertexColor(0.5, 0.5, 1.0);
      else
        icon:SetVertexColor(0.4, 0.4, 0.4);
        normalTexture:SetVertexColor(1.0, 1.0, 1.0);
      end
    end

    hooksecurefunc("ActionButton_OnUpdate", function(elapsed)
      -- Handle range indicator
      if ( this.rangeTimer ) then
        this.rangeTimer = this.rangeTimer - elapsed
        if ( this.rangeTimer <= 0.1 ) then
          if ( IsActionInRange( ActionButton_GetPagedID(this)) == 0 ) then
            if not this.a then
              this.r,this.g,this.b,this.a = strsplit(",", C.bars.rangecolor)
            end
            _G[this:GetName() .. 'Icon']:SetVertexColor(this.r, this.g, this.b, this.a)
          elseif IsUsableAction(ActionButton_GetPagedID(this)) then
            _G[this:GetName() .. 'Icon']:SetVertexColor(1, 1, 1, 1)
          end
          this.rangeTimer = TOOLTIP_UPDATE_TIME
        end
      end
    end)
  end

  function _G.ActionButton_GetPagedID(button)
    if ( button.isBonus and CURRENT_ACTIONBAR_PAGE == 1 ) then
      local offset = GetBonusBarOffset()
      if ( offset == 0 and BonusActionBarFrame and BonusActionBarFrame.lastBonusBar ) then
        offset = BonusActionBarFrame.lastBonusBar
      end
      return (button:GetID() + ((NUM_ACTIONBAR_PAGES + offset - 1) * NUM_ACTIONBAR_BUTTONS))
    end

    local parentName = button:GetParent():GetName()
    if ( parentName == "pfMultiBarBottomLeft" or parentName == "MultiBarBottomLeft" )  then
      return (button:GetID() + ((BOTTOMLEFT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
    elseif ( parentName == "pfMultiBarBottomRight" or parentName == "MultiBarBottomRight" ) then
      return (button:GetID() + ((BOTTOMRIGHT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
    elseif ( parentName == "pfMultiBarLeft" or parentName == "MultiBarLeft" ) then
      return (button:GetID() + ((LEFT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
    elseif ( parentName == "pfMultiBarRight" or parentName == "MultiBarRight" ) then
      return (button:GetID() + ((RIGHT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
    else
      return (button:GetID() + ((CURRENT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
    end
  end

  -- hide default blizz
  MainMenuBar:Hide()
  BonusActionBarTexture0:Hide()
  BonusActionBarTexture1:Hide()

  -- hide background texture of petactionbar
  SlidingActionBarTexture0:Hide()
  SlidingActionBarTexture0.Show = function () return end

  SlidingActionBarTexture1:Hide()
  SlidingActionBarTexture1.Show = function () return end

  -- create action bar frame
  pfUI.bars = CreateFrame("Frame", nil, UIParent)
  pfUI.bars:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.bars:RegisterEvent("CVAR_UPDATE")
  pfUI.bars:RegisterEvent("PET_BAR_UPDATE")
  pfUI.bars:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
  pfUI.bars:RegisterEvent("PLAYER_CONTROL_GAINED")
  pfUI.bars:RegisterEvent("PLAYER_CONTROL_LOST")
  pfUI.bars:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
  pfUI.bars:RegisterEvent("PET_BAR_SHOWGRID")
  pfUI.bars:RegisterEvent("PET_BAR_HIDEGRID")

  pfUI.bars.autohide = CreateFrame("Frame", nil, UIParent)
  pfUI.bars.autohide:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.bars.autohide:SetScript("OnEvent", function()
    if C.bars.hide_actionmain == "1" then
      CreateAutohide(pfUI.bars.actionmain)
    end
    if C.bars.hide_bottomleft == "1" then
      CreateAutohide(pfUI.bars.bottomleft)
    end
    if C.bars.hide_bottomright == "1" then
      CreateAutohide(pfUI.bars.bottomright)
    end
    if C.bars.hide_right == "1" then
      CreateAutohide(pfUI.bars.right)
    end
    if C.bars.hide_tworight == "1" then
      CreateAutohide(pfUI.bars.tworight)
    end
    if C.bars.hide_shapeshift == "1" then
      CreateAutohide(pfUI.bars.shapeshift)
    end
    if C.bars.hide_pet == "1" then
      CreateAutohide(pfUI.bars.pet)
    end
  end)

  pfUI.bars.actionmain   = CreateFrame("Frame", "pfBarActionMain",  UIParent)
  pfUI.bars.shapeshift   = CreateFrame("Frame", "pfBarShapeshift",  UIParent)
  pfUI.bars.bottomleft   = CreateFrame("Frame", "pfBarBottomLeft",  UIParent)
  pfUI.bars.bottomright  = CreateFrame("Frame", "pfBarBottomRight", UIParent)
  pfUI.bars.right        = CreateFrame("Frame", "pfBarRight",       UIParent)
  pfUI.bars.tworight     = CreateFrame("Frame", "pfBarTwoRight",    UIParent)
  pfUI.bars.pet          = CreateFrame("Frame", "pfBarPet",         UIParent)

  PetActionBarFrame:SetParent(pfUI.bars.pet)

  pfUI.bars:SetScript("OnEvent", function()
      BarLayoutSize(pfUI.bars.actionmain, NUM_ACTIONBAR_BUTTONS, C.bars.actionmain.formfactor, C.bars.icon_size, default_border)
      pfUI.bars.actionmain:SetWidth(pfUI.bars.actionmain._size[1])
      pfUI.bars.actionmain:SetHeight(pfUI.bars.actionmain._size[2])

      if (PetHasActionBar()) then
        PetActionBar_Update()
        pfUI.bars.pet:Show()
        local anchor = pfUI.bars.actionmain
        if pfUI.bars.bottomleft:IsShown() then
          anchor = pfUI.bars.bottomleft
        end
        pfUI.bars.pet:SetPoint("BOTTOM", anchor, "TOP", 0, default_border * 3)
        UpdateMovable(pfUI.bars.pet)
        BarLayoutSize(pfUI.bars.pet, NUM_PET_ACTION_SLOTS, C.bars.pet.formfactor, C.bars.icon_size, default_border)
        pfUI.bars.pet:SetWidth(pfUI.bars.pet._size[1])
        pfUI.bars.pet:SetHeight(pfUI.bars.pet._size[2])
        if C.bars.background == "1" then CreateBackdrop(pfUI.bars.pet, default_border) end

        PetActionBarFrame:ClearAllPoints()
        PetActionBarFrame:Hide()

        for i=1, NUM_PET_ACTION_SLOTS do
          local b = _G["PetActionButton"..i]
          b:ClearAllPoints()
          b:SetFrameLevel(pfUI.bars.pet:GetFrameLevel() + 1)
          b:SetParent(pfUI.bars.pet)
          CreateBackdrop(b, default_border)
          BarButtonAnchor(b, "PetActionButton", i, NUM_PET_ACTION_SLOTS, C.bars.pet.formfactor, C.bars.icon_size, default_border)
          b:SetPoint(unpack(b._anchor))
        end
      else
        pfUI.bars.pet:Hide()
      end

      local shapeshiftbuttons = 0
      if ShapeshiftButton1:IsShown() then
        pfUI.bars.shapeshift:Show()
        ShapeshiftBarFrame:ClearAllPoints()
        ShapeshiftBarFrame:SetAllPoints(pfUI.bars.shapeshift)

        for i=1, NUM_SHAPESHIFT_SLOTS do
          local b = _G["ShapeshiftButton"..i]
          b:ClearAllPoints()
          b:SetParent(pfUI.bars.shapeshift)
          CreateBackdrop(b, default_border)
          BarButtonAnchor(b, "ShapeshiftButton", i, NUM_SHAPESHIFT_SLOTS, C.bars.shapeshift.formfactor, C.bars.icon_size, default_border)
          b:SetPoint(unpack(b._anchor))
          if b:IsShown() then shapeshiftbuttons = shapeshiftbuttons + 1 end
        end

        local anchor = pfUI.bars.actionmain
        if pfUI.bars.bottomleft:IsShown() then
          anchor = pfUI.bars.bottomleft
        end
        pfUI.bars.shapeshift:SetPoint("BOTTOM", anchor, "TOP", 0, default_border * 3)
        UpdateMovable(pfUI.bars.shapeshift)
        if C.bars.background == "1" then CreateBackdrop(pfUI.bars.shapeshift, default_border) end
        BarLayoutSize(pfUI.bars.shapeshift, shapeshiftbuttons, C.bars.shapeshift.formfactor, C.bars.icon_size, default_border)
        pfUI.bars.shapeshift:SetWidth(pfUI.bars.shapeshift._size[1])
        pfUI.bars.shapeshift:SetHeight(pfUI.bars.shapeshift._size[2])
      else
        pfUI.bars.shapeshift:Hide()
      end

      if SHOW_MULTI_ACTIONBAR_1 then
        pfUI.bars.bottomleft:Show()
        pfUI.bars.bottomleft:SetFrameStrata("LOW")
        pfUI.bars.bottomleft:ClearAllPoints()
        pfUI.bars.bottomleft:SetPoint("BOTTOM", pfUI.bars.actionmain, "TOP", 0, default_border)
        UpdateMovable(pfUI.bars.bottomleft)

        BarLayoutSize(pfUI.bars.bottomleft, NUM_ACTIONBAR_BUTTONS, C.bars.bottomleft.formfactor, C.bars.icon_size, default_border)
        pfUI.bars.bottomleft:SetWidth(pfUI.bars.bottomleft._size[1])
        pfUI.bars.bottomleft:SetHeight(pfUI.bars.bottomleft._size[2])

        MultiBarBottomLeft:SetParent(pfUI.bars.bottomleft)
        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetAllPoints(pfUI.bars.bottomleft)

        -- create temp frame to give a named parent to the buttons
        if not pfUI.bars.bottomleft.setuptf then
          pfUI.bars.bottomleft.setuptf = true
          local tf = CreateFrame("Frame", "pfMultiBarBottomLeft", UIParent )
          tf:SetParent(pfUI.bars.bottomleft)
          tf:SetAllPoints(pfUI.bars.bottomleft)

          for i=1, NUM_ACTIONBAR_BUTTONS do
            local b = _G["MultiBarBottomLeftButton"..i]
            b:ClearAllPoints()
            b:SetParent(tf)
            CreateBackdrop(b, default_border)
            BarButtonAnchor(b, "MultiBarBottomLeftButton", i, NUM_ACTIONBAR_BUTTONS, C.bars.bottomleft.formfactor, C.bars.icon_size, default_border)
            b:SetPoint(unpack(b._anchor))
          end
        end
      else
        pfUI.bars.bottomleft:Hide()
      end

      pfUI.bars.actionmain:ClearAllPoints()
      pfUI.bars.actionmain:SetPoint("BOTTOM", UIParent ,"BOTTOM",0,5)

      if SHOW_MULTI_ACTIONBAR_2 then
        pfUI.bars.bottomright:Show()
        pfUI.bars.bottomright:SetFrameStrata("LOW")
        pfUI.bars.bottomright:SetPoint("BOTTOMRIGHT", pfUI.bars.actionmain, "BOTTOMLEFT", -default_border*3, 0)
        UpdateMovable(pfUI.bars.bottomright)
        if C.bars.background == "1" then CreateBackdrop(pfUI.bars.bottomright, default_border) end

        BarLayoutSize(pfUI.bars.bottomright, NUM_ACTIONBAR_BUTTONS, C.bars.bottomright.formfactor, C.bars.icon_size, default_border)
        pfUI.bars.bottomright:SetWidth(pfUI.bars.bottomright._size[1])
        pfUI.bars.bottomright:SetHeight(pfUI.bars.bottomright._size[2])

        MultiBarBottomRight:SetParent(pfUI.bars.bottomright)
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetAllPoints(pfUI.bars.bottomright)

        -- create temp frame to give a named parent to the buttons
        if not pfUI.bars.bottomright.setuptf then
          pfUI.bars.bottomright.setuptf = true
          local tf = CreateFrame("Frame", "pfMultiBarBottomRight", UIParent )
          tf:SetParent(pfUI.bars.bottomright)
          tf:SetAllPoints(pfUI.bars.bottomright)

          for i=1, NUM_ACTIONBAR_BUTTONS do
            local b = _G["MultiBarBottomRightButton"..i]
            b:ClearAllPoints()
            b:SetParent(tf)
            CreateBackdrop(b, default_border)
            BarButtonAnchor(b, "MultiBarBottomRightButton", i, NUM_ACTIONBAR_BUTTONS, C.bars.bottomright.formfactor, C.bars.icon_size, default_border)
            b:SetPoint(unpack(b._anchor))
          end
        end
      else
        pfUI.bars.bottomright:Hide()
      end

      if SHOW_MULTI_ACTIONBAR_3 then
        pfUI.bars.right:Show()
        pfUI.bars.right:SetFrameStrata("LOW")
        pfUI.bars.right:SetPoint("BOTTOMLEFT", pfUI.bars.actionmain, "BOTTOMRIGHT", default_border*3, 0)
        UpdateMovable(pfUI.bars.right)
        if C.bars.background == "1" then CreateBackdrop(pfUI.bars.right, default_border) end

        BarLayoutSize(pfUI.bars.right, NUM_ACTIONBAR_BUTTONS, C.bars.right.formfactor, C.bars.icon_size, default_border)
        pfUI.bars.right:SetWidth(pfUI.bars.right._size[1])
        pfUI.bars.right:SetHeight(pfUI.bars.right._size[2])

        MultiBarRight:SetParent(pfUI.bars.right)
        MultiBarRight:ClearAllPoints()
        MultiBarRight:SetAllPoints(pfUI.bars.right)

        -- create temp frame to give a named parent to the buttons
        if not pfUI.bars.right.setuptf then
          pfUI.bars.right.setuptf = true
          local tf = CreateFrame("Frame", "pfMultiBarRight", UIParent )
          tf:SetParent(pfUI.bars.right)
          tf:SetAllPoints(pfUI.bars.right)

          for i=1, NUM_ACTIONBAR_BUTTONS do
            local b = _G["MultiBarRightButton"..i]
            b:ClearAllPoints()
            b:SetParent(tf)
            CreateBackdrop(b, default_border)
            BarButtonAnchor(b, "MultiBarRightButton", i, NUM_ACTIONBAR_BUTTONS, C.bars.right.formfactor, C.bars.icon_size, default_border)
            b:SetPoint(unpack(b._anchor))
          end
        end
      else
        pfUI.bars.right:Hide()
      end

      if SHOW_MULTI_ACTIONBAR_4 and SHOW_MULTI_ACTIONBAR_3 then
        pfUI.bars.tworight:Show()
        pfUI.bars.tworight:SetFrameStrata("LOW")
        pfUI.bars.tworight:ClearAllPoints()
        pfUI.bars.tworight:SetPoint("RIGHT", UIParent, "RIGHT", -5, 0)
        UpdateMovable(pfUI.bars.tworight)
        if C.bars.background == "1" then CreateBackdrop(pfUI.bars.tworight, default_border) end
        BarLayoutSize(pfUI.bars.tworight, NUM_ACTIONBAR_BUTTONS, C.bars.tworight.formfactor, C.bars.icon_size, default_border)
        pfUI.bars.tworight:SetWidth(pfUI.bars.tworight._size[1])
        pfUI.bars.tworight:SetHeight(pfUI.bars.tworight._size[2])

        MultiBarLeft:SetParent(pfUI.bars.tworight)
        MultiBarLeft:ClearAllPoints()
        MultiBarLeft:SetAllPoints(pfUI.bars.tworight)

        -- create temp frame to give a named parent to the buttons
        if not pfUI.bars.tworight.setuptf then
          pfUI.bars.tworight.setuptf = true
          local tf = CreateFrame("Frame", "pfMultiBarLeft", UIParent )
          tf:SetParent(pfUI.bars.tworight)
          tf:SetAllPoints(pfUI.bars.tworight)

          for i=1, NUM_ACTIONBAR_BUTTONS do
            local b = _G["MultiBarLeftButton"..i]
            b:ClearAllPoints()
            b:SetParent(tf)
            CreateBackdrop(b, default_border)
            BarButtonAnchor(b, "MultiBarLeftButton", i, NUM_ACTIONBAR_BUTTONS, C.bars.tworight.formfactor, C.bars.icon_size, default_border)
            b:SetPoint(unpack(b._anchor))
          end
        end
      else
        pfUI.bars.tworight:Hide()
      end
      UpdateMovable(pfUI.bars.actionmain)

      local _, a, _ = pfUI.bars.bottomleft:GetPoint()
      if a and a == pfUI.bars.actionmain and pfUI.bars.bottomleft:IsShown() and pfUI.bars.bottomleft:GetWidth() == a:GetWidth() and pfUI.bars.bottomleft:GetScale() == a:GetScale() then
        -- share one backdrop
        if not pfUI.bars.actionmain.share then
          pfUI.bars.actionmain.share = CreateFrame("Frame", "pfBottomBackdrop", UIParent)
          pfUI.bars.actionmain.share:SetFrameStrata("LOW")
          pfUI.bars.actionmain.share:SetPoint("TOPLEFT", pfUI.bars.bottomleft, "TOPLEFT", 0, 0)
          pfUI.bars.actionmain.share:SetPoint("BOTTOMLEFT", pfUI.bars.actionmain, "BOTTOMLEFT", 0, 0)
          pfUI.bars.actionmain.share:SetPoint("TOPRIGHT", pfUI.bars.bottomleft, "TOPRIGHT", 0, 0)
          pfUI.bars.actionmain.share:SetPoint("BOTTOMRIGHT", pfUI.bars.actionmain, "BOTTOMRIGHT", 0, 0)
          if C.bars.background == "1" then CreateBackdrop(pfUI.bars.actionmain.share, default_border) end
        end
      else
        -- give both their own backdrop
        if pfUI.bars.actionmain.share then pfUI.bars.actionmain.share:Hide() end
        if C.bars.background == "1" then CreateBackdrop(pfUI.bars.actionmain, default_border) end
        if C.bars.background == "1" then CreateBackdrop(pfUI.bars.bottomleft, default_border) end
      end
    end)

  -- create main action bar frame
  pfUI.bars.actionmain:SetFrameStrata("LOW")
  UpdateMovable(pfUI.bars.actionmain)

  function pfUI.bars.bottomleft:OnMove()
    local _, a, _ = pfUI.bars.bottomleft:GetPoint()
    if a ~= pfUI.bars.actionmain or not pfUI.bars.bottomleft:IsShown() or pfUI.bars.bottomleft:GetWidth() ~= a:GetWidth() or pfUI.bars.bottomleft:GetScale() ~= a:GetScale() then
      if C.bars.background == "1" then CreateBackdrop(pfUI.bars.actionmain, default_border) end
      if C.bars.background == "1" then CreateBackdrop(pfUI.bars.bottomleft, default_border) end
      if pfUI.bars.actionmain.share then pfUI.bars.actionmain.share:Hide() end
    end
  end

  -- create temp frame to give a named parent to the buttons
  if not pfUI.bars.actionmain.setuptf then
    pfUI.bars.actionmain.setuptf = true
    local tf = CreateFrame("Frame","pfActionBar", UIParent)
    tf:SetParent(pfUI.bars.actionmain)
    tf:SetAllPoints(pfUI.bars.actionmain)

    for i=1, NUM_ACTIONBAR_BUTTONS do
      local b = _G["ActionButton"..i]
      b:ClearAllPoints()
      b:SetParent(tf)
      CreateBackdrop(b, default_border)
      BarButtonAnchor(b, "ActionButton", i, NUM_ACTIONBAR_BUTTONS, C.bars.actionmain.formfactor, C.bars.icon_size, default_border)
      b:SetPoint(unpack(b._anchor))
    end
  end

  BonusActionBarFrame:ClearAllPoints()
  BonusActionBarFrame:SetParent(pfUI.bars.actionmain)
  BonusActionBarFrame:SetAllPoints(pfUI.bars.actionmain)
  BonusActionBarFrame:EnableMouse(0)

  local tf = _G["pfBonusBar"] or CreateFrame("Frame","pfBonusBar", UIParent)
  tf:SetParent(pfUI.bars.actionmain)
  tf:SetAllPoints(pfUI.bars.actionmain)
  tf:SetFrameLevel(pfActionBar:GetFrameLevel() + 1)
  for i=1, NUM_BONUS_ACTION_SLOTS do
    local b = _G["BonusActionButton"..i]
    b:ClearAllPoints()
    b:SetParent(tf)
    CreateBackdrop(b, default_border)
    BarButtonAnchor(b, "BonusActionButton", i, NUM_BONUS_ACTION_SLOTS, C.bars.actionmain.formfactor, C.bars.icon_size, default_border)
    b:SetPoint(unpack(b._anchor))
  end

  for i = 1, NUM_SHAPESHIFT_SLOTS do
    local button = _G["ShapeshiftButton"..i]
    button:SetWidth(C.bars.icon_size)
    button:SetHeight(C.bars.icon_size)

    local icon = _G["ShapeshiftButton"..i..'Icon']
    icon:SetParent(button)
    icon:SetAllPoints(button)
    icon:SetTexCoord(.08, .92, .08, .92)

    local texture = _G["ShapeshiftButton"..i..'NormalTexture']
    texture:SetAlpha(0)

    local border = _G["ShapeshiftButton"..i..'Border']
    border:SetAlpha(0)

    local hotkey = _G["ShapeshiftButton"..i..'HotKey']
    hotkey:SetAllPoints(button)
    hotkey:SetFont(pfUI.font_unit, C.global.font_unit_size -2, "OUTLINE")
    hotkey:SetJustifyH("RIGHT")
    hotkey:SetJustifyV("TOP")
  end

  for i = 1, NUM_PET_ACTION_SLOTS do
    local button = _G["PetActionButton"..i]
    button:SetWidth(C.bars.icon_size)
    button:SetHeight(C.bars.icon_size)
    button:Show()

    local icon = _G["PetActionButton"..i..'Icon']
    icon:SetAllPoints(button)
    icon:SetParent(button)
    icon:SetTexCoord(.08, .92, .08, .92)

    local texture = _G["PetActionButton"..i..'NormalTexture2']
    texture :SetAlpha(0)

    local castable = _G["PetActionButton"..i..'AutoCastable']
    castable:SetAlpha(0)

    local border = _G["PetActionButton"..i..'Border']
    border:SetAlpha(0)

    local autocast = _G["PetActionButton"..i..'AutoCast']
    autocast:SetScale(C.bars.icon_size / 30)
    autocast:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    autocast:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    autocast:SetAlpha(.1)
  end

  -- theme all actionbars (spacing, size, border, text position and style)
  local actionbars = { "ActionButton", "MultiBarLeftButton", "MultiBarRightButton",
    "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "BonusActionButton", }

  for i = 1, NUM_ACTIONBAR_BUTTONS do
    for _, actionbutton in pairs(actionbars) do
      local button = _G[actionbutton..i]
      button:SetWidth(C.bars.icon_size)
      button:SetHeight(C.bars.icon_size)
      button:Show()

      local texture = _G[actionbutton..i..'NormalTexture']
      texture:SetAlpha(0)
      texture:SetAllPoints(button)
      texture:SetTexCoord(.08, .92, .08, .92)

      local icon = _G[actionbutton..i..'Icon']
      icon:SetAllPoints(button)
      icon:SetTexCoord(.08, .92, .08, .92)

      local border = _G[actionbutton..i..'Border']
      border:SetAllPoints(button)
      border:SetTexture(0,1,0,.75)

      local hotkey = _G[actionbutton..i..'HotKey']
      if C.bars.showkeybind == "1" then
        hotkey:SetAllPoints(button)
        hotkey:SetFont(pfUI.font_unit, C.global.font_unit_size -2, "OUTLINE")
        hotkey:SetJustifyH("RIGHT")
        hotkey:SetJustifyV("TOP")
      else
        hotkey:SetAlpha(0)
      end

      local name = _G[actionbutton..i..'Name']
      if C.bars.showmacro == "1" then
        name:SetAllPoints(button)
        name:SetFont(pfUI.font_unit, C.global.font_unit_size -2, "OUTLINE")
        name:SetJustifyH("CENTER")
        name:SetJustifyV("BOTTOM")
      else
        name:SetAlpha(0)
      end
    end
  end
end)
