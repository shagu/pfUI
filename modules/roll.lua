pfUI:RegisterModule("roll", "vanilla:tbc", function ()
  pfUI.roll = CreateFrame("Frame", "pfLootRoll", UIParent)
  pfUI.roll.frames = {}

  -- squash vanilla item placeholders
  local LOOT_ROLL_GREED = string.gsub(LOOT_ROLL_GREED, "%%s|Hitem:%%d:%%d:%%d:%%d|h%[%%s%]|h%%s", "%%s")
  local LOOT_ROLL_NEED = string.gsub(LOOT_ROLL_NEED, "%%s|Hitem:%%d:%%d:%%d:%%d|h%[%%s%]|h%%s", "%%s")
  local LOOT_ROLL_PASSED = string.gsub(LOOT_ROLL_PASSED, "%%s|Hitem:%%d:%%d:%%d:%%d|h%[%%s%]|h%%s", "%%s")

  -- try to detect the everyone string
  local _, _, everyone, _ = strfind(LOOT_ROLL_ALL_PASSED, LOOT_ROLL_PASSED)
  pfUI.roll.blacklist = { YOU, everyone }

  pfUI.roll.cache = {}

  pfUI.roll.scan = CreateFrame("Frame", "pfLootRollMonitor", UIParent)
  pfUI.roll.scan:RegisterEvent("CHAT_MSG_LOOT")
  pfUI.roll.scan:SetScript("OnEvent", function()
    local player, item = cmatch(arg1, LOOT_ROLL_GREED)
    if player and item then
      pfUI.roll:AddCache(item, player, "GREED")
      return
    end

    local player, item = cmatch(arg1, LOOT_ROLL_NEED)
    if player and item then
      pfUI.roll:AddCache(item, player, "NEED")
      return
    end

    local player, item = cmatch(arg1, LOOT_ROLL_PASSED)
    if player and item then
      pfUI.roll:AddCache(item, player, "PASS")
      return
    end
  end)

  function pfUI.roll:AddCache(hyperlink, name, roll)
    -- skip invalid names
    for _, invalid in pairs(pfUI.roll.blacklist) do
      if name == invalid then return end
    end

    local _, _, itemLink = string.find(hyperlink, "(item:%d+:%d+:%d+:%d+)")
    local itemName = GetItemInfo(itemLink)

    -- delete obsolete tables
    if pfUI.roll.cache[itemName] and pfUI.roll.cache[itemName]["TIMESTAMP"] < GetTime() - 60 then
      pfUI.roll.cache[itemName] = nil
    end

    -- initialize itemtable
    if not pfUI.roll.cache[itemName] then
      pfUI.roll.cache[itemName] = { ["GREED"] = {}, ["NEED"] = {}, ["PASS"] = {}, ["TIMESTAMP"] = GetTime() }
    end

    -- ignore already listed names
    for _, existing in pairs(pfUI.roll.cache[itemName][roll]) do
      if name == existing then return end
    end

    table.insert(pfUI.roll.cache[itemName][roll], name)

    for id=1,4 do
      if pfUI.roll.frames[id]:IsVisible() and pfUI.roll.frames[id].itemname == itemName then
        local count_greed = pfUI.roll.cache[itemName] and table.getn(pfUI.roll.cache[itemName]["GREED"]) or 0
        local count_need  = pfUI.roll.cache[itemName] and table.getn(pfUI.roll.cache[itemName]["NEED"]) or 0
        local count_pass  = pfUI.roll.cache[itemName] and table.getn(pfUI.roll.cache[itemName]["PASS"]) or 0

        pfUI.roll.frames[id].greed.count:SetText(count_greed > 0 and count_greed or "")
        pfUI.roll.frames[id].need.count:SetText(count_need > 0 and count_need or "")
        pfUI.roll.frames[id].pass.count:SetText(count_pass > 0 and count_pass or "")
      end
    end
  end

  function pfUI.roll:CreateLootRoll(id)
    local size = 24
    local rawborder, border = GetBorderSize()
    local esize = size - border*2
    local f = CreateFrame("Frame", "pfLootRollFrame" .. id, UIParent)

    CreateBackdrop(f, nil, nil, .8)
    CreateBackdropShadow(f)

    f.backdrop:SetFrameStrata("BACKGROUND")
    f.hasItem = 1

    f:SetWidth(350)
    f:SetHeight(size)

    f.icon = CreateFrame("Button", "pfLootRollFrame" .. id .. "Icon", f)
    CreateBackdrop(f.icon, nil, true)
    f.icon:SetPoint("LEFT", border, 0)
    f.icon:SetWidth(esize)
    f.icon:SetHeight(esize)

    f.icon.tex = f.icon:CreateTexture("OVERLAY")
    f.icon.tex:SetTexCoord(.08, .92, .08, .92)
    f.icon.tex:SetAllPoints(f.icon)

    f.icon:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
      GameTooltip:SetLootRollItem(this:GetParent().rollID)
      CursorUpdate()
    end)

    f.icon:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    f.icon:SetScript("OnClick", function()
      if IsControlKeyDown() then
        DressUpItemLink(GetLootRollItemLink(this:GetParent().rollID))
      elseif IsShiftKeyDown() then
        if ChatEdit_InsertLink then
          ChatEdit_InsertLink(GetLootRollItemLink(this:GetParent().rollID))
        elseif ChatFrameEditBox:IsVisible() then
          ChatFrameEditBox:Insert(GetLootRollItemLink(this:GetParent().rollID))
        end
      end
    end)

    f.need = CreateFrame("Button", "pfLootRollFrame" .. id .. "Need", f)
    f.need:SetPoint("LEFT", f.icon, "RIGHT", border*3, -1)
    f.need:SetWidth(esize)
    f.need:SetHeight(esize)
    f.need:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
    f.need:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Highlight")

    f.need.count = f.need:CreateFontString("NEED")
    f.need.count:SetPoint("CENTER", f.need, "CENTER", 0, 0)
    f.need.count:SetJustifyH("CENTER")
    f.need.count:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")

    f.need:SetScript("OnClick", function()
      RollOnLoot(this:GetParent().rollID, 1)
    end)
    f.need:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
      GameTooltip:SetText("|cff33ffcc" .. NEED)
      if f.itemname and pfUI.roll.cache[f.itemname] then
        for _, player in pairs(pfUI.roll.cache[f.itemname]["NEED"]) do
          GameTooltip:AddLine(player)
        end
      end
      GameTooltip:Show()
    end)
    f.need:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    f.greed = CreateFrame("Button", "pfLootRollFrame" .. id .. "Greed", f)
    f.greed:SetPoint("LEFT", f.icon, "RIGHT", border*5+esize, -2)
    f.greed:SetWidth(esize)
    f.greed:SetHeight(esize)
    f.greed:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
    f.greed:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Highlight")

    f.greed.count = f.greed:CreateFontString("GREED")
    f.greed.count:SetPoint("CENTER", f.greed, "CENTER", 0, 1)
    f.greed.count:SetJustifyH("CENTER")
    f.greed.count:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")

    f.greed:SetScript("OnClick", function()
      RollOnLoot(this:GetParent().rollID, 2)
    end)
    f.greed:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
      GameTooltip:SetText("|cff33ffcc" .. GREED)
      if f.itemname and pfUI.roll.cache[f.itemname] then
        for _, player in pairs(pfUI.roll.cache[f.itemname]["GREED"]) do
          GameTooltip:AddLine(player)
        end
      end
      GameTooltip:Show()
    end)
    f.greed:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    f.pass = CreateFrame("Button", "pfLootRollFrame" .. id .. "Pass", f)
    f.pass:SetPoint("LEFT", f.icon, "RIGHT", border*7+esize*2, 0)
    f.pass:SetWidth(esize)
    f.pass:SetHeight(esize)
    f.pass:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    f.pass:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Highlight")

    f.pass.count = f.pass:CreateFontString("PASS")
    f.pass.count:SetPoint("CENTER", f.pass, "CENTER", 0, -1)
    f.pass.count:SetJustifyH("CENTER")
    f.pass.count:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")

    f.pass:SetScript("OnClick", function()
      RollOnLoot(this:GetParent().rollID, 0)
    end)
    f.pass:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
      GameTooltip:SetText("|cff33ffcc" .. PASS)
      if f.itemname and pfUI.roll.cache[f.itemname] then
        for _, player in pairs(pfUI.roll.cache[f.itemname]["PASS"]) do
          GameTooltip:AddLine(player)
        end
      end
      GameTooltip:Show()
    end)
    f.pass:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    f.boe = CreateFrame("Frame", "pfLootRollFrame" .. id .. "BOE", f)
    f.boe:SetPoint("LEFT", f.icon, "RIGHT", border*9+esize*3, 0)
    f.boe:SetWidth(esize*2)
    f.boe:SetHeight(esize)
    f.boe.text = f.boe:CreateFontString("BOE")
    f.boe.text:SetAllPoints(f.boe)
    f.boe.text:SetJustifyH("LEFT")
    f.boe.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")

    f.name = CreateFrame("Frame", "pfLootRollFrame" .. id .. "Name", f)
    f.name:SetPoint("LEFT", f.icon, "RIGHT", border*11+esize*4, 0)
    f.name:SetPoint("RIGHT", f, "RIGHT", border*2, 0)
    f.name:SetHeight(esize)
    f.name.text = f.name:CreateFontString("NAME")
    f.name.text:SetAllPoints(f.name)
    f.name.text:SetJustifyH("LEFT")
    f.name.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")

    f.time = CreateFrame("Frame", "pfLootRollFrame" .. id .. "Time", f)
    f.time:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    f.time:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    f.time:SetFrameStrata("LOW")
    f.time.bar = CreateFrame("StatusBar", "pfLootRollFrame" .. id .. "TimeBar", f.time)
    f.time.bar:SetAllPoints(f.time)
    f.time.bar:SetStatusBarTexture(pfUI.media["img:bar"])
    f.time.bar:SetMinMaxValues(0, 100)
    local r, g, b, a = strsplit(",", C.appearance.border.color)
    f.time.bar:SetStatusBarColor(r, g, b)
    f.time.bar:SetValue(20)
    f.time.bar:SetScript("OnUpdate", function()
      if not this:GetParent():GetParent().rollID then return end
      local left = GetLootRollTimeLeft(this:GetParent():GetParent().rollID)
      local min, max = this:GetMinMaxValues()
      if left < min or left > max then left = min end
      this:SetValue(left)
    end)

    return f
  end

  pfUI.roll:RegisterEvent("CANCEL_LOOT_ROLL")
  pfUI.roll:SetScript("OnEvent", function()
    for i=1,4 do
      if pfUI.roll.frames[i].rollID == arg1 then
        pfUI.roll.frames[i]:Hide()
      end
    end
  end)

  function _G.GroupLootFrame_OpenNewFrame(id, rollTime)
    -- clear cache if possible
    local visible = nil
    for i=1,4 do
      visible = visible or pfUI.roll.frames[i]:IsVisible()
    end
    if not visible then pfUI.roll.cache = {} end

    -- setup roll frames
    for i=1,4 do
      if not pfUI.roll.frames[i]:IsVisible() then
        pfUI.roll.frames[i].rollID = id
        pfUI.roll.frames[i].rollTime = rollTime
        pfUI.roll:UpdateLootRoll(i)
        return
      end
    end
  end

  function pfUI.roll:UpdateLootRoll(id)
    local texture, name, count, quality, bop = GetLootRollItemInfo(pfUI.roll.frames[id].rollID)
    local color = ITEM_QUALITY_COLORS[quality]

    pfUI.roll.frames[id].itemname = name

    local count_greed = pfUI.roll.cache[name] and table.getn(pfUI.roll.cache[name]["GREED"]) or 0
    local count_need  = pfUI.roll.cache[name] and table.getn(pfUI.roll.cache[name]["NEED"]) or 0
    local count_pass  = pfUI.roll.cache[name] and table.getn(pfUI.roll.cache[name]["PASS"]) or 0

    pfUI.roll.frames[id].greed.count:SetText(count_greed > 0 and count_greed or "")
    pfUI.roll.frames[id].need.count:SetText(count_need > 0 and count_need or "")
    pfUI.roll.frames[id].pass.count:SetText(count_pass > 0 and count_pass or "")

    pfUI.roll.frames[id].name.text:SetText(name)
    pfUI.roll.frames[id].name.text:SetTextColor(color.r, color.g, color.b, 1)
    pfUI.roll.frames[id].icon.tex:SetTexture(texture)
    pfUI.roll.frames[id].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
    pfUI.roll.frames[id].time.bar:SetMinMaxValues(0, pfUI.roll.frames[id].rollTime)

    if C.loot.raritytimer == "1" then
      pfUI.roll.frames[id].time.bar:SetStatusBarColor(color.r, color.g, color.b, .5)
    end

    if bop then
      pfUI.roll.frames[id].boe.text:SetText(T["BoP"])
      pfUI.roll.frames[id].boe.text:SetTextColor(1,.3,.3,1)
    else
      pfUI.roll.frames[id].boe.text:SetText(T["BoE"])
      pfUI.roll.frames[id].boe.text:SetTextColor(.3,1,.3,1)
    end

    pfUI.roll.frames[id]:Show()
  end

  for i=1,4 do
    if not pfUI.roll.frames[i] then
      pfUI.roll.frames[i] = pfUI.roll:CreateLootRoll(i)
      pfUI.roll.frames[i]:SetPoint("CENTER", 0, -i*35)
      UpdateMovable(pfUI.roll.frames[i])
      pfUI.roll.frames[i]:Hide()
    end
  end
end)
