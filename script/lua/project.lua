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
	exit_standalone_with_esc_key = false,
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

local function spawn_crate()
	print("spawn_crate{")
	local ball_count = SimpleProject.ball_count
	local crate_count = (ball_count / (SimpleProject.base*SimpleProject.base) )
	print("}end-spawn_crate")
end

function spawn_box(createID)
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
	
	-- Network object.
	if (createID) then
	    SimpleProject.config.game_state.createActiveObject(ObjectTypes.box, box_unit)
   end
   return box_unit
end

local function scale( isInflate )
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
		local curr_scale = Unit.local_scale( live_unit, 1 )
		if isInflate then
			new_scale = curr_scale * 1.1
		else
			new_scale = curr_scale * 0.9
		end
		Unit.set_local_scale( live_unit, 1, new_scale )

		-- network update.
		SimpleProject.config.game_state.updateActiveObject(live_unit)
	else
		print "command ignored"
	end
end

local function scale( isInflate )
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
		local curr_scale = Unit.local_scale( live_unit, 1 )
		if isInflate then
			new_scale = curr_scale * 1.1
		else
			new_scale = curr_scale * 0.9
		end
		Unit.set_local_scale( live_unit, 1, new_scale )
	else
		print "command ignored"
	end
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

		-- network update.
		SimpleProject.config.game_state.updateActiveObject(live_unit)
	else
		print "command ignored"
	end
end

local function rotate( quat )
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
		new_rot = Quaternion.multiply(Unit.local_rotation( live_unit, 1 ), quat)
		Unit.set_local_rotation( live_unit, 1, new_rot )
		
		-- network update.
		local networkID = Unit.get_data(live_unit, "networkID")
		SimpleProject.config.game_state.updateActiveObject(live_unit)
	else
		print "command ignored"
	end
end

local function x_rotate()
	rotate( Quaternion.from_euler_angles_xyz( 90, 0, 0) )
	print "x rotate processed"
end

local function y_rotate()
	rotate( Quaternion.from_euler_angles_xyz( 0, 90, 0) )
	print "y rotate processed"
end

local function z_rotate()
	rotate( Quaternion.from_euler_angles_xyz( 0, 0, 90) )
	print "z rotate processed"
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

function spawn_ball(createID)
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
	
	local ball_unit = World.spawn_unit(SimpleProject.world, "content/models/balls/ball_1", pose_zero)

	-- Network object.
	if (createID) then
    	SimpleProject.config.game_state.createActiveObject(ObjectTypes.ball, ball_unit)
    end
    table.insert( SimpleProject.balls, ball_unit )
    return ball_unit
end

-- Optional function called by SimpleProject after world update (we will probably want to split to pre/post appkit calls)
function Project.update(dt)
    
    GameState.update(SimpleProject, dt)
    
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
	local rotateX = nil
	local rotateY = nil
	local rotateZ = nil
	local inflate = nil
	local deflate = nil
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
		local index = Keyboard.button_id("x")
		rotateX = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("y")
		rotateY = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("z")
		rotateZ = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("d")
		deflate = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("i")
		inflate = index and Keyboard.pressed(index) 
	end
	if sphere then
		print ("dt is: "..tostring(dt))
		local ball_unit = spawn_ball(true)
	elseif box then
		print ("dt is: "..tostring(dt))
		local box_unit = spawn_box(true)
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
	elseif rotateX then
		x_rotate()
	elseif rotateY then
		y_rotate()
	elseif rotateZ then
		z_rotate()
	elseif inflate then
		scale( true )
	elseif deflate then
		scale( false )
	else
		return
	end
end

-- Optional function called by SimpleProject *before* appkit/world render
function Project.render()
end

-- Optional function called by SimpleProject *before* appkit/level/player/world shutdown
function Project.shutdown()
    SimpleProject.config.game_state.shutdown(SimpleProject)
end

return Project

