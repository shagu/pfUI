pfUI:RegisterModule("whisperproxy", "vanilla", function ()
  if not pfUI.chat then return end

  local proxy = CreateFrame("Button", "pfWhisperProxy", pfUI.chat.left.panelTop)
  proxy:SetPoint("TOPRIGHT", pfUI.chat.left, "TOPRIGHT", -22, -5)
  proxy:SetWidth(12)
  proxy:SetHeight(12)
  proxy.tex = proxy:CreateTexture(nil, "OVERLAY")
  proxy.tex:SetAllPoints()
  proxy.tex:SetTexture(pfUI.media["img:proxy"])
  proxy.tex:SetVertexColor(.5,.5,.5,1)
  proxy:SetAlpha(0.4)

  proxy.enabled = false
  proxy.forwardto = ""

  proxy:SetScript("OnEnter", function()
    this:SetAlpha(1)
  end)

  proxy:SetScript("OnLeave", function()
    this:SetAlpha(.4)
  end)

  local function ToggleProxy()
    if proxy.enabled == true then
      -- redirect inactive
      proxy.enabled = false
      proxy.tex:SetVertexColor(.5,.5,.5,1)
      DEFAULT_CHAT_FRAME:AddMessage(T["Messages are no longer forwarded to:"] .. " |cff33ffcc" .. proxy.forwardto)
    elseif proxy.forwardto ~= "" then
      -- redirect active
      proxy.enabled = true
      proxy.tex:SetVertexColor(1,.8,0,1)
      DEFAULT_CHAT_FRAME:AddMessage(T["All messages will be forwarded to:"] .. " |cff33ffcc" .. proxy.forwardto)
    end
  end

  local proxyOK = { OKAY, function()
    pfUI.chat.whisperproxy.forwardto = this:GetParent().input:GetText()
    ToggleProxy()
  end }

  local proxyCancel = { CANCEL, function()
    pfUI.chat.whisperproxy.forwardto = ""
  end }

  proxy:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  proxy:SetScript("OnClick", function()
    if proxy.forwardto == "" or arg1 == "RightButton" then
      CreateQuestionDialog(T["Please enter a name of a character who should receive your whispers:"], proxyOK, proxyCancel, true)
    else
      ToggleProxy()
    end
  end)

  proxy:RegisterEvent("CHAT_MSG_WHISPER")
  proxy:SetScript("OnEvent", function()
    local forwardto = proxy.forwardto
    if proxy.enabled == false then return end

    if arg2 ~= UnitName("player") and arg2 ~= forwardto and forwardto ~= UnitName("player") then
      SendChatMessage("[" .. arg2 .. "]: " .. arg1, "WHISPER", nil, forwardto)
    end

    if strlower(arg2) == strlower(forwardto) then
      local isForward, _, name, message = string.find(arg1, "(.*): (.*)")
      if isForward then
        SendChatMessage(message, "WHISPER", nil, name)
        SendChatMessage("-> " .. name, "WHISPER", nil, forwardto)
      end
    end
  end)

  -- attach module to the pfUI tree
  pfUI.chat.whisperproxy = proxy
end)
