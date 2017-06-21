pfUI:RegisterModule("cooldown", function ()

  -- cache values
  local lowcolor    = {strsplit(",", C.appearance.cd.lowcolor)}
  local normalcolor = {strsplit(",", C.appearance.cd.normalcolor)}
  local minutecolor = {strsplit(",", C.appearance.cd.minutecolor)}
  local hourcolor   = {strsplit(",", C.appearance.cd.hourcolor)}
  local daycolor    = {strsplit(",", C.appearance.cd.daycolor)}

  local function pfCreateCoolDown(cooldown, start, duration)
    cooldown.cd = CreateFrame("Frame", "pfCooldownFrame", cooldown:GetParent())
    cooldown.cd:SetAllPoints(cooldown:GetParent())
    cooldown.cd:SetFrameLevel(cooldown.cd:GetFrameLevel() + 1)

    cooldown.cd.text = cooldown.cd:CreateFontString("pfCooldownFrameText", "OVERLAY")
    cooldown.cd.text:SetFont(pfUI.font_unit, C.appearance.cd.font_size, "OUTLINE")
    cooldown.cd.text:SetPoint("CENTER", cooldown.cd, "CENTER", 0, 1)

    cooldown.cd:SetScript("OnUpdate", function()
      if not this:GetParent() then
        this:Hide()
      end

      if this:GetParent() and this:GetParent():GetName() and _G[this:GetParent():GetName() .. "Cooldown"] then
        if not _G[this:GetParent():GetName() .. "Cooldown"]:IsShown() then
          this:Hide()
        end
      end

      if not this.next then this.next = GetTime() + .1 end
      if this.next > GetTime() then return end
      this.next = GetTime() + .1

      -- fix own alpha value (should be inherited, but isn't)
      this:SetAlpha(this:GetParent():GetAlpha())

      local remaining = this.duration - (GetTime() - this.start)
      if remaining >= 0 then
        local r, g, b, a = unpack(normalcolor)
        local unit = ""
        if remaining <= 3 then
          r,g,b,a = unpack(lowcolor)
        end
        if remaining > 99 then
          remaining = remaining / 60
          unit = "m"
          r,g,b,a = unpack(minutecolor)
        end
        if remaining > 99 then
          remaining = remaining / 60
          unit = "h"
          r,g,b,a = unpack(hourcolor)
        end
        if remaining > 99 then
          remaining = remaining / 24
          unit = "d"
          r,g,b,a = unpack(daycolor)
        end
        this.text:SetText(round(remaining) .. unit)
        this.text:SetTextColor(r,g,b,a)
      else
        this:Hide()
      end
    end)
  end

  -- hook
  hooksecurefunc("CooldownFrame_SetTimer", function(this, start, duration, enable)
    -- realign guessed cooldown frames
    if this:GetParent() and this:GetParent():GetWidth() / 36 > 0 then
      this:SetScale(this:GetParent():GetWidth() / 36)
      this:SetPoint("TOPLEFT", this:GetParent(), "TOPLEFT", 0, 0)
      this:SetPoint("BOTTOMRIGHT", this:GetParent(), "BOTTOMRIGHT", 1, -1)
    end

    -- print time as text on cooldown frames
    if ( start > 0 and duration > tonumber(C.appearance.cd.threshold) and enable > 0) then
      if( not this.cd ) then
        pfCreateCoolDown(this, start, duration)
      end
      this.cd.start = start
      this.cd.duration = duration
      this.cd:Show()
    elseif(this.cd) then
      this.cd:Hide();
    end
  end)
end)
