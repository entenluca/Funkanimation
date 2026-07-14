fx_version "cerulean"
game "gta5"
lua54 "yes"
author 'NoWave'
description 'Funkanimation für pma-voice [/funkani] | made by NoWave'
version '1.1.5'

ui_page "html/index.html"

files {
    "html/index.html",
    "html/style.css",
    "html/script.js",
}

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
    "html/**",
}

dependencies {
    "ox_lib",
}
