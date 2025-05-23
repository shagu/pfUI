pfUI:RegisterModule("combopoints", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()

  -- Hide Blizzard combo point frame and unregister all events to prevent it from popping up again
  ComboFrame:Hide()
  ComboFrame:UnregisterAllEvents()

  local _, class = UnitClass("player")
  local combo_width = C["unitframes"]["combowidth"]
  local combo_height = C["unitframes"]["comboheight"]
  pfUI.combopoints = {}

  for point = 1, 5 do
    pfUI.combopoints[point] = CreateFrame("Frame", "pfCombo" .. point, UIParent)
    pfUI.combopoints[point]:SetFrameStrata("HIGH")
    pfUI.combopoints[point]:SetWidth(combo_width)
    pfUI.combopoints[point]:SetHeight(combo_height)
    pfUI.combopoints[point]:Hide()

    if pfUI.uf.target then
      pfUI.combopoints[point]:SetPoint("TOPLEFT", pfUI.uf.target, "TOPRIGHT", border*3, -(point - 1) * (combo_height + border*3))
    else
      pfUI.combopoints[point]:SetPoint("CENTER", UIParent, "CENTER", (point - 3) * (combo_width + border*3), 10 )
    end

    pfUI.combopoints[point].tex = pfUI.combopoints[point]:CreateTexture("OVERLAY")
    pfUI.combopoints[point].tex:SetAllPoints(pfUI.combopoints[point])

    if point < 3 then
      pfUI.combopoints[point].tex:SetTexture(1, .3, .3, .75)
    elseif point < 4 then
      pfUI.combopoints[point].tex:SetTexture(1, 1, .3, .75)
    else
      pfUI.combopoints[point].tex:SetTexture(.3, 1, .3, .75)
    end

    UpdateMovable(pfUI.combopoints[point])
    CreateBackdrop(pfUI.combopoints[point])
    CreateBackdropShadow(pfUI.combopoints[point])
  end

  function pfUI.combopoints:DisplayNum(num)
    for point=1, num do
      pfUI.combopoints[point]:Show()
    end

    for point=num+1, 5 do
      pfUI.combopoints[point]:Hide()
    end
  end

  -- combo
  if class == "DRUID" or class == "ROGUE" then
    local combo = CreateFrame("Frame")
    combo:RegisterEvent("UNIT_COMBO_POINTS")
    combo:RegisterEvent("PLAYER_COMBO_POINTS")
    combo:RegisterEvent("PLAYER_TARGET_CHANGED")
    combo:RegisterEvent("PLAYER_ENTERING_WORLD")
    combo:SetScript("OnEvent", function()
      pfUI.combopoints:DisplayNum(GetComboPoints("target"))
    end)

  -- reck
  elseif class == "PALADIN" then
    local reck = CreateFrame("Frame")
    reck:RegisterEvent("CHARACTER_POINTS_CHANGED")
    reck:RegisterEvent("PLAYER_DEAD")
    reck:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
    reck:RegisterEvent("CHAT_MSG_COMBAT_SELF_CRITS")
    reck:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
    reck:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
    reck:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS")

    local COMBATHITCRITOTHERSELF = SanitizePattern(COMBATHITCRITOTHERSELF)
    local COMBATHITCRITSCHOOLOTHERSELF = SanitizePattern(COMBATHITCRITSCHOOLOTHERSELF)

    reck:SetScript("OnEvent", function()
      if not this.rank or event == "CHARACTER_POINTS_CHANGED" then
        _,_,_,_,this.rank = GetTalentInfo(2,13)
      end

      if event == "PLAYER_DEAD" or event == "CHAT_MSG_COMBAT_SELF_HITS" or event == "CHAT_MSG_COMBAT_SELF_CRITS" or event == "CHAT_MSG_COMBAT_SELF_MISSES" then
        this.stacks = 0
        pfUI.combopoints:DisplayNum(0)
      elseif arg1 and this.rank and this.rank == 5 and this.stacks and this.stacks < 4 then
        if strfind(arg1, COMBATHITCRITOTHERSELF) or strfind(arg1, COMBATHITCRITSCHOOLOTHERSELF) then
          this.stacks = this.stacks + 1
          pfUI.combopoints:DisplayNum(this.stacks)
        end
      end
    end)
  end
end)
