local love = require("love")

local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(x, y)
	local self = setmetatable({}, Enemy)

	self.spriteSheet = love.graphics.newImage("sprites/Run.png")
	self.grid = anim8.newGrid(64, 64, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

	self.animations = {}
	self.animations.run = anim8.newAnimation(self.grid("1-6", 1), 0.2)
	self.anim = self.animations.run

	self.x = x
	self.y = y
	self.width = 50
	self.height = 50
	self.speed = 50
	self.health = 50

	return self
end

function Enemy:update(dt)
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
end

function Enemy:takeDamage(amount)
	self.health = self.health - amount
	if self.health <= 0 then
		self.health = 0
		-- Handle enemy death here
	end
end

function Enemy:draw()
	self.anim:draw(self.spriteSheet, self.x, self.y, nil, 1.5, 1.5, 32, 32)

	-- draw health bar
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", self.x, self.y - 10, self.health / 50 * self.width, 5)
	love.graphics.setColor(1, 1, 1)
end

return Enemy
