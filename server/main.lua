local QBCore = exports['qb-core']:GetCoreObject()
local playersInScene = {}

local function startScene(source, targetId, data)
    if playersInScene[targetId] then
        TriggerClientEvent('QBCore:Notify', source, "Target is already in a scene. Please wait.", 'error')
        return
    end
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', source, "Player not found.", 'error')
        return
    end
    
    playersInScene[targetId] = true

    local actionText = data.action == "kick" and "kick" or "BAN"
    TriggerClientEvent('QBCore:Notify', source, string.format('Initiating %s for %s...', actionText, targetPlayer.PlayerData.charinfo.firstname), 'success')
    
    TriggerClientEvent("ap_kidnap:startKidnapScene", targetId, data)
end

QBCore.Commands.Add(Config.CommandName, 'Kick a player', {{name = "id", help = "Player Server ID"}}, false, function(source, args)
    startScene(source, tonumber(args[1]), { action = "kick" })
end, Config.Permission)

QBCore.Commands.Add(Config.BanCommandName, 'Ban a player', {
    {name = "id", help = "Player Server ID"},
    {name = "time", help = "Ban duration in HOURS (0 = permanent)"},
    {name = "reason", help = "Reason for the ban"}
}, false, function(source, args)
    local banData = {
        action = "ban_qbcore",
        reason = table.concat(args, " ", 3) or Config.BanMessageDefault,
        expire = nil,
        adminName = GetPlayerName(source)
    }
    local time = tonumber(args[2]) or 0
    if time > 0 then banData.expire = os.time() + (time * 3600) end
    
    startScene(source, tonumber(args[1]), banData)
end, Config.BanPermission)

RegisterNetEvent('ap_kidnap:performActionAfterScene', function(data)
    local source = source
    playersInScene[source] = nil
    
    if data.action == "kick" then DropPlayer(source, Config.KickMessage)
    elseif data.action == "ban_qbcore" then
        local identifiers = {}; for i = 0, GetNumPlayerIdentifiers(source) - 1 do table.insert(identifiers, GetPlayerIdentifier(source, i)) end
        local license, discord, ip; for _, identifier in ipairs(identifiers) do if string.match(identifier, "license:") then license = identifier end; if string.match(identifier, "discord:") then discord = identifier end; if string.match(identifier, "ip:") then ip = identifier end end
        DropPlayer(source, data.reason)
        exports.oxmysql:execute('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', { GetPlayerName(source) or "Unknown", license or "N/A", discord or "N/A", ip or "N/A", data.reason, data.expire, data.adminName })
    end
end)

RegisterNetEvent('ap_kidnap:sceneAborted', function()
    local source = source
    if playersInScene[source] then
        print(string.format("[ap_kidnap] Scene aborted by client %d. Unlocking status.", source))
        playersInScene[source] = nil
    end
end)

AddEventHandler('playerDropped', function(reason)
    if playersInScene[source] then
        playersInScene[source] = nil
    end
end)