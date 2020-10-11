ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('status', function(source, args, raw)
    TriggerClientEvent('esx_status:set', source, args[1], args[2])
end)