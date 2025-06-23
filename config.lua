Config = {}

-- FRAMEWORK & TARGET SETTINGS
Config.Framework = 'autodetect' -- 'esx', 'qb', atau 'autodetect'
Config.TargetSystem = 'autodetect' -- 'ox', 'qb', atau 'autodetect'

-- JOB & COMMAND SETTINGS
Config.PoliceJobName = { esx = 'police', qb = 'police' }
Config.Command = 'k9'
Config.ActiveDogBreed = 'retriever' -- choose: 'husky', 'shepherd', 'retriever', 'rottweiler'

-- GAMEPLAY SETTINGS
Config.Gameplay = {
TargetingDistance = 35.0,
FollowStartDistance = 4.0,
FollowStopDistance = 2.5,
FollowSpeed = 7.0,
SitDuration = 15000,
}

-- DISCORD WEBHOOK SETTINGS
Config.Webhook = {
    Enabled = true,
    URL = "https://discord.com/api/webhooks/1386513616156622858/wJvq9zR_LCI6ydqXNtZX1CHfpNqKJyj-CwrY8qSEwXOTIJ6-sCdV7GnuY8eKoJCUGxu_", 
    BotName = "K9 Dispatch",
    BotAvatar = "https://i.imgur.com/pBq5O1L.png"
}

Config.Permissions = {
    Enabled = true, -- Set to false to disable permission system (who can use it)
    Method = 'grade', -- Choose method: 'grade' (based on rank) or 'ace' (based on FiveM permissions)

    -- Settings if Method = 'grade'
    RequiredGrade = 3, -- Minimum rank required (number). ESX: 0=recruit. QBCore: 0=boss. Adjust accordingly!

    -- Settings if Method = 'ace'
    AcePermission = 'ap_k9.use' -- Name of the ACE permission required
}


Config.Locales = {
    -- General Notifications
    not_a_cop = 'You are not a police officer!',
    must_wait = 'You must wait %s more seconds.',
    no_dog_out = 'Use /k9 to summon your dog.',
    not_in_vehicle = 'You are not inside a vehicle.',
    failed_to_load_model = 'Failed to load dog model.',
    
    -- Dog Notifications
    dog_recalled = 'The dog has been recalled.',
    dog_called = 'Dog %s has been summoned.',
    dog_died = 'Your dog has died.',
    player_died = 'You are unconscious, your dog has been recalled.',
    dog_is_sitting = 'Sitting down for a moment.',
    dog_cannot_sit = 'The dog cannot sit.',
    dog_following = 'Back to following!',
    dog_entering_vehicle = 'Dog is entering the vehicle.',
    dog_exiting_vehicle = 'Dog is exiting the vehicle.',
    
    -- Attack Mode
    attack_mode_on = 'Attack Mode Enabled. Aim and click to attack.',
    attack_mode_off = 'Attack Mode Disabled.',
    attacking_target = 'Attacking the target!',
    attack_failed = 'Failed to initiate attack.',
    attack_finished = 'Fight is over, back to following.',
    protecting_owner = 'Dog is protecting you and attacking the aggressor!'
}

-- DO NOT MODIFY BELOW UNLESS YOU KNOW WHAT YOU’RE DOING
Config.DogModels = {
    ['husky'] = { model = 'a_c_husky', name = 'Husky' },
    ['shepherd'] = { model = 'a_c_shepherd', name = 'German Shepherd' },
    ['retriever'] = { model = 'a_c_retriever', name = 'Retriever' },
    ['rottweiler'] = { model = 'a_c_rottweiler', name = 'Rottweiler' },
}

