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
-- ============================================================================

local _cfg = {
    remove_warly_kitchen      = GetModConfigData("remove_warly_kitchen") ~= false,
    freezer_priority_storage  = GetModConfigData("freezer_priority_storage") ~= false,
    freezer_search_radius     = GetModConfigData("freezer_search_radius") or 60,
    block_admin_revive        = GetModConfigData("block_admin_revive") ~= false,
}

-- Exporta para os scripts de patch (modimport roda no mesmo env do mod)
PATCH_CONFIG = _cfg

print(string.format("[WarlyAdminPatch] config: remove_kitchen=%s freezer_priority=%s radius=%s block_revive=%s",
    tostring(_cfg.remove_warly_kitchen),
    tostring(_cfg.freezer_priority_storage),
    tostring(_cfg.freezer_search_radius),
    tostring(_cfg.block_admin_revive)))

-- ──────────────────────────────────────────────────────────────────────────
--  Patch 1: NPC Friends (Warly) — cozinha + armazenamento em freezer
-- ──────────────────────────────────────────────────────────────────────────
if _cfg.remove_warly_kitchen or _cfg.freezer_priority_storage then
    local ok_warly, err_warly = pcall(function()
        modimport("scripts/patch/warly_kitchen_patch.lua")
    end)
    if not ok_warly then
        print("[WarlyAdminPatch][ERRO] falha ao aplicar patch do Warly: " .. tostring(err_warly))
    end
end

-- ──────────────────────────────────────────────────────────────────────────
--  Patch 2: Admin Panel — bloquear ressurreição
-- ──────────────────────────────────────────────────────────────────────────
if _cfg.block_admin_revive then
    local ok_admin, err_admin = pcall(function()
        modimport("scripts/patch/admin_revive_patch.lua")
    end)
    if not ok_admin then
        print("[WarlyAdminPatch][ERRO] falha ao aplicar patch do admin: " .. tostring(err_admin))
    end
end

print("[WarlyAdminPatch] patches registrados.")
