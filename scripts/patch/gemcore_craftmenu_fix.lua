-- ============================================================================
--  gemcore_craftmenu_fix.lua
--
--  Patch de compatibilidade entre:
--    * [API] Gem Core        (workshop-1378549454)  v5.1.46
--    * Craft Menu Tweak      (workshop-2784074596)  v6.73
--
--  ----------------------------------------------------------------------------
--  CRASH CORRIGIDO
--  ----------------------------------------------------------------------------
--  Mensagem:
--    [string "../mods/workshop-1378549454/gemscripts/gemd..."]:249:
--    attempt to call method 'HasGemDictIngredients' (a nil value)
--
--  Stack trace (resumida):
--    gemdictionary/ui.lua:249           (method) SetRecipe     <- self:HasGemDictIngredients(recipe)
--    scripts/widgets/redux/craftingmenu_ingredients.lua:24  (field) _ctor
--    scripts/class.lua:191              (upvalue) CraftingMenuIngredients
--    scripts/widgets/redux/craftingmenu_pinslot.lua:314      () ?  (cria RecipePopupRoot)
--    ../mods/workshop-2784074596/modmain.lua:909  (method) ShowRecipe
--    scripts/widgets/redux/craftingmenu_pinslot.lua:507      (method) OnGainFocus
--    scripts/frontend.lua:934 / 873    (hover focus update)
--
--  Causa raiz:
--  O Craft Menu Tweak tem um recurso de "pin bar" onde o usuario pode fixar um
--  FILTRO inteiro de crafting (ex.: ARMOUR) num slot. Ele cria recipes
--  sinteticos chamados "filter recipes" (recipe_name = "filter_ARMOUR",
--  filter_name = "ARMOUR") via CreateFilterRecipe. Esses recipes NAO sao
--  recipes reais do jogo — nao tem ingredientes normais nem entrada no Gem
--  Dictionary.
--
--  Quando o usuario passa o mouse sobre um PinSlot fixado num filter recipe,
--  o OnGainFocus -> ShowRecipe cria um widget CraftingMenuIngredients com esse
--  filter recipe. O Gem Core faz hook do metodo SetRecipe desse widget (em
--  gemdictionary/ui.lua:224-286) e, dentro do hook, chama:
--
--      self:HasGemDictIngredients(recipe)        -- linha 249
--
--  O metodo HasGemDictIngredients deveria ser definido pelo proprio Gem Core
--  na classe CraftingMenuIngredients. Porem ele é nil nesse caminho — muito
--  provavelmente porque o Gem Core so define HasGemDictIngredients quando a
--  config "Highlight Crafting Ingredients" (craftinghighlight) esta ativada,
--  mas o hook de SetRecipe é instalado INCONDICIONALMENTE e chama o metodo de
--  qualquer jeito. No relatorio de crash do usuario, craftinghighlight=false,
--  o que e consistente com essa teoria: hook instalado, metodo ausente, crash.
--  O filter recipe agrava o problema porque tambem nao tem entrada no Gem
--  Dictionary, mas o crash acontece ANTES de qualquer lookup — é a chamada do
--  proprio metodo que falha (nil).
--
--  ----------------------------------------------------------------------------
--  CORREÇÃO (load-order-independent)
--  ----------------------------------------------------------------------------
--  Garantir que a classe CraftingMenuIngredients SEMPRE tenha um metodo
--  HasGemDictIngredients visivel, como fallback seguro que retorna false
--  (= "este recipe nao tem ingredientes do Gem Dictionary" -> nenhum
--  highlighting -> sem crash). Se o Gem Core ja definiu o metodo real,
--  NAO sobrescrevemos — respeitamos a implementacao verdadeira.
--
--  Por que isso funciona independente da ordem de carga:
--    * require("widgets/redux/craftingmenu_ingredients") retorna a MESMA
--      tabela de classe (cacheada em package.loaded). Qualquer alteracao
--      nessa tabela se propaga para TODAS as instancias futuras, porque o
--      __index do class.lua aponta para essa tabela.
--    * Se rodarmos ANTES do Gem Core: adicionamos o fallback. Se o Gem Core
--      depois definir o metodo real, ele sobrescreve nosso fallback (bom).
--      Se nao definir (craftinghighlight=false), nosso fallback permanece
--      (bom — evita o crash).
--    * Se rodarmos DEPOIS do Gem Core: se o Gem Core definiu o metodo real,
--      pulamos (nao sobrescrevemos). Se nao definiu, adicionamos o fallback.
--    * Em ambos os casos, no momento em que o widget for instanciado (em
--      runtime, quando o usuario hover o PinSlot), o metodo existira na
--      classe — seja o real do Gem Core ou nosso fallback.
--
--  Re-check no world load: rodamos install_fallback() de novo em
--  AddPrefabPostInit("world") + DoTaskInTime(0) para cobrir o caso raro de
--  algum mod re-require do script e resetar a tabela, ou do Gem Core fazer
--  wipe do metodo depois. No spawn do prefab "world", TODOS os modmain ja
--  rodaram (host + clients, surface + caves), entao o estado final da classe
--  esta estabelecido.
--
--  ----------------------------------------------------------------------------
--  DEFENSIVO
--  ----------------------------------------------------------------------------
--  Se o Gem Core nao estiver instalado, o metodo SetRecipe do widget é o
--  original do jogo (nao chama HasGemDictIngredients), e nosso fallback
--  simplesmente fica dormindo na classe — nenhum efeito colateral. O patch é
--  no-op completo sem o Gem Core. Da mesma forma, se o Craft Menu Tweak nao
--  estiver instalado, nenhum filter recipe é criado, mas o fallback continua
--  valido para qualquer outro mod que dispare o mesmo caminho.
-- ============================================================================

local _G = GLOBAL
local CFG = PATCH_CONFIG

-- Tag de marcação para nao reinstalar o fallback multiplas vezes.
local _MARK = "__warly_admin_patch_gemcore_fix_installed"

-- ============================================================================
--  install_fallback()
--  Garante que CraftingMenuIngredients.HasGemDictIngredients existe.
--  Idempotente: so instala se faltar; nunca sobrescreve implementacao real.
-- ============================================================================
local function install_fallback()
    -- require do script do jogo. pcall protege contra ambiente que nao
    -- exponha o script (ex.: servidor dedicado sem frontend — improvavel,
    -- mas seguro).
    --
    -- SANDBOX NOTE: no modimport do DST, a funcao `pcall` NAO é exposta
    -- como global direto do env do mod (ela é nil). Precisamos acessá-la
    -- via GLOBAL / _G, senao o patch inteiro crasha em modimport com
    -- "attempt to call global 'pcall' (a nil value)" — exatamente o bug
    -- que este commit corrige. O mesmo vale para xpcall, rawget, rawset,
    -- loadstring, etc. Veja a NOTA SOBRE SANDBOX no modmain.lua.
    local _pcall = _G.pcall
    if type(_pcall) ~= "function" then
        -- Ambient extremamente restrito (improvavel): sem pcall, sem patch.
        -- Loga e sai sem crashar o modmain.
        print("[WarlyAdminPatch][GemCoreFix] AVISO: _G.pcall indisponivel neste ambiente (no-op).")
        return false
    end
    local ok, CMI = _pcall(_G.require, "widgets/redux/craftingmenu_ingredients")
    if not (ok and CMI and type(CMI) == "table") then
        print("[WarlyAdminPatch][GemCoreFix] AVISO: nao foi possivel require 'widgets/redux/craftingmenu_ingredients' ("
            .. tostring(CMI) .. "). Patch de Gem Core nao aplicado neste ambiente (no-op).")
        return false
    end

    -- Ja tem o metodo real (definido pelo Gem Core)? Respeitar.
    if type(CMI.HasGemDictIngredients) == "function" then
        -- Metodo real presente. Marca como instalado para o re-check saber
        -- que esta saudavel, mas nao faz nada. (Nao logamos a cada tick para
        -- nao poluir — so logamos quando efetivamente adicionamos o fallback.)
        return true
    end

    -- Sem o metodo -> instala fallback seguro.
    -- Retorna false: "nao tem ingredientes do Gem Dictionary" -> o hook do
    -- Gem Core vai pular o highlighting para este recipe e seguir em frente,
    -- sem crash. Para filter recipes (filter_ARMOUR etc.) isso é exatamente
    -- o comportamento desejado: nenhum highlighting, nenhuma alteracao.
    CMI.HasGemDictIngredients = function(self, recipe)
        return false
    end

    print("[WarlyAdminPatch][GemCoreFix] fallback HasGemDictIngredients instalado na classe CraftingMenuIngredients "
        .. "(retorna false -> sem highlighting, sem crash).")
    return true
end

-- ============================================================================
--  Registro
-- ============================================================================

-- 1) Instala imediatamente no modmain (cobre o caso em que carregamos depois
--    do Gem Core, ou em que o Gem Core nao esta instalado).
install_fallback()

-- 2) Re-check no world load. No spawn do prefab "world", todos os modmain ja
--    rodaram, entao o estado final da classe esta estabelecido. Se o Gem Core
--    carregou depois de nos e fez wipe do metodo (ou se um re-require resetou
--    a tabela), reinstalamos o fallback. DoTaskInTime(0) garante que rodamos
--    depois de qualquer hook tardio do Gem Core.
AddPrefabPostInit("world", function(inst)
    inst:DoTaskInTime(0, function()
        install_fallback()
    end)
end)

print("[WarlyAdminPatch][GemCoreFix] patch registrado (fallback HasGemDictIngredients + re-check no world load).")
