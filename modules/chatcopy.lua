pfUI:RegisterModule("chatcopy", 20400, function ()
  -- temporary till the new API is merged
  local function CreateScrollFrame(name, parent)
    local f = CreateFrame("ScrollFrame", name, parent)
    SetAllPointsOffset(f, parent, 2)

    -- create slider
    f.slider = CreateFrame("Slider", nil, f)
    f.slider:SetOrientation('VERTICAL')
    f.slider:SetPoint("TOPLEFT", f, "TOPRIGHT", -7, 0)
    f.slider:SetPoint("BOTTOMRIGHT", 0, 0)
    f.slider:SetThumbTexture("Interface\\AddOns\\pfUI\\img\\col")
    f.slider.thumb = f.slider:GetThumbTexture()
    f.slider.thumb:SetHeight(50)
    f.slider.thumb:SetTexture(.3,1,.8,.5)

    f.slider:SetScript("OnValueChanged", function()
      f:SetVerticalScroll(this:GetValue())
      f.UpdateScrollState()
    end)

    f.UpdateScrollState = function()
      f.slider:SetMinMaxValues(0, f:GetVerticalScrollRange())
      f.slider:SetValue(f:GetVerticalScroll())

      local m = f:GetHeight()+f:GetVerticalScrollRange()
      local v = f:GetHeight()
      local ratio = v / m

      if ratio < 1 then
        local size = math.floor(v * ratio)
        f.slider.thumb:SetHeight(size)
        f.slider:Show()
      else
        f.slider:Hide()
      end
    end

    f.Scroll = function(self, step)
      local step = step or 0

      local current = f:GetVerticalScroll()
      local max = f:GetVerticalScrollRange()
      local new = current - step

      if new >= max then
        f:SetVerticalScroll(max)
      elseif new <= 0 then
        f:SetVerticalScroll(0)
      else
        f:SetVerticalScroll(new)
      end

      f:UpdateScrollState()
    end

    f:EnableMouseWheel(1)
    f:SetScript("OnMouseWheel", function()
      this:Scroll(arg1*10)
    end)

    return f
  end

  local limit = 100
  local f = CreateFrame("Frame")
  f:RegisterEvent("PLAYER_ENTERING_WORLD")
  f:SetScript("OnEvent", function()

    local button = CreateFrame("Button", "pfChatCopyButton", pfUI.chat.left.panelTop)
    button:SetPoint("TOPRIGHT", 0, 0)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetWidth(16)
    button:SetHeight(16)
    button:SetAlpha(.25)
    button.icon = button:CreateTexture(nil,"BACKGROUND")
    button.icon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
    button.icon:SetAllPoints()

    button:SetScript("OnClick", function()
      if arg1 == "LeftButton" then
        this.state = not this.state

        for i=1, _G.NUM_CHAT_WINDOWS do
          local frame = _G["ChatFrame"..i]
          local scroll = frame.scroll

          if scroll and this.state then
            scroll:Show()
          elseif scroll then
            scroll:Hide()
          end
        end

        if this.state then
          button.icon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
        else
          button.icon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
        end
      elseif arg1 == "RightButton" then
        if ChatMenu:IsShown() then
          ChatMenu:Hide()
        else
          ChatMenu:Show()
          ChatMenu:ClearAllPoints()
          ChatMenu:SetPoint("BOTTOMLEFT", this, "TOPRIGHT", 0, 0)
        end
      end
    end)

    button:SetScript("OnEnter", function()
      this:SetAlpha(1)
    end)

    button:SetScript("OnLeave", function()
      this:SetAlpha(.4)
    end)

    for i=1, _G.NUM_CHAT_WINDOWS do
      local frame = _G["ChatFrame"..i]
      local name = frame:GetName()

      local combat = 0
      for i, msg in pairs(frame.messageTypeList) do
        if strfind(msg, "SPELL", 1) or strfind(msg, "COMBAT", 1) then
          combat = combat + 1
        end
      end

      if combat < 5 then
        -- initialize message cache
        local history = {}
        local AddMessage = frame.AddMessage
        frame.AddMessage = function(self,msg,r,g,b)
          if msg and r and g and b then
            local col = string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
            table.insert(history, 1, col..string.gsub(msg, "|r", col))
          elseif msg then
            table.insert(history, 1, "|cffffffff"..msg)
          end

          if history[limit] then
            table.remove(history, limit)
          end
          AddMessage(self,msg,r,g,b)
        end

        -- read chat defaults
        local font, size, flags = frame:GetFont()

        -- build the frames
        local scroll = CreateScrollFrame("ChatFrameScroll"..i, frame)
        scroll:SetAllPoints(frame)
        scroll.tex = scroll:CreateTexture(nil, "BACKGROUND")
        scroll.tex:SetTexture(0,0,0,.95)
        scroll.tex:SetPoint("TOPLEFT", -3, 3)
        scroll.tex:SetPoint("BOTTOMRIGHT", 3, -3)
        scroll:Hide()

        local editbox = CreateFrame("EditBox", "pfChatCopyBox" .. i, scroll)
        editbox:SetHeight(frame:GetHeight())
        editbox:SetWidth(frame:GetWidth())
        editbox:SetAllPoints(scroll)
        editbox:SetTextColor(1,1,1,1)
        editbox:SetFontObject(ChatFontNormal)
        editbox:SetFont(font, size, flags)
        editbox:SetAutoFocus(true)
        editbox:SetMultiLine(true)
        editbox:SetMaxLetters(0)

        editbox:SetScript("OnEscapePressed", function ()
          this:ClearFocus()
        end)

        scroll:SetScrollChild(editbox)
        scroll:SetScript("OnShow", function()
          editbox:SetText("")
          for i=limit,0,-1 do
            if history[i] then
              editbox:Insert("\n" .. history[i])
            end
          end

          editbox:SetScript("OnUpdate", function()
            if not this.count then this.count = 0 end

            scroll:UpdateScrollChildRect()
            scroll:SetVerticalScroll(scroll:GetVerticalScrollRange())
            scroll:Scroll()
            this.count = this.count + 1

            -- the scroll frame takes a while to update
            if this.count >= 3 then
              this:SetScript("OnUpdate", nil)
              this.count = 0
            end
          end)
        end)

        frame.scroll = scroll
      end
    end

    this:UnregisterAllEvents()
  end)
end)
