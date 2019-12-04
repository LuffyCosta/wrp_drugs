Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil
local font = 2
local color = { r = 220, g = 220, b = 220, alpha = 255 }
local background = {
    enable = true,
    color = { r = 35, g = 35, b = 35, alpha = 150 },
}
local playerPed
local playerCoords
local working = false
local startH = Config.StartTime
local endH = Config.EndTime
local drugObjects = {}
local spawntime = false

local created_ped

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	ESX.PlayerData = ESX.GetPlayerData()
end)

Citizen.CreateThread(function()	
	while true do 
		playerPed = PlayerPedId()
		playerCoords = GetEntityCoords(playerPed)
		Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()	
	while true do 
		if GetClockHours() == startH and GetClockMinutes() == 0 then
			TriggerServerEvent("wrp_drugs:generateDrugs")
			--print("GENERUOJAM DRUGSUS NX")
		end
		Citizen.Wait(5000)
	end
end)

function canSpawn()
	if GetClockHours() >= startH or GetClockHours() < endH then
		return true
	else
		return false
	end
end
Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(0)
		if playerCoords ~= nil then
			for k, v in pairs(Config.Locations) do
				for b, c in pairs(v) do
					for z, j in pairs(c.coords) do 
						local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, j.x, j.y, j.z)
						if distance < 4 then
							if b == "gather" and canSpawn() == true then
								DrawText3D(j.x, j.y, j.z + 1, c.text)
								if IsControlJustReleased(0, Keys["E"]) and distance < 2.4 then
									routeDrugs(k, b, c.input, c.output, c.animation, c.msg)
									Citizen.Wait(500)
								end
							elseif b ~= "gather" then
								DrawText3D(j.x, j.y, j.z + 1, c.text)
								if IsControlJustReleased(0, Keys["E"]) and distance < 2.4 then
									routeDrugs(k, b, c.input, c.output, c.animation, c.msg)
									Citizen.Wait(500)
								end
							end
						end

					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(500)
		if playerCoords ~= nil then
			for k, v in pairs(Config.Locations) do
				for b, c in pairs(v.gather.propsToSpawn) do
					for s, j in pairs(v.gather.coords) do
						local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, j.x, j.y, j.z)
						local state = canSpawn()
						if distance < 150 and state == true then
							SpawnObjects(j)
						end
						if distance > 150 or state == false then
							deleteObjects(k)
						end
					end
				end
			end
		end
		if IsPedInAnyVehicle(PlayerPedId()) == 1 and working == true then
			TriggerServerEvent("wrp_drugs:cancel")
			TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = "Can't sell from a vehicle!"})
		end
	end
end)

Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(0)
		if IsControlJustReleased(0, Keys["Y"]) and working == true then
			TriggerServerEvent("wrp_drugs:cancel")
			TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = "You stopped the action!"})
		end

	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(15000)
	SpawnObjects()
end)

RegisterNetEvent("wrp_drugs:continue")
AddEventHandler("wrp_drugs:continue", function(drugName, proccess, input, output, anim, msg, source, zoneName)
	TriggerServerEvent("wrp_drugs:proccessDrugs",drugName, proccess, input, output, anim, msg, source, zoneName)
end)

RegisterNetEvent("wrp_drugs:spawnNpc")
AddEventHandler("wrp_drugs:spawnNpc", function(modelid, drugName, zoneName)
	local target = PlayerPedId()
	local pc = GetEntityCoords(target)
	local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 100, 100, 20)
    local heading, spawn = FindSpawnPointInDirection(offset.x, offset.y, offset.z, pc.x, pc.y, pc.z, 50.0)
    working = true
    created_ped = GetRandomPedAtCoord(pc.x , pc.y, pc.z, 120.0,120.0, 120.0, 1)

    if created_ped == 0 then
    	pc = GetEntityCoords(target)
    	created_ped = GetRandomPedAtCoord(pc.x , pc.y, pc.z, 120.0,120.0, 120.0, 1)
    end
    if created_ped == 0 then
    	TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = "There are no customers around you"})
    end

    SetEntityAsMissionEntity(created_ped, false, false)
    --AddBlipForEntity(created_ped)
    local arrived = false
    ClearPedTasksImmediately(created_ped)

    TaskGoToEntity(created_ped, target, -1, 1.3, 1.0, 1073741824, 0)
    local tooFar = false
	while true do
		Citizen.Wait(0)
		local pcCoords = GetEntityCoords(target)
		local coords = GetEntityCoords(created_ped)
		local distance = Vdist(coords.x, coords.y, coords.z, pc.x, pc.y, pc.z)

		if IsPedDeadOrDying(created_ped) then
			TriggerServerEvent("wrp_drugs:npcDead")
			break
		end
		local drugDist = Vdist(pc.x, pc.y, pc.z, pcCoords.x, pcCoords.y, pcCoords.z)
		if drugDist > 3 and working == true then
			TriggerServerEvent("wrp_drugs:cancel")
			tooFar = true
			TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = "You got too far!"})
			break
		end
        if distance < 2.5 then
        	break
        end
	end
	if IsPedDeadOrDying(created_ped) == false and tooFar == false then
		local anim = Config.Locations[drugName].sell.animation
		ClearPedTasks(PlayerPedId())
		if anim ~= nil then
			ESX.Streaming.RequestAnimDict(anim.library, function()
				TaskPlayAnim(PlayerPedId(), anim.library, anim.name, 8.0, -8.0, -1, 0, 0, false, false, false)
			end)
		end
		TaskChatToPed(created_ped, target, 1, 0,0,0,0,0,0)
		Citizen.Wait(Config.Locations[drugName].sell.haglingduration)

		anim = Config.Locations[drugName].sell.animation2
		ESX.Streaming.RequestAnimDict(anim.library, function()
			TaskPlayAnim(PlayerPedId(), anim.library, anim.name, 8.0, -8.0, -1, 0, 0, false, false, false)
		end)
		TriggerServerEvent("wrp_drugs:hagleDone")
		--print("haggleDone")
		local temp = math.random(1,10)
		print(temp)
		if temp > 4 then
			--CALL THE POLICE HERE WITH YOU SCRIPT
			--TriggerServerEvent('gcPhone:sendMessage', 'police', "The person is selling something possibly illegal", { x = pc.x, y = pc.y, z = pc.z })
		end

	    Citizen.Wait(Config.Locations[drugName].sell.duration)
	   	ClearPedTasks(target)
	   	SetEntityAsNoLongerNeeded(created_ped)
	   	created_ped = nil
	end
end)

function SpawnObjects(j)
	for k, v in pairs(Config.Locations) do
		for b, c in pairs(v.gather.propsToSpawn) do
			for s, p in pairs(v.gather.coords) do
				if j == p then
					if drugObjects[k] == nil then
						ESX.Game.SpawnLocalObject(c.name, p, function(obj)
							SetEntityHeading(obj, c.heading)
							PlaceObjectOnGroundProperly(obj)
							FreezeEntityPosition(obj, true)
							drugObjects[k] = obj
					    end)
					end
				end
			end
		end
	end
end

function deleteObjects(name)
    for k, v in pairs(drugObjects) do
    	if k == name then
  			ESX.Game.DeleteObject(drugObjects[k])
  			drugObjects[k] = nil
  		end
  	end
end

RegisterNetEvent("wrp_drugs:playAnimation")
AddEventHandler("wrp_drugs:playAnimation", function(anim)
	print(anim)			
	if anim ~= nil then
		ESX.Streaming.RequestAnimDict(anim.library, function()
			TaskPlayAnim(PlayerPedId(), anim.library, anim.name, 8.0, -8.0, -1, 0, 0, false, false, false)
		end)
	end
end)

RegisterNetEvent("wrp_drugs:stopAnimation")
AddEventHandler("wrp_drugs:stopAnimation", function()
	ClearPedTasks(PlayerPedId())
	working = false
	--FreezeEntityPosition(PlayerPedId(), false)
	--ClearPedTasksImmediately(created_ped)
   	SetEntityAsNoLongerNeeded(created_ped)
end)

function routeDrugs(drugName, proccessName, input, output, anim, msg)
	gatherDrugs(drugName, proccessName, input, output, anim, msg)
	working = true
end

function gatherDrugs(drugName, proccessName, input, output, anim, msg)
	TriggerServerEvent("wrp_drugs:proccessDrugs", drugName, proccessName, input, output, anim, msg)
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y = World3dToScreen2d(x,y,z)
    local px,py,pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = ((1/dist)*2)*(1/GetGameplayCamFov())*90

    _y = _y + 0.2

    if onScreen then

        -- Formalize the text
        SetTextColour(color.r, color.g, color.b, color.alpha)
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextCentre(true)
        SetTextOutline()
        if dropShadow then
            SetTextDropshadow(10, 100, 100, 100, 255)
        end

        -- Calculate width and height
        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local height = GetTextScaleHeight(0.70*scale, font)
        local width = EndTextCommandGetWidth(font)

        -- Diplay the text
        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)

        if background.enable then
            DrawRect(_x, _y+scale/40, width + 0.01, height, background.color.r, background.color.g, background.color.b , background.color.alpha)
        end
    end
end

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
    	return
  	end
  	for k, v in pairs(drugObjects) do
  		ESX.Game.DeleteObject(v)
  		drugObjects[k] = nil
  	end
end)
AddEventHandler('playerDropped', function (reason)
    for k, v in pairs(drugObjects) do
  		ESX.Game.DeleteObject(v)
  		drugObjects[k] = nil
  	end
end)