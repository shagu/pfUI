pfUI:RegisterModule("prediction", function ()
  local heals = {}
  local ress = {}

  pfUI.prediction = CreateFrame("Frame")
  pfUI.prediction:RegisterEvent("COMBAT_TEXT_UPDATE")
  pfUI.prediction:RegisterEvent("UNIT_COMBAT")
  pfUI.prediction:RegisterEvent("UNIT_HEALTH")
  pfUI.prediction:RegisterEvent("CHAT_MSG_ADDON")
  pfUI.prediction:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.prediction:RegisterEvent("SPELLCAST_STOP")

  pfUI.prediction:SetScript("OnEvent", function()
    if event == "CHAT_MSG_ADDON" and arg1 == "HealComm" then
      local channel = arg3
      local sender = arg4

      if arg2 == "Healstop" then
        pfUI.prediction:HealStop(sender)
        return
      elseif arg2 == "GrpHealstop" then
        pfUI.prediction:HealStop(sender)
        return
      elseif arg2 == "Resurrection/stop/" then
        pfUI.prediction:RessStop(sender)
        return
      end

      local _, _, evtype, target, amount, duration  = string.find(arg2, '(Heal)/(%a+)/(%d+)/(%d+)/')
      if evtype then
        heals[target] = heals[target] or {}
        heals[target][sender] = { amount, duration + GetTime() }
        pfUI.prediction:TriggerUpdate(target)
        return
      end

      local _, _, evtype, amount, duration, targets = string.find(arg2, '(GrpHeal)/(%d+)/(%d+)/(.+)/')
      if evtype then
        for _, target in pairs({strsplit("/", targets)}) do
          heals[target] = heals[target] or {}
          heals[target][sender] = { amount, duration + GetTime() }
          pfUI.prediction:TriggerUpdate(target)
        end
        return
      end

      local _, _, evtype, target  = string.find(arg2, '(Resurrection)/(%a+)/(start)/')
      if evtype then
        ress[target] = ress[target] or {}
        ress[target][sender] = true
        pfUI.prediction:TriggerUpdate(target)
        return
      end
    elseif event == "COMBAT_TEXT_UPDATE" and arg1 == "HEAL" then
      pfUI.prediction:HealStop(arg2)
    elseif event == "UNIT_COMBAT" and arg2 == "HEAL" then
      pfUI.prediction:CleanHeals()
    elseif event == "UNIT_HEALTH" then
      local name = UnitName(arg1)
      if ress[name] and not UnitIsDeadOrGhost(arg1) then
        ress[UnitName(arg1)] = nil
        pfUI.prediction:TriggerUpdate(name)
      end

      if heals[name] then
        pfUI.prediction:TriggerUpdate(name)
      end
    elseif event == "SPELLCAST_STOP" then
      pfUI.prediction:HealStop(UnitName("player"))
    elseif event == "PLAYER_TARGET_CHANGED" then
      if pfUI.uf and pfUI.uf.target then
        pfUI.prediction:DrawPrediction("target", pfUI.uf.target)
      end
    end
  end)

  pfUI.prediction.scanner = CreateFrame('GameTooltip', "pfPredictionScanner", UIParent, "GameTooltipTemplate")
  pfUI.prediction.scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

  function pfUI.prediction:CleanHeals()
    for ttarget, t in pairs(heals) do
      for tsender in pairs(heals[ttarget]) do
        if heals[ttarget][tsender][2] >= GetTime() then
          heals[ttarget][tsender] = nil
          pfUI.prediction:TriggerUpdate(ttarget)
        end
      end
    end
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

  function pfUI.prediction:GetHeal(target)
    local sumheal = 0
    if not heals[target] then
      return sumheal
    else
      for sender, amount in pairs(heals[target]) do
        sumheal = sumheal + amount[1]
      end
    end
    return sumheal
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
    for id, frame in _G.pfUI.uf.frames do
      if frame:IsVisible() and UnitName(frame.label .. frame.id) == target then
        pfUI.prediction:DrawPrediction(frame.label .. frame.id, frame)
      end
    end
  end

  function pfUI.prediction:DrawPrediction(unit, frame)
    OVERHEALPERCENT = OVERHEALPERCENT or 20
    if not frame then return end
    local healed = pfUI.prediction:GetHeal(UnitName(unit))
    local ressed = pfUI.prediction:GetRess(UnitName(unit))

    if ressed and UnitIsDeadOrGhost(unit) then
      frame.ressIcon:Show()
      return
    else
      frame.ressIcon:Hide()
    end

    local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
    if( healed > 0 and (health < maxHealth or OVERHEALPERCENT > 0 )) then
      frame.incHeal:Show()
      frame.incHeal:SetFrameStrata("BACKGROUND")
      frame.incHeal:ClearAllPoints()

      local width = frame.hp.bar:GetWidth() / frame.hp.bar:GetEffectiveScale()
      local height = frame.hp.bar:GetHeight() / frame.hp.bar:GetEffectiveScale()

      if frame.config.verticalbar == "0" then
        local healthWidth = width * (health / maxHealth)
        local incWidth = width * healed / maxHealth
        if healthWidth + incWidth > width * (1+(OVERHEALPERCENT/100)) then
          incWidth = width * (1+OVERHEALPERCENT/100) - healthWidth
        end

        frame.incHeal:SetPoint("TOPLEFT", frame.hp.bar, "TOPLEFT", 0, 0)
        frame.incHeal:SetHeight(height)
        frame.incHeal:SetWidth(incWidth + healthWidth)

        if frame.config.invert_healthbar == "1" then
          frame.incHeal:SetWidth(incWidth)
          frame.incHeal:SetFrameStrata("HIGH")
        end
      else
        local healthHeight = height * (health / maxHealth)
        local incHeight = height * healed / maxHealth
        if healthHeight + incHeight > height * (1+(OVERHEALPERCENT/100)) then
          incHeight = height * (1+OVERHEALPERCENT/100) - healthHeight
        end

        frame.incHeal:SetPoint("BOTTOM", frame.hp.bar, "BOTTOM", 0, 0)
        frame.incHeal:SetWidth(width)
        frame.incHeal:SetHeight(incHeight + healthHeight)

        if frame.config.invert_healthbar == "1" then
          frame.incHeal:SetHeight(incHeight)
          frame.incHeal:SetFrameStrata("HIGH")
        end
      end
    else
      frame.incHeal:Hide()
    end
  end
end)
