local love = require("love")

function love.load()
	anim8 = require("libraries/anim8")
	love.graphics.setDefaultFilter("nearest", "nearest")

	camera = require("libraries/camera")
	cam = camera()

	sti = require("libraries/sti")
	gameMap = sti("maps/testMap.lua")

	player = {}

	player.x = 300
	player.y = 400
	player.speed = 100
	player.isAttacking = false

	player.spriteSheet = love.graphics.newImage("sprites/4.png")
	player.grid = anim8.newGrid(64, 64, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

	player.animations = {}
	player.animations.idle = anim8.newAnimation(player.grid("1-6", 1), 0.2)
	player.animations.walkRight = anim8.newAnimation(player.grid("1-6", 2), 0.2)
	player.animations.die = anim8.newAnimation(player.grid("1-6", 3), 0.2)
	player.animations.attack = anim8.newAnimation(player.grid("1-6", 4), 0.1)

	player.anim = player.animations.idle
	player.isFacingRight = true

	-- projectile animation (row 6, columns 1-6)
	projectileAnimation = anim8.newAnimation(player.grid("1-6", 6), 0.3)

	-- Initialize projectiles table
	projectiles = {}
	projectileSpeed = 300
end

function love.update(dt)
	gameMap:update(dt)

	if not player.isAttacking then
		local isMoving = false
		if love.keyboard.isDown("w") then
			isMoving = true
			player.y = player.y - player.speed * dt
			player.anim = player.animations.walkRight
		end
		if love.keyboard.isDown("s") then
			isMoving = true
			player.y = player.y + player.speed * dt
			player.anim = player.animations.walkRight
		end
		if love.keyboard.isDown("d") then
			isMoving = true
			player.x = player.x + player.speed * dt
			player.anim = player.animations.walkRight
			player.isFacingRight = true
		end
		if love.keyboard.isDown("a") then
			isMoving = true
			player.x = player.x - player.speed * dt
			player.anim = player.animations.walkRight
			player.isFacingRight = false
		end
		if isMoving == false then
			player.anim = player.animations.idle
		end
	else
		if player.animations.attack.position == #player.grid("1-6", 4) then
			player.isAttacking = false
			player.anim = player.animations.idle
		end
	end
	player.anim:update(dt)

	-- Update projectiles
	for i = #projectiles, 1, -1 do
		local projectile = projectiles[i]
		projectile.x = projectile.x + projectile.speed * dt
		projectile.animation:update(dt)

		-- Remove projectiles if it goes off-screen
		if projectile.animation.status == "finished" then
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
		player.isAttacking = true
		player.anim = player.animations.attack
		player.anim:gotoFrame(1)

		-- Create a new projectile with animation
		local direction = player.isFacingRight and 1 or -1
		table.insert(projectiles, {
			x = player.x + (direction * 32),
			y = player.y,
			speed = projectileSpeed * direction,
			animation = projectileAnimation:clone(),
		})
	end
end

function love.draw()
	cam:attach()
	gameMap:drawLayer(gameMap.layers["Ground"])
	gameMap:drawLayer(gameMap.layers["Trees"])
	local scaleX = player.isFacingRight and 2 or -2
	local offsetX = player.isFacingRight and 0 or 64
	player.anim:draw(player.spriteSheet, player.x, player.y, nil, scaleX, 2, 32, 32)

	-- Draw projectiles with animation
	for _, projectile in ipairs(projectiles) do
		projectile.animation:draw(player.spriteSheet, projectile.x, projectile.y, nil, 2, nil, 32, 32)
	end
	cam:detach()
end

-- To flip an animation do this:
-- in anim:draw function make the sx or sy value negative, sx = horizontal flip, sy = vertical flip
