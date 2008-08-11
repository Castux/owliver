--[[
	Copyright © 2008 Noé Falzon

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

-- game mode "namespace"

game = {}

function game.load()
	
	-- Stuff
	
	math.randomseed(os.time())

	-- Graphic settings
	
	love.graphics.setBackgroundColor(208, 243, 255)

	
	clouds = love.graphics.newImage("clouds.png")
	clouds:setCenter(clouds:getWidth()/2, clouds:getHeight())
	
	admitted = love.graphics.newImage("admitted.png")
	blood = love.graphics.newImage("blood.png")
	blood:setCenter(blood:getWidth()/2, -25)
	dead_msg = love.graphics.newImage("deadmess.png")
	
	win_img = love.graphics.newImage("win.png")
	
	-- Font settings
	font_big = love.graphics.newFont(love.default_font, 32)
	font_small = love.graphics.newFont(love.default_font, 18)

	love.graphics.setColor(0,0,0)
	love.graphics.setFont(font_small)

	-- make a trooper
	
	initx, inity = 400, 0
	
	trooper_img = love.graphics.newImage("trooper.png")
	
	trooper = {}
	trooper.img = trooper_img
	trooper.x, trooper.y = initx, inity
	trooper.vx = 0
	trooper.vy = 0
	trooper.dir = 1		-- 1 is right, -1 is left
	trooper.thrust = false


	-- camera stuff
	cam = {}
	cam.x = 0
	cam.y = 0
	cam.rel = function(x,y)
		return (x - cam.x), (y - cam.y)
	end
	
	-- levels
	love.filesystem.include("levels.lua")
	
	l_levels = {}	-- loaded levels
	base_y = 600
	
	for i,l in ipairs(levels) do
		l_levels[i] = load_level(l)
		l_levels[i].y_offset = base_y
		base_y = l_levels[i].ofs - 2*l_levels[i].bg:getHeight()		-- bg are drawn twice the size
	end
	
	inside_level = 1
	level_end = false


	-- sound
	snd = {}
	
	snd.spawn = love.audio.newSound("spawn.wav")
	snd.jet = love.audio.newSound("jet.wav")
	snd.fix = love.audio.newSound("fix.wav")
	snd.level = love.audio.newSound("level.wav")
	snd.dead = love.audio.newSound("dead.wav")
	snd.denied = love.audio.newSound("denied.wav")
	
	snd.deathsong = love.audio.newSound("death.ogg")
	snd.music = love.audio.newSound("music.ogg")
	
	snd.jet:setVolume(0.2)
	
	love.audio.play(snd.music,0)
	
	last_thsound = love.timer.getTime()
end

function new_gimmick(x,y,kind)

	local g = {}
	g.x = x or 0
	g.y = y or 0
	
	g.state = false		-- false needs to be switched. true is already switched
	g.kind = kind
	
	g.timer = nil
	
	return g
end

function new_floor(x,y,w)

	local f = {}
	f.x = x or 0
	f.y = y or 0
	f.w = w or 200
		
	return f
end

function game.update(dt)
	
	local y_accel = 0
	local x_accel = 0
	collide = false
	
	
	-- gravity for the trooper
	y_accel = y_accel + 1500
	
	
	-- Fernando class propeller
	
	trooper.thrust = false
	
	if love.keyboard.isDown(love.key_up) then
		y_accel = y_accel - 3000
		trooper.thrust = true
	end
	
	if love.keyboard.isDown(love.key_down) then
		y_accel = y_accel + 3000	-- debug purpose only
		trooper.thrust = true
	end
	
	if love.keyboard.isDown(love.key_left) then
		x_accel = x_accel - 1000
		trooper.dir = -1
		trooper.thrust = true
	end
	
	if love.keyboard.isDown(love.key_right) then
		x_accel = x_accel + 1000
		trooper.dir = 1
		trooper.thrust = true
	end
	
	local now = love.timer.getTime()
	
	if not dead and trooper.thrust then
		if last_thsound and (now - last_thsound > 0.25) then
			love.audio.play(snd.jet)
			last_thsound = love.timer.getTime()
		end
	end
	
	local friction = 0.995
	trooper.vy = trooper.vy * friction + y_accel * dt
	trooper.vx = trooper.vx * friction + x_accel * dt
	
	if trooper.vy < -1000 then
		trooper.vy = -1000
	end
	
	
	local oldx, oldy = trooper.x, trooper.y
	
	if not dead then
		-- trooper position
		
		trooper.x = trooper.x + trooper.vx * dt
		trooper.y = trooper.y + trooper.vy * dt
	
		-- trooper cannot go out of the game
		if trooper.y >= 580 then
			trooper.y = 580
			trooper.vy = 0
		end
	
		local margin = 380
		if trooper.x >= 1680 + margin then
			trooper.x = 1680 + margin
			trooper.vx = 0
		elseif trooper.x < -margin then
			trooper.x = -margin
			trooper.vx = 0
		end
	end
	
	close_gims = {}
	
	for _,curr_lev in pairs(l_levels) do
	
		-- trooper cannot go through floors
		for _,floor in pairs(curr_lev.floors) do
		
			if floor_collision(trooper.x, trooper.y, trooper.img, floor) then
				if trooper.vx * trooper.vx + trooper.vy * trooper.vy > 1500000 then
					trooper.img = blood
					dead = true
					love.audio.play(snd.dead)
					love.audio.pause()
					love.audio.play(snd.deathsong)
				end
			
				collide = "floor"
				trooper.vx = 0
				trooper.vy = 0
				trooper.x, trooper.y = oldx, oldy
			end
		end
	
		-- check also gimmicks proximity
		for _,gim in pairs(curr_lev.gimmicks) do
		
		--	if collision(trooper.x, trooper.y, trooper.img, gim.x, gim.y, gim.kind.ok) then
			if distance(trooper.x, trooper.y, gim.x, gim.y) < 50 then
				collide = "gimmick"
				table.insert(close_gims, gim)
			end
		end
	end
	
	-- check gimmicks timers
	
	local now = love.timer.getTime()
	local ok_delay = levels[inside_level].respawn
	
	if not level_end then for _,g in pairs(l_levels[inside_level].gimmicks) do
	
		if g.state == true and (now - g.timer > ok_delay) then
					
			g.state = false		-- break again...
			l_levels[inside_level].remain = l_levels[inside_level].remain + 1
			
			love.audio.play(snd.spawn)
		end
	end end
	
	
	
	
	-- check next inside_level or not
	
	local i_lev = l_levels[inside_level]
	
	if trooper.y < i_lev.ofs - 2*i_lev.bg:getHeight() then
		if level_end and inside_level < 7 then
			inside_level = inside_level + 1
			level_end = false
		else
			trooper.y = i_lev.ofs - 2*i_lev.bg:getHeight() - 1
			trooper.vy = 900
			love.audio.play(snd.denied)
		end
	end
	
	
	-- update camera
	
	local cam_speed = 7
	
	cam.y = cam.y - (cam.y - trooper.y + 300) * cam_speed * dt	-- awesome smooth movement
	if cam.y > 0 then cam.y = 0 end
	
	local cam_margin = 400
	cam.x = cam.x - (cam.x - trooper.x + 400) * cam_speed * dt	-- awesome smooth movement
	--[[if cam.x < -cam_margin then cam.x = -cam_margin
	elseif cam.x > 1680 + cam_margin then cam.x = 1680 + cam_margin end]]
	
	
	-- check end of level condition
	
	if (not level_end) and l_levels[inside_level].remain == 0 then
		level_end = true
		love.audio.play(snd.level)
	end
	
	if level_end and inside_level == 7 then
	
		end_game = true	
	end
	
	-- update animations
	
	elec.nok:update(dt)
	
end


function game.keypressed(key)

	if key == love.key_space then
		for _,g in pairs(close_gims) do
			if not g.state then	-- fixing stuff!
				g.state = true
				g.timer = love.timer.getTime()
				l_levels[inside_level].remain = l_levels[inside_level].remain - 1
				
				love.audio.play(snd.fix)
			end
		end
	end
	
	-- CHEATING!!! (but also debugging...)
	if key == love.key_a and love.keyboard.isDown(love.key_p) and love.keyboard.isDown(love.key_n) then
	
		inside_level = inside_level + 1
		if inside_level > 7 then inside_level = 7 end
		level_end = false
	end
end


function collision(x, y, img, x2, y2, img2)
	
	local l,r,u,d
	local L,R,U,D
	
	l = x - img:getWidth()/2
	r = x + img:getWidth()/2
	u = y - img:getHeight()/2
	d = y + img:getHeight()/2
	
	L = x2 - img2:getWidth()/2
	R = x2 + img2:getWidth()/2
	U = y2 - img2:getHeight()/2
	D = y2 + img2:getHeight()/2
	
	if d < U then return false end
	if D < u then return false end
	
	if r < L then return false end
	if R < l then return false end
	
	return true
end

function floor_collision(x, y, img, floor)

	local l,r,u,d
	local L,R,U,D
	
	l = x - img:getWidth()/2
	r = x + img:getWidth()/2
	u = y - img:getHeight()/2
	d = y + img:getHeight()/2
	
	L = floor.x - floor.w/2
	R = floor.x + floor.w/2
	U = floor.y
	D = floor.y
	
	if d < U then return false end
	if D < u then return false end
	
	if r < L then return false end
	if R < l then return false end
	
	return true

end

function distance(x, y, X, Y)

	return math.sqrt( (X-x)*(X-x) + (Y-y)*(Y-y) )
end


function game.draw()

	local x,y
	
	-- sky color : at -17000 it's blue, at 600 it's dark blue
		
	local tau = (trooper.y + 17000) / (600 + 17000)		-- 0 at top
	
	local r,v,b = 0, 0, 120		-- dark blue
	local R,V,B = 194, 243, 255	-- blue
	
	love.graphics.setBackgroundColor(R + tau*(r-R), V + tau*(v-V), B + tau*(b-B))
	
	love.graphics.draw(clouds, 400, 600 + (1-tau) * (clouds:getHeight() - 600) )
	
	for i,curr_lev in pairs(l_levels) do
				
		-- background  TODO: might want to add a static bg, for parallax scrolling madness
		x,y = cam.rel(0, curr_lev.ofs)
		love.graphics.draw(curr_lev.bg, x, y, 0, 2)
	
		--[[ floors
		for _,floor in pairs(curr_lev.floors) do
	
			x,y = cam.rel(floor.x, floor.y)
			love.graphics.line( x - floor.w/2, y, x + floor.w/2, y )
		end]]
	
		-- gimmicks
		for _,gim in pairs(curr_lev.gimmicks) do
		
			x,y = cam.rel(gim.x, gim.y)
			if gim.state then
				love.graphics.draw(gim.kind.ok, x, y)
			else
				love.graphics.draw(gim.kind.nok, x, y)
			end
		end
	
	end
	
	
	-- draw trooper
	x,y = cam.rel(trooper.x, trooper.y)
	if not dead then love.graphics.draw(trooper.img, x, y, 0, trooper.dir, 1)
		else love.graphics.draw(trooper.img, x, y) end
	
	-- level info
	if level_end then
		if end_game then
			love.graphics.draw(win_img, 400, 300)
		else
			love.graphics.draw(admitted, 400, 300)
		end
	end
	
	love.graphics.draw(levels[inside_level].name, 20, 40)
	love.graphics.draw("Remaining stuff: " .. l_levels[inside_level].remain, 20, 60)
	
	if dead then
		love.graphics.draw(dead_msg, 400, 300)
	end
	
	
	-- some debug info

--	love.graphics.draw(trooper.x .. ";" .. trooper.y .. ";" .. cam.y , 20, 20)
--	if collide then love.graphics.draw(collide, 20, 40) end
--	if level_end then love.graphics.draw("end level", 20, 100) end

--	love.graphics.draw("inside_level : " .. inside_level, 20, 80)

end

function game.mousepressed(x, y, button)
	
	if dead then
		dead = false
		
		inside_level = 1
		
		for _,curr_lev in pairs(l_levels) do
			
			-- remain
			
			curr_lev.remain = #curr_lev.gimmicks
		
			-- reset gimmicks
			for _,gim in pairs(curr_lev.gimmicks) do
				gim.state = false
			end
		end
		
		trooper.x, trooper.y = initx, inity
		trooper.img = trooper_img
		
		love.audio.pause()
		love.audio.play(snd.music,0)
	end
	
	if end_game then
		love.system.exit()
	end

end



