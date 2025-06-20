K9Commands = {}

function K9Commands.FollowMe()
    if not K9.active or not DoesEntityExist(K9.ped) then return end
    K9.currentTask = 'follow'
    lib.notify({title = 'K9', description = 'Kembali mengikuti!', type = 'inform'})
    ClearPedTasksImmediately(K9.ped)
end

function K9Commands.Sit()
    if not K9.active or not DoesEntityExist(K9.ped) then return end
    lib.notify({title = 'K9', description = 'Duduk sejenak.', type = 'inform'})
    local animDict = "creatures@rottweiler@amb@world_dog_sitting@base"
    RequestAnimDict(animDict)
    CreateThread(function()
        local timer = 2000
        while not HasAnimDictLoaded(animDict) and timer > 0 do Wait(100); timer = timer - 100 end
        if HasAnimDictLoaded(animDict) then
            TaskPlayAnim(K9.ped, animDict, "base", 8.0, -8.0, Config.Gameplay.SitDuration, 1, 0, false, false, false)
        else
        lib.notify({title = 'K9', description = 'Anjing gak bisa duduk.', type = 'error'})
            return
        end
    end)
end

function K9Commands.EnterVehicle()
    if not K9.active or not DoesEntityExist(K9.ped) then return end
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if DoesEntityExist(vehicle) then
        if IsEntityAttachedToEntity(K9.ped, vehicle) then
            DetachEntity(K9.ped, true, true)
            local pos = GetOffsetFromEntityInWorldCoords(vehicle, 1.0, 2.0, 0.5)
            SetEntityCoords(K9.ped, pos.x, pos.y, pos.z, false, false, false, true)
            lib.notify({title = 'K9', description = 'Anjing keluar dari kendaraan.', type = 'inform'})
            Wait(500)
            K9Commands.FollowMe()
            return
        end
        K9.currentTask = 'in_vehicle'
        K9.vehicle = vehicle
        ClearPedTasksImmediately(K9.ped)
        SetEntityVisible(K9.ped, false, false)
        AttachEntityToEntity(K9.ped, vehicle, GetEntityBoneIndexByName(vehicle, "seat_pside_f"), 0.0, -0.2, 0.45, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        SetEntityVisible(K9.ped, true, false)
        lib.notify({title = 'K9', description = 'Anjing masuk ke kendaraan.', type = 'inform'})
        CreateThread(function()
            Wait(500)
            if DoesEntityExist(K9.ped) and IsEntityAttachedToEntity(K9.ped, vehicle) then
                local animDict = "creatures@rottweiler@amb@world_dog_sitting@base"
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do Wait(50) end
                TaskPlayAnim(K9.ped, animDict, "base", 8.0, -8.0, -1, 1, 0, false, false, false)
            end
        end)
    else
        lib.notify({title = 'K9', description = 'Anda tidak berada di dalam kendaraan.', type = 'error'})
    end
end

function K9Commands.StartTargeting()
    K9.targeting = true
    lib.notify({ title = 'K9', description = 'Mode Serang Aktif', type = 'inform'})
end

function K9Commands.StopTargeting()
    K9.targeting = false
    lib.notify({ title = 'K9', description = 'Mode Serang Nonaktif.', type = 'error' })
    if ActiveTargetSystem == 'ox' then
        exports.ox_target:removePlayer({'ap_k9_attack_player'})
        exports.ox_target:removeNpc({'ap_k9_attack_npc'})
    end
end

function K9Commands.ToggleTargeting()
    if K9.targeting then K9Commands.StopTargeting() else K9Commands.StartTargeting() end
end

function K9Commands.Bite(targetEntity)
    if targetEntity == K9.ped then return end
    if not K9.active or not DoesEntityExist(K9.ped) or not DoesEntityExist(targetEntity) or IsPedDeadOrDying(targetEntity) then return end
    K9.currentTask = 'attacking_initiated'
    K9.attackTarget = targetEntity
    lib.notify({title = 'K9', description = 'Menyerang target!', type = 'success'})
    SetEntityAsMissionEntity(K9.ped, true, true)
    ClearPedTasksImmediately(K9.ped)
    SetBlockingOfNonTemporaryEvents(K9.ped, false)
    local dogGroupHash = GetPedRelationshipGroupHash(K9.ped)
    local targetGroupHash = GetPedRelationshipGroupHash(targetEntity)
    SetRelationshipBetweenGroups(5, dogGroupHash, targetGroupHash)
    SetRelationshipBetweenGroups(5, targetGroupHash, dogGroupHash)
    SetPedCombatAttributes(K9.ped, 46, true)
    SetPedCombatAttributes(K9.ped, 5, true)
    SetPedAlertness(K9.ped, 3)
    TaskPutPedDirectlyIntoMelee(K9.ped, targetEntity, -1.0, -1.0, 0, false)
    if K9.targeting then K9Commands.ToggleTargeting() end
end