-- main.lua
local love = require("love")
local Player = require("source/Player")
local Enemy = require("source/Enemy")

function love.load()
	love.window.setTitle("PixelValor")
	anim8 = require("libraries/anim8")
	love.graphics.setDefaultFilter("nearest", "nearest")

	camera = require("libraries/camera")
	cam = camera()

	sti = require("libraries/sti")
	gameMap = sti("maps/map.lua")

	-- Initialize player
	player = Player:new("sprites/char_1.png", 100, 250)

	-- Initialize projectile table

	enemies = {}
	table.insert(enemies, Enemy:new(700, 200))
	table.insert(enemies, Enemy:new(300, 300))

	sounds = {}
	sounds.music = love.audio.newSource("sounds/field_theme_1.wav", "stream")
	sounds.music:setLooping(true)

	sounds.music:play()
end

function love.update(dt)
	if player.health <= 0 then
		return -- Skip updating if player is dead
	end
	gameMap:update(dt)
	player:update(dt)

	-- update enemies
	for i = #enemies, 1, -1 do
		local enemy = enemies[i]
		enemy:update(dt)
		if enemy.toBeRemoved then
			table.remove(enemies, i)
		end
	end

	cam:lookAt(player.x, player.y)

	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	if cam.x < w / 2 then
		cam.x = w / 2
	end
	if cam.y < h / 2 then
		cam.y = h / 2
	end

	local mapW = gameMap.width * gameMap.tilewidth
	local mapH = gameMap.height * gameMap.tileheight

	if cam.x > (mapW - w / 2) then
		cam.x = (mapW - w / 2)
	end

	if cam.y > (mapH - h / 2) then
		cam.y = (mapH - h / 2)
	end
end

function love.keypressed(key)
	if player.health <= 0 and key == "r" then
		player = Player:new("sprites/4.png", 100, 250)
		return
	end
	if key == "space" then
		player:attack(enemies)
	end
end

function love.draw()
	if player.health <= 0 then
		love.graphics.setColor(1, 0, 0)
		love.graphics.printf(
			"Game Over - Press 'R' to Respawn",
			0,
			love.graphics.getHeight() / 2 - 10,
			love.graphics.getWidth(),
			"center"
		)
		love.graphics.setColor(1, 1, 1)
		return
	end

	cam:attach()
	gameMap:drawLayer(gameMap.layers["Ground"])
	gameMap:drawLayer(gameMap.layers["Props"])
	gameMap:drawLayer(gameMap.layers["Man"])
	gameMap:drawLayer(gameMap.layers["Road"])
	player:draw()

	for _, enemy in ipairs(enemies) do
		enemy:draw()
	end
	cam:detach()
end
