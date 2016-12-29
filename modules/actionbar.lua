pfUI:RegisterModule("actionbar", function ()
  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.actionbars ~= "-1" then
    default_border = pfUI_config.appearance.border.actionbars
  end

  -- override defaultUI functions to always show grid
  function ActionButton_ShowGrid(button) return end
  function ActionButton_HideGrid(button) return end

  if not Hook_ShowBonusActionBar then
    Hook_ShowBonusActionBar = ShowBonusActionBar
  end

  function ShowBonusActionBar()
    for i=1, NUM_ACTIONBAR_BUTTONS do getglobal("ActionButton" .. i):Hide() end
    Hook_ShowBonusActionBar()
  end

  if not Hook_HideBonusActionBar then
    Hook_HideBonusActionBar = HideBonusActionBar
  end

  function HideBonusActionBar()
    for i=1, NUM_ACTIONBAR_BUTTONS do getglobal("ActionButton" .. i):Show() end
    Hook_HideBonusActionBar()
  end

  if pfUI_config.bars.glowrange == "1" then
    if not Hook_ActionButton_OnUpdate then
      Hook_ActionButton_OnUpdate = ActionButton_OnUpdate
    end

    function ActionButton_OnUpdate(elapsed)
      -- Handle range indicator
      if ( this.rangeTimer ) then
        this.rangeTimer = this.rangeTimer - elapsed
        if ( this.rangeTimer <= 0.1 ) then
          if ( IsActionInRange( ActionButton_GetPagedID(this)) == 0 ) then
            if not this.a then
              this.r,this.g,this.b,this.a = pfUI.api.strsplit(",", pfUI_config.bars.rangecolor)
            end
            getglobal(this:GetName() .. 'Icon'):SetVertexColor(this.r, this.g, this.b, this.a)
          elseif IsUsableAction(ActionButton_GetPagedID(this)) then
            getglobal(this:GetName() .. 'Icon'):SetVertexColor(1, 1, 1, 1)
          end
          this.rangeTimer = TOOLTIP_UPDATE_TIME
        end
      end
      Hook_ActionButton_OnUpdate(elapsed)
    end
  end

  function ActionButton_GetPagedID(button)
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
  pfUI.bars = CreateFrame("Frame",nil,UIParent)
  pfUI.bars:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.bars:RegisterEvent("CVAR_UPDATE")
  pfUI.bars:RegisterEvent("PET_BAR_UPDATE")
  pfUI.bars:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
  pfUI.bars:RegisterEvent("PLAYER_CONTROL_GAINED")
  pfUI.bars:RegisterEvent("PLAYER_CONTROL_LOST")
  pfUI.bars:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
  pfUI.bars:RegisterEvent("PET_BAR_SHOWGRID")
  pfUI.bars:RegisterEvent("PET_BAR_HIDEGRID")

  pfUI.bars.actionmain   = CreateFrame("Frame", "pfBarActionMain",  UIParent)
  pfUI.bars.shapeshift   = CreateFrame("Frame", "pfBarShapeshift",  UIParent)
  pfUI.bars.bottomleft   = CreateFrame("Frame", "pfBarBottomLeft",  UIParent)
  pfUI.bars.bottomright  = CreateFrame("Frame", "pfBarBottomRight", UIParent)
  pfUI.bars.right        = CreateFrame("Frame", "pfBarRight",       UIParent)
  pfUI.bars.tworight     = CreateFrame("Frame", "pfBarTwoRight",    UIParent)
  pfUI.bars.pet          = CreateFrame("Frame", "pfBarPet",         UIParent)

  PetActionBarFrame:SetParent(pfUI.bars.pet)

  pfUI.bars:SetScript("OnEvent", function()
      pfUI.api:BarLayoutSize(pfUI.bars.actionmain, NUM_ACTIONBAR_BUTTONS, pfUI_config.bars.actionmain.formfactor, pfUI_config.bars.icon_size, default_border)
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
        pfUI.api:UpdateMovable(pfUI.bars.pet)
        pfUI.api:BarLayoutSize(pfUI.bars.pet, NUM_PET_ACTION_SLOTS, pfUI_config.bars.pet.formfactor, pfUI_config.bars.icon_size, default_border)
        pfUI.bars.pet:SetWidth(pfUI.bars.pet._size[1])
        pfUI.bars.pet:SetHeight(pfUI.bars.pet._size[2])
        if pfUI_config.bars.background == "1" then pfUI.api:CreateBackdrop(pfUI.bars.pet, default_border) end

        PetActionBarFrame:ClearAllPoints()
        PetActionBarFrame:Hide()

        for i=1, NUM_PET_ACTION_SLOTS do
          local b = getglobal("PetActionButton"..i)
          b:ClearAllPoints()
          b:SetParent(pfUI.bars.pet)
          pfUI.api:CreateBackdrop(b, default_border)
          pfUI.api:BarButtonAnchor(b, "PetActionButton", i, NUM_PET_ACTION_SLOTS, pfUI_config.bars.pet.formfactor, pfUI_config.bars.icon_size, default_border)
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
          local b = getglobal("ShapeshiftButton"..i)
          b:ClearAllPoints()
          b:SetParent(pfUI.bars.shapeshift)
          pfUI.api:CreateBackdrop(b, default_border)
          pfUI.api:BarButtonAnchor(b, "ShapeshiftButton", i, NUM_SHAPESHIFT_SLOTS, pfUI_config.bars.shapeshift.formfactor, pfUI_config.bars.icon_size, default_border)
          b:SetPoint(unpack(b._anchor))
          if b:IsShown() then shapeshiftbuttons = shapeshiftbuttons + 1 end
        end

        local anchor = pfUI.bars.actionmain
        if pfUI.bars.bottomleft:IsShown() then
          anchor = pfUI.bars.bottomleft
        end
        pfUI.bars.shapeshift:SetPoint("BOTTOM", anchor, "TOP", 0, default_border * 3)
        pfUI.api:UpdateMovable(pfUI.bars.shapeshift)
        if pfUI_config.bars.background == "1" then pfUI.api:CreateBackdrop(pfUI.bars.shapeshift, default_border) end
        pfUI.api:BarLayoutSize(pfUI.bars.shapeshift, shapeshiftbuttons, pfUI_config.bars.shapeshift.formfactor, pfUI_config.bars.icon_size, default_border)
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
        pfUI.api:UpdateMovable(pfUI.bars.bottomleft)

        pfUI.api:BarLayoutSize(pfUI.bars.bottomleft, NUM_ACTIONBAR_BUTTONS, pfUI_config.bars.bottomleft.formfactor, pfUI_config.bars.icon_size, default_border)
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
            local b = getglobal("MultiBarBottomLeftButton"..i)
            b:ClearAllPoints()
            b:SetParent(tf)
            pfUI.api:CreateBackdrop(b, default_border)
            pfUI.api:BarButtonAnchor(b, "MultiBarBottomLeftButton", i, NUM_ACTIONBAR_BUTTONS, pfUI_config.bars.bottomleft.formfactor, pfUI_config.bars.icon_size, default_border)
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
        pfUI.api:UpdateMovable(pfUI.bars.bottomright)
        if pfUI_config.bars.background == "1" then pfUI.api:CreateBackdrop(pfUI.bars.bottomright, default_border) end

        pfUI.api:BarLayoutSize(pfUI.bars.bottomright, NUM_ACTIONBAR_BUTTONS, pfUI_config.bars.bottomright.formfactor, pfUI_config.bars.icon_size, default_border)
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
            local b = getglobal("MultiBarBottomRightButton"..i)
            b:ClearAllPoints()
            b:SetParent(tf)
            pfUI.api:CreateBackdrop(b, default_border)
            pfUI.api:BarButtonAnchor(b, "MultiBarBottomRightButton", i, NUM_ACTIONBAR_BUTTONS, pfUI_config.bars.bottomright.formfactor, pfUI_config.bars.icon_size, default_border)
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
        pfUI.api:UpdateMovable(pfUI.bars.right)
        if pfUI_config.bars.background == "1" then pfUI.api:CreateBackdrop(pfUI.bars.right, default_border) end

        pfUI.api:BarLayoutSize(pfUI.bars.right, NUM_ACTIONBAR_BUTTONS, pfUI_config.bars.right.formfactor, pfUI_config.bars.icon_size, default_border)
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
            local b = getglobal("MultiBarRightButton"..i)
            b:ClearAllPoints()
            b:SetParent(tf)
            pfUI.api:CreateBackdrop(b, default_border)
            pfUI.api:BarButtonAnchor(b, "MultiBarRightButton", i, NUM_ACTIONBAR_BUTTONS, pfUI_config.bars.right.formfactor, pfUI_config.bars.icon_size, default_border)
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
        pfUI.api:UpdateMovable(pfUI.bars.tworight)
        if pfUI_config.bars.background == "1" then pfUI.api:CreateBackdrop(pfUI.bars.tworight, default_border) end
        pfUI.api:BarLayoutSize(pfUI.bars.tworight, NUM_ACTIONBAR_BUTTONS, pfUI_config.bars.tworight.formfactor, pfUI_config.bars.icon_size, default_border)
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
            local b = getglobal("MultiBarLeftButton"..i)
            b:ClearAllPoints()
            b:SetParent(tf)
            pfUI.api:CreateBackdrop(b, default_border)
            pfUI.api:BarButtonAnchor(b, "MultiBarLeftButton", i, NUM_ACTIONBAR_BUTTONS, pfUI_config.bars.tworight.formfactor, pfUI_config.bars.icon_size, default_border)
            b:SetPoint(unpack(b._anchor))
          end
        end
      else
        pfUI.bars.tworight:Hide()
      end
      pfUI.api:UpdateMovable(pfUI.bars.actionmain)

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
          if pfUI_config.bars.background == "1" then pfUI.api:CreateBackdrop(pfUI.bars.actionmain.share, default_border) end
        end
      else
        -- give both their own backdrop
        if pfUI.bars.actionmain.share then pfUI.bars.actionmain.share:Hide() end
        if pfUI_config.bars.background == "1" then pfUI.api:CreateBackdrop(pfUI.bars.actionmain, default_border) end
        if pfUI_config.bars.background == "1" then pfUI.api:CreateBackdrop(pfUI.bars.bottomleft, default_border) end
      end
    end)

  -- create main action bar frame
  pfUI.bars.actionmain:SetFrameStrata("LOW")
  pfUI.api:UpdateMovable(pfUI.bars.actionmain)

  function pfUI.bars.bottomleft:OnMove()
    local _, a, _ = pfUI.bars.bottomleft:GetPoint()
    if a ~= pfUI.bars.actionmain or not pfUI.bars.bottomleft:IsShown() or pfUI.bars.bottomleft:GetWidth() ~= a:GetWidth() or pfUI.bars.bottomleft:GetScale() ~= a:GetScale() then
      if pfUI_config.bars.background == "1" then pfUI.api:CreateBackdrop(pfUI.bars.actionmain, default_border) end
      if pfUI_config.bars.background == "1" then pfUI.api:CreateBackdrop(pfUI.bars.bottomleft, default_border) end
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
      local b = getglobal("ActionButton"..i)
      b:ClearAllPoints()
      b:SetParent(tf)
      pfUI.api:CreateBackdrop(b, default_border)
      pfUI.api:BarButtonAnchor(b, "ActionButton", i, NUM_ACTIONBAR_BUTTONS, pfUI_config.bars.actionmain.formfactor, pfUI_config.bars.icon_size, default_border)
      b:SetPoint(unpack(b._anchor))
    end
  end

  BonusActionBarFrame:ClearAllPoints()
  BonusActionBarFrame:SetParent(pfUI.bars.actionmain)
  BonusActionBarFrame:SetAllPoints(pfUI.bars.actionmain)
  BonusActionBarFrame:EnableMouse(0)

  do
    local tf = getglobal("pfBonusBar") or CreateFrame("Frame","pfBonusBar", UIParent)
    tf:SetParent(pfUI.bars.actionmain)
    tf:SetAllPoints(pfUI.bars.actionmain)
    for i=1, NUM_BONUS_ACTION_SLOTS do
      local b = getglobal("BonusActionButton"..i)
      b:ClearAllPoints()
      b:SetParent(tf)
      pfUI.api:CreateBackdrop(b, default_border)
      pfUI.api:BarButtonAnchor(b, "BonusActionButton", i, NUM_BONUS_ACTION_SLOTS, pfUI_config.bars.actionmain.formfactor, pfUI_config.bars.icon_size, default_border)
      b:SetPoint(unpack(b._anchor))
    end
  end

  for i = 1, NUM_SHAPESHIFT_SLOTS do
    getglobal("ShapeshiftButton"..i):SetWidth(pfUI_config.bars.icon_size)
    getglobal("ShapeshiftButton"..i):SetHeight(pfUI_config.bars.icon_size)
    getglobal("ShapeshiftButton"..i).showgrid = 1

    getglobal("ShapeshiftButton"..i..'Icon'):SetParent(getglobal("ShapeshiftButton"..i))
    getglobal("ShapeshiftButton"..i..'Icon'):SetAllPoints(getglobal("ShapeshiftButton"..i))
    getglobal("ShapeshiftButton"..i..'Icon'):SetTexCoord(.08, .92, .08, .92)

    getglobal("ShapeshiftButton"..i..'NormalTexture'):SetAlpha(0)
    getglobal("ShapeshiftButton"..i..'Border'):SetAlpha(0)

    getglobal("ShapeshiftButton"..i..'HotKey'):SetAllPoints(getglobal("ShapeshiftButton"..i))
    getglobal("ShapeshiftButton"..i..'HotKey'):SetFont(pfUI.font_square, pfUI_config.global.font_size -2, "OUTLINE")
    getglobal("ShapeshiftButton"..i..'HotKey'):SetJustifyH("RIGHT")
    getglobal("ShapeshiftButton"..i..'HotKey'):SetJustifyV("TOP")
  end

  for i = 1, NUM_PET_ACTION_SLOTS do
    getglobal("PetActionButton"..i):SetWidth(pfUI_config.bars.icon_size)
    getglobal("PetActionButton"..i):SetHeight(pfUI_config.bars.icon_size)
    getglobal("PetActionButton"..i):Show()
    getglobal("PetActionButton"..i).showgrid = 1

    getglobal("PetActionButton"..i..'Icon'):SetAllPoints(getglobal("PetActionButton"..i))
    getglobal("PetActionButton"..i..'Icon'):SetParent(getglobal("PetActionButton"..i))
    getglobal("PetActionButton"..i..'Icon'):SetTexCoord(.08, .92, .08, .92)

    getglobal("PetActionButton"..i..'NormalTexture2'):SetAlpha(0)
    getglobal("PetActionButton"..i..'AutoCastable'):SetAlpha(0)
    getglobal("PetActionButton"..i..'Border'):SetAlpha(0)
    getglobal("PetActionButton"..i..'AutoCast'):SetScale(pfUI_config.bars.icon_size / 30)
    getglobal("PetActionButton"..i..'AutoCast'):SetPoint("TOPLEFT", getglobal("PetActionButton"..i), "TOPLEFT", 0, 0)
    getglobal("PetActionButton"..i..'AutoCast'):SetPoint("BOTTOMRIGHT", getglobal("PetActionButton"..i), "BOTTOMRIGHT", 1, -1)
    getglobal("PetActionButton"..i..'AutoCast'):SetAlpha(.1)
  end

  -- theme all actionbars (spacing, size, border, text position and style)
  local actionbars = { "ActionButton", "MultiBarLeftButton", "MultiBarRightButton",
    "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "BonusActionButton", }

  for i = 1, NUM_ACTIONBAR_BUTTONS do
    for _, button in pairs(actionbars) do
      getglobal(button..i..'NormalTexture'):SetAlpha(0)
      getglobal(button..i):SetWidth(pfUI_config.bars.icon_size)
      getglobal(button..i):SetHeight(pfUI_config.bars.icon_size)
      getglobal(button..i):Show()
      getglobal(button..i).showgrid = 1

      getglobal(button..i..'Icon'):SetAllPoints(getglobal(button..i))
      getglobal(button..i..'Icon'):SetTexCoord(.08, .92, .08, .92)
      getglobal(button..i..'NormalTexture'):SetAllPoints(getglobal(button..i))
      getglobal(button..i..'NormalTexture'):SetTexCoord(.08, .92, .08, .92)
      getglobal(button..i..'Border'):SetTexture(0,0,0,0)
      getglobal(button..i..'HotKey'):SetAllPoints(getglobal(button..i))
      getglobal(button..i..'HotKey'):SetFont(pfUI.font_square, pfUI_config.global.font_size -2, "OUTLINE")
      getglobal(button..i..'HotKey'):SetJustifyH("RIGHT")
      getglobal(button..i..'HotKey'):SetJustifyV("TOP")
      getglobal(button..i..'Name'):SetAllPoints(getglobal(button..i))
      getglobal(button..i..'Name'):SetFont(pfUI.font_square, pfUI_config.global.font_size -2, "OUTLINE")
      getglobal(button..i..'Name'):SetJustifyH("CENTER")
      getglobal(button..i..'Name'):SetJustifyV("BOTTOM")
    end
  end

  local function pfEnableAutohide(frame)
    frame.hover = CreateFrame("Frame", frame:GetName() .. "Autohide", frame)
    frame.hover:SetParent(frame)
    frame.hover:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
    frame.hover:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5)
    frame.hover:SetFrameStrata("BACKGROUND")

    frame.hover:RegisterEvent("CVAR_UPDATE")
    frame.hover:SetScript("OnEvent", function()
      this.x = nil
    end)

    frame.hover:SetScript("OnUpdate", function()
      -- reset frame positions to UIParent
      if not this.resetpos then
        this:SetMovable(1)
        this:StartMoving()
        this:StopMovingOrSizing()
        this:SetMovable(0)
        this.resetpos = true
      end

      -- cache frame positions
      if not this.x then
        local _, _, _, fx, fy = this:GetPoint()
        fy = GetScreenHeight() + fy
        local fxmax = fx+this:GetWidth()
        local fymax = fy-this:GetHeight()

        this.x = fx
        this.xmax = floor(fxmax)

        this.y = fy
        this.ymax = floor(fymax)
      end

      -- get cursor position
      local x, y = GetCursorPosition()
      x = x / UIParent:GetEffectiveScale()
      y = y / UIParent:GetEffectiveScale()

      if not this.activeTo then this.activeTo = GetTime() + tonumber(pfUI_config.bars.hide_time) end
      if x > this.x and x < this.xmax and y < this.y and y > this.ymax then
        this.activeTo = GetTime() + tonumber(pfUI_config.bars.hide_time)
        this:GetParent():SetAlpha(1)
      else
        if this.activeTo < GetTime() and this:GetParent():GetAlpha() > 0 then
          this:GetParent():SetAlpha(this:GetParent():GetAlpha() - 0.1)
        end
      end
    end)
  end

  -- configure autohiding frames
  if pfUI_config.bars.hide_actionmain == "1" then
    pfEnableAutohide(pfUI.bars.actionmain)
  end

  if pfUI_config.bars.hide_bottomleft == "1" then
    pfEnableAutohide(pfUI.bars.bottomleft)
  end

  if pfUI_config.bars.hide_bottomright == "1" then
    pfEnableAutohide(pfUI.bars.bottomright)
  end

  if pfUI_config.bars.hide_right == "1" then
    pfEnableAutohide(pfUI.bars.right)
  end

  if pfUI_config.bars.hide_tworight == "1" then
    pfEnableAutohide(pfUI.bars.tworight)
  end

  if pfUI_config.bars.hide_shapeshift == "1" then
    pfEnableAutohide(pfUI.bars.shapeshift)
  end

  if pfUI_config.bars.hide_pet == "1" then
    pfEnableAutohide(pfUI.bars.pet)
  end
end)
