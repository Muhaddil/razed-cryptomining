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

function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

if FrameWork == 'esx' then
    if ESXVer ~= 'new' and ESXVer ~= 'old' then
        print('Invalid ESX version specified in config. Please set it to "new" or "old".')
        return
    end

    LoadedEvent = 'esx:playerLoaded'
    ReviveEvent = 'esx_ambulancejob:revive'
    JobChangeEvent = 'esx:setJob'
    TriggerServerCallback = ESX.TriggerServerCallback

    function GetPlayerJobDatas()
        return ESX.GetPlayerData().job
    end

    function GetClosestPlayerFunction()
        return ESX.Game.GetClosestPlayer()
    end

    function GetClosestVehicleFunction(coords, modelFilter)
        return ESX.Game.GetClosestVehicle(coords, modelFilter)
    end
elseif FrameWork == 'qb' then
    LoadedEvent = 'QBCore:Client:OnPlayerLoaded'
    ReviveEvent = 'hospital:client:Revive'
    JobChangeEvent = 'QBCore:Client:OnJobUpdate'
    TriggerServerCallback = QBCore.Functions.TriggerCallback

    function GetPlayerJobDatas()
        return QBCore.Functions.GetPlayerData().job
    end

    function GetClosestPlayerFunction()
        return QBCore.Functions.GetClosestPlayer()
    end

    function GetClosestVehicleFunction(coords, modelFilter)
        return QBCore.Functions.GetClosestVehicle(coords, modelFilter)
    end
end

function TextUIFunction(type, text)
    if type == 'open' then
        if Config.TextUI:lower() == 'ox_lib' then
            lib.showTextUI(text)
        elseif Config.TextUI:lower() == 'okoktextui' then
            exports['okokTextUI']:Open(text, 'darkblue', 'right')
        elseif Config.TextUI:lower() == 'esxtextui' then
            ESX.TextUI(text)
        elseif Config.TextUI:lower() == 'qbdrawtext' then
            exports['qb-core']:DrawText(text, 'left')
        end
    elseif type == 'hide' then
        if Config.TextUI:lower() == 'ox_lib' then
            lib.hideTextUI()
        elseif Config.TextUI:lower() == 'okoktextui' then
            exports['okokTextUI']:Close()
        elseif Config.TextUI:lower() == 'esxtextui' then
            ESX.HideUI()
        elseif Config.TextUI:lower() == 'qbdrawtext' then
            exports['qb-core']:HideText()
        end
    end
end
