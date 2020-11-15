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

  -- add /use and /equip to the macro api
  _G.SLASH_PFUSE1, _G.SLASH_PFUSE2, _G.SLASH_PFUSE3, _G.SLASH_PFUSE4 = '/use', '/pfuse', '/equip', '/pfequip'
  function _G.SlashCmdList.PFUSE(msg)
    if not msg or msg == "" then return end
    local bag, slot = FindItem(msg)
    if bag and slot then
      UseContainerItem(bag, slot)
    end
  end
end)
