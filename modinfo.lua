-- ============================================================================
--  Warly Kitchen + Admin Revive Patch
--  Um único patch para dois mods do repositório HIKESS/Mods:
--    * workshop-3684000581  (NPC Friends / 橘子的NPC小伙伴)
--    * workshop-3678857150  (Admin Panel / 橘子的超级管理员)
--
--  O patch NÃO remove a dependência do mod de admin — ele carrega DEPOIS dos
--  dois mods originais (declarado em `dependencies`) e apenas neutraliza os
--  comportamentos indesejados, mantendo todo o resto funcionando.
-- ============================================================================

local _locale = locale or ""
local _is_pt = _locale == "pt" or _locale == "ptbr" or _locale == "brazilian"

name = "Warly Kitchen + Admin Revive Patch"
author = "HIKESS patch"
version = "1.0.0"

api_version = 10
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false

description = [[
Patch mod for HIKESS's "NPC Friends" (workshop-3684000581) and "Admin Panel" (workshop-3678857150).

Applies two fixes that run together with the original mods (dependencies are kept):

1) NPC Friends - Warly
   * Removes Warly's auto-built kitchen (cookpot + icebox + 2 chests) that is
     spawned right at the start of the game.
   * Fixes cooked-food storage: Warly no longer only uses his own fridge (and
     then falls back to chests). Warly now prioritizes the NEAREST container
     tagged "freezer", then the nearest "fridge"-tagged container, before any
     chest. This is the "closest freezer" fix.

2) Admin Panel
   * Disables the resurrect/respawn feature (right-click ghost revive and the
     panel "Revive" button) to stop infinite self-revive / auto-resurrection
     abuse. All other admin features (panel, item view/take/give, full restore,
     NPC status, etc.) keep working. The dependency on workshop-3678857150 is
     NOT removed.

Load order is handled by the declared dependencies.
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
}
