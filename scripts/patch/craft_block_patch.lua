-- ============================================================================
--  craft_block_patch.lua
--  Patch para o mod workshop-3597024951 (JingXi Furniture) + bloqueio genérico
--  de itens que emitem luz.
--
--  Duas fases, controladas por config:
--
--  FASE 1 — block_jingxi_crafts (3 itens nomeados)
--     Oculta/bloqueia 3 crafts especificados pelo usuario:
--       1) "gothic palace Strong light"
--       2) "rose red solid woodlamp"
--       3) "engraved candlestick"
--     Match duplo: (A) nome de prefab snake_case, (B) nome de exibição com
--     grupos de palavras-chave em inglês E chinês. Robusto a locale e a
--     ausência do mod (no-op se JingXi não instalado).
--
--  FASE 2 — block_light_emitting_crafts (itens que emitem luz, genérico)
--     Procura por crafts cujo nome/prefab indique emissão de luz (lamp,
--     lantern, candle, 灯, 烛, 强光, etc.) e os bloqueia — MAS só em TABS DE
--     CRAFTING MODDADAS (não-vanilla). Assim a tocha/fogueira/lanterna vanilha
--     continuam craftáveis, e só mobs de furniture de mods (JingXi et al.)
--     têm seus itens de luz ocultados. Isso pega os 3 itens da Fase 1 (se
--     estiverem numa tab moddada) E quaisquer outros móveis de luz de mods.
--
--  ----------------------------------------------------------------------------
--  POR QUE DETECÇÃO DE LUZ POR VOCABULÁRIO + TAB MODDADA (e não spawn)
--  ----------------------------------------------------------------------------
--  A forma "pura" de detectar emissão de luz seria spawnar o prefab
--  temporariamente e checar `inst.components.light`. MAS:
--    * O menu de crafting é client-side — para OCULTAR um recipe em todos os
--      clientes, o `builder_tag` precisa ser setado no processo de CADA client.
--      Um scan só-server não esconde o recipe nos clients.
--    * Spawnar prefabs de estrutura em clients pode gerar som/partículas/
--      tráfego de rede indesejado, mesmo com Remove() imediato.
--  Solução segura e que roda idêntica em todos os processos: casar por
--  vocabulário de luz (nome do prefab + display name) E restringir à tabs de
--  crafting não-vanilla. Sem spawn, sem rede, sem side-effects.
--
--  ----------------------------------------------------------------------------
--  MECANISMO DE BLOQUEIO
--  ----------------------------------------------------------------------------
--  Para cada recipe que casa (em qualquer fase):
--    1) recipe.builder_tag = "__warly_admin_patch_blocked"
--       → nenhum jogador tem essa tag, então Builder:CanMake() retorna false
--         e o recipe não aparece no menu de crafting (ou aparece travado).
--    2) recipe.CanLearn = function() return false end
--       → backup: a checagem CanLearn do Recipe2 também falha.
--    3) recipe:SetBuilderTag(BLOCK_TAG) se existir o método.
--
--  NÃO removemos o recipe de AllRecipes — outros mods que referenciem o
--  recipe continuam funcionando. Operação reversível e não destrutiva.
--
--  ----------------------------------------------------------------------------
--  TIMING / LOAD ORDER
--  ----------------------------------------------------------------------------
--  O scan NÃO roda no modmain — roda em AddPrefabPostInit("world") com
--  DoTaskInTime(0). No spawn do prefab "world", TODOS os modmain já rodaram
--  (host + clients, surface + caves), então AllRecipes está totalmente
--  populado, independente da ordem de carga. Guard por-recipe (_patch_blocked)
--  torna o scan idempotente.
-- ============================================================================

local _G = GLOBAL
local CFG = PATCH_CONFIG

-- Tag aplicada a recipes bloqueados. Nenhum jogador/entidade tem essa tag.
local BLOCK_TAG = "__warly_admin_patch_blocked"

-- ═══════════════════════════════════════════════════════════════════════════
--  FASE 1 — padrões para os 3 itens nomeados
-- ═══════════════════════════════════════════════════════════════════════════

-- A) Candidatos de nome de prefab (snake_case). Igualdade OR substring (len>=5).
local PREFAB_PATTERNS = {
    -- gothic palace Strong light
    "gothic_palace_strong_light",
    "gothic_strong_light",
    "gothicpalace_stronglight",
    "gothic_stronglight",
    "gp_strong_light",
    -- rose red solid woodlamp
    "rose_red_solid_woodlamp",
    "rose_red_woodlamp",
    "rosered_solid_woodlamp",
    "rosesolid_woodlamp",
    "solid_woodlamp",
    -- engraved candlestick
    "engraved_candlestick",
    "carved_candlestick",
    "engravedcandlestick",
}

-- B) Grupos de palavras-chave do display name. Casa se contiver TODAS as
--    palavras de QUALQUER grupo (case-insensitive). EN + ZH.
local NAME_GROUPS = {
    -- gothic palace Strong light (EN)
    { "gothic", "strong" },
    { "gothic", "palace", "light" },
    -- 哥特宫殿强光 / 哥特强光灯 (ZH)
    { "哥特", "强光" },
    { "哥特", "宫殿" },
    { "哥特", "强光灯" },

    -- rose red solid woodlamp (EN)
    { "rose", "red", "woodlamp" },
    { "rose", "red", "wood lamp" },
    { "rose", "red", "wood", "lamp" },
    { "solid", "woodlamp" },
    { "rose red", "woodlamp" },
    -- 玫瑰红实木灯 / 玫红木灯 (ZH)
    { "玫瑰", "木灯" },
    { "玫红", "木灯" },
    { "玫瑰", "红", "灯" },
    { "玫瑰", "实木" },
    { "玫瑰红", "木灯" },

    -- engraved candlestick (EN)
    { "engraved", "candlestick" },
    { "carved", "candlestick" },
    -- 雕花烛台 / 雕刻烛台 (ZH)
    { "雕花", "烛台" },
    { "雕刻", "烛台" },
    { "雕", "烛台" },
}

-- ═══════════════════════════════════════════════════════════════════════════
--  FASE 2 — vocabulário de luz + tabs de crafting não-vanilla
-- ═══════════════════════════════════════════════════════════════════════════

-- Palavras que indicam emissão de luz (substring, case-insensitive).
-- Cuidado: NÃO inclui "light" puro (false-positivos: lightning, flight, ...).
-- "光" sozinho é mantido fora para evitar pescar 阳光/月光 em nomes de comida;
-- "强光" e "光柱" cobrem os casos de furniture. "灯"/"烛" são os mais fortes.
local LIGHT_KEYWORDS = {
    -- English
    "lamp", "lantern", "candle", "candlestick", "chandelier", "sconce",
    "brazier", "candelabra", "illumin", "beacon", "firelight", "woodlamp",
    "stronglight", "strong_light", "strong light", "torch", "lightbulb",
    "nightlight", "ceilinglight", "walllight", "streetlight", "streetlamp",
    "headlight", "floodlight", "spotlight", "lumin", "glowstone", "glowcap",
    -- Chinese (light-emitting furniture vocabulary)
    "灯", "烛", "烛台", "壁灯", "吊灯", "台灯", "路灯", "宫灯", "花灯",
    "强光", "照明", "明灯", "火炬", "光柱", "荧光灯",
}

-- Tabs de crafting VANILLA (RECIPETABS / CraftingFilter). Receitas cuja(s)
-- tab(s) sejam TODAS não-vanilla são candidatas à Fase 2. Isso impede
-- bloquear tocha/fogueira/lanterna/minerhat (tab LIGHT vanilla), etc.
local VANILLA_TABS = {
    SURVIVAL = true, TOOLS = true, LIGHT = true, FARM = true, SCIENCE = true,
    FIGHT = true, STRUCTURES = true, REFINE = true, COOK = true, DRESS = true,
    MAGIC = true, ANCIENT = true, DECOR = true, RUMMAGE = true, ARCHIVE = true,
    SEASONS = true, CITYMACHINES = true, LUNARPLANT = true, LUNAR = true,
    PLANTS = true, WINTER = true, EVENTS = true, BUILDER = true,
    -- Recipe2 crafting filter names (lowercase variants usadas por alguns mods)
    survival = true, tools = true, light = true, farm = true, science = true,
    fight = true, structures = true, refine = true, cook = true, dress = true,
    magic = true, ancient = true, decor = true, rummage = true, archive = true,
    seasons = true,
}

-- ═══════════════════════════════════════════════════════════════════════════
--  Helpers
-- ═══════════════════════════════════════════════════════════════════════════

local function _lower(s)
    return string.lower(tostring(s or ""))
end

--- Pega o display name localizado de um recipe a partir de STRINGS.NAMES.
local function _recipe_display_name(recipename)
    local STR = _G.STRINGS
    if STR and STR.NAMES then
        local key = string.upper(recipename)
        local v = STR.NAMES[key] or STR.NAMES[recipename]
        if type(v) == "string" and #v > 0 then
            return v
        end
    end
    return recipename
end

--- True se displayname contém TODAS as palavras-chave de algum grupo (Fase 1).
local function _name_matches_groups(displayname)
    local dl = _lower(displayname)
    for _, group in ipairs(NAME_GROUPS) do
        local all = true
        for _, kw in ipairs(group) do
            if not string.find(dl, _lower(kw), 1, true) then
                all = false
                break
            end
        end
        if all then
            return true
        end
    end
    return false
end

--- True se o nome do prefab casa com algum padrão da Fase 1.
local function _prefab_matches(recipename)
    local nl = _lower(recipename)
    for _, p in ipairs(PREFAB_PATTERNS) do
        local pl = _lower(p)
        if nl == pl then
            return true
        end
        if #pl >= 5 and string.find(nl, pl, 1, true) then
            return true
        end
    end
    return false
end

--- True se o texto (nome de prefab OU display name) contém algum keyword de luz.
local function _has_light_keyword(s)
    local sl = _lower(s)
    for _, kw in ipairs(LIGHT_KEYWORDS) do
        if string.find(sl, _lower(kw), 1, true) then
            return true, kw
        end
    end
    return false
end

--- Coleta os nomes de tab(s) de um recipe (Recipe antigo + Recipe2 filters).
local function _get_recipe_tab_names(recipe)
    local names = {}
    if recipe.tab then
        if type(recipe.tab) == "string" then
            table.insert(names, recipe.tab)
        elseif type(recipe.tab) == "table" then
            if type(recipe.tab.name) == "string" then
                table.insert(names, recipe.tab.name)
            end
            if type(recipe.tab.str) == "string" then
                table.insert(names, recipe.tab.str)
            end
        end
    end
    if recipe.filters and type(recipe.filters) == "table" then
        for _, f in ipairs(recipe.filters) do
            if type(f) == "string" then
                table.insert(names, f)
            elseif type(f) == "table" and type(f.name) == "string" then
                table.insert(names, f.name)
            end
        end
    end
    return names
end

--- True se o recipe está em uma tab NÃO-vanilla (todas as suas tabs são
--- modded). Se não houver info de tab, conserva: trata como vanilla (skip).
local function _is_modded_tab(recipe)
    local names = _get_recipe_tab_names(recipe)
    if #names == 0 then
        return false
    end
    for _, n in ipairs(names) do
        if VANILLA_TABS[n] or VANILLA_TABS[string.upper(n)] then
            return false
        end
    end
    return true
end

--- Bloqueia um recipe: seta builder_tag + CanLearn. Idempotente.
local function _block_recipe(recipe, reason)
    if not recipe then
        return false
    end
    if recipe._patch_blocked then
        return false
    end
    recipe._patch_blocked = true

    -- 1) Tag que nenhum jogador tem → CanMake falha → recipe some do menu.
    recipe.builder_tag = BLOCK_TAG

    -- 2) CanLearn sempre false (backup para Recipe2).
    recipe.CanLearn = function()
        return false
    end

    -- 3) Se houver método SetBuilderTag, chama (algumas versões cacheiam tags).
    if type(recipe.SetBuilderTag) == "function" then
        _G.pcall(function()
            recipe:SetBuilderTag(BLOCK_TAG)
        end)
    end

    print(string.format("[WarlyAdminPatch][CraftBlock] hid '%s' (%s)",
        tostring(recipe.name), reason))
    return true
end

-- ═══════════════════════════════════════════════════════════════════════════
--  Scan principal
-- ═══════════════════════════════════════════════════════════════════════════

local function _scan_and_block()
    local AllRecipes = _G.AllRecipes
    if not AllRecipes then
        print("[WarlyAdminPatch][CraftBlock] AllRecipes não disponível — nada feito.")
        return
    end

    local blocked = 0

    for name, recipe in pairs(AllRecipes) do
        if type(recipe) == "table" then
            local displayname = _recipe_display_name(name)
            local blocked_this = false

            -- ── FASE 1: 3 itens nomeados (prefab pattern OU name group) ──
            if CFG.block_jingxi_crafts and not recipe._patch_blocked then
                if _prefab_matches(name) then
                    blocked_this = _block_recipe(recipe, "phase1 prefab pattern")
                elseif _name_matches_groups(displayname) then
                    blocked_this = _block_recipe(recipe, "phase1 name keyword")
                end
            end

            -- ── FASE 2: itens que emitem luz em tabs MODDADAS ──
            -- (só roda se a Fase 1 não tiver bloqueado este recipe)
            if not blocked_this
               and CFG.block_light_emitting_crafts
               and not recipe._patch_blocked
            then
                if _is_modded_tab(recipe) then
                    local hit_prefab, kw_p = _has_light_keyword(name)
                    local hit_name, kw_n = _has_light_keyword(displayname)
                    if hit_prefab then
                        blocked_this = _block_recipe(recipe,
                            "phase2 light prefab '" .. tostring(kw_p) .. "'")
                    elseif hit_name then
                        blocked_this = _block_recipe(recipe,
                            "phase2 light name '" .. tostring(kw_n) .. "'")
                    end
                end
            end

            if blocked_this then
                blocked = blocked + 1
            end
        end
    end

    if blocked > 0 then
        print(string.format(
            "[WarlyAdminPatch][CraftBlock] %d recipe(s) oculto(s)/bloqueado(s) " ..
            "(phase1_jingxi=%s phase2_light=%s).",
            blocked,
            tostring(CFG.block_jingxi_crafts),
            tostring(CFG.block_light_emitting_crafts)))
    else
        print("[WarlyAdminPatch][CraftBlock] nenhum recipe-alvo encontrado " ..
            "(mods não instalados ou nomes divergem — no-op).")
    end
end

-- ──────────────────────────────────────────────────────────────────────────
--  Registro: scan no spawn do world (todos os modmain já rodaram).
--  AddPrefabPostInit("world") dispara em host, clients, surface e caves —
--  cada um tem seu próprio AllRecipes; o guard por-recipe evita duplo
--  trabalho caso o mesmo processo spawne world mais de uma vez.
-- ──────────────────────────────────────────────────────────────────────────
_G.pcall(function()
    AddPrefabPostInit("world", function(inst)
        if not inst then return end
        inst:DoTaskInTime(0, function()
            _G.pcall(_scan_and_block)
        end)
    end)
end)

print(string.format(
    "[WarlyAdminPatch][CraftBlock] PostInit('world') registrado — scan no spawn " ..
    "(phase1_jingxi=%s phase2_light=%s).",
    tostring(CFG.block_jingxi_crafts),
    tostring(CFG.block_light_emitting_crafts)))
