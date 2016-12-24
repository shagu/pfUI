-- a real "round" instead of ceil or floor
function pfUI:round(input, places)
  if not places then places = 0 end
  if type(input) == "number" and type(places) == "number" then
    local pow = 1
    for i = 1, places do pow = pow * 10 end
    return floor(input * pow + 0.5) / pow
  end
end

function pfUI:strsplit(delimiter, subject)
  local ret = {}
  local sector = subject
  while true do
    local pos = strfind(sector, delimiter)
    if pos then
      table.insert(ret, strsub(sector,1,pos-1))
      sector = strsub(sector,pos+1)
    else
      table.insert(ret, sector)
      return unpack(ret)
    end
  end
end

function pfUI:CreateGoldString(money)
  local gold = floor(money/ 100 / 100)
  local silver = floor(mod((money/100),100))
  local copper = floor(mod(money,100))

  local string = ""
  if gold > 0 then string = string .. "|cffffffff" .. gold .. "|cffffd700g" end
  if silver > 0 then string = string .. "|cffffffff " .. silver .. "|cffc7c7cfs" end
  string = string .. "|cffffffff " .. copper .. "|cffeda55fc"

  return string
end

function pfUI:CopyTable(src)
  local lookup_table = {}
  local function _copy(src)
    if type(src) ~= "table" then
      return src
    elseif lookup_table[src] then
      return lookup_table[src]
    end
    local new_table = {}
    lookup_table[src] = new_table
    for index, value in pairs(src) do
      new_table[_copy(index)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(src))
  end
  return _copy(src)
end
