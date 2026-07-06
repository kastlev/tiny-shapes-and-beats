function spw(cfg)
    cfg = cfg or {}
    local etype, x, y = cfg.enemy_type, cfg.x, cfg.y
    cfg.enemy_type, cfg.x, cfg.y = nil, nil, nil
    return spawn(etype, x, y, cfg)
end

-- sentinel: "size=4;size_max=10;ease_grow=out_quad;duration_frames=60;fill=false;burst=true;burst_count=10;burst_speed=1.6" (usar con E_SQUARE)
-- drifter:  "size=6;duration_frames=140;fill=false;warning=false"

PERIMETER_POINTS_4 = { { 18, 18 }, { 109, 18 }, { 18, 109 }, { 109, 109 } }
PERIMETER_POINTS_8 = {
    { 18, 18 }, { 64, 18 }, { 109, 18 },
    { 18, 64 }, { 109, 64 },
    { 18, 109 }, { 64, 109 }, { 109, 109 }
}

function _spw_pos(pattern, i, n)
    if pattern == "perimeter" then
        local pts = n <= 4 and PERIMETER_POINTS_4 or PERIMETER_POINTS_8
        local b = pts[((i - 1) % #pts) + 1]
        return b[1], b[2]
    end
    if pattern == "rain" then
        return 10 + (i - 1) * 108 \ max(1, n - 1), -4
    end
    return nil, nil
end

function spw_loop(cfg)
    cfg = cfg or {}
    local n = cfg.n or 6
    local etype = cfg.enemy_type
    local pattern = cfg.pattern

    if cfg.parallel then
        local coros = {}
        for i = 1, n do
            local x, y = _spw_pos(pattern, i, n)
            add(coros, meanwhile(function() spawn(etype, x, y, cfg) end))
        end
        for co in all(coros) do
            wait_until_pattern_finished(co)
        end
    else
        for i = 1, n do
            local x, y = _spw_pos(pattern, i, n)
            spawn(etype, x, y, cfg)
            wait_frames(cfg.spawn_interval or 15)
        end
    end
end

-- function sweep(cfg)
--     cfg = cfg or {}
--     local dir = cfg.dir or 1
--     local horiz = cfg.axis != "v"

--     for i = 0, 3 do
--         local x, y
--         if horiz then
--             x, y = (dir == 1 and -7 or 133), 18 + i * 28
--         else
--             x, y = 18 + i * 28, (dir == 1 and -7 or 133)
--         end
--         spawn(E_SQUARE, x, y, { vx = horiz and dir * 1.9 or nil, vy = not horiz and dir * 1.9 or nil, size = 10, duration_frames = 85, warning = false })
--         wait_frames(14)
--     end
-- end

function bullet_emitter(x, y, target_x, target_y, params)
  params = params or {}
  return spawn(
    params.enemy_type or E_BULLET, x, y, {
      size = params.size or 4,
      color = params.color,
      shape = params.shape,
      warning = false,

      target_x = target_x,
      target_y = target_y,
      ease_move = params.ease_move or "out_quad",
      duration_frames = params.duration_frames or 30,
      hold_frames = params.hold_frames or 20,

      flicker = true,
      flicker_colors = params.flicker_colors,
      flicker_rate = params.flicker_rate,

      burst = true,
      burst_count = params.burst_count,
      burst_speed = params.burst_speed,
      burst_size = params.burst_size,
      burst_color = params.burst_color,
      burst_duration_frames = params.burst_duration_frames,
      burst_angle_offset = params.burst_angle_offset or rnd(1),
      burst_shape = params.burst_shape
    }
  )
end