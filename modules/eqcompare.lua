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
    [INVTYPE_GUNPROJECTILE] = "AmmoSlot",
    [INVTYPE_BOWPROJECTILE] = "AmmoSlot",
    [INVTYPE_CROSSBOW] = "RangedSlot",
    [INVTYPE_THROWN] = "RangedSlot",
  }

  pfUI.eqcompare = CreateFrame( "Frame" , "pfEQCompare", GameTooltip )
  pfUI.eqcompare:SetScript("OnShow", function()
    if not IsShiftKeyDown() and C.tooltip.compare.showalways ~= "1" then
      return
    end

    local border = tonumber(C.appearance.border.default)

    for i=1,GameTooltip:NumLines() do
      local tmpText = _G["GameTooltipTextLeft"..i]

      for slotType, slotName in pairs(pfUI.slotTable) do
        if tmpText:GetText() == slotType then
          local slotID = GetInventorySlotInfo(pfUI.slotTable[slotType])

          -- determine screen part
          local ltrigger = GetScreenWidth() / 2
          local x = GetCursorPosition()
          x = x / UIParent:GetEffectiveScale()
          if x > ltrigger then ltrigger = nil end

          -- first tooltip
          ShoppingTooltip1:SetOwner(GameTooltip, "ANCHOR_NONE");
          ShoppingTooltip1:ClearAllPoints();

          if ltrigger then
            ShoppingTooltip1:SetPoint("BOTTOMLEFT", GameTooltip, "BOTTOMRIGHT", 0, 0);
          else
            ShoppingTooltip1:SetPoint("BOTTOMRIGHT", GameTooltip, "BOTTOMLEFT", -border*2-1, 0);
          end

          ShoppingTooltip1:SetInventoryItem("player", slotID)
          ShoppingTooltip1:Show();

          -- second tooltip
          if pfUI.slotTable[slotType .. "_other"] then
            local slotID_other = GetInventorySlotInfo(pfUI.slotTable[slotType .. "_other"])

            ShoppingTooltip2:SetOwner(GameTooltip, "ANCHOR_NONE");
            ShoppingTooltip2:ClearAllPoints();

            if ltrigger then
              ShoppingTooltip2:SetPoint("BOTTOMLEFT", ShoppingTooltip1, "BOTTOMRIGHT", 0, 0);
            else
              ShoppingTooltip2:SetPoint("BOTTOMRIGHT", ShoppingTooltip1, "BOTTOMLEFT", -border*2-1, 0);
            end

            ShoppingTooltip2:SetInventoryItem("player", slotID_other)
            ShoppingTooltip2:Show();
          end

        end
      end
    end
  end)
end)
