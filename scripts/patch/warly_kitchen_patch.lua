-- ============================================================================
--  warly_kitchen_patch.lua
--  Patch para o mod NPC Friends (workshop-3684000581), focado no Warly.
--
--  Faz duas coisas:
--
--  A) Remover a criação automática da cozinha completa
--     (portablecookpot + icebox + 2x treasurechest) que o Warly monta logo no
--     início do jogo. O comportamento de montar a cozinha vive no behavior tree
--     obfuscado `cheffarmbehavior`, que usa a classe `BuildStationManager`
--     (scripts/npc/npc_build_station.lua). Sobrescrevemos os métodos que
--     decidem o próximo item a construir e que spawna estruturas, fazendo com
--     que a estação nunca seja construída — sem tocar no arquivo obfuscado.
--
--  B) Corrigir o armazenamento de comida cozida
--     No mod original o Warly só guarda comida cozida na própria geladeira que
--     ele cria ao entrar no mundo; quando ela enche (ou some), a comida cai nos
--     baús. Sobrescrevemos `InvUtil.SmartStore` para que o Warly procure, ao
--     redor dele, os containers marcados com a tag "freezer" (prioridade,
--     mais próximo primeiro) e depois os containers com a tag "fridge"
--     (também mais próximo primeiro), antes de cair para a lista original de
--     iceboxes / baús. Assim a comida vai para o freezer mais próximo.
--
--  Todo o resto do mod (sistema de cozinha acelerada do Warly, tags
--  masterchef/expertchef, etc.) continua funcionando normalmente.
--
--  ============================================================================
--  TIMING / LOAD ORDER (importante)
--  ----------------------------------------------------------------------------
--  Os módulos `npc/npc_build_station` e `npc/npc_inventory_util` NÃO são
--  carregados eagermente pelo modmain do NPC Friends — eles são puxados
--  lazy pela cadeia  prefab(npcfriend) -> brain -> cheffarmbehavior -> require.
--  Ou seja, no momento em que o nosso modmain roda, esses módulos ainda NÃO
--  estão em package.loaded, e um `require` nosso falharia (nossos scripts/
--  não os contêm).
--
--  Solução: aplicamos os overrides DENTRO de AddPrefabPostInit("npcfriend").
--  Quando o primeiro NPC spawna, a cadeia de require do prefab já rodou
--  (top-level requires do arquivo de prefab rodam no carregamento do arquivo,
--  antes do fn e do PostInit), então package.loaded já tem os módulos, e nosso
--  require devolve a MESMA tabela que o mod original está usando — logo as
--  substituições de métodos se propagam. PostInit dispara antes do primeiro
--  tick do brain, então as mudanças estão em vigor a tempo de impedir a
--  construção da cozinha. Um guard global garante que aplicamos só uma vez.
-- ============================================================================

local CFG = PATCH_CONFIG

-- Helper seguro de require (entre mods, via package.loaded compartilhado).
local function safe_require(modname)
    local ok, mod = GLOBAL.pcall(require, modname)
    if ok then return mod end
    return nil
end

-- Guard global: aplica os overrides uma única vez em todo o jogo.
local _APPLIED_FLAG = "_warly_admin_patch_applied"

-- ═══════════════════════════════════════════════════════════════════════════
--  Aplica os overrides (idempotente). Chamada a partir do PostInit do NPC.
-- ═══════════════════════════════════════════════════════════════════════════

local function ApplyWarlyPatches(inst)
    if GLOBAL.rawget(GLOBAL, _APPLIED_FLAG) then return end
    GLOBAL.rawset(GLOBAL, _APPLIED_FLAG, true)

    -- ───────────────────────────────────────────────────────────────────────
    -- A) REMOVER A COZINHA AUTOMÁTICA DO WARLY
    -- ───────────────────────────────────────────────────────────────────────
    if CFG.remove_warly_kitchen then
        local BuildStationManager = safe_require("npc/npc_build_station")
        if BuildStationManager then
            -- O behavior tree (cheffarmbehavior) chama GetNextBuildEntry para
            -- saber o que spawnar em seguida; retornar nil => "nada a fazer" e
            -- o nó de construção não executa.
            BuildStationManager.GetNextBuildEntry = function(self)
                return nil
            end
            -- Cinto de segurança: mesmo que algum caminho chame SpawnStructure,
            -- ele vira no-op (não spawna cookpot/icebox/chest).
            BuildStationManager.SpawnStructure = function(self, entry, pos)
                return nil
            end
            -- Estação sempre considerada "completa" => sem loops de build.
            BuildStationManager.IsComplete = function(self)
                return true
            end
            print("[WarlyAdminPatch][Warly] Cozinha automática DESATIVADA (BuildStationManager neutralizado).")
        else
            print("[WarlyAdminPatch][Warly] AVISO: BuildStationManager não encontrado nesta versão do mod — kitchen removal não aplicado.")
        end
    end

    -- ───────────────────────────────────────────────────────────────────────
    -- B) PRIORIZAR FREEZER NO ARMAZENAMENTO DE COMIDA
    -- ───────────────────────────────────────────────────────────────────────
    if CFG.freezer_priority_storage then
        local InvUtil = safe_require("npc/npc_inventory_util")
        if InvUtil and InvUtil.SmartStore then
            local _orig_SmartStore = InvUtil.SmartStore
            local RADIUS = CFG.freezer_search_radius or 60

            local function _dist_sq(owner, ent)
                local x1, y1, z1 = owner.Transform:GetWorldPosition()
                local x2, y2, z2 = ent.Transform:GetWorldPosition()
                local dx, dz = x1 - x2, z1 - z2
                return dx * dx + dz * dz
            end

            local function _is_valid_food_container(ent)
                if not ent or not ent:IsValid() then return false end
                if not (ent.components and ent.components.container) then return false end
                if ent:HasTag("backpack") then return false end
                -- Ignora cookpot/stewer (não é lugar de guardar comida pronta)
                if ent:HasTag("cookpot") or ent:HasTag("stewer") then return false end
                return true
            end

            --- Coleta freezers (tag "freezer") e geladeiras (tag "fridge") ao
            --- redor do NPC, ordenados do mais próximo ao mais distante.
            --- Freezers vêm primeiro (prioridade), depois geladeiras que não
            --- sejam freezers.
            local function GatherFreezersAndFridges(owner)
                local result = {}
                local seen = {}
                if not (owner and owner.Transform) then return result end
                local x, y, z = owner.Transform:GetWorldPosition()

                -- 1) Freezers (prioridade)
                local freezers = {}
                GLOBAL.pcall(function()
                    freezers = TheSim:FindEntities(x, y, z, RADIUS, {"freezer"}) or {}
                end)
                for _, ent in ipairs(freezers) do
                    if _is_valid_food_container(ent) and not seen[ent] then
                        seen[ent] = true
                        table.insert(result, ent)
                    end
                end
                table.sort(result, function(a, b) return _dist_sq(owner, a) < _dist_sq(owner, b) end)

                -- 2) Geladeiras (fridge) que ainda não foram incluídas
                local fridge_extra = {}
                local fridges = {}
                GLOBAL.pcall(function()
                    fridges = TheSim:FindEntities(x, y, z, RADIUS, {"fridge"}) or {}
                end)
                for _, ent in ipairs(fridges) do
                    if _is_valid_food_container(ent) and not seen[ent] then
                        seen[ent] = true
                        table.insert(fridge_extra, ent)
                    end
                end
                table.sort(fridge_extra, function(a, b) return _dist_sq(owner, a) < _dist_sq(owner, b) end)

                for _, ent in ipairs(fridge_extra) do
                    table.insert(result, ent)
                end

                return result
            end

            --- SmartStore sobrescrito:
            --- 1) Reúne freezers + geladeiras mais próximos do NPC.
            --- 2) effective = [freezers+fridges...] ++ [iceboxes originais] (dedup)
            --- 3) Chama o SmartStore original com essa lista.
            --- Comida cozida vai primeiro para o freezer mais próximo; só cai
            --- em baús se NÃO houver nem freezer nem geladeira por perto (ou
            --- quando todos encherem — overflow natural do SmartStore original).
            InvUtil.SmartStore = function(npc, iceboxes, chests, dump_pos)
                if not (npc and npc.IsValid and npc:IsValid()) then
                    return _orig_SmartStore(npc, iceboxes, chests, dump_pos)
                end

                local gathered = GatherFreezersAndFridges(npc)
                local seen = {}
                local effective = {}

                for _, c in ipairs(gathered) do
                    if not seen[c] then
                        seen[c] = true
                        table.insert(effective, c)
                    end
                end
                for _, c in ipairs(iceboxes or {}) do
                    if c and c.IsValid and c:IsValid() and not seen[c] then
                        seen[c] = true
                        table.insert(effective, c)
                    end
                end

                if #effective > 0 then
                    return _orig_SmartStore(npc, effective, chests, dump_pos)
                else
                    return _orig_SmartStore(npc, iceboxes, chests, dump_pos)
                end
            end

            print(string.format("[WarlyAdminPatch][Warly] Armazenamento com prioridade de FREEZER ativado (raio=%d).", RADIUS))
        else
            print("[WarlyAdminPatch][Warly] AVISO: InvUtil.SmartStore não encontrado nesta versão do mod — freezer priority não aplicado.")
        end
    end

    -- ───────────────────────────────────────────────────────────────────────
    -- C) USAR TODAS AS COOKPOTS PRÓXIMAS (não só a do _cooking_center)
    -- ───────────────────────────────────────────────────────────────────────
    if CFG.use_all_nearby_cookpots then
        -- No mod original, o brain do Warly passa para o NPCCookingBehavior
        -- um `get_cookpots_fn` que coleta cookpots (stewer) num raio de 17
        -- em torno de `inst._cooking_center` (posição fixa definida pelo
        -- comando "Cook Here"). Ou seja, o Warly só enxerga cookpots perto
        -- daquele centro fixo — ignorando cookpots/portable cookpots que
        -- estejam ao redor dele no momento. Resultado: "só usa uma fixa".
        --
        -- Correção: sobrescrevemos `NPCCookingBehavior:_GetCookpots` para
        -- coletar TODAS as cookpots (tag "stewer") num raio ao redor da
        -- posição ATUAL do NPC, MESCLADAS com a lista original (vinda do
        -- _cooking_center), dedup. Assim o Warly cozinha em qualquer
        -- cookpot/portable cookpot próximo dele, onde quer que esteja.
        local NPCCookingBehavior = safe_require("behaviours/npc_cooking_behavior")
        if NPCCookingBehavior and NPCCookingBehavior._GetCookpots then
            local _orig_GetCookpots = NPCCookingBehavior._GetCookpots
            local COOKPOT_RADIUS = 17 -- = NPC_TUNING.FARM_WORK_RADIUS do mod alvo

            local function _dist_sq(a, b)
                local x1, y1, z1 = a.Transform:GetWorldPosition()
                local x2, y2, z2 = b.Transform:GetWorldPosition()
                local dx, dz = x1 - x2, z1 - z2
                return dx * dx + dz * dz
            end

            local function _is_valid_cookpot(ent)
                if not ent or not ent:IsValid() then return false end
                if not (ent.components and ent.components.stewer) then return false end
                return true
            end

            NPCCookingBehavior._GetCookpots = function(self)
                local inst = self and self.inst
                if not (inst and inst.IsValid and inst:IsValid() and inst.Transform) then
                    return _orig_GetCookpots(self)
                end

                local seen = {}
                local merged = {}

                -- 1) Cookpots ao redor da posição ATUAL do NPC (prioridade).
                --    Tag "stewer" cobre cookpot, portablecookpot, archive_cookpot
                --    e quaisquer cookpots de mods que usem o componente stewer.
                local x, y, z = inst.Transform:GetWorldPosition()
                local nearby = {}
                GLOBAL.pcall(function()
                    nearby = TheSim:FindEntities(x, y, z, COOKPOT_RADIUS, {"stewer"}) or {}
                end)
                for _, ent in ipairs(nearby) do
                    if _is_valid_cookpot(ent) and not seen[ent] then
                        seen[ent] = true
                        table.insert(merged, ent)
                    end
                end
                -- Ordena do mais próximo ao mais distante do NPC.
                table.sort(merged, function(a, b) return _dist_sq(inst, a) < _dist_sq(inst, b) end)

                -- 2) Acrescenta a lista original (cookpots do _cooking_center)
                --    como fallback, caso o NPC esteja longe de toda cookpot
                --    própria mas ainda tenha o centro de cozinha configurado.
                local ok_orig, orig_list = GLOBAL.pcall(_orig_GetCookpots, self)
                if ok_orig and type(orig_list) == "table" then
                    for _, ent in ipairs(orig_list) do
                        if _is_valid_cookpot(ent) and not seen[ent] then
                            seen[ent] = true
                            table.insert(merged, ent)
                        end
                    end
                end

                return merged
            end

            print(string.format("[WarlyAdminPatch][Warly] _GetCookpots sobrescrito: usa TODAS as cookpots próximas (raio=%d, merge com _cooking_center).", COOKPOT_RADIUS))
        else
            print("[WarlyAdminPatch][Warly] AVISO: NPCCookingBehavior._GetCookpots não encontrado nesta versão do mod — use_all_cookpots não aplicado.")
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  Hook no prefab do NPC. Aplica os overrides no primeiro spawn (e marca
--  _chef_station.built=true para qualquer save antigo).
--  Múltiplos AddPrefabPostInit se acumulam — não conflita com os PostInit que
--  o próprio mod NPC Friends registra em "npcfriend".
-- ═══════════════════════════════════════════════════════════════════════════

if CFG.remove_warly_kitchen or CFG.freezer_priority_storage or CFG.use_all_nearby_cookpots then
    GLOBAL.pcall(function()
        AddPrefabPostInit("npcfriend", function(inst)
            if not inst then return end

            -- Aplica overrides UMA vez (require funciona aqui: a cadeia
            -- prefab->brain->cheffarmbehavior já populou package.loaded).
            ApplyWarlyPatches(inst)

            -- Bônus defensivo: marca _chef_station persistida de save antigo
            -- como "já construída", impedindo reconstrução. Não destrói
            -- estruturas já existentes no mundo do jogador.
            if CFG.remove_warly_kitchen then
                inst:DoTaskInTime(0, function()
                    if not inst:IsValid() then return end
                    if inst._chef_station then
                        inst._chef_station.built = true
                    end
                    inst._warly_skip_kitchen = true
                end)
            end
        end)
    end)
    print("[WarlyAdminPatch][Warly] PostInit registrado para 'npcfriend' (overrides aplicados no primeiro spawn).")
end
