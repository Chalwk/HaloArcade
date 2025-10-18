-- HaloArcade - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Game = {
    state = "playing",
    score = 0,
    highScore = 0,
    screenWidth = 800,
    screenHeight = 600,
    modules = {}
}

function Game:init()
    -- Load all modules
    self.modules.Utils = require "classes/utils"
    self.modules.Config = require "classes/config"
    self.modules.Player = require "classes/player"
    self.modules.Enemy = require "classes/enemy"
    self.modules.Bullet = require "classes/bullet"
    self.modules.Powerup = require "classes/powerup"
    self.modules.Particle = require "classes/particle"
    self.modules.Level = require "classes/level"

    -- Initialize modules that need it
    self.modules.Level:init(self)

    -- Set up module dependencies
    self.modules.Player.game = self
    self.modules.Enemy.game = self
    self.modules.Bullet.game = self
    self.modules.Powerup.game = self
    self.modules.Particle.game = self
    self.modules.Level.game = self

    return self
end

function Game:reset()
    self.state = "playing"
    self.score = 0
    self.modules.Player:reset()
    self.modules.Bullet.list = {}
    self.modules.Enemy.list = {}
    self.modules.Particle.list = {}
    self.modules.Powerup.list = {}

    self.modules.Level.wave = 1
    self.modules.Level.difficulty = 1
    self.modules.Level.spawnTimer = self.modules.Config.SPAWN_RATE
    self.modules.Level.enemiesInWave = 0
    self.modules.Level.enemiesDefeated = 0
    self.modules.Level:init(self)
end

function Game:getPlayer()
    return self.modules.Player
end

function Game:getEnemies()
    return self.modules.Enemy.list
end

function Game:getBullets()
    return self.modules.Bullet.list
end

function Game:getPowerups()
    return self.modules.Powerup.list
end

function Game:getParticles()
    return self.modules.Particle.list
end

function Game:getLevel()
    return self.modules.Level
end

return Game