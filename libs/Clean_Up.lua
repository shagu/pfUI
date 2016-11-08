-- Repository: https://github.com/shirsig/Clean_Up-lib
-- Usage: Clean_Up(containers [, reverse])
--   containers - 'bags' or 'bank'
--   reverse - boolean

if Clean_Up then return end
local _G, _M = getfenv(0), {}
setfenv(1, setmetatable(_M, {__index=_G}))

CreateFrame('GameTooltip', 'Clean_Up_Tooltip', nil, 'GameTooltipTemplate')

local function set(...)
	local t = {}
	for i = 1, arg.n do
		t[arg[i]] = true
	end
	return t
end

local function union(...)
	local t = {}
	for i = 1, arg.n do
		for k in arg[i] do
			t[k] = true
		end
	end
	return t
end

local ITEM_TYPES = {GetAuctionItemClasses()}

local MOUNT = set(
	-- rams
	5864, 5872, 5873, 18785, 18786, 18787, 18244, 19030, 13328, 13329,
	-- horses
	2411, 2414, 5655, 5656, 18778, 18776, 18777, 18241, 12353, 12354,
	-- sabers
	8629, 8631, 8632, 18766, 18767, 18902, 18242, 13086, 19902, 12302, 12303, 8628, 12326,
	-- mechanostriders
	8563, 8595, 13321, 13322, 18772, 18773, 18774, 18243, 13326, 13327,
	-- kodos
	15277, 15290, 18793, 18794, 18795, 18247, 15292, 15293,
	-- wolves
	1132, 5665, 5668, 18796, 18797, 18798, 18245, 12330, 12351,
	-- raptors
	8588, 8591, 8592, 18788, 18789, 18790, 18246, 19872, 8586, 13317,
	-- undead horses
	13331, 13332, 13333, 13334, 18791, 18248, 13335,
	-- qiraji battle tanks
	21218, 21321, 21323, 21324, 21176
)

local SPECIAL = set(5462, 17696, 17117, 13347, 13289, 11511)

local KEY = set(9240, 17191, 13544, 12324, 16309, 12384, 20402)

local TOOL = set(7005, 12709, 19727, 5956, 2901, 6219, 10498, 6218, 6339, 11130, 11145, 16207, 9149, 15846, 6256, 6365, 6367)

local ENCHANTING_REAGENT = set(
	-- dust
	10940, 11083, 11137, 11176, 16204,
	-- essence
	10938, 10939, 10998, 11082, 11134, 11135, 11174, 11175, 16202, 16203,
	-- shard
	10978, 11084, 11138, 11139, 11177, 11178, 14343, 14344,
	-- crystal
	20725
)

local CLASSES = {
	-- arrow
	{
		containers = {2101, 5439, 7278, 11362, 3573, 3605, 7371, 8217, 2662, 19319, 18714},
		items = set(2512, 2515, 3030, 3464, 9399, 11285, 12654, 18042, 19316),
	},
	-- bullet
	{
		containers = {2102, 5441, 7279, 11363, 3574, 3604, 7372, 8218, 2663, 19320},
		items = set(2516, 2519, 3033, 3465, 4960, 5568, 8067, 8068, 8069, 10512, 10513, 11284, 11630, 13377, 15997, 19317),
	},
	-- soul
	{
		containers = {22243, 22244, 21340, 21341, 21342},
		items = set(6265),
	},
	-- ench
	{
		containers = {22246, 22248, 22249},
		items = union(
			ENCHANTING_REAGENT,
			-- rods
			set(6218, 6339, 11130, 11145, 16207)
		),
	},
	-- herb
	{
		containers = {22250, 22251, 22252},
		items = set(765, 785, 2447, 2449, 2450, 2452, 2453, 3355, 3356, 3357, 3358, 3369, 3818, 3819, 3820, 3821, 4625, 8831, 8836, 8838, 8839, 8845, 8846, 13463, 13464, 13465, 13466, 13467, 13468),
	},
}

local model, itemStacks, itemClasses, itemSortKeys

do
	local f = CreateFrame'Frame'
	f:Hide()

	function _G.Clean_Up(containers, reverse)
		if f:IsShown() then return end
		if containers == 'bags' then
			CONTAINERS = {0, 1, 2, 3, 4}
		elseif containers == 'bank' then
			CONTAINERS = {-1, 5, 6, 7, 8, 9, 10}
		else
			error()
		end
		REVERSE = reverse
		Initialize()
		f:Show()
	end

	local delay = 0
	f:SetScript('OnUpdate', function()
		delay = delay - arg1
		if delay <= 0 then
			delay = .2

			local complete = Sort()
			if complete then
				f:Hide()
				return
			end
			Stack()
		end
	end)
end

do
	local function key(table, value)
		for k, v in table do
			if v == value then
				return k
			end
		end
	end

	function ItemTypeKey(itemClass)
		return key(ITEM_TYPES, itemClass) or 0
	end

	function ItemSubTypeKey(itemClass, itemSubClass)
		return key({GetAuctionItemSubClasses(ItemTypeKey(itemClass))}, itemClass) or 0
	end

	function ItemInvTypeKey(itemClass, itemSubClass, itemSlot)
		return key({GetAuctionInvTypes(ItemTypeKey(itemClass), ItemSubTypeKey(itemSubClass))}, itemSlot) or 0
	end
end

function LT(a, b)
	local i = 1
	while true do
		if a[i] and b[i] and a[i] ~= b[i] then
			return a[i] < b[i]
		elseif not a[i] and b[i] then
			return true
		elseif not b[i] then
			return false
		end
		i = i + 1
	end
end

function Move(src, dst)
    local texture, _, srcLocked = GetContainerItemInfo(src.container, src.position)
    local _, _, dstLocked = GetContainerItemInfo(dst.container, dst.position)
    
	if texture and not srcLocked and not dstLocked then
		ClearCursor()
       	PickupContainerItem(src.container, src.position)
		PickupContainerItem(dst.container, dst.position)

		if src.item == dst.item then
			local count = min(src.count, itemStacks[dst.item] - dst.count)
			src.count = src.count - count
			dst.count = dst.count + count
			if src.count == 0 then
				src.item = nil
			end
		else
			src.item, dst.item = dst.item, src.item
			src.count, dst.count = dst.count, src.count
		end

		return true
    end
end

function TooltipInfo(container, position)
	local chargesPattern = '^' .. gsub(gsub(ITEM_SPELL_CHARGES_P1, '%%d', '(%%d+)'), '%%%d+%$d', '(%%d+)') .. '$'

	Clean_Up_Tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	Clean_Up_Tooltip:ClearLines()

	if container == BANK_CONTAINER then
		Clean_Up_Tooltip:SetInventoryItem('player', BankButtonIDToInvSlotID(position))
	else
		Clean_Up_Tooltip:SetBagItem(container, position)
	end

	local charges, usable, soulbound, quest, conjured
	for i = 1, Clean_Up_Tooltip:NumLines() do
		local text = getglobal('Clean_Up_TooltipTextLeft' .. i):GetText()

		local _, _, chargeString = strfind(text, chargesPattern)
		if chargeString then
			charges = tonumber(chargeString)
		elseif strfind(text, '^' .. ITEM_SPELL_TRIGGER_ONUSE) then
			usable = true
		elseif text == ITEM_SOULBOUND then
			soulbound = true
		elseif text == ITEM_BIND_QUEST then
			quest = true
		elseif text == ITEM_CONJURED then
			conjured = true
		end
	end

	return charges or 1, usable, soulbound, quest, conjured
end

function Sort()
	local complete = true

	for _, dst in model do
		if dst.targetItem and (dst.item ~= dst.targetItem or dst.count < dst.targetCount) then
			complete = false

			local sources, rank = {}, {}

			for _, src in model do
				if src.item == dst.targetItem
					and src ~= dst
					and not (dst.item and src.class and src.class ~= itemClasses[dst.item])
					and not (src.targetItem and src.item == src.targetItem and src.count <= src.targetCount)
				then
					rank[src] = abs(src.count - dst.targetCount + (dst.item == dst.targetItem and dst.count or 0))
					tinsert(sources, src)
				end
			end

			sort(sources, function(a, b) return rank[a] < rank[b] end)

			for _, src in sources do
				if Move(src, dst) then
					break
				end
			end
		end
	end

	return complete
end

function Stack()
	for _, src in model do
		if src.item and src.count < itemStacks[src.item] and src.item ~= src.targetItem then
			for _, dst in model do
				if dst ~= src and dst.item and dst.item == src.item and dst.count < itemStacks[dst.item] and dst.item ~= dst.targetItem then
					Move(src, dst)
				end
			end
		end
	end
end

do
	local counts

	local function insert(t, v)
		if REVERSE then
			tinsert(t, v)
		else
			tinsert(t, 1, v)
		end
	end

	local function assign(slot, item)
		if counts[item] > 0 then
			local count
			if REVERSE and mod(counts[item], itemStacks[item]) ~= 0 then
				count = mod(counts[item], itemStacks[item])
			else
				count = min(counts[item], itemStacks[item])
			end
			slot.targetItem = item
			slot.targetCount = count
			counts[item] = counts[item] - count
			return true
		end
	end

	function Initialize()
		model, counts, itemStacks, itemClasses, itemSortKeys = {}, {}, {}, {}, {}

		for _, container in CONTAINERS do
			local class = ContainerClass(container)
			for position = 1, GetContainerNumSlots(container) do
				local slot = {container=container, position=position, class=class}
				local item = Item(container, position)
				if item then
					local _, count = GetContainerItemInfo(container, position)
					slot.item = item
					slot.count = count
					counts[item] = (counts[item] or 0) + count
				end
				insert(model, slot)
			end
		end

		local free = {}
		for item, count in counts do
			local stacks = ceil(count / itemStacks[item])
			free[item] = stacks
			if itemClasses[item] then
				free[itemClasses[item]] = (free[itemClasses[item]] or 0) + stacks
			end
		end
		for _, slot in model do
			if slot.class and free[slot.class] then
				free[slot.class] = free[slot.class] - 1
			end
		end

		local items = {}
		for item in counts do
			tinsert(items, item)
		end
		sort(items, function(a, b) return LT(itemSortKeys[a], itemSortKeys[b]) end)

		for _, slot in model do
			if slot.class then
				for _, item in items do
					if itemClasses[item] == slot.class and assign(slot, item) then
						break
					end
				end
			else
				for _, item in items do
					if (not itemClasses[item] or free[itemClasses[item]] > 0) and assign(slot, item) then
						if itemClasses[item] then
							free[itemClasses[item]] = free[itemClasses[item]] - 1
						end
						break
					end
				end
			end
		end
	end
end

function ContainerClass(container)
	if container ~= 0 and container ~= BANK_CONTAINER then
		local name = GetBagName(container)
		if name then		
			for class, info in CLASSES do
				for _, itemID in info.containers do
					if name == GetItemInfo(itemID) then
						return class
					end
				end	
			end
		end
	end
end

function Item(container, position)
	local link = GetContainerItemLink(container, position)
	if link then
		local _, _, itemID, enchantID, suffixID, uniqueID = strfind(link, 'item:(%d+):(%d*):(%d*):(%d*)')
		itemID = tonumber(itemID)
		local _, _, quality, _, type, subType, stack, invType = GetItemInfo(itemID)
		local charges, usable, soulbound, quest, conjured = TooltipInfo(container, position)

		local sortKey = {}

		-- hearthstone
		if itemID == 6948 then
			tinsert(sortKey, 1)

		-- mounts
		elseif MOUNT[itemID] then
			tinsert(sortKey, 2)

		-- special items
		elseif SPECIAL[itemID] then
			tinsert(sortKey, 3)

		-- key items
		elseif KEY[itemID] then
			tinsert(sortKey, 4)

		-- tools
		elseif TOOL[itemID] then
			tinsert(sortKey, 5)

		-- soul shards
		elseif itemID == 6265 then
			tinsert(sortKey, 14)

		-- conjured items
		elseif conjured then
			tinsert(sortKey, 15)

		-- soulbound items
		elseif soulbound then
			tinsert(sortKey, 6)

		-- enchanting reagents
		elseif ENCHANTING_REAGENT[itemID] then
			tinsert(sortKey, 7)

		-- other reagents
		elseif type == ITEM_TYPES[9] then
			tinsert(sortKey, 8)

		-- quest items
		elseif quest then
			tinsert(sortKey, 10)

		-- consumables
		elseif usable and type ~= ITEM_TYPES[1] and type ~= ITEM_TYPES[2] and type ~= ITEM_TYPES[8] or type == ITEM_TYPES[4] then
			tinsert(sortKey, 9)

		-- higher quality
		elseif quality > 1 then
			tinsert(sortKey, 11)

		-- common quality
		elseif quality == 1 then
			tinsert(sortKey, 12)

		-- junk
		elseif quality == 0 then
			tinsert(sortKey, 13)
		end
		
		tinsert(sortKey, ItemTypeKey(type))
		tinsert(sortKey, ItemInvTypeKey(type, subType, invType))
		tinsert(sortKey, ItemSubTypeKey(type, subType))
		tinsert(sortKey, -quality)
		tinsert(sortKey, itemID)
		tinsert(sortKey, (REVERSE and 1 or -1) * charges)
		tinsert(sortKey, suffixID)
		tinsert(sortKey, enchantID)
		tinsert(sortKey, uniqueID)

		local key = format('%s:%s:%s:%s:%s:%s', itemID, enchantID, suffixID, uniqueID, charges, (soulbound and 1 or 0))

		itemStacks[key] = stack
		itemSortKeys[key] = sortKey

		for class, info in CLASSES do
			if info.items[itemID] then
				itemClasses[key] = class
				break
			end
		end

		return key
	end
end
