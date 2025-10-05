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
        end
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        FrameWork = 'qb'
    end
elseif Config.FrameWork == "esx" and GetResourceState('es_extended') == 'started' then
    if ESXVer == 'new' then
        ESX = exports['es_extended']:getSharedObject()
        FrameWork = 'esx'
    else
        ESX = nil
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    end
elseif Config.FrameWork == "qb" and GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    FrameWork = 'qb'
else
    print('===NO SUPPORTED FRAMEWORK FOUND===')
end

lib.locale()

local CryptoBalance = 0.0
local MinerStatus = false
local defaultCard = 'shitgpu'

local function getData(citizenid)
    local data = MySQL.Sync.prepare('SELECT * FROM cryptominers where citizenid = ?', { citizenid })
    return data
end

local function getGPU(citizenid, card)
    local dataGPU = MySQL.Sync.prepare('SELECT * FROM cryptominers where card = ?', { card })
    local dataCitizen = MySQL.Sync.prepare('SELECT * FROM cryptominers where citizenid = ?', { citizenid })
    return dataGPU, dataCitizen
end

local function ReceiveSCb(name, cb)
    if FrameWork == 'qb' then
        QBCore.Functions.CreateCallback(name, cb)
    elseif FrameWork == 'esx' then
        ESX.RegisterServerCallback(name, cb)
    end
end

RegisterNetEvent('razed-cryptomining:server:buyCryptoMiner', function()
    local src = source
    local Player = GetPlayer(src)
    local PlayerCitizenID = GetIdentifier(src)
    if not Player then return end

    local cash = GetAccountMoney(src, 'money')
    local bank = GetAccountMoney(src, 'bank')
    local price = Config.Price['Stage 1']

    local notifSuccessCash = {
        title = locale('payment_success_cash'),
        description = locale('payment_success_cash'),
        type = 'success'
    }
    local notifSuccessBank = {
        title = locale('payment_success_bank'),
        description = locale('payment_success_bank'),
        type = 'success'
    }
    local notifFail = {
        title = locale('payment_failed'),
        description = locale('payment_failed'),
        type = 'error'
    }

    if cash >= price then
        RemoveAccountMoney(src, 'money', price)
        TriggerClientEvent("ox_lib:notify", src, notifSuccessCash)
    elseif bank >= price then
        RemoveAccountMoney(src, 'bank', price)
        TriggerClientEvent("ox_lib:notify", src, notifSuccessBank)
    else
        TriggerClientEvent("ox_lib:notify", src, notifFail)
        return
    end

    MySQL.insert.await('INSERT INTO `cryptominers` (citizenid, card, balance) VALUES (?, ?, ?)',
        { PlayerCitizenID, defaultCard, CryptoBalance })
    TriggerClientEvent('razed-cryptomining:client:sendMail', src)
    TriggerClientEvent('razed-cryptomining:client:addinfo', src, getData(PlayerCitizenID))
end)

RegisterNetEvent('razed-cryptomining:server:getinfo', function()
    local src = source
    local PlayerCitizenID = GetIdentifier(src)
    local data = getData(PlayerCitizenID)
    TriggerClientEvent('razed-cryptomining:client:addinfo', src, data)
end)

ReceiveSCb('razed-cryptomining:server:showBalance', function(source, cb)
    local PlayerCitizenID = GetIdentifier(source)
    local row = MySQL.single.await('SELECT balance FROM cryptominers WHERE citizenid = ?', { PlayerCitizenID })
    cb(row and row.balance or 0)
end)

RegisterNetEvent('razed-cryptomining:server:withdrawcrypto', function()
    local src = source
    local citizenid = GetIdentifier(src)
    local row = MySQL.single.await('SELECT balance FROM cryptominers WHERE citizenid = ?', { citizenid })
    if not row or not row.balance then return end

    local balance = row.balance
    local notifLow = {
        title = locale('withdraw_failed'),
        description = locale('withdraw_failed'),
        duration = 5000,
        type = 'error'
    }
    local notifSuccess = {
        title = locale('withdraw_success', balance, Config.CryptoWithdrawalFeeShown),
        description = locale('withdraw_success', balance, Config.CryptoWithdrawalFeeShown),
        duration = 5000,
        type = 'success'
    }

    if balance > 0.001 then
        local payout = balance * Config.CryptoWithdrawalFee
        MySQL.update.await('UPDATE cryptominers SET balance = ? WHERE citizenid = ?', { 0, citizenid })

        if Config.Crypto == 'qb' then
            local Player = GetPlayer(src)
            if Player then
                Player.Functions.AddMoney('crypto', payout)
            end
        elseif Config.Crypto == 'renewed-phone' then
            exports['qb-phone']:AddCrypto(src, Config.RenewedCryptoType, payout)
        elseif Config.Crypto == 'lb-phone' then
            local success = exports["lb-phone"]:AddCrypto(src, Config.LBPhoneCryptoType, payout)
            if not success then
                print(locale('lbphone_addcrypto_failed', src, payout))
            end
        elseif FrameWork == 'esx' then
            AddMoneyFunction(src, 'bank', payout)
        else
            print(locale('framework_not_recognized'))
        end

        TriggerClientEvent("ox_lib:notify", src, notifSuccess)
    else
        TriggerClientEvent("ox_lib:notify", src, notifLow)
    end
end)

RegisterNetEvent('razed-cryptomining:server:switch', function(switchStatus)
    MinerStatus = switchStatus
end)

AddEventHandler('playerDropped', function()
    MinerStatus = false
end)

ReceiveSCb('razed-cryptomining:server:showGPU', function(source, cb)
    local citizenid = GetIdentifier(source)
    local gpuMap = {
        shitgpu = "GTX 480",
        ['1050gpu'] = "GTX 1050",
        ['1060gpu'] = "GTX 1060",
        ['1080gpu'] = "GTX 1080",
        ['2080gpu'] = "RTX 2080",
        ['3060gpu'] = "RTX 3060",
        ['4090gpu'] = "RTX 4090",
        ['5090gpu'] = "RTX 5090",
    }

    for card, label in pairs(gpuMap) do
        if getGPU(citizenid, card) then
            cb(label)
            return
        end
    end

    cb("Unknown")
end)

ReceiveSCb('razed-cryptomining:server:checkGPUImage', function(source, cb)
    local citizenid = GetIdentifier(source)
    local imageMap = {
        shitgpu = "https://files.catbox.moe/ivxw2a.png",
        ['1050gpu'] = "https://files.catbox.moe/rojnv7.png",
        ['1060gpu'] = "https://files.catbox.moe/xd2c5j.png",
        ['1080gpu'] = "https://files.catbox.moe/y58jcq.png",
        ['2080gpu'] = "https://files.catbox.moe/6ygah8.png",
        ['3060gpu'] = "https://files.catbox.moe/ugf1ir.png",
        ['4090gpu'] = "https://files.catbox.moe/4bjhmx.png",
        ['5090gpu'] = "https://files.catbox.moe/p5odzm.png",
    }

    for card, img in pairs(imageMap) do
        if getGPU(citizenid, card) then
            cb(img)
            return
        end
    end

    cb("Unknown")
end)

RegisterNetEvent('razed-cryptomining:server:sendGPUDatabase', function(gpu)
    local src = source
    if not gpu then return end

    local citizenid = GetIdentifier(src)
    MySQL.update.await('UPDATE cryptominers SET card = ? WHERE citizenid = ?', { gpu, citizenid })
    RemoveItem(src, gpu, 1)
    TriggerClientEvent('razed-cryptomining:client:sendGPUMail', src)
end)

RegisterNetEvent('razed-cryptomining:server:miningSystem', function()
    local src = source
    local citizenid = GetIdentifier(src)

    CreateThread(function()
        while true do
            Wait(1000)
            while MinerStatus do
                local miningRates = {
                    shitgpu = { wait = { 15000, 50000 }, gain = { 0.1, 0.3 } },
                    ['1050gpu'] = { wait = { 12500, 40000 }, gain = { 0.2, 0.6 } },
                    ['1060gpu'] = { wait = { 10000, 35000 }, gain = { 0.3, 0.7 } },
                    ['1080gpu'] = { wait = { 8000, 30000 }, gain = { 0.5, 1.0 } },
                    ['2080gpu'] = { wait = { 7500, 27500 }, gain = { 0.7, 1.1 } },
                    ['3060gpu'] = { wait = { 5500, 20500 }, gain = { 1.0, 1.5 } },
                    ['4090gpu'] = { wait = { 2500, 18500 }, gain = { 2.5, 5.0 } },
                    ['5090gpu'] = { wait = { 1750, 16000 }, gain = { 4.0, 8.0 } },
                }

                for gpu, data in pairs(miningRates) do
                    if getGPU(citizenid, gpu) then
                        Wait(math.random(data.wait[1], data.wait[2]))
                        if not MinerStatus then break end

                        local gain = math.random(data.gain[1] * 10, data.gain[2] * 10) / 10
                        CryptoBalance = CryptoBalance + gain

                        MySQL.update.await('UPDATE cryptominers SET balance = ? WHERE citizenid = ?', {
                            CryptoBalance, citizenid
                        })
                        Wait(math.random(1000, 5000))
                    end
                end
            end
        end
    end)
end)

if Config.EnableCryptoSellCommand then
    if FrameWork == 'qb' then
        QBCore.Commands.Add("sellcrypto", locale('sell_crypto_command'), {}, false, function(source, args)
            local src = source
            local Player = QBCore.Functions.GetPlayer(src)

            if not Config.SellCryptoEnabled then
                TriggerClientEvent('QBCore:Notify', src, locale('sell_crypto_disabled'), "error")
                return
            end

            if not Player then
                TriggerClientEvent('QBCore:Notify', src, locale('player_not_found'), "error")
                return
            end

            local coins = tonumber(args[1])
            if coins == nil or coins <= 0 then
                TriggerClientEvent('QBCore:Notify', src, locale('invalid_amount'), "error")
                return
            end

            MySQL.Async.fetchScalar("SELECT worth FROM crypto WHERE crypto = 'qbit'", {}, function(cryptoWorth)
                if cryptoWorth and cryptoWorth > 0 then
                    local playerCryptoBalance = Player.PlayerData.money.crypto or 0

                    if playerCryptoBalance >= coins then
                        local amount = math.floor(coins * cryptoWorth)
                        Player.Functions.RemoveMoney('crypto', coins)
                        Player.Functions.AddMoney('bank', amount)
                        TriggerClientEvent('QBCore:Notify', src, locale('sale_success', coins, amount), "success")
                    else
                        TriggerClientEvent('QBCore:Notify', src, locale('not_enough_crypto'), "error")
                    end
                else
                    TriggerClientEvent('QBCore:Notify', src, locale('unable_to_get_crypto_worth'), "error")
                end
            end)
        end)
    elseif FrameWork == 'esx' then
        RegisterCommand('sellcrypto', function(source, args)
            local xPlayer = ESX.GetPlayerFromId(source)

            if not Config.SellCryptoEnabled then
                TriggerClientEvent('esx:showNotification', source, locale('sell_crypto_disabled'))
                return
            end

            if not xPlayer then
                TriggerClientEvent('esx:showNotification', source, locale('player_not_found'))
                return
            end

            local coins = tonumber(args[1])
            if coins == nil or coins <= 0 then
                TriggerClientEvent('esx:showNotification', source, locale('invalid_amount'))
                return
            end

            MySQL.Async.fetchScalar("SELECT worth FROM crypto WHERE crypto = 'qbit'", {}, function(cryptoWorth)
                if cryptoWorth and cryptoWorth > 0 then
                    local playerCryptoBalance = xPlayer.getAccount('crypto') and xPlayer.getAccount('crypto').money or 0

                    if playerCryptoBalance >= coins then
                        local amount = math.floor(coins * cryptoWorth)
                        xPlayer.removeAccountMoney('crypto', coins)
                        xPlayer.addAccountMoney('bank', amount)
                        TriggerClientEvent('esx:showNotification', source, locale('sale_success', coins, amount))
                    else
                        TriggerClientEvent('esx:showNotification', source, locale('not_enough_crypto'))
                    end
                else
                    TriggerClientEvent('esx:showNotification', source, locale('unable_to_get_crypto_worth'))
                end
            end)
        end, false)
    end
end

RegisterNetEvent('razed-cryptomining:server:sendMail', function(data)
    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(source)
    local email = exports["lb-phone"]:GetEmailAddress(phoneNumber)
    if exports["lb-phone"] and exports["lb-phone"].SendMail then
        exports["lb-phone"]:SendMail({
            to = email,
            sender = data.sender,
            subject = data.subject,
            message = data.message
        })
    else
        print('[CryptoMining] LB-Phone export not available.')
    end
end)
