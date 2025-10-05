local ESXVer = Config.ESXVer
local FrameWork = nil
local ESX, QBCore

if Config.FrameWork == "auto" then
    if GetResourceState('es_extended') == 'started' then
        if ESXVer == 'new' then
            ESX = exports['es_extended']:getSharedObject()
        else
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
        end
        FrameWork = 'esx'
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        FrameWork = 'qb'
    end
elseif Config.FrameWork == "esx" and GetResourceState('es_extended') == 'started' then
    if ESXVer == 'new' then
        ESX = exports['es_extended']:getSharedObject()
    else
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
    print('=== ⚠️ NO SUPPORTED FRAMEWORK FOUND ===')
end

function HasGPU(item)
    if Config.Inventory == 'ox' then
        local hasItem = false
        local itemCount = exports.ox_inventory:GetItemCount(item)

        if itemCount > 0 then
            hasItem = true
        else
            hasItem = false
        end
        return hasItem
    else
        if FrameWork == 'qb' then
            local hasItem = QBCore.Functions.HasItem(item)
            return not hasItem
        elseif FrameWork == 'esx' then
            if ESX.SearchInventory and ESXVer == 'new' then
                local itemData = ESX.SearchInventory(item)
                if itemData and itemData.count and itemData.count > 0 then
                    return false
                else
                    return true
                end
            else
                local xPlayer = ESX.GetPlayerData()
                if not xPlayer or not xPlayer.inventory then return true end
                for _, invItem in pairs(xPlayer.inventory) do
                    if invItem.name == item and invItem.count > 0 then
                        return false
                    end
                end
                return true
            end
        else
            return false
        end
    end
end

local GPUList = {
    GTX480 = 'shitgpu',
    GTX1050 = '1050gpu',
    GTX1060 = '1060gpu',
    GTX1080 = '1080gpu',
    RTX2080 = '2080gpu',
    RTX3060 = '3060gpu',
    RTX4090 = '4090gpu',
    RTX5090 = '5090gpu',
}

local function CheckGPU(item)
    return not HasGPU(item)
end

for name, item in pairs(GPUList) do
    _G['Check' .. name] = function()
        return CheckGPU(item)
    end
end

local function InstallGPU(gpu, skillSequence, skillOptions, speedMultiplier)
    local notif1 = {
        title = locale('installing'),
        description = locale('wait_instalation'),
        duration = 3000,
        type = 'success'
    }
    local notif2 = {
        title = locale('gpu_installed_succesfully'),
        description = locale('enjoy_minig'),
        duration = 3000,
        type = 'success'
    }
    local notif3 = {
        title = locale('error'),
        description = locale('error_description'),
        duration = 3000,
        type = 'error'
    }

    if speedMultiplier then
        for i, step in ipairs(skillSequence) do
            if type(step) == 'table' then
                step.speedMultiplier = speedMultiplier
            end
        end
    end

    local success = lib.skillCheck(skillSequence, skillOptions)

    if success then
        ExecuteCommand("e mechanic")
        TriggerEvent("ox_lib:notify", notif1)
        if lib.progressCircle({
                duration = 15000,
                position = 'bottom',
                label = locale('installing'),
                useWhileDead = false,
                canCancel = false,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                },
            }) then
            TriggerEvent("ox_lib:notify", notif2)
            TriggerServerEvent('razed-cryptomining:server:sendGPUDatabase', gpu)
            ExecuteCommand("e c")
        else
            TriggerEvent("ox_lib:notify", notif3)
            ExecuteCommand("e c")
        end
    else
        TriggerEvent("ox_lib:notify", notif3)
    end
end

local GPUs = {
    GTX480 = { id = 'shitgpu', skill = { 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'easy' }, options = { 'w', 'a' } },
    GTX1050 = { id = '1050gpu', skill = { 'easy', 'easy', { areaSize = 60 }, 'easy' }, options = { 'w', 'a', 's', 'd' }, speed = 1.25 },
    GTX1060 = { id = '1060gpu', skill = { 'easy', 'easy', { areaSize = 60 }, 'easy' }, options = { 'w', 'a', 's', 'd' }, speed = 1.5 },
    GTX1080 = { id = '1080gpu', skill = { 'easy', 'easy', { areaSize = 60 }, 'medium' }, options = { 'w', 'a', 's', 'd' }, speed = 1.75 },
    RTX2080 = { id = '2080gpu', skill = { 'easy', 'easy', { areaSize = 60 }, 'medium' }, options = { 'w', 'a', 's', 'd' }, speed = 2 },
    RTX3060 = { id = '3060gpu', skill = { 'easy', 'medium', { areaSize = 60 }, 'medium' }, options = { 'w', 'a', 's', 'd' }, speed = 2.25 },
    RTX4090 = { id = '4090gpu', skill = { 'easy', 'medium', { areaSize = 60 }, 'hard' }, options = { 'w', 'a', 's', 'd' }, speed = 2.5 },
    RTX5090 = { id = '5090gpu', skill = { 'easy', 'medium', { areaSize = 60 }, 'hard' }, options = { 'w', 'a', 's', 'd' }, speed = 2.75 },
}

for name, data in pairs(GPUs) do
    RegisterNetEvent('razed-cryptomining:client:use' .. name, function()
        InstallGPU(data.id, data.skill, data.options, data.speed)
    end)
end
