fx_version "cerulean"
game "gta5"
lua54 "yes"
author 'Luis-Werkstatt™️'
description 'Funkanimation für pma-voice [/funkani] | mit Kleidungs-Mapping & Adminmenü'
version '1.0.2'

shared_scripts {
    "@ox_lib/init.lua"
}

client_scripts {
    "data/config.lua",
    "client/main.lua"
}

server_scripts {
    'data/version.lua',
    "@oxmysql/lib/MySQL.lua",
    "data/config.lua",
    "server/main.lua"
}

escrow_ignore {
    "data/config.lua",
}

dependencies {
    "ox_lib",
    "oxmysql"
}