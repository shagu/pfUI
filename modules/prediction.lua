pfUI:RegisterModule("prediction", function ()
  local heals = {}
  local ress = {}
  local events = {}

  pfUI.prediction = CreateFrame("Frame")
  pfUI.prediction:RegisterEvent("UNIT_HEALTH")
  pfUI.prediction:RegisterEvent("CHAT_MSG_ADDON")
  pfUI.prediction:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.prediction:SetScript("OnEvent", function()
    if event == "CHAT_MSG_ADDON" and arg1 == "HealComm" then
      this:ParseChatMessage(arg4, arg2)
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

  function pfUI.prediction:ParseChatMessage(sender, msg)
    if msg == "Healstop" or msg == "GrpHealstop" then
      pfUI.prediction:HealStop(sender)
      return
    elseif msg == "Resurrection/stop/" then
      pfUI.prediction:RessStop(sender)
      return
    end

    local message = {strsplit("/", msg)}

    if message[1] and ( message[1] == "GrpHealdelay" or message[1] == "Healdelay" ) then
      pfUI.prediction:HealDelay(sender, message[2])
      return
    end

    if message[1] and message[1] == "Heal" and message[2] then
      pfUI.prediction:Heal(sender, message[2], message[3], message[4])
      return
    end

    if message[1] and message[1] == "GrpHeal" and message[2] then
      for i=4,8 do
        if message[i] then
          pfUI.prediction:Heal(sender, message[i], message[2], message[3])
        end
      end
      return
    end

    if message[1] and message[1] == "Resurrection" and message[2] then
      pfUI.prediction:Ress(sender, message[2])
      return
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
    OVERHEALPERCENT = OVERHEALPERCENT or 20

    for id, frame in pairs(_G.pfUI.uf.frames) do
      if frame:IsVisible() and frame.label and frame.id then
        local unit = frame.label .. frame.id
        local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)

        if UnitName(unit) == name then
          if ress and UnitIsDeadOrGhost(unit) then
            frame.ressIcon:Show()
          elseif heal and heal > 0 and (health < maxHealth or OVERHEALPERCENT > 0 ) then
            local width = frame.config.width
            local height = frame.config.height

            if frame.config.verticalbar == "0" then
              local healthWidth = width * (health / maxHealth)
              local incWidth = width * heal / maxHealth
              if healthWidth + incWidth > width * (1+(OVERHEALPERCENT/100)) then
                incWidth = width * (1+OVERHEALPERCENT/100) - healthWidth
              end

              if frame.config.invert_healthbar == "1" then
                frame.incHeal:SetWidth(incWidth)
              else
                frame.incHeal:SetWidth(incWidth + healthWidth)
              end
            else
              local healthHeight = height * (health / maxHealth)
              local incHeight = height * heal / maxHealth
              if healthHeight + incHeight > height * (1+(OVERHEALPERCENT/100)) then
                incHeight = height * (1+OVERHEALPERCENT/100) - healthHeight
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

  local healedselfother = SanitizePattern(HEALEDSELFOTHER)
  local healedselfself = SanitizePattern(HEALEDSELFSELF)
  local healedcritselfother = SanitizePattern(HEALEDCRITSELFOTHER)
  local healedcritselfself = SanitizePattern(HEALEDCRITSELFSELF)
  local spell_queue = { "DUMMY", "DUMMYRank 9", "TARGET" }

  local realm = GetRealmName()
  local player = UnitName("player")
  pfUI_cache["prediction"] = pfUI_cache["prediction"] or {}
  pfUI_cache["prediction"][realm] = pfUI_cache["prediction"][realm] or {}
  pfUI_cache["prediction"][realm][player] = pfUI_cache["prediction"][realm][player] or {}
  pfUI_cache["prediction"][realm][player]["heals"] = pfUI_cache["prediction"][realm][player]["heals"] or {}
  local cache = pfUI_cache["prediction"][realm][player]["heals"]

  -- Gather Data by User Actions
  hooksecurefunc("CastSpell", function(id, bookType)
    if not pfUI.prediction.sender.enabled then return end
    local effect, rank = libspell.GetSpellInfo(id, bookType)
    spell_queue[1] = effect
    spell_queue[2] = effect.. ( rank or "" )
    spell_queue[3] = UnitName("target") and UnitCanAssist("player", "target") and UnitName("target") or UnitName("player")
  end, true)

  hooksecurefunc("CastSpellByName", function(effect, target)
    if not pfUI.prediction.sender.enabled then return end
    local effect, rank = libspell.GetSpellInfo(effect)
    spell_queue[1] = effect
    spell_queue[2] = effect.. ( rank or "" )
    spell_queue[3] = UnitName("target") and UnitCanAssist("player", "target") and UnitName("target") or UnitName("player")
  end, true)

  local scanner = libtipscan:GetScanner("prediction")
  hooksecurefunc("UseAction", function(slot, target, button)
    if not pfUI.prediction.sender.enabled then return end
    if GetActionText(slot) or not IsCurrentAction(slot) then return end
    scanner:SetAction(slot)
    local effect, rank = scanner:Line(1)
    spell_queue[1] = effect
    spell_queue[2] = effect.. ( rank or "" )
    spell_queue[3] = UnitName("target") and UnitCanAssist("player", "target") and UnitName("target") or UnitName("player")
  end, true)

  pfUI.prediction.sender = CreateFrame("Frame", "pfPredictionSender", UIParent)
  pfUI.prediction.sender.enabled = true
  pfUI.prediction.sender.SendHealCommMsg = function(self, msg)
    SendAddonMessage("HealComm", msg, "RAID")
    SendAddonMessage("HealComm", msg, "BATTLEGROUND")
  end

  pfUI.prediction.sender:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
  pfUI.prediction.sender:RegisterEvent("SPELLCAST_START")
  pfUI.prediction.sender:RegisterEvent("SPELLCAST_STOP")
  pfUI.prediction.sender:RegisterEvent("SPELLCAST_FAILED")
  pfUI.prediction.sender:RegisterEvent("SPELLCAST_INTERRUPTED")
  pfUI.prediction.sender:RegisterEvent("SPELLCAST_DELAYED")
  pfUI.prediction.sender:SetScript("OnEvent", function()
    if event == "CHAT_MSG_SPELL_SELF_BUFF" then
      -- "Your %s heals %s for %d.";
      for spell, _, heal in gfind(arg1, healedselfother) do
        if spell == spell_queue[1] then cache[spell_queue[2]] = tonumber(heal) end
        return
      end

      -- "Your %s heals you for %d."
      for spell, heal in gfind(arg1, healedselfself) do
        if spell == spell_queue[1] then cache[spell_queue[2]] = tonumber(heal) end
        return
      end

      -- "Your %s critically heals %s for %d."
      for spell, heal in gfind(arg1, healedcritselfother) do
        if spell == spell_queue[1] and not cache[spell_queue[2]] then cache[spell_queue[2]] = tonumber(heal)*2/3 end
        return
      end

      -- "Your %s critically heals you for %d."
      for spell, _, heal in gfind(arg1, healedcritselfself) do
        if spell == spell_queue[1] and not cache[spell_queue[2]] then cache[spell_queue[2]] = tonumber(heal)*2/3 end
        return
      end
    elseif event == "SPELLCAST_START" then
      if spell_queue[1] == arg1 and cache[spell_queue[2]] then
        local sender = player
        local target = spell_queue[3]
        local amount = cache[spell_queue[2]]
        local casttime = arg2

        pfUI.prediction:Heal(player, target, amount, casttime)
        pfUI.prediction.sender:SendHealCommMsg("Heal/" .. target .. "/" .. amount .. "/" .. casttime .. "/")
        pfUI.prediction.sender.healing = true
      elseif spell_queue[1] == arg1 and L["resurrections"][arg1] then
        pfUI.prediction:Ress(player, spell_queue[3])
        pfUI.prediction.sender:SendHealCommMsg("Resurrection/" .. spell_queue[3] .. "/start/")
        pfUI.prediction.sender.resurrecting = true
      end
    elseif event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
      if pfUI.prediction.sender.healing then
        pfUI.prediction:HealStop(player)
        pfUI.prediction.sender:SendHealCommMsg("HealStop")
        pfUI.prediction.sender.healing = nil
      elseif pfUI.prediction.sender.resurrecting then
        pfUI.prediction:RessStop(player)
        pfUI.prediction.sender:SendHealCommMsg("Resurrection/stop/")
        pfUI.prediction.sender.resurrecting = nil
      end
    elseif event =="SPELLCAST_DELAYED" then
      if pfUI.prediction.sender.healing then
        pfUI.prediction:HealDelay(player, arg1)
        pfUI.prediction.sender:SendHealCommMsg("Healdelay/" .. arg1 .. "/")
      end
    elseif event == "SPELLCAST_STOP" then
      pfUI.prediction:HealStop(player)
    end
  end)
end)
