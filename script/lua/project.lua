-----------------------------------------------------------------------------------
-- This implementation uses the default SimpleProject and the Project extensions are 
-- used to extend the SimpleProject behavior.

-- This is the global table name used by Appkit Basic project to extend behavior
Project = Project or {}

require 'script/lua/flow_callbacks'
require 'script/lua/game_state'

Project.level_names = {
	empty = "content/levels/empty"
}

-- Can provide a config for the basic project, or it will use a default if not.
local SimpleProject = require 'core/appkit/lua/simple_project'
SimpleProject.config = {
	standalone_init_level_name = Project.level_names.empty,
	camera_unit = "core/appkit/units/camera/camera",
	camera_index = 1,
	shading_environment = nil, -- Will override levels that have env set in editor.
	create_free_cam_player = true, -- Project will provide its own player.
	exit_standalone_with_esc_key = true,
	game_state = GameState
}

-- Optional function by SimpleProject after level, world and player is loaded 
-- but before lua trigger level loaded node is activated.
function Project.on_level_load_pre_flow()
end

-- Optional function by SimpleProject after loading of level, world and player and 
-- triggering of the level loaded flow node.
function Project.on_level_shutdown_post_flow()
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

function request_name()
    --(id, name)
    stingray.RPC.receive_name(1, "name")
end

function receive_name(id, name)
    print(id .. ' ' .. name)    
end

update_callbacks = {
    ["game_object_created"] = game_object_created,
    ["game_object_destroyed"] = game_object_destroyed,
    ["game_object_migrated_to_me"] = game_object_migrated_to_me,
    ["game_object_migrated_away"] = game_object_migrated_away,
    ["game_object_sync_done"] = game_object_sync_done,
    ["game_session_disconnect"] = game_session_disconnect,
    ["hello_world"] = hello_world,
    ["request_name"] = request_name,
    ["receive_name"] = receive_name
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

