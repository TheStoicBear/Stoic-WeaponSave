-- Function to get the weapon name from the configuration
function GetWeaponName(weaponHash)
    return Config.weaponNames[weaponHash] or "Unknown Weapon"
end

-- Notification function
function Notify(data)
    lib.notify({
        title = data.title or 'Notification',
        description = data.description or 'No description provided.',
        duration = Config.Notification.duration,
        position = Config.Notification.position,
        style = Config.Notification.style,
        icon = data.icon or 'info-circle',
        iconColor = Config.Notification.iconColor,
        type = data.type or 'inform'
    })
end

-- Function to delete all weapons from the player's ped
function DeleteAllWeapons()
    local playerPed = PlayerPedId()
    
    for _, hash in ipairs(Config.weaponHashes) do
        if HasPedGotWeapon(playerPed, hash, false) then
            RemoveWeaponFromPed(playerPed, hash)
            Notify({
                title = "Weapons",
                description = "Removed weapon: " .. GetWeaponName(hash),
                type = 'success'
            })
        end
    end

    -- Trigger server event to delete weapons from the database if necessary
    TriggerServerEvent('deleteWeaponsFromDB')
    Notify({
        title = "Weapons",
        description = "All weapons have been removed.",
        type = 'inform'
    })
end

-- Function to save the player's weapons to the database
function SaveWeapons()
    local player = PlayerPedId()
    local weapons = {}

    if not Config.weaponHashes or type(Config.weaponHashes) ~= "table" then
        Notify({
            title = "Error",
            description = "Weapon hashes configuration is missing.",
            type = 'error'
        })
        return
    end

    for _, hash in ipairs(Config.weaponHashes) do
        if HasPedGotWeapon(player, hash, false) then
            local weaponName = GetWeaponName(hash)
            table.insert(weapons, { name = weaponName, hash = hash })
        end
    end

    if #weapons > 0 then
        print("Sending weapons to server:", json.encode(weapons))  -- Debug log
        
        -- Retrieve the player ID using GetPlayerData before sending the data
        TriggerServerEvent('saveWeaponsToDB', weapons, GetPlayerData('id'))  -- Assume 'fw_id' is the data you want
        Notify({
            title = "Weapons",
            description = "Saving your weapons...",
            type = 'inform'
        })
    else
        Notify({
            title = "Weapons",
            description = "You have no weapons to save.",
            type = 'error'
        })
    end
end

-- Function to retrieve the player's weapons from the database
function RetrieveWeapons()
    TriggerServerEvent('retrieveWeaponsFromDB', GetPlayerData('fw_id'))  -- Sending fw_id to retrieve weapons
end

-- Function to delete a specific weapon from the player's ped
function DeleteWeaponFromPlayer(weaponHash)
    local playerPed = PlayerPedId()
    if HasPedGotWeapon(playerPed, weaponHash, false) then
        RemoveWeaponFromPed(playerPed, weaponHash)
        Notify({
            title = "Weapons",
            description = "Weapon has been removed.",
            type = 'success'
        })
    else
        Notify({
            title = "Weapons",
            description = "You do not have this weapon.",
            type = 'error'
        })
    end
end

-- -- Command to delete all weapons from the player's ped
-- RegisterCommand('deleteAllWeapons', function()
--     DeleteAllWeapons()
-- end, false)

-- Command to save the player's weapons to the database
RegisterCommand('saveWeapons', function()
    SaveWeapons()
end, false)

-- Command to retrieve the player's weapons from the database
RegisterCommand('retrieveWeapons', function()
    RetrieveWeapons()
end, false)

-- Event to receive notifications about saved weapons
RegisterNetEvent('lib.notify')
AddEventHandler('lib.notify', function(data)
    Notify(data)
end)

-- Event to give weapons to the player
RegisterNetEvent('sendWeaponsToClient')
AddEventHandler('sendWeaponsToClient', function(weapons)
    local player = PlayerPedId()
    for _, weapon in ipairs(weapons) do
        GiveWeaponToPed(player, weapon.hash, 100, false, true)
        Notify({
            title = "Weapons",
            description = "Received weapon: " .. weapon.name,
            type = 'success'
        })
    end
end)

-- Event to handle weapon deletion request from the server
RegisterNetEvent('deleteWeaponFromPlayer')
AddEventHandler('deleteWeaponFromPlayer', function(weaponHash)
    DeleteWeaponFromPlayer(weaponHash)
end)

-- Export the functions
exports('deleteAllWeapons', DeleteAllWeapons)
exports('saveWeapons', SaveWeapons)
exports('retrieveWeapons', RetrieveWeapons)
exports('deleteWeaponFromPlayer', DeleteWeaponFromPlayer)

-- Function to get player data using server callback
function GetPlayerData(data)
    local playerId = PlayerId() -- Get the local player ID
    local playerData = nil

    -- Trigger server event to get player data
    TriggerServerEvent('getPlayerData', data, playerId)
end
