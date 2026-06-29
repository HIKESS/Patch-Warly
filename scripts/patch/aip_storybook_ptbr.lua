-- ============================================================================
--  Patch 5: Additional Item Package (workshop-1085586145)
--           Tradução PT-BR do livro "API storybook"
--
--  SINTOMA:
--    O mod AIP tem uma opção de idioma "Portuguese" no modinfo, mas a versão
--    de workshop NÃO inclui o arquivo scripts/aipStory/portuguese.lua nem a
--    entrada "portuguese" no LANG_MAP do widget aipStorybookPage. Resultado:
--    selecionar "Portuguese" no config do AIP faz o livro storybook cair no
--    fallback English (o jogador vê o livro em inglês).
--
--  CORREÇÃO:
--    Este patch injeta a tradução PT-BR via hook de require().
--    O widget aipStorybookPage faz, no topo do arquivo:
--      local language = aipGetModConfig("language")
--      local LANG_MAP = { chinese="aipStory/chinese", default="aipStory/english" }
--      local langPath = LANG_MAP[language] or LANG_MAP["default"]
--      local docs = require(langPath)
--    Quando language="portuguese", LANG_MAP["portuguese"] é nil, então
--    langPath cai para "aipStory/english". O nosso hook intercepta
--    require("aipStory/english"), verifica se o idioma do AIP é "portuguese",
--    e se for, retorna a tabela PT-BR (AIP_STORYBOOK_PTBR_DATA) no lugar
--    dos dados em inglês.
--
--  DEFENSIVO:
--    - Se o mod AIP não estiver instalado, ninguém chama require("aipStory/
--      english"), então o hook nunca dispara (no-op).
--    - Se o idioma do AIP for "english", "chinese" ou qualquer outro, o hook
--      retorna o require original (inglês ou chinês carregam normalmente).
--    - A leitura do config do AIP usa dois métodos (GetModConfigData com
--      modname, e aipGetModConfig global); se ambos falharem, o hook
--      desativa-se (retorna o require original).
--
--  DADOS:
--    A tabela de tradução (1623 linhas, 18 capítulos) é carregada via
--    modimport do arquivo aip_storybook_ptbr_data.lua, que define a global
--    AIP_STORYBOOK_PTBR_DATA no env do mod.
-- ============================================================================

local _G = GLOBAL

-- Tabela PT-BR (definida pelo modimport de aip_storybook_ptbr_data.lua).
-- Capturada como local para performance e para evitar lookup a cada require.
local PTBR_DATA = AIP_STORYBOOK_PTBR_DATA

if PTBR_DATA == nil then
    print("[WarlyAdminPatch] AIP-Storybook-PTBR: ERRO — AIP_STORYBOOK_PTBR_DATA é nil.")
    print("[WarlyAdminPatch] AIP-Storybook-PTBR: Verifique se aip_storybook_ptbr_data.lua foi modimportado ANTES deste script.")
    return -- aborta o patch silenciosamente
end

-- Guarda o require original (uma única vez).
local _orig_require = _G.require
if type(_orig_require) ~= "function" then
    print("[WarlyAdminPatch] AIP-Storybook-PTBR: ERRO — _G.require não é função, patch abortado.")
    return
end

-- Evita instalar o hook duas vezes (caso o patch seja recarregado).
if _G._WARLY_AIP_STORYBOOK_HOOK_INSTALLED then
    print("[WarlyAdminPatch] AIP-Storybook-PTBR: hook já instalado, pulando.")
    return
end

-- ---------------------------------------------------------------------------
--  Lê o idioma configurado no mod AIP (workshop-1085586145).
--  Tenta dois métodos para robustez:
--    1) GLOBAL.GetModConfigData("language", "workshop-1085586145")
--    2) _G.aipGetModConfig("language")  (função global definida pelo AIP)
--  Retorna "portuguese", "english", "chinese", etc. — ou nil se falhar.
-- ---------------------------------------------------------------------------
local function get_aip_language()
    -- Método 1: GetModConfigData com modname explícito
    local ok, lang = _G.pcall(_G.GetModConfigData, "language", "workshop-1085586145")
    if ok and type(lang) == "string" and lang ~= "" then
        return lang
    end
    -- Método 2: função global do AIP (disponível após o modmain do AIP rodar)
    if type(_G.aipGetModConfig) == "function" then
        ok, lang = _G.pcall(_G.aipGetModConfig, "language")
        if ok and type(lang) == "string" and lang ~= "" then
            return lang
        end
    end
    return nil
end

-- ---------------------------------------------------------------------------
--  Instala o hook de require.
--  Intercepta APENAS require("aipStory/english"). Todos os outros módulos
--  passam direto para o require original sem overhead.
-- ---------------------------------------------------------------------------
_G.require = function(modname)
    if modname == "aipStory/english" then
        local lang = get_aip_language()
        if lang == "portuguese" then
            -- Pré-registra nos package.loaded para que chamadas futuras
            -- do mesmo require retornem a mesma tabela (consistência).
            if _G.package and _G.package.loaded then
                _G.package.loaded["aipStory/portuguese"] = PTBR_DATA
            end
            print("[WarlyAdminPatch] AIP-Storybook-PTBR: injetando tradução PT-BR (AIP language=portuguese).")
            return PTBR_DATA
        end
    end
    return _orig_require(modname)
end

_G._WARLY_AIP_STORYBOOK_HOOK_INSTALLED = true

print("[WarlyAdminPatch] AIP-Storybook-PTBR: hook de require instalado.")
print("[WarlyAdminPatch] AIP-Storybook-PTBR: quando o AIP language=portuguese, o livro storybook usará a tradução PT-BR.")
