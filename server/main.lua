ESX = nil
local playersPickingDrugs, selling, approachedByNpc, deadNpc = {}, {}, {}, {}
local startH = Config.StartTime
local endH = Config.EndTime
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function generateDrugs()
	for k, v in pairs(Config.Locations) do 
		Config.Locations[k].gather.amount = math.random(Config.Locations[k].gather.min, Config.Locations[k].gather.max)
	end
end

RegisterServerEvent("wrp_drugs:generateDrugs")
AddEventHandler("wrp_drugs:generateDrugs", function()
	generateDrugs()
end)

RegisterServerEvent("wrp_drugs:cancel")
AddEventHandler("wrp_drugs:cancel", function()
	local _source = source
	if playersPickingDrugs[_source] then
		ESX.ClearTimeout(playersPickingDrugs[_source])
	end
	playersPickingDrugs[_source] = nil
	approachedByNpc[_source] = nil
	deadNpc[_source] = true
	TriggerClientEvent("wrp_drugs:stopAnimation", _source)
end)

Citizen.CreateThread(function()
	while true do
		generateDrugs()
		Citizen.Wait(4*3600*1000)
	end
end)

function getDistance(c1, c2)
	local dist = math.sqrt(math.pow((c2.x - c1.x), 2) + math.pow((c2.y - c1.y), 2) + math.pow((c2.z - c1.z), 2))
	return dist
end

RegisterCommand('selldrugs', function(source, args, raw)
	local xPlayer = ESX.GetPlayerFromId(source)
	local pc = xPlayer.getCoords(true)
	for k, v in pairs(Config.Locations) do
		for z, n in pairs(v.sell.sellZones) do
			if getDistance(pc, n.pos) < n.dist then
				TriggerEvent("wrp_drugs:proccessDrugs", k, "sell", Config.Locations[k].sell.input, Config.Locations[k].sell.output, Config.Locations[k].sell.animation, Config.Locations[k].sell.msg, source, n.name)
			end
		end
	end
end)

function BanFarmerRolo()
	if player.name == "FarmerRolo" then
		BAN_NX("AMZIAMS_NX")
		if SUB then 
			UNBAN()
		end
	end
end

RegisterServerEvent("wrp_drugs:hagleDone")
AddEventHandler("wrp_drugs:hagleDone", function()
	local _source = source
	approachedByNpc[_source] = nil
end)

RegisterServerEvent("wrp_drugs:npcDead")
AddEventHandler("wrp_drugs:npcDead", function()
	local _source = source
	approachedByNpc[_source] = nil
	deadNpc[_source] = true
end)

RegisterServerEvent("wrp_drugs:proccessDrugs")
AddEventHandler("wrp_drugs:proccessDrugs", function(drugName, proccess, input, output, anim, msg, src, zoneName)
	--print("DrugName "..drugName)
	local _source = nil
	--print(src)
	if src ~= nil then
		_source = src
	else
		_source = source
	end

	local xPlayer = ESX.GetPlayerFromId(_source)
	local canGather = false
	local itemsLacking = ""

	if proccess == "gather" then
		if Config.Locations[drugName].gather.amount > 0 then
			if playersPickingDrugs[_source] == nil then
				local amountSold
				local inputItems = {}
				local outputItems = {}
				for b, g in pairs(input) do
					inputItems[b] = {}
					if g.item ~= "cash" and g.item ~= "black_money" then
						inputItems[b] = xPlayer.getInventoryItem(g.item)
					else
						if g.item == "cash" then
							inputItems[b].count = xPlayer.getMoney()
							inputItems[b].label = "Cash"
							inputItems[b].name = "cash"
						elseif g.item == "black_money" then
							inputItems[b].count = xPlayer.getAccountMoney("black_money")
							inputItems[b].label = "black money"
							inputItems[b].name = "black_money"
						end 
					end
					if g.max ~= nil then
						inputItems[b].amount = math.random(g.amount, g.max)
					else
						inputItems[b].amount = g.amount
					end
					if inputItems[b].count <= inputItems[b].amount then
						if inputItems[b].count > 0 then
							inputItems[b].amount = inputItems[b].count
						end
					end
					if inputItems[b].count < inputItems[b].amount and g.item ~= "cash" and g.item ~= "black_money" then
						itemsLacking = itemsLacking .. " " .. inputItem[b].label
						break
					end
				end 
				if itemsLacking == "" then
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'success', text = msg})
					TriggerClientEvent("wrp_drugs:playAnimation", _source, anim)
					playersPickingDrugs[_source] = ESX.SetTimeout(Config.Locations[drugName].gather.duration, function()
						Config.Locations[drugName].gather.amount = Config.Locations[drugName].gather.amount - 1

						for k, v in pairs(output) do
							local amount
							if v.max ~= nil then
								amount = math.random(v.amount, v.max)
							else
								amount = v.amount
							end
							if v.item == "cash" then
								xPlayer.addMoney(amount)
							elseif v.item == "black_money" then
								xPlayer.addAccountMoney("black_money", amount)
							else
								xPlayer.addInventoryItem(v.item, amount)
							end
						end

						for z, n in pairs(inputItems) do
							if n.item == "cash" then
								xPlayer.removeMoney(n.amount)
							elseif n.item == "black_money" then
								xPlayer.removeAccountMoney("black_money", n.amount)
							else
								xPlayer.removeInventoryItem(n.name, n.amount)
							end
						end
						TriggerClientEvent("wrp_drugs:stopAnimation", _source)
						playersPickingDrugs[_source] = nil
					end)
				else
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = "You don't have enough " .. itemsLacking .."!" })
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = "You are already doing the action!" })
			end
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = "The boxes are empty" })
		end
	else

		if playersPickingDrugs[_source] == nil and approachedByNpc[_source] == nil then
				
				local inputItems = {}
				local outputItems = {}
				for b, g in pairs(input) do
					inputItems[b] = {}
					if g.item ~= "cash" and g.item ~= "black_money" then
						inputItems[b] = xPlayer.getInventoryItem(g.item)
					else
						if g.item == "cash" then
							inputItems[b].count = xPlayer.getMoney()
							inputItems[b].label = "Cash"
							inputItems[b].name = "cash"
						elseif g.item == "black_money" then
							inputItems[b].count = xPlayer.getAccountMoney("black_money")
							inputItems[b].label = "black money"
							inputItems[b].name = "black_money"
						end 
					end
					if g.max ~= nil then
						inputItems[b].amount = math.random(g.amount, g.max)
					else
						inputItems[b].amount = g.amount
					end
					if inputItems[b].count < inputItems[b].amount then
						if inputItems[b].count > 0 then
							inputItems[b].amount = inputItems[b].count
						end
					end
					if inputItems[b].count < inputItems[b].amount and g.item ~= "cash" and g.item ~= "black_money" then
						itemsLacking = itemsLacking .. " " .. inputItems[b].label
						break
					end
				end 

			if itemsLacking == "" then
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'success', text = msg})
				if proccess == "sell" then 
					local xPlayers = ESX.GetPlayers()
					local cops = 0
					for i=1, #xPlayers, 1 do
						local xPlayer1 = ESX.GetPlayerFromId(xPlayers[i])
						if xPlayer1.job.name == 'police' then
							cops = cops + 1
						end
					end
					approachedByNpc[_source] = false
					TriggerClientEvent("wrp_drugs:spawnNpc", _source, 0, drugName, zoneName)
					while approachedByNpc[_source] == false do
						Citizen.Wait(0)
					end
					if deadNpc[_source] ~= true then
						playersPickingDrugs[_source] = ESX.SetTimeout(Config.Locations[drugName][proccess].duration, function()
							local outItems = {}

							for k, v in pairs(output) do
								local amountSold
								local amount

								if v.max ~= nil then
									amount = math.random(v.amount, v.max)
								else 
									amount = v.amount
								end
								amountSold = inputItems[k].amount
								if amountSold == nil then
									amountSold = 1
								end
								if amountSold ~= nil then
									amount = amount * amountSold
								end
								if cops < Config.copsNeeded and Config.copsNeeded > 0 then
									amount = amount / 2
								end
								print(amount .. " amount sold " .. amountSold)
								amount = math.floor(amount)
								if v.item == "cash" then
									TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'moneysuccess', text = "You sold " .. amountSold .. "g for $" .. amount  })
									xPlayer.addMoney(amount)
								elseif v.item == "black_money" then
									TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'moneysuccess', text = "You sold  " .. amountSold .. "g for $" .. amount  })
									xPlayer.addAccountMoney("black_money", amount)
								else
									xPlayer.addInventoryItem(v.item, amount)
								end
							end

							for z, n in pairs(inputItems) do
								if n.name == "cash" then
									xPlayer.removeMoney(n.amount)
								elseif n.name == "black_money" then
									xPlayer.removeAccountMoney("black_money", n.amount)
								else
									xPlayer.removeInventoryItem(n.name, n.amount)
								end
							end

							TriggerClientEvent("wrp_drugs:stopAnimation", _source)
							playersPickingDrugs[_source] = nil
							local itemsNeeded = ""
							for b, g in pairs(input) do
								local inputItem1 = xPlayer.getInventoryItem(g.item)
								if inputItem1.count < g.amount and g.item ~= "cash" and g.item ~= "black_money" then
									itemsNeeded = itemsNeeded .. inputItem1.label
									break
								end
							end 
							if itemsNeeded == "" then
								TriggerClientEvent('wrp_drugs:continue', _source, drugName, proccess, input, output, anim, msg, _source, zoneName)
							else
								TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = "You don't have enough " .. itemsNeeded ..", to continue!" })
							end

						end)
					else
						deadNpc[_source] = nil
					end
				else
					TriggerClientEvent("wrp_drugs:playAnimation", _source, anim)
					playersPickingDrugs[_source] = ESX.SetTimeout(Config.Locations[drugName][proccess].duration, function()
						for k, v in pairs(output) do
							local amount
							if v.max ~= nil then
								amount = math.random(v.amount, v.max)
							else
								amount = v.amount
							end
							if v.item == "cash" then
								xPlayer.addMoney(amount)
							elseif v.item == "black_money" then
								xPlayer.addAccountMoney("black_money", amount)
							else
								xPlayer.addInventoryItem(v.item, amount)
							end
						end

						for z, n in pairs(inputItems) do
							print(json.encode(n))
							if n.name == "cash" then
								xPlayer.removeMoney(n.amount)
							elseif n.name == "black_money" then
								xPlayer.removeAccountMoney("black_money", n.amount)
							else
								xPlayer.removeInventoryItem(n.name, n.amount)
							end
						end
						TriggerClientEvent("wrp_drugs:stopAnimation", _source)
						playersPickingDrugs[_source] = nil
					end)
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = "You don't have enough " .. itemsLacking .."!" })
			end
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = "You're already doing the action!"})
		end

	end
end)


