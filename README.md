# Warly Kitchen + Admin Revive + Craft Block Patch

Um **único patch** para mods do repositório [HIKESS/Mods](https://github.com/HIKESS/Mods) + Steam Workshop:

| Mod | Workshop ID | O que o patch faz |
|-----|-------------|-------------------|
| **NPC Friends** (橘子的NPC小伙伴) | `workshop-3684000581` | Foco no **Warly**: (1) remove a cozinha completa que ele cria no início do jogo (baú/panela/geladeira); (2) corrige o armazenamento de comida para priorizar o **freezer mais próximo** (tag `freezer`) antes das geladeiras e dos baús; (3) faz o Warly cozinhar em **TODAS as cookpots/portable cookpots próximas** dele, em vez de só na cookpot fixa do `_cooking_center`. |
| **Admin Panel** (橘子的超级管理员) | `workshop-3678857150` | Bloqueia a **ressurreição / auto-ressurreição** (botão "Reviver" + clique-direito em fantasma) para evitar abuso. O resto do painel (ver/pegar/dar itens, *full restore*, status de NPC, etc.) continua funcionando. **A dependência deste mod NÃO é removida.** |
| **JingXi Furniture** (optional, não-dependência) | `workshop-3597024951` | **Bloqueia crafts**: (a) os 3 itens nomeados — *gothic palace strong light*, *rose red solid woodlamp*, *engraved candlestick*; (b) **qualquer item que emita luz** (por vocabulário de nome: lamp/lantern/candle/灯/烛/强光…) em **tabs de crafting moddadas** (não-vanilla). Tocha/fogueira/lanterna vanilla continuam craftáveis. No-op se o mod não estiver instalado. |

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

### 3) `craft_block_patch.lua` — JingXi Furniture + bloqueio de itens de luz

Duas fases, ambas controladas por config e **defensivas** (no-op se o mod
alvo não estiver instalado):

#### Fase 1 — `block_jingxi_crafts`: os 3 itens nomeados

Bloqueia os 3 crafts especificados:

1. *gothic palace Strong light*
2. *rose red solid woodlamp*
3. *engraved candlestick*

O patch **não** tem acesso ao código-fonte do JingXi Furniture, então os nomes
exatos de prefab não são conhecidos. Em vez de chutar um nome e errar, faz
**match duplo**:

- **(A) Nome de prefab** (snake_case) — candidatos derivados da descrição
  (ex.: `gothic_palace_strong_light`, `engraved_candlestick`). Casa por
  igualdade OU substring (len ≥ 5).
- **(B) Nome de exibição** — pego de `STRINGS.NAMES[prefab]`. Um recipe é
  bloqueado se o display name contiver **todas** as palavras-chave de
  **qualquer** grupo (case-insensitive). Grupos em **inglês E chinês**
  (porque o mod é chinês com tradução inglesa) → funciona em qualquer locale.

#### Fase 2 — `block_light_emitting_crafts`: itens que emitem luz (genérico)

Procura por crafts cujo nome/prefab indique **emissão de luz** e os bloqueia.
Vocabulário de luz casado (substring, case-insensitive):

- **Inglês**: `lamp`, `lantern`, `candle`, `candlestick`, `chandelier`,
  `sconce`, `brazier`, `candelabra`, `illumin`, `beacon`, `firelight`,
  `woodlamp`, `stronglight`, `strong light`, `torch`, `lightbulb`,
  `nightlight`, `ceilinglight`, `walllight`, `streetlight`, `streetlamp`,
  `headlight`, `floodlight`, `spotlight`, `lumin`, `glowstone`…
- **Chinês**: `灯`, `烛`, `烛台`, `壁灯`, `吊灯`, `台灯`, `路灯`, `宫灯`,
  `花灯`, `强光`, `照明`, `明灯`, `火炬`, `光柱`, `荧光灯`…

**Scoping crítico:** só bloqueia recipes em **tabs de crafting MODDADAS**
(não-vanilla). As tabs vanilla (`SURVIVAL`, `TOOLS`, `LIGHT`, `FARM`,
`SCIENCE`, `FIGHT`, `STRUCTURES`, `REFINE`, `COOK`, `DRESS`, `MAGIC`,
`ANCIENT`, `DECOR`, `RUMMAGE`, `ARCHIVE`, `SEASONS`, …) são excluídas. Assim a
tocha, fogueira, lanterna, miner hat, etc. **continuam craftáveis** — só
móveis de luz de mods (JingXi e outros) são ocultados.

> **Por que vocabulário + tab e não spawn+check de `components.light`?**
> O menu de crafting é client-side — para **ocultar** um recipe em todos os
> clients, o `builder_tag` precisa ser setado no processo de **cada** client.
> Um scan só-server não esconde o recipe nos clients, e spawnar prefabs de
> estrutura em clients gera som/partículas/tráfego de rede indesejado. A
> abordagem por vocabulário roda idêntica em todos os processos, sem spawn,
> sem side-effects.

#### Mecanismo de bloqueio (comum às duas fases)

Para cada recipe que casa:

1. `recipe.builder_tag = "__warly_admin_patch_blocked"` → nenhum jogador tem
   essa tag, então `Builder:CanMake()` retorna false e o recipe **some** do
   menu de crafting.
2. `recipe.CanLearn = function() return false end` → backup para `Recipe2`.
3. `recipe:SetBuilderTag(...)` se existir o método (algumas versões cacheiam).

**Não** remove o recipe de `AllRecipes` — outros mods que referenciem o
recipe continuam funcionando. Operação reversível e não destrutiva.

#### Timing

O scan roda em `AddPrefabPostInit("world")` + `DoTaskInTime(0)`. No spawn do
prefab `"world"`, **todos** os modmain já rodaram (host + clients, surface +
caves), então `AllRecipes` está totalmente populado, independente da ordem de
carga. Um guard por-recipe (`_patch_blocked`) torna o scan idempotente.

---

## Opções de configuração (`modinfo.lua`)

| Opção | Padrão | Descrição |
|-------|--------|-----------|
| `remove_warly_kitchen` | `true` | Remove a cozinha automática do Warly. |
| `freezer_priority_storage` | `true` | Prioriza freezer/geladeira mais próximos no armazenamento de comida. |
| `freezer_search_radius` | `60` | Raio de busca por freezers/geladeiras ao redor do NPC. |
| `block_admin_revive` | `true` | Bloqueia a ressurreição do painel admin. |
| `use_all_nearby_cookpots` | `true` | Faz o Warly cozinhar em todas as cookpots/portable cookpots próximas dele (não só na cookpot fixa do `_cooking_center`). |
| `block_jingxi_crafts` | `true` | Oculta/bloqueia os 3 crafts nomeados do JingXi Furniture (gothic palace strong light, rose red solid woodlamp, engraved candlestick). No-op se o mod não estiver instalado. |
| `block_light_emitting_crafts` | `true` | Bloqueia crafts cujo nome indique emissão de luz (lamp/lantern/candle/灯/烛/强光…) em **tabs de crafting moddadas** (não-vanilla). Vanilla torch/campfire/lantern continuam craftáveis. |

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
- `[WarlyAdminPatch][CraftBlock] hid '<recipe>' (phase1 prefab pattern)`
- `[WarlyAdminPatch][CraftBlock] hid '<recipe>' (phase2 light name '灯')`
- `[WarlyAdminPatch][CraftBlock] N recipe(s) oculto(s)/bloqueado(s) ...`

Se algo não carregou (ex.: o mod alvo mudou de versão), aparecerá um `AVISO`
ou mensagem indicando qual `require` falhou — o resto do patch ainda tenta rodar.

---

## Compatibilidade

- Testado contra as versões do repositório [HIKESS/Mods](https://github.com/HIKESS/Mods)
  (NPC Friends `v0.2.6`, Admin Panel `v1.3.1`).
- O bloqueio de crafts do JingXi Furniture (workshop-3597024951) é **defensivo**:
  como o patch não tem acesso ao código-fonte do mod, ele casa por nome de
  prefab + vocabulário de luz em tabs moddadas. Se o JingXi não estiver
  instalado, nada casa (no-op). Se os nomes divergirem, aparece
  `nenhum recipe-alvo encontrado` no log e o jogo não quebra.
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
