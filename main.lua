-- main.lua
local love = require("love")
local Player = require("source/Player")
local Projectile = require("source/Projectile")

function love.load()
	love.window.setTitle("PixelValor")
	anim8 = require("libraries/anim8")
	love.graphics.setDefaultFilter("nearest", "nearest")

	camera = require("libraries/camera")
	cam = camera()

	sti = require("libraries/sti")
	gameMap = sti("maps/testMap.lua")

	-- Initialize player
	player = Player:new("sprites/4.png", 300, 400)

	-- Initialize projectile table
	projectiles = {}
	projectileSpeed = 300
end

function love.update(dt)
	gameMap:update(dt)
	player:update(dt)

	-- Update projectiles
	for i = #projectiles, 1, -1 do
		local projectile = projectiles[i]
		projectile:update(dt)

		-- Remove projectiles if animation is finished
		if projectile:isFinished() then
			table.remove(projectiles, i)
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
	if key == "space" then
		player:attack()

		-- Create a new projectile
		local direction = player.isFacingRight and 1 or -1
		table.insert(
			projectiles,
			Projectile:new(
				player.spriteSheet,
				player.grid,
				player.x + (direction * 32),
				player.y,
				direction,
				projectileSpeed
			)
		)
	end
end

function love.draw()
	cam:attach()
	gameMap:drawLayer(gameMap.layers["Ground"])
	gameMap:drawLayer(gameMap.layers["Trees"])
	player:draw()

	-- Draw projectiles
	for _, projectile in ipairs(projectiles) do
		projectile:draw()
	end
	cam:detach()
end
