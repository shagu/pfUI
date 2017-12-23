pfUI:RegisterModule("easteregg", function ()
  if date("%m%d") == "1224" or date("%m%d") == "1225" then
    -- merry x-mas!
    local title = (UnitFactionGroup("player") == "Horde") and PVP_RANK_18_0 or PVP_RANK_18_1

    _G.CHAT_FLAG_AFK        = title .. " "
    _G.MARKED_AFK           = "|cff33ffccpf|cffffffffUI|r wishes you a merry christmas, |cff33ffcc" .. title .. "|r."
    _G.MARKED_AFK_MESSAGE   = "|cff33ffccpf|cffffffffUI|r wishes you a merry christmas, |cff33ffcc" .. title .. "|r: %s"
    _G.CLEARED_AFK          = "You are no longer |cff33ffcc" .. title .. "|r."
  end
end)
