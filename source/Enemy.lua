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

	return self
end

function Enemy:update(dt)
	self.x = self.x + math.sin(love.timer.getTime()) * self.speed * dt
end

function Enemy:draw()
	self.anim:draw(self.spriteSheet, self.x, self.y, nil, 1.5, 1.5, 32, 32)
end

return Enemy
