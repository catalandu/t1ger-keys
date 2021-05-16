-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {}

-- Locksmith Settings:
Config.RegisterKeyPrice 	= 300		
Config.KeyPayBankMoney		= true	-- set to false to pay with cash instead of bank moeny

-- Dependencies:
Config.t1ger_carinsurance 	= true	-- set to false if you don't own t1ger_carinsurance script
Config.t1ger_cardealer	  	= true	-- set to false if you don't own t1ger_cardealer script

-- Alarm Settings:
Config.AlarmPayBankMoney = true		-- set to false, if players should pay for alarms with cash instead of bank money
Config.AlarmPriceFactor = 1 		-- set factor of alarm price, so say it's 10% of vehicle price, then factorize this amount

-- Stealing NPC Cars Settings:
Config.HandsUpTime = 6					-- set the time NPC stands with their hands up
Config.PedGivesKeyChance = 85			-- set the chance of NPC giving keys upon threatening
Config.AlertTime = {min = 1, max = 8}	-- set min and max seconds, from car is successfully robbed, to police receive call from NPC

-- Police Settings:
Config.AllowedJobs = {"police", "ambulance"}
Config.AlertBlip = {{
	Enable 	= true,			-- enable or disable blip on map on police notify
	Time 	= 30,			-- miliseconds that blip is active on map (this value is multiplied with 4 in the script)
	Radius 	= 50.0,			-- set radius of the police notify blip
	Alpha 	= 250,			-- set alpha of the blip
	Color 	= 3				-- set blip color
}}

-- Locksmith Shop:
Config.Locksmith = {{
	Pos = {170.18,-1799.42,29.32},
	Key = 38,
	Marker = {
		Enable = true,
		DrawDist = 10.0,
		Type = 27,
		Scale = {x = 1.0, y = 1.0, z = 1.0},
		Color = {r = 240, g = 52, b = 52, a = 100},
	},
	Blip = {
		Enable 	= true,
		Pos 	= {170.18,-1799.42,29.32},
		Sprite 	= 134,
		Color 	= 1,
		Name 	= "Locksmith",
		Scale 	= 1.0,
		Display = 4,
	}
}}


-- Alarm Shop
Config.AlarmShop = {{
	Pos = {-194.48,-834.61,30.74},
	Key = 38,
	Marker = {
		Enable = true,
		DrawDist = 10.0,
		Type = 27,
		Scale = {x = 1.0, y = 1.0, z = 1.0},
		Color = {r = 240, g = 52, b = 52, a = 100},
	},
	Blip = {
		Enable 	= true,
		Pos 	= {-194.48,-834.61,30.74},
		Sprite 	= 459,
		Color 	= 3,
		Name 	= "Alarm Shop",
		Scale 	= 0.7,
		Display = 4,
	}
}}

-- Add Police/EMS Vehicles or other whitelisted vehicles and set job permissions
Config.WhitelistCars = {
    [1] = {model = GetHashKey('vchmp'), job = {"police", "ambulance"}},
    [2] = {model = GetHashKey('srpambulance'), job = {"ambulance"}},
    [3] = {model = GetHashKey('vapup'), job = {"police"}},
}

-- Settings for Lockpicking:
Config.LockpickItem = {{
	ItemName			= "lockpick",			-- Item name in database for usable item
	ItemLabel			= "Lockpick",			-- Item name that is displayed in notifications etc
	ProgressBarText		= "LOCKPICKING",		-- Progress bar text
	LockpickTime 		= 10,					-- Lockpicking time in seconds
	ChanceOne 			= 70,					-- Lockpicking success chance in percent (no alarm)
	ChanceTwo 			= 30,					-- Lockpicking success chance in percent (Alarm I)
	ChanceThree 		= 10,					-- Lockpicking success chance in percent (Alarm II)
	EnableAlarmSound 	= true,					-- Enable/Disable car clarm upon lockpicking 
	CarAlarmTime 		= 40,					-- Set duration of car alarm upon lockpicking, in seconds.
	PoliceAlert			= true,					-- Enable/Disable police alert upon lockpicking
	AnimDict			= "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
	AnimName			= "machinic_loop_mechandplayer",
}}

-- Settings for Hotwiring:
Config.HotwireFeature = {{
	ProgressBarText		= "HOTWIRING",			-- Progress bar text
	HotwireTime 		= 10,					-- Lockpicking time in seconds
	AnimDict			= "veh@handler@base",
	AnimName			= "hotwire",
}}
Config.HotwireChance = 90

-- Settings for Search:
Config.SearchCar = {{
	ProgressBarText		= "SEARCHING",			-- Progress bar text
	HotwireTime 		= 10,					-- Lockpicking time in seconds
	AnimDict			= "veh@handler@base",
	AnimName			= "hotwire"
}}

-- Search Rewards:
Config.SearchItems = {
	[1] = {item = "rolpaper", name = "Rolling Paper", min = 1, max = 4, chance = 67},
	[2] = {item = "goldwatch", name = "Gold Watch", min = 1, max = 3, chance = 20},
	[3] = {item = "sandwich", name = "Sandwich", min = 1, max = 4, chance = 54},
	[4] = {item = "repairkit", name = "Repair Kit", min = 1, max = 3, chance = 85},
	[5] = {item = "donut", name = "Donut", min = 2, max = 7, chance = 54},
	[6] = {item = "coke1g", name = "Coke", min = 1, max = 3, chance = 94}
}

Config.ExtraCash = {chance = 50, min = 100, max = 750, type = 'cash' --[[set to 'dirty' if u want dirty cash]]}