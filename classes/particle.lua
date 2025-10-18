-- HaloArcade - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_random = math.random
local table_insert = table.insert
local table_remove = table.remove

local Particle = {
    list = {},
    game = nil
}

function Particle:createExplosion(x, y, size, color)
    for _ = 1, 15 do
        table_insert(self.list, {
            x = x,
            y = y,
            vx = (math_random() - 0.5) * 200,
            vy = (math_random() - 0.5) * 200,
            life = 1,
            maxLife = 1,
            size = math_random(2, size),
            color = color or self.game.modules.Config.colors.explosion
        })
    end
end

function Particle:updateAll(dt)
    for i = #self.list, 1, -1 do
        local particle = self.list[i]
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
        particle.life = particle.life - dt

        if particle.life <= 0 then
            table_remove(self.list, i)
        end
    end
end

function Particle:drawAll()
    for _, particle in ipairs(self.list) do
        local alpha = particle.life / particle.maxLife
        love.graphics.setColor(particle.color[1], particle.color[2], particle.color[3], alpha)
        love.graphics.circle("fill", particle.x, particle.y, particle.size)
    end
end

return Particle