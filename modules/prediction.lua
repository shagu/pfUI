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

    for id, frame in _G.pfUI.uf.frames do
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
end)
