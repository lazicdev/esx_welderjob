ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_welder:paycheck')
AddEventHandler('esx_welder:paycheck', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local receivemoney = math.random(50, 100)
	xPlayer.addMoney(receivemoney)
end)

RegisterNetEvent('esx_welder:additems')
AddEventHandler('esx_welder:additems', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	xPlayer.addInventoryItem(RandomItem(), RandomNumber())
end)

Items = {
	"celik", -- put the items you want here --
    "bakar"
}

function RandomItem()
return Items[math.random(#Items)]
end

function RandomNumber()
	return math.random(1,2)
end

RegisterServerEvent("esx_welder:startsellcelik")
AddEventHandler("esx_welder:startsellcelik", function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
    local distance = #(GetEntityCoords(GetPlayerPed(src)) - vector3(-566.52, 5326.42, 72.61))

    if distance < 10 then
        if xPlayer.getInventoryItem('celik').count >= 1 then -- put the item you want here --
            random = math.random(15,20)
            money = random * xPlayer.getInventoryItem('celik').count -- put the item you want here --
            local moneytemp = money
            xPlayer.removeInventoryItem('celik', xPlayer.getInventoryItem('celik').count) -- put the item you want here --
            xPlayer.addMoney(moneytemp)
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You dont have steel'})
        end
    else
		print("godfather can't do that") -- put a ban trigger or kick here --
    end
end)

RegisterServerEvent("esx_welder:startsellbakar")
AddEventHandler("esx_welder:startsellbakar", function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
    local distance = #(GetEntityCoords(GetPlayerPed(src)) - vector3(-566.52, 5326.42, 72.61))

    if distance < 10 then
        if xPlayer.getInventoryItem('bakar').count >= 1 then -- put the item you want here --
            random = math.random(10,15)
            money = random * xPlayer.getInventoryItem('bakar').count -- put the item you want here -- 
            local moneytemp = money
            xPlayer.removeInventoryItem('bakar', xPlayer.getInventoryItem('bakar').count) -- put the item you want here --
            xPlayer.addMoney(moneytemp)
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You dont have Copper'})
        end
    else
		print("godfather can't do that") -- put a ban trigger or kick here --
    end
end)