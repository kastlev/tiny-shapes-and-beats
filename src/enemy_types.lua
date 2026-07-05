function spw_ring_expand(n, size_max, fill, ease, grow_px, duration_frames) --
    for i = 1, n do
        spawn(
            E_CIRCLE, 10 + rnd(108), 10 + rnd(108), {
                size = 1,
                size_max = size_max or 200,
                fill = fill or false,
                grow_px = 1.8,
                ease_grow = ease,
                duration_frames = 60,
                warning_time = 10
            }
        )
        wait_frames(15)
    end
end

function spw_perimeter(n, params)
    n = n or 4
    local settings = _merge({ size = 20, warning_time = 40 }, params)
    local pts = n <= 4 and { { 18, 18 }, { 109, 18 }, { 18, 109 }, { 109, 109 } } or {
        { 18, 18 }, { 64, 18 }, { 109, 18 },
        { 18, 64 }, { 109, 64 },
        { 18, 109 }, { 64, 109 }, { 109, 109 }
    }

    local coros = {}
    for i = 1, n do
        local b = pts[((i - 1) % #pts) + 1]
        add(
            coros, meanwhile(function()
                spawn(settings.enemy_type, b[1], b[2], settings)
            end)
        )
    end
    for co in all(coros) do
        wait_until_pattern_finished(co)
    end
end

function spw_stalker(overrides)
    return spawn(
        E_CIRCLE, 0, 0, _merge(
            {
                size = 8,
                near_player = true,
                near_range = 0,
                delay_move = 20,
                chase = true,
                chase_speed = 0.6,
                chase_turn = 0.05,
                duration_frames = 100,
            }, overrides
        )
    )
end

-- RUSHER: aparece lejos, sin telegraph, y se lanza rapido y agresivo
-- apenas nace. mas chico, mas urgente que el stalker.
function spawn_rusher(overrides)
    return spawn(
        E_CIRCLE, 0, 0, _merge(
            {
                size = 5,
                near_player = true,
                near_range = 60,
                delay_move = 0,
                chase = true,
                chase_speed = 1.4,
                chase_turn = 0.15,
                duration_frames = 70,
                warning = false,
                color = C_RED
            }, overrides
        )
    )
end

-- SENTINEL: no se mueve, crece lento como advertencia, y al final
-- dispara un anillo de balas. cuadrado outline (distinto de los que
-- persiguen, para que el jugador lo lea como "amenaza estatica").
function spawn_sentinel(x, y, overrides)
    return spawn(
        E_SQUARE, x, y, _merge(
            {
                size = 4,
                size_max = 10,
                ease_grow = "out_quad",
                duration_frames = 60,
                fill = false,
                color = C_ORANGE,
                burst = true,
                burst_count = 10,
                burst_speed = 1.6
            }, overrides
        )
    )
end

-- DRIFTER: cruza la pantalla en linea recta a velocidad constante,
-- sin perseguir. contorno, no relleno — se lee como "de fondo",
-- menos urgente que stalker/rusher.
function spawn_drifter(x, y, vx, vy, overrides)
    return spawn(
        E_CIRCLE, x, y, _merge(
            {
                size = 6,
                vx = vx, vy = vy,
                duration_frames = 140,
                fill = false,
                warning = false,
                color = C_LAVENDER
            }, overrides
        )
    )
end