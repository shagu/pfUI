pfUI:RegisterModule("prediction", "vanilla:tbc", function ()
  local heals = {}
  local ress = {}
  local events = {}
  local senttarget

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

  pfUI.prediction = CreateFrame("Frame")
  pfUI.prediction:RegisterEvent("UNIT_HEALTH")
  pfUI.prediction:RegisterEvent("CHAT_MSG_ADDON")
  pfUI.prediction:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.prediction:SetScript("OnEvent", function()
    if event == "CHAT_MSG_ADDON" and (arg1 == "HealComm" or arg1 == "CTRA") then
      this:ParseChatMessage(arg4, arg2, arg1)
    elseif event == "UNIT_HEALTH" then
      local name = UnitName(arg1)
      if ress[name] and not UnitIsDeadOrGhost(arg1) then
        ress[UnitName(arg1)] = nil
        this:TriggerUpdate(name)
      end

      if heals[name] then
        this:TriggerUpdate(name)
      end
    elseif event == "PLAYER_TARGET_CHANGED" then
      this:TriggerUpdate(UnitName("target"))
    end
  end)

  pfUI.prediction:SetScript("OnUpdate", function()
    for timestamp, targets in pairs(events) do
      if GetTime() >= timestamp then
        for id, target in pairs(targets) do
          pfUI.prediction:TriggerUpdate(target)
        end
        events[timestamp] = nil
      end
    end
  end)

  local function ParseComm(sender, msg)
    local msgtype, target, heal, time

    if msg == "Healstop" or msg == "GrpHealstop" then
      msgtype = "Stop"
    elseif msg == "Resurrection/stop/" then
      msgtype = "RessStop"
    else
      local msgobj = {strsplit("/", msg)}

      if msgobj and msgobj[1] and msgobj[2] then -- legacy healcomm object
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
      elseif select and UnitCastingInfo then -- latest healcomm
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

  function pfUI.prediction:ParseChatMessage(sender, msg, comm)
    local msgtype, target, heal, time

    if comm == "HealComm" then
      msgtype, target, heal, time = ParseComm(sender, msg)
    elseif comm == "CTRA" then
      local _, _, cmd, ctratarget = string.find(msg, "(%a+)%s?([^#]*)")
      if cmd and ctratarget and cmd == "RES" and ctratarget ~= "" and ctratarget ~= UNKNOWN then
        msgtype = "Ress"
        target = ctratarget
      end
    end

    if msgtype == "Stop" and sender then
      pfUI.prediction:HealStop(sender)
      return
    elseif ( msg == "RessStop" or msg == "RESNO" ) and sender then
      pfUI.prediction:RessStop(sender)
      return
    elseif msgtype == "Delay" and time then
      pfUI.prediction:HealDelay(sender, time)
    elseif msgtype == "Heal" and target and heal and time then
      if type(target) == "table" then
        for _, name in pairs(target) do
          pfUI.prediction:Heal(sender, name, heal, time)
        end
      else
        pfUI.prediction:Heal(sender, target, heal, time)
      end
    elseif msgtype == "Ress" then
      pfUI.prediction:Ress(sender, target)
    end
  end

  function pfUI.prediction:AddEvent(time, target)
    events[time] = events[time] or {}
    table.insert(events[time], target)
  end

  function pfUI.prediction:Heal(sender, target, amount, duration)
    if not sender or not target or not amount or not duration then
      return
    end

    local timeout = duration/1000 + GetTime()
    heals[target] = heals[target] or {}
    heals[target][sender] = { amount, timeout }
    pfUI.prediction:TriggerUpdate(target)
    pfUI.prediction:AddEvent(timeout, target)
  end

  function pfUI.prediction:HealStop(sender)
    for ttarget, t in pairs(heals) do
      for tsender in pairs(heals[ttarget]) do
        if sender == tsender then
          heals[ttarget][tsender] = nil
          pfUI.prediction:TriggerUpdate(ttarget)
        end
      end
    end
  end

  function pfUI.prediction:HealDelay(sender, delay)
    local delay = delay/1000
    for target, t in pairs(heals) do
      for tsender, amount in pairs(heals[target]) do
        if sender == tsender then
          amount[2] = amount[2] + delay
          pfUI.prediction:TriggerUpdate(target)
          pfUI.prediction:AddEvent(amount[2], target)
        end
      end
    end
  end

  function pfUI.prediction:GetHeal(target)
    local sumheal = 0
    if not heals[target] then
      return sumheal
    else
      for sender, amount in pairs(heals[target]) do
        if amount[2] <= GetTime() then
          heals[target][sender] = nil
        else
          sumheal = sumheal + amount[1]
        end
      end
    end
    return sumheal
  end

  function pfUI.prediction:Ress(sender, target)
    ress[target] = ress[target] or {}
    ress[target][sender] = true
    pfUI.prediction:TriggerUpdate(target)
  end

  function pfUI.prediction:RessStop(sender)
    for ttarget, t in pairs(ress) do
      for tsender in pairs(ress[ttarget]) do
        if sender == tsender then
          ress[ttarget][tsender] = nil
          pfUI.prediction:TriggerUpdate(ttarget)
        end
      end
    end
  end

  function pfUI.prediction:GetRess(target)
    if not ress[target] then
      return nil
    else
      for sender, val in pairs(ress[target]) do
        if val == true then
          return val
        end
      end
    end
    return nil
  end

  function pfUI.prediction:TriggerUpdate(target)
    if not target then return end
    local heal = pfUI.prediction:GetHeal(target)
    local ress = pfUI.prediction:GetRess(target)

    if pfUI.uf then
      pfUI.prediction:UpdateUnitFrames(target, heal, ress)
    end
  end

  function pfUI.prediction:UpdateUnitFrames(name, heal, ress)
    for id, frame in pairs(_G.pfUI.uf.frames) do
      if frame:IsVisible() and frame.label and frame.id then
        local overhealperc = tonumber(frame.config.overhealperc)
        local unit = frame.label .. frame.id
        local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)

        if UnitName(unit) == name then
          if ress and UnitIsDeadOrGhost(unit) then
            frame.ressIcon:Show()
          elseif heal and heal > 0 and (health < maxHealth or overhealperc > 0 ) then
            local width = frame.config.width
            local height = frame.config.height

            if frame.config.verticalbar == "0" then
              local healthWidth = width * (health / maxHealth)
              local incWidth = width * heal / maxHealth
              if healthWidth + incWidth > width * (1+(overhealperc/100)) then
                incWidth = width * (1+overhealperc/100) - healthWidth
              end

              if frame.config.invert_healthbar == "1" then
                frame.incHeal:SetWidth(incWidth)
              else
                frame.incHeal:SetWidth(incWidth + healthWidth)
              end
            else
              local healthHeight = height * (health / maxHealth)
              local incHeight = height * heal / maxHealth
              if healthHeight + incHeight > height * (1+(overhealperc/100)) then
                incHeight = height * (1+overhealperc/100) - healthHeight
              end

              if frame.config.invert_healthbar == "1" then
                frame.incHeal:SetHeight(incHeight)
              else
                frame.incHeal:SetHeight(incHeight + healthHeight)
              end
            end

            frame.incHeal:Show()
          else
            frame.incHeal:Hide()
            frame.ressIcon:Hide()
          end
        end
      end
    end
  end

  local spell_queue = { "DUMMY", "DUMMYRank 9", "TARGET" }

  local realm = GetRealmName()
  local player = UnitName("player")
  pfUI_cache["prediction"] = pfUI_cache["prediction"] or {}
  pfUI_cache["prediction"][realm] = pfUI_cache["prediction"][realm] or {}
  pfUI_cache["prediction"][realm][player] = pfUI_cache["prediction"][realm][player] or {}
  pfUI_cache["prediction"][realm][player]["heals"] = pfUI_cache["prediction"][realm][player]["heals"] or {}

  local cache = pfUI_cache["prediction"][realm][player]["heals"]
  local gear_string = ""
  local resetcache = CreateFrame("Frame")

  resetcache:RegisterEvent("SKILL_LINES_CHANGED")
  resetcache:RegisterEvent("UNIT_INVENTORY_CHANGED")
  resetcache:SetScript("OnEvent", function()
    if event == "UNIT_INVENTORY_CHANGED" then
      -- skip non-player events
      if arg1 and arg1 ~= "player" then return end

      local gear = ""
      for id = 1, 18 do
        gear = gear .. (GetInventoryItemLink("player",id) or "")
      end

      -- abort when inventory didn't change
      if gear == gear_string then return end
      gear_string = gear
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
    if not spell or not heal then return end
    local heal = tonumber(heal)

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
    if not pfUI.prediction.sender.enabled then return end
    local effect, rank = libspell.GetSpellInfo(id, bookType)
    if not effect then return end
    spell_queue[1] = effect
    spell_queue[2] = effect.. ( rank or "" )
    spell_queue[3] = UnitName("target") and UnitCanAssist("player", "target") and UnitName("target") or UnitName("player")
  end, true)

  hooksecurefunc("CastSpellByName", function(effect, target)
    if not pfUI.prediction.sender.enabled then return end
    local effect, rank = libspell.GetSpellInfo(effect)
    if not effect then return end
    spell_queue[1] = effect
    spell_queue[2] = effect.. ( rank or "" )
    spell_queue[3] = UnitName("target") and UnitCanAssist("player", "target") and UnitName("target") or UnitName("player")
  end, true)

  local scanner = libtipscan:GetScanner("prediction")
  hooksecurefunc("UseAction", function(slot, target, selfcast)
    if not pfUI.prediction.sender.enabled then return end
    if GetActionText(slot) or not IsCurrentAction(slot) then return end
    scanner:SetAction(slot)
    local effect, rank = scanner:Line(1)
    if not effect then return end
    spell_queue[1] = effect
    spell_queue[2] = effect.. ( rank or "" )
    spell_queue[3] = selfcast and UnitName("player") or UnitName("target") and UnitCanAssist("player", "target") and UnitName("target") or UnitName("player")
  end, true)

  pfUI.prediction.sender = CreateFrame("Frame", "pfPredictionSender", UIParent)
  pfUI.prediction.sender.enabled = true
  pfUI.prediction.sender.SendHealCommMsg = function(self, msg)
    SendAddonMessage("HealComm", msg, "RAID")
    SendAddonMessage("HealComm", msg, "BATTLEGROUND")
  end
  pfUI.prediction.sender.SendResCommMsg = function(self, msg)
    SendAddonMessage("CTRA", msg, "RAID")
    SendAddonMessage("CTRA", msg, "BATTLEGROUND")
  end

  -- tbc
  pfUI.prediction.sender:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  pfUI.prediction.sender:RegisterEvent("UNIT_SPELLCAST_START")
  pfUI.prediction.sender:RegisterEvent("UNIT_SPELLCAST_STOP")
  pfUI.prediction.sender:RegisterEvent("UNIT_SPELLCAST_FAILED")
  pfUI.prediction.sender:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
  pfUI.prediction.sender:RegisterEvent("UNIT_SPELLCAST_SENT")

  -- vanilla
  pfUI.prediction.sender:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
  pfUI.prediction.sender:RegisterEvent("SPELLCAST_START")
  pfUI.prediction.sender:RegisterEvent("SPELLCAST_STOP")
  pfUI.prediction.sender:RegisterEvent("SPELLCAST_FAILED")
  pfUI.prediction.sender:RegisterEvent("SPELLCAST_INTERRUPTED")
  pfUI.prediction.sender:RegisterEvent("SPELLCAST_DELAYED")

  -- force cache updates
  pfUI.prediction.sender:RegisterEvent("UNIT_INVENTORY_CHANGED")
  pfUI.prediction.sender:RegisterEvent("SKILL_LINES_CHANGED")

  pfUI.prediction.sender:SetScript("OnEvent", function()
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

        if spell == PRAYER_OF_HEALING then
          target = sender

          for i=1,4 do
            if CheckInteractDistance("party"..i, 4) then
              pfUI.prediction:Heal(player, UnitName("party"..i), amount, casttime)
              if pfUI.client < 20000 then -- vanilla
                pfUI.prediction.sender:SendHealCommMsg("Heal/" .. UnitName("party"..i) .. "/" .. amount .. "/" .. casttime .. "/")
              else -- tbc
                pfUI.prediction.sender:SendHealCommMsg(string.format("002%05d%s", math.min(amount, 99999), UnitName("party"..i)))
              end
              pfUI.prediction.sender.healing = true
            end
          end
        end

        pfUI.prediction:Heal(player, target, amount, casttime)
        if pfUI.client < 20000 then -- vanilla
          pfUI.prediction.sender:SendHealCommMsg("Heal/" .. target .. "/" .. amount .. "/" .. casttime .. "/")
        else -- tbc
          pfUI.prediction.sender:SendHealCommMsg(string.format("002%05d%s", math.min(amount, 99999), target))
        end
        pfUI.prediction.sender.healing = true

      elseif spell_queue[1] == spell and L["resurrections"][spell] then
        local target = senttarget or spell_queue[3]
        pfUI.prediction:Ress(player, target)
        pfUI.prediction.sender:SendHealCommMsg("Resurrection/" .. target .. "/start/")
        pfUI.prediction.sender:SendResCommMsg("RES " .. target)
        pfUI.prediction.sender.resurrecting = true
      end
    elseif strfind(event, "SPELLCAST_FAILED", 1) or strfind(event, "SPELLCAST_INTERRUPTED", 1) then
      if strfind(event, "UNIT_", 1) and arg1 ~= "player" then return end
      if pfUI.prediction.sender.healing then
        pfUI.prediction:HealStop(player)
        if pfUI.client < 20000 then -- vanilla
          pfUI.prediction.sender:SendHealCommMsg("HealStop")
        else -- tbc
          pfUI.prediction.sender:SendHealCommMsg("001F")
        end
        pfUI.prediction.sender.healing = nil
      elseif pfUI.prediction.sender.resurrecting then
        local target = senttarget or spell_queue[3]
        pfUI.prediction:RessStop(player)
        pfUI.prediction.sender:SendHealCommMsg("Resurrection/stop/")
        pfUI.prediction.sender:SendResCommMsg("RESNO " .. target)
        pfUI.prediction.sender.resurrecting = nil
      end
    elseif event == "SPELLCAST_DELAYED" then
      if pfUI.prediction.sender.healing then
        pfUI.prediction:HealDelay(player, arg1)
        pfUI.prediction.sender:SendHealCommMsg("Healdelay/" .. arg1 .. "/")
      end
    elseif strfind(event, "SPELLCAST_STOP", 1) then
      if strfind(event, "UNIT_", 1) and arg1 ~= "player" then return end
      pfUI.prediction:HealStop(player)
    end
  end)
end)
