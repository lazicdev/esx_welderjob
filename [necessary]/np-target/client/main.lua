ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()

end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
    Citizen.Wait(5000)
end)

local Models = {}
local Zones = {}

RegisterKeyMapping("+playerTarget", "Player Targeting", "keyboard", "LMENU")

RegisterCommand("+playerTarget", function()
    playerTargetEnable()
end)

RegisterCommand("-playerTarget", function()
    playerTargetDisable()
end)

function playerTargetEnable()
    if success then return end
    if IsPedArmed(PlayerPedId(), 6) then return end

    targetActive = true

    SendNUIMessage({response = "openTarget"})

    while targetActive do
        local plyCoords = GetEntityCoords(GetPlayerPed(-1))
        local hit, coords, entity = RayCastGamePlayCamera(20.0)

        if hit == 1 then
            if GetEntityType(entity) ~= 0 then
                for _, model in pairs(Models) do
                    if PlayerData.job.name == model.job or PlayerData.job.name == nil then
                        if _ == GetEntityModel(entity) then
                            if #(plyCoords - coords) <= Models[_]["distance"] then

                                success = true

                                SendNUIMessage({response = "validTarget", data = Models[_]["options"]})

                                while success and targetActive do
                                    local plyCoords = GetEntityCoords(GetPlayerPed(-1))
                                    local hit, coords, entity = RayCastGamePlayCamera(20.0)

                                    DisablePlayerFiring(PlayerPedId(), true)

                                    if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
                                        SetNuiFocus(true, true)
                                        SetCursorLocation(0.5, 0.5)
                                    end

                                    if GetEntityType(entity) == 0 or #(plyCoords - coords) > Models[_]["distance"] then
                                        success = false
                                    end

                                    Citizen.Wait(1)
                                end
                                SendNUIMessage({response = "leftTarget"})
                            end
                        end
                    end
                end
            end

            for _, zone in pairs(Zones) do
                local TrebamJob = zone["targetoptions"]["job"]
                if TrebamJob ~= "all" then
                    if PlayerData.job.name == TrebamJob then
                        if Zones[_]:isPointInside(coords) then
                            if #(plyCoords - Zones[_].center) <= zone["targetoptions"]["distance"] then

                                success = true

                                SendNUIMessage({response = "validTarget", data = Zones[_]["targetoptions"]["options"]})

                                while success and targetActive do
                                    local plyCoords = GetEntityCoords(GetPlayerPed(-1))
                                    local hit, coords, entity = RayCastGamePlayCamera(20.0)

                                    DisablePlayerFiring(PlayerPedId(), true)

                                    if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
                                        SetNuiFocus(true, true)
                                        SetCursorLocation(0.5, 0.5)
                                    end
                                    
                                    if not Zones[_]:isPointInside(coords) or #(plyCoords - Zones[_].center) > zone.targetoptions.distance then
                                        success = false
                                    end

                                    Citizen.Wait(1)
                                end
                                SendNUIMessage({response = "leftTarget"})
                            end
                        end
                    end
                else
                    if Zones[_]:isPointInside(coords) then
                        if #(plyCoords - Zones[_].center) <= zone["targetoptions"]["distance"] then

                            success = true

                            SendNUIMessage({response = "validTarget", data = Zones[_]["targetoptions"]["options"]})

                            while success and targetActive do
                                local plyCoords = GetEntityCoords(GetPlayerPed(-1))
                                local hit, coords, entity = RayCastGamePlayCamera(20.0)

                                DisablePlayerFiring(PlayerPedId(), true)

                                if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
                                    SetNuiFocus(true, true)
                                    SetCursorLocation(0.5, 0.5)
                                end
                                
                                if not Zones[_]:isPointInside(coords) or #(plyCoords - Zones[_].center) > zone.targetoptions.distance then
                                    success = false
                                end

                                Citizen.Wait(1)
                            end
                            SendNUIMessage({response = "leftTarget"})
                        end
                    end
                end
            end
        end
        Citizen.Wait(250)
    end
end

function playerTargetDisable()
    if success then return end

    targetActive = false

    SendNUIMessage({response = "closeTarget"})
end

--NUI CALL BACKS

RegisterNUICallback('selectTarget', function(data, cb)
    SetNuiFocus(false, false)

    success = false

    targetActive = false

    TriggerEvent(data.event)
end)

RegisterNUICallback('closeTarget', function(data, cb)
    SetNuiFocus(false, false)

    success = false

    targetActive = false
end)

--Functions from https://forum.cfx.re/t/get-camera-coordinates/183555/14

function RotationToDirection(rotation)
    local adjustedRotation =
    {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction =
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

--Exports

function AddCircleZone(name, center, radius, options, targetoptions)
    Zones[name] = CircleZone:Create(center, radius, options)
    Zones[name].targetoptions = targetoptions
end

function AddBoxZone(name, center, length, width, options, targetoptions)
    Zones[name] = BoxZone:Create(center, length, width, options)
    Zones[name].targetoptions = targetoptions
end

function AddPolyzone(name, points, options, targetoptions)
    Zones[name] = PolyZone:Create(points, options)
    Zones[name].targetoptions = targetoptions
end

function AddTargetModel(models, parameteres)
	for _, model in pairs(models) do
		Models[model] = parameteres
	end
end

exports("AddCircleZone", AddCircleZone)

exports("AddBoxZone", AddBoxZone)

exports("AddPolyzone", AddPolyzone)

exports("AddTargetModel", AddTargetModel)

Citizen.CreateThread(function()

    exports['np-target']:AddCircleZone("WelderStartJob", vector3(2569.44, 2720.29, 41.95), 205.6, {
        name="WelderStartJob",
        debugPoly=false,
        useZ=true,
        }, {
            options = {
                {
                    event = "esx_welder:mainmenu",
                    icon = "fas fa-circle",
                    label = "Welder Job",
                },
            },
            job = "all",
            distance = 1.5
        })

    exports['np-target']:AddCircleZone("WelderReturntheVehicle", vector3(2582.26, 2732.01, 41.69), 14.29, {
        name="WelderReturntheVehicle",
        debugPoly=false,
        useZ=true,
        }, {
            options = {
                {
                    event = "esx_welder:deletevehiclejob",
                    icon = "fas fa-circle",
                    label = "Return the Vehicle",
                },
            },
            job = "all",
            distance = 3.0
        })

    exports['np-target']:AddCircleZone("Weld1", vector3(2789.52, 2835.49, 36.17), 268.7, {
        name="Weld1",
        debugPoly=false,
        useZ=true,
        }, {
            options = {
                {
                    event = "esx_welder:weldingstart",
                    icon = "fas fa-circle",
                    label = "Weld",
                },
            },
            job = "all",
            distance = 1.5
        })

    exports['np-target']:AddCircleZone("Weld2", vector3(2754.6, 2801.41, 33.97), 268.7, {
        name="Weld2",
        debugPoly=false,
        useZ=true,
        }, {
            options = {
                {
                    event = "esx_welder:weldingstart",
                    icon = "fas fa-circle",
                    label = "Weld",
                },
            },
            job = "all",
            distance = 1.5
        })

    exports['np-target']:AddCircleZone("Weld3", vector3(2666.03, 2771.74, 36.94), 268.7, {
        name="Weld3",
        debugPoly=false,
        useZ=true,
        }, {
            options = {
                {
                    event = "esx_welder:weldingstart",
                    icon = "fas fa-circle",
                    label = "Weld",
                },
            },
            job = "all",
            distance = 1.5
        })

    exports['np-target']:AddCircleZone("Weld4", vector3(2639.25, 2932.11, 36.88), 268.7, {
        name="Weld4",
        debugPoly=false,
        useZ=true,
        }, {
            options = {
                {
                    event = "esx_welder:weldingstart",
                    icon = "fas fa-circle",
                    label = "Weld",
                },
            },
            job = "all",
            distance = 1.5
        })

    exports['np-target']:AddCircleZone("Weld5", vector3(2673.16, 2796.82, 32.81), 268.7, {
        name="Weld5",
        debugPoly=false,
        useZ=true,
        }, {
            options = {
                {
                    event = "esx_welder:weldingstart",
                    icon = "fas fa-circle",
                    label = "Weld",
                },
            },
            job = "all",
            distance = 1.5
        })
		
    exports['np-target']:AddCircleZone("SellOfMaterials", vector3(-566.52, 5326.42, 72.61), 268.7, {
        name="SellOfMaterials",
        debugPoly=false,
        useZ=true,
        }, {
            options = {
                {
                    event = "esx_welder:sellmenu",
                    icon = "fas fa-circle",
                    label = "Sale of Materials",
                },
            },
            job = "all",
            distance = 1.5
        })
end)   
