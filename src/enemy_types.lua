function spw(cfg)
    local e, x, y = cfg.enemy_type, cfg.x, cfg.y
    cfg.enemy_type, cfg.x, cfg.y = nil, nil, nil
    return spawn(e, x, y, cfg)
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

function _dist(i, n, minv, maxv, random)
    return random
            and rnd(maxv - minv) + minv
            or minv + (i - 1) * (maxv - minv) \ max(1, n - 1)
end

function _spw_pos(pt, i, n, c)
    local m = c.margin or 10
    if pt == "perimeter" then
        return _square_perimeter_pt(64, 64, c.radius or 46, c.random and rnd() or (i - 1) / n)
    elseif pt == "row" then
        return _dist(i, n, m, 128 - m, c.random), c.row_y or -4
    elseif pt == "column" then
        return c.column_x or -4, _dist(i, n, m, 128 - m, c.random)
    elseif pt == "point" then
        return c.x or 64, c.y or 64
    end
end

function spw_loop(cfg)
    local n, coros = cfg.n or 6, {}
    for i = 1, n do
        local x, y = _spw_pos(cfg.pattern, i, n, cfg)
        local s = _merge({}, cfg)

        for k, v in pairs(cfg) do
            if sub(k, 1, 8) == "stagger_" then
                local f = sub(k, 9)
                s[f] = (cfg[f] or 0) + v * (i - 1)
            end
        end

        if cfg.parallel then
            s.delay_spawn = (cfg.stagger or 0) * (i - 1)
            add(coros, meanwhile(function() spawn(cfg.enemy_type, x, y, s) end))
        else
            spawn(cfg.enemy_type, x, y, s)
            wait_frames(cfg.spawn_interval or 15)
        end
    end
    for co in all(coros) do
        wait_until_pattern_finished(co)
    end
end

-- EMIT_DEFAULT_CFG = _kv_parts(split(
--     "enemy_type=E_CIRCLE;size=4;warning=false;ease_move=out_quad;duration_frames=30;hold_frames=20;flicker=true;burst=true",
--     ";"
-- ))

-- function emit(cfg)
--     return spw(_merge(_merge({}, EMIT_DEFAULT_CFG), cfg))
-- end