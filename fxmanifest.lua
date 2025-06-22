
fx_version 'cerulean'
game 'gta5'

author 'Anya Project'
description 'Immersive Kick & Ban System with a cinematic kidnapping scene, integrated with txAdmin.'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'qb-core'
}