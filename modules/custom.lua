--[[ startup code ]]--
--[[

type
    One of the following:

        "list"
            Items up for auction, the "Browse" tab in the dialog.
        "bidder"
            Items the player has bid on, the "Bids" tab in the dialog.
        "owner"
            Items the player has up for auction, the "Auctions" tab in the dialog.


numBatchAuctions, totalAuctions = GetNumAuctionItems("list")
name, texture, count, quality, canUse, level, bid, minIncrement, buyoutPrice, bidAmount, highBidder, owner =  GetAuctionItemInfo("list", offset + i)
duration = GetAuctionItemTimeLeft("list", offset + i)


QueryAuctionItems(name, minLevel, maxLevel, selectedInvtypeIndex, selectedClassIndex, selectedSubclassIndex, page, IsUsable, rarity);

QueryAuctionItems(nil, nil, nil, nil, nil, nil, 1, nil, nil);


AUCTION_ITEM_LIST_UPDATE

PlaceAuctionBid("type", index, bid);

]]--

--[[ GetBagSlotByName ]]--
-- Find an item in bags by name.
-- Optionally set "skip" to ignore the first match.
-- Returns: Bag, Slot
local function GetBagSlotByName(name, skip)
  for b=0,4 do
    for s=0, GetContainerNumSlots(b) do
      local itemLink = GetContainerItemLink(b, s)
      if itemLink and string.sub(itemLink, string.find(itemLink, "%[")+1, string.find(itemLink, "%]")-1) == name then
        if skip then skip = nil else return b, s end
      end
    end
  end
end

--[[ GetEmptyBagSlot ]]--
-- Returns the first empty bag slot that was found.
local function GetEmptyBagSlot()
  for b=0,4 do
    for s=1, GetContainerNumSlots(b) do
      if not GetContainerItemLink(b, s) then return b, s end
    end
  end
end

do --[[ SplitItemByName ]]--
  -- Tries to split an item based on its name into pieces defined by amount.
  -- Returns the bag and slot into the callbacks first arguments,
  -- when the splitting process is done.

  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ITEM_LOCK_CHANGED")
  frame:SetScript("OnEvent", function()
    this.lock = nil
  end)

  frame:SetScript("OnUpdate", function()
    if this.lock then return end
    if not this.name then this:Hide() end

    local fb, fs = GetBagSlotByName(this.name)
    local tb, ts = GetEmptyBagSlot()

    if not fb or not tb then return end

    local _, count = GetContainerItemInfo(fb, fs)
    if count < this.amount then
      local bag, slot = GetBagSlotByName(this.name, true)
      if bag and slot then
        ClearCursor()
        PickupContainerItem(bag, slot)
        PickupContainerItem(fb, fs)
        ClearCursor()
        this.lock = true
        return
      else
        print("ERROR: Ooops! Something went wrong inside 'SplitItemByName'.")
        this:Hide()
      end
    else
      ClearCursor()
      SplitContainerItem(fb, fs, this.amount)
      PickupContainerItem(tb, ts)
      if this.callback then
        this.callback(tb, ts)
      end
      this:Hide()
    end
  end)

  function SplitItemByName(name, amount, callback)
    frame.name, frame.amount, frame.callback, frame.env = name, amount, callback
    frame:Show()
  end
end


local function BeautifyTimeLeft(time)
  if time == 1 then -- short (less than 30 minutes)
    return "|cffff555530m"
  elseif time == 2 then -- medium (30 minutes - 2 hours)
    return "|cffffff552h"
  elseif time == 3 then -- long (2 - 12 hours)
    return "|cff55ffff12h"
  elseif time == 4 then -- very long (more than 12 hours)
    return "|cff5555ff24h"
  else
    return "|cff555555??h"
  end
end

local function BeautifyGoldString(money)
  local gold = floor(money/100/100)
  local silver = floor(mod((money/100),100))
  local copper = floor(mod(money,100))

  if gold > 0 then
    return string.format("|r%d|cffffd700g|r %02d|cffc7c7cfs|r %02d|cffeda55fc|r", gold, silver, copper)
  elseif silver > 0 then
    return string.format("|r%d|cffc7c7cfs|r %02d|cffeda55fc|r", silver, copper)
  elseif copper > 0 then
    return string.format("|r%d|cffeda55fc|r", copper)
  else
    return "-"
  end
end
pfUI:RegisterModule("auctionhouse", function ()
  local db = {}

  local crawler = CreateFrame("Frame")
  crawler:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
  crawler:SetScript("OnEvent", function()
    local time = date("%Y-%m-%d")
    local batch, max = GetNumAuctionItems("list")

    for i=1, batch do
      local name, texture, count, quality, canUse, level, bid, minIncrement, buyout, bidAmount, highBidder, owner =  GetAuctionItemInfo("list", i)
      local duration = GetAuctionItemTimeLeft("list", i)
      local link = GetAuctionItemLink("list", i)
      local price = buyout and (count and buyout/count or buyout) or 0

      if not db[name] then db[name] = {} end
      if not db[name][time] then db[name][time] = {} end

      if price > 0 then
        local identifier = string.format("%s:%s:%s:%s", price, count, bid, buyout)

        local skip = nil
        for _, data in pairs(db[name][time]) do
          if data.identifier == identifier then
            skip = true
            break
          end
        end

        if not skip then
          table.insert(db[name][time], { identifier, price, count, bid, buyout })
        end
      end
    end
  end)

  local cache = {}
  local columns = {
    { "icon", "", 20, nil, 3 },
    { "item", T["Item Name"], 146, "LEFT", 2 },
    { "level", T["Level"], 35, "CENTER", 6 },
    { "timeleft", T["Time"], 35, "CENTER", 5 },
    { "stack", T["Stack"], 35, "CENTER", 4 },
    { "bid", T["Bid"], 70, "RIGHT", 7 },
    { "buyout", T["Buyout"], 70, "RIGHT", 8 },
    { "price", T["Per Item"], 70, "RIGHT", 9 },
    { "owner", T["Owner"], 100, "RIGHT", 10 },
  }

  local sort = {}
  sort.desc = nil
  sort.prio = 3

  -- TODO: cleanup
  sort.func = function(a, b)
    -- custom prio
    if (a[sort.prio] < b[sort.prio]) then
      if sort.desc then
        return true
      else
        return false
      end
    elseif ( a[sort.prio] > b[sort.prio]) then
      if sort.desc then
        return false
      else
        return true
      end
    else
      -- rarity
      if (a[3] < b[3]) then
        return true
      elseif ( a[3] > b[3]) then
        return false
      else
        -- name
        if (a[2] < b[2]) then
          return true
        elseif ( a[2] > b[2]) then
          return false
        else
          -- price
          if (a[9] < b[9]) then
            return true
          elseif ( a[9] > b[9]) then
            return false
          else
            return false
          end
        end
      end
    end
  end

  local gui = CreateFrame("Frame", "pfAuctionHouse", UIParent)
  gui:RegisterEvent("AUCTION_HOUSE_CLOSED")
  gui:RegisterEvent("AUCTION_HOUSE_SHOW")
  gui:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
  gui:SetScript("OnEvent", function()
    if event == "AUCTION_HOUSE_SHOW" then
      AuctionFrame:UnregisterEvent('AUCTION_HOUSE_SHOW')
      AuctionFrame:SetScript('OnHide', nil)
      AuctionFrame:Hide()
      this:Show()
    elseif event == "AUCTION_HOUSE_CLOSED" then
      this:Hide()
    elseif event == "AUCTION_ITEM_LIST_UPDATE" then
      local batch, max = GetNumAuctionItems("list")
      this.wait = GetTime() + 1

      if this.state == "PREPARE" then
        this.state = "LOAD"
        this.pages = ceil(max / 50)
        this.page  = 1
        print("PREPARE: " .. this.query .. " [Pages: " .. this.pages .. "]") -- DEBUG
      end

      if this.state == "LOAD" then
        gui.progress:SetText("Loading Page " .. this.page .. "/" .. this.pages .. " |cffaaaaaa -")
        print("LOAD PAGE: " .. this.page .. " of " .. this.pages) -- DEBUG
        for i=1, batch do
          local name, texture, count, quality, canUse, level, bid, minIncrement, buyout, bidAmount, highBidder, owner = GetAuctionItemInfo("list", i)
          local timeleft = GetAuctionItemTimeLeft("list", i)
          local link = GetAuctionItemLink("list", i)

          -- request same page again when no owner was transmitted
          if not owner then
            this.page = this.page -1
            this.state = "ASK"
            return
          end

          local price = buyout and (count and buyout/count or buyout) or 0

          cache[(this.page-1)*50+i] = { texture, name, quality, count, timeleft, level, bid, buyout, price, owner, link }
        end

        if this.page >= this.pages then
          this.progress:SetText("Found " .. max .. " Auctions on " .. this.pages .. " Pages.")
          this.rows:Refresh(true)
          this.state = nil
        else
          this.state = "ASK"
        end
      end
    end
  end)

  gui:SetScript("OnUpdate", function()
    if this.wait and this.wait > GetTime() then return end

    if this.state == "ASK" then
      this.state = "LOAD"
      this.page = this.page + 1
      gui.progress:SetText("Loading Page " .. this.page .. "/" .. this.pages .. " |cffaaaaaa |")
      print("ASK PAGE: " .. this.page .. " of " .. this.pages) -- DEBUG

      -- Uh.. wow.. looks like this guy counts pages from 0. consistency ftw.
      QueryAuctionItems(this.query, minLevel, maxLevel, selectedInvtypeIndex, selectedClassIndex, selectedSubclassIndex, this.page - 1, IsUsable, rarity);
    end
  end)

  gui:SetScript("OnShow", function()
    this.rows:Refresh(true)
  end)

  gui:SetScript("OnHide", function()
    StaticPopup_Hide("BUYOUT_AUCTION");
    StaticPopup_Hide("CANCEL_AUCTION");
    HideUIPanel(AuctionDressUpFrame);
    CloseAuctionHouse()
  end)

  gui:SetPoint("CENTER", UIParent, 0, 0)
  gui:SetWidth(800)
  gui:SetHeight(600)

  CreateBackdrop(gui, nil, nil, .7)
  EnableMovable(gui)

  gui.search = CreateTextBox("pfAuctionHouseSearch", gui)
  gui.search:SetPoint("TOPLEFT", 20, -20)
  gui.search:SetWidth(200)
  gui.search:SetHeight(20)
  gui.search:SetTextColor(1,1,1,1)
  gui.search:SetScript("OnEnterPressed", function()
    local name = this:GetText()
    cache = {}

    -- empty all rows
    gui.rows:Refresh(true)

    -- reset page counter
    gui.state = "PREPARE"
    gui.query = name

    -- trigger the initial search to obtain page numbers
    QueryAuctionItems(name, minLevel, maxLevel, selectedInvtypeIndex, selectedClassIndex, selectedSubclassIndex, nil, IsUsable, rarity)

    this:ClearFocus()
  end)

  gui.progress = gui:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  gui.progress:SetJustifyH("LEFT")
  gui.progress:SetPoint("TOPLEFT", gui.search, "BOTTOMLEFT", 2, -2)
  gui.progress:SetPoint("TOPRIGHT", gui.search, "BOTTOMRIGHT", -2, 2)
  gui.progress:SetTextColor(1,1,1,.8)
  gui.progress:SetHeight(20)

  gui.blizzard = CreateFrame("Button", nil, gui)
  gui.blizzard:SetText("Blizzard")
  gui.blizzard:SetWidth(120)
  gui.blizzard:SetHeight(20)
  gui.blizzard:SetPoint("TOPRIGHT", -20, -20)
  gui.blizzard:SetScript("OnClick", function() AuctionFrame:Show() end)
  SkinButton(gui.blizzard)


  gui.filter = CreateFrame("Button", "pfAuctionHouseFilterBackground", gui)
  gui.filter:SetPoint("TOPLEFT", gui, "TOPLEFT", 10, -90)
  gui.filter:SetPoint("BOTTOMRIGHT", gui, "TOPLEFT", 170, -572)
  gui.filter:EnableMouseWheel(1)
  gui.filter:SetScript("OnMouseWheel", function()
    this.scroll = arg1 > 0 and this.scroll - 1 or this.scroll + 1
    this:Refresh(this.class, this.subclass, this.invtype)
  end)
  gui.filter.scroll = 0

  gui.filter:SetScript("OnShow", function()
    this:Refresh()
  end)

  gui.filter.Refresh = function(self, class, subclass, invtype)
    -- trigger search on changed filters
    if self.class ~= class or self.subclass ~= subclass or self.invtype ~= invtype then

    end

    -- save latest search
    self.class = class
    self.subclass = subclass
    self.invtype = invtype


    -- generate viewport
    local view = {}
    for i, name in pairs({GetAuctionItemClasses()}) do
      table.insert(view, { caption = name, class = i, subclass = nil, invtype = nil })

      for j, name in pairs({GetAuctionItemSubClasses(i)}) do
        if class and class == i then -- add to viewport
          table.insert(view, { caption = name, class = i, subclass = j, invtype = nil })

          for k, name in pairs({GetAuctionInvTypes(i, j)}) do
            if subclass and subclass == j and name ~= 1 then
              table.insert(view, { caption = (_G[name] or name), class = i, subclass = j, invtype = k })
            end
          end
        end
      end
    end

    -- adjust scroll state
    if self.scroll < 0 then self.scroll = 0 end

    if self.scroll > max(0, table.getn(view) - 20) then
      self.scroll = max(0, table.getn(view) - 20)
    end

    for button=1,23 do
      local data = view[button + self.scroll]
      if data then
        -- save values into the button
        self[button].class    = data.class
        self[button].subclass = data.subclass
        self[button].invtype  = data.invtype

        -- update indentation based on levels
        if data.invtype then -- 3rd level
          self[button].text:SetPoint("LEFT", 25, 0)
        elseif data.subclass then -- 2nd level
          self[button].text:SetPoint("LEFT", 15, 0)
        else -- 1st level
          self[button].text:SetPoint("LEFT", 5, 0)
        end

        -- highlight selection
        if ( data.invtype and data.invtype == invtype) or
           (not data.invtype and data.subclass and data.subclass == subclass) or
           (not data.invtype and not data.subclass and data.class and data.class == class)
        then
          self[button].text:SetTextColor(.3,1,.8,1)
        else
          self[button].text:SetTextColor(1,1,1,1)
        end

        -- show button and set values
        self[button]:SetText(data.caption)
        self[button]:Show()
      else
        self[button]:Hide()
      end
    end
  end

  CreateBackdrop(gui.filter)

  for i=1,23 do
    gui.filter[i] = CreateFrame("Button", nil, gui.filter)
    gui.filter[i]:SetID(i)
    gui.filter[i]:SetWidth(160)
    gui.filter[i]:SetHeight(20)
    gui.filter[i]:SetPoint("TOPLEFT", 0, -(i-1)*21)
    SkinButton(gui.filter[i])

    -- ugly workaround to get the font aligned to left
    gui.filter[i].text = gui.filter[i]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    gui.filter[i].text:SetPoint("LEFT", 5, 0)
    gui.filter[i].text:SetJustifyH("LEFT")
    gui.filter[i].text:SetTextColor(1,1,1,1)
    gui.filter[i]:SetFontString(gui.filter[i].text)

    gui.filter[i]:SetScript("OnClick", function()
      local class, subclass, invtype = this.class, this.subclass, this.invtype

      -- 3rd level toggle
      if this.invtype and this.invtype == gui.filter.invtype then
        invtype = nil
      end

      -- 2nd level toggle
      if not this.invtype and this.subclass and this.subclass == gui.filter.subclass then
        subclass = nil
      end

      -- 1st level toggle
      if not this.invtype and not this.subclass and this.class and this.class == gui.filter.class then
        class = nil
      end

      gui.filter:Refresh(class, subclass, invtype)
    end)
  end

  gui.rows = CreateFrame("Button", "pfAuctionHouseResultBackground", gui)
  gui.rows:SetPoint("TOPLEFT", gui, "TOPLEFT", 200, -90)
  gui.rows:SetPoint("BOTTOMRIGHT", gui, "TOPRIGHT", -20, -572)
  gui.rows:EnableMouseWheel(1)
  gui.rows:SetScript("OnMouseWheel", function()
    this.scroll = arg1 > 0 and this.scroll - 1 or this.scroll + 1
    this:Refresh()
  end)
  CreateBackdrop(gui.rows)
  gui.rows.scroll = 0

  gui.rows.Refresh = function(self, init)
    if init then
      gui.rows.scroll = 0
      for id, data in pairs(columns) do
        if gui.rows.buttons[data[1]].sort == sort.prio then
          gui.rows.buttons[data[1]]:SetTextColor(.2,1,.8,1)
        else
          gui.rows.buttons[data[1]]:SetTextColor(1,1,1,1)
        end
      end

      table.sort(cache, sort.func)
    end

    if gui.rows.scroll < 0 then gui.rows.scroll = 0 end

    if gui.rows.scroll > max(0, table.getn(cache) - 20) then
      gui.rows.scroll = max(0, table.getn(cache) - 20)
    end

    for i=1,22 do
      local data = cache[i+self.scroll]

      if data and data[1] then
        -- { texture, name, quality, count, timeleft, level, bid, buyout, price, owner, link }
        gui.rows[i].icon:SetTexture(data[1])
        gui.rows[i].item:SetText(data[2])
        gui.rows[i].item:SetTextColor(GetItemQualityColor(data[3]))
        gui.rows[i].stack:SetText(data[4])
        gui.rows[i].timeleft:SetText(BeautifyTimeLeft(data[5]))
        gui.rows[i].level:SetText(data[6])
        gui.rows[i].bid:SetText(BeautifyGoldString(round(data[7],2)))
        gui.rows[i].buyout:SetText(BeautifyGoldString(round(data[8],2)))
        gui.rows[i].price:SetText(BeautifyGoldString(round(data[9],2)))
        gui.rows[i].owner:SetText(data[10])
        gui.rows[i].link = data[11]

        gui.rows[i]:Show()
      else
        gui.rows[i]:Hide()
      end
    end
  end

  local function ColumnSort()
    sort.desc = not sort.desc
    sort.prio = this.sort
    gui.rows.scroll = 0
    gui.rows:Refresh(true)
  end

  gui.rows.buttons = {}
  for id, data in pairs(columns) do
    gui.rows.buttons[data[1]] = CreateFrame("Button", nil, gui.rows)
    gui.rows.buttons[data[1]]:SetText(data[2])
    gui.rows.buttons[data[1]]:SetWidth(data[3] -1)
    gui.rows.buttons[data[1]]:SetHeight(20)
    if id == 1 then
      gui.rows.buttons[data[1]]:SetPoint("TOPLEFT", gui.rows, "TOPLEFT", 0, 0)
    else
      gui.rows.buttons[data[1]]:SetPoint("LEFT", gui.rows.buttons[columns[id-1][1]], "RIGHT", 1, 0)
    end
    gui.rows.buttons[data[1]].sort = data[5]
    gui.rows.buttons[data[1]]:SetScript("OnClick", ColumnSort)
    SkinButton(gui.rows.buttons[data[1]])
  end

  for i=1,22 do -- results
    gui.rows[i] = CreateFrame("Button", "pfAuctionHouseResult"..i, gui.rows)
    gui.rows[i]:SetPoint("TOPLEFT", gui.rows, "TOPLEFT", 0, -22-(i-1)*21)
    gui.rows[i]:SetPoint("BOTTOMRIGHT", gui.rows, "TOPRIGHT", 0, -22-i*21+1)

    gui.rows[i].id = i
    gui.rows[i].color = 0.1 + math.mod(i,2)/50

    gui.rows[i].bg = gui.rows[i]:CreateTexture(nil, "BACKGROUND")
    gui.rows[i].bg:SetTexture(gui.rows[i].color, gui.rows[i].color, gui.rows[i].color)
    gui.rows[i].bg:SetAllPoints(gui.rows[i])

    gui.rows[i].highlight = gui.rows[i]:CreateTexture(nil, "BORDER")
    gui.rows[i].highlight:SetAllPoints(gui.rows[i])

    gui.rows[i].icon = gui.rows[i]:CreateTexture(nil, "ARTWORK")
    gui.rows[i].icon:SetPoint("LEFT", 2, 0)
    gui.rows[i].icon:SetHeight(16)
    gui.rows[i].icon:SetWidth(16)
    gui.rows[i].icon:SetTexture(0,0,0,1)
    gui.rows[i].icon:SetTexCoord(.08, .92, .08, .92)

    for id, data in pairs(columns) do
      if id > 1 then -- skip icon entry
        gui.rows[i][data[1]] = gui.rows[i]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        gui.rows[i][data[1]]:SetWidth(data[3] - 2)
        gui.rows[i][data[1]]:SetTextColor(1,1,1,1)
        gui.rows[i][data[1]]:SetJustifyH(data[4])
        gui.rows[i][data[1]]:SetPoint("LEFT", gui.rows[i][columns[id-1][1]], "RIGHT", 2, 0)
      end
    end

    gui.rows[i]:SetScript("OnEnter", function()
      this.bg:SetTexture(.2,.2,.2,1)
      GameTooltip:SetOwner(this, "ANCHOR_LEFT", 10, -5)
      GameTooltip:SetHyperlink(this.link)
      GameTooltip:Show()
    end)
    gui.rows[i]:SetScript("OnLeave", function()
      this.bg:SetTexture(this.color, this.color, this.color, 1)
      GameTooltip:Hide()
    end)
  end

  gui:Hide()

































  local function pricesort(a,b)
    return a[2] < b[2]
  end

  local function GetPrice(item)
    if not db[item] then return end

    local days = 0
    for _ in pairs(db[item]) do
      days = days + 1
    end

    local avgprice = 0
    local minprice
    for time in pairs(db[item]) do
      table.sort(db[item][time], pricesort)
      local id, data = next(db[item][time])
      local dayprice = data[2]
      if dayprice > 0 then
        avgprice = avgprice + dayprice
      end

      minprice = not minprice and dayprice
      minprice = dayprice < minprice and dayprice or minprice
    end

    avgprice = avgprice / days

    return minprice, avgprice, days
  end

  local tooltip = CreateFrame("Frame", nil, GameTooltip)
  tooltip:SetScript("OnShow", function()
    local text = GameTooltipTextLeft1:IsVisible() and GameTooltipTextLeft1:GetText() or nil
    local min, avg, days = GetPrice(text)
    if min then
      GameTooltip:AddDoubleLine("Min:", CreateGoldString(min))
    end

    if avg then
      GameTooltip:AddDoubleLine("Average |cffffffff[" .. days .. " days]|r:", CreateGoldString(avg))
    end

    GameTooltip:Show()
  end)
end)
