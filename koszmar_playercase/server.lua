ESX = exports['es_extended']:getSharedObject()

local targetPlayerCount = nil
local item = 'itemek'
local itemCount = nil
local caseGiven = false

local allowedHexes = {
    "1100001487deca4"
}

function giveitemekToAllPlayers(item, count)
    local xPlayers = ESX.GetPlayers()

    for i = 1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer then
            xPlayer.addInventoryItem(item, count)
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                title = "Przedmiot Otrzymany",
                description = "Dostałeś skrzyneczkę: " .. item,
                type = "success",
                position = "top-right",
                duration = 5000
            })
        end
    end
end

function isAllowedHex(identifier)
    for _, hex in ipairs(allowedHexes) do
        if identifier == hex then
            return true
        end
    end
    return false
end

RegisterCommand('playercase', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer and (xPlayer.getGroup() == 'owner' or isAllowedHex(xPlayer.identifier)) then
        targetPlayerCount = tonumber(args[1])
        itemCount = tonumber(args[2])
        item = args[3]
        caseGiven = false 

        if targetPlayerCount and itemCount and item then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"^1SYSTEM", "Ustawiono próg graczy na " .. targetPlayerCount .. ", ilość przedmiotów na " .. itemCount .. " oraz nazwę przedmiotu na " .. item}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {"^1SYSTEM", "Użyj poprawnej komendy: /playercase [liczba_graczy] [ilość_przedmiotów] [nazwa_przedmiotu]"}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1SYSTEM", "Nie masz uprawnień do użycia tej komendy."}
        })
    end
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000) -- Sprawdzenie co 10 sekund

        if targetPlayerCount and itemCount and item and not caseGiven then
            local playerCount = #ESX.GetPlayers()
            if playerCount >= targetPlayerCount then
                giveitemekToAllPlayers(item, itemCount)
                print("Wszyscy gracze otrzymali " .. itemCount .. " przedmiot(ów) " .. item .. ".")
                caseGiven = true
            end
        end
    end
end)