-- Player.lua
local love = require("love")
local anim8 = require("libraries/anim8")
local wf = require("libraries/windfield/windfield")

local Player = {}
Player.__index = Player

function Player:new(spriteSheetPath, x, y)
	local self = setmetatable({}, Player)

	-- Load player sprite and set up animations
	self.spriteSheet = love.graphics.newImage(spriteSheetPath)
	self.grid = anim8.newGrid(80, 80, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

	self.animations = {}
	-- Idle Animations
	self.animations.idleDown = anim8.newAnimation(self.grid("1-5", 1), 0.2)
	self.animations.idleRight = anim8.newAnimation(self.grid("1-5", 2), 0.2)
	self.animations.idleLeft = anim8.newAnimation(self.grid("1-5", 2), 0.2):flipH()
	self.animations.idleUp = anim8.newAnimation(self.grid("1-5", 3), 0.2)

	-- Walk Animations
	self.animations.walk = anim8.newAnimation(self.grid("1-5", 4), 0.2)
	self.animations.walkUp = anim8.newAnimation(self.grid("1-5", 8), 0.2)
	self.animations.walkRight = anim8.newAnimation(self.grid("1-5", 6), 0.2)
	self.animations.walkLeft = anim8.newAnimation(self.grid("1-5", 6), 0.2):flipH()
	self.animations.die = anim8.newAnimation(self.grid("1-5", 3), 0.3, "pauseAtEnd")

	-- Attack Animations
	self.animations.attackRight = anim8.newAnimation(self.grid("1-5", 14), 0.1)
	self.animations.attackLeft = anim8.newAnimation(self.grid("1-5", 14), 0.1):flipH()
	self.animations.attackUp = anim8.newAnimation(self.grid("1-5", 15), 0.1)
	self.animations.attackDown = anim8.newAnimation(self.grid("1-5", 13), 0.1)

	self.anim = self.animations.idle
	self.isFacingRight = true
	self.isAttacking = false

	self.x = x
	self.y = y
	self.speed = 100
	self.health = 100 -- can be adjusted
	self.maxHealth = 100

	world = wf.newWorld(0, 0)

	self.collider = world:newBSGRectangleCollider(200, 250, 15, 10, 10)
	self.collider:setFixedRotation(true)

	self.lastDirection = "down"

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
	if self.isAttacking then
		-- Update attack animation and check if it has ended
		self.anim:update(dt)
		if self.anim.position == #self.anim.frames then
			self.isAttacking = false
			-- Set back to idle based on last direction
			if self.lastDirection == "up" then
				self.anim = self.animations.idleUp
			elseif self.lastDirection == "down" then
				self.anim = self.animations.idleDown
			elseif self.lastDirection == "right" then
				self.anim = self.animations.idleRight
			elseif self.lastDirection == "left" then
				self.anim = self.animations.idleLeft
			else
				self.anim = self.animations.idle
			end
		end
	else
		local isMoving = false

		local vx = 0
		local vy = 0

		if love.keyboard.isDown("w") then
			isMoving = true
			vy = self.speed * -1
			self.anim = self.animations.walkUp
			self.lastDirection = "up"
		end
		if love.keyboard.isDown("s") then
			isMoving = true
			vy = self.speed
			self.anim = self.animations.walk
			self.lastDirection = "down"
		end
		if love.keyboard.isDown("d") then
			isMoving = true
			vx = self.speed
			self.anim = self.animations.walkRight
			self.isFacingRight = true
			self.lastDirection = "right"
		end
		if love.keyboard.isDown("a") then
			isMoving = true
			vx = self.speed * -1
			self.anim = self.animations.walkLeft
			self.isFacingRight = false
			self.lastDirection = "left"
		end
		player.collider:setLinearVelocity(vx, vy)

		if not isMoving then
			if self.lastDirection == "up" then
				self.anim = self.animations.idleUp
			elseif self.lastDirection == "down" then
				self.anim = self.animations.idleDown
			elseif self.lastDirection == "right" then
				self.anim = self.animations.idleRight
			elseif self.lastDirection == "left" then
				self.anim = self.animations.idleLeft
			else
				self.anim = self.animations.idle
			end
		end
		self.anim:update(dt)
	end
end

function Player:attack(enemies)
	self.isAttacking = true

	if self.lastDirection == "up" then
		self.anim = self.animations.attackUp
	end
	if self.lastDirection == "down" then
		self.anim = self.animations.attackDown
	end
	if self.lastDirection == "right" then
		self.anim = self.animations.attackRight
	end
	if self.lastDirection == "left" then
		self.anim = self.animations.attackLeft
	end
	self.anim:gotoFrame(1)

	local attackRange
	if self.anim == self.animations.attackUp then
		attackRange = { x = self.x, y = self.y - 64, width = 64, height = 64 }
	elseif self.anim == self.animations.attackDown then
		attackRange = { x = self.x, y = self.y + 32, width = 64, height = 64 }
	elseif self.anim == self.animations.attackLeft then
		attackRange = { x = self.x - 64, y = self.y, width = 64, height = 64 }
	elseif self.anim == self.animations.attackRight then
		attackRange = { x = self.x + 32, y = self.y, width = 64, height = 64 }
	end

	-- Check for collision with enemies
	for _, enemy in ipairs(enemies) do
		if self:checkCollision(attackRange, enemy) then
			enemy:takeDamage(15)
		end
	end
end

function Player:checkCollision(rect, enemy)
	if not rect then
		return
	end
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

function Player:drawHealthBar()
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 20, 20, 100, 20)

	-- Draw health amount
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", 20, 20, self.health / 100 * 100, 20)
	love.graphics.setColor(1, 1, 1)
end
function Player:draw()
	self.anim:draw(self.spriteSheet, self.x, self.y, nil, 2, 2, 40, 40)
end

return Player
