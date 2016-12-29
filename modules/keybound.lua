pfUI:RegisterModule("keybound", function ()
  local default_border = pfUI_config.appearance.border.default
  local keymap = {
    ["BonusActionButton"]         = "ACTIONBUTTON",
    ["MultiBarBottomLeftButton"]  = "MULTIACTIONBAR1BUTTON",
    ["MultiBarBottomRightButton"] = "MULTIACTIONBAR2BUTTON",
    ["MultiBarRightButton"]       = "MULTIACTIONBAR3BUTTON",
    ["MultiBarLeftButton"]        = "MULTIACTIONBAR4BUTTON",
    ["ShapeshiftButton"]          = "SHAPESHIFTBUTTON",
    ["PetActionButton"]           = "BONUSACTIONBUTTON",
  }
  local modifiers = {
    ["ALT"]   = "ALT-",
    ["CTRL"]  = "CTRL-",
    ["SHIFT"] = "SHIFT-"
  }
  pfUI.keybound = CreateFrame("Frame","pfKeyBindingFrame",UIParent)
  pfUI.keybound:RegisterEvent("PLAYER_REGEN_DISABLED")
  pfUI.keybound:SetFrameStrata("DIALOG")
  pfUI.keybound:SetWidth(pfUI_config.bars.icon_size)
  pfUI.keybound:SetHeight(pfUI_config.bars.icon_size)
  pfUI.keybound:SetPoint("CENTER",UIParent,"CENTER",0,25)
  pfUI.api:CreateBackdrop(pfUI.keybound,default_border)
  pfUI.keybound.ico = pfUI.keybound:CreateTexture(nil,"ARTWORK")
  pfUI.keybound.ico:SetAllPoints(pfUI.keybound)
  pfUI.keybound.ico:SetTexture([[Interface\AddOns\pfUI\img\keyboard]])
  pfUI.keybound:EnableMouse(true)
  pfUI.keybound:SetScript("OnMouseUp",function(...)
      pfUI.keybound:Off()
    end)
  pfUI.keybound:SetScript("OnEnter",function()
      GameTooltip:SetOwner(this,"ANCHOR_CURSOR")
      GameTooltip:SetText("|cff555555Hoverbind Mode Active|r")
      GameTooltip:AddDoubleLine("Mouseover |cffffffffa button and press any key|r", "Sets keybind")
      GameTooltip:AddDoubleLine("Mouseover |cffffffffa button and press |rEsc","Clears keybind")
      GameTooltip:AddDoubleLine("Esc |cffffffffover world or|r Click |cffffffffthis button", "Exits Hoverbind Mode")
      GameTooltip:Show()
    end)
  pfUI.keybound:SetScript("OnLeave",function()
      if GameTooltip:IsOwned(this) then GameTooltip:Hide() end
    end)
  pfUI.keybound:SetScript("OnHide",function()
      if GameTooltip:IsOwned(this) then GameTooltip:Hide() end
    end)
  pfUI.keybound:EnableKeyboard(true)
  pfUI.keybound:SetScript("OnKeyUp",function(...)
      if modifiers[arg1] then return end -- ignore single modifier keyup
      local need_save = false
      local frame = GetMouseFocus()
      local hovername = (frame and frame.GetName) and (frame:GetName()) or ""
      local binding = pfUI.keybound:GetBinding(hovername)
      if arg1 == "ESCAPE" and not binding then pfUI.keybound:Off() return end
      if (binding) then
        if arg1 == "ESCAPE" then
          local key = (GetBindingKey(binding))
          if (key) then
            SetBinding(key)
            need_save = true
          end
        else
          if (SetBinding(pfUI.keybound:GetPrefix()..arg1,binding)) then
            need_save = true
          end
        end
      end
      -- if we set or cleared a binding save to the selected set
      if need_save then  
        need_save = false
        SaveBindings(GetCurrentBindingSet())
      end
    end)
  pfUI.keybound:Hide()

  function pfUI.keybound:GetBinding(button_name)
    local found,_,buttontype,buttonindex = string.find(button_name,"^(%a+)(%d+)$")
    if found then
      if keymap[buttontype] then
        return string.format("%s%d",keymap[buttontype],buttonindex)
      elseif buttontype == "ActionButton" then
        return string.format("ACTIONBUTTON%d",buttonindex)
      else
        return nil
      end
    else
      return nil
    end
  end

  function pfUI.keybound:GetPrefix()
    return string.format("%s%s%s",
      (IsAltKeyDown() and modifiers.ALT or ""),
      (IsControlKeyDown() and modifiers.CTRL or ""),
      (IsShiftKeyDown() and modifiers.SHIFT or ""))
  end

  function pfUI.keybound:On()
    self:Show()
  end

  function pfUI.keybound:Off()
    self:Hide()
  end

  pfUI.keybound:SetScript("OnEvent",function()
      -- disable keybound so player gets back control of their keyboard to fight
      pfUI.keybound:Off()
    end)
end)
