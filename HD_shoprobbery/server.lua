ESX = exports['es_extended']:getSharedObject()

local isRobberyActive = false

ESX.RegisterServerCallback('HD_shoprobbery:canRob', function(source, cb)
    local xPlayers = ESX.GetPlayers()
    local policeCount = 0

    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            policeCount = policeCount + 1
        end
    end

    if policeCount >= Config.RequiredPolice and not isRobberyActive then
        cb(true)
        isRobberyActive = true
    else
        cb(false)
    end
end)

RegisterServerEvent('HD_shoprobbery:notifyPolice')
AddEventHandler('HD_shoprobbery:notifyPolice', function(shop)
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            if Config.UseCDDispatch then
                -- cd_dispatch ilmoitus
                TriggerEvent('cd_dispatch:AddNotification', {
                    job_table = {'police'},
                    coords = {x = shop.x, y = shop.y, z = shop.z},
                    title = '023A - Kaupparyöstö',
                    message = 'Kaupparyöstö käynnissä sijainnissa: [' .. shop.x .. ', ' .. shop.y .. ']',
                    flash = 0,
                    unique_id = tostring(math.random(0000000, 9999999)),
                    blip = {
                        sprite = 161,
                        scale = 1.2,
                        colour = 1,
                        flashes = false,
                        text = '023A - Kaupparyöstö',
                        time = (5*60*1000),
                        sound = 1,
                    }
                })
            else
                -- ESX ilmoitus
                TriggerClientEvent('esx:showNotification', xPlayer.source, "Kaupparyöstö käynnissä sijainnissa: [" .. shop.x .. ", " .. shop.y .. ", " .. shop.z .. "]")
            end
        end
    end
end)

ESX.RegisterServerCallback('HD_shoprobbery:reward', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local reward = math.random(Config.MinCash, Config.MaxCash)
    xPlayer.addMoney(reward)
    cb(reward)
    isRobberyActive = false
end)
