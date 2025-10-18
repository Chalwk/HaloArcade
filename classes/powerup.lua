-- HaloArcade - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Config = require "classes/config"

local math_random = math.random
local table_insert = table.insert
local table_remove = table.remove

local Powerup = {
    list = {},
    game = nil
}

Powerup.types = {
    health = {
        color = Config.colors.health_powerup,
        effect = function(game)
            local player = game:getPlayer()
            player.health = math.min(player.maxHealth, player.health + 30)
        end
    },
    shield = {
        color = Config.colors.shield_powerup,
        effect = function(game)
            local player = game:getPlayer()
            player.shields = player.maxShields
        end
    },
    weapon = {
        color = Config.colors.weapon_powerup,
        effect = function(game)
            local player = game:getPlayer()
            if player.weapons.current == "assault_rifle" then
                player.weapons.current = "plasma_pistol"
            elseif player.weapons.current == "plasma_pistol" then
                player.weapons.current = "rocket_launcher"
            else
                player.weapons.current = "assault_rifle"
            end
        end
    }
}

function Powerup:spawn(x, y)
    local powerupType
    local rand = math_random()

    if rand < 0.4 then
        powerupType = "health"
    elseif rand < 0.7 then
        powerupType = "shield"
    else
        powerupType = "weapon"
    end

    table_insert(self.list, {
        x = x,
        y = y,
        type = powerupType,
        size = 12,
        vy = 50
    })
end

function Powerup:updateAll(dt)
    for i = #self.list, 1, -1 do
        local powerup = self.list[i]
        powerup.y = powerup.y + powerup.vy * dt

        if powerup.y > self.game.screenHeight + 20 then
            table_remove(self.list, i)
        end
    end
end

function Powerup:drawAll()
    for _, powerup in ipairs(self.list) do
        local color = self.types[powerup.type].color
        love.graphics.setColor(color)
        love.graphics.circle("fill", powerup.x, powerup.y, powerup.size)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", powerup.x, powerup.y, powerup.size)

        -- Draw symbol based on type
        if powerup.type == "health" then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("+", powerup.x - 4, powerup.y - 8)
        elseif powerup.type == "shield" then
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("line", powerup.x, powerup.y, powerup.size - 2)
        elseif powerup.type == "weapon" then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("W", powerup.x - 4, powerup.y - 8)
        end
    end
end

function Powerup:collect(powerup)
    self.types[powerup.type].effect(self.game)
end

return Powerup