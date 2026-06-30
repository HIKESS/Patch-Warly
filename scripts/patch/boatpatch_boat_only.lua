-- ============================================================================
--  boatpatch_boat_only.lua
--
--  Patch 9: Item vanilla "boatpatch" (Remendo de Barco do DST base) —
--           restringe o remendo a APENAS consertar barcos, bloqueando
--           todas as outras interações acidentais.
--
--  ----------------------------------------------------------------------------
--  SINTOMA (relato do usuário)
--  ----------------------------------------------------------------------------
--  O item vanilla "boatpatch" (Remendo de Barco, prefab `boatpatch` e sua
--  variante `boatpatch_kelp`) serve para consertar barcos. MAS o item
--  também aceita várias outras interações que causam uso acidental:
--
--    * Reparo de estruturas de madeira (repairer.repairmaterial = WOOD) —
--      clicar o remendo numa parede de madeira / estrutura workable de
--      madeira CONSUME o item para reparar a estrutura.
--    * Cura de entidades com health (repairer.healthrepairvalue) — se
--      presente, clicar numa entidade com health CONSUME o item para
--      curá-la ("dar life").
--    * Pegar fogo (MakeSmallBurnable + MakeSmallPropagator) — o item
--      pega fogo se dropado perto de uma fogueira, e some em cinzas.
--      Mods de terceiros podem converter burnable -> fuel.
--    * Combustível (fuel) — alguns mods adicionam fuel a itens burnable,
--      permitindo que o remendo seja usado como combustível de fogueira
--      ("alimentar a fogueira").
--
--  Problema: o usuário tenta consertar o barco, mas clica sem querer numa
--  fogueira, parede, ou outra coisa, e o remendo é consumido no alvo
--  errado. "assim eu nao uso ele por engano no fogo ou outra coisa."
--
--  ----------------------------------------------------------------------------
--  CAUSA RAIZ
--  ----------------------------------------------------------------------------
--  O prefab vanilla boatpatch (scripts/prefabs/boatpatch.lua no DST) faz:
--
--    inst:AddComponent("repairer")
--    inst.components.repairer.repairmaterial = MATERIALS.WOOD
--    inst.components.repairer.boatrepairvalue = TUNING.REPAIR_BOATPATCH_HEALTH
--    inst.components.repairer.boatrepairsound = ".../repair_with_wood"
--    ...
--    MakeSmallBurnable(inst)
--    MakeSmallPropagator(inst)
--
--  Resultado: o item conserta barcos (uso pretendido) MAS TAMBÉM repara
--  madeira (repairmaterial=WOOD), pega fogo (burnable), e pode virar
--  combustível (mods de terceiros).
--
--  ----------------------------------------------------------------------------
--  CORREÇÃO (este patch)
--  ----------------------------------------------------------------------------
--  Restringe o boatpatch (e boatpatch_kelp) a APENAS consertar barcos.
--  Remove/neutaliza todas as outras interações:
--
--    REMOVE:
--      * burnable         — não pega fogo ("não alimentar a fogueira")
--      * propagator       — não propaga fogo
--      * fuel (se houver) — defensivo: não pode ser usado como combustível
--      * edible (se houver) — defensivo: não pode ser comida
--      * bait (se houver) — defensivo: não pode ser isca
--
--    NEUTRALIZA (mantém o componente, zera os campos não-barco):
--      * repairer.repairmaterial = nil     — não repara estruturas de madeira
--      * repairer.healthrepairvalue = 0    — não cura entidades com health
--
--    MANTÉM:
--      * repairer.boatrepairvalue  — conserta a saúde do barco
--      * repairer.boatrepairsound  — som do reparo do barco
--      * inspectable, inventoryitem, stackable — inventário neutro
--
--  Assim, ao clicar o remendo em QUALQUER coisa que não seja um barco, NADA
--  acontece — o item não é consumido. Só conserta barcos. O usuário não
--  precisa mais se preocupar em acertar o alvo.
--
--  ----------------------------------------------------------------------------
--  VARIANTES
--  ----------------------------------------------------------------------------
--  O DST tem dois prefabs de remendo:
--    * boatpatch       — Remendo de Barco (madeira)
--    * boatpatch_kelp  — Remendo de Barco de Alga (kelp)
--  O patch aplica a AMBOS via AddPrefabPostInit. AddPrefabPostInit em
--  prefab inexistente é no-op (seguro).
--
--  ----------------------------------------------------------------------------
--  NOTA SOBRE SANDBOX + STRICT.LUA
--  ----------------------------------------------------------------------------
--  Usa _G.pcall, _G.rawget, _G.rawset (convenção v1.5.1 + v1.6.1). Guard
--  de reinstall via rawget/rawset em global marcadora (bypass do strict.lua).
--
--  ----------------------------------------------------------------------------
--  DEFENSIVO
--  ----------------------------------------------------------------------------
--  - Sempre aplica (o boatpatch é vanilla, sempre existe no DST).
--  - Idempotente: guard via rawset evita reprocessar se o patch for
--    carregado duas vezes.
--  - Só modifica no master sim (componentes são server-side).
--  - Não remove o repairer inteiro — apenas neutraliza os campos não-
--    barco, preservando boatrepairvalue + boatrepairsound.
-- ============================================================================

local _G = GLOBAL

-- Sandbox-safe helpers (convenção v1.5.1 + v1.6.1).
local _pcall  = _G.pcall
local _rawget = _G.rawget
local _rawset = _G.rawset

-- Guard de reinstall global (rawget/rawset para bypass do strict.lua).
local _GUARD = "_WARLY_BOATPATCH_BOAT_ONLY_INSTALLED"
if type(_rawget) == "function" and _rawget(_G, _GUARD) then
    -- Já carregado (ex.: modmain executado duas vezes). No-op.
    return
end
if type(_rawset) == "function" then
    _rawset(_G, _GUARD, true)
end

-- ---------------------------------------------------------------------------
--  Lista de prefabs vanilla a patchear.
-- ---------------------------------------------------------------------------
local BOATPATCH_PREFABS = {
    "boatpatch",       -- Remendo de Barco (madeira)
    "boatpatch_kelp",  -- Remendo de Barco de Alga (kelp)
}

-- ---------------------------------------------------------------------------
--  restrict_to_boat_repair(inst)
--  Remove/neutaliza todas as interações não-barco do remendo.
--  Só roda no master sim (componentes são server-side).
-- ---------------------------------------------------------------------------
local function restrict_to_boat_repair(inst)
    -- Componentes só existem no master sim. No client, inst.components é
    -- nil/vazio — pula silenciosamente.
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then
        return
    end
    if not (inst and inst.components) then
        return
    end

    -- 1. Remove burnable + propagator — o item não pega fogo e não
    --    propaga fogo. Isto também impede que mods que convertem
    --    burnable->fuel usem o item como combustível.
    --    ("não alimentar a fogueira")
    if inst.components.burnable then
        inst:RemoveComponent("burnable")
    end
    if inst.components.propagator then
        inst:RemoveComponent("propagator")
    end

    -- 2. Remove fuel (defensivo) — alguns mods de terceiros adicionam
    --    fuel a itens; removendo garante que o remendo não alimente
    --    fogueiras/fogueiras geladas/qualquer coisa com fueled.
    if inst.components.fuel then
        inst:RemoveComponent("fuel")
    end

    -- 3. Remove edible (defensivo) — o boatpatch vanilla não é edible,
    --    mas mods de terceiros poderiam adicionar. Removendo garante
    --    que não possa ser comido ("não dar life [ao comer]").
    if inst.components.edible then
        inst:RemoveComponent("edible")
    end

    -- 4. Remove bait (defensivo) — não pode ser usado como isca.
    if inst.components.bait then
        inst:RemoveComponent("bait")
    end

    -- 5. Neutraliza repairer: mantém reparo de barco, remove o resto.
    --    - repairmaterial = nil  -> não repara estruturas de madeira
    --    - healthrepairvalue = 0 -> não cura entidades com health
    --    - MANTÉM boatrepairvalue (conserta o barco)
    --    - MANTÉM boatrepairsound (som do reparo)
    if inst.components.repairer then
        inst.components.repairer.repairmaterial = nil
        inst.components.repairer.healthrepairvalue = 0
    end

    -- MANTIDO (não tocado):
    --   * repairer.boatrepairvalue  — conserta a saúde do barco
    --   * repairer.boatrepairsound  — som do reparo
    --   * inspectable               — pode ser examinado
    --   * inventoryitem              — item de inventário
    --   * stackable                  — empilhável
end

-- ---------------------------------------------------------------------------
--  Registro: AddPrefabPostInit para cada prefab de remendo.
-- ---------------------------------------------------------------------------

local function safe_restrict(inst)
    if type(_pcall) == "function" then
        local ok, err = _pcall(restrict_to_boat_repair, inst)
        if not ok then
            print("[WarlyAdminPatch][BoatPatchBoatOnly] AVISO — restrict falhou: " .. tostring(err))
        end
    else
        restrict_to_boat_repair(inst)
    end
end

for _, prefab_name in ipairs(BOATPATCH_PREFABS) do
    AddPrefabPostInit(prefab_name, safe_restrict)
end

print("[WarlyAdminPatch][BoatPatchBoatOnly] patch registrado para " .. #BOATPATCH_PREFABS .. " prefab(s) vanilla (boatpatch + boatpatch_kelp).")
print("[WarlyAdminPatch][BoatPatchBoatOnly] remove burnable/propagator/fuel/edible/bait, neutraliza repairer.repairmaterial + healthrepairvalue; MANTÉM repairer.boatrepairvalue + boatrepairsound (só conserta barcos).")
