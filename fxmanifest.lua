fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'TheStoicBear'
description 'Stoic-SaveWeapon'
version '1.0.0'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'source/server.lua'
}

client_scripts {
    'source/client.lua'
}

shared_scripts {
	'config.lua',
    '@ox_lib/init.lua',
}


