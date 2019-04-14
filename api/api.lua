pfUI.api = { }

-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

-- Client API shortcuts
gfind = string.gmatch or string.gfind
mod = math.mod or mod

-- [ strsplit ]
-- Splits a string using a delimiter.
-- 'delimiter'  [string]        characters that will be interpreted as delimiter
--                              characters (bytes) in the string.
-- 'subject'    [string]        String to split.
-- return:      [list]          a list of strings.
function pfUI.api.strsplit(delimiter, subject)
  if not subject then return nil end
  local delimiter, fields = delimiter or ":", {}
  local pattern = string.format("([^%s]+)", delimiter)
  string.gsub(subject, pattern, function(c) fields[table.getn(fields)+1] = c end)
  return unpack(fields)
end

-- [ checkversion ]
-- Compares a given version (major,minor,fix) and compares it to the current
-- 'chkmajor'   [number]        the major number to check
-- 'chkminor'   [number]        the minor number to check
-- 'chkfix'     [number]        the fix number to check
--
-- return:      [boolean]       true when the current version is smaller or equal
--                              to the given value, otherwise returns nil.
local major, minor, fix = nil, nil, nil
function pfUI.api.checkversion(chkmajor, chkminor, chkfix)
  if not major and not minor and not fix then
    -- load and convert current version
    major, minor, fix = pfUI.api.strsplit(".", tostring(pfUI_config.version))
    major, minor, fix = tonumber(major) or 0, tonumber(minor) or 0, tonumber(fix) or 0
  end

  local chkversion = chkmajor + chkminor/100 + chkfix/10000
  local curversion = major + minor/100 + fix/10000
  return curversion <= chkversion and true or nil
end

-- [ UnitInRange ]
-- Returns whether a party/raid member is nearby.
-- It takes care of the rangecheck module if existing.
-- unit         [string]        A unit to query (string, unitID)
-- return:      [bool]          "1" if in range otherwise "nil"
local RangeCache = {}
function pfUI.api.UnitInRange(unit)
  if not UnitExists(unit) or not UnitIsVisible(unit) then
    return nil
  elseif CheckInteractDistance(unit, 4) then
    return 1
  else
    return librange:UnitInSpellRange(unit)
  end
end

-- [ UnitHasBuff ]
-- Returns whether a unit has the given buff or not.
-- unit         [string]        A unit to query (string, unitID)
-- buff         [string]        The texture of the buff.
-- return:      [bool]          true if unit has buff otherwise "nil"
function pfUI.api.UnitHasBuff(unit, buff)
  local hasbuff = nil
  for i=1,32 do
    if UnitBuff(unit, i) == buff then
      hasbuff = true
      break
    end
  end

  return hasbuff
end

-- [[ GetUnitColor ]]
-- Returns an escape string for the unit aswell as the RGB values
-- unit         [string]        the unitstring
-- return:      [table]         string, r, g, b
function pfUI.api.GetUnitColor(unitstr)
  local _, class = UnitClass(unitstr)

  local r, g, b = .8, .8, .8
  if RAID_CLASS_COLORS[class] then
    r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
  end

  return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255), r, g, b
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

-- [ modf ]
-- Returns integral and fractional part of a number.
-- 'f'          [float]        the number to breakdown.
-- returns:     [int],[float]  whole and fractional part.
function pfUI.api.modf(f)
  if modf then return modf(f) end
  if f > 0 then
    return math.floor(f), mod(f,1)
  end
  return math.ceil(f), mod(f,1)
end

-- [ GetCaptures ]
-- Returns the indexes of a given regex pattern
-- 'pat'        [string]         unformatted pattern
-- returns:     [numbers]        capture indexes
local capture_cache = {}
function pfUI.api.GetCaptures(pat)
  local r = capture_cache
  if not r[pat] then
    for a, b, c, d, e in string.gfind(gsub(pat, "%((.+)%)", "%1"), gsub(pat, "%d%$", "%%(.-)$")) do
      r[pat] = { a, b, c, d, e}
    end
  end

  if not r[pat] then return nil, nil, nil, nil end
  return r[pat][1], r[pat][2], r[pat][3], r[pat][4], r[pat][5]
end

-- [ SanitizePattern ]
-- Sanitizes and convert patterns into gfind compatible ones.
-- 'pattern'    [string]         unformatted pattern
-- returns:     [string]         simplified gfind compatible pattern
local sanitize_cache = {}
function pfUI.api.SanitizePattern(pattern, dbg)
  if not sanitize_cache[pattern] then
    local ret = pattern
    -- escape magic characters
    ret = gsub(ret, "([%+%-%*%(%)%?%[%]%^])", "%%%1")
    -- remove capture indexes
    ret = gsub(ret, "%d%$","")
    -- catch all characters
    ret = gsub(ret, "(%%%a)","%(%1+%)")
    -- convert all %s to .+
    ret = gsub(ret, "%%s%+",".+")
    -- set priority to numbers over strings
    ret = gsub(ret, "%(.%+%)%(%%d%+%)","%(.-%)%(%%d%+%)")
    -- cache it
    sanitize_cache[pattern] = ret
  end

  return sanitize_cache[pattern]
end

-- [ cmatch ]
-- Same as string.match but aware of capture indexes (up to 5)
-- 'str'        [string]         input string that should be matched
-- 'pat'        [string]         unformatted pattern
-- returns:     [strings]        matched string in capture order
function pfUI.api.cmatch(str, pat)
  -- read capture indexes
  local a,b,c,d,e = GetCaptures(pat)
  local _, _, va, vb, vc, vd, ve = string.find(str, pfUI.api.SanitizePattern(pat))

  -- put entries into the proper return values
  local ra, rb, rc, rd, re
  ra = e == "1" and ve or d == "1" and vd or c == "1" and vc or b == "1" and vb or va
  rb = e == "2" and ve or d == "2" and vd or c == "2" and vc or a == "2" and va or vb
  rc = e == "3" and ve or d == "3" and vd or a == "3" and va or b == "3" and vb or vc
  rd = e == "4" and ve or a == "4" and va or c == "4" and vc or b == "4" and vb or vd
  re = a == "5" and va or d == "5" and vd or c == "5" and vc or b == "5" and vb or ve

  return ra, rb, rc, rd, re
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
  if bag == 0 then return "BAG" end -- backpack
  if bag == -1 then return "BAG" end -- bank

  local _, _, id = strfind(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)) or "", "item:(%d+)")
  if id then
    local _, _, _, _, itemType, subType = GetItemInfo(id)
    local bagsubtype = L["bagtypes"][subType]

    if bagsubtype == "DEFAULT" then return "BAG" end
    if bagsubtype == "SOULBAG" then return "SOULBAG" end
    if bagsubtype == "QUIVER" then return "QUIVER" end
    if bagsubtype == nil and GetContainerNumFreeSlots then
      -- handle new bag classes introduced in TBC
      local _, subtype = GetContainerNumFreeSlots(bag)
      if subtype and subtype > 0 then
        return "SPECIAL"
      else
        return "BAG"
      end
    elseif bagsubtype == nil then
      return "SPECIAL"
    end
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
    if ( IsRaidLeader() or IsRaidOfficer() ) then
      channel = "RAID_WARNING"
    else
    channel = "RAID"
    end
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

-- [ HookScript ]
-- Securely post-hooks a script handler.
-- 'f'          [frame]             the frame which needs a hook
-- 'script'     [string]            the handler to hook
-- 'func'       [function]          the function that should be added
function HookScript(f, script, func)
  local prev = f:GetScript(script)
  f:SetScript(script, function()
    if prev then prev() end
    func()
  end)
end

-- [ HookAddonOrVariable ]
-- Sets a function to be called automatically once an addon gets loaded
-- 'addon'      [string]            addon or variable name
-- 'func'       [function]          function that should run
function pfUI.api.HookAddonOrVariable(addon, func)
  local lurker = CreateFrame("Frame", nil)
  lurker.func = func
  lurker:RegisterEvent("ADDON_LOADED")
  lurker:RegisterEvent("VARIABLES_LOADED")
  lurker:RegisterEvent("PLAYER_ENTERING_WORLD")
  lurker:SetScript("OnEvent",function()
    -- only run when config is available
    if event == "ADDON_LOADED" and not this.foundConfig then
      return
    elseif event == "VARIABLES_LOADED" then
      this.foundConfig = true
    end

    if IsAddOnLoaded(addon) or _G[addon] then
      this:func()
      this:UnregisterAllEvents()
    end
  end)
end

-- [ QueueFunction ]
-- Add functions to a FIFO queue for execution after a short delay.
-- '...'        [vararg]        function, [arguments]
local timer
function pfUI.api.QueueFunction(a1,a2,a3,a4,a5,a6,a7,a8,a9)
  if not timer then
    timer = CreateFrame("Frame")
    timer.queue = {}
    timer.interval = TOOLTIP_UPDATE_TIME
    timer.DeQueue = function()
      local item = table.remove(timer.queue,1)
      if item then
        item[1](item[2],item[3],item[4],item[5],item[6],item[7],item[8],item[9])
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
  table.insert(timer.queue,{a1,a2,a3,a4,a5,a6,a7,a8,a9})
  timer:Show() -- start the OnUpdate
end

-- [ Create Gold String ]
-- Transforms a amount of copper into a fully fledged gold string
-- 'money'      [int]           the amount of coppy (GetMoney())
-- return:      [string]        a colorized string which is split into
--                              gold,silver and copper values.
function pfUI.api.CreateGoldString(money)
  if type(money) ~= "number" then return "-" end

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
  return src
end

-- [ Load Movable ]
-- Loads the positions of a Frame.
-- 'frame'      [frame]        the frame that should be positioned.
-- 'init'       [bool]         treats the current position as initial data
function pfUI.api.LoadMovable(frame, init)
  -- update position data
  if not frame.posdata or init then
    frame.posdata = { scale = frame:GetScale(), pos = {} }
    for i=1,frame:GetNumPoints() do
      frame.posdata.pos[i] = { frame:GetPoint(i) }
    end
  end

  if pfUI_config["position"][frame:GetName()] then
    if pfUI_config["position"][frame:GetName()]["scale"] then
      frame:SetScale(pfUI_config["position"][frame:GetName()].scale)
    end

    if pfUI_config["position"][frame:GetName()]["xpos"] then
      local anchor = pfUI_config["position"][frame:GetName()]["anchor"] or "TOPLEFT"
      frame:ClearAllPoints()
      frame:SetPoint(anchor, pfUI_config["position"][frame:GetName()].xpos, pfUI_config["position"][frame:GetName()].ypos)
    end
  elseif frame.posdata and frame.posdata.pos[1] then
    frame:ClearAllPoints()
    frame:SetScale(frame.posdata.scale)

    for id, point in pairs(frame.posdata.pos) do
      frame:SetPoint(unpack(point))
    end
  end
end

-- [ Save Movable ]
-- Save the positions of a Frame.
-- 'frame'      [frame]        the frame that should be saved.
function pfUI.api.SaveMovable(frame)
  local anchor, _, _, xpos, ypos = frame:GetPoint()
  if not C.position[frame:GetName()] then
    C.position[frame:GetName()] = {}
  end

  C.position[frame:GetName()]["xpos"] = round(xpos)
  C.position[frame:GetName()]["ypos"] = round(ypos)
  C.position[frame:GetName()]["anchor"] = anchor
end

-- [ Update Movable ]
-- Loads and update the configured position of the specified frame.
-- It also creates an entry in the movables table.
-- 'frame'      [frame]        the frame that should be updated.
-- 'init'       [bool]         treats the current position as initial data
function pfUI.api.UpdateMovable(frame, init)
  local name = frame:GetName()

  if pfUI_config.global.offscreen == "0" then
    frame:SetClampedToScreen(true)
  end

  if not pfUI.movables[name] then
    pfUI.movables[name] = frame
  end

  LoadMovable(frame, init)
end

-- [ Remove Movable ]
-- Removes a Frame from the movable list.
-- 'frame'      [frame]        the frame that should be removed.
function pfUI.api.RemoveMovable(frame)
  local name = frame:GetName()
  pfUI.movables[name] = nil
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

  if not x or not y then return end

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

-- [ GetDefaultColors ]
-- Queries the pfUI setting strings and extract its color codes
-- returns r,g,b,a
local color_cache = {}
function pfUI.api.GetStringColor(colorstr)
  if not color_cache[colorstr] then
    local r, g, b, a = pfUI.api.strsplit(",", colorstr)
    color_cache[colorstr] = { r, g, b, a }
  end
  return unpack(color_cache[colorstr])
end

-- [ Create Backdrop ]
-- Creates a pfUI compatible frame as backdrop element
-- 'f'          [frame]         the frame which should get a backdrop.
-- 'inset'      [int]           backdrop inset, defaults to border size.
-- 'legacy'     [bool]          use legacy backdrop instead of creating frames.
-- 'transp'     [number]        set default transparency
function pfUI.api.CreateBackdrop(f, inset, legacy, transp, backdropSetting)
  -- exit if now frame was given
  if not f then return end

  -- use default inset if nothing is given
  local border = inset
  if not border then
    border = tonumber(pfUI_config.appearance.border.default)
  end

  local br, bg, bb, ba = pfUI.api.GetStringColor(pfUI_config.appearance.border.background)
  local er, eg, eb, ea = pfUI.api.GetStringColor(pfUI_config.appearance.border.color)

  if transp and transp < tonumber(ba) then ba = transp end

  -- use legacy backdrop handling
  if legacy then
    local backdrop = border == 1 and pfUI.backdrop_thin or pfUI.backdrop
    if backdropSetting then f:SetBackdrop(backdropSetting) end
    f:SetBackdrop(backdrop)
    f:SetBackdropColor(br, bg, bb, ba)
    f:SetBackdropBorderColor(er, eg, eb , ea)
  else
    -- increase clickable area if available
    if f.SetHitRectInsets then
      f:SetHitRectInsets(-border,-border,-border,-border)
    end

    -- use new backdrop behaviour
    if not f.backdrop then
      if f:GetBackdrop() then f:SetBackdrop(nil) end

      local b = CreateFrame("Frame", nil, f)
      if tonumber(border) > 1 then
        local border = tonumber(border) - 1
        b:SetPoint("TOPLEFT", f, "TOPLEFT", -border, border)
        b:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", border, -border)
        b:SetBackdrop(pfUI.backdrop)
      else
        local border = tonumber(border)
        b:SetPoint("TOPLEFT", f, "TOPLEFT", -border, border)
        b:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", border, -border)
        b:SetBackdrop(pfUI.backdrop_thin)
      end

      local level = f:GetFrameLevel()
      if level < 1 then
        b:SetFrameLevel(level)
      else
        b:SetFrameLevel(level - 1)
      end

      f.backdrop = b
    end

    local b = f.backdrop
    b:SetBackdropColor(br, bg, bb, ba)
    b:SetBackdropBorderColor(er, eg, eb , ea)
  end

  -- add shadow
  if not f.backdrop_shadow and pfUI_config.appearance.border.shadow == "1" then
    local anchor = f.backdrop or f

    f.backdrop_shadow = CreateFrame("Frame", nil, anchor)
    f.backdrop_shadow:SetFrameStrata("BACKGROUND")
    f.backdrop_shadow:SetFrameLevel(1)

    f.backdrop_shadow:SetPoint("TOPLEFT", anchor, "TOPLEFT", -7, 7)
    f.backdrop_shadow:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 7, -7)
    f.backdrop_shadow:SetBackdrop(pfUI.backdrop_shadow)
    f.backdrop_shadow:SetBackdropBorderColor(0,0,0,tonumber(pfUI_config.appearance.border.shadow_intensity))
  end
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
local formfactors = {}
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
-- 'bar'        frame reference,
-- 'barsize'    integer number of buttons,
-- 'formfactor' string formfactor in cols x rows,
-- 'padding'    the spacing between buttons
function pfUI.api.BarLayoutSize(bar,barsize,formfactor,iconsize,bordersize,padding)
  assert(barsize > 0 and barsize <= NUM_ACTIONBAR_BUTTONS,"BarLayoutSize: barsize "..tostring(barsize).." is invalid")
  local formfactor = pfUI.api.BarLayoutFormfactor(formfactor)
  local cols, rows = unpack(pfGridmath[barsize][formfactor])
  local width = (iconsize + bordersize*2+padding) * cols + padding
  local height = (iconsize + bordersize*2+padding) * rows + padding
  bar._size = {width,height}
  return bar._size
end

-- [ Bar Button Anchor ] --
-- 'button'       frame reference
-- 'basename'     name of button frame without index
-- 'buttonindex'  index number of button on bar
-- 'formfactor'   string formfactor in cols x rows
-- 'iconsize'     size of the button
-- 'bordersize'   default bordersize
-- 'padding'      the spacing between buttons
function pfUI.api.BarButtonAnchor(button,basename,buttonindex,barsize,formfactor,iconsize,bordersize,padding)
  assert(barsize > 0 and barsize <= NUM_ACTIONBAR_BUTTONS,"BarButtonAnchor: barsize "..tostring(barsize).." is invalid")
  local formfactor = pfUI.api.BarLayoutFormfactor(formfactor)
  local parent = button:GetParent()
  local cols, rows = unpack(pfGridmath[barsize][formfactor])
  if buttonindex == 1 then
    button._anchor = {"TOPLEFT", parent, "TOPLEFT", bordersize+padding, -bordersize-padding}
  else
    local col = buttonindex-((math.ceil(buttonindex/cols)-1)*cols)
    button._anchor = col==1 and {"TOP",_G[basename..(buttonindex-cols)],"BOTTOM",0,-(bordersize*2+padding)} or {"LEFT",_G[basename..(buttonindex-1)],"RIGHT",(bordersize*2+padding),0}
  end
  return button._anchor
end

-- [ Enable Autohide ] --
-- 'frame'  the frame that should be hidden
function pfUI.api.EnableAutohide(frame, timeout)
  if not frame then return end

  frame.hover = frame.hover or CreateFrame("Frame", frame:GetName() .. "Autohide", frame)
  frame.hover:SetParent(frame)
  frame.hover:SetAllPoints(frame)
  frame.hover.parent = frame
  frame.hover:Show()

  local timeout = timeout
  frame.hover:SetScript("OnUpdate", function()
    if MouseIsOver(this, 10, -10, -10, 10) then
      this.activeTo = GetTime() + timeout
      this.parent:SetAlpha(1)
    elseif this.activeTo then
      if this.activeTo < GetTime() and this.parent:GetAlpha() > 0 then
        this.parent:SetAlpha(this.parent:GetAlpha() - 0.1)
      end
    else
      this.activeTo = GetTime() + timeout
    end
  end)
end

-- [ Disable Autohide ] --
-- 'frame'  the frame that should get the autohide removed
function pfUI.api.DisableAutohide(frame)
  if not frame then return end
  if not frame.hover then return end

  frame.hover:SetScript("OnUpdate", nil)
  frame.hover:Hide()
  frame:SetAlpha(1)
end

-- [ GetColoredTime ] --
-- 'remaining'   the time in seconds that should be converted
-- return        a colored string including a time unit (m/h/d)
function pfUI.api.GetColoredTimeString(remaining)
  if not remaining then return "" end
  if remaining > 99 * 60 * 60 then
    local r,g,b,a = pfUI.api.GetStringColor(C.appearance.cd.daycolor)
    return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. round(remaining / 60 / 60 / 24) .. "|rd"
  elseif remaining > 99 * 60 then
    local r,g,b,a = pfUI.api.GetStringColor(C.appearance.cd.hourcolor)
    return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. round(remaining / 60 / 60) .. "|rh"
  elseif remaining > 99 then
    local r,g,b,a = pfUI.api.GetStringColor(C.appearance.cd.minutecolor)
    return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. round(remaining / 60) .. "|rm"
  elseif remaining <= 5 then
    local r,g,b,a = pfUI.api.GetStringColor(C.appearance.cd.lowcolor)
    return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. string.format("%.1f", round(remaining,1))
  elseif remaining >= 0 then
    local r, g, b, a = pfUI.api.GetStringColor(C.appearance.cd.normalcolor)
    return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. round(remaining)
  else
    return ""
  end
end

-- [ GetColorGradient ] --
-- 'perc'     percentage (0-1)
-- return r,g,b and hexcolor
local gradientcolors = {}
function pfUI.api.GetColorGradient(perc)
  -- fallback to black on bad numbers
  if perc < 0 or perc > 1 then return 0,0,0,"|cff000000" end

  if not gradientcolors[perc] then
    local r1, g1, b1, r2, g2, b2
    if perc <= 0.5 then
      perc = perc * 2
      r1, g1, b1 = 1, 0, 0
      r2, g2, b2 = 1, 1, 0
    else
      perc = perc * 2 - 1
      r1, g1, b1 = 1, 1, 0
      r2, g2, b2 = 0, 1, 0
    end

    local r = r1 + (r2 - r1)*perc
    local g = g1 + (g2 - g1)*perc
    local b = b1 + (b2 - b1)*perc
    local h = string.format("|cff%02x%02x%02x", r*255, g*255, b*255)

    gradientcolors[perc] = {}
    gradientcolors[perc].r = r
    gradientcolors[perc].g = g
    gradientcolors[perc].b = b
    gradientcolors[perc].h = h
  end

  return gradientcolors[perc].r,
    gradientcolors[perc].g,
    gradientcolors[perc].b,
    gradientcolors[perc].h
end

-- [ GetNoNameObject ] --
-- 'frame'      [string]       parent frame
-- 'scantype'   [string]       scanning Region or Children
-- 'objtype'    [string]
-- 'layer'      [string]
-- 'arg1'       [string]
-- return object

-- NOTE: special symbols must be escaped by the SAME symbol!
-- e.g. symbol '\':  '\\'
-- symbol '-': '--'
function pfUI.api.GetNoNameObject(frame, objtype, layer, arg1, arg2)
  local objects
  if objtype == "Texture" or objtype == "FontString" then
    objects = {frame:GetRegions()}
  else
    objects = {frame:GetChildren()}
  end

  for _, object in ipairs(objects) do
    local check = true
    if object:GetObjectType() ~= objtype or (layer and object:GetDrawLayer() ~= layer) then check = false end

    if check then
      if objtype == "Texture" and object.SetTexture and object:GetTexture() ~= "Interface\\BUTTONS\\WHITE8X8" then
        if arg1 then
          local texture = object:GetTexture()
          if texture and not string.find(texture, arg1) then check = false end
        end

        if check then return object end
      elseif objtype == "FontString" and object.SetText then
        if arg1 then
          local text = object:GetText()
          if text and not string.find(text, arg1) then check = false end
        end

        if check then return object end
      elseif objtype == "Button" and object.GetNormalTexture and object:GetNormalTexture() then
        if arg1 then
          local texture = object:GetNormalTexture():GetTexture()
          if texture and not string.find(texture, arg1) then check = false end
        end
        if arg2 then
          local text = object:GetText()
          if text and not string.find(text, arg2) then check = false end
        end

        if check then return object end
      end
    end
  end
end
