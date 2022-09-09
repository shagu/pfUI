pfUI:RegisterModule("questitem", function ()
  local questlog = {}
  local itemcache = {}

  local function AddTooltip(frame, item)
    -- abort when no item was given
    if not item then return end

    -- abort if questitem is disabled
    if C.tooltip.questitem.showquest ~= "1" then return end

    -- check if we can replace the questitem string
    local replace = nil
    if frame and _G[frame:GetName().."TextLeft2"] then
      if _G[frame:GetName().."TextLeft2"]:GetText() == ITEM_BIND_QUEST then
        replace = true
      end
    end

    -- set fallbacks for unidentified quests
    local quest, level = UNKNOWN, 255

    -- check cache for already existing values
    if itemcache[item] and itemcache[item] == false then
      -- not a quest item
      return
    elseif itemcache[item] then
      -- read from caches
      quest, level = GetQuestLogTitle(itemcache[item])
    elseif item then
      -- scan for quests
      for id, text in pairs(questlog) do
        if string.find(string.lower((text or "")), string.lower(item), 1) then
          quest, level = GetQuestLogTitle(id)
          itemcache[item] = id
          break
        end
      end
    end

    -- mark non quest items
    if not itemcache[item] and not replace then
      itemcache[item] = false
      return
    end

    -- return on invalid/empty quest results
    if not quest then return end

    -- read difficulty color
    local color = GetDifficultyColor(level)

    -- read item counts
    if C.tooltip.questitem.showcount == "1" and itemcache[item] and itemcache[item] ~= false then
      local _, _, required = strfind(string.lower(questlog[itemcache[item]]), "_"..string.lower(item).."_(.-)_")
      if required then
        quest = string.format("%s |cffaaaaaa[%s/%s]", quest, (GetItemCount(item) or 0), required)
      end
    end

    -- add quest to quest item
    if replace then
      _G[frame:GetName().."TextLeft2"]:SetText("|cffffffff"..ITEM_BIND_QUEST..": |r" .. quest)
      _G[frame:GetName().."TextLeft2"]:SetTextColor(color.r, color.g, color.b)
    elseif quest ~= UNKNOWN then
      frame:AddLine("|cffffffff"..ITEM_BIND_QUEST..": |r" .. quest, color.r, color.g, color.b)
    end

    frame:Show()
  end

  -- initialize questlog scanner
  pfUI.questitem = CreateFrame("Frame", "pfQuestItemScanner", UIParent)
  pfUI.questitem:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.questitem:RegisterEvent("QUEST_LOG_UPDATE")
  pfUI.questitem:SetScript("OnEvent", function()
    -- queue update events to run in .5 seconds
    this.run = GetTime() + .5
  end)

  pfUI.questitem:SetScript("OnUpdate", function()
    if C.tooltip.questitem.showquest ~= "1" then return end

    -- skip if nothing to do
    if not this.run or GetTime() < this.run then return end

    -- clear item caches
    for name, quest in pairs(itemcache) do
      itemcache[name] = nil
    end

    -- reload quests
    local text, objective, objcount, objtext, header, _
    local logid = GetQuestLogSelection()
    for quest=1, 50 do
      SelectQuestLogEntry(quest)

      -- detect and ignore quest headers
      if pfUI.client <= 11200 then -- vanilla
        _, _, _, header = GetQuestLogTitle(quest)
      elseif pfUI.client > 11200 then -- tbc
        _, _, _, _, header = GetQuestLogTitle(quest)
      end

      if not header then
        text, objective = GetQuestLogQuestText()
        objcount = GetNumQuestLeaderBoards()
        questlog[quest] = string.format("%s:%s", (text or ""), (objective or ""))

        -- scan objectives
        if objcount > 0 then
          for i=1, objcount do
            objtext = GetQuestLogLeaderBoard(i)
            local _, _, obj, cur, req = strfind((objtext or ""), "(.*):%s*([%d]+)%s*/%s*([%d]+)")
            if obj and req then
              questlog[quest] = string.format("%s:_%s_%s_", questlog[quest], obj, req)
            else
              questlog[quest] = string.format("%s:%s", questlog[quest], (objtext or ""))
            end
          end
        end
      else
        questlog[quest] = nil
      end
    end

    -- restore questlog selection
    SelectQuestLogEntry(logid)
    this.run = nil
  end)

  -- reload quest entries on config change
  pfUI.questitem.UpdateConfig = function()
    pfUI.questitem.run = GetTime() + .5
  end

  -- add to regular tooltips
  pfUI.questitem.tooltip = CreateFrame("Frame", "pfQuestItems", GameTooltip )
  pfUI.questitem.tooltip:SetScript("OnShow", function()
    if libtooltip:GetItemLink() then
      local id = libtooltip:GetItemID()
      if not id then return end
      local name = GetItemInfo(id)
      AddTooltip(GameTooltip, name)
    end
  end)

  -- add to itemref tooltips
  local HookSetItemRef = SetItemRef
  _G.SetItemRef = function(link, text, button)
    HookSetItemRef(link, text, button)
    local item, _, id = string.find(link, "item:(%d+):.*")
    if not IsAltKeyDown() and not IsShiftKeyDown() and not IsControlKeyDown() and item then
      local name = GetItemInfo(id)
      AddTooltip(ItemRefTooltip, name)
    end
  end
end)
