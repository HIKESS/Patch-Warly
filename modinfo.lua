-- ============================================================================
--  Warly Kitchen + Admin Revive + Craft Block Patch
--  Um único patch para mods do repositório HIKESS/Mods + Steam Workshop:
--    * workshop-3684000581  (NPC Friends / 橘子的NPC小伙伴)
--    * workshop-3678857150  (Admin Panel / 橘子的超级管理员)
--    * workshop-3597024951  (JingXi Furniture — bloqueio de crafts, opcional)
--
--  O patch NÃO remove a dependência do mod de admin — ele carrega DEPOIS dos
--  dois mods originais (declarado em `dependencies`) e apenas neutraliza os
--  comportamentos indesejados, mantendo todo o resto funcionando. O bloqueio
--  de crafts do JingXi Furniture é defensivo: se o mod não estiver instalado,
--  o patch simplesmente não encontra nada para bloquear (no-op).
-- ============================================================================

local _locale = locale or ""
local _is_pt = _locale == "pt" or _locale == "ptbr" or _locale == "brazilian"

name = "Warly Kitchen + Admin Revive + Craft Block Patch"
author = "HIKESS patch"
version = "1.6.1"

api_version = 10
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false

description = [[
Patch mod for HIKESS's "NPC Friends" (workshop-3684000581), "Admin Panel"
(workshop-3678857150), JingXi Furniture (workshop-3597024951), a crash
compatibility fix between [API] Gem Core (workshop-1378549454) and
Craft Menu Tweak (workshop-2784074596), and a PT-BR translation for the
"API storybook" book item from Additional Item Package (workshop-1085586145).

Applies five patches that run together with the original mods (dependencies
on the first two are kept; the rest are optional / defensive):

1) NPC Friends - Warly
   * Removes Warly's auto-built kitchen (cookpot + icebox + 2 chests) that is
     spawned right at the start of the game.
   * Fixes cooked-food storage: Warly no longer only uses his own fridge (and
     then falls back to chests). Warly now prioritizes the NEAREST container
     tagged "freezer", then the nearest "fridge"-tagged container, before any
     chest. This is the "closest freezer" fix.
   * Warly now cooks in ALL nearby cookpots / portable cookpots, not only the
     single fixed cookpot at his _cooking_center.

2) Admin Panel
   * Disables the resurrect/respawn feature (right-click ghost revive and the
     panel "Revive" button) to stop infinite self-revive / auto-resurrection
     abuse. All other admin features (panel, item view/take/give, full restore,
     NPC status, etc.) keep working. The dependency on workshop-3678857150 is
     NOT removed.

3) JingXi Furniture (workshop-3597024951) — optional craft block
   * Blocks the LIGHT SOURCES of the mod. Prefab names were obtained by direct
     source analysis of the mod repo (github.com/HIKESS/Mods/3597024951), so
     matching is exact (not vocabulary-based).
   * Phase 1 (block_jingxi_crafts): the 3 named items —
       - jx_mushroom_light   ("Gothic Palace Streetlight"  / 哥特式宫廷道路灯)
       - jx_mushroom_light_2 ("RoseRed Solid Wood Lamp"    / 蔷薇红实木室内灯)
       - jx_lamp_2           ("Engraved Candlestick"       / 雕花三臂欧式烛台)
   * Phase 2 (block_light_emitting_crafts): ALL pure light sources of the mod —
       - jx_lamp      ("Vintage Embellished Bedside Lamp" / 复古缀饰床头灯)
       - jx_lantern   ("Gemstone Rose Night Patrol Light" / 宝石玫瑰夜巡灯)
       - jx_flashlight("Miller's Flashlight"              / 米勒的手电筒)
       - + the 3 from Phase 1.
   * WHITELIST (allow_*): each light source can be individually UN-blocked even
     when the block options above are enabled. Use this to keep the lantern(s)
     you want while still blocking the rest. Set allow_jx_lantern=true to keep
     the night patrol lantern, allow_jx_flashlight=true to keep the flashlight,
     allow_jx_lamp=true to keep the bedside lamp, etc.
   * Functional items where light is a side-effect (cookpot, furnace, oven,
     toaster, charcoal_stove, portable cookpots, portabletent, table_8, tv,
     vending_machine) are NOT blocked, to preserve cooking/heating features.
   * If the JingXi Furniture mod is not installed, nothing matches (no-op).
     The mod is NOT a hard dependency.

4) Gem Core + Craft Menu Tweak crash fix (fix_gemcore_craftmenu_crash)
   * Fixes the crash:
       "attempt to call method 'HasGemDictIngredients' (a nil value)"
       at gemdictionary/ui.lua:249 in CraftingMenuIngredients:SetRecipe
     that occurs when hovering a PinSlot pinned to a FILTER recipe
     (e.g. filter_ARMOUR) created by Craft Menu Tweak's pin-bar feature.
     Gem Core hooks SetRecipe and calls self:HasGemDictIngredients(recipe),
     but that method is nil for filter recipes / when craftinghighlight is off.
   * The fix installs a safe fallback HasGemDictIngredients on the
     CraftingMenuIngredients widget class (returns false -> no highlighting
     -> no crash), re-checked at world load for load-order robustness.
   * Defensive: no-op if Gem Core is not installed.

5) Additional Item Package storybook PT-BR translation (translate_aip_storybook)
   * The mod workshop-1085586145 (Additional Item Package) has a "Portuguese"
     language option in its config, but the workshop version does NOT include
     the portuguese.lua story file nor the LANG_MAP entry in the storybook
     widget. Selecting "Portuguese" falls back to English.
   * This patch injects a full PT-BR translation (18 chapters of story prose)
     for the "API storybook" book item via a require() hook: when the AIP
     storybook widget loads its fallback English data and the AIP language is
     set to "Portuguese", the hook returns the PT-BR translation instead.
   * Only the storybook book item is translated. Item names, UI labels, and
     other mod strings are untouched.
   * Defensive: no-op if AIP is not installed, or if its language is not
     "Portuguese".

6) JingXi Furniture item descriptions PT-BR (translate_jx_descriptions)
   * The mod workshop-3597024951 (JingXi Furniture) has two language files
     (jx_en.lua / jx_ch.lua) auto-selected by DST locale. PT-BR players get
     the English file — all furniture items show English descriptions in the
     crafting menu and when examined.
   * This patch overrides STRINGS.RECIPE_DESC and STRINGS.CHARACTERS.GENERIC.
     DESCRIBE with PT-BR translations for ALL ~188 items of the mod (lamps,
     furniture, decor, rugs, walls, turfs, tools, food, vehicles, etc.).
   * Item NAMES are NOT translated (per user request — only descriptions).
   * Also fixes two bugs in the English source file: the CHESSPIECES_JX plural
     typo (should be singular CHESSPIECE_JX) and the JX_RUG_TRIANGLE overwrite
     bug (the EN file accidentally clobbered JX_RUG_FOREST instead of setting
     JX_RUG_TRIANGLE).
   * Defensive: no-op if JingXi is not installed (orphan STRINGS entries are
     never read). Default: Enabled.

7) Additional Item Package item descriptions PT-BR (translate_aip_descriptions)
   * The mod workshop-1085586145 (AIP) uses a per-prefab LANG_MAP pattern. Only
     ~5 prefabs + 17 foods have a Portuguese section; the rest fall back to
     English when the user selects "Portuguese" in the AIP config.
   * This patch overrides STRINGS.RECIPE_DESC and STRINGS.CHARACTERS.GENERIC.
     DESCRIBE with PT-BR translations for ALL craftable AIP items, plus the
     dynamic-loop items: 8 chesspieces, 11 inscriptions, 36 foods (base) +
     108 spice variants (garlic/sugar/chili), 9 veggies, 6 livers, 6 element
     guards, 4 rubik fire colors, sunflower stages, breadfruit tree stages,
     and 5 torch stands.
   * Item NAMES are NOT translated (per user request — only descriptions).
   * aip_pet_* items are NOT translated (they inherit from vanilla DST, which
     already has PT-BR).
   * Gated on AIP language="portuguese" — respects the user's AIP language
     choice. Defensive: no-op if AIP is not installed or language is not
     "Portuguese".

Load order for (1) and (2) is handled by the declared dependencies.
]]

-- Dependências: garante que os dois mods originais carreguem ANTES deste patch.
dependencies = {
    ["workshop-3684000581"] = true, -- NPC Friends
    ["workshop-3678857150"] = true, -- Admin Panel
}

configuration_options = {
    {
        name = "remove_warly_kitchen",
        label = _is_pt and "Remover cozinha do Warly" or "Remove Warly kitchen",
        hover = _is_pt
            and "Remove a criação automática da cozinha completa (bau/panela/geladeira) no inicio do jogo."
            or "Remove Warly's auto-built kitchen (chest/pot/fridge) at the start of the game.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
    {
        name = "freezer_priority_storage",
        label = _is_pt and "Priorizar freezer (comida)" or "Prioritize freezer (food)",
        hover = _is_pt
            and "Guarda comida cozida no freezer mais proximo (tag 'freezer'), depois na geladeira mais proxima, antes dos baus."
            or "Store cooked food in the nearest freezer ('freezer' tag), then nearest fridge, before chests.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
    {
        name = "freezer_search_radius",
        label = _is_pt and "Raio de busca (freezer)" or "Search radius (freezer)",
        hover = _is_pt
            and "Distancia maxima de busca por freezers/geladeiras ao redor do NPC."
            or "Max search distance for freezers/fridges around the NPC.",
        options = {
            { description = "30", data = 30 },
            { description = "40", data = 40 },
            { description = "50", data = 50 },
            { description = "60", data = 60 },
            { description = "80", data = 80 },
        },
        default = 60,
    },
    {
        name = "block_admin_revive",
        label = _is_pt and "Bloquear ressurreição (admin)" or "Block resurrect (admin)",
        hover = _is_pt
            and "Bloqueia a ressurreição/auto-ressurreição do painel admin (botao Reviver + clique-direito em fantasma)."
            or "Blocks resurrect/auto-resurrect from the admin panel (Revive button + right-click ghost).",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
    {
        name = "use_all_nearby_cookpots",
        label = _is_pt and "Usar todas as cookpots próximas" or "Use all nearby cookpots",
        hover = _is_pt
            and "O Warly passa a cozinhar em TODAS as cookpots/portable cookpots ao redor dele, não só na cookpot fixa do _cooking_center."
            or "Warly cooks in ALL cookpots/portable cookpots around him, not only the fixed cookpot at _cooking_center.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
    {
        name = "block_jingxi_crafts",
        label = _is_pt and "Bloquear crafts (JingXi Furniture)" or "Block crafts (JingXi Furniture)",
        hover = _is_pt
            and "Oculta/bloqueia os 3 crafts nomeados do mod workshop-3597024951 (JingXi Furniture) pelos nomes EXATOS de prefab: jx_mushroom_light (Gothic Palace Streetlight), jx_mushroom_light_2 (RoseRed Solid Wood Lamp), jx_lamp_2 (Engraved Candlestick). No-op se o mod não estiver instalado."
            or "Hides/blocks the 3 named crafts from mod workshop-3597024951 (JingXi Furniture) by EXACT prefab names: jx_mushroom_light (Gothic Palace Streetlight), jx_mushroom_light_2 (RoseRed Solid Wood Lamp), jx_lamp_2 (Engraved Candlestick). No-op if the mod is not installed.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
    {
        name = "block_light_emitting_crafts",
        label = _is_pt and "Bloquear fontes de luz (JingXi)" or "Block light sources (JingXi)",
        hover = _is_pt
            and "Bloqueia TODAS as fontes de luz puras do mod JingXi (nomes EXATOS de prefab do código-fonte): jx_lamp, jx_lamp_2, jx_mushroom_light, jx_mushroom_light_2, jx_lantern, jx_flashlight. NÃO bloqueia itens funcionais onde luz é efeito colateral (cookpot/forno/TV/etc.) — preserva cozinha e aquecimento."
            or "Blocks ALL pure light sources of the JingXi mod (EXACT prefab names from source): jx_lamp, jx_lamp_2, jx_mushroom_light, jx_mushroom_light_2, jx_lantern, jx_flashlight. Does NOT block functional items where light is a side-effect (cookpot/oven/TV/etc.) — preserves cooking and heating.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
    -- ──────────────────────────────────────────────────────────────────────
    --  Patch 4: compat Gem Core (workshop-1378549454) + Craft Menu Tweak
    --           (workshop-2784074596). Corrige o crash "attempt to call
    --           method 'HasGemDictIngredients' (a nil value)" ao passar o
    --           mouse sobre um PinSlot fixado em um recipe de FILTER (ex.:
    --           filter_ARMOUR). Defensive: no-op se o Gem Core não existir.
    -- ──────────────────────────────────────────────────────────────────────
    {
        name = "fix_gemcore_craftmenu_crash",
        label = _is_pt and "Corrigir crash Gem Core + Craft Menu" or "Fix Gem Core + Craft Menu crash",
        hover = _is_pt
            and "Corrige o crash 'attempt to call method HasGemDictIngredients (a nil value)' que acontece ao passar o mouse sobre um PinSlot fixado em um recipe de FILTER (ex.: filter_ARMOUR) criado pelo Craft Menu Tweak. O Gem Core (workshop-1378549454) faz hook do SetRecipe do widget de ingredientes e chama self:HasGemDictIngredients(recipe), mas esse metodo é nil para filter recipes / quando o highlighting está desligado. O patch instala um fallback seguro (retorna false) na classe do widget. Defensive: no-op se o Gem Core não estiver instalado."
            or "Fixes the 'attempt to call method HasGemDictIngredients (a nil value)' crash that happens when hovering a PinSlot pinned to a FILTER recipe (e.g. filter_ARMOUR) created by Craft Menu Tweak. Gem Core (workshop-1378549454) hooks the ingredient widget's SetRecipe and calls self:HasGemDictIngredients(recipe), but that method is nil for filter recipes / when highlighting is off. The patch installs a safe fallback (returns false) on the widget class. Defensive: no-op if Gem Core is not installed.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
    -- ──────────────────────────────────────────────────────────────────────
    --  Patch 5: Additional Item Package (workshop-1085586145) — tradução
    --           PT-BR do livro "API storybook". Defensive: no-op se o mod
    --           AIP não estiver instalado ou se o idioma não for "portuguese".
    -- ──────────────────────────────────────────────────────────────────────
    {
        name = "translate_aip_storybook",
        label = _is_pt and "Traduzir livro API storybook (PT-BR)" or "Translate API storybook book (PT-BR)",
        hover = _is_pt
            and "Injeta a tradução PT-BR do livro 'API storybook' do mod Additional Item Package (workshop-1085586145). O mod AIP tem uma opção de idioma 'Portuguese' no config, mas a versão de workshop não inclui o arquivo de tradução — selecionar 'Portuguese' faz o livro cair no fallback English. Este patch corrige isso via hook de require(): quando o widget do livro carrega os dados em inglês (fallback) e o idioma do AIP está em 'Portuguese', o hook retorna a tradução PT-BR no lugar. Apenas o conteúdo do livro storybook é traduzido (18 capítulos). Defensive: no-op se o mod AIP não estiver instalado ou se o idioma não for 'Portuguese'."
            or "Injects the PT-BR translation of the 'API storybook' book item from the Additional Item Package mod (workshop-1085586145). The AIP mod has a 'Portuguese' language option in its config, but the workshop version does not include the translation file — selecting 'Portuguese' falls back to English. This patch fixes that via a require() hook: when the storybook widget loads its fallback English data and the AIP language is set to 'Portuguese', the hook returns the PT-BR translation instead. Only the storybook book content is translated (18 chapters). Defensive: no-op if the AIP mod is not installed or if its language is not 'Portuguese'.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
    -- ──────────────────────────────────────────────────────────────────────
    --  Patch 6: JingXi Furniture (workshop-3597024951) — tradução PT-BR
    --           das descrições (RECIPE_DESC + DESCRIBE) dos itens. NÃO
    --           traduz nomes (NAMES). Defensive: no-op se o mod não existir.
    -- ──────────────────────────────────────────────────────────────────────
    {
        name = "translate_jx_descriptions",
        label = _is_pt and "Traduzir descrições (JingXi Furniture, PT-BR)" or "Translate descriptions (JingXi Furniture, PT-BR)",
        hover = _is_pt
            and "Sobrescreve STRINGS.RECIPE_DESC e STRINGS.CHARACTERS.GENERIC.DESCRIBE com traduções PT-BR para TODOS os ~188 itens do mod JingXi Furniture (workshop-3597024951): abajures, móveis, decoração, tapetes, paredes, turfs, ferramentas, comidas, veículos, etc. NÃO traduz nomes dos itens (STRINGS.NAMES) — apenas descrições. O mod JingXi carrega inglês para locales não-chineses, então jogadores PT-BR veem tudo em inglês por padrão. Este patch corrige isso. Também fixa 2 bugs do arquivo EN: o typo plural CHESSPIECES_JX (deveria ser singular) e o bug de overwrite do JX_RUG_TRIANGLE. Defensive: no-op se o JingXi não estiver instalado. Default: Ativado."
            or "Overrides STRINGS.RECIPE_DESC and STRINGS.CHARACTERS.GENERIC.DESCRIBE with PT-BR translations for ALL ~188 items of the JingXi Furniture mod (workshop-3597024951): lamps, furniture, decor, rugs, walls, turfs, tools, food, vehicles, etc. Does NOT translate item names (STRINGS.NAMES) — descriptions only. The JingXi mod loads English for non-Chinese locales, so PT-BR players see everything in English by default. This patch fixes that. Also fixes 2 EN-file bugs: the CHESSPIECES_JX plural typo (should be singular) and the JX_RUG_TRIANGLE overwrite bug. Defensive: no-op if JingXi is not installed. Default: Enabled.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
    -- ──────────────────────────────────────────────────────────────────────
    --  Patch 7: Additional Item Package (workshop-1085586145) — tradução
    --           PT-BR das descrições (RECIPE_DESC + DESCRIBE) dos itens.
    --           Gated em AIP language=portuguese. Defensive: no-op se o
    --           AIP não estiver instalado ou se o idioma não for portuguese.
    -- ──────────────────────────────────────────────────────────────────────
    {
        name = "translate_aip_descriptions",
        label = _is_pt and "Traduzir descrições (AIP itens, PT-BR)" or "Translate descriptions (AIP items, PT-BR)",
        hover = _is_pt
            and "Sobrescreve STRINGS.RECIPE_DESC e STRINGS.CHARACTERS.GENERIC.DESCRIBE com traduções PT-BR para TODOS os itens craftáveis do mod Additional Item Package (workshop-1085586145), mais comidas (36 bases + 108 variantes com especiarias), veggies, chesspieces, inscrições, guardiões elementais, livers, rubik fire, sunflower, breadfruit tree, e torch stands. NÃO traduz nomes (NAMES) — apenas descrições. NÃO traduz aip_pet_* (herdam do vanilla DST). Gated em AIP language=portuguese: só aplica quando o config de idioma do AIP está em 'Portuguese' (respeita a escolha do usuário). Defensive: no-op se o AIP não estiver instalado ou se o idioma não for 'Portuguese'. Default: Ativado."
            or "Overrides STRINGS.RECIPE_DESC and STRINGS.CHARACTERS.GENERIC.DESCRIBE with PT-BR translations for ALL craftable items of the Additional Item Package mod (workshop-1085586145), plus foods (36 base + 108 spice variants), veggies, chesspieces, inscriptions, element guards, livers, rubik fire, sunflower, breadfruit tree, and torch stands. Does NOT translate names (NAMES) — descriptions only. Does NOT translate aip_pet_* (they inherit from vanilla DST). Gated on AIP language=portuguese: only applies when the AIP language config is set to 'Portuguese' (respects the user's choice). Defensive: no-op if AIP is not installed or if its language is not 'Portuguese'. Default: Enabled.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
    -- ──────────────────────────────────────────────────────────────────────
    --  WHITELIST: opções para NÃO bloquear itens específicos.
    --  Cada opção abaixo, quando Ativada, impede que o item correspondente
    --  seja bloqueado — mesmo com block_jingxi_crafts e/ou
    --  block_light_emitting_crafts ativados. Útil para manter as lanternas
    --  / lampadas / flashlight que voce quer, enquanto bloqueia o resto.
    -- ──────────────────────────────────────────────────────────────────────
    {
        name = "allow_jx_lantern",
        label = _is_pt and "NÃO bloquear a lanterna (jx_lantern)" or "Do NOT block lantern (jx_lantern)",
        hover = _is_pt
            and "WHITELIST: quando Ativado, o item jx_lantern (Gemstone Rose Night Patrol Light / 宝石玫瑰夜巡灯) NÃO será bloqueado, mesmo se 'Bloquear fontes de luz' estiver Ativado. Use para manter a lanterna de patrulha noturna craftável."
            or "WHITELIST: when Enabled, the item jx_lantern (Gemstone Rose Night Patrol Light / 宝石玫瑰夜巡灯) will NOT be blocked, even if 'Block light sources' is Enabled. Use this to keep the night patrol lantern craftable.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = false,
    },
    {
        name = "allow_jx_flashlight",
        label = _is_pt and "NÃO bloquear a lanterna (jx_flashlight)" or "Do NOT block flashlight (jx_flashlight)",
        hover = _is_pt
            and "WHITELIST: quando Ativado, o item jx_flashlight (Miller's Flashlight / 米勒的手电筒) NÃO será bloqueado, mesmo se 'Bloquear fontes de luz' estiver Ativado. Use para manter a lanterna de mão craftável."
            or "WHITELIST: when Enabled, the item jx_flashlight (Miller's Flashlight / 米勒的手电筒) will NOT be blocked, even if 'Block light sources' is Enabled. Use this to keep the handheld flashlight craftable.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = false,
    },
    {
        name = "allow_jx_lamp",
        label = _is_pt and "NÃO bloquear a lampada (jx_lamp)" or "Do NOT block bedside lamp (jx_lamp)",
        hover = _is_pt
            and "WHITELIST: quando Ativado, o item jx_lamp (Vintage Embellished Bedside Lamp / 复古缀饰床头灯) NÃO será bloqueado, mesmo se 'Bloquear fontes de luz' estiver Ativado. Use para manter o abajur de cabeceira craftável."
            or "WHITELIST: when Enabled, the item jx_lamp (Vintage Embellished Bedside Lamp / 复古缀饰床头灯) will NOT be blocked, even if 'Block light sources' is Enabled. Use this to keep the bedside lamp craftable.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = false,
    },
    {
        name = "allow_jx_mushroom_light",
        label = _is_pt and "NÃO bloquear (jx_mushroom_light)" or "Do NOT block streetlight (jx_mushroom_light)",
        hover = _is_pt
            and "WHITELIST: quando Ativado, o item jx_mushroom_light (Gothic Palace Streetlight / 哥特式宫廷道路灯) NÃO será bloqueado, mesmo se 'Bloquear crafts (JingXi)' e/ou 'Bloquear fontes de luz' estiverem Ativados."
            or "WHITELIST: when Enabled, the item jx_mushroom_light (Gothic Palace Streetlight / 哥特式宫廷道路灯) will NOT be blocked, even if 'Block crafts (JingXi)' and/or 'Block light sources' are Enabled.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = false,
    },
    {
        name = "allow_jx_mushroom_light_2",
        label = _is_pt and "NÃO bloquear (jx_mushroom_light_2)" or "Do NOT block lamp (jx_mushroom_light_2)",
        hover = _is_pt
            and "WHITELIST: quando Ativado, o item jx_mushroom_light_2 (RoseRed Solid Wood Lamp / 蔷薇红实木室内灯) NÃO será bloqueado, mesmo se 'Bloquear crafts (JingXi)' e/ou 'Bloquear fontes de luz' estiverem Ativados."
            or "WHITELIST: when Enabled, the item jx_mushroom_light_2 (RoseRed Solid Wood Lamp / 蔷薇红实木室内灯) will NOT be blocked, even if 'Block crafts (JingXi)' and/or 'Block light sources' are Enabled.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = false,
    },
    {
        name = "allow_jx_lamp_2",
        label = _is_pt and "NÃO bloquear (jx_lamp_2)" or "Do NOT block candlestick (jx_lamp_2)",
        hover = _is_pt
            and "WHITELIST: quando Ativado, o item jx_lamp_2 (Engraved Candlestick / 雕花三臂欧式烛台) NÃO será bloqueado, mesmo se 'Bloquear crafts (JingXi)' e/ou 'Bloquear fontes de luz' estiverem Ativados."
            or "WHITELIST: when Enabled, the item jx_lamp_2 (Engraved Candlestick / 雕花三臂欧式烛台) will NOT be blocked, even if 'Block crafts (JingXi)' and/or 'Block light sources' are Enabled.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = false,
    },
}
