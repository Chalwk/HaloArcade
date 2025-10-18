-- HaloArcade - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Config = {
    PLAYER_SPEED = 300,
    PLAYER_SIZE = 20,
    BULLET_SPEED = 500,
    ENEMY_SPEED_MIN = 50,
    ENEMY_SPEED_MAX = 150,
    SPAWN_RATE = 1.5,
    POWERUP_CHANCE = 0.1,

    colors = {
        player = { 0.2, 0.8, 0.2 },
        player_shield = { 0.2, 0.5, 1, 0.3 },
        bullet = { 1, 1, 1 },
        enemy_grunt = { 0.8, 0.2, 0.2 },
        enemy_elite = { 0.2, 0.8, 0.2 },
        enemy_hunter = { 0.5, 0.5, 0.5 },
        explosion = { 1, 0.8, 0.2 },
        plasma = { 0.2, 0.8, 1 },
        health_powerup = { 1, 0.2, 0.2 },
        shield_powerup = { 0.2, 0.5, 1 },
        weapon_powerup = { 0.8, 0.8, 0.2 },
        text = { 1, 1, 1 },
        ui_background = { 0, 0, 0, 0.7 }
    }
}

return Config