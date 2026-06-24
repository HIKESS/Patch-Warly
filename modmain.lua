-- ============================================================================
--  modmain.lua  —  Warly Kitchen + Admin Revive Patch
--
--  Carrega DEPOIS de:
--    * workshop-3684000581 (NPC Friends)
--    * workshop-3678857150 (Admin Panel)
--  (declarado em modinfo.lua -> dependencies)
--
--  Dois patches independentes, controlados por config:
--    1) warly_kitchen_patch.lua  -> remove cozinha auto + prioriza freezer
--    2) admin_revive_patch.lua   -> bloqueia ressurreição do painel admin
--
--  NOTA SOBRE SANDBOX: no modmain do DST, funções como pcall/rawget/rawset
--  NÃO são globais diretos do env do mod — precisam ser acessadas via GLOBAL
--  (ou _G). Os scripts de patch usam GLOBAL.pcall / GLOBAL.rawget etc.
--  modimport roda no mesmo env do modmain, então os patches também enxergam
--  GLOBAL. Aqui no modmain usamos modimport direto (idiomático do DST), sem
--  wrapper pcall — se um patch falhar, aparece como MOD ERROR normal no log.
-- ============================================================================

local _cfg = {
    remove_warly_kitchen      = GetModConfigData("remove_warly_kitchen") ~= false,
    freezer_priority_storage  = GetModConfigData("freezer_priority_storage") ~= false,
    freezer_search_radius     = GetModConfigData("freezer_search_radius") or 60,
    block_admin_revive        = GetModConfigData("block_admin_revive") ~= false,
    use_all_nearby_cookpots   = GetModConfigData("use_all_nearby_cookpots") ~= false,
}

-- Exporta para os scripts de patch (modimport roda no mesmo env do mod)
PATCH_CONFIG = _cfg

print(string.format("[WarlyAdminPatch] config: remove_kitchen=%s freezer_priority=%s radius=%s block_revive=%s use_all_cookpots=%s",
    tostring(_cfg.remove_warly_kitchen),
    tostring(_cfg.freezer_priority_storage),
    tostring(_cfg.freezer_search_radius),
    tostring(_cfg.block_admin_revive),
    tostring(_cfg.use_all_nearby_cookpots)))

-- ──────────────────────────────────────────────────────────────────────────
--  Patch 1: NPC Friends (Warly) — cozinha + armazenamento em freezer
-- ──────────────────────────────────────────────────────────────────────────
if _cfg.remove_warly_kitchen or _cfg.freezer_priority_storage or _cfg.use_all_nearby_cookpots then
    modimport("scripts/patch/warly_kitchen_patch.lua")
end

-- ──────────────────────────────────────────────────────────────────────────
--  Patch 2: Admin Panel — bloquear ressurreição
-- ──────────────────────────────────────────────────────────────────────────
if _cfg.block_admin_revive then
    modimport("scripts/patch/admin_revive_patch.lua")
end

print("[WarlyAdminPatch] patches registrados.")
