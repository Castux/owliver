love.filesystem.include("menu.lua")
love.filesystem.include("game.lua")


-- this function changes to the given game mode
-- all modes have to be done as tables containing the
-- usual callbacks.

-- the "or no_op" is important, if a callback is not implemented in one mode,
-- there is no call to nil

function set_game_mode(mode)
	
	load = mode.load or no_op
	update = mode.update or no_op
	draw = mode.draw or no_op
	mousepressed = mode.mousepressed or no_op
	mousereleased = mode.mousereleased or no_op
	keypressed = mode.keypressed or no_op
	keyreleased = mode.keyreleased or no_op
	
	mode.load()
end

function no_op() end

-- setting initial game mode

set_game_mode(menu)
