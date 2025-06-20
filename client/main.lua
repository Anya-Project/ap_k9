local QBCore, ESX = nil, nil
K9 = { active = false, ped = nil, vehicle = nil, targeting = false, currentTask = nil, attackTarget = nil }
ActiveTargetSystem = nil

CreateThread(function()
    if GetResourceState('qb-core') == 'started' then QBCore = exports['qb-core']:GetCoreObject()
    elseif GetResourceState('es_extended') == 'started' then ESX = exports['es_extended']:getSharedObject() end

    if Config.TargetSystem == 'autodetect' then
        if GetResourceState('ox_target') == 'started' then ActiveTargetSystem = 'ox'
        elseif GetResourceState('qb-target') == 'started' then ActiveTargetSystem = 'qb'
        else ActiveTargetSystem = 'native' end
    else
        ActiveTargetSystem = Config.TargetSystem
    end
    print('ap_k9: Menggunakan sistem target -> ' .. ActiveTargetSystem)
    K9Menu.Register()
end)

RegisterNetEvent('ap_k9:client:toggleDog', function(dogBreed)
    if K9.active then
        if K9.targeting then K9Commands.StopTargeting() end
        if DoesEntityExist(K9.ped) then DeleteEntity(K9.ped) end
        K9 = { active = false, ped = nil, vehicle = nil, targeting = false, currentTask = nil, attackTarget = nil }
        lib.notify({title = 'K9', description = 'Anjing telah dipulangkan.', type = 'error'})
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
                lib.notify({title = 'K9', description = 'Anjing '..Config.DogModels[dogBreed].name..' telah dipanggil.', type = 'success'})
            end
        else
            SetModelAsNoLongerNeeded(modelHash)
            lib.notify({title = 'K9', description = 'Gagal memuat model anjing.', type = 'error'})
        end
    end
end)

RegisterNetEvent('ap_k9:client:BiteTarget', function(data)
    local targetEntity
    if data.target then targetEntity = NetworkGetEntityFromNetworkId(data.target)
    elseif data.entity then targetEntity = data.entity end
    if targetEntity and DoesEntityExist(targetEntity) then K9Commands.Bite(targetEntity) end
end)

RegisterCommand('k9menu', function()
    local playerData
    if ESX then playerData = ESX.GetPlayerData()
    elseif QBCore then playerData = QBCore.Functions.GetPlayerData() end
    if playerData and playerData.job.name == Config.PoliceJobName[Config.Framework] then
        if K9.active then K9Menu.Open()
        else lib.notify({title = 'K9 System', description = 'Gunakan /k9 untuk memanggil anjing Anda.', type = 'inform'}) end
    end
end, false)
RegisterKeyMapping('k9menu', 'Buka Menu K9', 'keyboard', 'M')

CreateThread(function() -- Thread Utama
    while true do
        Wait(1500)
        if K9.active and DoesEntityExist(K9.ped) then
            if K9.currentTask == 'attacking_initiated' then
                Wait(2000)
                if IsPedInCombat(K9.ped, -1) then K9.currentTask = 'attack'
                else K9Commands.FollowMe(); lib.notify({title = 'K9', description = 'Gagal memulai serangan.', type = 'error'}) end
           elseif K9.currentTask == 'attack' then
                local target = K9.attackTarget
                
                local isNotInCombat = not IsPedInCombat(K9.ped, -1)
                local isTargetInvalid = not DoesEntityExist(target) or IsPedDeadOrDying(target, 1)

                if isNotInCombat or isTargetInvalid then
                     if DoesEntityExist(target) and IsPedDeadOrDying(target, 1) then
                        local targetIsPlayer = IsPedAPlayer(target)
                        local targetIdentifier = nil
                        if targetIsPlayer then
                            targetIdentifier = GetPlayerServerId(NetworkGetPlayerIndexFromPed(target))
                        end
                        TriggerServerEvent('ap_k9:server:targetKilled', targetIsPlayer, targetIdentifier)
                    end
                    ClearPedTasks(K9.ped)
                    TaskStandStill(K9.ped, 3000)
                    K9.attackTarget = nil
                    K9.currentTask = 'follow'
                    lib.notify({title = 'K9', description = 'Pertarungan selesai, kembali mengikuti.', type = 'inform'})
                end
            elseif K9.currentTask == 'follow' then
                if IsPedStill(K9.ped) then
                    local playerPed = PlayerPedId()
                    if #(GetEntityCoords(K9.ped) - GetEntityCoords(playerPed)) > Config.Gameplay.FollowStartDistance then
                        TaskGoToEntity(K9.ped, playerPed, -1, Config.Gameplay.FollowStopDistance, Config.Gameplay.FollowSpeed, 1073741824, 0)
                    end
                end
            elseif K9.currentTask == 'in_vehicle' then
                local playerPed = PlayerPedId()
                if not IsPedInVehicle(playerPed, K9.vehicle, false) or not DoesEntityExist(K9.vehicle) then
                    if IsEntityAttachedToEntity(K9.ped, K9.vehicle) then
                        DetachEntity(K9.ped, true, true)
                        local coords = DoesEntityExist(K9.vehicle) and GetOffsetFromEntityInWorldCoords(K9.vehicle, 1.0, 2.0, 0.5) or GetEntityCoords(playerPed)
                        SetEntityCoords(K9.ped, coords.x, coords.y, coords.z, false, false, false, true)
                    end
                    K9.vehicle = nil
                    K9Commands.FollowMe()
                    lib.notify({title = 'K9', description = 'Anjing keluar dari kendaraan.', type = 'inform'})
                end
            end
            if IsPedDeadOrDying(K9.ped, 1) then
                TriggerEvent('ap_k9:client:toggleDog', 'dead'); lib.notify({id = 'k9_dead', title = 'K9', description = 'Anjing Anda telah mati.', type = 'error'})
            elseif IsPlayerDead(PlayerId()) then
                TriggerEvent('ap_k9:client:toggleDog', 'dead'); lib.notify({id = 'player_dead', title = 'K9', description = 'Anda pingsan, anjing Anda dipulangkan.', type = 'error'})
            end
        end
    end
end)

CreateThread(function() -- Targeting System
    while true do
        Wait(250)
        if K9.targeting then
            local canInteract = function(entity) return entity ~= K9.ped end
            if ActiveTargetSystem == 'ox' then
                exports.ox_target:addPlayer({ name = 'ap_k9_attack_player', icon = 'fas fa-hand-rock', label = 'Perintahkan anjing untuk Menyerang', distance = Config.Gameplay.TargetingDistance, onSelect = function(data) K9Commands.Bite(data.entity) end, canInteract = canInteract })
                exports.ox_target:addNpc({ name = 'ap_k9_attack_npc', icon = 'fas fa-hand-lizard', label = 'Perintahkan anjing untuk Menyerang NPC', distance = Config.Gameplay.TargetingDistance, onSelect = function(data) K9Commands.Bite(data.entity) end, canInteract = canInteract })
            elseif ActiveTargetSystem == 'qb' then
                local playerPed = PlayerPedId()
                for _, player in ipairs(GetActivePlayers()) do
                    local targetPed = GetPlayerPed(player)
                    if targetPed ~= playerPed and DoesEntityExist(targetPed) and targetPed ~= K9.ped then
                        exports['qb-target']:AddTargetEntity(targetPed, { options = {{ type = "client", event = "ap_k9:client:BiteTarget", icon = "fas fa-hand-rock", label = 'Perintahkan Serang', target = NetworkGetNetworkIdFromEntity(targetPed) }}, distance = Config.Gameplay.TargetingDistance })
                    end
                end
                for _, npc in ipairs(GetGamePool('CPed')) do
                    if not IsPedAPlayer(npc) and DoesEntityExist(npc) and npc ~= K9.ped and NetworkHasControlOfEntity(npc) then
                        exports['qb-target']:AddTargetEntity(npc, { options = {{ type = "client", event = "ap_k9:client:BiteTarget", icon = "fas fa-hand-lizard", label = 'Perintahkan Serang', entity = npc }}, distance = Config.Gameplay.TargetingDistance })
                    end
                end
            end
        end
    end
end)


