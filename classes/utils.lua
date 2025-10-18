-- HaloArcade - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_sqrt = math.sqrt
local math_min = math.min
local math_max = math.max

local Utils = {}

function Utils.distance(x1, y1, x2, y2)
    return math_sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function Utils.checkCollision(x1, y1, size1, x2, y2, size2)
    return Utils.distance(x1, y1, x2, y2) < (size1 + size2) / 2
end

function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.clamp(value, min, max)
    return math_max(min, math_min(max, value))
end

return Utils