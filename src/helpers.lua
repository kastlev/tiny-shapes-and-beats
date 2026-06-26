function ring_expand(n, col)
    local pos = {
        { 21, 21 }, { 64, 21 }, { 107, 21 },
        { 21, 64 }, { 64, 64 }, { 107, 64 },
        { 21, 107 }, { 64, 107 }, { 107, 107 }
    }
    for i = 1, n do
        local b = pos[((i - 1) % 9) + 1]
        local ox = rnd(14) - 7
        local oy = rnd(14) - 7
        spawn(
            E_CIRCLE, b[1] + ox, b[2] + oy, {
                size = 2, max_size = 44,
                fill = false, grow = true, growth_rate = 1.6,
                duration_frames = 50,
                color = col or C_PINK,
                warning = false
            }
        )
        wait_frames(18)
    end
end

function four_corners(size)
    sync(
        function() spawn(E_CIRCLE, 18, 18, { size = size }) end,
        function() spawn(E_CIRCLE, 109, 18, { size = size }) end,
        function() spawn(E_CIRCLE, 18, 109, { size = size }) end,
        function() spawn(E_CIRCLE, 109, 109, { size = size }) end
    )
end

function burst_triangle(speed, count)
    count = count or 8
    sync(
        function() spawn(E_BULLET, 64, 16, { count = count, speed = speed }) end,
        function() spawn(E_BULLET, 22, 100, { count = count, speed = speed }) end,
        function() spawn(E_BULLET, 106, 100, { count = count, speed = speed }) end
    )
end

function sweep_h(dir, col)
    local sx = dir == 1 and -7 or 133
    for i = 0, 3 do
        spawn(
            E_SQUARE, sx, 18 + i * 28, {
                vx = dir * 1.9, size = 10,
                duration_frames = 85,
                color = col or C_PINK,
                warning = false
            }
        )
        wait_frames(14)
    end
end

function sweep_v(dir, col)
    local sy = dir == 1 and -7 or 133
    for i = 0, 3 do
        spawn(
            E_SQUARE, 18 + i * 28, sy, {
                vy = dir * 1.9, size = 10,
                duration_frames = 85,
                color = col or C_PINK,
                warning = false
            }
        )
        wait_frames(14)
    end
end

function bullet_rain(n, spd)
    spd = spd or 1.5
    for i = 1, n do
        spawn(
            E_BULLET, 10 + i * flr(108 / n), -4, {
                vy = spd + rnd(0.5), size = 1,
                duration_frames = 110
            }
        )
        wait_frames(7)
    end
end