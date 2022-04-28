pfUI:RegisterModule("macrotweak", "vanilla", function ()
  -- do not write macro calls into chat input history
  if ChatFrameEditBox._AddHistoryLine then
    local userinput
    ChatFrameEditBox._AddHistoryLine = ChatFrameEditBox.AddHistoryLine
    ChatFrameEditBox.AddHistoryLine = function(self, text)
      if not userinput and text and string.find(text, "^/run(.+)") then return end
      if not userinput and string.find(text, "^/script(.+)") then return end
      if not userinput and string.find(text, "^/cast(.+)") then return end
      ChatFrameEditBox._AddHistoryLine(self, text)
    end

    local OnEnter = ChatFrameEditBox:GetScript("OnEnterPressed")
    ChatFrameEditBox:SetScript("OnEnterPressed", function(a1,a2,a3,a4)
      userinput = true
      OnEnter(a1,a2,a3,a4)
      userinput = nil
    end)
  end

  -- make sure #showtooltip inside macros won't be sent
  local hookSendChatMessage = SendChatMessage
  function _G.SendChatMessage(msg, ...)
    if msg and string.find(msg, "^#showtooltip ") then return end
    hookSendChatMessage(msg, unpack(arg))
  end

  -- add /use and /equip to the macro api:
  -- https://wowwiki.fandom.com/wiki/Making_a_macro
  -- supported arguments:
  --   /use <itemname>
  --   /use <inventory slot>
  --   /use <bag> <slot>
  pfUI.api.RegisterSlashCommand("PFUSE", { "/equip" , "/use", "/pfequip", "/pfuse" }, function (msg)
    if not msg or msg == "" then return end
    local bag, slot, _
    if string.find(msg, "%d+%s+%d+") then
      _, _, bag, slot = string.find(msg, "(%d+)%s+(%d+)")
    elseif string.find(msg, "%d+") then
      _, _, slot = string.find(msg, "(%d+)")
    else
      bag, slot = FindItem(msg)
    end

    if bag and slot then
      UseContainerItem(bag, slot)
    elseif not bag and slot then
      UseInventoryItem(slot)
    end
  end)
end)
