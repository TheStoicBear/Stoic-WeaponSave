-- Initialize core objects for QBCore, ESX, and NDCore
local QBCore = nil
local ESX = nil
local NDCore = nil

-- Check for QBCore and set the core object
if GetResourceState('QBCore') == 'started' then
    QBCore = exports['QBCore']:GetCoreObject()
end

-- Check for ESX and set the core object
if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
end

-- Check for NDCore and set the core object
if GetResourceState('ND_Core') == 'started' then
    NDCore = exports['ND_Core']:GetCoreObject()
end

-- Function to get player data
function GetPlayerData(source, data)
    local playerData = nil
    local fw_id = nil  -- Variable to hold the framework ID

    -- Retrieve player data based on available core object
    if QBCore then
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            playerData = player[data] or nil
            fw_id = player.PlayerData.citizenid  -- Get QBCore ID
        end
    elseif ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            playerData = xPlayer[data] or nil
            fw_id = xPlayer.identifier  -- Get ESX ID
        end
    elseif NDCore then
        local player = NDCore.getPlayer(source)
        if player then
            playerData = player.getData(data) or nil
            fw_id = player.getData("id")  -- Get NDCore ID
        end
    end

    return playerData, fw_id  -- Return both player data and framework ID
end

-- Function to save weapons to the database
RegisterNetEvent('saveWeaponsToDB')
AddEventHandler('saveWeaponsToDB', function(weapons)
    local src = source
    local discordName = GetPlayerName(src)
    local jsonWeapons = json.encode(weapons)

    -- Get player ID
    local playerData, fw_id = GetPlayerData(src, 'identifier')  -- Assume 'identifier' is the key for player data

    print("Received weapons for saving:", discordName, jsonWeapons, "Framework ID:", fw_id)  -- Debug log

    local query = [[
        INSERT INTO player_weapons (fw_id, discord_name, weapons)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE discord_name = VALUES(discord_name), weapons = VALUES(weapons)
    ]]

    MySQL.Async.execute(query, { fw_id, discordName, jsonWeapons }, function(rowsChanged)
        print("Rows changed:", rowsChanged)  -- Debug log
        if rowsChanged > 0 then
            TriggerClientEvent('lib.notify', src, {
                title = "Weapons",
                description = "Your weapons have been saved!",
                type = 'success'
            })
        else
            TriggerClientEvent('lib.notify', src, {
                title = "Weapons",
                description = "Failed to save your weapons.",
                type = 'error'
            })
        end
    end)
end)

-- Function to retrieve weapons from the database
RegisterNetEvent('retrieveWeaponsFromDB')
AddEventHandler('retrieveWeaponsFromDB', function()
    local src = source
    local discordName = GetPlayerName(src)

    -- Get player ID
    local _, fw_id = GetPlayerData(src, 'identifier')  -- Get the framework ID

    local query = [[
        SELECT weapons FROM player_weapons WHERE fw_id = ?
    ]]

    MySQL.Async.fetchScalar(query, { fw_id }, function(weaponsJson)
        if weaponsJson then
            local weapons = json.decode(weaponsJson)
            if type(weapons) == "table" then
                TriggerClientEvent('sendWeaponsToClient', src, weapons)
            else
                print("Error: Retrieved weapons data is not a table")
            end
        else
            print("No weapons found for:", discordName)
        end
    end)
end)

-- Function to delete all weapons from the database for the player
RegisterNetEvent('deleteWeaponsFromDB')
AddEventHandler('deleteWeaponsFromDB', function()
    local src = source
    local discordName = GetPlayerName(src)

    -- Get player ID
    local _, fw_id = GetPlayerData(src, 'identifier')  -- Get the framework ID

    -- Prepare SQL query to delete weapons for the player
    local query = [[
        DELETE FROM player_weapons WHERE fw_id = ?
    ]]

    MySQL.Async.execute(query, { fw_id }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('lib.notify', src, {
                title = "Weapons",
                description = "Your weapons have been deleted.",
                type = 'success'
            })
        else
            TriggerClientEvent('lib.notify', src, {
                title = "Weapons",
                description = "No weapons found to delete.",
                type = 'error'
            })
        end
    end)
end)

-- Command to check player ID using NDCore only
RegisterCommand('checkID', function(source)
    -- Ensure NDCore is initialized
    if NDCore then
        local player = NDCore.getPlayer(source)  -- Get player object using NDCore
        if player then
            local playerId = player.getData("id")  -- Get the player's ID
            
            if playerId then
                TriggerClientEvent('lib.notify', source, {
                    title = "Player ID",
                    description = "Your Player ID is: " .. playerId,
                    type = 'success'
                })
            else
                TriggerClientEvent('lib.notify', source, {
                    title = "Error",
                    description = "Unable to retrieve your Player ID.",
                    type = 'error'
                })
            end
        else
            TriggerClientEvent('lib.notify', source, {
                title = "Error",
                description = "Player data not found.",
                type = 'error'
            })
        end
    else
        TriggerClientEvent('lib.notify', source, {
            title = "Error",
            description = "NDCore is not available.",
            type = 'error'
        })
    end
end, false)
