pfUI:RegisterSkin("Profession", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  local frames = {
    ["TradeSkill"] = { "Blizzard_TradeSkillUI", "TRADE_SKILLS_DISPLAYED", "TradeSkillSkill", "MAX_TRADE_SKILL_REAGENTS" },
    ["Craft"] = { "Blizzard_CraftUI", "CRAFTS_DISPLAYED", "Craft", "MAX_CRAFT_REAGENTS" },
  }

  for name, ext in pairs(frames) do
    local name        = name
    local ext         = ext
    local addon       = ext[1]
    local displayed   = ext[2]
    local template    = ext[3]
    local maxreagents = ext[4]
    local frame       = name .. "Frame"

    HookAddonOrVariable(addon, function()
      local SetSelection = frame.."_SetSelection"
      local icon = _G[template.."Icon"]
      local seltitle = _G[template.."Name"]
      local reagentlabel = _G[name.."ReagentLabel"]
      local collapseall = _G[name.."CollapseAllButton"]
      local detailscroll = _G[name.."DetailScrollFrame"]
      local detailscrollchild = _G[name.."DetailScrollChildFrame"]
      local detailscrollbar = _G[name.."DetailScrollFrameScrollBar"]
      local rankbar = _G[name.."RankFrame"]
      local decrease = _G[name.."DecrementButton"]
      local increase = _G[name.."IncrementButton"]
      local inputbox = _G[name.."InputBox"]
      local cancel = _G[name.."CancelButton"]
      local create = _G[name.."CreateButton"]
      local createall = _G[name.."CreateAllButton"]
      local subclassdropdown = _G[name.."SubClassDropDown"]
      local invslotdropdown = _G[name.."InvSlotDropDown"]
      local scrollbar = _G[name.."ListScrollFrameScrollBar"]
      local scrollframe = _G[name.."ListScrollFrame"]
      local close = _G[frame.."CloseButton"]
      local title = _G[frame.."TitleText"]
      local points = _G[frame.."PointsText"]
      local requiretext = _G[name .. "RequirementText"]
      local search = _G[name .. "FrameEditBox"]

      local frame = _G[frame]

      StripTextures(frame)
      CreateBackdrop(frame, nil, nil, .75)
      CreateBackdropShadow(frame)

      frame:SetWidth(676)
      frame:SetHeight(440)
      frame:DisableDrawLayer("BACKGROUND")
      EnableMovable(frame)

      title:ClearAllPoints()
      title:SetPoint("TOP", 0, -10)
      title:SetTextColor(1,1,1,1)
      SkinCloseButton(close, frame, -6, -6)

      do -- left pane
        StripTextures(scrollframe)
        SkinScrollbar(scrollbar)

        scrollframe:ClearAllPoints()
        scrollframe:SetPoint("TOPLEFT", 10, -65)
        scrollframe:SetWidth(300)
        scrollframe:SetHeight(365)

        local backdrop = CreateFrame("Frame", scrollframe:GetName().."Backdrop", frame)
        CreateBackdrop(backdrop, nil, nil, .75)
        scrollframe.backdrop = backdrop.backdrop
        scrollframe.backdrop:SetPoint("TOPLEFT", scrollframe, "TOPLEFT", -5, 5)
        scrollframe.backdrop:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", 26, -5)

        _G[template..1]:ClearAllPoints()
        _G[template..1]:SetPoint("TOPLEFT", scrollframe, "TOPLEFT", 0, 0)

        StripTextures(collapseall)
        SkinCollapseButton(collapseall, true)
        collapseall:ClearAllPoints()
        collapseall:SetPoint("BOTTOMLEFT", scrollframe, "TOPLEFT", -5, 5)

        if invslotdropdown then
          SkinDropDown(invslotdropdown)
          invslotdropdown:ClearAllPoints()
          invslotdropdown:SetPoint("BOTTOMRIGHT", scrollframe.backdrop, "TOPRIGHT", 15, 0)

          SkinDropDown(subclassdropdown)
          subclassdropdown:ClearAllPoints()
          subclassdropdown:SetPoint("RIGHT", invslotdropdown, "LEFT", 27, 0)
        end
      end

      do -- right pane
        StripTextures(detailscroll)
        StripTextures(detailscrollchild)
        SkinScrollbar(detailscrollbar)

        local backdrop = CreateFrame("Frame", nil, frame)
        CreateBackdrop(backdrop, nil, nil, .75)
        detailscroll.backdrop = backdrop.backdrop

        detailscroll.backdrop:SetPoint("TOPLEFT", detailscroll, "TOPLEFT", -5, 5)
        detailscroll.backdrop:SetPoint("BOTTOMRIGHT", detailscroll, "BOTTOMRIGHT", 26, -5)

        StripTextures(_G[name.."RankFrameBorder"])
        CreateBackdrop(rankbar, nil, true)
        rankbar:SetStatusBarTexture(pfUI.media["img:bar"])
        rankbar:ClearAllPoints()
        rankbar:SetPoint("TOPLEFT", detailscroll.backdrop, "TOPLEFT", 0, 25)
        rankbar:SetPoint("BOTTOMRIGHT", detailscroll.backdrop, "TOPRIGHT", 0, 6)

        if decrease and increase then
          SkinArrowButton(decrease, "left", 18)
          SkinArrowButton(increase, "right", 18)
        end

        if inputbox then
          inputbox:DisableDrawLayer("BACKGROUND")
          CreateBackdrop(inputbox)
          SetAllPointsOffset(inputbox.backdrop, inputbox, .2)
          inputbox:SetJustifyH("CENTER")
          inputbox:SetWidth(36)
        end

        SkinButton(cancel)
        cancel:ClearAllPoints()
        cancel:SetPoint("TOPRIGHT", detailscroll.backdrop, "BOTTOMRIGHT", 0, -5)

        SkinButton(create)
        create:ClearAllPoints()
        create:SetPoint("RIGHT", cancel, "LEFT", -2*bpad, 0)

        SkinButton(createall)
        StripTextures(_G[name.."ExpandButtonFrame"])

        detailscroll:ClearAllPoints()
        detailscroll:SetPoint("TOPLEFT", 346, -65)
        detailscroll:SetWidth(299)
        detailscroll:SetHeight(338)

        -- skin buttons
        for i = 1, _G[maxreagents] do
          local name = name.."Reagent" .. i
          local item = _G[name]
          local icon = _G[name.."IconTexture"]
          local count = _G[name.."Count"]
          local title = _G[name.."Name"]
          local size = item:GetHeight() - 10

          StripTextures(item)
          CreateBackdrop(item, nil, nil, .75)
          SetAllPointsOffset(item.backdrop, item, 4)
          SetHighlight(item)

          icon:SetWidth(size)
          icon:SetHeight(size)
          icon:ClearAllPoints()
          icon:SetPoint("LEFT", 5, 0)
          icon:SetTexCoord(.08, .92, .08, .92)
          icon:SetParent(item.backdrop)
          icon:SetDrawLayer("OVERLAY")

          count:SetParent(item.backdrop)
          count:SetDrawLayer("OVERLAY")
          count:ClearAllPoints()
          count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)

          title:SetParent(item.backdrop)
          title:SetDrawLayer("OVERLAY")
        end

        if points then
          points:ClearAllPoints()
          points:SetPoint("RIGHT", create, "LEFT", -20, 0)
        end

        StripTextures(icon)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 5, -5)
        SkinButton(icon, nil, nil, nil, nil, true)
        icon:SetPushedTexture(nil)

        seltitle:SetJustifyV("TOP")
        seltitle:SetTextColor(.8,.8,.8,1)

        reagentlabel:ClearAllPoints()
        reagentlabel:SetPoint("TOPLEFT", seltitle, "BOTTOMLEFT", -45, -15)
        reagentlabel:SetTextColor(1,1,1,1)

        local scanner = libtipscan:GetScanner(name)
        hooksecurefunc(SetSelection, function(id)
          if id and id ~= 0 then
            detailscroll:Show()
            HandleIcon(icon, icon:GetNormalTexture())

            if name == "TradeSkill" then
              local itemlink  = GetTradeSkillItemLink(id)
              if not itemlink then return end
              local _, _, link = string.find(itemlink, "(item:%d+:%d+:%d+:%d+)")

              local off = requiretext and requiretext:GetHeight() or 1
              reagentlabel:SetPoint("TOPLEFT", seltitle, "BOTTOMLEFT", -45, -15-off)

              if link then
                scanner:SetHyperlink(link)
                seltitle:SetHeight(0)
                seltitle:SetText(scanner:FontString())

                if seltitle:GetHeight() < 30 then
                  seltitle:SetHeight(35)
                end
              else
                detailscroll:Hide()
              end
            end
          end
        end, true)
      end

      -- Compatibility
      if search then -- tbc
        _G[displayed] = 21
        scrollframe:SetHeight(338)

        local rank = _G[name.."RankFrameSkillRank"]
        rank:ClearAllPoints()
        rank:SetPoint("CENTER", rankbar, "CENTER", 0, 0)

        local available = _G[frame:GetName().."AvailableFilterCheckButton"]
        SkinCheckbox(available)
        available:ClearAllPoints()
        available:SetPoint("TOPLEFT", scrollframe.backdrop, "BOTTOMLEFT", -4, -5)

        search:DisableDrawLayer("BACKGROUND")
        CreateBackdrop(search, nil, nil, 1)
        search.backdrop:SetAllPoints(search)
        search:SetTextInsets(5, 5, 5, 5)
        search:SetHeight(22)
        search:ClearAllPoints()
        search:SetPoint("TOPRIGHT", scrollframe.backdrop, "BOTTOMRIGHT", 0, -5)

        local craft_filter = CraftFrameFilterDropDown
        if craft_filter then
          SkinDropDown(craft_filter)
          craft_filter:ClearAllPoints()
          craft_filter:SetPoint("BOTTOMRIGHT", scrollframe.backdrop, "TOPRIGHT", 15, 0)
        end
      else -- vanilla
        _G[displayed] = 23
      end
      -- build remaining tradeskills
      for i = 9, _G[displayed] do
        local button = _G[template..i] or CreateFrame("Button", template..i, frame, template.."ButtonTemplate")
        button:SetPoint("TOPLEFT", _G[template..i - 1], "BOTTOMLEFT")
      end
      for i = 1, _G[displayed] do SkinCollapseButton(_G[template..i]) end
    end)
  end
end)
