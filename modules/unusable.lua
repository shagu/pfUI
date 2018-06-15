pfUI:RegisterModule("unusable", function ()
  pfUI.unusable = CreateFrame("Frame", "pfUnusable", UIParent)
  pfUI.unusable.tooltip = CreateFrame("GameTooltip", "pfUnusableTooltip", UIParent, "GameTooltipTemplate")

  pfUI.unusable:RegisterEvent("MAIL_INBOX_UPDATE")
  pfUI.unusable:RegisterEvent("PLAYER_LEVEL_UP")
  pfUI.unusable:RegisterEvent("SKILL_LINES_CHANGED")

  pfUI.unusable.unusables = {}

  pfUI.unusable:SetScript("OnEvent", function()
    if event == "MAIL_INBOX_UPDATE" and MailFrame:IsVisible() then
      local total = GetInboxNumItems()
      for i = 1, INBOXITEMS_TO_DISPLAY do
        local index = (((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + i)
        local name, _, _, _, canUse = GetInboxItem(index)
        local _, _, _, _, _, _, _, hasItem = GetInboxHeaderInfo(index)

        if hasItem and hasItem > 0 and name then
          if not canUse or not pfUI.unusable:IsItemUsable(name, "MailBox", i) then
            pfUI.unusable:MakeUnusable(_G["MailItem" .. i .. "ButtonIcon"])
          end
        else
          pfUI.unusable:MakeUsable(_G["MailItem" .. i .. "ButtonIcon"])
        end
      end
    elseif event == "PLAYER_LEVEL_UP" or event == "SKILL_LINES_CHANGED" then
      for _, slot in pairs(pfUI.unusable.unusables) do
        if slot and not pfUI.unusable:IsSlotItemUsable(slot) then
          pfUI.unusable:MakeUnusable(slot)
        end
      end
    end
  end)

  function pfUI.unusable:UpdateSlot(frame, bag, slot)
    if not pfUI.unusable:IsSlotItemUsable(frame, bag, slot) then
      pfUI.unusable:MakeUnusable(frame)
    else
      pfUI.unusable:MakeUsable(frame)
    end
  end

  function pfUI.unusable:IsSlotItemUsable(slot, bag, index)
    if not bag then bag = slot.bag end
    if not index then index = slot.slot end

    local itemId, name = self:GetItemInfoFromLink(GetContainerItemLink(bag, index))
    return self:IsItemUsable(itemId, bag, index)
  end

  function pfUI.unusable:IsItemUsable(item, bag, slot)
    if item and (type(item) == "number" and item < 0) or item == "Unknown" then
      return true
    else
      local name, itemLink, _, minLevel = GetItemInfo(item)

      if minLevel and minLevel > UnitLevel("player") then
          return false
      end
    end

    self.tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    if bag == -1 then
      self.tooltip:SetInventoryItem("player", slot + 39)
    elseif bag == "MailBox" then
      self.tooltip:SetInboxItem(slot)
    elseif bag == "Merchant" then
      self.tooltip:SetMerchantItem(slot)
    else
      self.tooltip:SetBagItem(bag, slot)
    end

    local result = true
    for id = 0, 8 do
      for _, v in pairs({"TextRight", "TextLeft"}) do
        local widget = _G["pfUnusableTooltip"..v..id]
        if widget and widget:GetText() then
          local r, g, b = widget:GetTextColor()
          if r > .9 and g < .2 and b < .2 then
            -- item contains red text
            result = false
            break
          end
        end
        if not result then break end
      end
    end

    self.tooltip:Hide()
    return result
  end

  function pfUI.unusable:MakeUnusable(slot)
    if not slot then return end
    local frame = slot.frame

    if type(frame) == "number" then
      if MerchantFrame:IsVisible() then
        local itemButton = _G["MerchantItem" .. frame .. "ItemButton"]
        if itemButton then
          SetItemButtonTextureVertexColor(itemButton, 0, 1, 0)
          SetItemButtonNormalTextureVertexColor(itemButton, 0, 1, 0)
        end
        local merchantButton = _G["MerchantItem" .. frame]
        if merchantButton then
          SetItemButtonNameFrameVertexColor(merchantButton, 0, 1, 0)
          SetItemButtonSlotVertexColor(merchantButton, 0, 1, 0)
        end
      end
    elseif type(frame) == "table" or type(frame) == "userdata" then
      if frame:IsObjectType("Texture") then
        SetDesaturation(frame, nil)
        frame:SetVertexColor(1, 0, 0)
        SetDesaturation(frame, nil)
      else
        SetItemButtonTextureVertexColor(frame, 1, 0, 0)

        -- Hack: there is an issue with the bank frame overriding the VertexColor,
        --       since we have no idea where this is happening, we will store the
        --       original SetVertexColor function and override it, it will be restored
        --       when we call MakeUsable().
        if not slot.oldVertexFunc and slot.bag and slot.bag < 0 then
          slot.oldVertexFunc = _G[frame:GetName().."IconTexture"].SetVertexColor
          _G[frame:GetName().."IconTexture"].SetVertexColor = function(this, r, g, b, a)
            return slot.oldVertexFunc(this, 1, 0, 0)
          end
        end
      end
    else
      return false
    end

    self.unusables[slot] = slot
    return true
  end

  function pfUI.unusable:MakeUsable(slot)
    if not slot then return end
    local frame = slot.frame

    if type(frame) == "number" and MerchantFrame:IsVisible() then
      local itemButton = _G["MerchantItem" .. frame .. "ItemButton"]
      if itemButton then
        SetItemButtonTextureVertexColor(itemButton, 1, 1, 1)
        SetItemButtonNormalTextureVertexColor(itemButton, 1, 1, 1)
      end
      local merchantButton = _G["MerchantItem" .. frame]
      if merchantButton then
        SetItemButtonNameFrameVertexColor(merchantButton, 1, 1, 1)
        SetItemButtonSlotVertexColor(merchantButton, 1, 1, 1)
      end
    elseif type(frame) == "table" or type(frame) == "userdata" then
      if frame:IsObjectType("Texture") then
        SetDesaturation(frame, nil)
        frame:SetVertexColor(1, 1, 1)
        SetDesaturation(frame, nil)
      else
        if slot.oldVertexFunc then
          _G[frame:GetName().."IconTexture"].SetVertexColor = slot.oldVertexFunc
          slot.oldVertexFunc = nil
        end

        SetItemButtonTextureVertexColor(frame, 1, 1, 1)
      end
    else
      return false
    end

    self.unusables[slot] = nil
    return true
  end

  function pfUI.unusable:GetItemInfoFromLink(link)
    local id = -1
    local name = "Unknown"
    if link ~= nil then
      for i, n in string.gfind(link, "|c%x+|Hitem:(%d+):%d+:%d+:%d+|h%[(.-)%]|h|r") do
        if i ~= nil then id = i end
        if n ~= nil then name = n end
      end
    end
    return id, name
  end
end)
