pfUI:RegisterModule("castbar", function ()
    pfUI.castbar = CreateFrame("Frame")

    if pfUI.uf.player then

      -- hide blizzard
      if pfUI_config.castbar.player.hide_blizz == "1" then
        CastingBarFrame:UnregisterAllEvents()
        CastingBarFrame:Hide()
      end

      -- setup player castbar
      pfUI.castbar.player = CreateFrame("Frame",nil, pfUI.uf.player)
      pfUI.castbar.player:SetBackdrop(pfUI.backdrop)
      pfUI.castbar.player:SetHeight(pfUI_config.global.font_size * 2)
      pfUI.castbar.player:SetPoint("TOPRIGHT",pfUI.uf.player,"BOTTOMRIGHT",0,-1)
      pfUI.castbar.player:SetPoint("TOPLEFT",pfUI.uf.player,"BOTTOMLEFT",0,-1)
      pfUI.castbar.player:Hide();
      pfUI.castbar.player.delay = 0;

      -- statusbar
      pfUI.castbar.player.bar = CreateFrame("StatusBar", nil, pfUI.castbar.player)
      pfUI.castbar.player.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
      pfUI.castbar.player.bar:ClearAllPoints()
      pfUI.castbar.player.bar:SetPoint("TOPLEFT", pfUI.castbar.player, "TOPLEFT", 3, -3)
      pfUI.castbar.player.bar:SetPoint("BOTTOMRIGHT", pfUI.castbar.player, "BOTTOMRIGHT", -3, 3)
      pfUI.castbar.player.bar:SetMinMaxValues(0, 100)
      pfUI.castbar.player.bar:SetValue(20)
      pfUI.castbar.player.bar:SetStatusBarColor(.7,.7,.9,.8)

      -- text left
      pfUI.castbar.player.bar.left = pfUI.castbar.player.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      pfUI.castbar.player.bar.left:ClearAllPoints()
      pfUI.castbar.player.bar.left:SetPoint("TOPLEFT", pfUI.castbar.player.bar, "TOPLEFT", 3, 0)
      pfUI.castbar.player.bar.left:SetPoint("BOTTOMRIGHT", pfUI.castbar.player.bar, "BOTTOMRIGHT", -3, 0)
      pfUI.castbar.player.bar.left:SetNonSpaceWrap(false)
      pfUI.castbar.player.bar.left:SetFontObject(GameFontWhite)
      pfUI.castbar.player.bar.left:SetTextColor(1,1,1,1)
      pfUI.castbar.player.bar.left:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
      pfUI.castbar.player.bar.left:SetText("left")
      pfUI.castbar.player.bar.left:SetJustifyH("left")

      -- text right
      pfUI.castbar.player.bar.right = pfUI.castbar.player.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      pfUI.castbar.player.bar.right:ClearAllPoints()
      pfUI.castbar.player.bar.right:SetPoint("TOPLEFT", pfUI.castbar.player.bar, "TOPLEFT", 3, 0)
      pfUI.castbar.player.bar.right:SetPoint("BOTTOMRIGHT", pfUI.castbar.player.bar, "BOTTOMRIGHT", -3, 0)
      pfUI.castbar.player.bar.right:SetNonSpaceWrap(false)
      pfUI.castbar.player.bar.right:SetFontObject(GameFontWhite)
      pfUI.castbar.player.bar.right:SetTextColor(1,1,1,1)
      pfUI.castbar.player.bar.right:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
      pfUI.castbar.player.bar.right:SetText("right")
      pfUI.castbar.player.bar.right:SetJustifyH("right")

      -- events
      pfUI.castbar.player:RegisterEvent("SPELLCAST_START");
      pfUI.castbar.player:RegisterEvent("SPELLCAST_STOP");
      pfUI.castbar.player:RegisterEvent("SPELLCAST_DELAYED");
      pfUI.castbar.player:RegisterEvent("SPELLCAST_CHANNEL_START");
      pfUI.castbar.player:RegisterEvent("SPELLCAST_CHANNEL_STOP");
      pfUI.castbar.player:RegisterEvent("SPELLCAST_CHANNEL_UPDATE");
      pfUI.castbar.player:RegisterEvent("SPELLCAST_FAILED");
      pfUI.castbar.player:RegisterEvent("SPELLCAST_INTERRUPTED");

      pfUI.castbar.player:SetScript("OnEvent", function ()
        if ( event == "SPELLCAST_START" ) then
          pfUI.castbar.player.delay = 0;
          pfUI.castbar.player.spell = arg1
          pfUI.castbar.player.bar.left:SetText(arg1)
          pfUI.castbar.player.bar:SetStatusBarColor(.7,.7,.9,.8)
          pfUI.castbar.player.startTime = GetTime();
          pfUI.castbar.player.maxValue = pfUI.castbar.player.startTime + (arg2 / 1000);
          pfUI.castbar.player.endTime = nil
          pfUI.castbar.player.bar:SetMinMaxValues(pfUI.castbar.player.startTime, pfUI.castbar.player.maxValue);
          pfUI.castbar.player.bar:SetValue(pfUI.castbar.player.startTime);
          pfUI.castbar.player.holdTime = 0;
          pfUI.castbar.player.casting = 1;
          pfUI.castbar.player.mode = "casting";
          pfUI.castbar.player.fadeout = nil
          pfUI.castbar.player:SetAlpha(1)
          pfUI.castbar.player:Show()

        elseif ( event == "SPELLCAST_CHANNEL_START" ) then
          pfUI.castbar.player.delay = 0;
          pfUI.castbar.player.spell = arg2
          pfUI.castbar.player.bar.left:SetText(arg2)
          pfUI.castbar.player.bar:SetStatusBarColor(.9,.9,.7,.8)
          pfUI.castbar.player.maxValue = nil;
          pfUI.castbar.player.startTime = GetTime();
          pfUI.castbar.player.endTime = pfUI.castbar.player.startTime + (arg1 / 1000);
          pfUI.castbar.player.duration = arg1 / 1000;
          pfUI.castbar.player.bar:SetMinMaxValues(pfUI.castbar.player.startTime, pfUI.castbar.player.endTime);
          pfUI.castbar.player.bar:SetValue(pfUI.castbar.player.endTime);
          pfUI.castbar.player.holdTime = 0;
          pfUI.castbar.player.casting = nil;
          pfUI.castbar.player.channeling = 1;
          pfUI.castbar.player.fadeout = nil
          pfUI.castbar.player:SetAlpha(1)
          pfUI.castbar.player:Show()

        elseif event == "SPELLCAST_STOP" then
          if pfUI.castbar.player.casting then
            pfUI.castbar.player.fadeout = 1
            pfUI.castbar.player.bar:SetMinMaxValues(1,pfUI.castbar.player.bar:GetValue())
          end

        elseif event == "SPELLCAST_CHANNEL_STOP" then
          if pfUI.castbar.player.channeling then
            pfUI.castbar.player.fadeout = 1
            pfUI.castbar.player.bar:SetMinMaxValues(1,pfUI.castbar.player.bar:GetValue())
          end

        elseif event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
            pfUI.castbar.player.fadeout = 1
            pfUI.castbar.player.bar:SetStatusBarColor(1,.5,.5,1)
            pfUI.castbar.player.bar:SetMinMaxValues(1,100)
            pfUI.castbar.player.bar:SetValue(100)

        elseif ( event == "SPELLCAST_DELAYED" ) then
          if( pfUI.castbar.player:IsShown() ) then
            pfUI.castbar.player.delay = pfUI.castbar.player.delay + arg1/1000
            pfUI.castbar.player.startTime = pfUI.castbar.player.startTime + (arg1 / 1000);
            pfUI.castbar.player.maxValue = pfUI.castbar.player.maxValue + (arg1 / 1000);
            pfUI.castbar.player.bar:SetMinMaxValues(pfUI.castbar.player.startTime, pfUI.castbar.player.maxValue);
          end

        elseif ( event == "SPELLCAST_CHANNEL_UPDATE" ) then
          if ( pfUI.castbar.player:IsShown() ) then
            pfUI.castbar.player.delay = pfUI.castbar.player.delay + arg1/1000
            local origDuration = pfUI.castbar.player.endTime - pfUI.castbar.player.startTime
            pfUI.castbar.player.endTime = GetTime() + (arg1 / 1000)
            pfUI.castbar.player.startTime = pfUI.castbar.player.endTime - origDuration
            pfUI.castbar.player.bar:SetMinMaxValues(pfUI.castbar.player.startTime, pfUI.castbar.player.endTime);
          end
        end
      end)

      pfUI.castbar.player:SetScript("OnUpdate", function ()
        -- fadeout
        if pfUI.castbar.player.fadeout and pfUI.castbar.player:GetAlpha() > 0 then
          pfUI.castbar.player:SetAlpha(pfUI.castbar.player:GetAlpha()-0.025)
          if pfUI.castbar.player:GetAlpha() == 0 then
            pfUI.castbar.player:Hide()
            pfUI.castbar.player.fadeout = nil
          end
        end

        -- cast
        if ( pfUI.castbar.player.casting ) then
          local status = GetTime();
          local cur = round(GetTime() - pfUI.castbar.player.startTime,1)
          local max = round(pfUI.castbar.player.maxValue - pfUI.castbar.player.startTime,1)
          local delay = pfUI.castbar.player.delay
          if cur > max then cur = max end
          if ( status > pfUI.castbar.player.maxValue ) then
            status = pfUI.castbar.player.maxValue
          end
          if delay > 0 then
            delay = "|cffffaaaa+" .. round(delay,1) .. " |r "
            pfUI.castbar.player.bar.right:SetText(delay .. cur .. " / " .. max)
          else
            pfUI.castbar.player.bar.right:SetText(cur .. " / " .. max)
          end
          pfUI.castbar.player.bar:SetValue(status);

        -- channel
        elseif ( pfUI.castbar.player.channeling ) then
          local time = GetTime();
          local barValue = pfUI.castbar.player.startTime + (pfUI.castbar.player.endTime - time);
          local cur = round(pfUI.castbar.player.endTime - GetTime(),1)
          local max = round(pfUI.castbar.player.endTime - pfUI.castbar.player.startTime,1)
          local delay = pfUI.castbar.player.delay
          if cur > max then cur = max end
          if ( time > pfUI.castbar.player.endTime ) then
            time = pfUI.castbar.player.endTime
          end
          if ( time == pfUI.castbar.player.endTime ) then
            pfUI.castbar.player.channeling = nil;
            pfUI.castbar.player.fadeout = 1;
            return;
          end
          if delay > 0 then
            delay = "|cffffaaaa-" .. round(delay,1) .. " |r "
            pfUI.castbar.player.bar.right:SetText(delay .. cur)
          else
            pfUI.castbar.player.bar.right:SetText(cur)
          end
          pfUI.castbar.player.bar:SetValue( barValue );
        end
      end)
    end

    if pfUI.uf.target then
      --[[ TODO
      pfUI.castbar.target = CreateFrame("Frame",nil, pfUI.uf.target)
      pfUI.castbar.target:SetBackdrop(pfUI.backdrop)
      pfUI.castbar.target:SetHeight(pfUI_config.global.font_size * 2)
      pfUI.castbar.target:SetPoint("TOPRIGHT",pfUI.uf.target,"BOTTOMRIGHT",0,-1)
      pfUI.castbar.target:SetPoint("TOPLEFT",pfUI.uf.target,"BOTTOMLEFT",0,-1)
      pfUI.castbar.target.bar = CreateFrame("StatusBar", nil, pfUI.castbar.target)
      ]]--
    end
end)