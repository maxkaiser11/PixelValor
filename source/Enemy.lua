local love = require("love")

local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(x, y)
	local self = setmetatable({}, Enemy)

	self.isDying = false
	self.toBeRemoved = false

	self.spriteSheet = love.graphics.newImage("sprites/Run.png")
	self.spriteSheetDeath = love.graphics.newImage("sprites/Death.png")
	self.grid = anim8.newGrid(64, 64, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
	self.gridDeath = anim8.newGrid(64, 64, self.spriteSheetDeath:getWidth(), self.spriteSheetDeath:getHeight())

	self.animations = {}
	self.animations.run = anim8.newAnimation(self.grid("1-6", 1), 0.2)
	self.animations.death = anim8.newAnimation(self.gridDeath("1-6", 1), 0.2, "pauseAtEnd")
	self.anim = self.animations.run

	self.x = x
	self.y = y
	self.width = 50
	self.height = 50
	self.speed = 35
	self.health = 50

	return self
end

function Enemy:update(dt)
	if self.isDying then
		self.anim:update(dt)
		if self.anim.status == "paused" then
			self.toBeRemoved = true
		end
		return
	end
	local distanceToPlayer = math.sqrt((player.x - self.x) ^ 2 + (player.y - self.y) ^ 2)

	-- Chase player if within chase radius
	if distanceToPlayer < 200 then
		local directionX = player.x > self.x and 1 or -1
		local directionY = player.y > self.y and 1 or -1

		self.x = self.x + directionX * self.speed * dt
		self.y = self.y + directionY * self.speed * dt
	else
		self.x = self.x + math.sin(love.timer.getTime()) * self.speed * dt
	end
	self.anim:update(dt)
end

function Enemy:takeDamage(amount)
	if self.isDying then
		return
	end
	self.health = self.health - amount
	if self.health <= 0 then
		self.health = 0
		self.isDying = true
		self.anim = self.animations.death
		-- Handle enemy death here
	end
end

function Enemy:draw()
	if self.isDying then
		self.anim:draw(self.spriteSheetDeath, self.x, self.y, nil, 1.5, 1.5, 32, 32)
	else
		self.anim:draw(self.spriteSheet, self.x, self.y, nil, 1.5, 1.5, 32, 32)
	end

	-- draw health bar
	if not self.isDying then
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle("fill", self.x, self.y - 10, self.health / 50 * self.width, 5)
		love.graphics.setColor(1, 1, 1)
	end
end

return Enemy
