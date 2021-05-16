ESX.RegisterServerCallback("t1ger_keys:fetchData", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicles = {}
    if xPlayer then
            MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner=@identifier',{['@identifier'] = xPlayer.getIdentifier()}, function(data)
                    for k,v in pairs(data) do
                            local vehicle = json.decode(v.vehicle)
                            table.insert(vehicles, {vehicle = vehicle, plate = v.plate, gotKey = v.gotKey, alarm = v.alarm})
                    end
                    cb(vehicles)
            end)
    end
end)

-- Callback to fetch owned vehicle key:
ESX.RegisterServerCallback("t1ger_keys:fetchCarKey", function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicles = {}
    if xPlayer then
            MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate=@plate AND owner=@identifier',{ ['@plate'] = plate, ['@identifier'] = xPlayer.getIdentifier()}, function(data)
                    local KeyFound = false
                    if data[1] ~= nil then
                            if xPlayer.identifier == data[1].owner then
                                    KeyFound = true
                            end
                    end
                    if KeyFound then
                            cb(true)
                    else
                            cb(false)
                    end
            end)
    end
end)