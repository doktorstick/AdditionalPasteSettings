-- DEBUG
function print_r ( t , player)  
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
    player.print("end")
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
stacks_size = { 0.1, 0.25, 0.5, 1, 2, 3, 4, 5, 10 }
local event_add_settings;

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
local assembly_to_inserter = function (from, to, player, multiplier)
	local ctrl = to.get_or_create_control_behavior()
	
	local c1 = ctrl.get_circuit_network(defines.wire_type.red)
	local c2 = ctrl.get_circuit_network(defines.wire_type.green)
	
	local product = from.recipe.products[1].name
	local item = game.item_prototypes[product]
	
	if item ~= nil then
		if c1 == nil and c2 == nil then			
			ctrl.connect_to_logistic_network = true
			ctrl.logistic_condition = {condition={comparator="<", first_signal={type="item", name=product}, constant=multiplier * item.stack_size}}
		else							
			ctrl.circuit_mode_of_operation = defines.control_behavior.inserter.circuit_mode_of_operation.enable_disable
			ctrl.circuit_condition = {condition={comparator="<", first_signal={type="item", name=product}, constant=multiplier * item.stack_size}}
			
		end
		
	end
end

local function generateEventIDs()
	get_register_event();
end

-- Local logic

local function register_local_settings()

	--for k in pairs(game.entity_prototypes) do
		--if string.find(k, "assembling-machine", 1, true) ~= nil then
			map_type_to_type("assembling-machine", "inserter", assembly_to_inserter)
		--end
	--end
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

local function on_options_pressed(event)

	local player = game.players[event.player_index]
	
	if player ~= nil and player.connected then
	
		local current_stack = global.players[player.name]

		if current_stack == nil then
			current_stack = 1
		else
			local k
			for i=0,#stacks_size do
				if stacks_size[i] == current_stack then
					k = i + 1
				end
			end
			
			if k > #stacks_size then
				k = 1
			end
			
			current_stack = stacks_size[k]
		end
		
		player.print("Additional Paste Settings: Your stack size multiplayer has been changed to: " .. current_stack)
		
		global.players[player.name] = current_stack
	
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
			local multiplier = global.players[player.name]
			
			if act ~= nil then
				for i=1, #act do
					act[i](from, to, player, multiplier)
				end
			end
			
			key = from.type .. "!" .. to.prototype.name
			act = actions.type_prototype[key]
			
			if act ~= nil then
				for i=1, #act do
					act[i](from, to, player, multiplier)
				end
			end
			
			key = from.prototype.name .. "!" .. to.prototype.name
			act = actions.prototype_prototype[key]
			
			if act ~= nil then
				for i=1, #act do
					act[i](from, to, player, multiplier)
				end
			end
			
			key = from.prototype.name .. "!" .. to.type
			act = actions.prototype_type[key]
			
			if act ~= nil then
				for i=1, #act do
					act[i](from, to, player, multiplier)
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

	game.raise_event(event_add_settings, {})
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

script.on_event("additional-paste-settings-options-hotkey", on_options_pressed)