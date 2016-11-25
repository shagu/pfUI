pfUI:RegisterModule("cooldown", function ()
  local function pfCreateCoolDown(cooldown, start, duration)
    cooldown.cd = CreateFrame("Frame", "pfCooldownFrame", cooldown:GetParent())
    cooldown.cd:SetAllPoints(cooldown:GetParent())
    cooldown.cd:SetFrameLevel(cooldown.cd:GetFrameLevel() + 1)

    cooldown.cd.text = cooldown.cd:CreateFontString("pfCooldownFrameText", "OVERLAY")
    cooldown.cd.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
    cooldown.cd.text:SetPoint("CENTER", cooldown.cd, "CENTER", 0, 1)

    cooldown.cd:SetScript("OnUpdate", function()
      if not getglobal(this:GetParent():GetName() .. "Cooldown"):IsShown() then this:Hide() end
      if not this.next then this.next = GetTime() + .1 end
      if this.next > GetTime() then return end
      this.next = GetTime() + .1

      local remaining = this.duration - (GetTime() - this.start)
      if remaining >= 0 then
        local unit = ""
        local color = "|cffffffff"
        if remaining > 99 then
          remaining = remaining / 60
          unit = "m"
          color = "|cff" .. pfUI_config.appearance.cd.mincolor
        end
        if remaining > 99 then
          remaining = remaining / 60
          unit = "h"
          color = "|cff" ..  pfUI_config.appearance.cd.hourcolor
        end
        if remaining > 99 then
          remaining = remaining / 24
          unit = "d"
          color = "|cff" .. pfUI_config.appearance.cd.daycolor
        end
        this.text:SetText(color .. round(remaining) .. unit)
      else
        this:Hide()
      end
    end)
  end

  -- hook
  if not pfCooldownFrame_SetTimer then pfCooldownFrame_SetTimer = CooldownFrame_SetTimer end
  function CooldownFrame_SetTimer(this, start, duration, enable)
    -- realign all cooldown frames
    if this:GetParent():GetWidth() / 36 > 0 then
        this:SetScale(this:GetParent():GetWidth() / 36)
        this:SetPoint("TOPLEFT", this:GetParent(), "TOPLEFT", 0, 0)
        this:SetPoint("BOTTOMRIGHT", this:GetParent(), "BOTTOMRIGHT", 1, -1)
    end

    -- print time as text on cooldown frames
    if ( start > 0 and duration > tonumber(pfUI_config.appearance.cd.threshold) and enable > 0) then
      if( not this.cd ) then
        pfCreateCoolDown(this, start, duration)
      end
      this.cd.start = start
      this.cd.duration = duration
      this.cd:Show()
    elseif(this.cd) then
      this.cd:Hide();
    end

    pfCooldownFrame_SetTimer(this, start, duration, enable)
  end
end)
