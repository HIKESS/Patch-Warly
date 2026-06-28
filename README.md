# Warly Kitchen + Admin Revive + Craft Block Patch

Um **único patch** para mods do repositório [HIKESS/Mods](https://github.com/HIKESS/Mods) + Steam Workshop:

| Mod | Workshop ID | O que o patch faz |
|-----|-------------|-------------------|
| **NPC Friends** (橘子的NPC小伙伴) | `workshop-3684000581` | Foco no **Warly**: (1) remove a cozinha completa que ele cria no início do jogo (baú/panela/geladeira); (2) corrige o armazenamento de comida para priorizar o **freezer mais próximo** (tag `freezer`) antes das geladeiras e dos baús; (3) faz o Warly cozinhar em **TODAS as cookpots/portable cookpots próximas** dele, em vez de só na cookpot fixa do `_cooking_center`. |
| **Admin Panel** (橘子的超级管理员) | `workshop-3678857150` | Bloqueia a **ressurreição / auto-ressurreição** (botão "Reviver" + clique-direito em fantasma) para evitar abuso. O resto do painel (ver/pegar/dar itens, *full restore*, status de NPC, etc.) continua funcionando. **A dependência deste mod NÃO é removida.** |
| **JingXi Furniture** (optional, não-dependência) | `workshop-3597024951` | **Bloqueia as fontes de luz do mod** pelos nomes EXATOS de prefab (obtidos do código-fonte): (a) os 3 itens nomeados — `jx_mushroom_light` (Gothic Palace Streetlight), `jx_mushroom_light_2` (RoseRed Solid Wood Lamp), `jx_lamp_2` (Engraved Candlestick); (b) **todas as fontes de luz puras** — + `jx_lamp`, `jx_lantern`, `jx_flashlight`. NÃO bloqueia itens funcionais (cookpot/forno/TV) — preserva cozinha/aquecimento. No-op se o mod não estiver instalado. |

> Os dois mods originais (NPC Friends + Admin Panel) precisam estar instalados e
> ativos. O JingXi Furniture é **opcional** — o patch de bloqueio de crafts é
> defensivo (no-op se ausente). Este patch carrega **depois** dos mods com
> dependência declarada (em `dependencies` no `modinfo.lua`) e apenas
> neutraliza os comportamentos indesejados.

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
├── modmain.lua                         # carrega os três scripts de patch
├── scripts/
│   └── patch/
│       ├── warly_kitchen_patch.lua     # remove cozinha + prioriza freezer + cookpots
│       ├── admin_revive_patch.lua      # bloqueia ressurreição do admin
│       └── craft_block_patch.lua       # bloqueia 3 crafts JingXi + itens de luz moddados
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
