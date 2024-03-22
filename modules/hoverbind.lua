pfUI:RegisterModule("hoverbind", "vanilla:tbc", function ()
  local keymap = {
    -- buttons to binding association
    ["pfActionBarMainButton"]     = "ACTIONBUTTON",
    ["pfActionBarTopButton"]      = "MULTIACTIONBAR1BUTTON",
    ["pfActionBarLeftButton"]     = "MULTIACTIONBAR2BUTTON",
    ["pfActionBarRightButton"]    = "MULTIACTIONBAR3BUTTON",
    ["pfActionBarVerticalButton"] = "MULTIACTIONBAR4BUTTON",
    ["pfActionBarStancesButton"]  = "SHAPESHIFTBUTTON",
    ["pfActionBarPetButton"]      = "BONUSACTIONBUTTON",

    -- special buttons
    ["pfActionBarPagingButton"]     = "PFPAGING",
    ["pfActionBarStanceBar1Button"] = "PFSTANCEONE",
    ["pfActionBarStanceBar2Button"] = "PFSTANCETWO",
    ["pfActionBarStanceBar3Button"] = "PFSTANCETHREE",
    ["pfActionBarStanceBar4Button"] = "PFSTANCEFOUR",
  }

  local mousebuttonmap = {
    ["LeftButton"]   = "BUTTON1",
    ["RightButton"]  = "BUTTON2",
    ["MiddleButton"] = "BUTTON3",
    ["Button4"]      = "BUTTON4",
    ["Button5"]      = "BUTTON5",
  }

  local mousewheelmap = {
    [1]  = "MOUSEWHEELUP",
    [-1] = "MOUSEWHEELDOWN",
  }

  local modifiers = {
    ["ALT"]   = "ALT-",
    ["CTRL"]  = "CTRL-",
    ["SHIFT"] = "SHIFT-"
  }

  -- We don't allow binding these keys without any modifiers
  local blockedKeys = {
    "LeftButton",
    "RightButton",
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
    if pfUI.bars then
      pfUI.bars:UpdateGrid(1)
      pfUI.bars:UpdateGrid(1, "PET")
    end

    -- Initialize hoverbind frames on first show. We can't do this before because the action 
    -- bars might not exist yet when this module is loaded.
    if not pfUI.hoverbind.frames then
      pfUI.hoverbind.frames = pfUI.hoverbind:CreateHoverbindFrames()
    end

    pfUI.gui:Hide()
    pfUI.hoverbind.edit:Show()
    pfUI.hoverbind:ShowHoverbindFrames()

    local txt = T["|cff33ffccKeybind Mode|r\nThis mode allows you to bind keyboard shortcuts to your actionbars.\nBy hovering a button with your cursor and pressing a key, the key will be assigned to that button.\nHit Escape on a button to remove bindings.\n\nPress Escape or click on an empty area to leave the keybind mode."]
    CreateInfoBox(txt, 30,  pfUI.hoverbind.edit)
  end)

  pfUI.hoverbind:SetScript("OnHide",function()
    if pfUI.bars then
      pfUI.bars:UpdateGrid(0)
      pfUI.bars:UpdateGrid(0, "PET")
    end
    pfUI.hoverbind:HideHoverbindFrames()
    pfUI.hoverbind.edit:Hide()
    pfUI.gui:Show()
  end)

  function pfUI.hoverbind:GetBinding(button_name)
    local found,_,buttontype,buttonindex = string.find(button_name,"^(.-)(%d+)$")
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

  -- Loops over all actionbar buttons and creates an invisible overlapping hoverbind frame
  -- for each of them. These hoverbind frames receive all key, mouse and mouse wheel events
  -- so we can bind the respective key, mouse button or mouse wheel direction to the underlying
  -- actionbar button. They should only be shown when hoverbind is active, otherwise the
  -- underlying actionbar buttons can't be clicked anymore.
  function pfUI.hoverbind:CreateHoverbindFrames()
    if not pfUI.bars then return end

    local frames = {}

    for i=1,12 do
      for j=1,12 do
        local button = pfUI.bars[i][j]
        if button then
          local frame = CreateFrame("Frame", button:GetName() .. "HoverbindFrame", button)
          frame:SetAllPoints(button)
          frame:EnableKeyboard(true)
          frame:EnableMouse(true)
          frame:EnableMouseWheel(true)
          frame:Hide()

          -- Store the actionbar button on the overlaying hoverbind frame so we can reference 
          -- them in the hoverbind handler to create the key/mouse binding. We need this
          -- because the hoverbind frames "steal" the mouse focus from the actual buttons.
          frame.button = button

          local function GetHoverbindHandler(map)
            return function()
              if modifiers[arg1] then return end -- ignore single modifier keyup

              local prefix = pfUI.hoverbind:GetPrefix()

              -- Don't allow binding certain buttons without modifiers
              if not prefix or prefix == "" then
                for _, blockedKey in ipairs(blockedKeys) do
                  if arg1 == blockedKey then return end
                end
              end

              local frame = GetMouseFocus()
              local hovername = (frame and frame.button and frame.button.GetName) and frame.button:GetName() or ""
              local binding = pfUI.hoverbind:GetBinding(hovername)
              if arg1 == "ESCAPE" and not binding then pfUI.hoverbind:Hide() return end
              if binding then
                if arg1 == "ESCAPE" then 
                  -- Remove existing binding
                  local key = (GetBindingKey(binding))
                  if (key) then
                    SetBinding(key)
                    SaveBindings(GetCurrentBindingSet())
                  end
                else 
                  -- Create new binding
                  local key = map and map[arg1] or arg1
                  if (SetBinding(prefix..key, binding)) then
                    SaveBindings(GetCurrentBindingSet())
                  end
                end
              end
            end
          end
          frame:SetScript("OnKeyUp", GetHoverbindHandler())
          frame:SetScript("OnMouseUp", GetHoverbindHandler(mousebuttonmap))
          frame:SetScript("OnMouseWheel", GetHoverbindHandler(mousewheelmap))

          -- Explicitly call the corresponding button's onEnter/onLeave handlers to show/hide
          -- its highlight and tooltip. This is necessary because the actual buttons don't
          -- receive any mouse events in hoverbind mode since those are swallowed by the
          -- overlapping hoverbind frames.
          frame:SetScript("OnEnter", function()
            pfUI.bars.ButtonEnter(button)
          end)
          frame:SetScript("OnLeave", function()
            pfUI.bars.ButtonLeave(button)
          end)

          table.insert(frames, frame)
        end
      end
    end

    return frames
  end

  function pfUI.hoverbind:ShowHoverbindFrames()
    if not pfUI.hoverbind.frames then return end
    for _, frame in ipairs(pfUI.hoverbind.frames) do
      frame:Show()
    end
  end

  function pfUI.hoverbind:HideHoverbindFrames()
    if not pfUI.hoverbind.frames then return end
    for _, frame in ipairs(pfUI.hoverbind.frames) do
      frame:Hide()
    end
  end

  pfUI.hoverbind:SetScript("OnEvent",function()
    -- disable hoverbind so player gets back control of their keyboard to fight
    pfUI.hoverbind:Hide()
  end)
end)
