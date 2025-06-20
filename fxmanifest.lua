fx_version 'cerulean'
game 'gta5'
author 'AProject'
description 'Police Dog Script for QBCore'
version '1.0.0'

lua54 'yes'

shared_script '@ox_lib/init.lua'

shared_scripts {
    'config.lua',
    'bridge/server_bridge.lua'
}

client_scripts {
    '@ox_target/init.lua',
    '@qb-target/client/main.lua',
    'client/commands.lua',
    'client/menu.lua',    
    'client/main.lua'      
}

server_script 'server/main.lua'