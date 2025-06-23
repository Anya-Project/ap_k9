Framework = {}

if Config.Framework == 'autodetect' then
    if GetResourceState('es_extended') == 'started' then Config.Framework = 'esx' end
    if GetResourceState('qb-core') == 'started' then Config.Framework = 'qb' end
end

if Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
    function Framework.GetPlayerJob(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.job.name
    end
elseif Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
    function Framework.GetPlayerJob(source)
        return QBCore.Functions.GetPlayer(source).PlayerData.job.name
    end
end

function Framework.GetPlayerName(source)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getName() 
    elseif Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    end
    return GetPlayerName(source)
end

function Framework.GetPlayerGrade(source)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.job.grade or nil
    elseif Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.job.grade.level or nil
    end
    return nil
end