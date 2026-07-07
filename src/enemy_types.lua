function spw(cfg)
    cfg = cfg or {}
    local etype, x, y = cfg.enemy_type, cfg.x, cfg.y
    cfg.enemy_type, cfg.x, cfg.y = nil, nil, nil
    return spawn(etype, x, y, cfg)
end

function _dist(i, n, minv, maxv, random)
    return random
            and rnd(maxv - minv) + minv
            or minv + (i - 1) * (maxv - minv) \ max(1, n - 1)
end

function _square_perimeter_pt(cx, cy, r, t)
    -- t en [0,1)
    local d = t * (8 * r)
    if d < 2 * r then
        return cx - r + d, cy - r
    elseif d < 4 * r then
        d -= 2 * r
        return cx + r, cy - r + d
    elseif d < 6 * r then
        d -= 4 * r
        return cx + r - d, cy + r
    else
        d -= 6 * r
        return cx - r, cy + r - d
    end
end

function _spw_pos(pattern, i, n, cfg)
    if pattern == "perimeter" then
        return _square_perimeter_pt(
            64, 64,
            cfg.radius or 46,
            cfg.random and rnd(1) or (i - 1) / n
        )
    end
    if pattern == "circle" then
        local r = cfg.radius or 50
        return 64 + cos((i - 1) / n) * r, 64 + sin((i - 1) / n) * r
    end
    if pattern == "row" then
        local m = cfg.margin or 10
        return _dist(i, n, m, 128 - m, cfg.random), cfg.row_y or -4
    end

    if pattern == "column" then
        local m = cfg.margin or 10
        return cfg.column_x or -4, _dist(i, n, m, 128 - m, cfg.random)
    end
    if pattern == "point" then
        return cfg.x or 64, cfg.y or 64
    end
    return nil, nil
end

function spw_loop(cfg)
    cfg = cfg or {}

    if cfg.repeat_every then
        return meanwhile(function()
            while true do
                _spw_loop_body(cfg)
                wait_frames(cfg.repeat_every)
            end
        end)
    end

    if cfg.meanwhile then
        return meanwhile(function() _spw_loop_body(cfg) end)
    end

    _spw_loop_body(cfg)
end

function _spw_loop_body(cfg)
    local n = cfg.n or 6
    local etype = cfg.enemy_type
    local pattern = cfg.pattern

    local function make_cfg(i)
        local s = _merge({}, cfg)
        if cfg.explode then
            local a = (cfg.angle_offset or 0) + (i - 1) / n
            local spd = cfg.speed or 1.5
            s.vx = cos(a) * spd
            s.vy = sin(a) * spd
        end
        return s
    end

    if cfg.parallel then
        local coros = {}
        for i = 1, n do
            local x, y = _spw_pos(pattern, i, n, cfg)
            local s = make_cfg(i)
            s.delay_spawn = (cfg.stagger or 0) * (i - 1)
            add(coros, meanwhile(function() spawn(etype, x, y, s) end))
        end
        for co in all(coros) do
            wait_until_pattern_finished(co)
        end
    else
        for i = 1, n do
            local x, y = _spw_pos(pattern, i, n, cfg)
            spawn(etype, x, y, make_cfg(i))
            wait_frames(cfg.spawn_interval or 15)
        end
    end
end

EMIT_DEFAULT = "enemy_type=E_CIRCLE;size=4;warning=false;ease_move=out_quad;duration_frames=30;hold_frames=20;flicker=true;burst=true"

function emit(cfg)
    return spw(_merge(_kv_parts(split(EMIT_DEFAULT, ";")), cfg or {}))
end