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

-- [ isempty ]
-- Returns true if a table is empty or not existing, otherwise false.
-- 'tbl'         [table]        the table that shall be checked
-- return:      [boolean]       result of the check.
function pfUI.api.isempty(tbl)
  if not tbl then return true end
  for k, v in pairs(tbl) do
    return false
  end
  return true
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

-- [ RunOOC ]
-- Runs a function once, as soon as the combat lockdown fades.
-- func         [function]      The function that shall run ooc.
-- return:      [bool]          true if the function was added,
--                              nil if the function already exists in queue
local queue, frame = {}
function pfUI.api.RunOOC(func)
  if not frame then
    frame = CreateFrame("Frame")
    frame:SetScript("OnUpdate", function()
      if InCombatLockdown and InCombatLockdown() then return end
      for key, func in pairs(queue) do func(); queue[key] = nil end
    end)
  end

  if not queue[tostring(func)] then
    queue[tostring(func)] = func
    return true
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

  return pfUI.api.rgbhex(r,g,b), r, g, b
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

-- [ GetSlashCommands ]
-- Lists all registeres slash commands
-- 'text'       [string]        optional, a specific command to find
-- return:      [list]          a list of all matching slash commands
function pfUI.api.GetSlashCommands(text)
  local cmds
  for k, v in pairs(_G) do
    if strfind(k, "^SLASH_") and (not text or v == text) then
      cmds = cmds or {}
      cmds[k] = v
    end
  end

  return cmds
end

-- [ RegisterSlashCommand ]
-- Lists all registeres slash commands
-- 'name'       [string]      name of the command
-- 'cmds'       [table]       table containing all slash command strings
-- 'func'       [function]    the function that should be assigned
-- 'force'      [boolean]     force assign the command even if aleady provided
--                            by another function/addon.
function pfUI.api.RegisterSlashCommand(name, cmds, func, force)
  local counter = 1

  for _, cmd in pairs(cmds) do
    if force or not pfUI.api.GetSlashCommands(cmd) then
      _G["SLASH_"..name..counter] = cmd
      counter = counter + 1
    end
  end

  _G.SlashCmdList[name] = func
end

-- [ GetCaptures ]
-- Returns the indexes of a given regex pattern
-- 'pat'        [string]         unformatted pattern
-- returns:     [numbers]        capture indexes
local capture_cache = {}
function pfUI.api.GetCaptures(pat)
  local r = capture_cache

  if not r[pat] then
    for a, b, c, d, e in gfind(gsub(pat, "%((.+)%)", "%1"), gsub(pat, "%d%$", "%%(.-)$")) do
      r[pat] = { a, b, c, d, e}
    end

    r[pat] = r[pat] or {}
  end

  return r[pat][1], r[pat][2], r[pat][3], r[pat][4], r[pat][5]
end

-- [ SanitizePattern ]
-- Sanitizes and convert patterns into gfind compatible ones.
-- 'pattern'    [string]         unformatted pattern
-- returns:     [string]         simplified gfind compatible pattern
local sanitize_cache = {}
function pfUI.api.SanitizePattern(pattern)
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
local a, b, c, d, e
local _, va, vb, vc, vd, ve
local ra, rb, rc, rd, re
function pfUI.api.cmatch(str, pat)
  -- read capture indexes
  a, b, c, d, e = GetCaptures(pat)
  _, _, va, vb, vc, vd, ve = string.find(str, pfUI.api.SanitizePattern(pat))

  -- put entries into the proper return values
  ra = e == 1 and ve or d == 1 and vd or c == 1 and vc or b == 1 and vb or va
  rb = e == 2 and ve or d == 2 and vd or c == 2 and vc or a == 2 and va or vb
  rc = e == 3 and ve or d == 3 and vd or a == 3 and va or b == 3 and vb or vc
  rd = e == 4 and ve or a == 4 and va or c == 4 and vc or b == 4 and vb or vd
  re = a == 5 and va or d == 5 and vd or c == 5 and vc or b == 5 and vb or ve

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
      local _, itemCount = GetContainerItemInfo(bag, slot)
      if itemCount then
        local itemLink = GetContainerItemLink(bag,slot)
        local _, _, itemParse = strfind(itemLink, "(%d+):")
        local queryName = GetItemInfo(itemParse)
        if queryName and queryName ~= "" then
          if queryName == itemName then
            count = count + itemCount
          end
        end
      end
    end
  end

  return count
end

-- [ FindItem ]
-- Returns the bag and slot position of an item based on the name.
-- 'item'       [string]         name of the item
-- returns:     [int]            bag
--              [int]            slot
function pfUI.api.FindItem(item)
  for bag = 4, 0, -1 do
    for slot = 1, GetContainerNumSlots(bag) do
      local itemLink = GetContainerItemLink(bag,slot)
      if itemLink then
        local _, _, parse = strfind(itemLink, "(%d+):")
        local query = GetItemInfo(parse)
        if query and query ~= "" and string.lower(query) == string.lower(item) then
          return bag, slot
        end
      end
    end
  end

  return nil
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
    local _, _, _, _, _, itemType, subType = GetItemInfo(id)
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
    local sign = number < 0 and -1 or 1
    number = math.abs(number)

    if number > 1000000 then
      return pfUI.api.round(number/1000000*sign,2) .. "m"
    elseif number > 1000 then
      return pfUI.api.round(number/1000*sign,2) .. "k"
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
  f:SetScript(script, function(a1,a2,a3,a4,a5,a6,a7,a8,a9)
    if prev then prev(a1,a2,a3,a4,a5,a6,a7,a8,a9) end
    func(a1,a2,a3,a4,a5,a6,a7,a8,a9)
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
  if silver > 0 or gold > 0 then string = string .. "|cffffffff " .. silver .. "|cffc7c7cfs" end
  string = string .. "|cffffffff " .. copper .. "|cffeda55fc"

  return string
end

-- [ Enable Movable ]
-- Set all necessary functions to make a already existing frame movable.
-- 'name'       [frame/string]  Name of the Frame that should be movable
-- 'addon'      [string]        Addon that must be loaded before being able to access the frame
-- 'blacklist'  [table]         A list of frames that should be deactivated for mouse usage
local function OnDragStart() this:StartMoving() end
local function OnDragStop() this:StopMovingOrSizing() end
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
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", OnDragStart)
        frame:SetScript("OnDragStop", OnDragStop)

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
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", OnDragStart)
    frame:SetScript("OnDragStop", OnDragStop)
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
    if pfUI_config["position"][frame:GetName()]["parent"] then
      frame:SetParent(_G[pfUI_config["position"][frame:GetName()]["parent"]])
    end

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
      local a, b, c, d, e = unpack(point)
      if a and b then frame:SetPoint(a,b,c,d,e) end
    end
  end
end

-- [ Save Movable ]
-- Save the positions of a Frame.
-- 'frame'      [frame]        the frame that should be saved.
function pfUI.api.SaveMovable(frame, scale)
  local anchor, _, _, xpos, ypos = frame:GetPoint()
  C.position[frame:GetName()] = C.position[frame:GetName()] or {}
  C.position[frame:GetName()]["xpos"] = round(xpos)
  C.position[frame:GetName()]["ypos"] = round(ypos)
  C.position[frame:GetName()]["anchor"] = anchor
  C.position[frame:GetName()]["parent"] = frame:GetParent() and frame:GetParent():GetName() or nil
  if scale then
    C.position[frame:GetName()]["scale"] = frame:GetScale()
  end
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

-- [ AlignToPosition ]
-- Sets a frame to the selected anchor
-- 'frame'      [frame]     the frame that should be aligned
-- 'anchor'     [frame]     the frame where it should be aligned to
-- 'position'   [string]    where it should appear, takes the following:
--                          "TOP", "RIGHT", "BOTTOM", "LEFT"
function pfUI.api.AlignToPosition(frame, anchor, position, spacing)
  if frame == anchor then return end
  frame:ClearAllPoints()
  if position == "TOP" and anchor then
    frame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, (spacing or 0))
    frame:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, (spacing or 0))
  elseif position == "RIGHT" and anchor then
    frame:SetPoint("TOPLEFT", anchor, "TOPRIGHT", (spacing or 0), 0)
    frame:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT", (spacing or 0), 0)
  elseif position == "BOTTOM" and anchor then
    frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -(spacing or 0))
    frame:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -(spacing or 0))
  elseif position == "LEFT" and anchor then
    frame:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -(spacing or 0), 0)
    frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -(spacing or 0), 0)
  else
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
    frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
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

-- [ GetBestAnchor ]
-- Returns the best anchor of a frame, based on its position
-- 'self'       [frame]        the frame that should be checked
-- returns:     [string]       the name of the best anchor
function pfUI.api.GetBestAnchor(self)
  local scale = self:GetScale()
  local x, y = self:GetCenter()
  local a = GetScreenWidth()  / scale / 3
  local b = GetScreenWidth()  / scale / 3 * 2
  local c = GetScreenHeight() / scale / 3 * 2
  local d = GetScreenHeight() / scale / 3
  if not x or not y then return end

  if x < a and y > c then
    return "TOPLEFT"
  elseif x > a and x < b and y > c then
    return "TOP"
  elseif x > b and y > c then
    return "TOPRIGHT"
  elseif x < a and y > d and y < c then
    return "LEFT"
  elseif x > a and x < b and y > d and y < c then
    return "CENTER"
  elseif x > b and y > d and y < c then
    return "RIGHT"
  elseif x < a and y < d then
    return "BOTTOMLEFT"
  elseif x > a and x < b and y < d then
    return "BOTTOM"
  elseif x > b and y < d then
    return "BOTTOMRIGHT"
  end
end

-- [ ConvertFrameAnchor ]
-- Converts a frame anchor into another one while preserving the frame position
-- 'self'       [frame]        the frame that should get another anchor.
-- 'anchor'     [string]       the new anchor that shall be used
-- returns:     anchor, x, y   can directly be used in SetPoint()
function pfUI.api.ConvertFrameAnchor(self, anchor)
  local scale, x, y, _ = self:GetScale(), nil, nil, nil

  if anchor == "CENTER" then
    x, y = self:GetCenter()
    x, y = x - GetScreenWidth()/2/scale, y - GetScreenHeight()/2/scale
  elseif anchor == "TOPLEFT" then
    x, y = self:GetLeft(), self:GetTop() - GetScreenHeight()/scale
  elseif anchor == "TOP" then
    x, _ = self:GetCenter()
    x, y = x - GetScreenWidth()/2/scale, self:GetTop() - GetScreenHeight()/scale
  elseif anchor == "TOPRIGHT" then
    x, y = self:GetRight() - GetScreenWidth()/scale, self:GetTop() - GetScreenHeight()/scale
  elseif anchor == "RIGHT" then
    _, y = self:GetCenter()
    x, y = self:GetRight() - GetScreenWidth()/scale, y - GetScreenHeight()/2/scale
  elseif anchor == "BOTTOMRIGHT" then
    x, y = self:GetRight() - GetScreenWidth()/scale, self:GetBottom()
  elseif anchor == "BOTTOM" then
    x, _ = self:GetCenter()
    x, y = x - GetScreenWidth()/2/scale, self:GetBottom()
  elseif anchor == "BOTTOMLEFT" then
    x, y = self:GetLeft(), self:GetBottom()
  elseif anchor == "LEFT" then
    _, y = self:GetCenter()
    x, y = self:GetLeft(), y - GetScreenHeight()/2/scale
  end

  return anchor, round(x, 2), round(y, 2)
end

-- [ GetStringColor ]
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

-- [ rgbhex ]
-- Returns color format from color info
-- 'r'          [table | number]  color table or r color component
-- 'g'          [number]          optional g color component
-- 'b'          [number]          optional b color component
-- 'a'          [number]          optional alpha component
-- returns color string in the form of '|caarrggbb'
local _r, _g, _b, _a
function pfUI.api.rgbhex(r, g, b, a)
  if type(r) == "table" then
    if r.r then
      _r, _g, _b, _a = r.r, r.g, r.b, (r.a or 1)
    elseif table.getn(r) >= 3 then
      _r, _g, _b, _a = r[1], r[2], r[3], (r[4] or 1)
    end
  elseif tonumber(r) then
    _r, _g, _b, _a = r, g, b, (a or 1)
  end

  if _r and _g and _b and _a then
    -- limit values to 0-1
    _r = _r + 0 > 1 and 1 or _r + 0
    _g = _g + 0 > 1 and 1 or _g + 0
    _b = _b + 0 > 1 and 1 or _b + 0
    _a = _a + 0 > 1 and 1 or _a + 0
    return string.format("|c%02x%02x%02x%02x", _a*255, _r*255, _g*255, _b*255)
  end

  return ""
end

-- [ GetBorderSize ]
-- Returns the configure value of a border and its pixel scaled version.
-- 'pref' allows to specifiy a custom border (i.e unitframes, panel)
function pfUI.api.GetBorderSize(pref)
  if not pfUI.borders then pfUI.borders = {} end

  -- set to default border if accessing a wrong border type
  if not pref or not pfUI_config.appearance.border[pref] or pfUI_config.appearance.border[pref] == "-1" then
    pref = "default"
  end

  if pfUI.borders[pref] then
    -- return already cached values
    return pfUI.borders[pref][1], pfUI.borders[pref][2]
  else
    -- add new borders to the pfUI tree
    local raw = tonumber(pfUI_config.appearance.border[pref])
    if raw == -1 then raw = 3 end

    local scaled = raw * GetPerfectPixel()
    pfUI.borders[pref] = { raw, scaled }

    return raw, scaled
  end
end

-- [ GetPerfectPixel ]
-- Returns a number that equals a real pixel on regular scaled frames.
-- Respects the current UI-scale and calculates a real pixel based on
-- the screen resolution and the 768px sized drawlayer.
function pfUI.api.GetPerfectPixel()
  if pfUI.pixel then return pfUI.pixel end

  if pfUI_config.appearance.border.pixelperfect == "1" then
    local scale = GetCVar("uiScale")
    local resolution = GetCVar("gxResolution")
    local _, _, screenwidth, screenheight = strfind(resolution, "(.+)x(.+)")

    pfUI.pixel = 768 / screenheight / scale
    pfUI.pixel = pfUI.pixel > 1 and 1 or pfUI.pixel

    -- autodetect and zoom for HiDPI displays
    if pfUI_config.appearance.border.hidpi == "1" then
      pfUI.pixel = pfUI.pixel < .5 and pfUI.pixel * 2 or pfUI.pixel
    end
  else
    pfUI.pixel = .7
  end

  pfUI.backdrop = {
    bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = false, tileSize = 0,
    edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = pfUI.pixel,
    insets = {left = -pfUI.pixel, right = -pfUI.pixel, top = -pfUI.pixel, bottom = -pfUI.pixel},
  }

  pfUI.backdrop_thin = {
    bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = false, tileSize = 0,
    edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = pfUI.pixel,
    insets = {left = 0, right = 0, top = 0, bottom = 0},
  }

  return pfUI.pixel
end

-- [ Create Backdrop ]
-- Creates a pfUI compatible frame as backdrop element
-- 'f'          [frame]         the frame which should get a backdrop.
-- 'inset'      [int]           backdrop inset, defaults to border size.
-- 'legacy'     [bool]          use legacy backdrop instead of creating frames.
-- 'transp'     [number]        set default transparency
local backdrop, b, level, rawborder, border, br, bg, bb, ba, er, eg, eb, ea
function pfUI.api.CreateBackdrop(f, inset, legacy, transp, backdropSetting)
  -- exit if now frame was given
  if not f then return end

  -- load raw and pixel perfect scaled border
  rawborder, border = GetBorderSize()

  -- load custom border if existing
  if inset then
    rawborder = inset / GetPerfectPixel()
    border = inset
  end

  -- detect if blizzard backdrops shall be used
  local blizz = C.appearance.border.force_blizz == "1" and true or nil
  backdrop = blizz and pfUI.backdrop_blizz_full or rawborder == 1 and pfUI.backdrop_thin or pfUI.backdrop
  border = blizz and math.max(border, 3) or border

  -- get the color settings
  br, bg, bb, ba = pfUI.api.GetStringColor(pfUI_config.appearance.border.background)
  er, eg, eb, ea = pfUI.api.GetStringColor(pfUI_config.appearance.border.color)

  if transp and transp < tonumber(ba) then ba = transp end

  -- use legacy backdrop handling
  if legacy then
    if backdropSetting then f:SetBackdrop(backdropSetting) end
    f:SetBackdrop(backdrop)
    f:SetBackdropColor(br, bg, bb, ba)
    f:SetBackdropBorderColor(er, eg, eb , ea)
  else
    -- increase clickable area if available
    if f.SetHitRectInsets and ( not InCombatLockdown or not InCombatLockdown()) then
      f:SetHitRectInsets(-border,-border,-border,-border)
    end

    -- use new backdrop behaviour
    if not f.backdrop then
      if f:GetBackdrop() then f:SetBackdrop(nil) end

      local b = CreateFrame("Frame", nil, f)
      level = f:GetFrameLevel()
      if level < 1 then
        b:SetFrameLevel(level)
      else
        b:SetFrameLevel(level - 1)
      end

      f.backdrop = b
    end

    f.backdrop:SetPoint("TOPLEFT", f, "TOPLEFT", -border, border)
    f.backdrop:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", border, -border)
    f.backdrop:SetBackdrop(backdrop)
    f.backdrop:SetBackdropColor(br, bg, bb, ba)
    f.backdrop:SetBackdropBorderColor(er, eg, eb , ea)

    if blizz then
      if not f.backdrop_border then
        local border = CreateFrame("Frame", nil, f.backdrop)
        border:SetFrameLevel(level + 2)
        f.backdrop_border = border

        local hookSetBackdropBorderColor = f.backdrop.SetBackdropBorderColor
        f.backdrop.SetBackdropBorderColor = function(self, r, g, b, a)
          f.backdrop_border:SetBackdropBorderColor(r, g, b, a)
          hookSetBackdropBorderColor(f.backdrop, r, g, b, a)
        end
      end

      f.backdrop_border:SetAllPoints(f.backdrop)
      f.backdrop_border:SetBackdrop(pfUI.backdrop_blizz_border)
      f.backdrop_border:SetBackdropBorderColor(er, eg, eb , ea)
    end
  end
end

-- [ Create Shadow ]
-- Creates a pfUI compatible frame as shadow element
-- 'f'          [frame]         the frame which should get a backdrop.
function pfUI.api.CreateBackdropShadow(f)
  -- exit if now frame was given
  if not f then return end

  if f.backdrop_shadow or pfUI_config.appearance.border.shadow ~= "1" then
    return
  end

  local anchor = f.backdrop or f
  f.backdrop_shadow = CreateFrame("Frame", nil, anchor)
  f.backdrop_shadow:SetFrameStrata("BACKGROUND")
  f.backdrop_shadow:SetFrameLevel(1)
  f.backdrop_shadow:SetPoint("TOPLEFT", anchor, "TOPLEFT", -5, 5)
  f.backdrop_shadow:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 5, -5)
  f.backdrop_shadow:SetBackdrop(pfUI.backdrop_shadow)
  f.backdrop_shadow:SetBackdropBorderColor(0, 0, 0, tonumber(pfUI_config.appearance.border.shadow_intensity))
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
function pfUI.api.EnableAutohide(frame, timeout, combat)
  if not frame then return end
  local timeout = timeout

  frame.hover = frame.hover or CreateFrame("Frame", frame:GetName() .. "Autohide", frame)
  frame.hover:SetParent(frame)
  frame.hover:SetAllPoints(frame)
  frame.hover.parent = frame
  frame.hover:Show()

  if combat then
    frame.hover:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame.hover:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame.hover:SetScript("OnEvent", function()
      if event == "PLAYER_REGEN_DISABLED" then
        this.parent:SetAlpha(1)
        this.activeTo = "keep"
      elseif event == "PLAYER_REGEN_ENABLED" then
        this.activeTo = GetTime() + timeout
      end
    end)
  end

  frame.hover:SetScript("OnUpdate", function()
    if this.activeTo == "keep" then return end

    if MouseIsOver(this, 10, -10, -10, 10) then
      this.activeTo = GetTime() + timeout
      this.parent:SetAlpha(1)
    elseif this.activeTo then
      if this.activeTo < GetTime() and this.parent:GetAlpha() > 0 then
        local fps = (60 / math.max(GetFramerate(), 1))
        this.parent:SetAlpha(this.parent:GetAlpha() - 0.05*fps)
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

  frame.hover:SetScript("OnEvent", nil)
  frame.hover:SetScript("OnUpdate", nil)
  frame.hover:Hide()
  frame:SetAlpha(1)
end

-- [ GetColoredTime ] --
-- 'remaining'   the time in seconds that should be converted
-- return        a colored string including a time unit (m/h/d)
local color_day, color_hour, color_minute, color_low, color_normal
function pfUI.api.GetColoredTimeString(remaining)
  if not remaining then return "" end

  -- Show days if remaining is > 99 Hours (99 * 60 * 60)
  if remaining > 356400 then
    if not color_day then
      local r,g,b,a = pfUI.api.GetStringColor(C.appearance.cd.daycolor)
      color_day = pfUI.api.rgbhex(r,g,b)
    end

    return color_day .. round(remaining / 86400) .. "|rd"

  -- Show hours if remaining is > 99 Minutes (99 * 60)
  elseif remaining > 5940 then
    if not color_hour then
      local r,g,b,a = pfUI.api.GetStringColor(C.appearance.cd.hourcolor)
      color_hour = pfUI.api.rgbhex(r,g,b)
    end

    return color_hour .. round(remaining / 3600) .. "|rh"

  -- Show minutes if remaining is > 99 Seconds (99)
  elseif remaining > 99 then
    if not color_minute then
      local r,g,b,a = pfUI.api.GetStringColor(C.appearance.cd.minutecolor)
      color_minute = pfUI.api.rgbhex(r,g,b)
    end

    return color_minute .. round(remaining / 60) .. "|rm"

  -- Show milliseconds on low
  elseif remaining <= 5 and pfUI_config.appearance.cd.milliseconds == "1" then
    if not color_low then
      local r,g,b,a = pfUI.api.GetStringColor(C.appearance.cd.lowcolor)
      color_low = pfUI.api.rgbhex(r,g,b)
    end

    return color_low .. string.format("%.1f", round(remaining,1))

  -- Show seconds on low
  elseif remaining <= 5 then
    if not color_low then
      local r,g,b,a = pfUI.api.GetStringColor(C.appearance.cd.lowcolor)
      color_low = pfUI.api.rgbhex(r,g,b)
    end

    return color_low .. round(remaining)

  -- Show seconds on normal
  elseif remaining >= 0 then
    if not color_normal then
      local r, g, b, a = pfUI.api.GetStringColor(C.appearance.cd.normalcolor)
      color_normal = pfUI.api.rgbhex(r,g,b)
    end
    return color_normal .. round(remaining)

  -- Return empty
  else
    return ""
  end
end

-- [ GetColorGradient ] --
-- 'perc'     percentage (0-1)
-- return r,g,b and hexcolor
local gradientcolors = {}
function pfUI.api.GetColorGradient(perc)
  perc = perc > 1 and 1 or perc
  perc = perc < 0 and 0 or perc
  perc = floor(perc*100)/100

  local index = perc
  if not gradientcolors[index] then
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

    local r = round(r1 + (r2 - r1) * perc, 4)
    local g = round(g1 + (g2 - g1) * perc, 4)
    local b = round(b1 + (b2 - b1) * perc, 4)
    local h = pfUI.api.rgbhex(r,g,b)

    gradientcolors[index] = {}
    gradientcolors[index].r = r
    gradientcolors[index].g = g
    gradientcolors[index].b = b
    gradientcolors[index].h = h
  end

  return gradientcolors[index].r,
    gradientcolors[index].g,
    gradientcolors[index].b,
    gradientcolors[index].h
end

-- [ GetNoNameObject ] --
-- 'frame'      [string]       parent frame
-- 'scantype'   [string]       scanning Region or Children
-- 'objtype'    [string]
-- 'layer'      [string]
-- 'arg1'       [string]
-- return object
function pfUI.api.GetNoNameObject(frame, objtype, layer, arg1, arg2)
  local arg1 = arg1 and gsub(arg1, "([%+%-%*%(%)%?%[%]%^])", "%%%1")
  local arg2 = arg2 and gsub(arg2, "([%+%-%*%(%)%?%[%]%^])", "%%%1")

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
          if texture and not string.find(texture, arg1, 1) then check = false end
        end

        if check then return object end
      elseif objtype == "FontString" and object.SetText then
        if arg1 then
          local text = object:GetText()
          if text and not string.find(text, arg1, 1) then check = false end
        end

        if check then return object end
      elseif objtype == "Button" and object.GetNormalTexture and object:GetNormalTexture() then
        if arg1 then
          local texture = object:GetNormalTexture():GetTexture()
          if texture and not string.find(texture, arg1, 1) then check = false end
        end
        if arg2 then
          local text = object:GetText()
          if text and not string.find(text, arg2, 1) then check = false end
        end

        if check then return object end
      end
    end
  end
end
