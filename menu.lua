-- game mode "namespace"
menu = {}

function menu.load()

	-- setup
	math.randomseed(os.time())
	
	page = love.graphics.newImage("intropage.png")
	muzik = love.audio.newMusic("intro.ogg")
	love.audio.play(muzik, 0)
	
end

function menu.draw()
	
	for i = 0,79 do for j = 0,59 do
	
		local c = math.random(0,50)+200
		love.graphics.setColor(c, c, c)
	
		love.graphics.rectangle(love.draw_fill, i*10, j*10, 10, 10)
	end end
	
	love.graphics.draw(page, 400, 300)
	
end

function menu.mousepressed(x, y, button)
	
	love.audio.stop()
	set_game_mode(game)
end


