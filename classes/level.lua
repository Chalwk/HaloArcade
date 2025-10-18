-- HaloArcade - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_random = math.random
local math_min = math.min
local table_insert = table.insert

local Level = {
    wave = 1,
    difficulty = 1,
    spawnTimer = 0,
    backgroundStars = {},
    enemiesInWave = 0,
    enemiesDefeated = 0,
    game = nil
}

function Level:init(game)
    self.game = game
    -- Initialize background stars
    for _ = 1, 100 do
        table_insert(self.backgroundStars, {
            x = math_random(0, game.screenWidth),
            y = math_random(0, game.screenHeight),
            size = math_random(1, 3),
            speed = math_random(10, 30)
        })
    end
end

function Level:update(dt)
    -- Enemy spawning
    self.spawnTimer = self.spawnTimer - dt
    if self.spawnTimer <= 0 and self.enemiesInWave < (self.wave * 2 + 5) then
        local enemiesToSpawn = math_min(self.wave, 5)
        for _ = 1, enemiesToSpawn do
            self:spawnRandomEnemy()
        end
        self.spawnTimer = self.game.modules.Config.SPAWN_RATE / (self.difficulty * 0.5)
    end
end

function Level:updateStars(dt)
    for _, star in ipairs(self.backgroundStars) do
        star.y = star.y + star.speed * dt
        if star.y > self.game.screenHeight then
            star.y = 0
            star.x = math_random(0, self.game.screenWidth)
        end
    end
end

function Level:spawnRandomEnemy()
    local enemyType
    local rand = math_random()

    if self.difficulty >= 3 and rand < 0.1 then
        enemyType = "hunter"
    elseif self.difficulty >= 2 and rand < 0.3 then
        enemyType = "elite"
    else
        enemyType = "grunt"
    end

    self.game.modules.Enemy:spawn(enemyType)
    self.enemiesInWave = self.enemiesInWave + 1
end

function Level:drawBackground()
    -- Draw background
    love.graphics.setColor(0.1, 0.1, 0.2)
    love.graphics.rectangle("fill", 0, 0, self.game.screenWidth, self.game.screenHeight)

    -- Draw stars
    love.graphics.setColor(1, 1, 1)
    for _, star in ipairs(self.backgroundStars) do
        love.graphics.circle("fill", star.x, star.y, star.size)
    end
end

return Level
