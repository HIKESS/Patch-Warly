-- ============================================================================
--  modmain.lua  —  Warly Kitchen + Admin Revive + Craft Block Patch
--
--  Carrega DEPOIS de:
--    * workshop-3684000581 (NPC Friends)
--    * workshop-3678857150 (Admin Panel)
--  (declarado em modinfo.lua -> dependencies)
--  O mod workshop-3597024951 (JingXi Furniture) NÃO é dependência — o
--  patch de bloqueio de crafts é defensivo (no-op se o mod não existir).
--  O mod workshop-1378549454 ([API] Gem Core) tambem NÃO é dependência —
--  o patch de crash do crafting menu é defensivo (no-op se não existir).
--  O mod workshop-1085586145 (Additional Item Package) tambem NÃO é
--  dependência — o patch de tradução PT-BR do storybook é defensivo.
--
--  Cinco patches independentes, controlados por config:
--    1) warly_kitchen_patch.lua      -> remove cozinha auto + prioriza freezer
--                                       + usa todas as cookpots próximas
--    2) admin_revive_patch.lua       -> bloqueia ressurreição do painel admin
--    3) craft_block_patch.lua        -> oculta/bloqueia crafts do JingXi Furniture
--                                       + itens que emitem luz em tabs moddadas
--    4) gemcore_craftmenu_fix.lua    -> corrige crash HasGemDictIngredients nil
--                                       do Gem Core ao hover PinSlot de filter
--                                       recipe do Craft Menu Tweak
--    5) aip_storybook_ptbr.lua       -> injeta tradução PT-BR do livro
--                                       "API storybook" do mod AIP
--                                       (workshop-1085586145) via hook de
--                                       require() quando o idioma do AIP é
--                                       "Portuguese"
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
    fix_gemcore_craftmenu_crash = GetModConfigData("fix_gemcore_craftmenu_crash") ~= false,
    translate_aip_storybook    = GetModConfigData("translate_aip_storybook") ~= false,
    -- WHITELIST: quando true, o item NAO é bloqueado (mesmo com os block_* acima).
    -- Default false = segue o comportamento do block_* (bloqueia se o block estiver on).
    allow_jx_lantern          = GetModConfigData("allow_jx_lantern") == true,
    allow_jx_flashlight       = GetModConfigData("allow_jx_flashlight") == true,
    allow_jx_lamp             = GetModConfigData("allow_jx_lamp") == true,
    allow_jx_mushroom_light   = GetModConfigData("allow_jx_mushroom_light") == true,
    allow_jx_mushroom_light_2 = GetModConfigData("allow_jx_mushroom_light_2") == true,
    allow_jx_lamp_2           = GetModConfigData("allow_jx_lamp_2") == true,
}

-- Exporta para os scripts de patch (modimport roda no mesmo env do mod)
PATCH_CONFIG = _cfg

print(string.format("[WarlyAdminPatch] config: remove_kitchen=%s freezer_priority=%s radius=%s block_revive=%s use_all_cookpots=%s block_jingxi=%s block_light=%s fix_gemcore=%s translate_aip_storybook=%s | whitelist: lantern=%s flashlight=%s lamp=%s mushroom_light=%s mushroom_light_2=%s lamp_2=%s",
    tostring(_cfg.remove_warly_kitchen),
    tostring(_cfg.freezer_priority_storage),
    tostring(_cfg.freezer_search_radius),
    tostring(_cfg.block_admin_revive),
    tostring(_cfg.use_all_nearby_cookpots),
    tostring(_cfg.block_jingxi_crafts),
    tostring(_cfg.block_light_emitting_crafts),
    tostring(_cfg.fix_gemcore_craftmenu_crash),
    tostring(_cfg.translate_aip_storybook),
    tostring(_cfg.allow_jx_lantern),
    tostring(_cfg.allow_jx_flashlight),
    tostring(_cfg.allow_jx_lamp),
    tostring(_cfg.allow_jx_mushroom_light),
    tostring(_cfg.allow_jx_mushroom_light_2),
    tostring(_cfg.allow_jx_lamp_2)))

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

-- ──────────────────────────────────────────────────────────────────────────
--  Patch 4: Gem Core (workshop-1378549454) + Craft Menu Tweak
--           (workshop-2784074596) — crash fix.
--  Corrige "attempt to call method 'HasGemDictIngredients' (a nil value)"
--  ao passar o mouse sobre um PinSlot fixado em um filter recipe (ex.:
--  filter_ARMOUR). Defensive: no-op se o Gem Core não estiver instalado.
-- ──────────────────────────────────────────────────────────────────────────
if _cfg.fix_gemcore_craftmenu_crash then
    modimport("scripts/patch/gemcore_craftmenu_fix.lua")
end

-- ──────────────────────────────────────────────────────────────────────────
--  Patch 5: Additional Item Package (workshop-1085586145) — tradução
--           PT-BR do livro "API storybook".
--  O mod AIP tem config "Portuguese" mas a versão de workshop não inclui o
--  arquivo portuguese.lua nem a entrada no LANG_MAP do widget. Este patch
--  injeta a tradução via hook de require() quando o idioma do AIP é
--  "Portuguese". Defensive: no-op se o AIP não estiver instalado.
--  NOTA: o data file DEVE ser modimportado ANTES do patch script, pois o
--  patch lê a global AIP_STORYBOOK_PTBR_DATA definida pelo data file.
-- ──────────────────────────────────────────────────────────────────────────
if _cfg.translate_aip_storybook then
    modimport("scripts/patch/aip_storybook_ptbr_data.lua")
    modimport("scripts/patch/aip_storybook_ptbr.lua")
end

print("[WarlyAdminPatch] patches registrados.")
