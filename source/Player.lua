-- Player.lua
local love = require("love")
local anim8 = require("libraries/anim8")

local Player = {}
Player.__index = Player

function Player:new(spriteSheetPath, x, y)
	local self = setmetatable({}, Player)

	-- Load player sprite and set up animations
	self.spriteSheet = love.graphics.newImage(spriteSheetPath)
	self.grid = anim8.newGrid(80, 80, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

	self.animations = {}
	self.animations.idle = anim8.newAnimation(self.grid("1-5", 1), 0.2)
	self.animations.idleRight = anim8.newAnimation(self.grid("1-5", 2), 0.2)
	self.animations.idleLeft = anim8.newAnimation(self.grid("1-5", 2), 0.2):flipH()
	self.animations.idleUp = anim8.newAnimation(self.grid("1-5", 3), 0.2)
	self.animations.walk = anim8.newAnimation(self.grid("1-5", 4), 0.2)
	self.animations.walkUp = anim8.newAnimation(self.grid("1-5", 8), 0.2)
	self.animations.walkRight = anim8.newAnimation(self.grid("1-5", 6), 0.2)
	self.animations.walkLeft = anim8.newAnimation(self.grid("1-5", 6), 0.2):flipH()
	self.animations.die = anim8.newAnimation(self.grid("1-5", 3), 0.3, "pauseAtEnd")
	self.animations.attack = anim8.newAnimation(self.grid("1-5", 14), 0.1)

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
			self.anim = self.animations.walkUp
		end
		if love.keyboard.isDown("s") then
			isMoving = true
			self.y = self.y + self.speed * dt
			self.anim = self.animations.walk
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
			self.anim = self.animations.walkLeft
			self.isFacingRight = false
		end
		if not isMoving then
			self.anim = self.animations.idle
		end
	else
		if self.animations.attack.position == #self.grid("1-5", 14) then
			self.isAttacking = false
			self.anim = self.animations.idle
		end
	end

	self.anim:update(dt)
end

function Player:attack(enemies)
	self.isAttacking = true
	self.anim = self.animations.attack
	self.anim:gotoFrame(1)

	local attackRange = {
		x = self.isFacingRight and (self.x + 40) or (self.x - 80),
		y = self.y,
		width = 80,
		height = 80,
	}

	-- Check for collision with enemies
	for _, enemy in ipairs(enemies) do
		if self:checkCollision(attackRange, enemy) then
			enemy:takeDamage(15)
		end
	end
end

function Player:checkCollision(rect, enemy)
	return rect.x < enemy.x + enemy.width
		and rect.x + rect.width > enemy.x
		and rect.y < enemy.y + enemy.height
		and rect.y + rect.height > enemy.y
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
	self.anim:draw(self.spriteSheet, self.x, self.y, nil, 2, 2, 40, 40)

	-- Draw health bar
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", self.x - 20, self.y - 40, self.health / 100 * 40, 5)
	love.graphics.setColor(1, 1, 1)
end

return Player
