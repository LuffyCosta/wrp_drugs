Config = {}

Config.minQuantity = 300
Config.maxQuantity = 500
Config.StartTime = 19 -- hour when the drugs appear in town
Config.EndTime = 4 -- hour when the drugs go away
Config.copsNeeded = 2 -- Cop amount to get max amount of items for selling, SET 0 to disable

Config.Locations = {
	["Weed"] = {
		gather = {
			coords = {vector3(481.56, -557.76, 28.5), vector3(460.56, -540.76, 28.5)},			--coords where everything spawns, there can be more that one spot
			text = "[~g~E~s~] Gather",															--3d text
			input = {{item = "bags", amount = 1}},												--input things you can add any amount of different items, as well as any currency
			output ={{item = "cannabis", amount = 1},},											--output things, you can add any amount of different items, as well as any currency
			animation = {library = "anim@heists@ornate_bank@grab_cash_heels", name = "grab"},	--Picking from the thing animation
			propsToSpawn = {{name = 'prop_cratepile_07a_l1', heading = 150.0},},				--props that spawn to cover up the location
			min = 350,																			--amount in the containers are limited for unlimited amounts just set this to -1
			max = 650,																			--amount in the containers are limited for unlimited amounts just set this to -1
			amount = 0,																			--Just a placeholder
			msg = "You started gathering WEED",													--Start message
			duration = 5000																		--action duration
		},
		proccessing = {	
			coords = {vector3(472.69, -1311.4, 29.22)},											--coords where everything spawns, there can be more that one spot
			text = "[~g~E~s~] Proccess",
			input = {{item = "cannabis", amount = 1},{item = "cash", amount = 30, max = 50}},
			output = {{item = "marijuana", amount = 1},},
			animation = {library = "anim@heists@ornate_bank@grab_cash_heels", name = "grab"}, 	--Proccessing animation
			propsToSpawn = {name ='prop_cratepile_07a_l1', heading = 150.0},					--props don't spawn here, gotta clean it all up a little
			amount = 0,
			msg = "You started proccessing WEED",
			duration = 5000
		},
		sell = {
			coords = {}, 																		-- If you want a static zone for sales else players can sell anywhere on the map
			sellZones = { {pos = vector3(57.22, -1888.58, 21.63), dist = 85.0, name = "Grove Street"}, {pos = vector3(1163.72, -496.73, 65.27), dist = 85.0, name ="Mirror parke"}, {pos = vector3(-690.91, -966.45, 19.89), dist = 85.0, name = "Little Seoul"}},
			text = "[~g~E~s~] Sell",
			input = {{item = "marijuana", amount = 1, max = 7}},								--			
			output = {{item = "cash", amount = 300, max = 400}, {item = "black_money", amount = 100, max = 200}},											
			animation = nil,   																	--Hagling animation
			animation2 = {library = "missheistfbisetup1", name = "unlock_loop_janitor"},		--Giving the things animation
			propsToSpawn = {},																	
			amount = 0,
			msg = "You started selling weed",
			haglingduration = 8000,
			duration = 2000                         -- HOW LONG IT TAKES WHEN A PED APPROACHES THE PLAYER
		},
	},
	--[[["Cocaine"] = {
		gather = {
			coords = {vector3(481.56, -557.76, 28.5), vector3(460.56, -540.76, 28.5)},											--coords where everything spawns, there can be more that one spot
			text = "[~g~E~s~] Gather",															--3d text
			input = {{item = "bags", amount = 1}},												--input things you can add any amount of different items, as well as any currency
			output ={{item = "cannabis", amount = 1},},											--output things, you can add any amount of different items, as well as any currency
			animation = {library = "anim@heists@ornate_bank@grab_cash_heels", name = "grab"},	--Picking from the thing animation
			propsToSpawn = {{name = 'prop_cratepile_07a_l1', heading = 150.0},},				--props that spawn to cover up the location
			min = 350,																			--amount in the containers are limited for unlimited amounts just set this to -1
			max = 650,																			--amount in the containers are limited for unlimited amounts just set this to -1
			amount = 0,																			--Just a placeholder
			msg = "You started gathering WEED",														--Start message
			duration = 5000																		--action duration
		},
		proccessing = {	
			coords = {vector3(472.69, -1311.4, 29.22)},											--coords where everything spawns, there can be more that one spot
			text = "[~g~E~s~] Džiovinti",
			input = {{item = "cannabis", amount = 1},{item = "cash", amount = 30, max = 50}},
			output = {{item = "marijuana", amount = 1},},
			animation = {library = "anim@heists@ornate_bank@grab_cash_heels", name = "grab"}, 	--Proccessing animation
			propsToSpawn = {name ='prop_cratepile_07a_l1', heading = 150.0},
			amount = 0,
			msg = "Pradėjote džiovinti žolę",
			duration = 5000
		},
		sell = {
			coords = {}, 																		-- If you want a static zone for sales
			sellZones = { {pos = vector3(57.22, -1888.58, 21.63), dist = 85.0, name = "Grove Street"}, {pos = vector3(1163.72, -496.73, 65.27), dist = 85.0, name ="Mirror parke"}, {pos = vector3(-690.91, -966.45, 19.89), dist = 85.0, name = "Little Seoul"}},
			text = "[~g~E~s~] Parduoti",
			input = {{item = "marijuana", amount = 1, max = 7}},											
			output = {{item = "cash", amount = 300, max = 400}},											
			animation = nil,   --Hagling animation
			animation2 = {library = "missheistfbisetup1", name = "unlock_loop_janitor"},		--Giving the things animation
			propsToSpawn = {},																	
			amount = 0,
			msg = "Pradėjote pardavinėti žolę",
			haglingduration = 8000,
			duration = 2000                         -- HOW LONG IT TAKES WHEN A PED APPROACHES THE PLAYER
		},
	},]]
}

