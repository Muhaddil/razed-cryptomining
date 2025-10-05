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

function GetPlayer(source)
    if FrameWork == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif FrameWork == 'esx' then
        return ESX.GetPlayerFromId(source)
    end
    return nil
end

function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

if FrameWork == 'esx' then
    local ESXVer = Config.ESXVer

    if ESXVer ~= 'new' and ESXVer ~= 'old' then
        print('Invalid ESX version specified in config. Please set it to "new" or "old".')
        return
    end

    function GetIdentifier(source)
        local xPlayer = GetPlayer(source)
        return xPlayer.identifier
    end

    function GetPlayerByIdentifier(identifier)
        return ESX.GetPlayerFromIdentifier(identifier)
    end

    function GetAccountMoney(source, account)
        local xPlayer = GetPlayer(source)
        if account == 'bank' then
            return xPlayer.getAccount(account).money
        elseif account == 'money' then
            return xPlayer.getMoney()
        end
    end

    function AddMoneyFunction(source, account, amount)
        local xPlayer = GetPlayer(source)
        if account == 'bank' then
            xPlayer.addAccountMoney('bank', amount)
        elseif account == 'money' then
            xPlayer.addMoney(amount)
        end
    end

    function RemoveAccountMoney(source, account, amount)
        local xPlayer = GetPlayer(source)
        if account == 'bank' then
            xPlayer.removeAccountMoney('bank', amount)
        elseif account == 'money' then
            xPlayer.removeMoney(amount)
        end
    end

    function GetItemCount(source, item)
        local xPlayer = GetPlayer(source)

        if ESXVer == 'new' then
            return exports.ox_inventory:GetItemCount(source, item)
        else
            if string.sub(item, 0, 6):lower() == 'weapon' then
                local loadoutNum, weapon = xPlayer.getWeapon(item:upper())

                if weapon then
                    return true
                else
                    return false
                end
            else
                return xPlayer.getInventoryItem(item).count
            end
        end
    end

    function RemoveItem(source, item, amount)
        local xPlayer = GetPlayer(source)
        if ESXVer == 'new' then
            exports.ox_inventory:RemoveItem(source, item, amount)
        else
            if string.sub(item, 0, 6):lower() == 'weapon' then
                xPlayer.removeWeapon(item)
            else
                xPlayer.removeInventoryItem(item, amount)
            end
        end
    end

    function AddItem(source, item, count)
        local xPlayer = GetPlayer(source)
        if ESXVer == 'new' then
            exports.ox_inventory:AddItem(source, item, count)
        else
            if string.sub(item, 0, 6):lower() == 'weapon' then
                xPlayer.addWeapon(item, 90)
            else
                xPlayer.addInventoryItem(item, count)
            end
        end
    end

    function GetPlayerNameFunction(source)
        local name
        if Config.SteamName then
            name = GetPlayerName(source)
        else
            local xPlayer = GetPlayer(source)
            name = xPlayer.getName() or 'No Data'
        end
        return name
    end

    function GetPlayerSex(source)
        local xPlayer = GetPlayer(source)
        return xPlayer.get("sex")
    end

    function GetPlayerJob(source)
        local xPlayer = GetPlayer(source)
        return xPlayer.job.name
    end
elseif FrameWork == 'qb' then
    function GetIdentifier(source)
        local xPlayer = GetPlayer(source)
        return xPlayer.PlayerData.citizenid
    end

    function GetPlayerByIdentifier(identifier)
        return QBCore.Functions.GetPlayerByCitizenId(identifier)
    end

    function GetPlayersFunction()
        return QBCore.Functions.GetPlayers()
    end

    function GetAccountMoney(source, account)
        local xPlayer = GetPlayer(source)
        if account == 'bank' then
            return xPlayer.PlayerData.money.bank
        elseif account == 'money' then
            return xPlayer.PlayerData.money.cash
        end
    end

    function AddMoneyFunction(source, account, amount)
        local xPlayer = GetPlayer(source)
        if account == 'bank' then
            xPlayer.Functions.AddMoney('bank', amount)
        elseif account == 'money' then
            xPlayer.Functions.AddMoney('cash', amount)
        end
    end

    function GetItemCount(source, item)
        local xPlayer = GetPlayer(source)
        local items = xPlayer.Functions.GetItemByName(item)
        local item_count = 0
        if items ~= nil then
            item_count = items.amount
        else
            item_count = 0
        end
        return item_count
    end

    function RemoveAccountMoney(source, account, amount)
        local xPlayer = GetPlayer(source)
        if account == 'bank' then
            xPlayer.Functions.RemoveMoney('bank', amount)
        elseif account == 'money' then
            xPlayer.Functions.RemoveMoney('cash', amount)
        end
    end

    function RemoveItem(source, item, amount)
        local xPlayer = GetPlayer(source)
        xPlayer.Functions.RemoveItem(item, amount)
    end

    function AddItem(source, item, count)
        local xPlayer = GetPlayer(source)
        xPlayer.Functions.AddItem(item, count)
    end

    function GetPlayerNameFunction(source)
        local name
        if Config.SteamName then
            name = GetPlayerName(source)
        else
            local xPlayer = GetPlayer(source)
            name = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
        end
        return name
    end

    function GetPlayerSex(source)
        local xPlayer = GetPlayer(source)
        local sex = xPlayer.PlayerData.charinfo.gender

        if sex == 0 then
            sex = 'm'
        else
            sex = 'f'
        end

        return sex
    end

    function GetPlayerJob(source)
        local xPlayer = GetPlayer(source)
        return xPlayer.PlayerData.job.name
    end

    function GetPlayerDeathMetaData(source)
        local xPlayer = GetPlayer(source)
        return xPlayer.PlayerData.metadata['isdead']
    end

    function SetPlayerDeathMetaData(source, isDead)
        local xPlayer = GetPlayer(source)
        xPlayer.Functions.SetMetaData("isdead", isDead)
    end
end
