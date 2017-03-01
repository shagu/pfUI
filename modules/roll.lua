pfUI:RegisterModule("roll", function ()
  pfUI.roll = CreateFrame("Frame", "pfLootRoll", UIParent)
  pfUI.roll.frames = {}

  function pfUI.roll:CreateLootRoll(id)
    local size = 24
    local border = tonumber(C.appearance.border.default)
    local esize = size - border*2
    local f = CreateFrame("Frame", "pfLootRollFrame" .. id, UIParent)
    CreateBackdrop(f, nil, nil, .8)
    f.backdrop:SetFrameStrata("BACKGROUND")
    f.hasItem = 1

    f:SetWidth(350)
    f:SetHeight(size)

    f.icon = CreateFrame("Button", "pfLootRollFrame" .. id .. "Icon", f)
    CreateBackdrop(f.icon, nil, true)
    f.icon:SetPoint("LEFT", border, 0)
    f.icon:SetWidth(esize)
    f.icon:SetHeight(esize)

    f.icon.tex = f.icon:CreateTexture("OVERLAY")
    f.icon.tex:SetTexCoord(.08, .92, .08, .92)
    f.icon.tex:SetAllPoints(f.icon)

    f.icon:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
      GameTooltip:SetLootRollItem(this:GetParent().rollID)
      CursorUpdate()
    end)

    f.icon:SetScript("OnClick", function()
      if IsControlKeyDown() then
        DressUpItemLink(GetLootRollItemLink(this:GetParent().rollID))
      elseif IsShiftKeyDown() then
        if ChatFrameEditBox:IsVisible() then
          ChatFrameEditBox:Insert(GetLootRollItemLink(this:GetParent().rollID));
        end
      end
    end)

    f.need = CreateFrame("Button", "pfLootRollFrame" .. id .. "Need", f)
    f.need:SetPoint("LEFT", f.icon, "RIGHT", border*3, -1)
    f.need:SetWidth(esize)
    f.need:SetHeight(esize)
    f.need.tex = f.need:CreateTexture("OVERLAY")
    f.need.tex:SetAllPoints(f.need)
    f.need.tex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
    f.need:SetScript("OnClick", function()
      RollOnLoot(this:GetParent().rollID, 1)
    end)
    f.need:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
      GameTooltip:SetText(NEED)
    end)
    f.need:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    f.greed = CreateFrame("Button", "pfLootRollFrame" .. id .. "Greed", f)
    f.greed:SetPoint("LEFT", f.icon, "RIGHT", border*5+esize, -2)
    f.greed:SetWidth(esize)
    f.greed:SetHeight(esize)
    f.greed.tex = f.greed:CreateTexture("OVERLAY")
    f.greed.tex:SetAllPoints(f.greed)
    f.greed.tex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
    f.greed:SetScript("OnClick", function()
      RollOnLoot(this:GetParent().rollID, 2)
    end)
    f.greed:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
      GameTooltip:SetText(GREED)
    end)
    f.greed:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    f.pass = CreateFrame("Button", "pfLootRollFrame" .. id .. "Pass", f)
    f.pass:SetPoint("LEFT", f.icon, "RIGHT", border*7+esize*2, 0)
    f.pass:SetWidth(esize)
    f.pass:SetHeight(esize)
    f.pass.tex = f.pass:CreateTexture("OVERLAY")
    f.pass.tex:SetAllPoints(f.pass)
    f.pass.tex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    f.pass:SetScript("OnClick", function()
      RollOnLoot(this:GetParent().rollID, 0)
    end)
    f.pass:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
			GameTooltip:SetText(PASS)
    end)
    f.pass:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    f.boe = CreateFrame("Frame", "pfLootRollFrame" .. id .. "BOE", f)
    f.boe:SetPoint("LEFT", f.icon, "RIGHT", border*9+esize*3, 0)
    f.boe:SetWidth(esize*2)
    f.boe:SetHeight(esize)
    f.boe.text = f.boe:CreateFontString("BOE")
    f.boe.text:SetAllPoints(f.boe)
    f.boe.text:SetJustifyH("LEFT")
    f.boe.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")

    f.name = CreateFrame("Frame", "pfLootRollFrame" .. id .. "Name", f)
    f.name:SetPoint("LEFT", f.icon, "RIGHT", border*11+esize*4, 0)
    f.name:SetPoint("RIGHT", f, "RIGHT", border*2, 0)
    f.name:SetHeight(esize)
    f.name.text = f.name:CreateFontString("NAME")
    f.name.text:SetAllPoints(f.name)
    f.name.text:SetJustifyH("LEFT")
    f.name.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")

    f.time = CreateFrame("Frame", "pfLootRollFrame" .. id .. "Time", f)
    f.time:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    f.time:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    f.time:SetFrameStrata("LOW")
    f.time.bar = CreateFrame("StatusBar", "pfLootRollFrame" .. id .. "TimeBar", f.time)
    f.time.bar:SetAllPoints(f.time)
    f.time.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    f.time.bar:SetMinMaxValues(0, 100)
    local r, g, b, a = strsplit(",", C.appearance.border.color)
    f.time.bar:SetStatusBarColor(r, g, b)
    f.time.bar:SetValue(20)
    f.time.bar:SetScript("OnUpdate", function()
      if not this:GetParent():GetParent().rollID then return end
      local left = GetLootRollTimeLeft(this:GetParent():GetParent().rollID)
      local min, max = this:GetMinMaxValues()
      if left < min or left > max then left = min	end
      this:SetValue(left)
    end)

    return f
  end

  pfUI.roll:RegisterEvent("CANCEL_LOOT_ROLL")
  pfUI.roll:SetScript("OnEvent", function()
    for i=1,4 do
      if pfUI.roll.frames[i].rollID == arg1 then
        pfUI.roll.frames[i]:Hide()
      end
    end
  end)

  function _G.GroupLootFrame_OpenNewFrame(id, rollTime)
    for i=1,4 do
      if not pfUI.roll.frames[i]:IsVisible() then
        pfUI.roll.frames[i].rollID = id
        pfUI.roll.frames[i].rollTime = rollTime
        pfUI.roll:UpdateLootRoll(i)
        return
      end
    end
  end

  function pfUI.roll:UpdateLootRoll(id)
    local texture, name, count, quality, bop = GetLootRollItemInfo(pfUI.roll.frames[id].rollID);
    local color = ITEM_QUALITY_COLORS[quality]

    pfUI.roll.frames[id].name.text:SetText(name)
    pfUI.roll.frames[id].name.text:SetTextColor(color.r, color.g, color.b, 1)
    pfUI.roll.frames[id].icon.tex:SetTexture(texture)
    pfUI.roll.frames[id].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
    pfUI.roll.frames[id].time.bar:SetMinMaxValues(0, pfUI.roll.frames[id].rollTime)

    if bop then
      pfUI.roll.frames[id].boe.text:SetText("BoP")
      pfUI.roll.frames[id].boe.text:SetTextColor(1,.3,.3,1)
    else
      pfUI.roll.frames[id].boe.text:SetText("BoE")
      pfUI.roll.frames[id].boe.text:SetTextColor(.3,1,.3,1)
    end

    pfUI.roll.frames[id]:Show()
  end

  for i=1,4 do
    if not pfUI.roll.frames[i] then
      pfUI.roll.frames[i] = pfUI.roll:CreateLootRoll(i)
      pfUI.roll.frames[i]:SetPoint("CENTER", 0, -i*35)
      UpdateMovable(pfUI.roll.frames[i])
      pfUI.roll.frames[i]:Hide()
    end
  end
end)
