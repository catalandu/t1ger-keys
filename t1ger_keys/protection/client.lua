function OwnedKeysActions()
    local elements = {}

    ESX.TriggerServerCallback("t1ger_keys:fetchData", function(vehicles)

            for k,v in pairs(vehicles) do
                    local vehHash = v.vehicle.model
                    local vehName = GetDisplayNameFromVehicleModel(vehHash)
                    local vehLabel = GetLabelText(vehName)
                    if v.gotKey == 1 then
                            table.insert(elements,{ label = vehLabel.." ("..v.plate..")" , name = vehLabel, plate = v.plate, gotKey = v.gotKey})
                    end
            end

            ESX.UI.Menu.Open('default', GetCurrentResourceName(), "your_owned_keys",
                    {
                            title    = Lang['your_keys_title'],
                            align    = "center",
                            elements = elements
                    },
            function(data, menu)

                    -- CONFIRM MENU
                    local elements = {
                            { label = Lang['confirm_choice'], value = "give_key_accept" },
                            { label = Lang['decline_choice'], value = "give_key_decline" },
                    }

                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), "give_key_confirm",
                            {
                                    title    = Lang['confirm_giving_key'],
                                    align    = "center",
                                    elements = elements
                            },
                    function(data2, menu2)
                            if(data2.current.value == 'give_key_accept') then
                                    local player, distance = ESX.Game.GetClosestPlayer()
                                    menu2.close()
                                    ESX.UI.Menu.CloseAll()
                                    if distance ~= -1 and distance <= 2.0 then
                                            TriggerServerEvent('t1ger_keys:lendCarKeys', GetPlayerServerId(player), data2.current.plate)
                                    else
                                            ShowNotifyESX(Lang['no_players_nearby'])
                                    end
                            end
                            if(data2.current.value == 'give_key_decline') then
                                    menu2.close()
                                    OwnedKeysActions()
                            end
                    end, function(data2, menu2)
                            menu2.close()
                            OwnedKeysActions()
                    end)
                    -- CONFIRM MENU END

            end, function(data, menu)
                    menu.close()
                    ESX.UI.Menu.CloseAll()
            end)
    end)

end


-- Toggle Car Locks:
function ToggleVehicleLock()
    local plyPed = GetPlayerPed(-1)
    local coords = GetEntityCoords(plyPed, true)
    local car = nil

    if IsPedInAnyVehicle(plyPed,  false) then
            car = GetVehiclePedIsIn(plyPed, false)
    else
            car = GetClosestVehicle(coords.x, coords.y, coords.z, 6.0, 0, 71)
    end
    local closePlate = GetVehicleNumberPlateText(car)
    local closeHash = GetEntityModel(car)

    if DoesEntityExist(car) then
            ESX.TriggerServerCallback('t1ger_keys:fetchCarKey', function(hasKey)
                    ESX.TriggerServerCallback('t1ger_keys:fetchCarWlKey', function(hasWlKey)
                            Citizen.CreateThread(function()
                                    if HasTempCarKeys(closePlate) or hasKey or hasWlKey then
                                            if GetVehicleDoorLockStatus(car) == 1 or GetVehicleDoorLockStatus(car) == 0 then
                                                    LockToggleEffects(car,false)
                                            elseif GetVehicleDoorLockStatus(car) == 2 then
                                                    LockToggleEffects(car,true)
                                            end
                                    else
                                            return ShowNotifyESX(Lang['has_key_false'])
                                    end
                            end)
                    end, closeHash)
            end, closePlate)
    else
            ShowNotifyESX(Lang['no_veh_nearby'])
    end
end


carKeys = {}
plyIdentifier = 0
-- Sync Car Key Table from server to client:
RegisterNetEvent('t1ger_keys:syncTableKeys')
AddEventHandler('t1ger_keys:syncTableKeys', function(keysData, identifier)
    carKeys = keysData
    plyIdentifier = identifier
end)

-- Check if player has lended car keys:
function HasTempCarKeys(plate)
    if carKeys[plate] ~= nil then
            for k,v in pairs(carKeys[plate]) do
                    if v.identifier == plyIdentifier then
                            return true
                    end
            end
            return false
    else
            return false
    end
end