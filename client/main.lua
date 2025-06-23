local QBCore, ESX = nil, nil
K9 = { active = false, ped = nil, vehicle = nil, targeting = false, currentTask = nil, attackTarget = nil }
ActiveTargetSystem = nil
local lastPlayerHealth = 200

CreateThread(function()
    Wait(1000)
    if GetResourceState('qb-core') == 'started' then QBCore = exports['qb-core']:GetCoreObject()
    elseif GetResourceState('es_extended') == 'started' then ESX = exports['es_extended']:getSharedObject() end

    if Config.TargetSystem == 'autodetect' then
        if GetResourceState('ox_target') == 'started' then ActiveTargetSystem = 'ox'
        elseif GetResourceState('qb-target') == 'started' then ActiveTargetSystem = 'qb'
        else ActiveTargetSystem = 'native' end
    else ActiveTargetSystem = Config.TargetSystem end
    print('ap_k9: Using target system -> ' .. ActiveTargetSystem)

    lastPlayerHealth = GetEntityHealth(PlayerPedId())
    K9Menu.Register()

    RegisterCommand('k9menu', function()
        local playerData
        if ESX then playerData = ESX.GetPlayerData() elseif QBCore then playerData = QBCore.Functions.GetPlayerData() end
        if playerData and playerData.job and string.lower(playerData.job.name) == string.lower(Config.PoliceJobName[Config.Framework]) then
            if K9.active then K9Menu.Open()
            else lib.notify({title = 'K9 System', description = Config.Locales.no_dog_out, type = 'inform'}) end
        end
    end, false)
    RegisterKeyMapping('k9menu', 'Open K9 Menu', 'keyboard', 'M')
end)

RegisterNetEvent('ap_k9:client:toggleDog', function(dogBreed)
    if K9.active then
        if K9.targeting then K9Commands.StopTargeting() end
        if DoesEntityExist(K9.ped) then DeleteEntity(K9.ped) end
        K9 = { active = false, ped = nil, vehicle = nil, targeting = false, currentTask = nil, attackTarget = nil }
        if dogBreed == 'dismiss' then
            lib.notify({title = 'K9', description = Config.Locales.dog_recalled, type = 'error'})
        end
    else
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local modelHash = GetHashKey(Config.DogModels[dogBreed].model)
        RequestModel(modelHash)
        local timer = 5000
        while not HasModelLoaded(modelHash) and timer > 0 do Wait(100); timer = timer - 100 end
        if HasModelLoaded(modelHash) then
            K9.ped = CreatePed(4, modelHash, coords.x + 1.0, coords.y, coords.z, 0.0, true, true)
            if DoesEntityExist(K9.ped) then
                K9.active = true
                K9.currentTask = 'follow'
                SetEntityAsMissionEntity(K9.ped, true, true)
                SetModelAsNoLongerNeeded(modelHash)
                lib.notify({title = 'K9', description = Config.Locales.dog_called:format(Config.DogModels[dogBreed].name), type = 'success'})
            end
        else
            SetModelAsNoLongerNeeded(modelHash)
            lib.notify({title = 'K9', description = Config.Locales.failed_to_load_model, type = 'error'})
        end
    end
end)

RegisterNetEvent('ap_k9:client:BiteTarget', function(data)
    local targetEntity
    if data.target then targetEntity = NetworkGetEntityFromNetworkId(data.target)
    elseif data.entity then targetEntity = data.entity end
    if targetEntity and DoesEntityExist(targetEntity) then K9Commands.Bite(targetEntity) end
end)

-- MAIN THREAD

CreateThread(function()
    while true do
        Wait(500)
        if K9.active and DoesEntityExist(K9.ped) then
            if K9.currentTask ~= 'attack' and K9.currentTask ~= 'attacking_initiated' and K9.currentTask ~= 'in_vehicle' then
                local playerPed = PlayerPedId()
                local currentPHealth = GetEntityHealth(playerPed)
                if currentPHealth < lastPlayerHealth then
                    local peds = GetGamePool('CPed')
                    local closestAttacker = nil
                    local closestDist = 20.0
                    for i = 1, #peds do
                        local ped = peds[i]
                        if ped ~= playerPed and ped ~= K9.ped and DoesEntityExist(ped) and not IsPedDeadOrDying(ped) then
                            local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(ped))
                            if dist < closestDist and IsPedInCombat(ped, playerPed) then
                                closestAttacker = ped; closestDist = dist
                            end
                        end
                    end
                    if closestAttacker then
                        lib.notify({title = 'K9', description = Config.Locales.protecting_owner, type = 'warning'})
                        K9Commands.Bite(closestAttacker)
                    end
                end
                lastPlayerHealth = currentPHealth
            end

            if K9.currentTask == 'attacking_initiated' then
                Wait(1000)
                if IsPedInCombat(K9.ped, -1) then K9.currentTask = 'attack'
                else K9Commands.FollowMe(); lib.notify({title = 'K9', description = Config.Locales.attack_failed, type = 'error'}) end
            elseif K9.currentTask == 'attack' then
                local target = K9.attackTarget
                if (not IsPedInCombat(K9.ped, -1)) or (not DoesEntityExist(target) or IsPedDeadOrDying(target, 1)) then
                     if DoesEntityExist(target) and IsPedDeadOrDying(target, 1) then
                        local targetIsPlayer = IsPedAPlayer(target)
                        local targetNetId = targetIsPlayer and NetworkGetNetworkIdFromEntity(target) or nil
                        TriggerServerEvent('ap_k9:server:targetKilled', targetIsPlayer, targetNetId)
                    end
                    ClearPedTasks(K9.ped); TaskStandStill(K9.ped, 3000)
                    K9.attackTarget = nil; K9.currentTask = 'follow'
                    lib.notify({title = 'K9', description = Config.Locales.attack_finished, type = 'inform'})
                end
            elseif K9.currentTask == 'follow' then
                local playerPed = PlayerPedId()
                if IsPedStill(K9.ped) and #(GetEntityCoords(K9.ped) - GetEntityCoords(playerPed)) > Config.Gameplay.FollowStartDistance then
                    TaskGoToEntity(K9.ped, playerPed, -1, Config.Gameplay.FollowStopDistance, Config.Gameplay.FollowSpeed, 1073741824, 0)
                end
            elseif K9.currentTask == 'in_vehicle' then
                local playerPed = PlayerPedId()
                if not IsPedInVehicle(playerPed, K9.vehicle, false) or not DoesEntityExist(K9.vehicle) then
                   if IsEntityAttachedToEntity(K9.ped, K9.vehicle) then DetachEntity(K9.ped, true, true) end
                   local coords = DoesEntityExist(K9.vehicle) and GetOffsetFromEntityInWorldCoords(K9.vehicle, 1.0, 2.0, 0.5) or GetEntityCoords(playerPed)
                   SetEntityCoords(K9.ped, coords.x, coords.y, coords.z, false, false, false, true)
                   K9.vehicle = nil; K9Commands.FollowMe()
                   lib.notify({title = 'K9', description = Config.Locales.dog_exiting_vehicle, type = 'inform'})
                end
            end

            if IsPedDeadOrDying(K9.ped, 1) then
                lib.notify({id = 'k9_dead', title = 'K9', description = Config.Locales.dog_died, type = 'error'})
                TriggerEvent('ap_k9:client:toggleDog', 'dead')
            elseif IsPlayerDead(PlayerId()) then
                lib.notify({id = 'player_dead', title = 'K9', description = Config.Locales.player_died, type = 'error'})
                TriggerEvent('ap_k9:client:toggleDog', 'dead')
            end
        end
    end
end)

-- THREAD  QB-TARGET
CreateThread(function()
    while true do
        Wait(500)
        if K9.targeting and ActiveTargetSystem == 'qb' then
            local playerPed = PlayerPedId()
            for _, player in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(player)
                if targetPed ~= playerPed and DoesEntityExist(targetPed) and targetPed ~= K9.ped then
                    exports['qb-target']:AddTargetEntity(targetPed, {
                        options = {{ type = "client", event = "ap_k9:client:BiteTarget", icon = "fas fa-hand-rock", label = 'Bite Target', target = NetworkGetNetworkIdFromEntity(targetPed) }},
                        distance = Config.Gameplay.TargetingDistance
                    })
                end
            end
            for _, npc in ipairs(GetGamePool('CPed')) do
                if not IsPedAPlayer(npc) and DoesEntityExist(npc) and npc ~= K9.ped and NetworkHasControlOfEntity(npc) then
                    exports['qb-target']:AddTargetEntity(npc, {
                        options = {{ type = "client", event = "ap_k9:client:BiteTarget", icon = "fas fa-hand-lizard", label = 'Bite Target', entity = npc }},
                        distance = Config.Gameplay.TargetingDistance
                    })
                end
            end
        else
            Wait(1500) -- Jika tidak aktif, tunggu lebih lama
        end
    end
end)

-- =================================================================

-- =================================================================
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if K9.active and DoesEntityExist(K9.ped) then
        print('[ap_k9] Cleaning up K9 dog on resource stop...')
        DeleteEntity(K9.ped)
    end
end)