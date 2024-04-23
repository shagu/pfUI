pfUI:RegisterModule("unusable", "vanilla:tbc", function ()
  if not pfUI.bag then return end

  if C.appearance.bags.unusable ~= "1" then return end

  pfUI.unusable = CreateFrame("Frame")
  pfUI.unusable:RegisterEvent("PLAYER_LEVEL_UP")
  pfUI.unusable:RegisterEvent("SKILL_LINES_CHANGED")
  pfUI.unusable:RegisterEvent("ITEM_LOCK_CHANGED")
  pfUI.unusable:RegisterEvent("ACTIONBAR_HIDEGRID")
  pfUI.unusable:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
  pfUI.unusable:RegisterEvent("BANKFRAME_OPENED")
  pfUI.unusable.cache = {}

  local scanner = libtipscan:GetScanner("unusable")
  local durability = string.gsub(DURABILITY_TEMPLATE, "%%[^%s]+", "(.+)")
  local r, g, b, a = strsplit(",", C.appearance.bags.unusable_color)

  function pfUI.unusable:UpdateSlot(bag, slot)
    -- create bag cache and clear slot cache
    self.cache[bag] = self.cache[bag] or {}
    self.cache[bag][slot] = nil

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

  function pfUI.unusable:UpdateCache()
    local self = self or pfUI.unusable

    -- iterate through all known caches
    for bag, slots in pairs(self.cache) do
      for slot, state in pairs(slots) do
        pfUI.bag:UpdateSlot(bag, slot)
      end
    end
  end

  pfUI.unusable:SetScript("OnEvent", function()
    -- update all cached buttons
    if event == "PLAYERBANKSLOTS_CHANGED" or event == "BANKFRAME_OPENED" then
      -- BankFrameItemButton_OnUpdate fires after UpdateSlot overriding changes
      QueueFunction(this.UpdateCache, this)
    else
      -- regular button update
      this:UpdateCache()
    end
  end)
end)
