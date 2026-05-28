fx_version 'cerulean'
game 'gta5'

author 'Lunix'
description 'Elevators Builder'
version '1.0.0'
lua54 'yes'


-- Dépendances requises
dependency 'qbx_core'
dependency 'ox_lib'
dependency 'oxmysql'
-- ox_target est optionnel: activez si vous l'utilisez
-- dependency 'ox_target'


ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}