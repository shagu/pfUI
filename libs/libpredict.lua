-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

--[[ libpredict ]]--
-- A pfUI library that detects, receives and sends heal and resurrection predictions.
-- Healing predictions are done by caching the last known "normal" heal value of the
-- spell when last being used. Those chaches are cleared when new talents are detected.
-- The API provides function calls similar to later WoW expansions such as:
--   UnitGetIncomingHeals(unit)
--   UnitHasIncomingResurrection(unit)
--
-- The library is able to receive and send compatible messages to HealComm (vanilla)
-- and HealComm (tbc) including the ressurections of both versions. It has an option
-- to disable the sending of those messages in case one of the mentioned libraries
-- is already active.

-- return instantly when another libpredict is already active
if pfUI.api.libpredict then return end

local senttarget
local heals, ress, events, hots = {}, {}, {}, {}

local PRAYER_OF_HEALING
do -- Prayer of Healing
  local locales = {
    ["deDE"] = "Gebet der Heilung",
    ["enUS"] = "Prayer of Healing",
    ["esES"] = "Rezo de curación",
    ["frFR"] = "Prière de soins",
    ["koKR"] = "치유의 기원",
    ["ruRU"] = "Молитва исцеления",
    ["zhCN"] = "治疗祷言",
  }

  PRAYER_OF_HEALING = locales[GetLocale()] or locales["enUS"]
end

local REJUVENATION
do -- Rejuvenation
  local locales = {
    ["deDE"] = "Verjüngung",
    ["enUS"] = "Rejuvenation",
    ["esES"] = "Rejuvenecimiento",
    ["frFR"] = "Récupération",
    ["koKR"] = "회복",
    ["ruRU"] = "Омоложение",
    ["zhCN"] = "回春术",
  }

  REJUVENATION = locales[GetLocale()] or locales["enUS"]
end

local RENEW
do -- Renew
  local locales = {
    ["deDE"] = "Erneuerung",
    ["enUS"] = "Renew",
    ["esES"] = "Renovar",
    ["frFR"] = "Rénovation",
    ["koKR"] = "소생",
    ["ruRU"] = "Обновление",
    ["zhCN"] = "恢复",
  }

  RENEW = locales[GetLocale()] or locales["enUS"]
end

local REGROWTH
do -- Regrowth
  local locales = {
    ["deDE"] = "Nachwachsen",
    ["enUS"] = "Regrowth",
    ["esES"] = "Recrecimiento",
    ["frFR"] = "Rétablissement",
    ["koKR"] = "재생",
    ["ruRU"] = "Восстановление",
    ["zhCN"] = "愈合",
  }

  REGROWTH = locales[GetLocale()] or locales["enUS"]
end

local libpredict = CreateFrame("Frame")
libpredict:RegisterEvent("UNIT_HEALTH")
libpredict:RegisterEvent("CHAT_MSG_ADDON")
libpredict:RegisterEvent("PLAYER_TARGET_CHANGED")
libpredict:SetScript("OnEvent", function()
  if event == "CHAT_MSG_ADDON" and (arg1 == "HealComm" or arg1 == "CTRA") then
    this:ParseChatMessage(arg4, arg2, arg1)
  elseif event == "UNIT_HEALTH" then
    local name = UnitName(arg1)
    if ress[name] and not UnitIsDeadOrGhost(arg1) then
      ress[UnitName(arg1)] = nil
    end
  end
end)

libpredict:SetScript("OnUpdate", function()
  -- update on timeout events
  for timestamp, targets in pairs(events) do
    if GetTime() >= timestamp then
      events[timestamp] = nil
    end
  end
end)

function libpredict:ParseComm(sender, msg)
  local msgtype, target, heal, time

  if msg == "Healstop" or msg == "GrpHealstop" then
    msgtype = "Stop"
  elseif msg == "Resurrection/stop/" then
    msgtype = "RessStop"
  elseif msg then
    local msgobj = {strsplit("/", msg)}

    if msgobj and msgobj[1] and msgobj[2] then
      -- legacy healcomm object
      if msgobj[1] == "GrpHealdelay" or msgobj[1] == "Healdelay" then
        msgtype, time = "Delay", msgobj[2]
      end

      if msgobj[1] and msgobj[1] == "Resurrection" and msgobj[2] then
        msgtype, target = "Ress", msgobj[2]
      end

      if msgobj[1] == "Heal" and msgobj[2] then
        msgtype, target, heal, time = "Heal", msgobj[2], msgobj[3], msgobj[4]
      end

      if msgobj[1] == "GrpHeal" and msgobj[2] then
        msgtype, target, heal, time = "Heal", {}, msgobj[2], msgobj[3]
        for i=4,8 do
          if msgobj[i] then table.insert(target, msgobj[i]) end
        end
      end

      if msgobj[1] == "Reju" or msgobj[1] == "Renew" or msgobj[1] == "Regr" then --hots
        msgtype, target, heal, time = "Hot", msgobj[2], msgobj[1], msgobj[3]
      end
    elseif select and UnitCastingInfo then
      -- latest healcomm
      msgtype = tonumber(string.sub(msg, 1, 3))
      if not msgtype then return end

      if msgtype == 0 then
        msgtype = "Heal"
        heal = tonumber(string.sub(msg, 4, 8))
        target = string.sub(msg,9, -1)

        local starttime = select(5, UnitCastingInfo(sender))
        local endtime = select(6, UnitCastingInfo(sender))
        if not starttime or not endtime then return end
        time = endtime - starttime
      elseif msgtype == 1 then
        msgtype = "Stop"
      elseif msgtype == 2 then
        msgtype = "Heal"
        heal = tonumber(string.sub(msg,4, 8))
        target = {strsplit(":", string.sub(msg,9, -1))}
        local starttime = select(5, UnitCastingInfo(sender))
        local endtime = select(6, UnitCastingInfo(sender))
        if not starttime or not endtime then return end
        time = endtime - starttime
      end
    end
  end

  return msgtype, target, heal, time
end

function libpredict:ParseChatMessage(sender, msg, comm)
  local msgtype, target, heal, time

  if comm == "HealComm" then
    msgtype, target, heal, time = libpredict:ParseComm(sender, msg)
  elseif comm == "CTRA" then
    local _, _, cmd, ctratarget = string.find(msg, "(%a+)%s?([^#]*)")
    if cmd and ctratarget and cmd == "RES" and ctratarget ~= "" and ctratarget ~= UNKNOWN then
      msgtype = "Ress"
      target = ctratarget
    end
  end

  if msgtype == "Stop" and sender then
    libpredict:HealStop(sender)
    return
  elseif ( msg == "RessStop" or msg == "RESNO" ) and sender then
    libpredict:RessStop(sender)
    return
  elseif msgtype == "Delay" and time then
    libpredict:HealDelay(sender, time)
  elseif msgtype == "Heal" and target and heal and time then
    if type(target) == "table" then
      for _, name in pairs(target) do
        libpredict:Heal(sender, name, heal, time)
      end
    else
      libpredict:Heal(sender, target, heal, time)
    end
  elseif msgtype == "Ress" then
    libpredict:Ress(sender, target)
  elseif msgtype == "Hot" then
    libpredict:Hot(sender, target, heal, time)
  end
end

function libpredict:AddEvent(time, target)
  events[time] = events[time] or {}
  table.insert(events[time], target)
end

function libpredict:Heal(sender, target, amount, duration)
  if not sender or not target or not amount or not duration then
    return
  end

  local timeout = duration/1000 + GetTime()
  heals[target] = heals[target] or {}
  heals[target][sender] = { amount, timeout }
  libpredict:AddEvent(timeout, target)
end

function libpredict:Hot(sender, target, spell, duration)
  hots[target] = hots[target] or {}
  hots[target][spell] = hots[target][spell] or {}

  hots[target][spell].duration = duration
  hots[target][spell].start = GetTime()

  -- update aura events of relevant unitframes
  if pfUI and pfUI.uf and pfUI.uf.frames then
    for _, frame in pairs(pfUI.uf.frames) do
      if frame.namecache == target then
        frame.update_aura = true
      end
    end
  end
end

function libpredict:HealStop(sender)
  for ttarget, t in pairs(heals) do
    for tsender in pairs(heals[ttarget]) do
      if sender == tsender then
        heals[ttarget][tsender] = nil
      end
    end
  end
end

function libpredict:HealDelay(sender, delay)
  local delay = delay/1000
  for target, t in pairs(heals) do
    for tsender, amount in pairs(heals[target]) do
      if sender == tsender then
        amount[2] = amount[2] + delay
        libpredict:AddEvent(amount[2], target)
      end
    end
  end
end

function libpredict:Ress(sender, target)
  ress[target] = ress[target] or {}
  ress[target][sender] = true
end

function libpredict:RessStop(sender)
  for ttarget, t in pairs(ress) do
    for tsender in pairs(ress[ttarget]) do
      if sender == tsender then
        ress[ttarget][tsender] = nil
      end
    end
  end
end

function libpredict:UnitGetIncomingHeals(unit)
  if not unit or not UnitName(unit) then return 0 end
  if UnitIsDeadOrGhost(unit) then return 0 end
  local name = UnitName(unit)

  local sumheal = 0
  if not heals[name] then
    return sumheal
  else
    for sender, amount in pairs(heals[name]) do
      if amount[2] <= GetTime() then
        heals[name][sender] = nil
      else
        sumheal = sumheal + amount[1]
      end
    end
  end
  return sumheal
end

function libpredict:UnitHasIncomingResurrection(unit)
  if not unit or not UnitName(unit) then return nil end
  local name = UnitName(unit)

  if not ress[name] then
    return nil
  else
    for sender, val in pairs(ress[name]) do
      if val == true then
        return val
      end
    end
  end
  return nil
end

local spell_queue = { "DUMMY", "DUMMYRank 9", "TARGET" }
local realm = GetRealmName()
local player = UnitName("player")
local cache, gear_string = {}, ""
local resetcache = CreateFrame("Frame")
local rejuvDuration, renewDuration = 12, 15 --default durations
local hotsetbonus = libtipscan:GetScanner("hotsetbonus")
resetcache:RegisterEvent("PLAYER_ENTERING_WORLD")
resetcache:RegisterEvent("LEARNED_SPELL_IN_TAB")
resetcache:RegisterEvent("CHARACTER_POINTS_CHANGED")
resetcache:RegisterEvent("UNIT_INVENTORY_CHANGED")
resetcache:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    -- load and initialize previous caches of spell amounts
    pfUI_cache["prediction"] = pfUI_cache["prediction"] or {}
    pfUI_cache["prediction"][realm] = pfUI_cache["prediction"][realm] or {}
    pfUI_cache["prediction"][realm][player] = pfUI_cache["prediction"][realm][player] or {}
    pfUI_cache["prediction"][realm][player]["heals"] = pfUI_cache["prediction"][realm][player]["heals"] or {}
    cache = pfUI_cache["prediction"][realm][player]["heals"]
  end

  if event == "UNIT_INVENTORY_CHANGED" or "PLAYER_ENTERING_WORLD" then
    -- skip non-player events
    if arg1 and arg1 ~= "player" then return end

    local gear = ""
    for id = 1, 18 do
      gear = gear .. (GetInventoryItemLink("player",id) or "")
    end

    -- abort when inventory didn't change
    if gear == gear_string then return end
    gear_string = gear

    local setBonusCounter
    setBonusCounter = 0
    for i=1,10 do --there is no need to check slots above 10
      hotsetbonus:SetInventoryItem("player", i)
      if hotsetbonus:Find(L["healduration"]["Rejuvenation"]) then setBonusCounter = setBonusCounter + 1 end
    end
    rejuvDuration = setBonusCounter == 8 and 15 or 12
    setBonusCounter = 0
    for i =1,10 do
      hotsetbonus:SetInventoryItem("player", i)
      if hotsetbonus:Find(L["healduration"]["Renew"]) then setBonusCounter = setBonusCounter + 1 end
    end
    renewDuration = setBonusCounter == 5 and 18 or 15
  end

  -- flag all cached heals for renewal
  for k in pairs(cache) do
    if type(cache[k]) == "number" or type(cache[k]) == "string" then
      -- migrate old data
      local oldval = cache[k]
      cache[k] = { [1] = oldval }
    end

    -- flag for reset
    cache[k][2] = true
  end
end)

local function UpdateCache(spell, heal, crit)
  local heal = heal and tonumber(heal)
  if not spell or not heal then return end

  if not cache[spell] or cache[spell][2] then
    -- skills or equipment changed, save whatever is detected
    cache[spell] = cache[spell] or {}
    cache[spell][1] = crit and heal*2/3 or heal
    cache[spell][2] = crit
  elseif not crit and cache[spell][1] < heal then
    -- safe the best heal we can get
    cache[spell][1] = heal
    cache[spell][2] = nil
  end
end

-- Gather Data by User Actions
hooksecurefunc("CastSpell", function(id, bookType)
  if not libpredict.sender.enabled then return end
  local effect, rank = libspell.GetSpellInfo(id, bookType)
  if not effect then return end
  spell_queue[1] = effect
  spell_queue[2] = effect.. ( rank or "" )
  spell_queue[3] = UnitName("target") and UnitCanAssist("player", "target") and UnitName("target") or UnitName("player")
end, true)

hooksecurefunc("CastSpellByName", function(effect, target)
  if not libpredict.sender.enabled then return end
  local effect, rank = libspell.GetSpellInfo(effect)
  if not effect then return end
  local mouseover = pfUI and pfUI.uf and pfUI.uf.mouseover and pfUI.uf.mouseover.unit
  mouseover = mouseover and UnitCanAssist("player", mouseover) and UnitName(mouseover)

  local default = UnitName("target") and UnitCanAssist("player", "target") and UnitName("target") or UnitName("player")

  target = target and type(target) == "string" and UnitName(target) or target
  target = target and target == 1 and UnitName("player") or target

  spell_queue[1] = effect
  spell_queue[2] = effect.. ( rank or "" )
  spell_queue[3] = target or mouseover or default
end, true)

local scanner = libtipscan:GetScanner("prediction")
hooksecurefunc("UseAction", function(slot, target, selfcast)
  if not libpredict.sender.enabled then return end
  if GetActionText(slot) or not IsCurrentAction(slot) then return end
  scanner:SetAction(slot)
  local effect, rank = scanner:Line(1)
  if not effect then return end
  spell_queue[1] = effect
  spell_queue[2] = effect.. ( rank or "" )
  spell_queue[3] = selfcast and UnitName("player") or UnitName("target") and UnitCanAssist("player", "target") and UnitName("target") or UnitName("player")
end, true)

libpredict.sender = CreateFrame("Frame", "pfPredictionSender", UIParent)
libpredict.sender.enabled = true
libpredict.sender.SendHealCommMsg = function(self, msg)
  SendAddonMessage("HealComm", msg, "RAID")
  SendAddonMessage("HealComm", msg, "BATTLEGROUND")
end
libpredict.sender.SendResCommMsg = function(self, msg)
  SendAddonMessage("CTRA", msg, "RAID")
  SendAddonMessage("CTRA", msg, "BATTLEGROUND")
end

libpredict.sender:SetScript("OnUpdate", function()
  -- trigger delayed regrowth timers
  if this.regrowth_timer and GetTime() > this.regrowth_timer  then
    local target = this.regrowth_target or player
    local duration = 21

    libpredict:Hot(player, target, "Regr", duration)
    libpredict.sender:SendHealCommMsg("Regr/"..target.."/"..duration.."/")
    this.regrowth_target = this.regrowth_target_next
    this.regrowth_timer = nil
  end
end)

-- tbc
libpredict.sender:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
libpredict.sender:RegisterEvent("UNIT_SPELLCAST_START")
libpredict.sender:RegisterEvent("UNIT_SPELLCAST_STOP")
libpredict.sender:RegisterEvent("UNIT_SPELLCAST_FAILED")
libpredict.sender:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
libpredict.sender:RegisterEvent("UNIT_SPELLCAST_SENT")

-- vanilla
libpredict.sender:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
libpredict.sender:RegisterEvent("SPELLCAST_START")
libpredict.sender:RegisterEvent("SPELLCAST_STOP")
libpredict.sender:RegisterEvent("SPELLCAST_FAILED")
libpredict.sender:RegisterEvent("SPELLCAST_INTERRUPTED")
libpredict.sender:RegisterEvent("SPELLCAST_DELAYED")

-- force cache updates
libpredict.sender:RegisterEvent("UNIT_INVENTORY_CHANGED")
libpredict.sender:RegisterEvent("SKILL_LINES_CHANGED")

libpredict.sender:SetScript("OnEvent", function()
  if event == "CHAT_MSG_SPELL_SELF_BUFF" then -- vanilla
    local spell, _, heal = cmatch(arg1, HEALEDSELFOTHER) -- "Your %s heals %s for %d."
    if spell and heal then
      if spell == spell_queue[1] then UpdateCache(spell_queue[2], heal) end
      return
    end

    local spell, heal = cmatch(arg1, HEALEDSELFSELF) -- "Your %s heals you for %d."
    if spell and heal then
      if spell == spell_queue[1] then UpdateCache(spell_queue[2], heal) end
      return
    end

    local spell, heal = cmatch(arg1, HEALEDCRITSELFOTHER) -- "Your %s critically heals %s for %d."
    if spell and heal then
      if spell == spell_queue[1] then UpdateCache(spell_queue[2], heal, true) end
      return
    end

    local spell, _, heal = cmatch(arg1, HEALEDCRITSELFSELF) -- "Your %s critically heals you for %d."
    if spell and heal then
      if spell == spell_queue[1] then UpdateCache(spell_queue[2], heal, true) end
      return
    end
  elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and arg2 == "SPELL_HEAL" and arg4 == player then -- tbc
    local spell, heal, crit = arg10, arg12, arg13
    if spell and heal and crit then
      if spell == spell_queue[1] then UpdateCache(spell_queue[2], heal, true) end
    elseif spell and heal then
      if spell == spell_queue[1] then UpdateCache(spell_queue[2], heal) end
    end
  elseif event == "UNIT_SPELLCAST_SENT" and arg4 then -- fix tbc mouseover macros
      senttarget = arg4
  elseif strfind(event, "SPELLCAST_START", 1) then
    local spell, time = arg1, arg2

    if strfind(event, "UNIT_", 1) then -- tbc
      if arg1 ~= "player" then return end
      local spellname, _, _, _, starttime, endtime = UnitCastingInfo("player")
      spell, time = spellname, endtime - starttime
    end

    if spell_queue[1] == spell and cache[spell_queue[2]] then
      local sender = player
      local target = senttarget or spell_queue[3]
      local amount = cache[spell_queue[2]][1]
      local casttime = time

      if spell == REGROWTH then
        if this.regrowth_timer then
          this.regrowth_target_next = spell_queue[3]
        else
          this.regrowth_target = spell_queue[3]
        end
      end

      if spell == PRAYER_OF_HEALING then
        target = sender

        for i=1,4 do
          if CheckInteractDistance("party"..i, 4) then
            libpredict:Heal(player, UnitName("party"..i), amount, casttime)
            if pfUI.client < 20000 then -- vanilla
              libpredict.sender:SendHealCommMsg("Heal/" .. UnitName("party"..i) .. "/" .. amount .. "/" .. casttime .. "/")
            else -- tbc
              libpredict.sender:SendHealCommMsg(string.format("002%05d%s", math.min(amount, 99999), UnitName("party"..i)))
            end
            libpredict.sender.healing = true
          end
        end
      end

      libpredict:Heal(player, target, amount, casttime)
      if pfUI.client < 20000 then -- vanilla
        libpredict.sender:SendHealCommMsg("Heal/" .. target .. "/" .. amount .. "/" .. casttime .. "/")
      else -- tbc
        libpredict.sender:SendHealCommMsg(string.format("002%05d%s", math.min(amount, 99999), target))
      end
      libpredict.sender.healing = true

    elseif spell_queue[1] == spell and L["resurrections"][spell] then
      local target = senttarget or spell_queue[3]
      libpredict:Ress(player, target)
      libpredict.sender:SendHealCommMsg("Resurrection/" .. target .. "/start/")
      libpredict.sender:SendResCommMsg("RES " .. target)
      libpredict.sender.resurrecting = true
    end
  elseif strfind(event, "SPELLCAST_FAILED", 1) or strfind(event, "SPELLCAST_INTERRUPTED", 1) then
    if strfind(event, "UNIT_", 1) and arg1 ~= "player" then return end
    if libpredict.sender.healing then
      libpredict:HealStop(player)
      if pfUI.client < 20000 then -- vanilla
        libpredict.sender:SendHealCommMsg("HealStop")
      else -- tbc
        libpredict.sender:SendHealCommMsg("001F")
      end
      libpredict.sender.healing = nil
    elseif libpredict.sender.resurrecting then
      local target = senttarget or spell_queue[3]
      libpredict:RessStop(player)
      libpredict.sender:SendHealCommMsg("Resurrection/stop/")
      libpredict.sender:SendResCommMsg("RESNO " .. target)
      libpredict.sender.resurrecting = nil
    end
    if spell_queue[1] == REGROWTH then
      this.regrowth_timer = nil
    end
  elseif event == "SPELLCAST_DELAYED" then
    if libpredict.sender.healing then
      libpredict:HealDelay(player, arg1)
      libpredict.sender:SendHealCommMsg("Healdelay/" .. arg1 .. "/")
    end
  elseif strfind(event, "SPELLCAST_STOP", 1) then
    if strfind(event, "UNIT_", 1) and arg1 ~= "player" then return end
    libpredict:HealStop(player)
    if pfUI.client < 20000 then -- vanilla
      if spell_queue[1] == REJUVENATION then
        libpredict:Hot(player, spell_queue[3], "Reju", rejuvDuration)
        libpredict.sender:SendHealCommMsg("Reju/"..spell_queue[3].."/"..rejuvDuration.."/")
      elseif spell_queue[1] == RENEW then
        libpredict:Hot(player, spell_queue[3], "Renew", renewDuration)
        libpredict.sender:SendHealCommMsg("Renew/"..spell_queue[3].."/"..renewDuration.."/")
      elseif spell_queue[1] == REGROWTH then
        this.regrowth_timer = GetTime() + 0.1
      end
    else -- tbc
      --todo
    end
  end
end)

function libpredict:GetHotDuration(unit, spell)
  if unit == UNKNOWNOBJECT or unit == UNKOWNBEING then return end

  local start, duration, timeleft

  local unitdata = hots[UnitName(unit)]
  if unitdata and unitdata[spell] and (unitdata[spell].start + unitdata[spell].duration) > GetTime() - 1 then
    start = unitdata[spell].start
    duration = unitdata[spell].duration
    timeleft = (start + duration) - GetTime()
  end

  return start, duration, timeleft
end

pfUI.api.libpredict = libpredict
