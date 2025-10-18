-- HaloArcade - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Config = require "classes/config"

local math_min = math.min
local math_max = math.max

local Player = {
    x = 400,
    y = 500,
    size = Config.PLAYER_SIZE,
    speed = Config.PLAYER_SPEED,
    health = 100,
    maxHealth = 100,
    weapons = {
        current = "assault_rifle",
        assault_rifle = { fireRate = 0.15, damage = 10, timer = 0 },
        plasma_pistol = { fireRate = 0.3, damage = 25, timer = 0, charged = false },
        rocket_launcher = { fireRate = 1.0, damage = 75, timer = 0 }
    },
    shields = 100,
    maxShields = 100,
    shieldRechargeTimer = 0,
    game = nil
}

function Player:reset()
    self.health = self.maxHealth
    self.shields = self.maxShields
    self.x = self.game.screenWidth / 2
    self.y = self.game.screenHeight - 100
    self.weapons.current = "assault_rifle"
    self.shieldRechargeTimer = 0
end

function Player:update(dt)
    -- Movement
    if love.keyboard.isDown("a", "left") and self.x > self.size / 2 then
        self.x = self.x - self.speed * dt
    end
    if love.keyboard.isDown("d", "right") and self.x < self.game.screenWidth - self.size / 2 then
        self.x = self.x + self.speed * dt
    end
    if love.keyboard.isDown("w", "up") and self.y > self.size / 2 then
        self.y = self.y - self.speed * dt
    end
    if love.keyboard.isDown("s", "down") and self.y < self.game.screenHeight - self.size / 2 then
        self.y = self.y + self.speed * dt
    end

    -- Weapon firing
    local weapon = self.weapons[self.weapons.current]
    weapon.timer = weapon.timer - dt

    if love.keyboard.isDown("space") and weapon.timer <= 0 then
        if self.weapons.current == "assault_rifle" then
            self.game.modules.Bullet:fireAssaultRifle(self.x, self.y, weapon.damage)
        elseif self.weapons.current == "plasma_pistol" then
            self.game.modules.Bullet:firePlasmaPistol(self.x, self.y, weapon.damage, weapon.charged)
            weapon.charged = false
        elseif self.weapons.current == "rocket_launcher" then
            self.game.modules.Bullet:fireRocketLauncher(self.x, self.y, weapon.damage)
        end
        weapon.timer = weapon.fireRate
    end

    -- Plasma pistol charging
    if self.weapons.current == "plasma_pistol" and love.keyboard.isDown("lshift") then
        weapon.charged = true
    end

    -- Weapon switching
    if love.keyboard.isDown("1") then
        self.weapons.current = "assault_rifle"
    elseif love.keyboard.isDown("2") then
        self.weapons.current = "plasma_pistol"
    elseif love.keyboard.isDown("3") then
        self.weapons.current = "rocket_launcher"
    end

    -- Shield recharge
    if self.shields < self.maxShields then
        self.shieldRechargeTimer = self.shieldRechargeTimer + dt
        if self.shieldRechargeTimer >= 3 then
            self.shields = math_min(self.maxShields, self.shields + 20 * dt)
        end
    else
        self.shieldRechargeTimer = 0
    end
end

function Player:draw()
    if self.game.state ~= "playing" then return end

    -- Draw shields
    if self.shields > 0 then
        love.graphics.setColor(Config.colors.player_shield)
        love.graphics.circle("fill", self.x, self.y, self.size / 2 + 5)
    end

    -- Draw player
    love.graphics.setColor(Config.colors.player)
    love.graphics.rectangle("fill", self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)

    -- Helmet visor
    love.graphics.setColor(0.8, 0.9, 1)
    love.graphics.rectangle("fill", self.x - 4, self.y - 6, 8, 4)

    -- Weapon indicator
    love.graphics.setColor(1, 1, 1)
    if self.weapons.current == "assault_rifle" then
        love.graphics.print("AR", self.x - 8, self.y + 15)
    elseif self.weapons.current == "plasma_pistol" then
        love.graphics.print("PP", self.x - 8, self.y + 15)
        if self.weapons.plasma_pistol.charged then
            love.graphics.setColor(0.2, 0.8, 1)
            love.graphics.circle("line", self.x, self.y, self.size / 2 + 8)
        end
    elseif self.weapons.current == "rocket_launcher" then
        love.graphics.print("RL", self.x - 8, self.y + 15)
    end
end

function Player:takeDamage(damage)
    -- Damage shields first
    if self.shields > 0 then
        self.shields = self.shields - damage
        self.shieldRechargeTimer = 0
        if self.shields < 0 then
            self.health = self.health + self.shields
            self.shields = 0
        end
    else
        self.health = self.health - damage
    end

    if self.health <= 0 then
        self.game.state = "gameOver"
        self.game.highScore = math_max(self.game.highScore, self.game.score)
        self.game.modules.Particle:createExplosion(self.x, self.y, 40, Config.colors.player)
    end
end

return Player