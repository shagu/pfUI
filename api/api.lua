pfUI.api = { }

-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

-- [ strsplit ]
-- Splits a string using a delimiter.
-- 'delimiter'  [string]        characters that will be interpreted as delimiter
--                              characters (bytes) in the string.
-- 'subject'    [string]        String to split.
-- return:      [list]          a list of strings.
function pfUI.api.strsplit(delimiter, subject)
  local delimiter, fields = delimiter or ":", {}
  local pattern = string.format("([^%s]+)", delimiter)
  string.gsub(subject, pattern, function(c) fields[table.getn(fields)+1] = c end)
  return unpack(fields)
end

-- [ UnitInRange ]
-- Returns whether a party/raid member is nearby. It uses spells with a distance of around 40 yards.
-- unit         [string]        A unit to query (string, unitID)
-- return:      [bool]          "1" if in range otherwise "nil"
local RangeCache = {}
function pfUI.api.UnitInRange(unit)
    if not UnitExists(unit) or not UnitIsVisible(unit) then
      return nil
    end

    if CheckInteractDistance(unit, 4) then
      return 1
    else if not pfUI.rangecheck or not pfUI.rangecheck.slot then
      return nil
    else
      -- Extended Range Check
      if not RangeCache[unit] or RangeCache[unit].time + pfUI.rangecheck.interval < GetTime() then
        RangeCache[unit] = {}
        RangeCache[unit].time  = GetTime()

        if not UnitIsUnit("target", unit) then
          pfScanActive = true
          TargetUnit(unit)
        end

        if IsActionInRange(pfUI.rangecheck.slot) == 1 then
          RangeCache[unit].range = 1
        else
          RangeCache[unit].range = nil
        end

        if pfScanActive then
          TargetLastTarget()
          pfScanActive = false
        end
      end

      return RangeCache[unit].range
    end
  end
end

-- [ strvertical ]
-- Creates vertical text using linebreaks. Multibyte char friendly.
-- 'str'        [string]        String to columnize.
-- return:      [string]        the string tranformed to a column.
function pfUI.api.strvertical(str)
    local _, len = string.gsub(str,"[^\128-\193]", "")
    if (len == string.len(str)) then
      return string.gsub(str, "(.)", "%1\n")
    else
      return string.gsub(str,"([%z\1-\127\194-\244][\128-\191]*)", "%1\n")
    end
end

-- [ round ]
-- Rounds a float number into specified places after comma.
-- 'input'      [float]         the number that should be rounded.
-- 'places'     [int]           amount of places after the comma.
-- returns:     [float]         rounded number.
function pfUI.api.round(input, places)
  if not places then places = 0 end
  if type(input) == "number" and type(places) == "number" then
    local pow = 1
    for i = 1, places do pow = pow * 10 end
    return floor(input * pow + 0.5) / pow
  end
end

-- [ clamp ]
-- Clamps a number between given range.
-- 'x'          [number]        the number that should be clamped.
-- 'min'        [number]        minimum value.
-- 'max'        [number]        maximum value.
-- returns:     [number]        clamped value: 'x', 'min' or 'max' value itself.
function pfUI.api.clamp(x, min, max)
  if type(x) == "number" and type(min) == "number" and type(max) == "number" then
    return x < min and min or x > max and max or x
  else
    return x
  end
end

-- [ SanitizePattern ]
-- Sanitizes and convert patterns into gfind compatible ones.
-- 'pattern'    [string]         unformatted pattern
-- returns:     [string]         simplified gfind compatible pattern
function pfUI.api.SanitizePattern(pattern)
  -- escape brackets
  pattern = gsub(pattern, "%(", "%%(")
  pattern = gsub(pattern, "%)", "%%)")

  -- remove bad capture indexes
  pattern = gsub(pattern, "%d%$s","s") -- %1$s to %s
  pattern = gsub(pattern, "%d%$d","d") -- %1$d to %d
  pattern = gsub(pattern, "%ds","s") -- %2s to %s

  -- add capture to all findings
  pattern = gsub(pattern, "%%s", "(.+)")
  pattern = gsub(pattern, "%%d", "(%%d+)")

  return pattern
end

-- [ GetItemLinkByName ]
-- Returns an itemLink for the given itemname
-- 'name'       [string]         name of the item
-- returns:     [string]         entire itemLink for the given item
function pfUI.api.GetItemLinkByName(name)
  for itemID = 1, 25818 do
    local itemName, hyperLink, itemQuality = GetItemInfo(itemID)
    if (itemName and itemName == name) then
      local _, _, _, hex = GetItemQualityColor(tonumber(itemQuality))
      return hex.. "|H"..hyperLink.."|h["..itemName.."]|h|r"
    end
  end
end

-- [ GetItemCount ]
-- Returns information about how many of a given item the player has.
-- 'itemName'   [string]         name of the item
-- returns:     [int]            the number of the given item
function pfUI.api.GetItemCount(itemName)
  local count = 0
  for bag = 4, 0, -1 do
    for slot = 1, GetContainerNumSlots(bag) do
      local _, itemCount = GetContainerItemInfo(bag, slot);
      if itemCount then
        local itemLink = GetContainerItemLink(bag,slot)
        local _, _, itemParse = strfind(itemLink, "(%d+):")
        local queryName, _, _, _, _, _ = GetItemInfo(itemParse)
        if queryName and queryName ~= "" then
          if queryName == itemName then
            count = count + itemCount;
          end
        end
      end
    end
  end

  return count
end

-- [ GetBagFamily ]
-- Returns information about the type of a bag such as Soul Bags or Quivers.
-- Available bagtypes are "BAG", "KEYRING", "SOULBAG", "QUIVER" and "SPECIAL"
-- 'bag'        [int]        the bag id
-- returns:     [string]     the type of the bag, e.g "QUIVER"
function pfUI.api.GetBagFamily(bag)
  if bag == -2 then return "KEYRING" end
  if bag == 0 then return "BAG" end

  local _, _, id = strfind(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)) or "", "item:(%d+)")
  if id then
    local _, _, _, _, itemType, subType = GetItemInfo(id)
    local bagsubtype = L["bagtypes"][subType]

    if bagsubtype == "DEFAULT" then return "BAG" end
    if bagsubtype == "SOULBAG" then return "SOULBAG" end
    if bagsubtype == "QUIVER" then return "QUIVER" end
    if bagsubtype == nil then return "SPECIAL" end
  end

  return nil
end

-- [ Abbreviate ]
-- Abbreviates a number from 1234 to 1.23k
-- 'number'     [number]           the number that should be abbreviated
-- 'returns:    [string]           the abbreviated value
function pfUI.api.Abbreviate(number)
  if pfUI_config.unitframes.abbrevnum == "1" then
    if number > 1000000 then
      return pfUI.api.round(number/1000000,2) .. "m"
    elseif number > 1000 then
      return pfUI.api.round(number/1000,2) .. "k"
    end
  end

  return number
end

-- [ SendChatMessageWide ]
-- Sends a message to widest audience the player can broadcast to
-- 'msg'        [string]          the message to send
function pfUI.api.SendChatMessageWide(msg)
  local channel = "SAY"
  if UnitInRaid("player") then
    channel = "RAID"
  elseif UnitExists("party1") then
    channel = "PARTY"
  end
  SendChatMessage(msg,channel)
end

-- [ GroupInfoByName ]
-- Gets the unit id by name
-- 'name'       [string]          party or raid member
-- 'group'      [string]          "raid" or "party"
-- returns:     [table]           {name='name',unitId='unitId',Id=Id,lclass='lclass',class='class'}
do -- create a scope so we don't have to worry about upvalue collisions
  local party, raid, unitinfo = {}, {}, {}
  party[0] = "player" -- fake unit
  for i=1, MAX_PARTY_MEMBERS do
    party[i] = "party"..i
  end
  for i=1, MAX_RAID_MEMBERS do
    raid[i] = "raid"..i
  end
  function pfUI.api.GroupInfoByName(name,group)
    unitinfo = pfUI.api.wipe(unitinfo)
    if group == "party" then
      for i=0, MAX_PARTY_MEMBERS do
        local unitName = UnitName(party[i])
        if unitName == name then
          local lclass,class = UnitClass(party[i])
          if not (lclass and class) then
            lclass,class = _G.UNKNOWN, "UNKNOWN"
          end
          unitinfo.name,unitinfo.unitId,unitinfo.Id,unitinfo.lclass,unitinfo.class =
            unitName,party[i],i,lclass,class
          return unitinfo
        end
      end
    elseif group == "raid" then
      for i=1, MAX_RAID_MEMBERS do
        local unitName = UnitName(raid[i])
        if unitName == name then
          local lclass,class = UnitClass(raid[i])
          if not (lclass and class) then
            lclass,class = _G.UNKNOWN, "UNKNOWN"
          end
          unitinfo.name,unitinfo.unitId,unitinfo.Id,unitinfo.lclass,unitinfo.class =
            unitName,raid[i],i,lclass,class
          return unitinfo
        end
      end
    end
    -- fallback for GetMasterLootCandidate not updating immediately for leavers
    unitinfo.lclass,unitinfo.class = _G.UNKNOWN, "UNKNOWN"
    return unitinfo
  end
end

-- [ hooksecurefunc ]
-- Hooks a global function and injects custom code
-- 'name'       [string]           name of the function that should be hooked
-- 'func'       [function]         function containing the custom code
-- 'append'     [bool]             optional variable, used to append custom
--                                 code instead of prepending it
function pfUI.api.hooksecurefunc(name, func, append)
  if not _G[name] then return end

  pfUI.hooks[tostring(func)] = {}
  pfUI.hooks[tostring(func)]["old"] = _G[name]
  pfUI.hooks[tostring(func)]["new"] = func

  if append then
    pfUI.hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      pfUI.hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      pfUI.hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    end
  else
    pfUI.hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      pfUI.hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      pfUI.hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    end
  end

  _G[name] = pfUI.hooks[tostring(func)]["function"]
end

-- [ QueueFunction ]
-- Add functions to a FIFO queue for execution after a short delay.
-- '...'        [vararg]        function, [arguments]
local timer
function pfUI.api.QueueFunction(...)
  if not (timer) then
    timer = CreateFrame("frame")
    timer.queue = {}
    timer.interval = TOOLTIP_UPDATE_TIME
    timer.DeQueue = function()
      local item = table.remove(timer.queue,1)
      if (item) then
        item[1](unpack(item[2]))
      end
      if table.getn(timer.queue) == 0 then
        timer:Hide() -- no need to run the OnUpdate when the queue is empty
      end
    end
    timer:SetScript("OnUpdate",function()
      this.sinceLast = (this.sinceLast or 0) + arg1
      while (this.sinceLast > this.interval) do
        this.DeQueue()
        this.sinceLast = this.sinceLast - this.interval
      end
    end)
  end
  assert(type(arg[1])=="function","QueueFunction: arg1 is not a function")
  local func = arg[1]
  local args
  for i=2,arg.n do
    args = args or {}
    table.insert(args,arg[i])
  end
  table.insert(timer.queue,{func,args})
  timer:Show() -- start the OnUpdate
end

-- [ Create Gold String ]
-- Transforms a amount of copper into a fully fledged gold string
-- 'money'      [int]           the amount of coppy (GetMoney())
-- return:      [string]        a colorized string which is split into
--                              gold,silver and copper values.
function pfUI.api.CreateGoldString(money)
  local gold = floor(money/ 100 / 100)
  local silver = floor(mod((money/100),100))
  local copper = floor(mod(money,100))

  local string = ""
  if gold > 0 then string = string .. "|cffffffff" .. gold .. "|cffffd700g" end
  if silver > 0 then string = string .. "|cffffffff " .. silver .. "|cffc7c7cfs" end
  string = string .. "|cffffffff " .. copper .. "|cffeda55fc"

  return string
end

-- [ Enable Movable ]
-- Set all necessary functions to make a already existing frame movable.
-- 'name'       [frame/string]  Name of the Frame that should be movable
-- 'addon'      [string]        Addon that must be loaded before being able to access the frame
-- 'blacklist'  [table]         A list of frames that should be deactivated for mouse usage
function pfUI.api.EnableMovable(name, addon, blacklist)
  if addon then
    local scan = CreateFrame("Frame")
    scan:RegisterEvent("ADDON_LOADED")
    scan:SetScript("OnEvent", function()
      if arg1 == addon then
        local frame = _G[name]

        if blacklist then
          for _, disable in pairs(blacklist) do
            _G[disable]:EnableMouse(false)
          end
        end

        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:SetScript("OnMouseDown",function()
          this:StartMoving()
        end)

        frame:SetScript("OnMouseUp",function()
          this:StopMovingOrSizing()
        end)
        this:UnregisterAllEvents()
      end
    end)
  else
    if blacklist then
      for _, disable in pairs(blacklist) do
        _G[disable]:EnableMouse(false)
      end
    end

    local frame = name
    if type(name) == "string" then frame = _G[name] end
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown",function()
      this:StartMoving()
    end)

    frame:SetScript("OnMouseUp",function()
      this:StopMovingOrSizing()
    end)
  end
end

-- [ Copy Table ]
-- By default a table assignment only will be a reference instead of a copy.
-- This is used to create a replicate of the actual table.
-- 'src'        [table]        the table that should be copied.
-- return:      [table]        the replicated table.
function pfUI.api.CopyTable(src)
  local lookup_table = {}
  local function _copy(src)
    if type(src) ~= "table" then
      return src
    elseif lookup_table[src] then
      return lookup_table[src]
    end
    local new_table = {}
    lookup_table[src] = new_table
    for index, value in pairs(src) do
      new_table[_copy(index)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(src))
  end
  return _copy(src)
end

-- [ Wipe Table ]
-- Empties a table and returns it
-- 'src'      [table]         the table that should be emptied.
-- return:    [table]         the emptied table.
function pfUI.api.wipe(src)
  -- notes: table.insert, table.remove will have undefined behavior
  -- when used on tables emptied this way because Lua removes nil
  -- entries from tables after an indeterminate time.
  -- Instead of table.insert(t,v) use t[table.getn(t)+1]=v as table.getn collapses nil entries.
  -- There are no issues with hash tables, t[k]=v where k is not a number behaves as expected.
  local mt = getmetatable(src) or {}
  if mt.__mode == nil or mt.__mode ~= "kv" then
    mt.__mode = "kv"
    src=setmetatable(src,mt)
  end
  for k in pairs(src) do
    src[k] = nil
  end
  table.setn(src,0)
  return src
end

-- [ Update Movable ]
-- Loads and update the configured position of the specified frame.
-- It also creates an entry in the movables table.
-- 'frame'      [frame]        the frame that should be updated.
function pfUI.api.UpdateMovable(frame)
  local name = frame:GetName()

  if pfUI_config.global.offscreen == "0" then
    frame:SetClampedToScreen(true)
  end

  if not pfUI.movables[name] then
    pfUI.movables[name] = true
    table.insert(pfUI.movables, name)
  end

  if pfUI_config["position"][frame:GetName()] then
    if pfUI_config["position"][frame:GetName()]["scale"] then
      frame:SetScale(pfUI_config["position"][frame:GetName()].scale)
    end

    if pfUI_config["position"][frame:GetName()]["xpos"] then
      frame:ClearAllPoints()
      frame:SetPoint("TOPLEFT", pfUI_config["position"][frame:GetName()].xpos, pfUI_config["position"][frame:GetName()].ypos)
    end
  end
end


-- [ SetAutoPoint ]
-- Automatically places the frame according to screen position of the parent.
-- 'frame'      [frame]        the frame that should be moved.
-- 'parent'     [frame]        the frame's anchor point
-- 'spacing'    [number]       the padding that should be used between the
--                             frame and its parent frame
function pfUI.api.SetAutoPoint(frame, parent, spacing)
  --[[

          a     b       max
    +-----------------+
    |  1  |  2  |  3  |
    |-----+-----+-----| c
    |  4  |  5  |  6  |
    |-----+-----+-----| d
    |  7  |  8  |  9  |
    +-----------------+
  0

  ]]--

  local a = GetScreenWidth() / 3
  local b = GetScreenWidth() / 3 * 2

  local c = GetScreenHeight() / 3 * 2
  local d = GetScreenHeight() / 3

  local x, y = parent:GetCenter()

  local off = spacing or 0

  frame:ClearAllPoints()

  if x < a and y > c then
    -- TOPLEFT
    frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -off)
  elseif x > a and x < b and y > c then
    -- TOP
    frame:SetPoint("TOP", parent, "BOTTOM", 0, -off)
  elseif x > b and y > c then
    -- TOPRIGHT
    frame:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, -off)

  elseif x < a and y > d and y < c then
    -- LEFT
    frame:SetPoint("LEFT", parent, "RIGHT", off, 0)

  elseif x > a and x < b and y > d and y < c then
    -- CENTER
    frame:SetPoint("BOTTOM", parent, "TOP", 0, off)

  elseif x > b and y > d and y < c then
    -- RIGHT
    frame:SetPoint("RIGHT", parent, "LEFT", -off, 0)

  elseif x < a and y < d then
    -- BOTTOMLEFT
    frame:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, off)

  elseif x > a and x < b and y < d then
    -- BOTTOM
    frame:SetPoint("BOTTOM", parent, "TOP", 0, off)

  elseif x > b and y < d then
    -- BOTTOMRIGHT
    frame:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, off)
  end
end

-- [ Create Backdrop ]
-- Creates a pfUI compatible frame as backdrop element
-- 'f'          [frame]         the frame which should get a backdrop.
-- 'inset'      [int]           backdrop inset, defaults to border size.
-- 'legacy'     [bool]          use legacy backdrop instead of creating frames.
-- 'transp'     [bool]          force default transparency of 0.8.
function pfUI.api.CreateBackdrop(f, inset, legacy, transp, backdropSetting)
  -- exit if now frame was given
  if not f then return end

  -- use default inset if nothing is given
  local border = inset
  if not border then
    border = tonumber(pfUI_config.appearance.border.default)
  end

  -- bg and edge colors
  if not pfUI.cache.br then
    local br, bg, bb, ba = pfUI.api.strsplit(",", pfUI_config.appearance.border.background)
    local er, eg, eb, ea = pfUI.api.strsplit(",", pfUI_config.appearance.border.color)
    pfUI.cache.br, pfUI.cache.bg, pfUI.cache.bb, pfUI.cache.ba = br, bg, bb, ba
    pfUI.cache.er, pfUI.cache.eg, pfUI.cache.eb, pfUI.cache.ea = er, eg, eb, ea
  end

  local br, bg, bb, ba =  pfUI.cache.br, pfUI.cache.bg, pfUI.cache.bb, pfUI.cache.ba
  local er, eg, eb, ea = pfUI.cache.er, pfUI.cache.eg, pfUI.cache.eb, pfUI.cache.ea
  if transp then ba = transp end

  -- use legacy backdrop handling
  if legacy then
    local backdrop = pfUI.backdrop
    if backdropSetting then backdrop = backdropSetting end
    f:SetBackdrop(backdrop)
    f:SetBackdropColor(br, bg, bb, ba)
    f:SetBackdropBorderColor(er, eg, eb , ea)
    return
  end

  -- increase clickable area if available
  if f.SetHitRectInsets then
    f:SetHitRectInsets(-border,-border,-border,-border)
  end

  -- use new backdrop behaviour
  if not f.backdrop then
    f:SetBackdrop(nil)

    local backdrop = pfUI.backdrop
    local b = CreateFrame("Frame", nil, f)
    if tonumber(border) > 1 then
      local border = tonumber(border) - 1
      backdrop.insets = {left = -1, right = -1, top = -1, bottom = -1}
      b:SetPoint("TOPLEFT", f, "TOPLEFT", -border, border)
      b:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", border, -border)
    else
      local border = tonumber(border)
      backdrop.insets = {left = 0, right = 0, top = 0, bottom = 0}
      b:SetPoint("TOPLEFT", f, "TOPLEFT", -border, border)
      b:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", border, -border)
    end

    local level = f:GetFrameLevel()
    if level < 1 then
      b:SetFrameLevel(level)
    else
      b:SetFrameLevel(level - 1)
    end

    f.backdrop = b
    b:SetBackdrop(backdrop)
  end

  local b = f.backdrop
  b:SetBackdropColor(br, bg, bb, ba)
  b:SetBackdropBorderColor(er, eg, eb , ea)
end

-- [ Bar Layout Options ] --
-- 'barsize'  size of bar in number of buttons
-- returns:   array of options as strings for pfUI.gui.bar
function pfUI.api.BarLayoutOptions(barsize)
  assert(barsize > 0 and barsize <= NUM_ACTIONBAR_BUTTONS,"BarLayoutOptions: barsize "..tostring(barsize).." is invalid")
  local options = {}
  for i,layout in ipairs(pfGridmath[barsize]) do
    options[i] = string.format("%d x %d",layout[1],layout[2])
  end
  return options
end

-- [ Bar Layout Formfactor ] --
-- 'option'  string option as used in pfUI_config.bars[bar].option
-- returns:  integer formfactor
local formfactors = {} -- we'll use memoization so we only compute once, then lookup.
setmetatable(formfactors, {__mode = "v"}) -- weak table so values not referenced are collected on next gc
function pfUI.api.BarLayoutFormfactor(option)
  if formfactors[option] then
    return formfactors[option]
  else
    for barsize,_ in ipairs(pfGridmath) do
      local options = pfUI.api.BarLayoutOptions(barsize)
      for i,opt in ipairs(options) do
        if opt == option then
          formfactors[option] = i
          return formfactors[option]
        end
      end
    end
  end
end

-- [ Bar Layout Size ] --
-- 'bar'  frame reference,
-- 'barsize'  integer number of buttons,
-- 'formfactor'  string formfactor in cols x rows
function pfUI.api.BarLayoutSize(bar,barsize,formfactor,iconsize,bordersize)
  assert(barsize > 0 and barsize <= NUM_ACTIONBAR_BUTTONS,"BarLayoutSize: barsize "..tostring(barsize).." is invalid")
  local formfactor = pfUI.api.BarLayoutFormfactor(formfactor)
  local cols, rows = unpack(pfGridmath[barsize][formfactor])
  local width = (iconsize + bordersize*3) * cols - bordersize
  local height = (iconsize + bordersize*3) * rows - bordersize
  bar._size = {width,height}
  return bar._size
end

-- [ Bar Button Anchor ] --
-- 'button'  frame reference
-- 'basename'  name of button frame without index
-- 'buttonindex'  index number of button on bar
-- 'formfactor'  string formfactor in cols x rows
function pfUI.api.BarButtonAnchor(button,basename,buttonindex,barsize,formfactor,iconsize,bordersize)
  assert(barsize > 0 and barsize <= NUM_ACTIONBAR_BUTTONS,"BarButtonAnchor: barsize "..tostring(barsize).." is invalid")
  local formfactor = pfUI.api.BarLayoutFormfactor(formfactor)
  local parent = button:GetParent()
  local cols, rows = unpack(pfGridmath[barsize][formfactor])
  if buttonindex == 1 then
    button._anchor = {"TOPLEFT", parent, "TOPLEFT", bordersize, -bordersize}
  else
    local col = buttonindex-((math.ceil(buttonindex/cols)-1)*cols)
    button._anchor = col==1 and {"TOP",getglobal(basename..(buttonindex-cols)),"BOTTOM",0,-(bordersize*3)} or {"LEFT",getglobal(basename..(buttonindex-1)),"RIGHT",(bordersize*3),0}
  end
  return button._anchor
end

-- [ Create Autohide ] --
-- 'frame'  the frame that should be hidden
function pfUI.api.CreateAutohide(frame)
  if not frame then return end
  frame.hover = CreateFrame("Frame", frame:GetName() .. "Autohide", frame)
  frame.hover:SetParent(frame)
  frame.hover:SetAllPoints(frame)
  frame.hover.parent = frame

  frame.hover:RegisterEvent("PLAYER_LEAVING_WORLD")
  frame.hover:SetScript("OnEvent", function()
    this:Hide()
  end)

  frame.hover:SetScript("OnUpdate", function()
    if MouseIsOver(this, 10, -10, -10, 10) then
      this.activeTo = GetTime() + tonumber(pfUI_config.bars.hide_time)
      this.parent:SetAlpha(1)
    elseif this.activeTo then
      if this.activeTo < GetTime() and this.parent:GetAlpha() > 0 then
        this.parent:SetAlpha(this.parent:GetAlpha() - 0.1)
      end
    else
      this.activeTo = GetTime() + tonumber(pfUI_config.bars.hide_time)
    end
  end)
end
