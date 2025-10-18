-- HaloArcade - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Utils = require "classes/utils"
local math_sqrt = math.sqrt
local table_insert = table.insert
local table_remove = table.remove

local Bullet = {
    list = {},
    game = nil
}

function Bullet:fireAssaultRifle(x, y, damage)
    table_insert(self.list, {
        x = x,
        y = y - 10,
        vx = 0,
        vy = -self.game.modules.Config.BULLET_SPEED,
        damage = damage,
        type = "bullet",
        size = 3
    })
end

function Bullet:firePlasmaPistol(x, y, damage, charged)
    if charged then
        table_insert(self.list, {
            x = x,
            y = y - 15,
            vx = 0,
            vy = -self.game.modules.Config.BULLET_SPEED * 0.7,
            damage = damage * 3,
            type = "plasma_charged",
            size = 12,
            homing = true
        })
    else
        table_insert(self.list, {
            x = x,
            y = y - 10,
            vx = 0,
            vy = -self.game.modules.Config.BULLET_SPEED * 0.8,
            damage = damage,
            type = "plasma",
            size = 6
        })
    end
end

function Bullet:fireRocketLauncher(x, y, damage)
    table_insert(self.list, {
        x = x,
        y = y - 15,
        vx = 0,
        vy = -self.game.modules.Config.BULLET_SPEED * 0.6,
        damage = damage,
        type = "rocket",
        size = 8,
        explosionRadius = 60
    })
end

function Bullet:fireEnemyBullet(x, y, speed, damage)
    table_insert(self.list, {
        x = x,
        y = y,
        vx = 0,
        vy = speed,
        damage = damage,
        type = "enemy_bullet",
        size = 4
    })
end

function Bullet:updateAll(dt)
    for i = #self.list, 1, -1 do
        local bullet = self.list[i]
        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt

        -- Remove off-screen bullets
        if bullet.y < -50 or bullet.y > self.game.screenHeight + 50 or
            bullet.x < -50 or bullet.x > self.game.screenWidth + 50 then
            table_remove(self.list, i)
        else
            -- Homing for charged plasma
            if bullet.homing and #self.game.modules.Enemy.list > 0 then
                local closestEnemy = self.game.modules.Enemy.list[1]
                local closestDist = Utils.distance(bullet.x, bullet.y, closestEnemy.x, closestEnemy.y)

                for _, enemy in ipairs(self.game.modules.Enemy.list) do
                    local dist = Utils.distance(bullet.x, bullet.y, enemy.x, enemy.y)
                    if dist < closestDist then
                        closestDist = dist
                        closestEnemy = enemy
                    end
                end

                if closestDist < 200 and closestDist > 0 then  -- ADDED: and closestDist > 0
                    local dx = closestEnemy.x - bullet.x
                    local dy = closestEnemy.y - bullet.y
                    local dist = math_sqrt(dx * dx + dy * dy)
                    if dist > 0 then  -- ADDED: Check to avoid division by zero
                        bullet.vx = (dx / dist) * self.game.modules.Config.BULLET_SPEED * 0.7
                        bullet.vy = (dy / dist) * self.game.modules.Config.BULLET_SPEED * 0.7
                    end
                end
            end
        end
    end
end

function Bullet:drawAll()
    for _, bullet in ipairs(self.list) do
        if bullet.type == "bullet" then
            love.graphics.setColor(self.game.modules.Config.colors.bullet)
            love.graphics.circle("fill", bullet.x, bullet.y, bullet.size)
        elseif bullet.type == "plasma" then
            love.graphics.setColor(self.game.modules.Config.colors.plasma)
            love.graphics.circle("fill", bullet.x, bullet.y, bullet.size)
        elseif bullet.type == "plasma_charged" then
            love.graphics.setColor(0.8, 0.9, 1)
            love.graphics.circle("fill", bullet.x, bullet.y, bullet.size)
            love.graphics.setColor(0.2, 0.8, 1, 0.5)
            love.graphics.circle("fill", bullet.x, bullet.y, bullet.size * 1.5)
        elseif bullet.type == "rocket" then
            love.graphics.setColor(0.8, 0.6, 0.2)
            love.graphics.circle("fill", bullet.x, bullet.y, bullet.size)
            love.graphics.setColor(1, 0.8, 0.2)
            love.graphics.circle("fill", bullet.x, bullet.y - 2, bullet.size - 2)
        elseif bullet.type == "enemy_bullet" then
            love.graphics.setColor(1, 0.2, 0.2)
            love.graphics.circle("fill", bullet.x, bullet.y, bullet.size)
        end
    end
end

return Bullet