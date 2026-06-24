-- ============================================================================
--  admin_revive_patch.lua
--  Patch para o mod Admin Panel (workshop-3678857150).
--
--  Objetivo: remover a capacidade de ressurreição / auto-ressurreição que o
--  painel de admin oferece (botão "Reviver" + clique-direito em jogador
--  fantasma), para evitar abuso de auto-ressurreição. O dono do server
--  continua com todo o resto do painel (ver itens, pegar/dar itens, full
--  restore de life/hunger/sanity, status de NPC, etc.).
--
--  A dependência do mod de admin NÃO é removida — este patch só carrega depois
--  dele e neutraliza a ação de "respawn".
--
--  COMO FUNCIONA
--  -------------
--  No mod original, TODOS os caminhos de ressurreição convergem para o RPC
--  "AdminAction" do mod "DstAdmin":
--    * clique-direito em fantasma (hooks.lua) -> SendModRPCToServer("respawn|uid")
--    * botão "Reviver" do painel              -> SendModRPCToServer("respawn|uid")
--  O handler server-side chama ExecuteAdminAction(target,"respawn") que faz
--  target:PushEvent("respawnfromghost").
--
--  AddModRPCHandler(modname, name, fn) usa (modname,name) como chave única,
--  então registrar de novo com ("DstAdmin","AdminAction") SOBRESCREVE o
--  handler original. Reimplementamos o handler para:
--    * action == "respawn"      -> NO-OP (bloqueado)
--    * action == "fullrestore"  -> continua funcionando (reimplementado, já que
--                                  ExecuteAdminAction é local do env do mod)
--  Fazemos o mesmo com o handler cross-shard "ShardAdminAction".
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════════
--  Helpers
-- ═══════════════════════════════════════════════════════════════════════════

--- Verifica se `player` é admin do servidor.
--- (Réplica do cheque do handler original, em GLOBAL para independência do env.)
local function _IsAdmin(player)
    if not player or not player.userid then return false end
    local ok, res = GLOBAL.pcall(function()
        for _, c in ipairs(GLOBAL.TheNet:GetClientTable() or {}) do
            if c.userid == player.userid and c.admin then
                return true
            end
        end
        return false
    end)
    return ok and res or false
end

--- Reimplementa o "fullrestore" do server_utils.lua original.
--- (Não podemos chamar ExecuteAdminAction, que é local do env do mod de admin.)
local function _DoFullRestore(target)
    if not target or not target.components then return end
    if target.components.health then target.components.health:SetPercent(1) end
    if target.components.hunger then target.components.hunger:SetPercent(1) end
    if target.components.sanity then target.components.sanity:SetPercent(1) end
end

--- Acha um jogador pelo userid no shard atual.
local function _FindPlayerByUserid(userid)
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == userid then
            return p
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════════
--  Re-registra o RPC "AdminAction" (sobrescreve o handler original)
-- ═══════════════════════════════════════════════════════════════════════════

AddModRPCHandler("DstAdmin", "AdminAction", function(player, params_str)
    if not player or type(params_str) ~= "string" then return end
    if not _IsAdmin(player) then return end

    local action, target_userid = params_str:match("^([^|]+)|(.+)$")
    if not action or not target_userid then return end

    -- >>> BLOQUEIO DE RESSURREIÇÃO <<<
    if action == "respawn" then
        -- Ressurreição desativada pelo patch. Log opcional em modo debug.
        if GLOBAL.WARLY_ADMIN_PATCH_DEBUG then
            print(string.format("[WarlyAdminPatch][Admin] respawn BLOQUEADO para userid=%s",
                tostring(target_userid)))
        end
        return
    end

    -- fullrestore continua funcionando normalmente.
    if action == "fullrestore" then
        local target = _FindPlayerByUserid(target_userid)
        if target then
            _DoFullRestore(target)
        else
            -- Jogador está em outro shard: repassa para os outros mundos.
            GLOBAL.pcall(function()
                SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardAdminAction"),
                    nil, action .. "|" .. target_userid)
            end)
        end
        return
    end

    -- Qualquer outra ação: ignorada (o handler original só tratava respawn/fullrestore).
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  Re-registra o RPC cross-shard "ShardAdminAction"
-- ═══════════════════════════════════════════════════════════════════════════

AddShardModRPCHandler("DstAdmin", "ShardAdminAction", function(shard_id, data_str)
    local action, target_userid = tostring(data_str or ""):match("^([^|]+)|(.+)$")
    if not action or not target_userid then return end

    -- >>> BLOQUEIO DE RESSURREIÇÃO (cross-shard) <<<
    if action == "respawn" then
        return
    end

    if action == "fullrestore" then
        local target = _FindPlayerByUserid(target_userid)
        if target then
            _DoFullRestore(target)
        end
        return
    end
end)

print("[WarlyAdminPatch][Admin] Ressurreição do painel admin BLOQUEADA. (fullrestore mantido; demais recursos intactos.)")
