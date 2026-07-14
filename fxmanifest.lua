fx_version "cerulean"
game "gta5"
lua54 "yes"
author 'Luis-Werkstatt™️'
description 'Funkanimation für pma-voice [/funkani] | mit Kleidungs-Mapping via config.lua'
version '1.0.3'

shared_scripts {
    "@ox_lib/init.lua"
}

client_scripts {
    "data/config.lua",
    "client/main.lua"
}

server_scripts {
    'data/version.lua',
    "server/main.lua"
}

escrow_ignore {
    "data/config.lua",
}

dependencies {
    "ox_lib",
}
