-- ============================================================================
--  modmain.lua  —  Warly Kitchen + Admin Revive Patch
--
--  Carrega DEPOIS de:
--    * workshop-3684000581 (NPC Friends)
--    * workshop-3678857150 (Admin Panel)
--  (declarado em modinfo.lua -> dependencies)
--  O mod workshop-3597024951 (JingXi Furniture) NÃO é dependência — o
--  patch de bloqueio de crafts é defensivo (no-op se o mod não existir).
--
--  Três patches independentes, controlados por config:
--    1) warly_kitchen_patch.lua  -> remove cozinha auto + prioriza freezer
--                                  + usa todas as cookpots próximas
--    2) admin_revive_patch.lua   -> bloqueia ressurreição do painel admin
--    3) craft_block_patch.lua    -> oculta/bloqueia crafts do JingXi Furniture
--                                  + itens que emitem luz em tabs moddadas
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
    block_jingxi_crafts       = GetModConfigData("block_jingxi_crafts") ~= false,
    block_light_emitting_crafts = GetModConfigData("block_light_emitting_crafts") ~= false,
}

-- Exporta para os scripts de patch (modimport roda no mesmo env do mod)
PATCH_CONFIG = _cfg

print(string.format("[WarlyAdminPatch] config: remove_kitchen=%s freezer_priority=%s radius=%s block_revive=%s use_all_cookpots=%s block_jingxi=%s block_light=%s",
    tostring(_cfg.remove_warly_kitchen),
    tostring(_cfg.freezer_priority_storage),
    tostring(_cfg.freezer_search_radius),
    tostring(_cfg.block_admin_revive),
    tostring(_cfg.use_all_nearby_cookpots),
    tostring(_cfg.block_jingxi_crafts),
    tostring(_cfg.block_light_emitting_crafts)))

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

-- ──────────────────────────────────────────────────────────────────────────
--  Patch 3: JingXi Furniture (workshop-3597024951) — bloquear 3 crafts
--           + itens que emitem luz em tabs de crafting moddadas.
--  Defensive: no-op se nenhum mod-alvo estiver instalado.
-- ──────────────────────────────────────────────────────────────────────────
if _cfg.block_jingxi_crafts or _cfg.block_light_emitting_crafts then
    modimport("scripts/patch/craft_block_patch.lua")
end

print("[WarlyAdminPatch] patches registrados.")
