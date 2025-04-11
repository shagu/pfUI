pfUI:RegisterModule("unusable", "vanilla:tbc", function ()
  if not pfUI.bag then return end
  if C.appearance.bags.unusable ~= "1" then return end

  pfUI.unusable = {}

  local scanner = libtipscan:GetScanner("unusable")
  local durability = string.gsub(DURABILITY_TEMPLATE, "%%[^%s]+", "(.+)")
  local r, g, b, a = strsplit(",", C.appearance.bags.unusable_color)

  function pfUI.unusable:UpdateSlot(bag, slot)
    -- break on invalid bag slots
    if not pfUI.bags[bag] then return end
    if not pfUI.bags[bag].slots[slot] then return end

    -- add button shortcuts
    local frame = pfUI.bags[bag].slots[slot].frame
    local name = frame:GetName()

    -- return on empty buttons
    if not frame.hasItem then return end

    -- set the proper tooltip method
    if bag == BANK_CONTAINER then
      scanner:SetInventoryItem("player", 39+slot)
    else
      scanner:SetBagItem(bag, slot)
    end

    -- check for red color in tooltip
    local red = scanner:Color(RED_FONT_COLOR)
    if not red then return end

    -- check for broken items
    local left = scanner:Line(red)
    local _, _, broken = string.find(left, durability, 1)
    if broken then return end

    -- update button vertex color
    _G.SetItemButtonTextureVertexColor(frame, r, g, b, a)
  end

  -- update on regular pfUI button updates
  local HookUpdateSlot = pfUI.bag.UpdateSlot
  pfUI.bag.UpdateSlot = function(self, bag, slot)
    HookUpdateSlot(self, bag, slot)
    pfUI.unusable:UpdateSlot(bag, slot)
  end

  -- update on bank frame itemlock updates
  local HookBankFrameItemButton_UpdateLock = BankFrameItemButton_UpdateLock
  _G.BankFrameItemButton_UpdateLock = function()
    HookBankFrameItemButton_UpdateLock()
    pfUI.unusable:UpdateSlot(-1, this:GetID())
  end
end)
