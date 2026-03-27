ESX = exports["es_extended"]:getSharedObject()

local function SendObvNotification(message, sender)
    TriggerClientEvent("mHud:announce", -1, message, sender or "Sistem", 6000)
end

local eventActive = false
local playersWithEventItems = {}

RegisterServerEvent('masked:event:rewards')
AddEventHandler('masked:event:rewards', function()
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source) 

    if xPlayer then
        xPlayer.addInventoryItem('weapon_specialcarbine', 1)
        xPlayer.addInventoryItem('pancir', 10)
        xPlayer.addInventoryItem('brzijoint', 10)
        xPlayer.addInventoryItem('ifak', 10)
        xPlayer.addInventoryItem('ammo-rifle', 350)
        
        playersWithEventItems[_source] = {
            identifier = xPlayer.identifier,
            name = GetPlayerName(_source) or "Unknown"
        }
    end
end)

RegisterCommand('zapocnievent', function(source, args, raw)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getGroup() == 'developer' then
        if eventActive then
            TriggerClientEvent('esx:showNotification', source, 'Event je vec aktiviran!')
            return
        end
        
        playersWithEventItems = {}
        
        eventActive = true
        TriggerClientEvent('masked:event:start', -1)
        
        local playerName = GetPlayerName(source) or "Administrator"
        SendObvNotification("MASKED EVENT JE ZAPOCET! Dodjite na Ranch da ucestvujete!", playerName)
        
        TriggerClientEvent('esx:showNotification', source, 'Upravo je zapoceo Masked Event na Rancu!')
    else
        TriggerClientEvent('esx:showNotification', source, 'Nemate permisiju za ovu komandu!')
    end
end, false)

local function RemoveEventItemsFromAllPlayers()
    for playerId, playerData in pairs(playersWithEventItems) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        
        if xPlayer then
            
            local itemsToRemove = {
                'weapon_specialcarbine',
                'pancir',
                'brzijoint',
                'ifak',
                'ammo-rifle'
            }
            
            for _, itemName in ipairs(itemsToRemove) do
                local item = xPlayer.getInventoryItem(itemName)
                if item and item.count > 0 then
                    xPlayer.removeInventoryItem(itemName, item.count)
                    
                    
                    TriggerClientEvent('esx:showNotification', playerId, 
                        'Uklonjeno ' .. item.count .. 'x ' .. item.label .. ' - Masked Event je zavrsen')
                end
            end
        else
            
            MySQL.Async.execute('DELETE FROM ox_inventory WHERE owner = @owner AND name IN (@item1, @item2, @item3, @item4, @item5)', {
                ['@owner'] = playerData.identifier,
                ['@item1'] = 'weapon_specialcarbine',
                ['@item2'] = 'pancir',
                ['@item3'] = 'brzijoint',
                ['@item4'] = 'ifak',
                ['@item5'] = 'ammo-rifle'
            })
        end
    end
    
    
    playersWithEventItems = {}
end

RegisterCommand('zavrsievent', function(source, args, raw)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getGroup() == 'developer' then
        if not eventActive then
            TriggerClientEvent('esx:showNotification', source, 'Nema aktivnog eventa!')
            return
        end
        
        eventActive = false
        
        
        RemoveEventItemsFromAllPlayers()
        
        
        TriggerClientEvent('masked:event:stop', -1)
        
        
        local playerName = GetPlayerName(source) or "Administrator"
        SendObvNotification("MASKED EVENT JE ZAVRSEN! Hvala svima koji su ucestvovali!", playerName)
        
        
        SendObvNotification("Svi predmeti dobijeni na Masked Eventu su uklonjeni!", "Sistem")
        
        TriggerClientEvent('esx:showNotification', source, 'Masked Event je zavrsen! Svi predmeti su uklonjeni.')
    else
        TriggerClientEvent('esx:showNotification', source, 'Nemate permisiju za ovu komandu!')
    end
end, false)


AddEventHandler('playerDropped', function(reason)
    local playerId = source
    playersWithEventItems[playerId] = nil
end)