K9Menu = {}

function K9Menu.Register()
    lib.registerMenu({
        id = 'ap_k9_main_menu',
        title = 'Menu Kontrol K9',
        position = 'top-right',
        options = {
            { label = 'Mode Serang', description = 'Aktifkan mode untuk memilih target serangan.', icon = 'fas fa-skull-crossbones', args = { action = 'attack' } },
            { label = 'Ikuti Aku', description = 'Perintahkan anjing untuk kembali mengikutimu.', icon = 'fas fa-walking', args = { action = 'follow' } },
            { label = 'Duduk', description = 'Perintahkan anjing untuk duduk diam sejenak.', icon = 'fas fa-chair', args = { action = 'sit' } },
            { label = 'Masuk/Keluar Kendaraan', description = 'Perintahkan anjing untuk masuk atau keluar dari kendaraanmu.', icon = 'fas fa-car', disabled = function() return not IsPedInAnyVehicle(PlayerPedId(), false) end, args = { action = 'enter_vehicle' } },
            { label = 'Pulangkan Anjing', description = 'Kirim anjing ke markas.', icon = 'fas fa-times-circle', args = { action = 'dismiss' } }
        }
    }, function(selected, scrollIndex, args)
        if not selected then return end
        local action = args.action
        if action == 'attack' then K9Commands.ToggleTargeting()
        elseif action == 'follow' then K9Commands.FollowMe()
        elseif action == 'sit' then K9Commands.Sit()
        elseif action == 'enter_vehicle' then K9Commands.EnterVehicle()
        elseif action == 'dismiss' then TriggerEvent('ap_k9:client:toggleDog', 'dismiss') end
    end)
    print('ap_k9: Menu K9 berhasil didaftarkan ke ox_lib.')
end

function K9Menu.Open()
    if not K9.active then return end
    lib.showMenu('ap_k9_main_menu')
end