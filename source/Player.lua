-- Player.lua
local love = require("love")
local anim8 = require("libraries/anim8")

local Player = {}
Player.__index = Player

function Player:new(spriteSheetPath, x, y)
	local self = setmetatable({}, Player)

	-- Load player sprite and set up animations
	self.spriteSheet = love.graphics.newImage(spriteSheetPath)
	self.grid = anim8.newGrid(64, 64, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

	self.animations = {}
	self.animations.idle = anim8.newAnimation(self.grid("1-6", 1), 0.2)
	self.animations.walkRight = anim8.newAnimation(self.grid("1-6", 2), 0.2)
	self.animations.die = anim8.newAnimation(self.grid("1-6", 3), 0.3, "pauseAtEnd")
	self.animations.attack = anim8.newAnimation(self.grid("1-6", 4), 0.1)

	self.anim = self.animations.idle
	self.isFacingRight = true
	self.isAttacking = false

	self.x = x
	self.y = y
	self.speed = 100
	self.health = 100 -- can be adjusted

	local cooldown = 1.0
	self.lastDamageTime = -cooldown

	return self
end

function Player:update(dt)
	if self.health <= 0 then
		if self.anim ~= self.animations.die then
			self.anim = self.animations.die
			self.anim:gotoFrame(1)
		end
		self.anim:update(dt)
		return
	end
	if not self.isAttacking then
		local isMoving = false
		if love.keyboard.isDown("w") then
			isMoving = true
			self.y = self.y - self.speed * dt
			self.anim = self.animations.walkRight
		end
		if love.keyboard.isDown("s") then
			isMoving = true
			self.y = self.y + self.speed * dt
			self.anim = self.animations.walkRight
		end
		if love.keyboard.isDown("d") then
			isMoving = true
			self.x = self.x + self.speed * dt
			self.anim = self.animations.walkRight
			self.isFacingRight = true
		end
		if love.keyboard.isDown("a") then
			isMoving = true
			self.x = self.x - self.speed * dt
			self.anim = self.animations.walkRight
			self.isFacingRight = false
		end
		if not isMoving then
			self.anim = self.animations.idle
		end
	else
		if self.animations.attack.position == #self.grid("1-6", 4) then
			self.isAttacking = false
			self.anim = self.animations.idle
		end
	end

	self.anim:update(dt)
end

function Player:attack()
	self.isAttacking = true
	self.anim = self.animations.attack
	self.anim:gotoFrame(1)
end

function Player:takeDamage(amount)
	local currentTime = love.timer.getTime()
	if currentTime - self.lastDamageTime >= 1 then
		self.lastDamageTime = currentTime
		self.health = self.health - amount

		-- Trigger death animation if health reaches zero
		if self.health <= 0 then
			self.health = 0
			if self.anim ~= self.animations.die then
				self.anim = self.animations.die
				self.anim:gotoFrame(1) -- Start the death animation from the beginning
			end
		end
	end
end

function Player:draw()
	local scaleX = self.isFacingRight and 2 or -2
	local offsetX = self.isFacingRight and 0 or 64

	self.anim:draw(self.spriteSheet, self.x, self.y, nil, scaleX, 2, 32, 32)

	-- Draw health bar
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", self.x - 20, self.y - 40, self.health / 100 * 40, 5)
	love.graphics.setColor(1, 1, 1)
end

return Player
