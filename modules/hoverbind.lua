pfUI:RegisterModule("hoverbind", function ()
  local default_border = C.appearance.border.default
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

  pfUI.hoverbind = CreateFrame("Frame","pfKeyBindingFrame",UIParent)
  pfUI.hoverbind:Hide()
  pfUI.hoverbind:RegisterEvent("PLAYER_REGEN_DISABLED")
  pfUI.hoverbind:EnableMouse(true)
  pfUI.hoverbind.edit = CreateFrame("Button", "pfKeyBindingFrameEdit", pfUI.hoverbind)
  pfUI.hoverbind.edit:SetFrameStrata("BACKGROUND")
  pfUI.hoverbind.edit:SetAllPoints(UIParent)
  pfUI.hoverbind.edit.tex = pfUI.hoverbind.edit:CreateTexture("pfKeyBindShade", "BACKGROUND")
  pfUI.hoverbind.edit.tex:SetAllPoints(pfUI.hoverbind.edit)
  pfUI.hoverbind.edit.tex:SetTexture(0,0,0,.5)
  pfUI.hoverbind.edit:SetScript("OnClick", function()
    pfUI.hoverbind:Hide()
  end)

  pfUI.hoverbind:SetScript("OnMouseUp",function(...)
    pfUI.hoverbind:Hide()
  end)

  pfUI.hoverbind:SetScript("OnShow", function()
    pfUI.gui:Hide()
    pfUI.hoverbind.edit:Show()

    local txt = T["|cff33ffccKeybind Mode|r\nThis mode allows you to bind keyboard shortcuts to your actionbars.\nBy hovering a button with your cursor and pressing a key, the key will be assigned to that button.\nHit Escape on a button to remove bindings.\n\nPress Escape or click on an empty area to leave the keybind mode."]
    pfUI.info:ShowInfoBox(txt, 30,  pfUI.hoverbind.edit)
  end)

  pfUI.hoverbind:SetScript("OnHide",function()
    pfUI.hoverbind.edit:Hide()
    pfUI.gui:Show()
  end)

  pfUI.hoverbind:EnableKeyboard(true)
  pfUI.hoverbind:SetScript("OnKeyUp",function(...)
    if modifiers[arg1] then return end -- ignore single modifier keyup
    local need_save = false
    local frame = GetMouseFocus()
    local hovername = (frame and frame.GetName) and (frame:GetName()) or ""
    local binding = pfUI.hoverbind:GetBinding(hovername)
    if arg1 == "ESCAPE" and not binding then pfUI.hoverbind:Hide() return end
    if (binding) then
      if arg1 == "ESCAPE" then
        local key = (GetBindingKey(binding))
        if (key) then
          SetBinding(key)
          need_save = true
        end
      else
        if (SetBinding(pfUI.hoverbind:GetPrefix()..arg1,binding)) then
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

  function pfUI.hoverbind:GetBinding(button_name)
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

  function pfUI.hoverbind:GetPrefix()
    return string.format("%s%s%s",
      (IsAltKeyDown() and modifiers.ALT or ""),
      (IsControlKeyDown() and modifiers.CTRL or ""),
      (IsShiftKeyDown() and modifiers.SHIFT or ""))
  end

  pfUI.hoverbind:SetScript("OnEvent",function()
    -- disable hoverbind so player gets back control of their keyboard to fight
    pfUI.hoverbind:Hide()
  end)
end)
