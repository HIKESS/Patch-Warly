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
version = "1.1.0"

api_version = 10
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false

description = [[
Patch mod for HIKESS's "NPC Friends" (workshop-3684000581), "Admin Panel"
(workshop-3678857150), and JingXi Furniture (workshop-3597024951).

Applies three fixes that run together with the original mods (dependencies
on the first two are kept; the third is optional / defensive):

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
   * Hides/blocks three specific crafts from the JingXi Furniture mod:
       - "gothic palace Strong light"
       - "rose red solid woodlamp"
       - "engraved candlestick"
   * The patch matches by display-name keywords (English + Chinese, since the
     mod is Chinese with an English translation) AND by candidate prefab-name
     patterns, so it works even without knowing the exact prefab names. If the
     JingXi Furniture mod is not installed, nothing matches and this is a no-op.
     The mod is NOT a hard dependency.

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
            and "Oculta/bloqueia 3 crafts do mod workshop-3597024951 (JingXi Furniture): gothic palace strong light, rose red solid woodlamp, engraved candlestick. No-op se o mod não estiver instalado."
            or "Hides/blocks 3 crafts from mod workshop-3597024951 (JingXi Furniture): gothic palace strong light, rose red solid woodlamp, engraved candlestick. No-op if the mod is not installed.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
    {
        name = "block_light_emitting_crafts",
        label = _is_pt and "Bloquear itens que emitem luz (mods)" or "Block light-emitting crafts (mods)",
        hover = _is_pt
            and "Procura crafts cujo nome indique emissao de luz (lamp/lantern/candle/灯/烛/强光...) em tabs de crafting MODDADAS (nao-vanilla) e os bloqueia. Assim tocha/fogueira/lanterna vanilla continuam craftaveis. Pega os 3 itens do JingXi E outros moveis de luz de mods."
            or "Scans crafts whose name indicates light emission (lamp/lantern/candle/灯/烛/强光...) in MODDED (non-vanilla) crafting tabs and blocks them. Vanilla torch/campfire/lantern stay craftable. Catches the 3 JingXi items AND other mods' light furniture.",
        options = {
            { description = _is_pt and "Ativado" or "Enabled",  data = true  },
            { description = _is_pt and "Desativado" or "Disabled", data = false },
        },
        default = true,
    },
}
