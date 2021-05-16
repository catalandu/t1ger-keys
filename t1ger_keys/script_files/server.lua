-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

carKeys = {}


-- Callback to check if plate is owned by a player:
ESX.RegisterServerCallback('t1ger_keys:isCarOwned', function(source, cb, plate) 
	local xPlayer = ESX.GetPlayerFromId(source)
	local alarmType = 0
	local isCarOwned = false
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE @plate = plate', { ['@plate'] = plate }, function(data)
		if(data[1] ~= nil) then
			isCarOwned = true
			alarmType = data[1].alarm
			cb(isCarOwned,alarmType)
		else
			cb(isCarOwned,alarmType)
		end
    end)
end)

-- Callback to fetch insured vehicles for an identifier:
ESX.RegisterServerCallback("t1ger_keys:fetchInsuranceData", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local insuredCars = {}
	if xPlayer then
		MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner=@identifier',{['@identifier'] = xPlayer.getIdentifier()}, function(data) 
			for k,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				if v.insurance == 1 then
					table.insert(insuredCars, {vehicle = vehicle, plate = v.plate, insurance = v.insurance})
				end
			end
			cb(insuredCars)
		end)
	end
end)

-- Server event to update vehicle insurance state:
RegisterServerEvent("t1ger_keys:registerNewKey")
AddEventHandler("t1ger_keys:registerNewKey", function(plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
		MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner=@identifier',{['@identifier'] = xPlayer.getIdentifier()}, function(data) 
			for k,v in pairs(data) do
				if plate == v.plate then
					if v.gotKey == 0 then
						paidKey = false
						if Config.KeyPayBankMoney then
							if xPlayer.getAccount('bank').money >= Config.RegisterKeyPrice then
								xPlayer.removeAccountMoney('bank', Config.RegisterKeyPrice)
								paidKey = true
							else
								paidKey = false
							end
						else
							if xPlayer.getMoney() >= Config.RegisterKeyPrice then
								xPlayer.removeMoney(Config.RegisterKeyPrice)
								paidKey = true
							else
								paidKey = false
							end
						end
						if paidKey then
							MySQL.Async.execute('UPDATE owned_vehicles SET gotKey=@gotKey WHERE plate=@plate',{['@plate'] = plate,['@gotKey'] = 1}, function() end)
						else
							TriggerClientEvent('t1ger_keys:ShowNotifyESX', xPlayer.source, Lang['not_enough_money'])
						end
					end
					break
				end
			end
		end)
	end
end)

-- Server event to update vehicle alarm type:
RegisterServerEvent("t1ger_keys:updateCarAlarm")
AddEventHandler("t1ger_keys:updateCarAlarm", function(plate, alarmType, model)
    local xPlayer = ESX.GetPlayerFromId(source)
	local vehicles = MySQL.Sync.fetchAll('SELECT * FROM vehicles') -- get data
	local carPlate = plate
	local carModel = model
	local carAlarm = alarmType
	local carPrice = 0
	
	-- Get the selected vehicle from owned vehicles table:
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner=@identifier',{['@identifier'] = xPlayer.getIdentifier()}, function(data) 
		for k,v in pairs(data) do
			if plate == v.plate then
				local vehicle = json.decode(v.vehicle)
				if v.alarm == alarmType then
					if alarmType == 1 or alarmType == 2 then
						TriggerClientEvent('t1ger_keys:ShowNotifyESX', xPlayer.source, Lang['alarm_already_owned'])
					else
						TriggerClientEvent('t1ger_keys:ShowNotifyESX', xPlayer.source, Lang['remove_not_exist_alarm'])
					end
				else
					if Config.t1ger_cardealer then
						carPlate = v.plate
						carPrice = v.paidprice
						TriggerEvent("t1ger_keys:CarAlarmPayment",xPlayer,plate,carPrice,carAlarm)
					else
						for r,t in pairs(vehicles) do
							if t.model == carModel then
								carPlate = v.plate
								carPrice = t.price
								TriggerEvent("t1ger_keys:CarAlarmPayment",xPlayer,plate,carPrice,carAlarm)
							end
						end
					end
				end
				break
			end
		end
	end)
	
end)

-- Server event to update vehicle insurance state:
RegisterServerEvent("t1ger_keys:CarAlarmPayment")
AddEventHandler("t1ger_keys:CarAlarmPayment", function(xPlayer,plate,carPrice,carAlarm)
	local xPlayer = xPlayer
	local alarmPrice = 0
	local paidAlarm = false
	local alarmType = carAlarm
	
	-- Get Price for Alarm:
	if alarmType == 0 then -- REMOVE ALARM
		alarmPrice = (carPrice * (1/100))
	elseif alarmType == 1 then -- ALARM I
		alarmPrice = (carPrice * (5/100))
	elseif alarmType == 2 then  -- ALARM II
		alarmPrice = (carPrice * (15/100))
	end
	
	alarmPrice = math.floor(alarmPrice/Config.AlarmPriceFactor)
	
	-- Remove money from player:
	paidAlarm = false
	if not paidAlarm then
		if Config.AlarmPayBankMoney then
			if xPlayer.getAccount('bank').money >= alarmPrice then
				xPlayer.removeAccountMoney('bank', alarmPrice)
				paidAlarm = true
			else
				paidAlarm = false
			end
		else
			if xPlayer.getMoney() >= alarmPrice then
				xPlayer.removeMoney(alarmPrice)
				paidAlarm = true
			else
				paidAlarm = false
			end
		end
	end
	
	-- Update DB and notify player:
	if paidAlarm then
		MySQL.Async.execute('UPDATE owned_vehicles SET alarm=@alarm WHERE plate=@plate',{['@plate'] = plate,['@alarm'] = alarmType}, function() end)
		if alarmType == 1 then
			TriggerClientEvent('t1ger_keys:ShowNotifyESX', xPlayer.source, Lang['alarm_I_purchased'])
		elseif alarmType == 2 then
			TriggerClientEvent('t1ger_keys:ShowNotifyESX', xPlayer.source, Lang['alarm_II_purchased'])	
		elseif alarmType == 0 then
			TriggerClientEvent('t1ger_keys:ShowNotifyESX', xPlayer.source, Lang['alarm_removed'])
		end
	else
		TriggerClientEvent('t1ger_keys:ShowNotifyESX', xPlayer.source, Lang['not_enough_money'])
	end

end)

-- Server event to add keys to table
RegisterServerEvent("t1ger_keys:lendCarKeys")
AddEventHandler("t1ger_keys:lendCarKeys", function(target, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
	local tPlayer = ESX.GetPlayerFromId(target)
	local carPlate = tostring(plate)
	-- carKeys server table:
	carKeys[carPlate] = {}
	-- insert into table:
	table.insert(carKeys[carPlate], {identifier = tPlayer.getIdentifier()})
	-- Sync data:
	TriggerClientEvent('t1ger_keys:syncTableKeys', target, carKeys, tPlayer.getIdentifier())
	-- Send client notifications:
	TriggerClientEvent('t1ger_keys:ShowNotifyESX', xPlayer.source, Lang['keys_lend_give'])
	TriggerClientEvent('t1ger_keys:ShowNotifyESX', tPlayer.target, Lang['keys_lend_receive'])
end)

-- Server event to update stolen car keys
RegisterServerEvent("t1ger_keys:stolenCarKeys")
AddEventHandler("t1ger_keys:stolenCarKeys", function(plate)
    local xPlayer = ESX.GetPlayerFromId(source)
	local carPlate = tostring(plate)
	-- carKeys server table:
	carKeys[carPlate] = {}
	-- insert into table:
	table.insert(carKeys[carPlate], {identifier = xPlayer.getIdentifier()})
	-- Sync data:
	TriggerClientEvent('t1ger_keys:syncTableKeys', source, carKeys, xPlayer.getIdentifier())
end)

-- Usable item to lockpick vehicles:
Citizen.CreateThread(function()
	for k,v in pairs(Config.LockpickItem) do 
		ESX.RegisterUsableItem(v.ItemName, function(source)
			local xPlayer = ESX.GetPlayerFromId(source)
			local itemLabel = v.ItemLabel
			TriggerClientEvent("t1ger_keys:lockpickCL",source,k,v)
			-- Remove Item Upon Callback:
			ESX.RegisterServerCallback("t1ger_keys:removeLockpick",function(source,cb)
				local xPlayer = ESX.GetPlayerFromId(source)
				local lockpick = xPlayer.getInventoryItem(v.ItemName).count >= 1
				if lockpick then
					xPlayer.removeInventoryItem(v.ItemName,1)
					cb(true)
				end
			end)	
		end)
	end
end)

-- Callback to fetch whitelisted vehicle key:
ESX.RegisterServerCallback("t1ger_keys:fetchCarWlKey", function(source, cb, hashKey)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		local HasWhitelist = false
		for k,v in pairs(Config.WhitelistCars) do
			if hashKey == v.model then
				for _,y in pairs (Config.WhitelistCars[k].job) do
					if xPlayer.job.name == y then
						HasWhitelist = true
					end
				end
			end
		end
		if HasWhitelist then
			cb(true)
		else
			cb(false)
		end
	end
end)

-- Server Event for Job Reward:
RegisterServerEvent("t1ger_keys:giveSearchReward")
AddEventHandler("t1ger_keys:giveSearchReward", function()
	local xPlayer = ESX.GetPlayerFromId(source)
	
	-- CASH REWARDS:
	local cashChance = (math.random() * 100)
	if Config.ExtraCash.chance < cashChance then
		local type = Config.ExtraCash.type
		local amount = math.random(Config.ExtraCash.min,Config.ExtraCash.max) 
		if type == "cash" then
			xPlayer.addMoney(amount)
		elseif type == "dirty" then
			xPlayer.addAccountMoney('black_money',amount)
		end
		TriggerClientEvent('t1ger_keys:ShowNotifyESX', xPlayer.source, (Lang['cash_found']):format(amount))
	end
	
	-- ITEM REWARDS:
	local k = 0
	for k,v in pairs(Config.SearchItems) do
		local itemChance = (math.random() * 100)
		if v.chance > itemChance then
			local item = v.item
			local name = v.name
			local amount = math.random(v.min,v.max)
			xPlayer.addInventoryItem(item, tonumber(amount))
			TriggerClientEvent('t1ger_keys:ShowNotifyESX', xPlayer.source, (Lang['item_found']):format(amount,name))
		end
		k = (k + 1)
	end
	
end)

-- Event for police alerts
RegisterServerEvent('t1ger_keys:PoliceNotifySV')
AddEventHandler('t1ger_keys:PoliceNotifySV', function(targetCoords, streetName)
	TriggerClientEvent('t1ger_keys:PoliceNotifyCL', -1, (Lang['police_notify']):format(streetName))
	TriggerClientEvent('t1ger_keys:PoliceNotifyBlip', -1, targetCoords)
end)

-- Event for police alerts
RegisterServerEvent('t1ger_keys:PoliceNotifySV2')
AddEventHandler('t1ger_keys:PoliceNotifySV2', function(targetCoords, streetName, vehInfo)
	TriggerClientEvent('t1ger_keys:PoliceNotifyCL', -1, vehInfo)
	TriggerClientEvent('t1ger_keys:PoliceNotifyBlip', -1, targetCoords)
end)