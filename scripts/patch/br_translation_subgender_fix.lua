-- ============================================================================
--  br_translation_subgender_fix.lua
--
--  Patch 8: Tradução Brasileira (workshop-2785731953) — crash fix SubGender
--
--  ----------------------------------------------------------------------------
--  SINTOMA
--  ----------------------------------------------------------------------------
--  Crash ao entrar em combate (ex.: Wagstaff ataca Bunnyman com bengala):
--
--    [string "../mods/workshop-2785731953/scripts/gender...."]:149:
--    attempt to call method 'find' (a nil value)
--
--    ../mods/workshop-2785731953/scripts/gender.lua:149 in (field) SubGender
--       str = table: 000000008681B070
--       gender = 0
--    ../mods/workshop-2785731953/scripts/translators/speech.lua:207 in (method) Say
--       script = table: 000000008681B070
--       arg = nil
--    scripts/components/combat.lua:554 in (method) BattleCry
--    scripts/stategraphs/SGwilson.lua:10844 in (field) onenter
--
--  O CRSM diagnostica: "[High-Risk Mod] Tradução Brasileira".
--
--  ----------------------------------------------------------------------------
--  CAUSA RAIZ
--  ----------------------------------------------------------------------------
--  O mod "Tradução Brasileira" (workshop-2785731953, v8.3.0) faz hook de
--  talker:Say via AddClassPostConstruct("components/talker", ...). O hook
--  (scripts/translators/speech.lua:204-211) faz:
--
--    AddClassPostConstruct("components/talker", function(self)
--        local oldTalkerSay = self.Say
--        function self:Say(script, ...)
--            script = Genderer.SubGender(script, 0)   -- linha 207
--            oldTalkerSay(self, script, ...)
--        end
--    end)
--
--  Genderer.SubGender (scripts/gender.lua:144-168) só guardava contra nil:
--
--    function GENDERER.SubGender(str, gender)
--        if str == nil then return "" end
--        if not str:find("G|") then return str end   -- linha 149: CRASH
--        ...
--    end
--
--  Quando Combat:BattleCry (scripts/components/combat.lua:554) passa uma
--  TABLE (estrutura de speech, ex.: {default="...", emote="..."}) para
--  talker:Say, o hook do BR encaminha a table para SubGender. SubGender
--  chama str:find("G|") — mas tables NÃO têm método :find() → crash.
--
--  Repro: qualquer personagem (especialmente mods como Wagstaff) cujo
--  battle cry seja uma table em vez de string. O bug é intermitente:
--  só crasha QUANDO o battle cry dispara (ao atacar um inimigo pela
--  primeira vez contra aquele alvo).
--
--  ----------------------------------------------------------------------------
--  CORREÇÃO PRIMÁRIA (no próprio mod)
--  ----------------------------------------------------------------------------
--  A correção primária está no próprio mod, no repositório HIKESS/Mods:
--    2785731953/scripts/gender.lua — adicionado:
--      if type(str) ~= "string" then return str end
--    após o guard de nil. Commit 7056584 em github.com/HIKESS/Mods.
--  Usuários que sincronizam a pasta mods/ a partir do repo HIKESS/Mods
--  já têm a correção e NÃO precisam deste patch.
--
--  ----------------------------------------------------------------------------
--  CORREÇÃO SECUNDÁRIA (este patch, defensiva)
--  ----------------------------------------------------------------------------
--  Este patch é para usuários que rodam a versão do Steam Workshop (que
--  ainda não tem a correção, até o autor publicar uma atualização). É
--  DEFENSIVO: no-op se o mod BR não estiver instalado, e no-op se o bug
--  já estiver corrigido no mod.
--
--  ESTRATÉGIA:
--  Como não podemos acessar Genderer.SubGender diretamente (o mod BR
--  guarda GENDERER no env do modimport, não em _G — ver NOTA SOBRE
--  SANDBOX abaixo), interceptamos no ponto de chamada: wrappeamos
--  talker:Say para converter table→string ANTES de o hook do BR chamar
--  SubGender.
--
--  LOAD ORDER (crítico):
--    * Patch-Warly tem priority=0 (default).
--    * Mod BR tem priority=-2000 (modinfo.lua linha 64).
--    * Em DST, priority MAIOR carrega ANTES. Então Patch-Warly carrega
--      ANTES do mod BR.
--    * AddClassPostConstruct callbacks rodam na ordem de registro (=
--      ordem de modmain = ordem de priority). Então o PostConstruct do
--      Patch-Warly roda ANTES do PostConstruct do mod BR.
--    * Se wrappearmos self.Say imediatamente no nosso PostConstruct, o
--      mod BR wrappea o nosso wrapper. Em runtime, o wrapper do BR
--      chama SubGender(script) ANTES de chamar o nosso wrapper → a
--      conversão table→string aconteceria DEPOIS do crash. Inútil.
--    * SOLUÇÃO: deferir nosso wrap para o próximo tick via
--      inst:DoTaskInTime(0, ...). No próximo tick, TODOS os
--      PostConstructs (incluindo o do BR) já rodaram. self.Say é o
--      wrapper do BR. Nós wrappeamos ESSE wrapper — nosso outer
--      wrapper converte table→string ANTES de chamar o wrapper do BR,
--      que então chama SubGender(string) ✓ (sem crash).
--
--  TRADE-OFF:
--    A conversão table→string preserva o conteúdo textual (.default,
--    .text, .message, ou [1]) mas PERDE metadados da table (ex.: .emote
--    para animações de emote). Para battle cries (o cenário de crash),
--    a table é tipicamente {default="texto"} ou {"texto1","texto2"} —
--    sem emote — então a perda é nula. Para o raro caso de
--    talker:Say({default="texto", emote="wave"}), o emote não toca mas
--    o texto é exibido. Isso é aceitável: better text-only than crash.
--
--  ----------------------------------------------------------------------------
--  NOTA SOBRE SANDBOX + STRICT.LUA
--  ----------------------------------------------------------------------------
--  O mod BR guarda GENDERER no env do modimport (globals sem `local`
--  vão para o env do mod, NÃO para _G). A linha `GLOBAL.GENDERER =
--  Genderer` em gender.lua:418 está dentro do bloco DEVMODE (gated por
--  `if not CONFIG.DEVMODE then return end` em gender.lua:317), então em
--  produção _G.GENDERER é nil. Não podemos patchear SubGender diretamente.
--
--  Este patch usa _G.pcall, _G.rawget, _G.rawset (convenção de sandbox
--  v1.5.1) e NÃO usa guards globais declaradas (convenção strict.lua
--  v1.6.1 — acessar guards via rawget/rawset para não disparar
--  scripts/strict.lua).
--
--  ----------------------------------------------------------------------------
--  DEFENSIVO
--  ----------------------------------------------------------------------------
--  - Se o mod BR não estiver instalado: a conversão table→string é
--    inofensiva. Vanilla talker:Say aceita tables, mas nossa conversão
--    só ativa para tables (strings passam direto). O resultado é que
--    tables viram strings — o texto é exibido, emotes são perdidos.
--    Como vanilla raramente passa tables para Say, o impacto é mínimo.
--  - Se o bug já estiver corrigido no mod BR (SubGender lida com
--    non-string): nossa conversão é redundante mas inofensiva (o BR
--    recebe uma string em vez de uma table — SubGender(string) é fine).
--  - Idempotente: o DoTaskInTime wrap é instalado uma vez por
--    instância de talker (guard via rawset no componente).
--  - Se _G.pcall não estiver disponível (ambiente extremamente
--    restrito), chama direto sem proteção.
-- ============================================================================

local _G = GLOBAL

-- Sandbox-safe helpers (convenção v1.5.1 + v1.6.1).
local _pcall  = _G.pcall
local _rawget = _G.rawget
local _rawset = _G.rawset

-- Guard de reinstall por instância de talker (via rawset no componente,
-- bypass do strict.lua).
local _MARK = "_WARLY_BR_SUBGENDER_FIX_INSTALLED"

-- ---------------------------------------------------------------------------
--  convert_table_to_string(script)
--  Converte um table speech structure para string, preservando o conteúdo
--  textual. Tenta chaves comuns (.default, .text, .message) e depois
--  forma de array ([1]). Se nada funcionar, cai para tostring().
--  Retorna o input unchanged se não for table.
-- ---------------------------------------------------------------------------
local function convert_table_to_string(script)
    if type(script) ~= "table" then
        return script
    end

    -- Forma mais comum em DST: {default="texto", emote="..."}
    if type(script.default) == "string" then
        return script.default
    end
    -- Alguns mods usam .text em vez de .default
    if type(script.text) == "string" then
        return script.text
    end
    -- Chat messages podem usar .message
    if type(script.message) == "string" then
        return script.message
    end

    -- Forma de array: {"texto1", "texto2", ...} (DST battle cries às
    -- vezes usam arrays de variantes; o talker vanilla escolhe um
    -- aleatoriamente. Aqui pegamos o primeiro — perde variação
    -- aleatória mas evita crash.)
    if script[1] ~= nil then
        if type(script[1]) == "string" then
            return script[1]
        end
        -- [1] pode ser uma sub-table {default="..."}
        if type(script[1]) == "table" then
            if type(script[1].default) == "string" then
                return script[1].default
            end
            if type(script[1].text) == "string" then
                return script[1].text
            end
        end
    end

    -- Fallback: tostring (raramente alcançado — produz algo como
    -- "table: 0x..." que não é bonito mas não crasha).
    return tostring(script)
end

-- ---------------------------------------------------------------------------
--  install_talker_wrapper(comp)
--  Instala o wrapper de comp.Say que converte table→string antes de
--  chamar o Say existente (que pode ser o wrapper do mod BR).
--
--  CRÍTICO: esta função é chamada DENTRO de inst:DoTaskInTime(0, ...) para
--  garantir que roda DEPOIS de todos os outros AddClassPostConstruct
--  (especialmente o do mod BR, que tem priority=-2000 e carrega depois
--  do Patch-Warly). Ver "LOAD ORDER" no header.
-- ---------------------------------------------------------------------------
local function install_talker_wrapper(comp)
    if not (comp and type(comp) == "table") then
        return false
    end
    if not (comp.inst and type(comp.inst) == "table") then
        return false
    end

    local inst = comp.inst

    -- Defer para o próximo tick. No próximo tick, todos os
    -- AddClassPostConstruct para esta entidade já rodaram (incluindo
    -- o do mod BR). comp.Say é o wrapper final — possivelmente o do BR.
    inst:DoTaskInTime(0, function()
        -- Evita reinstalar (idempotente). rawget para bypass do strict.lua.
        if type(_rawget) == "function" and _rawget(comp, _MARK) then
            return
        end

        local currentSay = comp.Say
        if type(currentSay) ~= "function" then
            -- Say não é função neste talker (mod estranho?). No-op.
            return
        end

        -- Wrappea: converte table→string ANTES de chamar o Say atual
        -- (que é o wrapper do BR, se o BR estiver carregado). O wrapper
        -- do BR então chama SubGender(string) — sem crash.
        comp.Say = function(self, script, ...)
            if type(script) == "table" then
                script = convert_table_to_string(script)
            end
            return currentSay(self, script, ...)
        end

        -- Marca como instalado (rawset para bypass do strict.lua).
        if type(_rawset) == "function" then
            _rawset(comp, _MARK, true)
        end
    end)

    return true
end

-- ---------------------------------------------------------------------------
--  Registro
-- ---------------------------------------------------------------------------

-- Hook de AddClassPostConstruct para components/talker. Roda quando cada
-- entidade com talker é construída (players, NPCs, etc.). O wrap real é
-- deferido via DoTaskInTime(0) para garantir que rodamos por último
-- (depois do hook do mod BR).
AddClassPostConstruct("components/talker", function(self)
    local ok, err
    if type(_pcall) == "function" then
        ok, err = _pcall(install_talker_wrapper, self)
    else
        -- Sem pcall (ambiente restrito): chama direto. Se der erro,
        -- aparece como MOD ERROR normal no log (não aborta o modmain
        -- inteiro porque estamos dentro de um callback, não do modmain).
        ok, err = true, install_talker_wrapper(self)
    end
    if not ok then
        print("[WarlyAdminPatch][BR-SubGenderFix] AVISO — install_talker_wrapper falhou: " .. tostring(err))
    end
end)

print("[WarlyAdminPatch][BR-SubGenderFix] patch registrado (wrapper de talker:Say para converter table→string, deferido via DoTaskInTime(0) para rodar depois do hook do mod BR).")
print("[WarlyAdminPatch][BR-SubGenderFix] previne crash 'attempt to call method find (a nil value)' em gender.lua:149 quando BattleCry passa table speech.")
