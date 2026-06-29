-- ============================================================================
--  jx_descriptions_ptbr.lua
--
--  Patch 6: JingXi Furniture (workshop-3597024951)
--           Tradução PT-BR das descrições (RECIPE_DESC + DESCRIBE) dos itens.
--
--  ----------------------------------------------------------------------------
--  SINTOMA
--  ----------------------------------------------------------------------------
--  O mod JingXi Furniture centraliza todas as strings em dois arquivos de
--  idioma (scripts/jxlanguages/jx_en.lua e jx_ch.lua), escolhidos
--  automaticamente pelo locale do DST:
--    * locale zh/zht/zhr -> jx_ch.lua (Chinês)
--    * qualquer outro    -> jx_en.lua (Inglês — fallback)
--  Jogadores PT-BR (locale pt/ptbr) caem no fallback Inglês: todos os itens
--  aparecem com descrições em inglês no menu de crafting e ao examinar.
--
--  ----------------------------------------------------------------------------
--  CORREÇÃO
--  ----------------------------------------------------------------------------
--  Este patch sobrescreve STRINGS.RECIPE_DESC e STRINGS.CHARACTERS.GENERIC.
--  DESCRIBE com traduções PT-BR para TODOS os itens do mod JingXi.
--
--  NÃO traduz STRINGS.NAMES (nomes dos itens) — o usuário pediu expressamente
--  apenas descrições. Os nomes continuam no idioma original do mod (Inglês
--  para PT-BR, ou Chinês para zh).
--
--  As traduções estão no arquivo de dados companion
--  (jx_descriptions_ptbr_data.lua), que define a global JX_DESC_PTBR com
--  duas sub-tabelas: RECIPE_DESC e DESCRIBE. As chaves são UPPERCASE
--  (ex: "JX_LAMP"), correspondendo ao formato usado pelo mod JingXi.
--
--  ----------------------------------------------------------------------------
--  TIMING
--  ----------------------------------------------------------------------------
--  As STRINGS são tabelas globais compartilhadas. O mod JingXi carrega seus
--  arquivos de idioma durante o modmain dele. Este patch roda no modmain do
--  Patch-Warly. Para garantir que as STRINGS do JingXi já foram definidas
--  (independente da ordem de carga entre mods), deferimos a aplicação para
--  AddPrefabPostInit("world") + DoTaskInTime(0). No spawn do prefab "world",
--  TODOS os modmain já rodaram, então o estado final das STRINGS está
--  estabelecido. Nossa sobrescrita then "vence".
--
--  ----------------------------------------------------------------------------
--  DEFENSIVO
--  ----------------------------------------------------------------------------
--  - Se o mod JingXi não estiver instalado, as STRINGS do JingXi nunca são
--    definidas; nossas sobrescritas criam entradas órfãs que ninguém lê
--    (no-op efetivo — nenhum item do JingXi existe para exibi-las).
--  - Se o locale for Chinês (zh/zht/zhr), o JingXi carrega jx_ch.lua
--    (Chinês). Este patch ainda sobrescreve com PT-BR. Se o usuário quer
--    manter Chinês, deve desativar este patch no config do Patch-Warly.
--    Default: Ativado (recomendado para jogadores PT-BR).
--  - Idempotente: pode rodar múltiplas vezes sem problema (sobrescrita
--    direta de valores de tabela).
--  - O _G.pcall é usado (não pcall direto) porque no modimport sandbox o
--    pcall global é nil. Veja a NOTA SOBRE SANDBOX no modmain.lua e o
--    hotfix v1.5.1 do Patch 4.
-- ============================================================================

local _G = GLOBAL

-- Tabela PT-BR (definida pelo modimport de jx_descriptions_ptbr_data.lua).
local DATA = JX_DESC_PTBR

if DATA == nil then
    print("[WarlyAdminPatch][JX-Desc-PTBR] ERRO — JX_DESC_PTBR é nil.")
    print("[WarlyAdminPatch][JX-Desc-PTBR] Verifique se jx_descriptions_ptbr_data.lua foi modimportado ANTES deste script.")
    return
end

-- ---------------------------------------------------------------------------
--  apply_overrides()
--  Aplica as sobrescritas de STRINGS.RECIPE_DESC e DESCRIBE.
--  Idempotente.
-- ---------------------------------------------------------------------------
local function apply_overrides()
    local S = _G.STRINGS
    if not S then
        print("[WarlyAdminPatch][JX-Desc-PTBR] AVISO — _G.STRINGS é nil (ambiente restrito). Patch não aplicado (no-op).")
        return 0
    end

    local rd_table = S.RECIPE_DESC
    local desc_table = S.CHARACTERS and S.CHARACTERS.GENERIC and S.CHARACTERS.GENERIC.DESCRIBE
    if not (rd_table and desc_table) then
        print("[WarlyAdminPatch][JX-Desc-PTBR] AVISO — STRINGS.RECIPE_DESC ou DESCRIBE indisponível. Patch não aplicado (no-op).")
        return 0
    end

    local count = 0

    -- RECIPE_DESC
    if DATA.RECIPE_DESC then
        for key, pt_text in pairs(DATA.RECIPE_DESC) do
            if type(pt_text) == "string" and #pt_text > 0 then
                rd_table[key] = pt_text
                count = count + 1
            end
        end
    end

    -- DESCRIBE (examine quotes)
    if DATA.DESCRIBE then
        for key, pt_text in pairs(DATA.DESCRIBE) do
            if type(pt_text) == "string" and #pt_text > 0 then
                desc_table[key] = pt_text
                count = count + 1
            end
        end
    end

    return count
end

-- ---------------------------------------------------------------------------
--  Registro
-- ---------------------------------------------------------------------------

-- 1) Tenta aplicar imediatamente (cobre o caso em que carregamos depois
--    do JingXi).
local _pcall = _G.pcall
if type(_pcall) == "function" then
    local ok, n = _pcall(apply_overrides)
    if ok then
        print(("[WarlyAdminPatch][JX-Desc-PTBR] %d descrições PT-BR aplicadas (fase modmain)."):format(n))
    else
        print("[WarlyAdminPatch][JX-Desc-PTBR] AVISO — apply_overrides() falhou na fase modmain: " .. tostring(n))
    end
else
    -- Sem pcall (ambiente restrito): chama direto, sem proteção.
    local n = apply_overrides()
    print(("[WarlyAdminPatch][JX-Desc-PTBR] %d descrições PT-BR aplicadas (fase modmain, sem pcall)."):format(n))
end

-- 2) Re-aplica no world load para garantir que vence após o JingXi carregar
--    seus arquivos de idioma (caso o JingXi carregue depois de nós).
AddPrefabPostInit("world", function(inst)
    inst:DoTaskInTime(0, function()
        local _p = _G.pcall
        local ok, n
        if type(_p) == "function" then
            ok, n = _p(apply_overrides)
        else
            ok, n = true, apply_overrides()
        end
        if ok then
            print(("[WarlyAdminPatch][JX-Desc-PTBR] %d descrições PT-BR re-aplicadas (fase world load)."):format(n))
        else
            print("[WarlyAdminPatch][JX-Desc-PTBR] AVISO — apply_overrides() falhou no world load: " .. tostring(n))
        end
    end)
end)

print("[WarlyAdminPatch][JX-Desc-PTBR] patch registrado (tradução de RECIPE_DESC + DESCRIBE do JingXi Furniture).")
