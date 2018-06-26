-- DEBUG
function print_r ( t , player)  
	if player == nil then
		player = game.players[1]
	end	
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            player.print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        player.print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        player.print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        player.print(indent.."["..pos..'] => "'..val..'"')
                    else
                        player.print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                player.print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        player.print(tostring(t).." {")
        sub_print_r(t,"  ")
        player.print("}")
    else
        sub_print_r(t,"  ")
    end
    --player.print("end")
end
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
-- end DEBUG

-- Variables
actions = { type_type = {}, prototype_prototype = {}, type_prototype = {}, prototype_type = {}}
empty = {};
local event_add_settings;
local event_backup = {};


-- Api

map_type_to_type = function ( from , to , action )
	local previous = actions.type_type[from .. "!" .. to]
	if previous ~= nil then
		previous[#previous + 1] = action
	else
		actions.type_type[from .. "!" .. to] = { action }
	end
	
	return #actions.type_type[from .. "!" .. to]
end

map_type_to_prototype = function ( from , to , action )
	local previous = actions.type_prototype[from .. "!" .. to]
	if previous ~= nil then
		previous[#previous + 1] = action
	else
		actions.type_prototype[from .. "!" .. to] = { action }
	end
	
	return #actions.type_prototype[from .. "!" .. to]
end

map_prototype_to_prototype = function ( from , to , action )
	local previous = actions.prototype_prototype[from .. "!" .. to]
	if previous ~= nil then
		previous[#previous + 1] = action
	else
		actions.prototype_prototype[from .. "!" .. to] = { action }
	end
	
	return #actions.prototype_prototype[from .. "!" .. to]
end

map_prototype_to_type = function ( from , to , action )
	local previous = actions.prototype_type[from .. "!" .. to]
	if previous ~= nil then
		previous[#previous + 1] = action
	else
		actions.prototype_type[from .. "!" .. to] = { action }
	end
	
	return #actions.prototype_type[from .. "!" .. to]
end

get_register_event = function()
	if event_add_settings == nil then
		event_add_settings = script.generate_event_name();
	end
	return event_add_settings;
end

remote.add_interface("aps", {
   get_register_event,
   map_prototype_to_prototype,
   map_prototype_to_type,
   map_type_to_prototype,
   map_type_to_type
})

-- API end


-- Local additional paste settings
local assembly_to_inserter = function (from, to, player)

	local ctrl = to.get_or_create_control_behavior()
	
	local c1 = ctrl.get_circuit_network(defines.wire_type.red)
	local c2 = ctrl.get_circuit_network(defines.wire_type.green)
	
	local fromRecipe = from.get_recipe()
	
	if fromRecipe == nil then
		if c1 == nil and c2 == nil then
			ctrl.logistic_condition = nil
			ctrl.connect_to_logistic_network = false
		else
			ctrl.circuit_condition = nil
			ctrl.circuit_mode_of_operation = defines.control_behavior.inserter.circuit_mode_of_operation.none
		end
	else
		local product = fromRecipe.products[1].name
		local item = game.item_prototypes[product]
		
		if item ~= nil then
			local multiplier = settings.get_player_settings(player)["additional-paste-settings-options-inserter-multiplier-value"].value
			if c1 == nil and c2 == nil then
				ctrl.connect_to_logistic_network = true
				ctrl.logistic_condition = {condition={comparator="<", first_signal={type="item", name=product}, constant=multiplier * item.stack_size}}
			else							
				ctrl.circuit_mode_of_operation = defines.control_behavior.inserter.circuit_mode_of_operation.enable_disable
				ctrl.circuit_condition = {condition={comparator="<", first_signal={type="item", name=product}, constant=multiplier * item.stack_size}}
				
			end
			
		end
	end
end

local assembly_to_requester_chest = function (from, to, player)

	event_backup[from.position.x .. "-" .. from.position.y .. "-" .. to.position.x .. "-" .. to.position.y] = {gamer = player.index, stacks = {}}
end

local clear_requester_chest = function (from, to, player)

	if from == to and to.request_slot_count > 0 then
		for i = 1, to.request_slot_count do
			to.clear_request_slot(i)
		end
	end	
end

local clear_inserter_settings = function (from, to, player)

	if from == to then
		local ctrl = to.get_or_create_control_behavior()
		ctrl.logistic_condition = nil
		ctrl.circuit_condition = nil
		ctrl.connect_to_logistic_network = false
		ctrl.circuit_mode_of_operation = defines.control_behavior.inserter.circuit_mode_of_operation.none
	end	
end

local function generateEventIDs()
	get_register_event();
end

-- Local logic

local function register_local_settings()

	map_type_to_type("assembling-machine", "inserter", assembly_to_inserter)
	map_type_to_type("assembling-machine", "logistic-container", assembly_to_requester_chest)
	map_type_to_type("logistic-container", "logistic-container", clear_requester_chest)
	map_type_to_type("inserter", "inserter", clear_inserter_settings)
end

-- Events

local function on_init()
	generateEventIDs()
	
	script.on_event(event_add_settings, register_local_settings)
	
	global.players = {}
end

local function on_load()
	generateEventIDs()
	
	script.on_event(event_add_settings, register_local_settings)
end

local function on_vanilla_pre_paste(event)

	if event.source.type == "assembling-machine" and event.destination.type == "logistic-container" and event.destination.request_slot_count > 0 then
		local evt = event_backup[event.source.position.x .. "-" .. event.source.position.y .. "-" .. event.destination.position.x .. "-" .. event.destination.position.y]
		if evt ~= nil then
			for i=1, event.destination.request_slot_count do
				local j = event.destination.get_request_slot(i)
				if j == nil then
					evt.stacks[i] = empty
				else
					evt.stacks[i] = j
				end
			end
		end
	end
end

local function update_stack(multiplier, stack, previous_value, recipe)
	if recipe == nil then
		if previous_value == nil then
			return game.item_prototypes[stack.name].stack_size * multiplier
		else
			return previous_value + game.item_prototypes[stack.name].stack_size * multiplier
		end
	else
		local amount = 0
		for i=1, #recipe.ingredients do
			if recipe.ingredients[i].name == stack.name then
				amount = recipe.ingredients[i].amount
				break
			end
		end
		if previous_value == nil then
			return amount * multiplier
		else
			return previous_value + amount * multiplier
		end
	end
end

local function on_vanilla_paste(event)

	local evt = event_backup[event.source.position.x .. "-" .. event.source.position.y .. "-" .. event.destination.position.x .. "-" .. event.destination.position.y]

	if evt ~= nil and event.source.type == "assembling-machine" and event.destination.type == "logistic-container" and event.destination.request_slot_count > 0 then
		local result = {}
		local indexes = {}
		local multiplier = settings.get_player_settings(event.player_index)["additional-paste-settings-options-requester-multiplier-value"].value
		local recipe = nil
		if "additional-paste-settings-per-recipe-size" == settings.get_player_settings(event.player_index)["additional-paste-settings-options-requester-multiplier-type"].value then
			recipe = event.source.get_recipe()
		end
		for i=1, #evt.stacks do
			local found = false
			local prior = evt.stacks[i]
			local post = event.destination.get_request_slot(i)
			
			if prior ~= empty then
				if result[prior.name] ~= nil then
					result[prior.name].count = update_stack(multiplier, prior, result[prior.name].count, recipe)
				else
					result[prior.name] = { name = prior.name, count = prior.count }
				end
			end
			
			if post ~= nil then
				if result[post.name] ~= nil then
					result[post.name].count = update_stack(multiplier, post, result[post.name].count, recipe)
				else
					result[post.name] = { name = post.name, count = update_stack(multiplier, post, nil, recipe) }
				end
			end
		end
		local i = 1
		for k, v in pairs(result) do
			if i > event.destination.request_slot_count then
				game.players[evt.gamer].print('Missing space in chest to paste requests')
			else
				event.destination.set_request_slot(v, i)
				i = i + 1
			end
		end
		event_backup[event.source.position.x .. "-" .. event.source.position.y .. "-" .. event.destination.position.x .. "-" .. event.destination.position.y] = nil
	end

end

local function on_hotkey_pressed(event)

	local player = game.players[event.player_index]

	if player ~= nil and player.connected then
	
		local from = player.entity_copy_source
		local to = player.selected
		
		if from ~= nil and to ~= nil then
		
			local key = from.type .. "!" .. to.type
			local act = actions.type_type[key]
			
			if act ~= nil then
				for i=1, #act do
					act[i](from, to, player)
				end
			end
			
			key = from.type .. "!" .. to.prototype.name
			act = actions.type_prototype[key]
			
			if act ~= nil then
				for i=1, #act do
					act[i](from, to, player)
				end
			end
			
			key = from.prototype.name .. "!" .. to.prototype.name
			act = actions.prototype_prototype[key]
			
			if act ~= nil then
				for i=1, #act do
					act[i](from, to, player)
				end
			end
			
			key = from.prototype.name .. "!" .. to.type
			act = actions.prototype_type[key]
			
			if act ~= nil then
				for i=1, #act do
					act[i](from, to, player)
				end
			end
			
			--player.print( "From: type=" .. from.type .. " prototype=" .. from.prototype.name .. " | To: type=" .. to.type .. " prototype=" .. to.prototype.name )
		end
	end
	
	if is_debug then
		--player.print("Fired")
		--print_r(actions, player)
	end
	
end

-- This only fires once a game, when the game starts, every game (including after loading) (TODO: does this works in Multiplayer?)
local function first_tick(event)

	for i=1,#game.players do
		if global.players[game.players[i].name] == nil then
			global.players[game.players[i].name] = 1
		end
	end

	script.raise_event(event_add_settings, {})
	script.on_event(defines.events.on_tick, nil)
end

local function on_player_created(event)
	global.players[game.players[event.player_index]] = 1
end

local function on_player_joined(event)
	if global.players[game.players[event.player_index]] == nil then
		global.players[game.players[event.player_index]] = 1
	end
end

-- Event register

script.on_event(defines.events.on_tick, first_tick)

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_player_joined_game, on_player_joined)

script.on_event("additional-paste-settings-hotkey", on_hotkey_pressed)

script.on_event(defines.events.on_pre_entity_settings_pasted, on_vanilla_pre_paste)
script.on_event(defines.events.on_entity_settings_pasted, on_vanilla_paste)