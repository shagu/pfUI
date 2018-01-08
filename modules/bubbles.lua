pfUI:RegisterModule("bubbles", function ()

  local alpha = tonumber(C.chat.bubbles.alpha)

  SetCVar("chatBubbles", tonumber(C.chat.bubbles.chat))
  SetCVar("chatBubblesParty", tonumber(C.chat.bubbles.party))

  pfUI.bubbles = CreateFrame("Frame", "pfChatBubbles", UIParent)
  pfUI.bubbles:RegisterEvent("CHAT_MSG_SAY")
  pfUI.bubbles:RegisterEvent("CHAT_MSG_YELL")
  pfUI.bubbles:RegisterEvent("CHAT_MSG_PARTY")
  pfUI.bubbles:RegisterEvent("CHAT_MSG_PARTY_LEADER")
  pfUI.bubbles:RegisterEvent("CHAT_MSG_MONSTER_SAY")
  pfUI.bubbles:RegisterEvent("CHAT_MSG_MONSTER_YELL")
  pfUI.bubbles:RegisterEvent("CHAT_MSG_MONSTER_PARTY")

  pfUI.bubbles:SetScript("OnEvent", function()
    pfUI.bubbles:SetScript("OnUpdate", pfUI.bubbles.ScanBubbles)
  end)

  function pfUI.bubbles:IsBubble(f)
      if f:GetName() then return end
      if not f:GetRegions() then return end
      return f:GetRegions():GetTexture() == "Interface\\Tooltips\\ChatBubble-Background"
  end

  function pfUI.bubbles:ProcessBubble(f)
    f.text:Hide()
    f.text:SetFont(pfUI.font_default, tonumber(C.global.font_size) * UIParent:GetScale(), "OUTLINE")
    local r,g,b,a = f.text:GetTextColor()
    f.frame.text:SetText(f.text:GetText())
    f.frame.text:SetTextColor(r,g,b,a)
    f.frame.backdrop:SetBackdropBorderColor(r,g,b,a)
  end

  function pfUI.bubbles:ScanBubbles()
    local childs = { WorldFrame:GetChildren() }
    for _, f in pairs(childs) do
        if not f.frame and pfUI.bubbles:IsBubble(f) then
          local textures = {f:GetRegions()}
          for _, object in pairs(textures) do
            if object:GetObjectType() == "Texture" then
              object:SetTexture('')
            elseif object:GetObjectType() == 'FontString' then
              f.text = object
            end
          end

          f.frame = CreateFrame("Frame", nil, f)
          f.frame:SetScale(UIParent:GetScale())
          f.frame:SetAllPoints(f)

          f.frame.text = f.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
          f.frame.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
          f.frame.text:SetJustifyH("CENTER")
          f.frame.text:SetJustifyV("CENTER")
          f.frame.text:SetAllPoints(f.frame)

          CreateBackdrop(f.frame, nil, nil, alpha)
          f.frame.backdrop:SetPoint("TOPLEFT", f, "TOPLEFT", -10, -10)
          f.frame.backdrop:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 10, 10)

          pfUI.bubbles:ProcessBubble(f)

          f:SetScript("OnShow", function()
            pfUI.bubbles:ProcessBubble(this)
          end)
        end
    end

    pfUI.bubbles:SetScript("OnUpdate", nil)
  end
end)
