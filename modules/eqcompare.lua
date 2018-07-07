pfUI:RegisterModule("eqcompare", function ()
  local loc = pfUI.cache["locale"]
  for key, value in pairs(L["itemtypes"]) do setglobal(key, value) end
  INVTYPE_WEAPON_OTHER = INVTYPE_WEAPON.."_other";
  INVTYPE_FINGER_OTHER = INVTYPE_FINGER.."_other";
  INVTYPE_TRINKET_OTHER = INVTYPE_TRINKET.."_other";

  pfUI.slotTable = {
    [INVTYPE_2HWEAPON] = "MainHandSlot",
    [INVTYPE_BODY] = "ShirtSlot",
    [INVTYPE_CHEST] = "ChestSlot",
    [INVTYPE_CLOAK] = "BackSlot",
    [INVTYPE_FEET] = "FeetSlot",
    [INVTYPE_FINGER] = "Finger0Slot",
    [INVTYPE_FINGER_OTHER] = "Finger1Slot",
    [INVTYPE_HAND] = "HandsSlot",
    [INVTYPE_HEAD] = "HeadSlot",
    [INVTYPE_HOLDABLE] = "SecondaryHandSlot",
    [INVTYPE_LEGS] = "LegsSlot",
    [INVTYPE_NECK] = "NeckSlot",
    [INVTYPE_RANGED] = "RangedSlot",
    [INVTYPE_RELIC] = "RangedSlot",
    [INVTYPE_ROBE] = "ChestSlot",
    [INVTYPE_SHIELD] = "SecondaryHandSlot",
    [INVTYPE_SHOULDER] = "ShoulderSlot",
    [INVTYPE_TABARD] = "TabardSlot",
    [INVTYPE_TRINKET] = "Trinket0Slot",
    [INVTYPE_TRINKET_OTHER] = "Trinket1Slot",
    [INVTYPE_WAIST] = "WaistSlot",
    [INVTYPE_WEAPON] = "MainHandSlot",
    [INVTYPE_WEAPON_OTHER] = "SecondaryHandSlot",
    [INVTYPE_WEAPONMAINHAND] = "MainHandSlot",
    [INVTYPE_WEAPONOFFHAND] = "SecondaryHandSlot",
    [INVTYPE_WRIST] = "WristSlot",

    [INVTYPE_WAND] = "RangedSlot",
    [INVTYPE_GUN] = "RangedSlot",
    [INVTYPE_PROJECTILE] = "AmmoSlot",
    [INVTYPE_CROSSBOW] = "RangedSlot",
    [INVTYPE_THROWN] = "RangedSlot",
  }

  HookScript(ShoppingTooltip1, "OnShow", function()
    if C.tooltip.compare.basestats == "1" then
      local targetData = pfUI.eqcompare:ExtractAttributes(ShoppingTooltip1)
      pfUI.eqcompare:CompareAttributes(ShoppingTooltip1._data, targetData)
    end
  end)

  HookScript(ShoppingTooltip2, "OnShow", function()
    if C.tooltip.compare.basestats == "1" then
      local targetData = pfUI.eqcompare:ExtractAttributes(ShoppingTooltip2)
      pfUI.eqcompare:CompareAttributes(ShoppingTooltip2._data, targetData)
    end
  end)

  pfUI.eqcompare = CreateFrame( "Frame" , "pfEQCompare", GameTooltip )
  pfUI.eqcompare.ShowCompare = function(tooltip)
    -- use GameTooltip as default
    if not tooltip then tooltip = GameTooltip end

    if not IsShiftKeyDown() and C.tooltip.compare.showalways ~= "1" and not MerchantFrame:IsShown() then
      return
    end

    local data = pfUI.eqcompare:ExtractAttributes(tooltip)
    ShoppingTooltip1._data = data
    ShoppingTooltip2._data = data

    local border = tonumber(C.appearance.border.default)

    for i=1,tooltip:NumLines() do
      local tmpText = _G[tooltip:GetName() .. "TextLeft"..i]

      for slotType, slotName in pairs(pfUI.slotTable) do
        if tmpText:GetText() == slotType then
          local slotID = GetInventorySlotInfo(pfUI.slotTable[slotType])

          -- determine screen part
          local ltrigger = GetScreenWidth() / 2
          local x = GetCursorPosition()
          x = x / UIParent:GetEffectiveScale()
          if x > ltrigger then ltrigger = nil end

          -- first tooltip
          ShoppingTooltip1:SetOwner(tooltip, "ANCHOR_NONE");
          ShoppingTooltip1:ClearAllPoints();

          if ltrigger then
            ShoppingTooltip1:SetPoint("BOTTOMLEFT", tooltip, "BOTTOMRIGHT", 0, 0);
          else
            ShoppingTooltip1:SetPoint("BOTTOMRIGHT", tooltip, "BOTTOMLEFT", -border*2-1, 0);
          end

          ShoppingTooltip1:SetInventoryItem("player", slotID)
          ShoppingTooltip1:Show();

          -- second tooltip
          if pfUI.slotTable[slotType .. "_other"] then
            local slotID_other = GetInventorySlotInfo(pfUI.slotTable[slotType .. "_other"])

            ShoppingTooltip2:SetOwner(tooltip, "ANCHOR_NONE");
            ShoppingTooltip2:ClearAllPoints();

            if ltrigger then
              ShoppingTooltip2:SetPoint("BOTTOMLEFT", ShoppingTooltip1, "BOTTOMRIGHT", 0, 0);
            else
              ShoppingTooltip2:SetPoint("BOTTOMRIGHT", ShoppingTooltip1, "BOTTOMLEFT", -border*2-1, 0);
            end

            ShoppingTooltip2:SetInventoryItem("player", slotID_other)
            ShoppingTooltip2:Show();
          end
          return true
        end
      end
    end
  end
  pfUI.eqcompare:SetScript("OnShow", pfUI.eqcompare.ShowCompare)

  local function startsWith(str, start)
    return string.sub(str, 1, string.len(start)) == start
  end

  function pfUI.eqcompare:ExtractAttributes(tooltip)
    local name = tooltip:GetName()
    local data = {}
    for i=1,30 do
      local widget = _G[name.."TextLeft"..i]
      if widget and widget:GetObjectType() == "FontString" then
        local text = widget:GetText()
        if text and not string.find(text, "-", 1, true) then
          local start = 1
          if startsWith(text, "\+") or startsWith(text, "\(") then start = 2 end

          local space = string.find(text, " ", 1, true)
          if space then
            local value = tonumber(string.sub(text, start, space-1))
            if value and text then
              -- we've found an attr
              local attr = string.sub(text, space, string.len(text))
              data[attr] = { value = tonumber(value), widget = widget }
            end
          end
        end
      end
    end
    return data
  end

  function pfUI.eqcompare:CompareAttributes(data, targetData)
    if not data then return end
    for attr,v in pairs(data) do
      if targetData then
        local target = targetData[attr]
        if target then
          if v.value ~= target.value then
            if v.value > target.value then
              if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. v.value - target.value .. ")")
              end
            elseif not v.widget.compSet then
              if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. target.value - v.value .. ")")
              end
            end
            target.processed = true
          else
            target.processed = true
          end
        else
          -- this attribute doesnt exist in target
          v.widget:SetTextColor(.4, 1, .4)
        end
      end
    end

    for _,target in pairs(targetData) do
      if target and not target.processed then
        -- we are an extra value
        target.widget:SetTextColor(.4, 1, .4)
      end
    end
  end

end)
