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
  pfUI.unusable.frames = {}

  local scanner = libtipscan:GetScanner("unusable")
  local durability = string.gsub(DURABILITY_TEMPLATE, "%%[^%s]+", "(.+)")
  local r, g, b, a = strsplit(",", C.appearance.bags.unusable_color)

  function pfUI.unusable:UpdateSlot(bag, slot)
    local self = self or pfUI.unusable

    local frame = pfUI.bags[bag].slots[slot].frame
    local name = frame:GetName()

    -- clear previous item slot caches if existing
    if self.frames[bag] and self.frames[bag][slot] then
      self.frames[bag][slot] = nil
    end

    if frame.hasItem then
      -- write current item frame to cache
      self.frames[bag] = self.frames[bag] or {}
      self.frames[bag][slot] = frame

      -- read item tooltip
      if bag == BANK_CONTAINER then
        -- scanner:SetOwner(WorldFrame,"ANCHOR_NONE")
        scanner:SetInventoryItem("player", 39+slot)
      else
        -- scanner:SetOwner(WorldFrame,"ANCHOR_NONE")
        scanner:SetBagItem(bag, slot)
      end

      -- check item tooltip
      local red = scanner:Color(RED_FONT_COLOR)
      if not red then return end

      local left = scanner:Line(red)

      -- ignore broken equipment
      local _, _, is_broken = string.find(left, durability, 1)
      if is_broken then return end

      _G.SetItemButtonTextureVertexColor(_G[name], r, g, b, a)
    end
  end

  function pfUI.unusable:UpdateFrames()
    local self = self or pfUI.unusable

    -- update all known item frames
    for bag, slots in pairs(self.frames) do
      for slot, frame in pairs(slots) do
        pfUI.bag:UpdateSlot(bag, slot)
      end
    end
  end

  pfUI.unusable:SetScript("OnEvent", function()
    -- update all caches
    if event == "PLAYERBANKSLOTS_CHANGED" or event == "BANKFRAME_OPENED" then
      -- BankFrameItemButton_OnUpdate fires after UpdateSlot overriding changes
      QueueFunction(this.UpdateFrames, this)
    else
      -- regular update
      this:UpdateFrames()
    end
  end)
end)
