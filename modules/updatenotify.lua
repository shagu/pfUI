pfUI:RegisterModule("updatenotify", function ()
  local alreadyshown = false
  local localversion  = tonumber(pfUI.version.major*10000 + pfUI.version.minor*100 + pfUI.version.fix)
  local remoteversion = tonumber(pfUI_init.updateavailable) or 0

  pfUI.updater = CreateFrame("Frame")
  pfUI.updater:RegisterEvent("CHAT_MSG_ADDON")
  pfUI.updater:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.updater:SetScript("OnEvent", function()
    if event == "CHAT_MSG_ADDON" and arg1 == "pfUI" then
      local v, remoteversion = pfUI.api.strsplit(":", arg2)
      local remoteversion = tonumber(remoteversion)
      if v == "VERSION" and remoteversion then
        if remoteversion > localversion then
          pfUI_init.updateavailable = remoteversion
        end
      end
    end

    if event == "PLAYER_ENTERING_WORLD" then
      if not alreadyshown and localversion < remoteversion then
        DEFAULT_CHAT_FRAME:AddMessage(T["|cff33ffccpf|rUI: New version available! Have a look at http://shagu.org !"])
        DEFAULT_CHAT_FRAME:AddMessage(T["|cffddddddIt's always safe to upgrade |cff33ffccpf|rUI. |cffddddddYou won't lose any of your configuration."])
        pfUI_init.updateavailable = localversion
        alreadyshown = true
      end

      for _, chan in pairs({ "BATTLEGROUND", "RAID", "GUILD" }) do
        SendAddonMessage("pfUI", "VERSION:" .. localversion, chan)
      end
    end
  end)
end)
