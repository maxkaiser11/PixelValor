local love = require("love")

local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(x, y)
	local self = setmetatable({}, Enemy)

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
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(1, 1, 1)
end

return Enemy
