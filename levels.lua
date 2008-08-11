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


-- gimmicks

crack = {
	
	nok = love.graphics.newImage("crack.png"),
	ok = love.graphics.newImage("crack2.png")
}

glass = {
	
	nok = love.graphics.newImage("glass.png"),
	ok = love.graphics.newImage("glass2.png")
}

elec = {
	
	dummy = love.graphics.newImage("elec.png"),
	ok = love.graphics.newImage("transp.png")	
}

elec.nok = love.graphics.newAnimation(elec.dummy, 100, 100, 0.1)

-- levels data

levels = {}


levels[1] = {
	
	name = "Technical levels",
	bg = "lev1.png",
	
	floors = {
		{120, 1238, 1469}
	},

	gimmicks = {
		{474, 940, crack},
		{643, 365, crack},
		{896, 1046, crack},
		{1203, 1011, crack},
		{1080, 587, crack},
		{1274, 2159, crack},
		{1322, 1314, crack},
		{639, 1866, crack},
		{374, 1470, crack},
		{858, 1631, crack}
		
	},
	
	respawn = 30,
	y = 0
}

levels[2] = {
	
	name = "Business district",
	bg = "lev2.png",
	
	floors = {
		{27, 451, 1557},
		{106, 708, 420},
		{1160, 999, 395},
		{1160, 1283, 395},
		{1160, 1574, 395},
		{1160, 1823, 395},
		{49, 1784, 395},
		{3, 2849, 1666}
	},

	gimmicks = {
		{1379, 669, crack},
		{253, 548, crack},
		{279, 1969, elec},
		{1499, 1753, elec},
		{1526, 1943, elec}	
	},
	
	respawn = 30,
	y = 80
}

levels[3] = {
	
	name = "Residential area",
	bg = "lev3.png",
	
	floors = {
		{145, 442, 746},
		{145, 822, 746},
		{145, 1225, 746},
		{145, 1596, 746},
		{145, 1993, 746},
		{1265, 442, 403},
		{1162, 1905, 495},
		{828, 2673, 372}
	},

	gimmicks = {
		{413, 602, elec},
		{613, 1762, elec},
		{1342, 2433, elec},
		{1576, 916, crack},
		{1445, 2116, crack},
		{559, 928, crack},
		{242, 2105, crack}
	},
	
	respawn = 29,
	y = 6
}

levels[4] = {
	
	name = "Bolts factory",
	bg = "lev4.png",
	
	floors = {
		{360, 0, 810},
		{1069, 691, 327},
		{1065, 1121, 318},
		{609, 1735, 387},
		{360, 2026, 810}
	},

	gimmicks = {
		{494, 2153, elec},
		{1084, 2072, elec},
		{979, 375, elec},
		{712, 2100, crack},
		{819, 1959, crack},
		{470, 1343, crack},
		{1108, 947, crack}
	},
	
	respawn = 22,
	y = 0
}

levels[5] = {
	
	name = "Commercial segment",
	bg = "lev5.png",
	
	floors = {
		{150, 125, 1301},
		{179, 885, 812},
		{645, 1102, 772},
		{793, 1610, 635},
		{290, 1645, 81},
		{962, 2242, 501}
	},

	gimmicks = {
		{1259, 1730, elec},
		{85, 1479, elec},
		{528, 1345, elec},
		{133, 1185, elec},
		{925, 1193, elec},
		{830, 790, crack},
		{308, 322, crack}
	},
	
	respawn = 18,
	y = 74
}

levels[6] = {
	
	name = "Arboretum",
	bg = "lev6.png",
	
	floors = {
		{282, 381, 1186},
		{167, 1482, 170}
	},

	gimmicks = {
		{662, 1743, glass},
		{1080, 1514, glass},
		{553, 1217, glass},
		{643, 585, glass},
		{925, 1193, glass},
		{209, 1553, elec}
	},
	
	respawn = 10,
	y = 70
}

levels[7] = {
	
	name = "Luxury Plaza",
	bg = "lev7.png",
	
	floors = {
		{193, 553, 358},
		{1031, 581, 328},
		{175, 1189, 1146}
	},

	gimmicks = {
		{1130, 686, crack},
		{785, 848, crack},
		{443, 708, crack},
		{888, 2052, elec},
		{1353, 2104, elec},
		{212, 1785, glass},
	},
	
	respawn = 10,
	y = 0

}




-- turns the data tables into playable levels

function load_level(dat)
	
	local ofs = base_y + dat.y
	
	local lev = {}
	
	lev.bg = love.graphics.newImage(dat.bg)
	lev.bg:setCenter(0, lev.bg:getHeight())
	
	lev.floors = {}
	for _,f in pairs(dat.floors) do
		table.insert(lev.floors, new_floor(inkscape_to_love_floors(ofs, f[1], f[2], f[3])))
	end
	
	lev.gimmicks = {}
	for _,g in pairs(dat.gimmicks) do
		local x,y = inkscape_to_love(ofs, g[1], g[2])
		table.insert(lev.gimmicks, new_gimmick(x, y, g[3]))
	end	

	lev.remain = #lev.gimmicks

	lev.ofs = ofs

	
	return lev
end

function inkscape_to_love(ofs, x, y)
	
	return x, (ofs - y)
end

function inkscape_to_love_floors(ofs, x, y, w)

	return (x + w/2), (ofs - y), w
end
