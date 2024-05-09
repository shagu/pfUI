-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

--[[ libtipscan ]]--
-- A pfUI library that provides tooltip scanner.
--
--  libtipscan:GetScanner(name)
--    returns or resets a scanner for use with tooltip methods
--
--  libtipscan:List()
--    prints a list of all active scanners
--
--  The scanner tooltip returned by :GetScanner has all the Set____ GameTooltip methods with a built-in full clear
--  In addition the scanner has the following custom methods
--  <scanner>:Text()
--    return a table with all the left, right texts in {[line] = {left, right}} format
--  <scanner>:Find(text, [exact])
--    returns true (linenumber) and [the text found or the captures made if text is a pattern]
--    exact is optional flag making it look only for exact matches
--  <scanner>:Color(r,g,b)
--    returns true (linenumber) if the r,g,b color tuple is found as text color on the scanner
--    accepts color table as argument as well (eg. <scanner>:Color(RED_FONT_COLOR) )
--  <scanner>:Line(line_number)
--    returns left, right text from that tooltip line
--  <scanner>:List()
--    prints a list of all available scanner methods

-- return instantly when another libtipscan is already active
if pfUI.api.libtipscan then return end

local libtipscan = {}
local baseName = "pfUIScan"
local methods = {
  "SetBagItem", "SetAction", "SetAuctionItem", "SetAuctionSellItem", "SetBuybackItem",
  "SetCraftItem", "SetCraftSpell", "SetHyperlink", "SetInboxItem", "SetInventoryItem",
  "SetLootItem", "SetLootRollItem", "SetMerchantItem", "SetPetAction", "SetPlayerBuff",
  "SetQuestItem", "SetQuestLogItem", "SetQuestRewardSpell", "SetSendMailItem", "SetShapeshift",
  "SetSpell", "SetTalent", "SetTrackingSpell", "SetTradePlayerItem", "SetTradeSkillItem", "SetTradeTargetItem",
  "SetTrainerService", "SetUnit", "SetUnitBuff", "SetUnitDebuff",
}
local extra_methods = {
  "Find", "Line", "Text", "List",
}

local getFontString = function(obj)
  local name = obj:GetName()
  local r, g, b, color, a
  local text, segment

  for i=1, obj:NumLines() do
    local left = _G[string.format("%sTextLeft%d",name,i)]
    segment = left and left:IsVisible() and left:GetText()
    segment = segment and segment ~= "" and segment or nil
    if segment then
      r, g, b, a = left:GetTextColor()
      segment = rgbhex(r,g,b) .. segment .. "|r"
      text = text and text .. "\n" .. segment or segment
    end
  end
  return text
end

local getText = function(obj)
  local name = obj:GetName()
  local text = {}
  for i=1, obj:NumLines() do
    local left, right = _G[string.format("%sTextLeft%d",name,i)], _G[string.format("%sTextRight%d",name,i)]
    left = left and left:IsVisible() and left:GetText()
    right = right and right:IsVisible() and right:GetText()
    left = left and left ~= "" and left or nil
    right = right and right ~= "" and right or nil
    if left or right then
      text[i] = {left, right}
    end
  end
  return text
end

local findText = function(obj, text, exact)
  local name = obj:GetName()
  for i=1, obj:NumLines() do
    local left, right = _G[string.format("%sTextLeft%d",name,i)], _G[string.format("%sTextRight%d",name,i)]
    left = left and left:IsVisible() and left:GetText()
    right = right and right:IsVisible() and right:GetText()
    if exact then
      if (left and left == text) or (right and right == text) then
        return i, text
      end
    else
      if left then
        local found,_,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10 = string.find(left, text)
        if found then
          return i, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10
        end
      end
      if right then
        local found,_,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10 = string.find(right, text)
        if found then
          return i, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10
        end
      end
    end
  end
end

local lineText = function(obj, line)
  local name = obj:GetName()
  if line <= obj:NumLines() then
    local left, right = _G[string.format("%sTextLeft%d",name,line)], _G[string.format("%sTextRight%d",name,line)]
    left = left and left:IsVisible() and left:GetText()
    right = right and right:IsVisible() and right:GetText()

    if left or right then
      return left, right
    end
  end
end

local findColor = function(obj, r,g,b)
  local name = obj:GetName()
  if type(r) == "table" then
    r,g,b = r.r or r[1], r.g or r[2], r.b or r[3]
  end
  for i=1, obj:NumLines() do
    local tr, tg, tb
    local left, right = _G[string.format("%sTextLeft%d",name,i)], _G[string.format("%sTextRight%d",name,i)]
    if left and left:IsVisible() then
      tr, tg, tb = left:GetTextColor()
      tr, tg, tb = round(tr,1), round(tg,1), round(tb,1)
    end
    if tr and (tr == r and tg == g and tb == b) then
      return i
    end
    if right and right:IsVisible() then
      tr, tg, tb = right:GetTextColor()
      tr, tg, tb = round(tr,1), round(tg,1), round(tb,1)
    end
    if tr and (tr == r and tg == g and tb == b) then
      return i
    end
  end
end

libtipscan._registry = setmetatable({},{__index = function(t,k)
  local v = CreateFrame("GameTooltip", string.format("%s%s",baseName,k), nil, "GameTooltipTemplate")
  v:SetOwner(WorldFrame,"ANCHOR_NONE")
  v:SetScript("OnHide", function ()
    this:SetOwner(WorldFrame,"ANCHOR_NONE")
  end)
  function v:Text()
    return getText(self)
  end
  function v:FontString()
    return getFontString(self)
  end
  function v:Find(text, exact)
    return findText(self, text, exact)
  end
  function v:Color(r,g,b)
    return findColor(self,r,g,b)
  end
  function v:Line(line)
    return lineText(self, line)
  end
  for _,method in ipairs(methods) do
    local method = method
    local old = v[method]
    v[method] = function(v, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)
      v:ClearLines()
      v:SetOwner(WorldFrame, "ANCHOR_NONE")
      return old(v, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)
    end
  end
  function v:List()
    table.sort(methods)
    for _,method in ipairs(methods) do
      print(method)
    end
    for _,method in ipairs(extra_methods) do
      print(method)
    end
  end
  rawset(t,k,v)
  return v
end})

function libtipscan:GetScanner(type)
  local scanner = self._registry[type]
  scanner:ClearLines()
  return scanner
end

function libtipscan:List()
  for name, scanner in pairs(self._registry) do
    print(name)
  end
end

-- add libtipscan to pfUI API
pfUI.api.libtipscan = libtipscan
