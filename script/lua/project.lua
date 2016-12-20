-----------------------------------------------------------------------------------
-- This implementation uses the default SimpleProject and the Project extensions are 
-- used to extend the SimpleProject behavior.

local ComponentManager = require 'core/appkit/lua/component_manager'
local Keyboard = stingray.Keyboard
local Quaternion = stingray.Quaternion
local Unit = stingray.Unit
local Util = require 'core/appkit/lua/util'
local World = stingray.World

-- This is the global table name used by Appkit Basic project to extend behavior
Project = Project or {}

require 'script/lua/flow_callbacks'
require 'script/lua/game_state'

Project.level_names = {
	menu = "content/levels/main_menu",
	basic = "content/levels/basic"
}

-- Can provide a config for the basic project, or it will use a default if not.
local SimpleProject = require 'core/appkit/lua/simple_project'
SimpleProject.config = {
	standalone_init_level_name = Project.level_names.basic,
	camera_unit = "core/appkit/units/camera/camera",
	camera_index = 1,
	shading_environment = nil, -- Will override levels that have env set in editor.
	create_free_cam_player = false, -- Project will provide its own player.
	exit_standalone_with_esc_key = false
	game_state = GameState
}

-- This optional function is called by SimpleProject after level, world and player is loaded 
-- but before lua trigger level loaded node is activated.
function Project.on_level_load_pre_flow()
	-- Spawn the player for all non-menu levels. level_name will be nil if this 
	-- is an unsaved Test Level.
	SimpleProject.ball_count = 0
	SimpleProject.box_count = 0
	SimpleProject.liveIsBall = 0
	SimpleProject.liveIsBox = 0
	SimpleProject.balls = {}
	SimpleProject.boxes = {}
	SimpleProject.ball_pos = stingray.Vector3(4.5,2.5,0.15)
	SimpleProject.box_pos = stingray.Vector3(4.5,0.5,0.15)
	SimpleProject.base = 10
	local level_name = SimpleProject.level_name
	if level_name == nil or level_name ~= Project.level_names.menu then
		local view_position = Appkit.get_editor_view_position() or stingray.Vector3(0,-14,4)
		local view_rotation = Appkit.get_editor_view_rotation() or stingray.Quaternion.identity()
		local Player = require 'script/lua/player'
		Player.spawn_player(SimpleProject.level, view_position, view_rotation)
	elseif level_name == Project.level_names.menu then
		local MainMenu = require 'script/lua/main_menu'
		MainMenu.start()
	end
end

-- Optional function by SimpleProject after loading of level, world and player and 
-- triggering of the level loaded flow node.
function Project.on_level_shutdown_post_flow()
end

local function despawn_crate()
	print("despawn_crate{")
	local ball_count = SimpleProject.ball_count
	local crate_count = (ball_count / (SimpleProject.base*SimpleProject.base) )
	print("}end-despawn_crate")
end

local function spawn_crate()
	print("spawn_crate{")
	local ball_count = SimpleProject.ball_count
	local crate_count = (ball_count / (SimpleProject.base*SimpleProject.base) )
	print("}end-spawn_crate")
end

local function despawn_box()
	print("despawn_box{")
	local ball_count = SimpleProject.ball_count
	local box_count = (ball_count / SimpleProject.base )
	local box_mod = box_count % SimpleProject.base
	if box_mod == 0 then
		despawn_crate()
	end
	if box_count > 0 then
		local box_unit = SimpleProject.boxes[box_count]
		if box_unit then
			table.remove( SimpleProject.boxes, box_count )
			local world = SimpleProject.world
			ComponentManager.remove_components(box_unit)
			World.destroy_unit(world, box_unit)
		end
		local i = ball_count
		local numBallsInBox = SimpleProject.base
		local pose_zero = stingray.Vector3(4.5,3.5,0.15)
		-- local pose_zero = SimpleProject.ball_pos
		while (numBallsInBox > 0 ) do
			numBallsInBox = numBallsInBox - 1
			local ball_unit = SimpleProject.balls[i]
			Unit.set_local_position( ball_unit, 1, pose_zero )
			i = i - 1
		end
	end
	print("box_count is "..tostring(box_count))
	print("}end-despawn_box")
end

local function spawn_box()
	print("spawn_box{")
	SimpleProject.liveIsBall = 0
	SimpleProject.liveIsBox = 1
	print "box is live"
	local box_count = SimpleProject.box_count+1
	SimpleProject.box_count = box_count
	-- local init_pos = SimpleProject.ball_pos
	local init_box_pos = stingray.Vector3(4.5,2.3,0.15)
	local final_box_pos = stingray.Vector3(4.5,0.6,0.15+(0.6*(box_count-1)))
	local box_unit = World.spawn_unit(SimpleProject.world, "content/models/box/box", init_box_pos)
	table.insert( SimpleProject.boxes, box_unit )
	local totalSteps = 2
	print("box_count is: "..tostring(box_count))
	print("}end-spawn_box")
end

local function despawn_ball()
	local ball_count = SimpleProject.ball_count
	if ball_count > 0 then
		local ball_unit = SimpleProject.balls[ball_count]
		local ball_mod = ball_count % SimpleProject.base
		--if ball_mod == 0 then
		--	despawn_box()
		--end
		if ball_unit then
			table.remove( SimpleProject.balls, ball_count )
			local world = SimpleProject.world
			ComponentManager.remove_components(ball_unit)
			World.destroy_unit(world, ball_unit)
		end
		ball_count = ball_count - 1
		SimpleProject.ball_count = ball_count
		print "minus processed"
	else
		print "minus ignored"
	end
	print("ball_count is "..tostring(ball_count))
end

local function move( delta )
	live_unit = nil
	if SimpleProject.liveIsBall == 1 then
		print "ball is live"
		local ball_count = SimpleProject.ball_count
		if ball_count > 0 then
			live_unit = SimpleProject.balls[ball_count]
		end
	elseif SimpleProject.liveIsBox == 1 then
		print "box is live"
		local box_count = SimpleProject.box_count
		if box_count > 0 then
			live_unit = SimpleProject.boxes[box_count]
		end
	else
		print "command ignored"
	end
	if live_unit then
		new_pos = Unit.local_position( live_unit, 1 ) + delta
		Unit.set_local_position( live_unit, 1, new_pos )
	else
		print "command ignored"
	end
end

local function old_move( delta )
	local ball_count = SimpleProject.ball_count
	if ball_count > 0 then
		local ball_unit = SimpleProject.balls[ball_count]
		local ball_mod = ball_count % SimpleProject.base
		if ball_unit then
			new_pos = Unit.local_position( ball_unit, 1 ) + delta
			Unit.set_local_position( ball_unit, 1, new_pos )
		end
	else
		print "command ignored"
	end
end

local function down_move()
	move( stingray.Vector3(0,0,-.1) )
	print "down processed"
end

local function up_move()
	move( stingray.Vector3(0,0,.1) )
	print "up processed"
end

local function further_move()
	move( stingray.Vector3(-.1,0,0) )
	print "farther processed"
end

local function closer_move()
	move( stingray.Vector3(.1,0,0) )
	print "closer processed"
end

local function left_move()
	move( stingray.Vector3(0,-.1,0) )
	print "left processed"
end

local function right_move()
	move( stingray.Vector3(0,.1,0) )
	print "right processed"
end

local function spawn_ball()
	print("spawn_ball{")
	SimpleProject.liveIsBall = 1
	print "ball is live"
	SimpleProject.liveIsBox = 0
	-- local pose_zero = SimpleProject.ball_pos
	local pose_zero = stingray.Vector3(4.5,3.5,0.15)
	local ball_count = SimpleProject.ball_count+1
	SimpleProject.ball_count = ball_count
	print("ball_count is "..tostring(ball_count))
	local ball_mod = ball_count % SimpleProject.base
	print("}end-spawn_ball")
	return World.spawn_unit(SimpleProject.world, "content/models/balls/ball_1", pose_zero)
end

-- Optional function called by SimpleProject after world update (we will probably want to split to pre/post appkit calls)
function Project.update(dt)
	if stingray.Window then
		stingray.Window.set_show_cursor(true)
		stingray.Window.set_clip_cursor(false)
	end
	local pos = stingray.Vector3(5.0,-0.5,0.15)
	pos = stingray.Vector3(5.0,-2.0,0.15)
	pos = stingray.Vector3(5.0,-3.5,0.15)
	local sphere = nil
	local box = nil
	local minus = nil
	local up = nil
	local down = nil
	local left = nil
	local right = nil
	local farther = nil
	local closer = nil
	if Util.is_pc() then
		-- check input
		local index = Keyboard.button_id("s")
		sphere = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("b")
		box = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("m")
		minus = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("j")
		down = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("k")
		up = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("h")
		left = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("l")
		right = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("f")
		farther = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("c")
		closer = index and Keyboard.pressed(index) 
	end
	if sphere then
		print ("dt is: "..tostring(dt))
		local ball_unit = spawn_ball()
		table.insert( SimpleProject.balls, ball_unit )
	elseif box then
		print ("dt is: "..tostring(dt))
		local box_unit = spawn_box()
		--table.insert( SimpleProject.boxes, box_unit )
	elseif down then
		down_move()
	elseif up then
		up_move()
	elseif left then
		left_move()
	elseif right then
		right_move()
	elseif farther then
		further_move()
	elseif closer then
		closer_move()
	elseif minus then
		despawn_ball()
	else
		return
	end
end

function printLobbyState(lobby)
    print("state = " .. lobby:state())
    print("host = " .. lobby:lobby_host())
end

-- Built-ins (need them, or you get an asset)
function game_object_created(id, creator_id)
    print("game_object_created " .. tostring(id) .. " " .. tostring(creator_id))
    if (stingray.GameSession.game_object_is_type(SimpleProject.game_session, creator_id, "active_state")) then
        print("*** Created an active_state object")
        v0 = stingray.GameSession.game_object_field(SimpleProject.game_session, creator_id, "guessing_player")
        v1 = stingray.GameSession.game_object_field(SimpleProject.game_session, creator_id, "building_player")
        print("\tguessing_player = " .. tostring(v0))
        print("\tbuilding_player = " .. tostring(v1))
    else
        print("*** Unknown object type created")
    end
end

function game_object_destroyed(id, destroyer_id)
    print("game_object_destroyed " .. tostring(id) .. " " .. tostring(destroyer_id))
end
function game_object_migrated_to_me(id, old_owner_id)
    print("game_object_migrated_to_me " .. tostring(id) .. " " .. tostring(old_owner_id))
end
function game_object_migrated_away(id, new_owner_id)
    print("game_object_migrated_away " .. tostring(id) .. " " .. tostring(new_owner_id))
end
function game_object_sync_done(peer_id)
    print("game_object_sync_done " .. tostring(peer_id))
end
function game_session_disconnect(host_id)
    print("game_session_disconnect " .. tostring(host_id))
end

-- Implemented.
function hello_world()
    print("HELLO WORLD")
end

update_callbacks = {
    ["game_object_created"] = game_object_created,
    ["game_object_destroyed"] = game_object_destroyed,
    ["game_object_migrated_to_me"] = game_object_migrated_to_me,
    ["game_object_migrated_away"] = game_object_migrated_away,
    ["game_object_sync_done"] = game_object_sync_done,
    ["game_session_disconnect"] = game_session_disconnect,
    ["hello_world"] = hello_world
}

-- Optional function called by SimpleProject after world update (we will probably want to split to pre/post appkit calls)
function Project.update(dt)
    
    -- always need to update the network
    stingray.Network.update(dt, update_callbacks)
    
    if (SimpleProject.config.game_state.game_mode == GameModes.lobby) then
        
        -- CREATE CLIENT
        -- When done, SimpleProject.lobby_wait will be non-nil.
        -- Create the client.
        if (SimpleProject.client == nil) then
            print("Creating client.")
            SimpleProject.client = stingray.Network.init_lan_client("network") -- using random client address
            print("Creating browser.")
            SimpleProject.lobby_browser = SimpleProject.client:lobby_browser()
            SimpleProject.lobby_wait = 0
            
            -- TEMP
            int_info = stingray.Network.type_info("MyINT")
            print("int_type:\n")
            for k,v in pairs(int_info) do
                print("key = " .. tostring(k) .. " v = " .. tostring(v))
            end
            
            active_state_info = stingray.Network.object_info("active_state")
            print("active_state:\n")
            for k,v in pairs(active_state_info) do
                print("key = " .. tostring(k) .. " v = " .. tostring(v))
            end
            print("\tfields:")
            for k,v in pairs(active_state_info.fields) do
                print("\tkey = " .. tostring(k) .. " v = " .. tostring(v))
                for k0, v0 in pairs(v) do
                print("\t\tkey = " .. tostring(k0) .. " v = " .. tostring(v0))
                end
            end
        end
        -- Must have a client now, or you're hosed.
        if (SimpleProject.client == nil) then
            error("Couldn't connect to lan-client?")
        end
        
        -- JOIN/CREATE LOBBY
        -- When done, SimpleProject.lobby will be non-nil (also sets is_host true/false)
        -- Attempt to join a lobby (wait 10 seconds, and then create a new one)
        if (SimpleProject.lobby == nil and SimpleProject.lobby_wait ~= nil) then
            SimpleProject.lobby_wait = SimpleProject.lobby_wait + dt

            -- Attempt to join a lobby (wait 'LobbyWaitTime' seconds, and then create a new one)
            if (SimpleProject.lobby_wait >= LobbyWaitTime) then
                -- Done waiting, create a lobby.
                print("!DONE WAITING, creating my own lobby.")
                SimpleProject.lobby = stingray.Network.create_lan_lobby(LANLobbyPort, GameRequiredMembers)
                SimpleProject.lobby:set_game_session_host(SimpleProject.lobby:members()[1]) -- set the lobby creator to the host
                SimpleProject.is_host = true
            else
                if (SimpleProject.lobby_browser:num_lobbies() > 0) then
                    lobby_info = SimpleProject.lobby_browser:lobby(1)
                    print("!WE FOUND A LOBBY: " .. lobby_info.address)
                    SimpleProject.lobby = stingray.Network.join_lan_lobby(lobby_info.address) -- should use random port?
                    SimpleProject.is_host = false
                elseif (not SimpleProject.lobby_browser:is_refreshing()) then
                    print("Refressing lobby")
                    SimpleProject.lobby_browser:refresh(LANLobbyPort)
                end
            end
        
            -- If there is a lobby, kill the wait_time
            if (SimpleProject.lobby ~= nil) then
                printLobbyState(SimpleProject.lobby)
                SimpleProject.lobby_wait = nil
                SimpleProject.print_wait = 0
            else
                return
            end
        end

        -- WAIT FOR COMPLETION (host adds peers to game session)
        if (SimpleProject.game_session == nil and table.getn(SimpleProject.lobby:members()) == GameRequiredMembers) then
            print("!WE HAVE " .. table.getn(SimpleProject.lobby:members()) .. " Members now. START!")

            -- Everybody creates the game session
            SimpleProject.game_session = stingray.Network.create_game_session()
            
            -- The host is the one that adds the members, and creates the initial objects.
            if (SimpleProject.is_host) then
                -- Create the session, and add everybody in the lobby.
                SimpleProject.game_session:make_game_session_host()
                local members = SimpleProject.lobby:members()
                for i, peer in ipairs(members) do 
                    if (i ~= 1) then  -- don't add us, joined automatically
                        print("Adding: " .. peer)
                        SimpleProject.game_session:add_peer(peer)
                    end
                end
            
                -- Create the synchronized object state.
                -- NOTE: Guessing player always host, and starting other player always the next (assume at least two players)
                SimpleProject.active_state = stingray.GameSession.create_game_object(SimpleProject.game_session, "active_state", 
                    { guessing_player = 1, building_player = 2 } )

                -- Remove all the lobby/etc members
                SimpleProject.lobby = nil
                SimpleProject.lobby_browser = nil
            end
            
            -- Everybody goes into the next state of the game now.
            SimpleProject.config.game_state.game_mode = GameModes.active
        else
            -- Still waiting for correct number of players
            SimpleProject.print_wait = SimpleProject.print_wait + dt
            if (SimpleProject.print_wait > 1) then
                if (SimpleProject.game_session == nil) then
                    print ("!WE HAVE " .. table.getn(SimpleProject.lobby:members()) .. " Members now. Waiting for " .. GameRequiredMembers)
                    printLobbyState(SimpleProject.lobby)
                end
                SimpleProject.print_wait = 0
            end
        end
    elseif(SimpleProject.config.game_state.game_mode == GameModes.active) then
        if (SimpleProject.game_session:in_session() and not SimpleProject.send_hello) then
            print("In state: Active")
            for i,peer in ipairs(SimpleProject.game_session:other_peers()) do
                print("peer = " .. tostring(peer))
                stingray.RPC.hello_world(tostring(peer))
            end
            SimpleProject.send_hello = 1
        end
    end
end

-- Optional function called by SimpleProject *before* appkit/world render
function Project.render()
end

-- Optional function called by SimpleProject *before* appkit/level/player/world shutdown
function Project.shutdown()
end

return Project

