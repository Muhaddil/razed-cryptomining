local ESXVer = Config.ESXVer
local FrameWork = nil

if Config.FrameWork == "auto" then
    if GetResourceState('es_extended') == 'started' then
        if ESXVer == 'new' then
            ESX = exports['es_extended']:getSharedObject()
            FrameWork = 'esx'
        else
            ESX = nil
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
            FrameWork = 'esx'
        end
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        FrameWork = 'qb'
    end
elseif Config.FrameWork == "esx" and GetResourceState('es_extended') == 'started' then
    if ESXVer == 'new' then
        ESX = exports['es_extended']:getSharedObject()
    else
        ESX = nil
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    end
    FrameWork = 'esx'
elseif Config.FrameWork == "qb" and GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    FrameWork = 'qb'
else
    print('=== NO SUPPORTED FRAMEWORK FOUND ===')
end

function TriggerServerCallback(name, cb, ...)
    if FrameWork == 'qb' then
        QBCore.Functions.TriggerCallback(name, cb, ...)
    elseif FrameWork == 'esx' then
        ESX.TriggerServerCallback(name, cb, ...)
    end
end

lib.locale()

local CryptoMinerProp = Config.CryptoMinerProp
local CryptoBalance = 0.0
local MinerStatus = false
local arg = { owned = false }

RegisterNetEvent('razed-cryptomining:client:CryptoMiningMenu', function()
    TriggerServerCallback('razed-cryptomining:server:showBalance', function(balance)
        lib.registerContext({
            id = 'cryptomenuon',
            title = locale('crypto_menu'),
            options = {
                -- { title = locale('toggle_status_withdraw') },
                {
                    title = locale('toggle_crypto_miner'),
                    description = locale('miner_running_desc'),
                    icon = 'toggle-on',
                    onSelect = function()
                        ToggleCryptoMiner()
                        if MinerStatus then
                            lib.showContext('cryptomenuon')
                        else
                            lib.showContext('cryptomenuoff')
                        end
                    end
                },
                { title = locale('miner_status_running'), description = locale('miner_running_desc'), icon = 'question' },
                { title = locale('go_back'),              description = locale('go_back_desc'),       icon = 'arrow-left', event = 'razed-cryptomining:client:CheckIfOwnedCrypto' }
            }
        })

        lib.registerContext({
            id = 'cryptomenuoff',
            title = locale('crypto_menu'),
            options = {
                -- { title = locale('toggle_status_withdraw') },
                { title = locale('balance', balance), icon = 'fa-brands fa-bitcoin' },
                {
                    title = locale('toggle_crypto_miner'),
                    description = locale('miner_off_desc'),
                    icon = 'toggle-off',
                    onSelect = function()
                        ToggleCryptoMiner()
                        if MinerStatus then
                            lib.showContext('cryptomenuon')
                        else
                            lib.showContext('cryptomenuoff')
                        end
                    end
                },
                { title = locale('miner_status_off'), description = locale('miner_off_desc'),                                 icon = 'question' },
                { title = locale('withdraw'),         description = locale('withdraw_desc', Config.CryptoWithdrawalFeeShown), icon = 'dollar',     serverEvent = 'razed-cryptomining:server:withdrawcrypto' },
                { title = locale('go_back'),          description = locale('go_back_desc'),                                   icon = 'arrow-left', event = 'razed-cryptomining:client:CheckIfOwnedCrypto' }
            }
        })

        if MinerStatus then
            lib.showContext('cryptomenuon')
        else
            lib.showContext('cryptomenuoff')
        end
    end)
end)

RegisterNetEvent('razed-cryptomining:client:BuyCryptoMining', function(args)
    lib.registerContext({
        id = 'buycryptominer',
        title = locale('purchase_menu'),
        options = {
            -- { title = locale('toggle_status_withdraw') },
            { title = locale('purchase'),           description = locale('purchase_desc', Config.Price['Stage 1']), icon = 'dollar',                                         serverEvent = 'razed-cryptomining:server:buyCryptoMiner', disabled = args.owned },
            { title = locale('proceed_menu'),       icon = 'fa-brands fa-bitcoin',                                  event = 'razed-cryptomining:client:CryptoMiningMenu',    disabled = not args.owned },
            { title = locale('upgrade_mining_rig'), icon = 'fa-solid fa-sim-card',                                  event = 'razed-cryptomining:client:UpgradeCryptoMining', disabled = not args.owned }
        }
    })
    lib.showContext('buycryptominer')
end)

RegisterNetEvent('razed-cryptomining:client:UpgradeCryptoMining', function()
    TriggerServerCallback('razed-cryptomining:server:showGPU', function(GPUType)
        TriggerServerCallback('razed-cryptomining:server:checkGPUImage', function(image)
            lib.registerContext({
                id = 'upgradecryptominer',
                title = locale('upgrade_menu'),
                options = {
                    { title = locale('got_gpu_upgrade') },
                    { title = locale('current_gpu', GPUType), image = image },
                    { title = locale('go_back'),              description = locale('go_back_desc'),     icon = 'arrow-left',           event = 'razed-cryptomining:client:CheckIfOwnedCrypto' },
                    { title = locale('gpu_gtx480'),           description = locale('gpu_gtx480_desc'),  icon = 'fa-solid fa-question', event = 'razed-cryptomining:client:useGTX480',         image = 'https://files.catbox.moe/ivxw2a.png', disabled = CheckGTX480() },
                    { title = locale('gpu_gtx1050'),          description = locale('gpu_gtx1050_desc'), icon = 'fa-solid fa-1',        event = 'razed-cryptomining:client:useGTX1050',        image = 'https://files.catbox.moe/rojnv7.png', disabled = CheckGTX1050() },
                    { title = locale('gpu_gtx1060'),          description = locale('gpu_gtx1060_desc'), icon = 'fa-solid fa-2',        event = 'razed-cryptomining:client:useGTX1060',        image = 'https://files.catbox.moe/xd2c5j.png', disabled = CheckGTX1060() },
                    { title = locale('gpu_gtx1080'),          description = locale('gpu_gtx1080_desc'), icon = 'fa-solid fa-3',        event = 'razed-cryptomining:client:useGTX1080',        image = 'https://files.catbox.moe/y58jcq.png', disabled = CheckGTX1080() },
                    { title = locale('gpu_rtx2080'),          description = locale('gpu_rtx2080_desc'), icon = 'fa-solid fa-4',        event = 'razed-cryptomining:client:useRTX2080',        image = 'https://files.catbox.moe/6ygah8.png', disabled = CheckRTX2080() },
                    { title = locale('gpu_rtx3060'),          description = locale('gpu_rtx3060_desc'), icon = 'fa-solid fa-5',        event = 'razed-cryptomining:client:useRTX3060',        image = 'https://files.catbox.moe/ugf1ir.png', disabled = CheckRTX3060() },
                    { title = locale('gpu_rtx4090'),          description = locale('gpu_rtx4090_desc'), icon = 'fa-solid fa-6',        event = 'razed-cryptomining:client:useRTX4090',        image = 'https://files.catbox.moe/4bjhmx.png', disabled = CheckRTX4090() },
                    { title = locale('gpu_rtx5090'),          description = locale('gpu_rtx5090_desc'), icon = 'fa-solid fa-7',        event = 'razed-cryptomining:client:useRTX5090',        image = 'https://files.catbox.moe/p5odzm.png', disabled = CheckRTX5090() }
                }
            })
            lib.showContext('upgradecryptominer')
        end)
    end)
end)

function ToggleCryptoMiner()
    if MinerStatus then
        lib.notify({ title = locale('toggle_stopping'), description = locale('toggle_stopping_desc'), type = 'error', duration = 5000 })
        Wait(500)
        MinerStatus = false
        MinerStopped()
    else
        lib.notify({ title = locale('toggle_starting'), description = locale('toggle_starting_desc'), type = 'success', duration = 5000 })
        Wait(500)
        MinerStatus = true
        MinerStarted()
    end
end

RegisterNetEvent('razed-cryptomining:client:addinfo', function(data)
    arg.owned = data ~= nil
end)

function MinerStarted()
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 0.5, 'progressbar', 0.5)
    TriggerServerEvent('razed-cryptomining:server:switch', true)
    TriggerServerEvent('razed-cryptomining:server:miningSystem')
end

function MinerStopped()
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 0.5, 'progressbarcancel', 0.5)
    TriggerServerEvent('razed-cryptomining:server:switch', false)
end

RegisterNetEvent('razed-cryptomining:client:CheckIfOwnedCrypto', function()
    TriggerServerEvent('razed-cryptomining:server:getinfo')
    Wait(500)
    TriggerEvent('razed-cryptomining:client:BuyCryptoMining', arg)
end)

local function SendMail(sender, subject, message)
    if not Config.Email then return end
    if Config.Crypto == 'lb-phone' then
        TriggerServerEvent('razed-cryptomining:server:sendMail',
        { sender = sender, subject = subject, message = message })
        return
    end
    if FrameWork == 'qb' and GetResourceState('qb-phone') == 'started' then
        TriggerServerEvent('qb-phone:server:sendNewMail', { sender = sender, subject = subject, message = message })
        return
    end
    if FrameWork == 'esx' and GetResourceState('gcphone') == 'started' then
        TriggerServerEvent('gcPhone:sendMessageFromServer', sender, subject .. "\n" .. message)
        return
    end
    print('[CryptoMining] Email system not available for this framework.')
end

RegisterNetEvent('razed-cryptomining:client:sendMail', function()
    SendMail(locale('email_purchase_sender'), locale('email_purchase_subject'), locale('email_purchase_text'))
end)

RegisterNetEvent('razed-cryptomining:client:sendGPUMail', function()
    SendMail(locale('email_gpu_sender'), locale('email_gpu_subject'), locale('email_gpu_text'))
end)

CreateThread(function()
    if Config.Target == 'qb' and GetResourceState('qb-target') == 'started' then
        exports['qb-target']:AddTargetModel(CryptoMinerProp, {
            options = {
                {
                    icon = "fa-brands fa-bitcoin",
                    label = locale('open_target'),
                    event = "razed-cryptomining:client:CheckIfOwnedCrypto"
                },
            },
            distance = 3.0,
        })
    elseif Config.Target == 'ox' and GetResourceState('ox_target') == 'started' then
        exports.ox_target:addModel(CryptoMinerProp, {
            {
                icon = "fa-brands fa-bitcoin",
                label = locale('open_target'),
                event = "razed-cryptomining:client:CheckIfOwnedCrypto",
                distance = 3.0,
            }
        })
    end
end)