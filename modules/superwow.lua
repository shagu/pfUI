-- Compatibility layer to use castbars provided by SuperWoW:
-- https://github.com/balakethelock/SuperWoW

pfUI:RegisterModule("superwow", "vanilla", function ()
  if SetAutoloot and SpellInfo and not SUPERWOW_VERSION then
    -- Turn every enchanting link that we create in the enchanting frame,
    -- from "spell:" back into "enchant:". The enchant-version is what is
    -- used by all unmodified game clients. This is required to generate
    -- usable links for everyone from the enchant frame while having SuperWoW.
    local HookGetCraftItemLink = GetCraftItemLink
    _G.GetCraftItemLink = function(index)
      local link = HookGetCraftItemLink(index)
      return string.gsub(link, "spell:", "enchant:")
    end

    -- Convert every enchanting link that we receive into a
    -- spell link, as for some reason SuperWoW can't handle
    -- enchanting links at all and requires it to be a spell.
    local HookSetItemRef = SetItemRef
    _G.SetItemRef = function(link, text, button)
      link = string.gsub(link, "enchant:", "spell:")
      HookSetItemRef(link, text, button)
    end

    local HookGameTooltipSetHyperlink = GameTooltip.SetHyperlink
    _G.GameTooltip.SetHyperlink = function(self, link)
      link = string.gsub(link, "enchant:", "spell:")
      HookGameTooltipSetHyperlink(self, link)
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cffffffaaAn old version of SuperWoW was detected. Please consider updating:")
    DEFAULT_CHAT_FRAME:AddMessage("-> https://github.com/balakethelock/SuperWoW/releases/")
  end

  if SUPERWOW_VERSION == "1.5" then
    QueueFunction(function()
      local pfCombatText_AddMessage = _G.CombatText_AddMessage
      _G.CombatText_AddMessage = function(message, a, b, c, d, e, f)
        local match, _, hex = string.find(message, ".+ %[(0x.+)%]")
        if hex and UnitName(hex) then
          message = string.gsub(message, hex, UnitName(hex))
        end

        pfCombatText_AddMessage(message, a, b, c, d, e, f)
      end
    end)
  end

  -- Add native mouseover support
  if SUPERWOW_VERSION and pfUI.uf and pfUI.uf.mouseover then
    _G.SlashCmdList.PFCAST = function(msg)
      local func = loadstring(msg or "")
      local unit = "mouseover"

      if not UnitExists(unit) then
        local frame = GetMouseFocus()
        if frame.label and frame.id then
          unit = frame.label .. frame.id
        elseif UnitExists("target") then
          unit = "target"
        elseif GetCVar("autoSelfCast") == "1" then
          unit = "player"
        else
          return
        end
      end

      if func then
        -- set mouseover to target for script if needed
        local switch_target = not UnitIsUnit("target", unit)
        if switch_target then TargetUnit(unit) end
        func()
        if switch_target then TargetLastTarget() end
      else
        -- write temporary unit name
        pfUI.uf.mouseover.unit = unit

        -- cast spell to unitstr
        CastSpellByName(msg, unit)

        -- remove temporary mouseover unit
        pfUI.uf.mouseover.unit = nil
      end
    end
  end

  -- Add support for druid mana bars
  if SUPERWOW_VERSION and pfUI.uf and pfUI.uf.player and pfUI_config.unitframes.druidmanabar == "1" then
    local parent = pfUI.uf.player.power.bar
    local config = pfUI.uf.player.config
    local mana = config.defcolor == "0" and config.manacolor or pfUI_config.unitframes.manacolor
    local r, g, b, a = pfUI.api.strsplit(",", mana)
    local rawborder, default_border = GetBorderSize("unitframes")
    local _, class = UnitClass("player")
    local width = config.pwidth ~= "-1" and config.pwidth or config.width

    local fontname = pfUI.font_unit
    local fontsize = tonumber(pfUI_config.global.font_unit_size)
    local fontstyle = pfUI_config.global.font_unit_style

    if config.customfont == "1" then
      fontname = pfUI.media[config.customfont_name]
      fontsize = tonumber(config.customfont_size)
      fontstyle = config.customfont_style
    end

    local druidmana = CreateFrame("StatusBar", "pfDruidMana", UIParent)
    druidmana:SetFrameStrata(parent:GetFrameStrata())
    druidmana:SetFrameLevel(parent:GetFrameLevel() + 16)
    druidmana:SetStatusBarTexture(pfUI.media[config.pbartexture])
    druidmana:SetStatusBarColor(r, g, b, a)
    druidmana:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -2*default_border - config.pspace)
    druidmana:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, -2*default_border - config.pspace)
    druidmana:SetWidth(width)
    druidmana:SetHeight(tonumber(pfUI_config.unitframes.druidmanaheight) or 6)
    druidmana:EnableMouse(true)
    druidmana:Hide()

    UpdateMovable(druidmana)
    CreateBackdrop(druidmana)
    CreateBackdropShadow(druidmana)

    druidmana:RegisterEvent("UNIT_MANA")
    druidmana:RegisterEvent("UNIT_MAXMANA")
    druidmana:RegisterEvent("UNIT_DISPLAYPOWER")
    druidmana:SetScript("OnEvent", function()
      if UnitPowerType("player") == 0 then
        this:Hide()
        return
      end

      local _, mana = UnitMana("player")
      local _, max = UnitManaMax("player")
      local perc = math.ceil(mana / max * 100)
      if perc == 100 then
        this.text:SetText(string.format("%s", Abbreviate(mana)))
      else
        this.text:SetText(string.format("%s - %s%%", Abbreviate(mana), perc))
      end
      this:SetMinMaxValues(0, max)
      this:SetValue(mana)
      this:Show()
    end)

    druidmana.text = druidmana:CreateFontString("Status", "OVERLAY", "GameFontNormalSmall")
    druidmana.text:SetFontObject(GameFontWhite)
    druidmana.text:SetFont(fontname, fontsize, fontstyle)
    druidmana.text:SetPoint("RIGHT", -2*(default_border + config.txtpowerrightoffx), 0)
    druidmana.text:SetPoint("LEFT", 2*(default_border + config.txtpowerrightoffx), 0)
    druidmana.text:SetJustifyH("RIGHT")

    if config["powercolor"] == "1" then
      local r = ManaBarColor[0].r
      local g = ManaBarColor[0].g
      local b = ManaBarColor[0].b

      if pfUI_config.unitframes.pastel == "1" then
        druidmana.text:SetTextColor((r+.75)*.5, (g+.75)*.5, (b+.75)*.5, 1)
      else
        druidmana.text:SetTextColor(r, g, b, a)
      end
    end

    if pfUI_config.unitframes.druidmanatext == "1" then
      druidmana.text:Show()
    else
      druidmana.text:Hide()
    end

    if class ~= "DRUID" then
      druidmana:UnregisterAllEvents()
      druidmana:Hide()
    end
  end

  -- Add support for guid based focus frame
  if SUPERWOW_VERSION and pfUI.uf and pfUI.uf.focus then
    local focus = function(unitstr)
      -- try to read target's unit guid
      local _, guid = UnitExists(unitstr)

      if guid and pfUI.uf.focus then
        -- update focus frame
        pfUI.uf.focus.unitname = nil
        pfUI.uf.focus.label = guid
        pfUI.uf.focus.id = ""

        -- update focustarget frame
        pfUI.uf.focustarget.unitname = nil
        pfUI.uf.focustarget.label = guid .. "target"
        pfUI.uf.focustarget.id = ""
      end

      return guid
    end

    -- extend the builtin /focus slash command
    local legacyfocus = SlashCmdList.PFFOCUS
    function SlashCmdList.PFFOCUS(msg)
      -- try to perform guid based focus
      local guid = focus("target")

      -- run old focus emulation
      if not guid then legacyfocus(msg) end
    end

    -- extend the builtin /swapfocus slash command
    local legacyswapfocus = SlashCmdList.PFSWAPFOCUS
    function SlashCmdList.PFSWAPFOCUS(msg)
      -- save previous focus values
      local oldlabel = pfUI.uf.focus.label or ""
      local oldid = pfUI.uf.focus.id or ""

      -- try to perform guid based focus
      local guid = focus("target")

      -- target old focus
      if guid and oldlabel and oldid then
        TargetUnit(oldlabel..oldid)
      end

      -- run old focus emulation
      if not guid then legacyswapfocus(msg) end
    end
  end

  -- Enhance libdebuff with SuperWoW data
  local superdebuff = CreateFrame("Frame")
  superdebuff:RegisterEvent("UNIT_CASTEVENT")
  superdebuff:SetScript("OnEvent", function()
    -- variable assignments
    local caster, target, event, spell, duration = arg1, arg2, arg3, arg4

    -- skip other caster and empty target events
    local _, guid = UnitExists("player")
    if caster ~= guid then return end
    if event ~= "CAST" then return end
    if not target or target == "" then return end

    -- assign all required data
    local unit = UnitName(target)
    local unitlevel = UnitLevel(target)
    local effect, rank = SpellInfo(spell)
    local duration = libdebuff:GetDuration(effect, rank)
    local caster = "player"

    -- add effect to current debuff data
    libdebuff:AddEffect(unit, unitlevel, effect, duration, caster)
  end)

  -- Enhance libcast with SuperWoW data
  local supercast = CreateFrame("Frame")
  supercast:RegisterEvent("UNIT_CASTEVENT")
  supercast:SetScript("OnEvent", function()
    if not supercast.init then
      -- disable combat parsing events in superwow mode
      libcast:UnregisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
      libcast:UnregisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
      supercast.init = true
    end

    if arg3 == "START" or arg3 == "CAST" or arg3 == "CHANNEL" then
      -- human readable argument list
      local guid = arg1
      local target = arg2
      local event_type = arg3
      local spell_id = arg4
      local timer = arg5
      local start = GetTime()

      -- get spell info from spell id
      local spell, icon, _
      if SpellInfo and SpellInfo(spell_id) then
        spell, _, icon = SpellInfo(spell_id)
      end

      -- set fallback values
      spell = spell or UNKNOWN
      icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark"

      -- skip on buff procs during cast
      if event_type == "CAST" then
        if not libcast.db[guid] or libcast.db[guid].cast ~= spell then
          -- ignore casts without 'START' event, while there is already another cast.
          -- those events can be for example a frost shield proc while casting frostbolt.
          -- we want to keep the cast itself, so we simply skip those.
          return
        end
      end

      -- add cast action to the database
      if not libcast.db[guid] then libcast.db[guid] = {} end
      libcast.db[guid].cast = spell
      libcast.db[guid].rank = nil
      libcast.db[guid].start = GetTime()
      libcast.db[guid].casttime = timer
      libcast.db[guid].icon = icon
      libcast.db[guid].channel = event_type == "CHANNEL" or false

      -- write state variable
      superwow_active = true
    elseif arg3 == "FAIL" then
      local guid = arg1

      -- delete all cast entries of guid
      if libcast.db[guid] then
        libcast.db[guid].cast = nil
        libcast.db[guid].rank = nil
        libcast.db[guid].start = nil
        libcast.db[guid].casttime = nil
        libcast.db[guid].icon = nil
        libcast.db[guid].channel = nil
      end
    end
  end)
end)
