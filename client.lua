ESX = exports["es_extended"]:getSharedObject()

local event_masked = {
    {1456.3047, 1128.3083, 114.3341},
    {1457.4746, 1182.2358, 114.0935}
}

local pedovi = {
    {1457.7146, 1174.2262, 113.3343,"Obozavam",179,0x8D8F1B10,"s_m_y_swat_01"},
    {1456.5336, 1122.6501, 113.3343,"Obozavam",2.71,0x8D8F1B10,"s_m_y_swat_01"}
}

local spawnedPeds = {}
local markersActive = false
local qtargetAdded = false

local function SpawnPedovi()
    for _, v in pairs(pedovi) do
        local modelHash = GetHashKey(v[7])
        
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(1)
        end
        
        local ped = CreatePed(4, v[6], v[1], v[2], v[3], 3374176, false, true)
        SetEntityHeading(ped, v[5])
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        table.insert(spawnedPeds, ped)
    end
end

local function DeletePedovi()
    for _, ped in ipairs(spawnedPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    spawnedPeds = {}
end

local function AddQTarget()
    if qtargetAdded then return end
    
    exports['qtarget']:AddTargetModel({'s_m_y_swat_01'}, {
        options = {
            {
                event = "masked:event",
                icon = "fa-solid fa-person-rifle",
                label = "Masked Event",
            },
        },
        distance = 1.5
    })
    
    qtargetAdded = true
end

local function RemoveQTarget()
    if not qtargetAdded then return end
    
    exports['qtarget']:RemoveTargetModel({'s_m_y_swat_01'}, {
        "Masked Event"
    })
    
    qtargetAdded = false
end

Citizen.CreateThread(function()
    while true do
        if markersActive then
            for _, mark in pairs(event_masked) do
                local x, y, z = table.unpack(mark)
                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), x, y, z, true)
                
                if distance <= 20.0 then
                    DrawMarker(1, x, y, z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 0.4, 0, 255, 150, 100, false, false, false, true, false, false, false)
                end
            end
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('masked:event:start')
AddEventHandler('masked:event:start', function()
    markersActive = true
    SpawnPedovi()
    AddQTarget()
    ESX.ShowNotification('Masked Event je pokrenut!')
end)

RegisterNetEvent('masked:event:stop')
AddEventHandler('masked:event:stop', function()
    markersActive = false
    DeletePedovi()
    RemoveQTarget()
    ESX.ShowNotification('Masked Event je zavrsen!')
end)

AddEventHandler("masked:event", function()
    if not markersActive then return end 
    
    local playerPed = PlayerPedId()
    local armour = GetPedArmour(playerPed)
    SetPedArmour(playerPed, armour + 100)
    TriggerServerEvent('masked:event:rewards')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DeletePedovi()
        RemoveQTarget()
    end
end)