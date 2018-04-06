pfUI:RegisterModule("hdgraphic", function ()
  -- pixel perfect
  local function pixelperfect()
    local conf = tonumber(C.global.pixelperfect)
    if conf < 4 then
      -- restore gamesettings
      local scale = GetCVar("uiScale")
      local use = GetCVar("useUiScale")

      if use == 1 then
        UIParent:SetScale(tonumber(use))
      else
        UIParent:SetScale(.9)
      end
    else
      -- apply pixel dependent scaling
      local resolution = GetCVar("gxResolution")

      for screenwidth, screenheight in string.gfind(resolution, "(.+)x(.+)") do
        local screenheight = tonumber(screenheight) / 8
        local scale = 768 / ( screenheight * conf )
        UIParent:SetScale(scale)
        UIParent:SetWidth(screenwidth)
        UIParent:SetHeight(screenheight)
        UIParent:SetPoint("CENTER",0,0)

        SetCVar("uiScale", scale)
        SetCVar("useUiScale", 1)
      end
    end
  end

  -- best graphic
  local function bestgraphic()
    if C.global.hdgraphic == "1" then
      ConsoleExec("anisotropic 16")
      ConsoleExec("detailDoodadAlpha 100")
      ConsoleExec("farclip 777")
      ConsoleExec("frillDensity 256")
      ConsoleExec("gxColorBits 24")
      ConsoleExec("gxDepthBits 24")
      ConsoleExec("gxMultisample 8")
      ConsoleExec("gxMultisampleQuality 1.000000")
      ConsoleExec("fullAlpha 1")
      ConsoleExec("lod 0")
      ConsoleExec("M2Faster 3")
      ConsoleExec("Gamma 0.8")
      ConsoleExec("lodDist 250")
      ConsoleExec("mapObjLightLOD 2")
      ConsoleExec("maxLOD 3")
      ConsoleExec("nearClip 0.33")
      ConsoleExec("particleDensity 1")
      ConsoleExec("pixelShaders 1")
      ConsoleExec("shadowLevel 0")
      ConsoleExec("SmallCull 0.01")
      ConsoleExec("trilinear 1")
      ConsoleExec("SkyCloudLOD 1")
      ConsoleExec("SkySunGlare 1")
      ConsoleExec("specular 1")
      ConsoleExec("textureLodDist 777")
      ConsoleExec("texLodBias -1")
      ConsoleExec("trilinear 1")
      ConsoleExec("unitDrawDist 300")
      ConsoleExec("weatherDensity 3")
      ConsoleExec("waterParticulates 1")
      ConsoleExec("waterRipples 1")
      ConsoleExec("waterSpecular 1")
      ConsoleExec("waterWaves 1")
      ConsoleExec("ffxDeath 1")
      ConsoleExec("ffx 1")
      ConsoleExec("ffxRectangle 1")
      ConsoleExec("ffxGlow 1")
      ConsoleExec("spellEffectLevel 2")
      ConsoleExec("occlusion 1")
      ConsoleExec("footstepBias 0.125")
      ConsoleExec("showfootprints 1")
      ConsoleExec("horizonfarclip 2112")
      ConsoleExec("baseMip 0")
      ConsoleExec("waterLOD 0")
      ConsoleExec("mapObjOverbright 1")
      ConsoleExec("MaxLights 4")
      ConsoleExec("DistCull 888")
      ConsoleExec("mapShadows 1")
      ConsoleExec("doodadAnim 1")
      ConsoleExec("showShadow 1")
      ConsoleExec("showLowDetail 0")
      ConsoleExec("showSimpleDoodads 0")
      ConsoleExec("gxTripleBuffer 1")
      ConsoleExec("M2UsePixelShaders 1")
      ConsoleExec("M2UseZFill 1")
      ConsoleExec("M2UseClipPlanes 1")
      ConsoleExec("M2UseThreads 1")
      ConsoleExec("M2UseShaders 1")
      ConsoleExec("M2BatchDoodads 1")
      ConsoleExec("bspcache 1")
      local cur, max = GetCurrentResolution(), table.getn({GetScreenResolutions()})
      if cur ~= max then
        SetScreenResolution(max)
        ConsoleExec("gxrestart")
        ReloadUI()
      end
    end
  end

  -- pixelperfect: native UIScale listener
  if tonumber(C.global.pixelperfect) > 0 then
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", pixelperfect)
  end

  pfUI.hdgraphic = {}
  function pfUI.hdgraphic:UpdateConfig()
    bestgraphic()
    pixelperfect()
  end

  pfUI.hdgraphic:UpdateConfig()
end)
