fx_version "cerulean"
game "gta5"

description "Razed's Crypto Mining"

author 'Razed Scripts'

version '1.0.1'

lua54 'yes'

client_script {
    'client/*',
}

server_script {
    'server/*',
    '@oxmysql/lib/MySQL.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/*.lua',
}

files {
    'locales/*.json'
}
