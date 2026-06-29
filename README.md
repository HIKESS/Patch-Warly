# Warly Kitchen + Admin Revive + Craft Block Patch

Um **único patch** para mods do repositório [HIKESS/Mods](https://github.com/HIKESS/Mods) + Steam Workshop:

| Mod | Workshop ID | O que o patch faz |
|-----|-------------|-------------------|
| **NPC Friends** (橘子的NPC小伙伴) | `workshop-3684000581` | Foco no **Warly**: (1) remove a cozinha completa que ele cria no início do jogo (baú/panela/geladeira); (2) corrige o armazenamento de comida para priorizar o **freezer mais próximo** (tag `freezer`) antes das geladeiras e dos baús; (3) faz o Warly cozinhar em **TODAS as cookpots/portable cookpots próximas** dele, em vez de só na cookpot fixa do `_cooking_center`. |
| **Admin Panel** (橘子的超级管理员) | `workshop-3678857150` | Bloqueia a **ressurreição / auto-ressurreição** (botão "Reviver" + clique-direito em fantasma) para evitar abuso. O resto do painel (ver/pegar/dar itens, *full restore*, status de NPC, etc.) continua funcionando. **A dependência deste mod NÃO é removida.** |
| **JingXi Furniture** (optional, não-dependência) | `workshop-3597024951` | **Bloqueia as fontes de luz do mod** pelos nomes EXATOS de prefab (obtidos do código-fonte): (a) os 3 itens nomeados — `jx_mushroom_light` (Gothic Palace Streetlight), `jx_mushroom_light_2` (RoseRed Solid Wood Lamp), `jx_lamp_2` (Engraved Candlestick); (b) **todas as fontes de luz puras** — + `jx_lamp`, `jx_lantern`, `jx_flashlight`. NÃO bloqueia itens funcionais (cookpot/forno/TV) — preserva cozinha/aquecimento. No-op se o mod não estiver instalado. |
| **[API] Gem Core** + **Craft Menu Tweak** (optional, não-dependência) | `workshop-1378549454` + `workshop-2784074596` | **Corrige um crash** (`attempt to call method 'HasGemDictIngredients' (a nil value)`) que acontece ao passar o mouse sobre um PinSlot fixado num **filter recipe** (ex.: `filter_ARMOUR`) criado pelo Craft Menu Tweak. O Gem Core faz hook do `SetRecipe` do widget de ingredientes e chama `self:HasGemDictIngredients(recipe)`, mas esse método é `nil` para filter recipes / quando o highlighting está desligado. O patch instala um **fallback seguro** (`return false`) na classe do widget. No-op se o Gem Core não estiver instalado. |
| **Additional Item Package** (optional, não-dependência) | `workshop-1085586145` | **Injeta a tradução PT-BR** do livro "API storybook". O mod AIP tem uma opção de idioma "Portuguese" no config, mas a versão de workshop **não inclui** o arquivo `portuguese.lua` nem a entrada no `LANG_MAP` do widget `aipStorybookPage` — selecionar "Portuguese" faz o livro cair no fallback English. O patch corrige isso via **hook de `require()`**: quando o widget do livro carrega os dados em inglês (fallback) e o idioma do AIP está em "Portuguese", o hook retorna a tradução PT-BR no lugar. Apenas o conteúdo do livro storybook é traduzido (18 capítulos). No-op se o mod AIP não estiver instalado ou se o idioma não for "Portuguese". |

> Os dois mods originais (NPC Friends + Admin Panel) precisam estar instalados e
> ativos. O JingXi Furniture, o Gem Core, o Craft Menu Tweak e o Additional
> Item Package são **opcionais** — os patches correspondentes são defensivos
> (no-op se ausentes). Este patch carrega **depois** dos mods com dependência
> declarada (em `dependencies` no `modinfo.lua`) e apenas neutraliza os
> comportamentos indesejados.

---

## Instalação

1. Tenha os dois mods originais ativos na sua pasta de mods do Don't Starve Together:
   - `workshop-3684000581` (NPC Friends)
   - `workshop-3678857150` (Admin Panel)
2. Copie a pasta deste patch (`dst-warly-admin-patch`) para a sua pasta de mods
   (`mods/`).
3. Ative o patch no menu de mods do jogo, **depois** dos dois mods originais.
   A ordem é garantida pelas dependências declaradas.

Estrutura do mod:

```
dst-warly-admin-patch/
├── modinfo.lua                         # metadata, dependências e opções de config
├── modmain.lua                         # carrega os cinco scripts de patch
├── scripts/
│   └── patch/
│       ├── warly_kitchen_patch.lua     # remove cozinha + prioriza freezer + cookpots
│       ├── admin_revive_patch.lua      # bloqueia ressurreição do admin
│       ├── craft_block_patch.lua       # bloqueia 3 crafts JingXi + itens de luz moddados
│       ├── gemcore_craftmenu_fix.lua   # corrige crash HasGemDictIngredients do Gem Core
│       ├── aip_storybook_ptbr_data.lua # dados da tradução PT-BR do livro AIP storybook (18 capítulos)
│       └── aip_storybook_ptbr.lua      # hook de require() que injeta a tradução PT-BR
└── README.md
```

---

## O que cada patch faz (detalhe técnico)

### 1) `warly_kitchen_patch.lua` — Warly (NPC Friends)

#### A) Remoção da cozinha automática

No mod original, o behavior tree obfuscado `cheffarmbehavior` constrói uma
estação completa assim que o Warly entra no mundo:

- 1 × `portablecookpot` (panela)
- 1 × `icebox` (geladeira)
- 2 × `treasurechest` (baús)

A construção é feita pela classe `BuildStationManager`
(`scripts/npc/npc_build_station.lua`). O patch sobrescreve três métodos dessa
classe (via `require`, que retorna a **mesma tabela** já carregada pelo mod
original, então a alteração se propaga para o behavior tree):

- `GetNextBuildEntry` → retorna sempre `nil` (nada a construir)
- `SpawnStructure` → no-op (não spawna nada)
- `IsComplete` → retorna `true` (estação considerada pronta)

Além disso, um `AddPrefabPostInit("npcfriend", ...)` marca qualquer
`_chef_station` persistida de um save antigo como `built = true`, impedindo
reconstruções. **Não destrói** estruturas que já existam no mundo do jogador.

O restante do Warly continua intacto: tags `masterchef`/`expertchef`, gancho de
aceleração de cozinha (`stewer.cooktimemult`), etc.

#### B) Priorizar freezer no armazenamento de comida

**Bug corrigido:** no mod original o Warly só guarda comida cozida na **própria
geladeira** que ele cria; quando ela enche (ou some), a comida cai nos **baús**.

**Correção ("freezer mais próximo"):** o patch sobrescreve
`InvUtil.SmartStore` (`scripts/npc/npc_inventory_util.lua`) para, antes de
armazenar, procurar ao redor do NPC:

1. Containers com a tag **`freezer`** (prioridade), do mais próximo ao mais
   distante;
2. Containers com a tag **`fridge`** (geladeiras), do mais próximo ao mais
   distante, excluindo os já listados como freezer;
3. A lista original de iceboxes passada pelo behavior (ex.: a geladeira do
   próprio Warly, se ainda existir) como fallback final.

Só cai para os baús se **não houver** nem freezer nem geladeira por perto.
Assim a comida cozida vai para o **freezer mais próximo** do jogador.

#### C) Usar todas as cookpots próximas (não só a do `_cooking_center`)

**Bug corrigido:** no mod original, o brain do Warly passa para o
`NPCCookingBehavior` um `get_cookpots_fn` que coleta cookpots (tag `stewer`)
num raio de 17 em torno de `inst._cooking_center` — uma **posição fixa**
definida quando o jogador usa o comando "Cook Here". Ou seja, o Warly só
enxerga cookpots perto daquele centro fixo, ignorando cookpots/portable
cookpots que estejam ao redor dele no momento. Sintoma: "só usa uma fixa".

**Correção:** o patch sobrescreve `NPCCookingBehavior:_GetCookpots`
(`scripts/behaviours/npc_cooking_behavior.lua`) para:

1. Coletar **todas** as cookpots (tag `stewer`) num raio de 17 em torno da
   **posição ATUAL do NPC**, ordenadas do mais próximo ao mais distante;
2. Mesclar com a lista original (cookpots do `_cooking_center`) como fallback,
   com dedup.

A tag `stewer` cobre `cookpot`, `portablecookpot`, `archive_cookpot` e
qualquer cookpot de outros mods que use o componente `stewer`. Assim o Warly
cozinha em qualquer cookpot próxima dele, onde quer que esteja.

### 2) `admin_revive_patch.lua` — Admin Panel

No mod original, **todos** os caminhos de ressurreição convergem para o RPC
`AdminAction` do mod `DstAdmin`:

- Clique-direito em jogador fantasma (`hooks.lua`) →
  `SendModRPCToServer("respawn|uid")`
- Botão "Reviver" do painel (`adminpanelscreen.lua`) →
  `SendModRPCToServer("respawn|uid")`

O handler server-side chama `ExecuteAdminAction(target, "respawn")` que faz
`target:PushEvent("respawnfromghost")`.

`AddModRPCHandler(modname, name, fn)` usa `(modname, name)` como chave única,
então registrar de novo com `("DstAdmin", "AdminAction")` **sobrescreve** o
handler original. O patch reimplementa o handler para:

- `action == "respawn"` → **no-op** (bloqueado) ✅
- `action == "fullrestore"` → continua funcionando (reimplementado, já que
  `ExecuteAdminAction` é local do env do mod de admin) ✅

O mesmo é feito com o handler cross-shard `ShardAdminAction`. Assim a
ressurreição é bloqueada em todos os mundos (superfície + cavernas).

> Observação de UX: o botão "Reviver" continua visível no painel, mas clicar
> nele **não faz nada** (o servidor ignora a ação `respawn`). O botão "Full
> (全满)" continua funcionando normalmente. Isso preserva o *full restore*,
> que não é ressurreição.

### 3) `craft_block_patch.lua` — JingXi Furniture: bloqueio das fontes de luz

_(veja acima a seção já existente sobre este patch — não alterada nesta versão)_

---

### 4) `gemcore_craftmenu_fix.lua` — Gem Core + Craft Menu Tweak: crash fix

#### Sintoma

Ao passar o mouse sobre um **PinSlot** fixado num **filter recipe** (ex.:
`filter_ARMOUR`) criado pelo Craft Menu Tweak (`workshop-2784074596`), o jogo
**crasha** com:

```
[string "../mods/workshop-1378549454/gemscripts/gemd..."]:249:
attempt to call method 'HasGemDictIngredients' (a nil value)
```

Stack trace (resumida):

```
gemdictionary/ui.lua:249                                   (method) SetRecipe
scripts/widgets/redux/craftingmenu_ingredients.lua:24      (field)  _ctor
scripts/class.lua:191                                      CraftingMenuIngredients
scripts/widgets/redux/craftingmenu_pinslot.lua:314         cria RecipePopupRoot
../mods/workshop-2784074596/modmain.lua:909                (method) ShowRecipe
scripts/widgets/redux/craftingmenu_pinslot.lua:507         (method) OnGainFocus
scripts/frontend.lua:934 / 873                             hover focus update
```

#### Causa raiz

O Craft Menu Tweak tem um recurso de **pin bar** onde o usuário pode fixar um
**filtro** inteiro de crafting (ex.: `ARMOUR`) num slot. Ele cria recipes
sintéticos chamados *filter recipes* (`recipe_name = "filter_ARMOUR"`,
`filter_name = "ARMOUR"`) via `CreateFilterRecipe`. Esses recipes **não são
recipes reais** do jogo — não têm ingredientes normais nem entrada no Gem
Dictionary.

Quando o usuário hover o PinSlot, o `OnGainFocus` → `ShowRecipe` cria um widget
`CraftingMenuIngredients` com esse filter recipe. O **Gem Core**
(`workshop-1378549454`) faz hook do método `SetRecipe` desse widget (em
`gemdictionary/ui.lua:224-286`) e, dentro do hook, chama:

```lua
self:HasGemDictIngredients(recipe)        -- linha 249
```

O método `HasGemDictIngredients` **deveria** ser definido pelo próprio Gem Core
na classe `CraftingMenuIngredients`. Porém ele é `nil` nesse caminho — muito
provavelmente porque o Gem Core só define `HasGemDictIngredients` quando a config
*"Highlight Crafting Ingredients"* (`craftinghighlight`) está ativada, mas o
hook de `SetRecipe` é instalado **incondicionalmente** e chama o método de
qualquer jeito. No relatório de crash do usuário, `craftinghighlight=false`, o
que é consistente: hook instalado, método ausente, crash. O filter recipe
agrava o problema porque também não tem entrada no Gem Dictionary, mas o crash
acontece **antes** de qualquer lookup — é a chamada do próprio método que falha
(`nil`).

#### Correção (load-order-independent)

O patch garante que a classe `CraftingMenuIngredients` **sempre** tenha um
método `HasGemDictIngredients` visível, como **fallback seguro** que retorna
`false` (= "este recipe não tem ingredientes do Gem Dictionary" → nenhum
highlighting → sem crash). Se o Gem Core já definiu o método real, **não
sobrescrevemos** — respeitamos a implementação verdadeira.

Por que funciona independente da ordem de carga:

- `require("widgets/redux/craftingmenu_ingredients")` retorna a **mesma**
  tabela de classe (cacheada em `package.loaded`). Qualquer alteração nessa
  tabela se propaga para **todas** as instâncias futuras, porque o `__index` do
  `class.lua` aponta para essa tabela.
- Se rodarmos **antes** do Gem Core: adicionamos o fallback. Se o Gem Core
  depois definir o método real, ele sobrescreve nosso fallback (bom). Se não
  definir (`craftinghighlight=false`), nosso fallback permanece (bom — evita o
  crash).
- Se rodarmos **depois** do Gem Core: se o Gem Core definiu o método real,
  pulamos (não sobrescrevemos). Se não definiu, adicionamos o fallback.
- Re-check no `AddPrefabPostInit("world")` + `DoTaskInTime(0)` cobre o caso
  raro de algum mod re-`require` do script e resetar a tabela, ou do Gem Core
  fazer wipe do método depois.

#### Defensivo

Se o Gem Core não estiver instalado, o método `SetRecipe` do widget é o
**original** do jogo (não chama `HasGemDictIngredients`), e nosso fallback
simplesmente fica dormindo na classe — **nenhum efeito colateral**. O patch é
no-op completo sem o Gem Core. Da mesma forma, se o Craft Menu Tweak não
estiver instalado, nenhum filter recipe é criado, mas o fallback continua
válido para qualquer outro mod que dispare o mesmo caminho.

---

### 5) `aip_storybook_ptbr.lua` + `aip_storybook_ptbr_data.lua` — Additional Item Package: tradução PT-BR do livro storybook

#### Sintoma

O mod **Additional Item Package** (`workshop-1085586145`) tem uma opção de
idioma **"Portuguese"** no seu `modinfo.lua` (config `language` com
`data="portuguese"`). Porém a versão de workshop **não inclui**:

- o arquivo `scripts/aipStory/portuguese.lua` (a tradução), e
- a entrada `portuguese="aipStory/portuguese"` no `LANG_MAP` do widget
  `scripts/widgets/redux/aipStorybookPage.lua`.

Resultado: quando o jogador seleciona "Portuguese" no config do AIP, o widget
faz:

```lua
local language = aipGetModConfig("language")          -- "portuguese"
local LANG_MAP = { chinese="aipStory/chinese", default="aipStory/english" }
local langPath = LANG_MAP[language] or LANG_MAP["default"]   -- nil → "aipStory/english"
local docs = require(langPath)                        -- carrega INGLÊS
```

Ou seja, o livro storybook aparece em **inglês** mesmo com o idioma em
"Portuguese".

#### Correção (hook de `require()`)

O patch instala um **hook de `_G.require`** que intercepta **apenas**
`require("aipStory/english")`. Quando esse require é chamado, o hook verifica
se o idioma configurado do AIP é `"portuguese"` (lendo via
`GetModConfigData("language", "workshop-1085586145")` com fallback para
`_G.aipGetModConfig("language")`). Se for, o hook retorna a **tabela PT-BR**
(`AIP_STORYBOOK_PTBR_DATA`) no lugar dos dados em inglês. Nos demais casos
(inglês, chinês, ou AIP ausente), o require original roda normalmente.

Por que este approach:

- `LANG_MAP` é uma **local** do arquivo `aipStorybookPage.lua` — não dá para
  mutar de fora sem substituir o arquivo inteiro.
- O `require(langPath)` roda no **topo do arquivo** (tempo de carga), então
  o hook precisa estar instalado **antes** do widget ser carregado. Como o
  widget só é carregado quando o jogador abre o livro (on-demand), e o
  modmain do patch roda no load do mundo, o hook sempre está no lugar a tempo.
- Interceptar `require("aipStory/english")` é **cirúrgico**: só afeta o
  carregamento de dados do livro storybook do AIP. Nenhum outro módulo do
  jogo ou de outros mods é afetado.

#### Dados da tradução

A tabela de tradução vive em `aip_storybook_ptbr_data.lua` (1629 linhas,
48 KB) e é carregada via `modimport` **antes** do script de patch. O `modimport`
roda o arquivo no env do mod, que define a global `AIP_STORYBOOK_PTBR_DATA`.
O script de patch captura essa global como local para performance.

A tradução cobre **apenas o conteúdo do livro storybook** (o item "API
storybook"):

- **18 capítulos** de prosa de lore (títulos + parágrafos)
- **4 labels de qualidade de pet** (`type="txt"`): `-Bom`, `-Ótimo`,
  `-Excepcional`, `-Perfeito` (originais: `-Nice`, `-Great`, `-Outstanding`,
  `-Perfect`)
- Preserva **inalterados**: todos os `type="img"` (111 entradas, identificadores
  de asset), todos os `type="anim"` (64 entradas, build/bank/anim), e todas as
  referências `color=PET_QUALITY_COLORS[N]` (cores inlined para evitar
  dependência cross-mod).

**NÃO traduz** nomes de itens, labels de UI, ou outras strings do mod AIP —
apenas o conteúdo do livro.

#### Defensivo

- Se o mod AIP não estiver instalado, ninguém chama `require("aipStory/english")`,
  então o hook nunca dispara (no-op).
- Se o idioma do AIP for `"english"`, `"chinese"` ou qualquer outro, o hook
  retorna o require original (inglês ou chinês carregam normalmente).
- Se a leitura do config do AIP falhar (ambos `GetModConfigData` e
  `aipGetModConfig` retornam nil), o hook desativa-se (retorna o require
  original).
- O hook é instalado **uma única vez** (guard `_G._WARLY_AIP_STORYBOOK_HOOK_INSTALLED`).

---

Bloqueia as **fontes de luz** do mod workshop-3597024951 (JingXi Furniture /
景熹家居). Os nomes de prefab abaixo foram obtidos por **análise direta do
código-fonte** do mod em
[github.com/HIKESS/Mods/3597024951](https://github.com/HIKESS/Mods/tree/main/3597024951)
— não são chutes. Cada prefab foi confirmado como (a) emissor de luz real
(componente `Light` direto ou spawn de light fx) e (b) craftável (registrado
via `AddRecipe2` em `scripts/jxmain/jx_recipes.lua`).

Duas fases, ambas controladas por config e **defensivas** (no-op se o mod não
estiver instalado):

#### Fase 1 — `block_jingxi_crafts`: os 3 itens nomeados

| Prefab | Nome EN | Nome ZH |
|--------|---------|---------|
| `jx_mushroom_light` | Gothic Palace Streetlight | 哥特式宫廷道路灯 |
| `jx_mushroom_light_2` | RoseRed Solid Wood Lamp | 蔷薇红实木室内灯 |
| `jx_lamp_2` | Engraved Candlestick | 雕花三臂欧式烛台 |

> **Nota:** os nomes que o usuário passou ("gothic palace strong light",
> "rose red solid woodlamp", "engraved candlestick") correspondem a estes 3
> prefabs — o nome EN real de `jx_mushroom_light` é "Gothic Palace
> **Streetlight**" (não "strong light"), o que é por que a abordagem anterior
> por vocabulário falhou. Agora casamos pelo **nome exato de prefab**, que é
> à prova de locale e de variação de tradução.

#### Fase 2 — `block_light_emitting_crafts`: todas as fontes de luz puras

| Prefab | Nome EN | Nome ZH | Tipo de luz |
|--------|---------|---------|-------------|
| `jx_mushroom_light` | Gothic Palace Streetlight | 哥特式宫廷道路灯 | `Light` direto |
| `jx_mushroom_light_2` | RoseRed Solid Wood Lamp | 蔷薇红实木室内灯 | `Light` direto |
| `jx_lamp_2` | Engraved Candlestick | 雕花三臂欧式烛台 | `Light` direto |
| `jx_lamp` | Vintage Embellished Bedside Lamp | 复古缀饰床头灯 | `Light` direto (fueled) |
| `jx_lantern` | Gemstone Rose Night Patrol Light | 宝石玫瑰夜巡灯 | spawn `lanternlight` |
| `jx_flashlight` | Miller's Flashlight | 米勒的手电筒 | comp. `jx_flashlight` |

**NÃO bloqueamos** itens funcionais onde a luz é efeito colateral de
cozinha/aquecimento/tela: `jx_cookpot`, `jx_furnace`, `jx_oven`,
`jx_charcoal_stove`, `jx_toaster`, `jx_portable_cook_pot(_2)`,
`jx_portabletent`, `jx_table_8`, `jx_tv`, `jx_vending_machine`. Bloquear
esses quebraria as funções de cozinha/aquecimento/TV do mod. "Fonte de luz" =
item cuja função **primária** é iluminar. Se quiser bloquear também esses,
adicione os prefabs à lista `LIGHT_SOURCE_PREFABS` no script.

#### Mecanismo de bloqueio (tríplice, para máxima confiabilidade)

Para cada recipe que casa, aplicamos **três** mecanismos redundantes —
qualquer um já esconde o recipe; os três juntos garantem funcionamento em
qualquer versão do DST e com qualquer filtro customizado (o JingXi usa o
filtro `JXTAB`):

1. `recipe.builder_tag = "__warly_admin_patch_blocked"` → nenhum jogador tem
   essa tag, então `Builder:CanMake()` retorna false.
2. `recipe.CanLearn = function() return false end` →
   `Builder:KnowsRecipe()` falha; o recipe some do menu.
3. `recipe.filters = {}` (Recipe2) / `recipe.tab = nil` (Recipe antigo) → o
   recipe não aparece em **nenhuma** aba de crafting, porque o menu itera
   `filters` para decidir onde mostrar cada recipe.
4. `recipe:SetBuilderTag(...)` se existir o método (algumas versões cacheiam).

**Não** remove o recipe de `AllRecipes` — outros mods que referenciem o
recipe continuam funcionando. Operação reversível e não destrutiva.

#### Timing

O scan roda em `AddPrefabPostInit("world")` + `DoTaskInTime(0)`. No spawn do
prefab `"world"`, **todos** os modmain já rodaram (host + clients, surface +
caves), então `AllRecipes` está totalmente populado, independente da ordem de
carga. O scan itera pelos **nomes exatos de prefab** (não varre tudo), então
é rápido e direto. Um guard por-recipe (`_patch_blocked`) torna o scan
idempotente.

---

## Opções de configuração (`modinfo.lua`)

### Patches principais

| Opção | Padrão | Descrição |
|-------|--------|-----------|
| `remove_warly_kitchen` | `true` | Remove a cozinha automática do Warly. |
| `freezer_priority_storage` | `true` | Prioriza freezer/geladeira mais próximos no armazenamento de comida. |
| `freezer_search_radius` | `60` | Raio de busca por freezers/geladeiras ao redor do NPC. |
| `block_admin_revive` | `true` | Bloqueia a ressurreição do painel admin. |
| `use_all_nearby_cookpots` | `true` | Faz o Warly cozinhar em todas as cookpots/portable cookpots próximas dele (não só na cookpot fixa do `_cooking_center`). |
| `block_jingxi_crafts` | `true` | Bloqueia os 3 crafts nomeados do JingXi Furniture pelos nomes EXATOS de prefab: `jx_mushroom_light`, `jx_mushroom_light_2`, `jx_lamp_2`. No-op se o mod não estiver instalado. |
| `block_light_emitting_crafts` | `true` | Bloqueia TODAS as fontes de luz puras do JingXi (nomes EXATOS do código-fonte): `jx_lamp`, `jx_lamp_2`, `jx_mushroom_light`, `jx_mushroom_light_2`, `jx_lantern`, `jx_flashlight`. NÃO bloqueia itens funcionais (cookpot/forno/TV) — preserva cozinha/aquecimento. |
| `fix_gemcore_craftmenu_crash` | `true` | Corrige o crash `HasGemDictIngredients nil` do Gem Core (workshop-1378549454) ao hover de PinSlot de filter recipe (ex.: `filter_ARMOUR`) do Craft Menu Tweak (workshop-2784074596). Instala fallback seguro na classe do widget. No-op se o Gem Core não estiver instalado. |
| `translate_aip_storybook` | `true` | Injeta a tradução PT-BR do livro "API storybook" do mod Additional Item Package (workshop-1085586145) via hook de `require()`. Apenas o conteúdo do livro é traduzido (18 capítulos). No-op se o mod AIP não estiver instalado ou se o idioma não for "Portuguese". |

### Whitelist — NÃO bloquear itens específicos

Cada opção abaixo, quando **Ativada**, impede que o item correspondente seja
bloqueado — **mesmo** com `block_jingxi_crafts` e/ou `block_light_emitting_crafts`
ativados. Use estas opções para manter as lanternas/lâmpadas/flashlight que você
quer, enquanto bloqueia o resto.

| Opção | Padrão | Prefab | Item |
|-------|--------|--------|------|
| `allow_jx_lantern` | `false` | `jx_lantern` | Gemstone Rose Night Patrol Light / 宝石玫瑰夜巡灯 (lanterna de patrulha noturna) |
| `allow_jx_flashlight` | `false` | `jx_flashlight` | Miller's Flashlight / 米勒的手电筒 (lanterna de mão) |
| `allow_jx_lamp` | `false` | `jx_lamp` | Vintage Embellished Bedside Lamp / 复古缀饰床头灯 (abajur de cabeceira) |
| `allow_jx_mushroom_light` | `false` | `jx_mushroom_light` | Gothic Palace Streetlight / 哥特式宫廷道路灯 (lâmpada de rua gótica) |
| `allow_jx_mushroom_light_2` | `false` | `jx_mushroom_light_2` | RoseRed Solid Wood Lamp / 蔷薇红实木室内灯 (lâmpada de madeira) |
| `allow_jx_lamp_2` | `false` | `jx_lamp_2` | Engraved Candlestick / 雕花三臂欧式烛台 (candelabro entalhado) |

> **Exemplo:** para **não bloquear as lanternas** (lantern + flashlight) enquanto
> bloqueia as demais fontes de luz, ative `block_light_emitting_crafts` = `true`,
> `allow_jx_lantern` = `true` e `allow_jx_flashlight` = `true`.

Para desativar temporariamente qualquer um dos patches, mude a opção
correspondente no menu de mods (não é preciso reiniciar o servidor, mas é
recomendado).

---

## Logs

O patch imprime mensagens prefixadas com `[WarlyAdminPatch]` no log do jogo.
Procure por:

- `[WarlyAdminPatch][Warly] Cozinha automática DESATIVADA ...`
- `[WarlyAdminPatch][Warly] Armazenamento com prioridade de FREEZER ativado ...`
- `[WarlyAdminPatch][Admin] Ressurreição do painel admin BLOQUEADA ...`
- `[WarlyAdminPatch][CraftBlock] hid '<recipe>' (phase1 named)`
- `[WarlyAdminPatch][CraftBlock] hid '<recipe>' (phase2 light source)`
- `[WarlyAdminPatch][CraftBlock] KEEP '<recipe>' (whitelisted by config allow_*) — not blocked.`
- `[WarlyAdminPatch][CraftBlock] N recipe(s) de fonte de luz oculto(s)/bloqueado(s), M mantido(s) por whitelist ...`
- `[WarlyAdminPatch][CraftBlock] AVISO: recipe '<name>' não encontrado em AllRecipes (mod 3597024951 não instalado?).`
- `[WarlyAdminPatch][GemCoreFix] fallback HasGemDictIngredients instalado na classe CraftingMenuIngredients (retorna false -> sem highlighting, sem crash).`
- `[WarlyAdminPatch][GemCoreFix] patch registrado (fallback HasGemDictIngredients + re-check no world load).`
- `[WarlyAdminPatch][GemCoreFix] AVISO: nao foi possivel require 'widgets/redux/craftingmenu_ingredients' ...` (apenas em ambientes sem o frontend)
- `[WarlyAdminPatch] AIP-Storybook-PTBR: hook de require instalado.`
- `[WarlyAdminPatch] AIP-Storybook-PTBR: quando o AIP language=portuguese, o livro storybook usará a tradução PT-BR.`
- `[WarlyAdminPatch] AIP-Storybook-PTBR: injetando tradução PT-BR (AIP language=portuguese).` (quando o livro é aberto)
- `[WarlyAdminPatch] AIP-Storybook-PTBR: ERRO — AIP_STORYBOOK_PTBR_DATA é nil.` (se o data file não carregou)

Se algo não carregou (ex.: o mod alvo mudou de versão), aparecerá um `AVISO`
ou mensagem indicando qual `require` falhou — o resto do patch ainda tenta rodar.

---

## Compatibilidade

- Testado contra as versões do repositório [HIKESS/Mods](https://github.com/HIKESS/Mods)
  (NPC Friends `v0.2.6`, Admin Panel `v1.3.1`) e do JingXi Furniture
  (workshop-3597024951, versão `26.06.01` — código-fonte analisado em
  [github.com/HIKESS/Mods/3597024951](https://github.com/HIKESS/Mods/tree/main/3597024951)).
- O bloqueio de fontes de luz do JingXi usa **nomes EXATOS de prefab**
  confirmados no código-fonte do mod. Se o JingXi não estiver instalado, o
  scan imprime `AVISO: recipe '...' não encontrado` para cada prefab e o jogo
  não quebra (no-op). Se uma futura versão do JingXi renomear esses prefabs,
  o mesmo aviso aparece — basta atualizar a lista `LIGHT_SOURCE_PREFABS` /
  `NAMED_PREFABS` no script.
- Não modifica nenhum arquivo dos mods originais — tudo é feito por hooks em
  tempo de execução.
- Se os mods originais renomearem os módulos `npc/npc_build_station` /
  `npc/npc_inventory_util` ou o RPC `DstAdmin/AdminAction`, os `require` /
  re-registros correspondentes emitirão um `AVISO` no log e aquele pedaço do
  patch não será aplicado (sem quebrar o jogo).

---

## Licença / autor

Patch criado para uso com os mods de [HIKESS](https://github.com/HIKESS). Os
mods originais pertencem aos seus respectivos autores.
