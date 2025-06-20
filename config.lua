------------------------------------------
------------------------------------------
-- MASIH DALAM TAHAP PENGEMBANGAN
-- TERDETEKSI BUG MASIH ADA
-- DISARANKAN UNTUK TIDAK MENGGUNAKAN DI SERVER AKTIF (TUNGGU UPDATE SELANJUTNYA)
-- LATEST UPDATE: 06/21/2025 
------------------------------------------
------------------------------------------


Config = {}

-- FRAMEWORK SETTINGS
Config.Framework = 'autodetect' -- 'esx', 'qb', atau 'autodetect'

Config.TargetSystem = 'autodetect' -- 'esx', 'qb', atau 'autodetect'

-- JOB SETTINGS
Config.PoliceJobName = { esx = 'police', qb = 'police' }
Config.Command = 'k9'
Config.ActiveDogBreed = 'retriever' -- 'husky', 'shepherd', 'retriever', 'rottweiller'

-- GAMEPLAY SETTINGS
Config.Gameplay = {
    -- Jarak Target
    TargetingDistance = 35.0,

    -- Kalo jarak lebih kecil dari ini, anjing akan diam.
    FollowStartDistance = 4.0,
    -- Jarak dalam meter di mana anjing akan berhenti saat mengikuti pemain.
    FollowStopDistance = 2.5,
    -- Kecepatan lari anjing saat mengikuti pemain (1.0 - 10.0)
    FollowSpeed = 7.0,
    -- Durasi dalam milidetik (ms) anjing akan duduk sebelum otomatis berdiri.
    SitDuration = 15000, -- 15 detik
}

-- DISCORD WEBHOOK SETTINGS
Config.Webhook = {
    Enabled = true, -- Set true untuk hidupkan webhook, false untuk mematikannya.
    URL = "https://discord.com/api/webhooks/1385627178791731271/wYaTp-QQtFc5FPLTMM76N2kWXXd3DpyWI1oSNegrLzlVDJuw6xR0DthZBav4E8Yv8dsF",
    BotName = "K9 Dispatch",
    BotAvatar = "https://i.imgur.com/pBq5O1L.png"
}


-- JANGAN DIRUBAH DIBAWAH INI JIKA TIDAK PASTI
Config.DogModels = {
    ['husky'] = { model = 'a_c_husky', name = 'Husky' },
    ['shepherd'] = { model = 'a_c_shepherd', name = 'German Shepherd' },
    ['retriever'] = { model = 'a_c_retriever', name = 'Retriever' },
    ['rottweiler'] = { model = 'a_c_rottweiler', name = 'Rottweiler' },
}



