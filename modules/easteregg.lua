pfUI:RegisterModule("easteregg", function ()
  if date("%m%d") == "1224" or date("%m%d") == "1225" then
    -- merry x-mas!
    local title = (UnitFactionGroup("player") == "Horde") and PVP_RANK_18_0 or PVP_RANK_18_1
    local oldflag = _G.CHAT_FLAG_AFK

    local pvpking = CreateFrame("Frame", "pfPvPKing", UIParent)
    pvpking:Hide()

    pvpking:RegisterEvent("CHAT_MSG_SYSTEM")
    pvpking:SetScript("OnEvent", function()
      if strfind(arg1, _G.MARKED_AFK) or strfind(arg1, _G.MARKED_AFK_MESSAGE) then
        _G.CHAT_FLAG_AFK = title .. " "
        this.time = GetTime()
        this:Show()
      end
    end)

    pvpking:SetScript("OnUpdate", function()
      if this.time + 1 < GetTime() then
        _G.CHAT_FLAG_AFK = oldflag
        this:Hide()
      end
    end)

    _G.MARKED_AFK           = "|cff33ffccShagu|cffffffff wishes you a merry christmas. You are now |cff33ffcc" .. title .. "|cffffffff. Thanks for using |cff33ffccpf|cffffffffUI|cffffffff!|r"
    _G.MARKED_AFK_MESSAGE   = "|cff33ffccShagu|cffffffff wishes you a merry christmas. You are now |cff33ffcc" .. title .. "|cffffffff. Thanks for using |cff33ffccpf|cffffffffUI|cffffffff!|r: %s"
    _G.CLEARED_AFK          = "You are no longer |cff33ffcc" .. title .. "|r."
  end
end)
