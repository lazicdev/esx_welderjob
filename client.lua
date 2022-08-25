ESX                             = nil
local PlayerData                = {}
local onDuty                    = false
local BlipWelderJob             = nil
local Blips                     = {}
local OnJob                     = false
local Done 						= false
local skipjob                   = true

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	onDuty = false
	CreateBlip()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	onDuty = false
	CreateBlip()
end)			

RegisterNetEvent("esx_welder:jobfinish")
AddEventHandler("esx_welder:jobfinish", function()
	if Onjob then
		if skipjob then
			onDuty = false
			CreateBlip()
			exports['mythic_notify']:DoHudText('inform', 'You finished the job')
				
				if Onjob then
					StopNPCJob(true)
					RemoveBlip(Blips['NPCTargetPool'])
					Onjob = false
				end
		end
	else
		exports['mythic_notify']:DoHudText('error', 'You havent started a job')	
	end	
end)	

RegisterNetEvent("esx_welder:jobstart")
AddEventHandler("esx_welder:jobstart", function()
	local playerPed = PlayerPedId()
	local coords = vector3(2582.26, 2732.01, 42.69)
	local heading = 210.01
	local plates = Config.LicensePlate
	if not Onjob then
		if ESX.Game.IsSpawnPointClear(coords, 5) then
			if skipjob then
				onDuty = true
				CreateBlip()
				exports['mythic_notify']:DoHudText('inform', 'You have started work, the vehicle is waiting for you in the parking lot')

				StartNPCJob()
				Onjob = true
			
				ESX.Game.SpawnVehicle("burrito", coords, heading, function(vehicle)
					SetVehicleNumberPlateText(vehicle, plates)
					plate = GetVehicleNumberPlateText(vehicle)
					plate = string.gsub(plate, " ", "")
					name = 'Vehicle '..plates
				end)
			end
		else
			exports['mythic_notify']:DoHudText('error', 'Move the truck blocking the parking lot')
		end
	else
		exports['mythic_notify']:DoHudText('error', 'You have already started the job')
	end
end)

-- FUNCTIONS --

function CreateBlip()
	if skipjob then

		if BlipWelderJob == nil then
			BlipWelderJob = AddBlipForCoord(Config.Zones.WelderJob.Pos.x, Config.Zones.WelderJob.Pos.y, Config.Zones.WelderJob.Pos.z)
			SetBlipSprite(BlipWelderJob, Config.Zones.WelderJob.BlipSprite)
			SetBlipColour(BlipWelderJob, Config.Zones.WelderJob.BlipColor)
			SetBlipScale (BlipWelderJob, 1.0)
			SetBlipAsShortRange(BlipWelderJob, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(Config.Zones.WelderJob.BlipName)
			EndTextCommandSetBlipName(BlipWelderJob)
		end
	else

		if BlipWelderJob ~= nil then
			RemoveBlip(BlipWelderJob)
			BlipWelderJob = nil
		end
	end
end

function WeldingDestination()
	local index = GetRandomIntInRange(1,  #Config.Device)

	for k,v in pairs(Config.Zones) do
		if v.Pos.x == Config.Device[index].x and v.Pos.y == Config.Device[index].y and v.Pos.z == Config.Device[index].z then
			return k
		end
	end
end

function StartNPCJob()
	NPCTargetPool = WeldingDestination()
	local zone = Config.Zones[NPCTargetPool]

	Blips['NPCTargetPool'] = AddBlipForCoord(zone.Pos.x,  zone.Pos.y,  zone.Pos.z)
	SetBlipRoute(Blips['NPCTargetPool'], true)
	Done = true
	Onjob = true
end

function StopNPCJob(cancel)

	if Blips['NPCTargetPool'] ~= nil then
		RemoveBlip(Blips['NPCTargetPool'])
		Blips['NPCTargetPool'] = nil
	end

	OnJob = false

	if cancel then
		print("finished")
	else
		TriggerServerEvent('esx_welder:paycheck')
		TriggerServerEvent('esx_welder:additems') -- clear this if you don't want to get the item --
		StartNPCJob()
		Done = true
	end
end

function StartWelding()
	if Onjob then
		if NPCTargetPool ~= nil then

			local coords = GetEntityCoords(PlayerPedId())
			local zone   = Config.Zones[NPCTargetPool]
			local playerPed = PlayerPedId()

			if GetDistanceBetweenCoords(coords, zone.Pos.x, zone.Pos.y, zone.Pos.z, true) < 3 then

				local finished = exports["np-taskbarskill"]:taskBar(2200,10)
				if (finished == 100) then
					TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", -1, true)
					TriggerEvent('freeze:freezePlayer')
						local finished = exports["np-taskbar"]:taskBar(10000, "Welding...")
						if finished == 100 then

					StopNPCJob()
					ClearPedTasksImmediately(playerPed)
					TriggerEvent('unfreeze:freezePlayer')
					Done = false
						end
					else
						exports['mythic_notify']:DoHudText('error', 'You did not weld the object well, try again')
					end
			else
				Citizen.Wait(1000)
			end
		else
			Citizen.Wait(1000)
		end
	else
		exports['mythic_notify']:DoHudText('error', 'You havent started a job')
	end
end

function DeleteVehicleWelder()
	local playerPed = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(playerPed,  false)
	if IsPedInAnyVehicle(playerPed) then
		if Onjob then
		DeleteVehicle(vehicle)
		else
		exports['mythic_notify']:DoHudText('error', 'You didnt take the truck')
		end
	else
		exports['mythic_notify']:DoHudText('error', 'You are not in the vehicle')
	end	
end

RegisterNetEvent("esx_welder:deletevehiclejob")
AddEventHandler("esx_welder:deletevehiclejob", function()
	DeleteVehicleWelder()
end)

RegisterNetEvent("esx_welder:weldingstart")
AddEventHandler("esx_welder:weldingstart", function()
	StartWelding()
end)

-- NH CONTEXT --

AddEventHandler('esx_welder:mainmenu', function()
	TriggerEvent('nh-context:sendMenu', {
		{
			id = 1,
			header = "< Back",
			txt = "",
			params = {
				event = "lazic:offmenu",
				args = {
					
				}
			}
		},
		{
		  id = 2,
		  header = "Start the Job",
		  txt = "",
		  params = {
		  event = "esx_welder:jobstart",
		  }
		},
		{
		  id = 3,
		  header = "Finish the Job",
		  txt = "",
		  params = {
		  event = "esx_welder:jobfinish",
		  }
		},
	})
end)

AddEventHandler('esx_welder:sellmenu', function()
	TriggerEvent('nh-context:sendMenu', {
		{
			id = 1,
			header = "< Back",
			txt = "",
			params = {
				event = "lazic:offmenu",
				args = {
					
				}
			}
		},
		{
		  id = 2,
		  header = "Sell a Steel",
		  txt = "",
		  params = {
		  event = "esx_welder:takethemoneyofcelik",
		  }
		},
		{
		  id = 3,
		  header = "Sell a Copper",
		  txt = "",
		  params = {
		  event = "esx_welder:takethemoneyofbakar",
		  }
		},
	})
end)

-- BLIPS --

local blips = {
	{title="Welder Job", colour=64, id=318, x = 2569.44, y = 2720.29, z = 41.95},
	{title="Sale of Materials", colour=2, id=102, x = -566.52, y = 5326.42, z = 72.61},
}

Citizen.CreateThread(function()
   for _, info in pairs(blips) do
	info.blip = AddBlipForCoord(info.x, info.y, info.z)
	SetBlipSprite(info.blip, info.id)
	SetBlipDisplay(info.blip, 4)
	SetBlipScale(info.blip, 0.8)
	SetBlipColour(info.blip, info.colour)
	SetBlipAsShortRange(info.blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(info.title)
	EndTextCommandSetBlipName(info.blip)
   end
end)

-- SALE OF MATERIALS EVENTS --

RegisterNetEvent("esx_welder:takethemoneyofcelik")
AddEventHandler("esx_welder:takethemoneyofcelik", function()
  TriggerServerEvent('esx_welder:startsellcelik')
end)

RegisterNetEvent("esx_welder:takethemoneyofbakar")
AddEventHandler("esx_welder:takethemoneyofbakar", function()
  TriggerServerEvent('esx_welder:startsellbakar')
end)