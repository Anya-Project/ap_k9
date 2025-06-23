K9Commands = {}

function K9Commands.FollowMe()
    if not K9.active or not DoesEntityExist(K9.ped) or K9.currentTask == 'entering_vehicle' then return end
    if K9.targeting then K9Commands.StopTargeting() end
    K9.currentTask = 'follow'
    lib.notify({title = 'K9', description = Config.Locales.dog_following, type = 'inform'})
    ClearPedTasksImmediately(K9.ped)
end

function K9Commands.Sit()
    if not K9.active or not DoesEntityExist(K9.ped) or K9.currentTask == 'entering_vehicle' then return end
    if K9.targeting then K9Commands.StopTargeting() end
    lib.notify({title = 'K9', description = Config.Locales.dog_is_sitting, type = 'inform'})
    local animDict = "creatures@rottweiler@amb@world_dog_sitting@base"
    RequestAnimDict(animDict)
    CreateThread(function()
        local timer = 2000
        while not HasAnimDictLoaded(animDict) and timer > 0 do Wait(100); timer = timer - 100 end
        if HasAnimDictLoaded(animDict) then
            TaskPlayAnim(K9.ped, animDict, "base", 8.0, -8.0, Config.Gameplay.SitDuration, 1, 0, false, false, false)
        else
            lib.notify({title = 'K9', description = Config.Locales.dog_cannot_sit, type = 'error'})
        end
    end)
end

function K9Commands.EnterVehicle()
    if not K9.active or not DoesEntityExist(K9.ped) or K9.currentTask == 'entering_vehicle' then return end
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not DoesEntityExist(vehicle) then
        lib.notify({title = 'K9', description = Config.Locales.not_in_vehicle, type = 'error'})
        return
    end

    if IsEntityAttachedToEntity(K9.ped, vehicle) then
        DetachEntity(K9.ped, true, true)
        local pos = GetOffsetFromEntityInWorldCoords(vehicle, 1.0, 2.0, 0.5)
        SetEntityCoords(K9.ped, pos.x, pos.y, pos.z, false, false, false, true)
        K9.vehicle = nil
        Wait(500)
        K9Commands.FollowMe()
        lib.notify({title = 'K9', description = Config.Locales.dog_exiting_vehicle, type = 'inform'})
        return
    end
    
    K9.currentTask = 'entering_vehicle'
    lib.notify({title = 'K9', description = Config.Locales.dog_entering_vehicle, type = 'inform'})
    
    CreateThread(function()
        local doorIndex = 1 
        SetVehicleDoorOpen(vehicle, doorIndex, false, false)
        Wait(500)
        local doorCoords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_pside_f"))
        TaskGoStraightToCoord(K9.ped, doorCoords.x, doorCoords.y, doorCoords.z, 2.0, -1, 0.0, 0.0)
        local timer = 5000
        while #(GetEntityCoords(K9.ped) - doorCoords) > 1.8 and timer > 0 do
            Wait(100); timer = timer - 100
        end
        SetEntityVisible(K9.ped, false, false)
        AttachEntityToEntity(K9.ped, vehicle, GetEntityBoneIndexByName(vehicle, "seat_pside_f"), 0.0, -0.2, 0.45, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        SetEntityVisible(K9.ped, true, false)
        K9.vehicle = vehicle
        local animDict = "creatures@rottweiler@amb@world_dog_sitting@base"
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do Wait(50) end
        TaskPlayAnim(K9.ped, animDict, "base", 8.0, -8.0, -1, 1, 0, false, false, false)
        Wait(1000)
        SetVehicleDoorShut(vehicle, doorIndex, false)
        K9.currentTask = 'in_vehicle'
    end)
end

function K9Commands.StartTargeting()
    if K9.targeting or K9.currentTask == 'entering_vehicle' then return end
    K9.targeting = true
    lib.notify({ title = 'K9', description = Config.Locales.attack_mode_on, type = 'inform'})
    if ActiveTargetSystem == 'ox' then
        exports.ox_target:addGlobalPed({
            name = 'ap_k9_attack', icon = 'fas fa-skull-crossbones', label = 'Perintahkan Serang',
            distance = Config.Gameplay.TargetingDistance,
            onSelect = function(data) if data.entity then K9Commands.Bite(data.entity) end end,
            canInteract = function(entity) return entity ~= K9.ped and entity ~= PlayerPedId() end
        })
    end
end

function K9Commands.StopTargeting()
    if not K9.targeting then return end
    K9.targeting = false
    lib.notify({ title = 'K9', description = Config.Locales.attack_mode_off, type = 'error' })
    if ActiveTargetSystem == 'ox' then exports.ox_target:removeGlobalPed('ap_k9_attack') end
end

function K9Commands.ToggleTargeting()
    if K9.targeting then K9Commands.StopTargeting() else K9Commands.StartTargeting() end
end

function K9Commands.Bite(targetEntity)
    if targetEntity == K9.ped or targetEntity == PlayerPedId() then return end
    if not K9.active or not DoesEntityExist(K9.ped) or not DoesEntityExist(targetEntity) or IsPedDeadOrDying(targetEntity) then return end
    K9.currentTask = 'attacking_initiated'
    K9.attackTarget = targetEntity
    lib.notify({title = 'K9', description = Config.Locales.attacking_target, type = 'success'})
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
    TaskCombatPed(K9.ped, targetEntity, 0, 16)
end