local function SendToDiscord(embed)
    if not Config.Webhook.Enabled or Config.Webhook.URL == "WEBHOOK_URL" then return end
    PerformHttpRequest(Config.Webhook.URL, function(err, text, headers) end, 'POST', json.encode({username = Config.Webhook.BotName, avatar_url = Config.Webhook.BotAvatar, embeds = {embed}}), { ['Content-Type'] = 'application/json' })
end

RegisterCommand(Config.Command, function(source, args, raw)
    local job = Framework.GetPlayerJob(source)
    local requiredJob = Config.PoliceJobName[Config.Framework]
    if job == requiredJob then
        local dogToSpawn = Config.ActiveDogBreed
        if Config.DogModels[dogToSpawn] then
            TriggerClientEvent('ap_k9:client:toggleDog', source, dogToSpawn)
            local officerName = Framework.GetPlayerName(source) 
            local embed = {
                title = "Unit K9 Dikerahkan", color = 3447003,
                fields = { { name = "Nama Polisi", value = officerName, inline = true }, { name = "Jenis Anjing", value = Config.DogModels[dogToSpawn].name, inline = true } },
                footer = { text = "Waktu Pengerahan" }, timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
            }
            SendToDiscord(embed)
        else
            print(('[ap_k9] ERROR: Config.ActiveDogBreed ("%s") tidak valid!'):format(dogToSpawn))
        end
    else
        lib.notify(source, {title='K9 System', description='Anda bukan seorang polisi!', type='error'})
    end
end, false)

RegisterNetEvent('ap_k9:server:targetKilled', function(targetIsPlayer, targetIdentifier) 
    local source = source
    local officerName = Framework.GetPlayerName(source) 
    local targetName = "Warga Sipil (NPC)"
    
    if targetIsPlayer and targetIdentifier then
        local targetPlayer = nil
        if QBCore then targetPlayer = QBCore.Functions.GetPlayer(targetIdentifier) 
        elseif ESX then targetPlayer = ESX.GetPlayerFromIdentifier(targetIdentifier) end 
        
        if targetPlayer then
            targetName = Framework.GetPlayerName(targetPlayer.source)
        else
            targetName = "Pemain (Offline atau Tidak Ditemukan)"
        end
    end

    local embed = {
        title = "Target K9 Dilumpuhkan", color = 15158332,
        fields = { { name = "Nama Polisi", value = officerName, inline = true }, { name = "Nama Target", value = targetName, inline = true } },
        footer = { text = "Waktu Insiden" }, timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    SendToDiscord(embed)
end)
