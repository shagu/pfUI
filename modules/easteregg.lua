pfUI:RegisterModule("easteregg", function ()
  if date("%m%d") == "1224" or date("%m%d") == "1225" then
    -- merry x-mas!
    local title = (UnitFactionGroup("player") == "Horde") and PVP_RANK_18_0 or PVP_RANK_18_1

    local c1 = "|cffffaaaa"
    local c2 = "|cffffbbaa"
    local c3 = "|cffffccaa"
    local c4 = "|cffffddaa"
    local c5 = "|cffffeeaa"
    local c6 = "|cffffffaa"
    local c7 = "|cffeeffaa"
    local c8 = "|cffddffaa"
    local c9 = "|cffccffaa"
    local cA = "|cffbbffaa"
    local cB = "|cffaaffaa"
    local cC = "|cff33ffcc"

    _G.CHAT_FLAG_AFK        = title .. " "
    _G.DEFAULT_AFK_MESSAGE  = c1 .. "M" .. c2 .. "e" .. c3 .. "r" ..
                              c4 .. "r" .. c5 .. "y" .. c6 .. "  " ..
                              c7 .. "X" .. c8 .. "-" .. c9 .. "M" ..
                              cA .. "a" .. cB .. "s" .. cC .. "!"
    _G.MARKED_AFK           = "You are now " .. title .. "."
    _G.MARKED_AFK_MESSAGE   = "You are now " .. title .. ": %s"
    _G.CLEARED_AFK          = "You are no longer " .. title .. "."
  end
end)
