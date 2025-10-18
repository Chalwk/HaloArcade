-- HaloArcade - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Config = require "classes/config"

local math_random = math.random
local math_sin = math.sin
local table_insert = table.insert
local table_remove = table.remove

local Enemy = {
    list = {},
    game = nil,
    types = {
        grunt = {
            health = 30,
            size = 16,
            color = Config.colors.enemy_grunt,
            points = 10,
            fireRate = 2.0,
            bulletSpeed = 200,
            bulletDamage = 10
        },
        elite = {
            health = 60,
            size = 20,
            color = Config.colors.enemy_elite,
            points = 25,
            fireRate = 1.5,
            bulletSpeed = 250,
            bulletDamage = 15,
            shields = 50
        },
        hunter = {
            health = 150,
            size = 35,
            color = Config.colors.enemy_hunter,
            points = 50,
            fireRate = 3.0,
            bulletSpeed = 150,
            bulletDamage = 25,
            movementPattern = "charge"
        }
    }
}

function Enemy:spawn(type, x, y)
    local enemyType = self.types[type]
    local enemy = {
        x = x or math_random(50, self.game.screenWidth - 50),
        y = y or -30,
        type = type,
        health = enemyType.health,
        maxHealth = enemyType.health,
        size = enemyType.size,
        speed = math_random(Config.ENEMY_SPEED_MIN, Config.ENEMY_SPEED_MAX),
        fireTimer = 0,
        shields = enemyType.shields or 0,
        maxShields = enemyType.shields or 0
    }

    table_insert(self.list, enemy)
    return enemy
end

function Enemy:updateAll(dt)
    local Player = self.game:getPlayer()

    for i = #self.list, 1, -1 do
        local enemy = self.list[i]
        local enemyData = self.types[enemy.type]

        -- Movement
        if enemyData.movementPattern == "charge" then
            if Player and Player.x and Player.y then
                local dx = Player.x - enemy.x
                local dy = Player.y - enemy.y
                local dist = self.game.modules.Utils.distance(enemy.x, enemy.y, Player.x, Player.y)
                if dist > 0 then
                    enemy.x = enemy.x + (dx / dist) * enemy.speed * dt
                    enemy.y = enemy.y + (dy / dist) * enemy.speed * dt
                end
            end
        else
            enemy.y = enemy.y + enemy.speed * dt
            enemy.x = enemy.x + math_sin(love.timer.getTime() * 2 + i) * 50 * dt
        end

        -- Enemy firing
        if Player and Player.x and Player.y then
            enemy.fireTimer = enemy.fireTimer - dt
            if enemy.fireTimer <= 0 then
                self.game.modules.Bullet:fireEnemyBullet(enemy.x, enemy.y + enemy.size / 2, enemyData.bulletSpeed,
                    enemyData.bulletDamage)
                enemy.fireTimer = enemyData.fireRate
            end
        end

        -- Remove off-screen enemies
        if enemy.y > self.game.screenHeight + 100 then
            table_remove(self.list, i)
            self.game.modules.Level.enemiesDefeated = self.game.modules.Level.enemiesDefeated + 1
        end
    end
end

function Enemy:drawAll()
    for _, enemy in ipairs(self.list) do
        -- Only draw if enemy exists and has health
        if enemy and enemy.health then
            local enemyData = self.types[enemy.type]
            love.graphics.setColor(enemyData.color)

            if enemy.type == "grunt" then
                love.graphics.rectangle("fill", enemy.x - enemy.size / 2, enemy.y - enemy.size / 2, enemy.size,
                    enemy.size)
            elseif enemy.type == "elite" then
                love.graphics.circle("fill", enemy.x, enemy.y, enemy.size / 2)
                love.graphics.setColor(0.1, 0.4, 0.1)
                love.graphics.rectangle("fill", enemy.x - 3, enemy.y - enemy.size / 2 - 5, 6, 8)
            elseif enemy.type == "hunter" then
                love.graphics.rectangle("fill", enemy.x - enemy.size / 2, enemy.y - enemy.size / 3, enemy.size,
                    enemy.size * 0.66)
                love.graphics.setColor(0.3, 0.3, 0.3)
                love.graphics.rectangle("fill", enemy.x - enemy.size / 2 + 2, enemy.y - enemy.size / 3 + 2,
                    enemy.size - 4, 8)
                love.graphics.rectangle("fill", enemy.x - enemy.size / 2 + 2, enemy.y + enemy.size / 3 - 10,
                    enemy.size - 4,
                    8)
            end

            -- Draw enemy shields
            if enemy.shields > 0 then
                love.graphics.setColor(0.2, 0.5, 1, 0.3)
                love.graphics.circle("line", enemy.x, enemy.y, enemy.size / 2 + 3)
            end

            -- Draw health bar
            if enemy.health < enemy.maxHealth then
                local barWidth = enemy.size
                local barHeight = 4
                local healthPercent = enemy.health / enemy.maxHealth

                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.rectangle("fill", enemy.x - barWidth / 2, enemy.y - enemy.size / 2 - 8, barWidth, barHeight)
                love.graphics.setColor(0.2, 0.8, 0.2)
                love.graphics.rectangle("fill", enemy.x - barWidth / 2, enemy.y - enemy.size / 2 - 8,
                    barWidth * healthPercent, barHeight)
            end
        end
    end
end

function Enemy:takeDamage(enemy, damage)
    -- Handle shields first
    if enemy.shields > 0 then
        enemy.shields = enemy.shields - damage
        if enemy.shields < 0 then
            enemy.health = enemy.health + enemy.shields
            enemy.shields = 0
        end
    else
        enemy.health = enemy.health - damage
    end

    if enemy.health <= 0 then
        self.game.score = self.game.score + self.types[enemy.type].points
        self.game.modules.Particle:createExplosion(enemy.x, enemy.y, enemy.size, self.types[enemy.type].color)
        self.game.modules.Level.enemiesDefeated = self.game.modules.Level.enemiesDefeated + 1

        -- Chance to spawn powerup
        if math_random() < Config.POWERUP_CHANCE then
            self.game.modules.Powerup:spawn(enemy.x, enemy.y)
        end

        -- REMOVE THE ENEMY FROM THE LIST
        for i = #self.list, 1, -1 do
            if self.list[i] == enemy then
                table_remove(self.list, i)
                break
            end
        end

        return true -- Enemy destroyed
    end
    return false
end

return Enemy
