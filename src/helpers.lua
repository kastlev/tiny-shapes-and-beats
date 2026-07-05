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
            E_SQUARE, sx, 18 + i * 28,
            ptbl(split "vx,size,duration_frames,color,warning", { dir * 1.9, 10, 85, col or C_PINK, false })
        )
        wait_frames(14)
    end
end

function sweep_v(dir, col)
    local sy = dir == 1 and -7 or 133
    for i = 0, 3 do
        spawn(
            E_SQUARE, 18 + i * 28, sy,
            ptbl(split "vy,size,duration_frames,color,warning", { dir * 1.9, 10, 85, col or C_PINK, false })
        )
        wait_frames(14)
    end
end

function bullet_rain(n, spd)
    spd = spd or 1.5
    for i = 1, n do
        spawn(
            E_BULLET, 10 + i * 108 \ n, -4, {
                vy = spd + rnd(0.5), size = 1,
                duration_frames = 110
            }
        )
        wait_frames(7)
    end
end