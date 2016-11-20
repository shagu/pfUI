-- a real "round" instead of ceil or floor
function round(input, places)
  if not places then places = 0 end
  if type(input) == "number" and type(places) == "number" then
    local pow = 1
    for i = 1, places do pow = pow * 10 end
    return floor(input * pow + 0.5) / pow
  end
end

function strsplit(delimiter, subject)
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
