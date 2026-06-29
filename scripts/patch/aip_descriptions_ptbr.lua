-- ============================================================================
--  aip_descriptions_ptbr.lua
--
--  Patch 7: Additional Item Package (workshop-1085586145)
--           Tradução PT-BR das descrições (RECIPE_DESC + DESCRIBE) dos itens.
--
--  ----------------------------------------------------------------------------
--  SINTOMA
--  ----------------------------------------------------------------------------
--  O mod AIP usa um padrão de LANG_MAP por prefab: cada arquivo
--  scripts/prefabs/<name>.lua tem uma tabela LANG_MAP com seções por idioma
--  (english, chinese, spanish, russian, korean, portuguese). Quando o
--  usuário seleciona "Portuguese" no config do AIP, o prefab procura a
--  seção portuguese — mas só ~5 prefabs + 17 comidas têm essa seção. Os
--  demais caem no fallback english. Resultado: selecionar "Portuguese"
--  faz a maioria dos itens aparecer com descrições em inglês.
--
--  ----------------------------------------------------------------------------
--  CORREÇÃO
--  ----------------------------------------------------------------------------
--  Este patch sobrescreve STRINGS.RECIPE_DESC e STRINGS.CHARACTERS.GENERIC.
--  DESCRIBE com traduções PT-BR para TODOS os itens craftáveis do AIP,
--  mais as comidas (incluindo variantes com especiarias), veggies,
--  chesspieces, inscrições, guardiões elementais, livers, rubik fire,
--  sunflower, breadfruit tree, e torch stands.
--
--  NÃO traduz STRINGS.NAMES (nomes dos itens) — o usuário pediu expressamente
--  apenas descrições.
--
--  NÃO traduz aip_pet_* — esses prefabs herdam STRINGS do vanilla DST
--  (aip_pet_rabbit copia STRINGS.NAMES.RABBIT), e o DST já fornece PT-BR
--  para todos os prefabs vanilla.
--
--  As traduções estão no arquivo de dados companion
--  (aip_descriptions_ptbr_data.lua), que define a global AIP_DESC_PTBR com
--  duas sub-tabelas: RECIPE_DESC e DESCRIBE.
--
--  ----------------------------------------------------------------------------
--  GATE
--  ----------------------------------------------------------------------------
--  Este patch SÓ aplica quando o config de idioma do AIP é "portuguese".
--  Se o usuário selecionou English/Chinese/Spanish/Russian/Korean no AIP,
--  o patch é no-op (respeita a escolha do usuário). Isso é consistente
--  com o Patch 5 (tradução do storybook), que também é gated em
--  language=portuguese.
--
--  Leitura do config do AIP usa dois métodos para robustez:
--    1) GLOBAL.GetModConfigData("language", "workshop-1085586145")
--    2) _G.aipGetModConfig("language")  (função global do AIP)
--
--  ----------------------------------------------------------------------------
--  TIMING
--  ----------------------------------------------------------------------------
--  AIP tem priority=-111 (carrega cedo). Patch-Warly tem priority=default(0).
--  Então o modmain do AIP roda ANTES do Patch-Warly. Mas os arquivos de
--  prefab do AIP (scripts/prefabs/*.lua) são carregados pelo DST durante
--  a fase de carregamento de prefabs, que pode ser tardia. Para garantir
--  que TODAS as STRINGS do AIP já foram definidas antes de sobrescrevermos,
--  deferimos a aplicação para AddPrefabPostInit("world") + DoTaskInTime(0).
--
--  ----------------------------------------------------------------------------
--  DEFENSIVO
--  ----------------------------------------------------------------------------
--  - Se o AIP não estiver instalado, GetModConfigData("language",
--    "workshop-1085586145") falha/retorna nil, e o patch é no-op.
--  - Se o idioma do AIP não for "portuguese", o patch é no-op.
--  - Idempotente: sobrescrita direta de valores de tabela.
--  - Usa _G.pcall (não pcall direto) — veja NOTA SOBRE SANDBOX no modmain
--    e o hotfix v1.5.1 do Patch 4.
-- ============================================================================

local _G = GLOBAL

-- Tabela PT-BR (definida pelo modimport de aip_descriptions_ptbr_data.lua).
local DATA = AIP_DESC_PTBR

if DATA == nil then
    print("[WarlyAdminPatch][AIP-Desc-PTBR] ERRO — AIP_DESC_PTBR é nil.")
    print("[WarlyAdminPatch][AIP-Desc-PTBR] Verifique se aip_descriptions_ptbr_data.lua foi modimportado ANTES deste script.")
    return
end

-- ---------------------------------------------------------------------------
--  get_aip_language()
--  Lê o idioma configurado no mod AIP (workshop-1085586145).
--  Retorna "portuguese", "english", "chinese", etc. — ou nil se falhar.
-- ---------------------------------------------------------------------------
local function get_aip_language()
    local _p = _G.pcall
    if type(_p) ~= "function" then
        -- Sem pcall: tenta direto (pode dar erro em ambiente restrito,
        -- mas o GetModConfigData é exposto no env de mod).
        local lang = _G.GetModConfigData and _G.GetModConfigData("language", "workshop-1085586145")
        if type(lang) == "string" and lang ~= "" then
            return lang
        end
        if type(_G.aipGetModConfig) == "function" then
            lang = _G.aipGetModConfig("language")
            if type(lang) == "string" and lang ~= "" then
                return lang
            end
        end
        return nil
    end

    -- Método 1: GetModConfigData com modname explícito
    local ok, lang = _p(_G.GetModConfigData, "language", "workshop-1085586145")
    if ok and type(lang) == "string" and lang ~= "" then
        return lang
    end
    -- Método 2: função global do AIP
    if type(_G.aipGetModConfig) == "function" then
        ok, lang = _p(_G.aipGetModConfig, "language")
        if ok and type(lang) == "string" and lang ~= "" then
            return lang
        end
    end
    return nil
end

-- ---------------------------------------------------------------------------
--  apply_overrides()
--  Aplica as sobrescritas de STRINGS.RECIPE_DESC e DESCRIBE.
--  Retorna o número de entradas aplicadas.
-- ---------------------------------------------------------------------------
local function apply_overrides()
    local S = _G.STRINGS
    if not S then
        print("[WarlyAdminPatch][AIP-Desc-PTBR] AVISO — _G.STRINGS é nil. Patch não aplicado (no-op).")
        return 0
    end

    local rd_table = S.RECIPE_DESC
    local desc_table = S.CHARACTERS and S.CHARACTERS.GENERIC and S.CHARACTERS.GENERIC.DESCRIBE
    if not (rd_table and desc_table) then
        print("[WarlyAdminPatch][AIP-Desc-PTBR] AVISO — STRINGS.RECIPE_DESC ou DESCRIBE indisponível. Patch não aplicado (no-op).")
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

-- Verifica o idioma do AIP antes de aplicar. Se não for portuguese, aborta.
local aip_lang = get_aip_language()
if aip_lang ~= "portuguese" then
    if aip_lang == nil then
        print("[WarlyAdminPatch][AIP-Desc-PTBR] AIP não detectado ou idioma não pôde ser lido — patch em standby (no-op).")
    else
        print(("[WarlyAdminPatch][AIP-Desc-PTBR] AIP language='%s' (não é portuguese) — patch em standby (no-op)."):format(aip_lang))
    end
    -- Ainda assim registramos o world-load re-check, para o caso de o config
    -- ser lido tardiamente (improvável, mas defensivo).
else
    -- 1) Aplica imediatamente.
    local _p = _G.pcall
    local ok, n
    if type(_p) == "function" then
        ok, n = _p(apply_overrides)
    else
        ok, n = true, apply_overrides()
    end
    if ok then
        print(("[WarlyAdminPatch][AIP-Desc-PTBR] %d descrições PT-BR aplicadas (fase modmain, AIP language=portuguese)."):format(n))
    else
        print("[WarlyAdminPatch][AIP-Desc-PTBR] AVISO — apply_overrides() falhou na fase modmain: " .. tostring(n))
    end
end

-- 2) Re-check no world load. Re-lê o idioma (caso tenha mudado) e re-aplica.
AddPrefabPostInit("world", function(inst)
    inst:DoTaskInTime(0, function()
        local lang = get_aip_language()
        if lang ~= "portuguese" then
            return -- ainda não é portuguese, não faz nada
        end
        local _p = _G.pcall
        local ok, n
        if type(_p) == "function" then
            ok, n = _p(apply_overrides)
        else
            ok, n = true, apply_overrides()
        end
        if ok then
            print(("[WarlyAdminPatch][AIP-Desc-PTBR] %d descrições PT-BR re-aplicadas (fase world load, AIP language=portuguese)."):format(n))
        else
            print("[WarlyAdminPatch][AIP-Desc-PTBR] AVISO — apply_overrides() falhou no world load: " .. tostring(n))
        end
    end)
end)

print("[WarlyAdminPatch][AIP-Desc-PTBR] patch registrado (tradução de RECIPE_DESC + DESCRIBE do AIP, gated em language=portuguese).")
