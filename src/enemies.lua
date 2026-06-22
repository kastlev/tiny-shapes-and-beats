-- ============================
-- enemy types
-- each type only defines how it's drawn;
-- growth/lifetime is shared logic in update_enemies()
-- ============================
enemy_types = {
    [EK_CIRCLE] = { draw = function(e) circfill(e.x, e.y, e.tam, e.color) end },
    [EK_RING] = { draw = function(e) circ(e.x, e.y, e.tam, e.color) end },
    [EK_SQUARE] = { draw = function(e) rectfill(e.x - e.tam, e.y - e.tam, e.x + e.tam, e.y + e.tam, e.color) end },
    [EK_LINE] = { draw = function(e) rectfill(e.x - e.len / 2, e.y - e.tam, e.x + e.len / 2, e.y + e.tam, e.color) end },
    [EK_WARN] = { draw = function(e) circ(e.x, e.y, e.tam, C_DARK_PINK) end },
    [EK_BULLET] = { draw = function(e) pset(e.x, e.y, e.color) end }
}

-- ============================
-- enemy spawner
-- ============================
enemies = {}

function spawn_enemy(kind, x, y, params)
    params = params or {}

    local e = {
        kind = kind,

        x = x,
        y = y,

        tam = params.start_size or params.size or 2,
        max_tam = params.end_size or params.size or 12,

        grow = params.grow or false,

        growth_rate = params.growth_rate or 0.2,

        duration_frames = params.duration_frames or 30,

        color = params.color or C_PINK,

        age = 0,
        alive = true
    }

    add(enemies, e)

    return e
end

function update_enemies()
    for e in all(enemies) do
        e.age += 1

        -- movimiento (solo proyectiles)
        if e.vx then e.x += e.vx end
        if e.vy then e.y += e.vy end

        -- crecimiento
        if e.grow then
            e.tam = min(
                e.max_tam,
                e.tam + e.growth_rate
            )

        end
        -- muerte por tiempo o por salir de pantalla
        local out = e.x < -8 or e.x > 136 or e.y < -8 or e.y > 136
        if e.age > e.duration_frames or out then
            e.alive = false
            del(enemies, e)
        end
    end
end

function draw_enemies()
    for e in all(enemies) do
        local t = enemy_types[e.kind]
        if t then t.draw(e) end
    end
end

-- spawn un burst de count proyectiles desde (x,y) en todas direcciones
-- pico-8: cos/sin reciben 0..1 en vez de radianes
function spawn_burst(x, y, count, params)
    params = params or {}
    local speed = params.speed or 1.5
    for i = 0, count - 1 do
        local angle = i / count
        spawn_enemy(
            EK_BULLET, x, y, {
                vx = cos(angle) * speed,
                vy = sin(angle) * speed,
                tam = 1,
                max_tam = 1,
                growth_rate = 0,
                duration_frames = params.duration_frames or 70,
                color = params.color or C_PINK
            }
        )
    end
end