K9Menu = {}

function K9Menu.Register()
    lib.registerMenu({
        id = 'ap_k9_main_menu',
        title = 'K9 Control Menu',
        position = 'top-right',
        options = {
            {
                label = 'Attack Mode',
                description = 'Enable or disable targeting mode for selecting an attack target.',
                icon = 'fas fa-skull-crossbones',
                args = { action = 'attack' }
            },
            {
                label = 'Follow Me',
                description = 'Command the dog to follow you again.',
                icon = 'fas fa-walking',
                args = { action = 'follow' }
            },
            {
                label = 'Sit',
                description = 'Command the dog to sit and stay in place.',
                icon = 'fas fa-chair',
                args = { action = 'sit' }
            },
            {
                label = 'Enter/Exit Vehicle',
                description = 'Command the dog to enter or exit the vehicle.',
                icon = 'fas fa-car',
                disabled = function() return not IsPedInAnyVehicle(PlayerPedId(), false) end,
                args = { action = 'enter_vehicle' }
            },
            {
                label = 'Dismiss Dog',
                description = 'Send the dog back to its base or home position.',
                icon = 'fas fa-times-circle',
                args = { action = 'dismiss' }
            }
        }
    }, function(selected, scrollIndex, args)
        if not selected then return end
        lib.hideMenu()
        local action = args.action
        if action == 'attack' then
            CreateThread(function() Wait(100); K9Commands.ToggleTargeting() end)
        elseif action == 'follow' then
            K9Commands.FollowMe()
        elseif action == 'sit' then
            K9Commands.Sit()
        elseif action == 'enter_vehicle' then
            K9Commands.EnterVehicle()
        elseif action == 'dismiss' then
            TriggerEvent('ap_k9:client:toggleDog', 'dismiss')
        end
    end)
    print('ap_k9: Main K9 menu successfully registered.')
end

function K9Menu.Open()
    if not K9.active then return end
    lib.showMenu('ap_k9_main_menu')
end