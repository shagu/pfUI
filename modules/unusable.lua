pfUI:RegisterModule("unusable", "vanilla", function ()
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
  local dura_capture = string.gsub(DURABILITY_TEMPLATE, "%%[^%s]+", "(.+)")
  local r, g, b, a = strsplit(",", C.appearance.bags.unusable_color)

  function pfUI.unusable:UpdateSlot(bag, slot)
    local frame = pfUI.bags[bag].slots[slot].frame
    self.cache[bag] = self.cache[bag] or {}
    if frame.hasItem then
      if bag == BANK_CONTAINER then
        scanner:SetInventoryItem("player", 39+slot)
      else
        scanner:SetBagItem(bag, slot)
      end
      local name = frame:GetName()
      local red_line = scanner:Color(RED_FONT_COLOR)
      if red_line then
        local left = scanner:Line(red_line)
        local _,_, is_durability = string.find(left,dura_capture,1)
        if not is_durability then
          _G.SetItemButtonTextureVertexColor(_G[name],r,g,b,a)
          self.cache[bag][slot] = true
        end
      else
        self.cache[bag][slot] = false
      end
    else
      if self.cache[bag][slot] then
        self.cache[bag][slot] = false
      end
    end
  end

  function pfUI.unusable:UpdateCache()
    local self = self or pfUI.unusable
    for bag,slots in pairs(self.cache) do
      for slot,status in pairs(slots) do
        if status then
          pfUI.bag:UpdateSlot(bag, slot)
        end
      end
    end
  end

  function pfUI.unusable:DumpCache()
    local self = self or pfUI.unusable
    for bag,slots in pairs(self.cache) do
      for slot, status in pairs(slots) do
        if status then
          print(string.format("bag:%s, slot:%s",bag,slot))
        end
      end
    end
  end

  pfUI.unusable:SetScript("OnEvent", function()
    if event == "PLAYERBANKSLOTS_CHANGED" or event == "BANKFRAME_OPENED" then
      QueueFunction(this.UpdateCache,this) -- BankFrameItemButton_OnUpdate fires after UpdateSlot overriding changes
    else
      this:UpdateCache()
    end
  end)

  -- manual post hook update slot, hooksecurefunc won't work; _G[] doesn't like keys with periods.
  local bagUpdateSlot = pfUI.bag.UpdateSlot
  pfUI.bag.UpdateSlot = function(_, bag, slot)
    bagUpdateSlot(pfUI.bag, bag, slot)
    pfUI.unusable:UpdateSlot(bag, slot)
  end

end)
