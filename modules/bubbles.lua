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

  local lclass
  pfUI.bubbles.me = (UnitName("player"))
  lclass, pfUI.bubbles.myclass = UnitClass("player")
  pfUI.bubbles.players = pfUI_playerDB
  pfUI.bubbles:SetScript("OnEvent", function()
    this.msg, this.sender = arg1, arg2
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
    local text = f.text:GetText()
    f.frame.text:SetText(text)
    f.frame.text:SetTextColor(r,g,b,a)
    f.frame.backdrop:SetBackdropBorderColor(r,g,b,a)
    f.tail:SetTexture("Interface\\AddOns\\pfUI\\img\\bubble_tail")
    f.tail:SetPoint("TOP",f.frame,"BOTTOM",10,8)
    f.tail:SetVertexColor(r,g,b,a)
    if pfUI.bubbles.msg == text then
      local sender = pfUI.bubbles.sender
      local r,g,b,class
      if (sender) then
        if sender == me then
          class = pfUI.bubbles.myclass
        elseif pfUI.bubbles.players[sender] then
          class = pfUI.bubbles.players[sender].class
        end
        if (class) then
          r,g,b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
        else
          r,g,b = 0.8,0.8,0.8
        end
        f.frame.speaker:SetText(sender)
        f.frame.speaker:SetTextColor(r,g,b,a)
      end
    else
      f.frame.speaker:SetText("")
    end
  end

  function pfUI.bubbles:ScanBubbles()
    local childs = { WorldFrame:GetChildren() }
    for _, f in pairs(childs) do
        if not f.frame and pfUI.bubbles:IsBubble(f) then
          local textures = {f:GetRegions()}
          for _, object in pairs(textures) do
            if object:GetObjectType() == "Texture" then
              if object:GetTexture() == "Interface\\Tooltips\\ChatBubble-Tail" then
                f.tail = object
              end
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

          f.frame.speaker = f.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
          f.frame.speaker:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
          f.frame.speaker:SetJustifyH("CENTER")
          f.frame.speaker:SetJustifyV("CENTER")
          f.frame.speaker:SetPoint("BOTTOMLEFT",f.frame,"TOPLEFT",0,-9)
          f.frame.speaker:SetPoint("BOTTOMRIGHT",f.frame,"TOPRIGHT",0,-9)          

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
