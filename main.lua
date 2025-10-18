-- HaloArcade - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Game = require "classes/game"

-- Game instance
local game = Game:init()

-- Localize frequently used functions
local math_floor = math.floor
local table_remove = table.remove

-- Collision detection functions
local function checkCollisions()
    local Player = game:getPlayer()
    local Bullet = game.modules.Bullet
    local Enemy = game.modules.Enemy
    local Powerup = game.modules.Powerup
    local Particle = game.modules.Particle
    local Utils = game.modules.Utils

    -- Player bullets vs enemies
    for i = #Bullet.list, 1, -1 do
        local bullet = Bullet.list[i]
        if bullet.type ~= "enemy_bullet" then
            for j = #Enemy.list, 1, -1 do
                local enemy = Enemy.list[j]
                if Utils.checkCollision(bullet.x, bullet.y, bullet.size, enemy.x, enemy.y, enemy.size) then
                    local enemyDestroyed = Enemy:takeDamage(enemy, bullet.damage)
                    if enemyDestroyed then
                        table_remove(Bullet.list, i)
                        break
                    end

                    -- Handle rocket explosions
                    if bullet.explosionRadius then
                        Particle:createExplosion(bullet.x, bullet.y, 20, game.modules.Config.colors.explosion)
                        -- Damage all enemies in explosion radius
                        for k = #Enemy.list, 1, -1 do
                            local otherEnemy = Enemy.list[k]
                            if Utils.distance(bullet.x, bullet.y, otherEnemy.x, otherEnemy.y) < bullet.explosionRadius then
                                Enemy:takeDamage(otherEnemy, bullet.damage * 0.5)
                            end
                        end
                    end

                    table_remove(Bullet.list, i)
                    break
                end
            end
        end
    end

    -- Enemy bullets vs player
    for i = #Bullet.list, 1, -1 do
        local bullet = Bullet.list[i]
        if bullet.type == "enemy_bullet" then
            if Utils.checkCollision(bullet.x, bullet.y, bullet.size, Player.x, Player.y, Player.size) then
                Player:takeDamage(bullet.damage)
                Particle:createExplosion(bullet.x, bullet.y, 8, game.modules.Config.colors.plasma)
                table_remove(Bullet.list, i)
            end
        end
    end

    -- Player vs enemies (collision damage)
    for i = #Enemy.list, 1, -1 do
        local enemy = Enemy.list[i]
        if Player and Player.x and Player.y and Utils.checkCollision(Player.x, Player.y, Player.size, enemy.x, enemy.y, enemy.size) then
            Player:takeDamage(20)
            Particle:createExplosion(enemy.x, enemy.y, enemy.size, Enemy.types[enemy.type].color)
            table_remove(Enemy.list, i)
            game.modules.Level.enemiesDefeated = game.modules.Level.enemiesDefeated + 1
        end
    end

    -- Player vs powerups
    for i = #Powerup.list, 1, -1 do
        local powerup = Powerup.list[i]
        if Player and Player.x and Player.y and Utils.checkCollision(Player.x, Player.y, Player.size, powerup.x, powerup.y, powerup.size) then
            Powerup:collect(powerup)
            table_remove(Powerup.list, i)
        end
    end
end

-- Wave management
local function checkWaveCompletion()
    local Level = game.modules.Level
    if Level.enemiesInWave > 0 and Level.enemiesDefeated >= Level.enemiesInWave and #game.modules.Enemy.list == 0 then
        Level.wave = Level.wave + 1
        Level.enemiesInWave = 0
        Level.enemiesDefeated = 0

        -- Increase difficulty every 5 waves
        if Level.wave % 5 == 0 then
            Level.difficulty = Level.difficulty + 1
        end
    end
end

-- UI rendering functions
local function drawUI()
    local Player = game:getPlayer()
    local Level = game.modules.Level
    local Config = game.modules.Config

    -- UI background panels
    love.graphics.setColor(Config.colors.ui_background)
    love.graphics.rectangle("fill", 10, 10, 200, 80)
    love.graphics.rectangle("fill", game.screenWidth - 210, 10, 200, 80)

    -- Score and wave info
    love.graphics.setColor(Config.colors.text)
    love.graphics.print("Score: " .. game.score, 20, 20)
    love.graphics.print("Wave: " .. Level.wave, 20, 40)
    love.graphics.print("Difficulty: " .. Level.difficulty, 20, 60)

    -- Health bar
    local healthPercent = Player.health / Player.maxHealth
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", game.screenWidth - 200, 20, 180 * healthPercent, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", game.screenWidth - 200, 20, 180, 20)
    love.graphics.print("Health: " .. math_floor(Player.health), game.screenWidth - 190, 22)

    -- Shield bar
    local shieldPercent = Player.shields / Player.maxShields
    love.graphics.setColor(0.2, 0.5, 1)
    love.graphics.rectangle("fill", game.screenWidth - 200, 50, 180 * shieldPercent, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", game.screenWidth - 200, 50, 180, 20)
    love.graphics.print("Shields: " .. math_floor(Player.shields), game.screenWidth - 190, 52)

    -- Controls help
    love.graphics.setColor(Config.colors.text)
    love.graphics.print("WASD: Move | Space: Fire | 1/2/3: Switch Weapon | Shift: Charge (Plasma) | R: Restart", 10,
        game.screenHeight - 30)
end

local function drawGameOverScreen()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, game.screenWidth, game.screenHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("GAME OVER", 0, game.screenHeight / 2 - 60, game.screenWidth, "center")
    love.graphics.printf("Score: " .. game.score, 0, game.screenHeight / 2 - 20, game.screenWidth, "center")
    love.graphics.printf("High Score: " .. game.highScore, 0, game.screenHeight / 2 + 10, game.screenWidth, "center")
    love.graphics.printf("Press R to Restart", 0, game.screenHeight / 2 + 50, game.screenWidth, "center")
end

-- Love2D callbacks
function love.load()
    game.screenWidth = love.graphics.getWidth()
    game.screenHeight = love.graphics.getHeight()
    love.window.setTitle("HaloArcade")

    game:getPlayer():reset()
end

function love.update(dt)
    -- Update screen dimensions in case of window resize
    game.screenWidth = love.graphics.getWidth()
    game.screenHeight = love.graphics.getHeight()

    game.modules.Level:updateStars(dt)

    if game.state == "playing" then
        game:getPlayer():update(dt)
        game.modules.Level:update(dt)
        game.modules.Bullet:updateAll(dt)
        game.modules.Enemy:updateAll(dt)
        game.modules.Powerup:updateAll(dt)
        game.modules.Particle:updateAll(dt)

        checkCollisions()
        checkWaveCompletion()
    end

    -- Restart game
    if game.state == "gameOver" and love.keyboard.isDown("r") then
        game:reset()
    end
end

function love.draw()
    -- Draw game elements in correct order
    game.modules.Level:drawBackground()
    game.modules.Particle:drawAll()
    game.modules.Powerup:drawAll()
    game.modules.Bullet:drawAll()
    game.modules.Enemy:drawAll()
    game:getPlayer():draw()

    drawUI()

    if game.state == "gameOver" then
        drawGameOverScreen()
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

-- Handle window resizing
function love.resize(w, h)
    game.screenWidth = w
    game.screenHeight = h
end
