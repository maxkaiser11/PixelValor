-- Projectile.lua
local love = require("love")
local anim8 = require("libraries/anim8")

local Projectile = {}
Projectile.__index = Projectile

function Projectile:new(spriteSheet, grid, x, y, direction, speed)
	local self = setmetatable({}, Projectile)

	self.spriteSheet = spriteSheet
	self.x = x
	self.y = y
	self.speed = speed * direction
	self.animation = anim8.newAnimation(grid("1-6", 6), 0.3)

	return self
end

function Projectile:update(dt)
	self.x = self.x + self.speed * dt
	self.animation:update(dt)
end

function Projectile:isFinished()
	return self.animation.status == "finished"
end

function Projectile:draw()
	self.animation:draw(self.spriteSheet, self.x, self.y, nil, 2, nil, 32, 32)
end

return Projectile
