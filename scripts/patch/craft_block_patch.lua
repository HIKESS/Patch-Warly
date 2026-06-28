-- ============================================================================
--  craft_block_patch.lua
--  Patch para o mod workshop-3597024951 (JingXi Furniture / 景熹家居).
--
--  Bloqueia as FONTES DE LUZ do mod, controlado por config em duas fases.
--  Os nomes de prefab abaixo foram obtidos por ANÁLISE DIRETA do código-fonte
--  do mod em https://github.com/HIKESS/Mods/tree/main/3597024951 — não são
--  chutes. Cada prefab foi confirmado como:
--    (a) emissão de luz real (componente Light direto, ou spawn de light fx),
--    (b) craftável (registrado via AddRecipe2 em scripts/jxmain/jx_recipes.lua).
--
--  FASE 1 — block_jingxi_crafts: os 3 itens nomeados pelo usuario
--    Prefab                     Nome de exibição (EN)               Nome (ZH)
--    -------------------------  ----------------------------------  -----------
--    jx_mushroom_light          "Gothic Palace Streetlight"         哥特式宫廷道路灯
--    jx_mushroom_light_2        "RoseRed Solid Wood Lamp"           蔷薇红实木室内灯
--    jx_lamp_2                  "Engraved Candlestick"              雕花三臂欧式烛台
--
--  FASE 2 — block_light_emitting_crafts: TODAS as fontes de luz puras do mod
--    Prefab                     Nome de exibição (EN)               Nome (ZH)
--    -------------------------  ----------------------------------  -----------
--    jx_lamp                    "Vintage Embellished Bedside Lamp"  复古缀饰床头灯
--    jx_lantern                 "Gemstone Rose Night Patrol Light"  宝石玫瑰夜巡灯
--    jx_flashlight              "Miller's Flashlight"               米勒的手电筒
--    (+ os 3 da Fase 1)
--
--  NÃO bloqueamos itens funcionais onde a luz é efeito colateral (cookpot,
--  furnace, oven, toaster, charcoal_stove, portable_cook_pot, portabletent,
--  table_8, tv, vending_machine) — bloquear esses quebraria cozinha/aquecimento
--  e outras funções do mod. "Fonte de luz" = item cuja função PRIMÁRIA é
--  iluminar. Se quiser bloquear também esses, adicione os prefabs à lista
--  LIGHT_SOURCE_PREFABS abaixo.
--
--  ----------------------------------------------------------------------------
--  MECANISMO DE BLOQUEIO (tríplice, para máxima confiabilidade)
--  ----------------------------------------------------------------------------
--  Para cada recipe que casa:
--    1) recipe.builder_tag = "__warly_admin_patch_blocked"
--       → nenhum jogador tem essa tag, então Builder:CanMake() retorna false.
--    2) recipe.CanLearn = function() return false end
--       → Builder:KnowsRecipe() falha; recipe some do menu de crafting.
--    3) recipe.filters = {}  (Recipe2) / recipe.tab = nil  (Recipe antigo)
--       → o recipe não aparece em NENHUMA aba de crafting, porque o menu
--         itera filters para decidir onde mostrar cada recipe.
--  Os três mecanismos são redundantes: qualquer um já esconde o recipe; os
--  três juntos garantem que funcione em qualquer versão do DST e qualquer
--  filtro customizado (o JingXi usa filtro "JXTAB").
--
--  NÃO removemos o recipe de AllRecipes — outros mods que referenciem o
--  recipe continuam funcionando. Operação reversível e não destrutiva.
--
--  ----------------------------------------------------------------------------
--  TIMING / LOAD ORDER
--  ----------------------------------------------------------------------------
--  O scan roda em AddPrefabPostInit("world") + DoTaskInTime(0). No spawn do
--  prefab "world", TODOS os modmain já rodaram (host + clients, surface +
--  caves), então AllRecipes está totalmente populado. Guard por-recipe
--  (_patch_blocked) torna o scan idempotente.
-- ============================================================================

local _G = GLOBAL
local CFG = PATCH_CONFIG

-- Tag aplicada a recipes bloqueados. Nenhum jogador/entidade tem essa tag.
local BLOCK_TAG = "__warly_admin_patch_blocked"

-- ═══════════════════════════════════════════════════════════════════════════
--  Listas EXATAS de prefabs (da análise do código-fonte do mod)
-- ═══════════════════════════════════════════════════════════════════════════

-- Fase 1: os 3 itens nomeados pelo usuario.
local NAMED_PREFABS = {
    "jx_mushroom_light",    -- Gothic Palace Streetlight  / 哥特式宫廷道路灯
    "jx_mushroom_light_2",  -- RoseRed Solid Wood Lamp    / 蔷薇红实木室内灯
    "jx_lamp_2",            -- Engraved Candlestick       / 雕花三臂欧式烛台
}

-- Fase 2: TODAS as fontes de luz puras (função primária = iluminar) do mod.
-- Inclui os 3 da Fase 1 + os demais itens de luz craftáveis confirmados no
-- código-fonte como emissores de luz (componente Light direto ou spawn de
-- light fx).
local LIGHT_SOURCE_PREFABS = {
    -- Os 3 nomeados
    "jx_mushroom_light",    -- direct Light component
    "jx_mushroom_light_2",  -- direct Light component
    "jx_lamp_2",            -- direct Light component (candlestick)
    -- Demais fontes de luz puras
    "jx_lamp",              -- direct Light component (bedside lamp, fueled)
    "jx_lantern",           -- spawns "lanternlight" when equipped
    "jx_flashlight",        -- jx_flashlight component (held light)
}

-- Tabela de lookup rápida para a Fase 2 (set).
local _LIGHT_SET = {}
for _, p in ipairs(LIGHT_SOURCE_PREFABS) do
    _LIGHT_SET[p] = true
end

-- ═══════════════════════════════════════════════════════════════════════════
--  Bloqueio
-- ═══════════════════════════════════════════════════════════════════════════

--- Bloqueia um recipe: mecanismo triplo. Idempotente.
local function _block_recipe(recipe, reason)
    if not recipe then
        return false
    end
    if recipe._patch_blocked then
        return false
    end
    recipe._patch_blocked = true

    -- 1) builder_tag que nenhum jogador tem → Builder:CanMake() falha.
    recipe.builder_tag = BLOCK_TAG

    -- 2) CanLearn sempre false → Builder:KnowsRecipe() falha; recipe some.
    recipe.CanLearn = function()
        return false
    end

    -- 3) Limpa filters (Recipe2) / tab (Recipe antigo) → não aparece em
    --    nenhuma aba de crafting. O JingXi usa filtro customizado "JXTAB";
    --    esvaziar filters garante que o recipe não apareça ali.
    if type(recipe.filters) == "table" then
        for i = #recipe.filters, 1, -1 do
            recipe.filters[i] = nil
        end
    end
    -- Recipe antigo: limpa tab.
    recipe.tab = nil

    -- 4) Se houver método SetBuilderTag, chama (algumas versões cacheiam tags).
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

    -- Constroi sets ativos conforme config.
    local phase1_set = {}
    if CFG.block_jingxi_crafts then
        for _, p in ipairs(NAMED_PREFABS) do
            phase1_set[p] = true
        end
    end
    local phase2_active = CFG.block_light_emitting_crafts

    local blocked = 0

    -- Itera por nome direto (mais eficiente e confiável que varrer tudo).
    -- Fase 1: os 3 nomeados.
    if CFG.block_jingxi_crafts then
        for _, pname in ipairs(NAMED_PREFABS) do
            local recipe = AllRecipes[pname]
            if recipe then
                if _block_recipe(recipe, "phase1 named") then
                    blocked = blocked + 1
                end
            else
                print(string.format(
                    "[WarlyAdminPatch][CraftBlock] AVISO: recipe '%s' não encontrado em AllRecipes (mod 3597024951 não instalado?).",
                    pname))
            end
        end
    end

    -- Fase 2: demais fontes de luz (pula as 3 da Fase 1, já bloqueadas acima,
    -- embora o guard por-recipe tornaria isso seguro de qualquer forma).
    if phase2_active then
        for _, pname in ipairs(LIGHT_SOURCE_PREFABS) do
            if not phase1_set[pname] then
                local recipe = AllRecipes[pname]
                if recipe then
                    if _block_recipe(recipe, "phase2 light source") then
                        blocked = blocked + 1
                    end
                end
            end
        end
    end

    if blocked > 0 then
        print(string.format(
            "[WarlyAdminPatch][CraftBlock] %d recipe(s) de fonte de luz oculto(s)/bloqueado(s) " ..
            "(phase1_jingxi=%s phase2_light=%s).",
            blocked,
            tostring(CFG.block_jingxi_crafts),
            tostring(phase2_active)))
    else
        print("[WarlyAdminPatch][CraftBlock] nenhum recipe-alvo encontrado " ..
            "(mod 3597024951 não instalado — no-op).")
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
    "[WarlyAdminPatch][CraftBlock] PostInit('world') registrado — scan de fontes de luz no spawn " ..
    "(phase1_jingxi=%s phase2_light=%s).",
    tostring(CFG.block_jingxi_crafts),
    tostring(CFG.block_light_emitting_crafts)))
