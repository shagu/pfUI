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
          f.frame.backdrop:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -10)
          f.frame.backdrop:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 10)

          f.text:Hide()
          local r,g,b,a = f.text:GetTextColor()
          f.frame.text:SetText(f.text:GetText())
          f.frame.text:SetTextColor(r,g,b,a)
          f.frame.backdrop:SetBackdropBorderColor(r,g,b,a)

          f:SetScript("OnShow", function()
            this.text:Hide()
            local r,g,b,a = this.text:GetTextColor()
            this.frame.text:SetText(this.text:GetText())
            this.frame.text:SetTextColor(r,g,b,a)
            this.frame.backdrop:SetBackdropBorderColor(r,g,b,a)
          end)
        end
    end

    pfUI.bubbles:SetScript("OnUpdate", nil)
  end
end)
