# Warly Kitchen + Admin Revive Patch

Um **único patch** para **dois mods** do repositório [HIKESS/Mods](https://github.com/HIKESS/Mods):

| Mod | Workshop ID | O que o patch faz |
|-----|-------------|-------------------|
| **NPC Friends** (橘子的NPC小伙伴) | `workshop-3684000581` | Foco no **Warly**: remove a cozinha completa que ele cria no início do jogo (baú/panela/geladeira) e corrige o armazenamento de comida para priorizar o **freezer mais próximo** (tag `freezer`) antes das geladeiras e dos baús. |
| **Admin Panel** (橘子的超级管理员) | `workshop-3678857150` | Bloqueia a **ressurreição / auto-ressurreição** (botão "Reviver" + clique-direito em fantasma) para evitar abuso. O resto do painel (ver/pegar/dar itens, *full restore*, status de NPC, etc.) continua funcionando. **A dependência deste mod NÃO é removida.** |

> Os dois mods originais precisam estar instalados e ativos. Este patch carrega
> **depois** deles (declarado em `dependencies` no `modinfo.lua`) e apenas
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
├── modmain.lua                         # carrega os dois scripts de patch
├── scripts/
│   └── patch/
│       ├── warly_kitchen_patch.lua     # remove cozinha + prioriza freezer
│       └── admin_revive_patch.lua      # bloqueia ressurreição do admin
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

---

## Opções de configuração (`modinfo.lua`)

| Opção | Padrão | Descrição |
|-------|--------|-----------|
| `remove_warly_kitchen` | `true` | Remove a cozinha automática do Warly. |
| `freezer_priority_storage` | `true` | Prioriza freezer/geladeira mais próximos no armazenamento de comida. |
| `freezer_search_radius` | `60` | Raio de busca por freezers/geladeiras ao redor do NPC. |
| `block_admin_revive` | `true` | Bloqueia a ressurreição do painel admin. |

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

Se algo não carregou (ex.: o mod alvo mudou de versão), aparecerá um `AVISO`
ou `ERRO` indicando qual `require` falhou — o resto do patch ainda tenta rodar.

---

## Compatibilidade

- Testado contra as versões do repositório [HIKESS/Mods](https://github.com/HIKESS/Mods)
  (NPC Friends `v0.2.6`, Admin Panel `v1.3.1`).
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
