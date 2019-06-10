pfUI:RegisterModule("gm", "vanilla", function ()
  -- do not load by default
  if C.gm.disable == "1" then return end

  -- core specific commands
  pfUI.gm_server = {
    ["elysium"] = {
      ["GM_PLAYERINFO"]   = { ".pinfo #PLAYER", "Player Info" },
      ["GM_GO"]           = { ".go #PLAYER", "Goto" },
      ["GM_APPEAR"]       = { ".goname #PLAYER", "Appear" },
      ["GM_SUMMON"]       = { ".namego #PLAYER", "Summon" },
      ["GM_RECALL"]       = { ".recall #PLAYER", "Recall" },
      ["GM_KICK"]         = { ".kick #PLAYER", "Kick" },
      ["GM_POSSES"]       = { ".posses", "Posses" },
      ["GM_MUTE"]         = { ".mute #PLAYER 5", "Mute 5 Minutes" },
      ["GM_UNMUTE"]       = { ".unmute #PLAYER", "Unmute" },
      ["GM_FREEZE"]       = { ".freez #PLAYER", "Freeze" },
      ["GM_UNFREEZE"]     = { ".unaura 29826", "Unfreeze" },
      ["GM_FLY"]          = { ".gm fly on", "Flying Mode" },
      ["GM_SPEED_BOOST"]  = { ".modify aspeed 5", "Speed Boost" },
      ["GM_SPEED_MAX"]    = { ".modify aspeed 10", "Max Speed" },
      ["GM_SPEED_RESET"]  = { ".modify aspeed 1", "Reset Speed" },
      ["GM_TICKET_LIST"]  = { ".ticket list", "List Tickets" },
    },
  }

  UnitPopupButtons["GM_HEADER"] = { text = TEXT("\n"), dist = 0 }
  for label, data in pairs(pfUI.gm_server[C.gm.server]) do
    local displayname = data[2]
    UnitPopupButtons[label] = { text = TEXT("|cffaaccff" .. displayname), dist = 0 }
  end

  -- chat dropdown
  table.insert(UnitPopupMenus["FRIEND"], "GM_HEADER")
  table.insert(UnitPopupMenus["FRIEND"], "GM_PLAYERINFO")
  table.insert(UnitPopupMenus["FRIEND"], "GM_GO")
  table.insert(UnitPopupMenus["FRIEND"], "GM_APPEAR")
  table.insert(UnitPopupMenus["FRIEND"], "GM_SUMMON")
  table.insert(UnitPopupMenus["FRIEND"], "GM_RECALL")
  table.insert(UnitPopupMenus["FRIEND"], "GM_MUTE")
  table.insert(UnitPopupMenus["FRIEND"], "GM_UNMUTE")
  table.insert(UnitPopupMenus["FRIEND"], "GM_KICK")

  -- player dropdown
  table.insert(UnitPopupMenus["SELF"], "GM_HEADER")
  table.insert(UnitPopupMenus["SELF"], "GM_FLY")
  table.insert(UnitPopupMenus["SELF"], "GM_SPEED_BOOST")
  table.insert(UnitPopupMenus["SELF"], "GM_SPEED_MAX")
  table.insert(UnitPopupMenus["SELF"], "GM_SPEED_RESET")
  table.insert(UnitPopupMenus["SELF"], "GM_RECALL")
  table.insert(UnitPopupMenus["SELF"], "GM_TICKET_LIST")

  -- player target dropdown
  table.insert(UnitPopupMenus["PLAYER"], "GM_HEADER")
  table.insert(UnitPopupMenus["PLAYER"], "GM_PLAYERINFO")
  table.insert(UnitPopupMenus["PLAYER"], "GM_POSSES")
  table.insert(UnitPopupMenus["PLAYER"], "GM_RECALL")
  table.insert(UnitPopupMenus["PLAYER"], "GM_FREEZE")
  table.insert(UnitPopupMenus["PLAYER"], "GM_UNFREEZE")
  table.insert(UnitPopupMenus["PLAYER"], "GM_MUTE")
  table.insert(UnitPopupMenus["PLAYER"], "GM_UNMUTE")
  table.insert(UnitPopupMenus["PLAYER"], "GM_KICK")

  -- party member dropdown
  table.insert(UnitPopupMenus["PARTY"], "GM_HEADER")
  table.insert(UnitPopupMenus["PARTY"], "GM_PLAYERINFO")
  table.insert(UnitPopupMenus["PARTY"], "GM_GO")
  table.insert(UnitPopupMenus["PARTY"], "GM_APPEAR")
  table.insert(UnitPopupMenus["PARTY"], "GM_SUMMON")
  table.insert(UnitPopupMenus["PARTY"], "GM_RECALL")
  table.insert(UnitPopupMenus["PARTY"], "GM_MUTE")
  table.insert(UnitPopupMenus["PARTY"], "GM_UNMUTE")
  table.insert(UnitPopupMenus["PARTY"], "GM_KICK")

  -- raid member dropdown
  table.insert(UnitPopupMenus["RAID"], "GM_HEADER")
  table.insert(UnitPopupMenus["RAID"], "GM_PLAYERINFO")
  table.insert(UnitPopupMenus["RAID"], "GM_GO")
  table.insert(UnitPopupMenus["RAID"], "GM_APPEAR")
  table.insert(UnitPopupMenus["RAID"], "GM_SUMMON")
  table.insert(UnitPopupMenus["RAID"], "GM_RECALL")
  table.insert(UnitPopupMenus["RAID"], "GM_MUTE")
  table.insert(UnitPopupMenus["RAID"], "GM_UNMUTE")
  table.insert(UnitPopupMenus["RAID"], "GM_KICK")

  -- pet dropdown
  -- table.insert(UnitPopupMenus["PET"], "GM_HEADER")

  hooksecurefunc("UnitPopup_OnClick", function()
   local dropdownFrame = _G[UIDROPDOWNMENU_INIT_MENU]
   local button = this.value
   local unit = dropdownFrame.unit
   local name = dropdownFrame.name
   local server = dropdownFrame.server

   for label, data in pairs(pfUI.gm_server[C.gm.server]) do
     local command = data[1]
     if button == label then

       if name then
         command = string.gsub(command, "#PLAYER", name)
         command = string.gsub(command, CHAT_FLAG_GM, "")
       end

       SendChatMessage(command)
     end
   end
  end)
end)
