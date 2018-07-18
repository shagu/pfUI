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
--  <scanner>:Clear()
--    empties the scanner tooltip
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
  "Clear", "Find", "Line", "Text", "List",
}

local clearText = function(...)
  for i=1,arg.n do
    local region = arg[i]
    if region:IsObjectType("FontString") and region.SetText then
      region:SetTextColor(0,0,0)
      region:SetText()
    end
  end
end

local clearTooltip = function(obj)
  clearText(obj:GetRegions())
  obj:ClearLines()
  return obj
end

local getText = function(obj)
  local name = obj:GetName()
  local text = {}
  for i=1, obj:NumLines() do
    local left, right = _G[string.format("%sTextLeft%d",name,i)]:GetText(), _G[string.format("%sTextRight%d",name,i)]:GetText()
    left = left and left ~= "" and left or nil
    right = right and right ~= "" and right or nil
    if left or right then
      text[i] = {left, right}
    end
  end
  return text
end

local stripPos = function(...)
  if arg[1] then
    table.remove(arg,1)
    table.remove(arg,1)
  end
  return unpack(arg)
end

local findText = function(obj, text, exact)
  local name = obj:GetName()
  for i=1, obj:NumLines() do
    local left, right = _G[string.format("%sTextLeft%d",name,i)]:GetText(), _G[string.format("%sTextRight%d",name,i)]:GetText()
    if exact then
      if (left and left == text) or (right and right == text) then
        return i, text
      end
    else
      if left and (string.find(left, text)) then
        return i, stripPos(string.find(left,text))
      end
      if right and (string.find(right, text)) then
        return i, stripPos(string.find(right,text))
      end
    end
  end
end

local lineText = function(obj, line)
  local name = obj:GetName()
  if line <= obj:NumLines() then
    local left, right = _G[string.format("%sTextLeft%d",name,line)]:GetText(), _G[string.format("%sTextRight%d",name,line)]:GetText()
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
    if left then
      tr, tg, tb = left:GetTextColor()
      tr, tg, tb = round(tr,1), round(tg,1), round(tb,1)
    end
    if tr and (tr == r and tg == g and tb == b) then
      return i
    end
    if right then
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
  v:SetOwner(v,"ANCHOR_NONE")
  v:SetScript("OnHide", function ()
    this:SetOwner(this,"ANCHOR_NONE")
  end)
  function v:Clear()
    clearTooltip(self)
  end
  function v:Text()
    return getText(self)
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
      if v:IsShown() then
        v:Hide()
      end
      v:Clear()
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
  scanner:Clear()
  return scanner
end

function libtipscan:List()
  for name, scanner in pairs(self._registry) do
    print(name)
  end
end

-- add libtipscan to pfUI API
pfUI.api.libtipscan = libtipscan
