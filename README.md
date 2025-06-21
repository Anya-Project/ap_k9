# 🐕‍🦺 K9 Police Dog System for QBCore & ESX  
**integrated with ox_lib Menu | Discord Logging**

**K9 police dog system** built for both **QBCore** and **ESX** frameworks. Designed with realism and roleplay depth in mind, this script replaces manual commands with a smooth **ox_lib-based interaction menu**.

---

## 🚨 Features

- 🎛️ **Interactive ox_lib Menu**
  - Call / Dismiss your dog
  - Make it follow or sit
  - Command to attack specific NPCs or players
  - Enter / exit vehicles with you
  - All without using any slash commands

- 🧠 **Smart Behavior & Reactions**
  - Dog dies if shot, run over, or beaten
  - If attacked by its own handler, the dog auto-retaliates

- 🐶 **Dog Breed Options**
  - 🐺 Husky  
  - 🦴 Retriever *(default)*  
  - 🐕 German Shepherd  
  - 🐾 Rottweiler

- 🔁 **Framework Auto Detection**
  - Automatically detects QBCore or ESX
  - Works out-of-the-box for both

- 📡 **Discord Logging (Optional)**
  - Logs every K9 summon, attack, and kill
  - Easily enabled/disabled in `config.lua`
 
## ⚙️ Requirements

- **[qb-core](https://github.com/qbcore-framework/qb-core)**
- **[qb-target](https://github.com/qbcore-framework/qb-target)** 
- **[ox_lib](https://github.com/overextended/ox_lib)** 

---

## ⚙️ Configuration Highlights

```lua
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
    URL = "URL_WEBHOOK",
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
```

