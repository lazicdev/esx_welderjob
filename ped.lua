local npcs = {
  ["Welder"] = {location = vector3(2569.44, 2720.29, 41.95), h = 205.6, ped = `cs_josef`, approached = false, spawnedPed = 0},
  ["SellMaterials"] = {location = vector3(-566.52, 5326.42, 72.61), h = 76.22, ped = `s_m_m_gaffer_01`, approached = false, spawnedPed = 0},
}

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end

	for key, data in pairs(npcs) do
		DeleteEntity(data.spawnedPed)
	end

end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)  
		local ped = PlayerPedId()
		local pedLoc = GetEntityCoords(ped)

		for key, data in pairs(npcs) do
			if not data.approached then
				if #(pedLoc - data.location) <= 150 then
					npcs[key].approached = true
					CreateNPCped(data, key)
				end
			else
				if #(pedLoc - npcs[key].location) > 150 then
					if DoesEntityExist(npcs[key].spawnedPed) then
						DeleteEntity(npcs[key].spawnedPed)
					end
					npcs[key].approached = false
					npcs[key].spawnedPed = 0
				end
			end
		end
	end
end)

function CreateNPCped(data, key)

	RequestModel(data.ped)

	while not HasModelLoaded(data.ped) do
		Wait(10)
	end

	if data.ped == -634611634 then

		npcs[key].spawnedPed = CreatePed(26, data.ped, data.location, data.h, false, false)
		FreezeEntityPosition(npcs[key].spawnedPed, true)
		SetBlockingOfNonTemporaryEvents(npcs[key].spawnedPed, true)
		SetEntityInvincible(npcs[key].spawnedPed, true)
		GiveWeaponToPed(npcs[key].spawnedPed,GetHashKey('WEAPON_CARBINERIFLE'), 0, false, true)
        SetCurrentPedWeapon(npcs[key].spawnedPed,GetHashKey('WEAPON_CARBINERIFLE'),true)
	else
		npcs[key].spawnedPed = CreatePed(26, data.ped, data.location, data.h, false, false)
		FreezeEntityPosition(npcs[key].spawnedPed, true)
		SetBlockingOfNonTemporaryEvents(npcs[key].spawnedPed, true)
		SetEntityInvincible(npcs[key].spawnedPed, true)
	end
end