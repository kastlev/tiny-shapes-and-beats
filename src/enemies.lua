enemy_types = {
  [E_CIRCLE] = {
    draw = function(e)
      local col = enemy_color(e)
      if e.fill then
        circfill(e.x, e.y, e.size, col)
      else
        circ(e.x, e.y, e.size, col)
      end
    end
  },
  [E_SQUARE] = {
    draw = function(e)
      local col = enemy_color(e)
      local s = e.size
      if e.fill then
        rectfill(e.x - s, e.y - s, e.x + s, e.y + s, col)
      else
        rect(e.x - s, e.y - s, e.x + s, e.y + s, col)
      end
    end
  },
  [E_LINE_BI] = {
    draw = function(e)
      line_c(e.x, e.y, e.len, e.size * 2, e.ang, enemy_color(e), true)
    end
  },
  [E_CROSS] = {
    draw = function(e)
      local col = enemy_color(e)
      line_c(e.x, e.y, e.len, e.size * 2, e.ang, col, true)
      line_c(e.x, e.y, e.len, e.size * 2, e.ang + 0.25, col, true)
    end
  },
  [E_BULLET] = {
    draw = function(e)
      local remaining = e.duration_frames - e.age
      local col = remaining <= 8 and C_DARK_PINK or enemy_color(e)
      local fx, fy = flr(e.x), flr(e.y)

      if e.shape == "square" then
        local s = e.size
        rectfill(fx - s, fy - s, fx + s, fy + s, col)
      else
        circfill(fx, fy, e.size, col)
      end
    end
  }
}

enemies = {}

function enemy_color(e)
  if e.flicker then
    local colors = e.flicker_colors or { C_PINK, C_WHITE }
    local rate = e.flicker_rate or 4
    local i = (e.age \ rate % #colors) + 1
    return colors[i]
  end
  return e.color or C_PINK
end

function enemy_remaining_frames(e)
  return max(0, (e.duration_frames or 0) + (e.hold_frames or 0) - (e.age or 0))
end

function fire_bullet_ring(x, y, count, speed, angle_offset, bullet_settings)
  count = count or 8
  speed = speed or 1.5
  angle_offset = angle_offset or 0
  bullet_settings = bullet_settings or {}

  for i = 0, count - 1 do
    local a = angle_offset + i / count
    spawn_enemy(
      E_BULLET, x, y, {
        vx = cos(a) * speed,
        vy = sin(a) * speed,
        size = bullet_settings.size,
        duration_frames = bullet_settings.duration_frames or 80,
        color = bullet_settings.color,
        shape = bullet_settings.shape
      }
    )
  end
end

function spawn_bullet_burst(e)
  fire_bullet_ring(
    e.x, e.y, e.burst_count, e.burst_speed, e.burst_angle_offset, {
      size = e.burst_size,
      duration_frames = e.burst_duration_frames,
      color = e.burst_color,
      shape = e.burst_shape
    }
  )
end

function spawn_enemy(enemy_type, x, y, settings)
  settings = settings or {}

  local s0 = settings.size or (enemy_type == E_BULLET and 1 or 2)
  local s1 = settings.size_max or s0

  local grow_mode = "px"
  if settings.grow_lerp ~= nil then
    grow_mode = "lerp"
  elseif settings.ease_grow ~= nil then
    grow_mode = "curve"
  end

  local e = {
    type = enemy_type or E_CIRCLE,
    x = x, y = y,

    vx = settings.vx,
    vy = settings.vy,
    delay_move = settings.delay_move or 0,
    delay_move_total = settings.delay_move or 0,
    delay_grow = settings.delay_grow or 0,
    delay_grow_total = settings.delay_grow or 0,
    origin_x = x,
    origin_y = y,
    target_x = settings.target_x,
    target_y = settings.target_y,
    ease_move = settings.ease_move,
    lerp_factor = settings.lerp_factor or 0.1,
    chase = settings.chase or false,
    chase_speed = settings.chase_speed or 1.6,
    chase_turn = settings.chase_turn or 0.06,
    fill = settings.fill ~= false,
    shape = settings.shape,
    size = s0,
    size_start = s0,
    max_size = s1,
    grow = s1 > s0,
    grow_mode = grow_mode,
    grow_px = settings.grow_px or 0.5,
    grow_lerp = settings.grow_lerp or 0.1,
    ease_grow = settings.ease_grow,

    duration_frames = settings.duration_frames or 30,
    hold_frames = settings.hold_frames or 0,
    color = settings.color,
    len = settings.len or 80,
    ang = settings.ang or 0,
    ang_vel = settings.ang_vel or 0,
    age = 0,
    alive = true,

    flicker = settings.flicker or false,
    flicker_colors = settings.flicker_colors,
    flicker_rate = settings.flicker_rate,

    burst = settings.burst or false,
    burst_count = settings.burst_count,
    burst_speed = settings.burst_speed,
    burst_angle_offset = settings.burst_angle_offset,
    burst_size = settings.burst_size,
    burst_color = settings.burst_color,
    burst_duration_frames = settings.burst_duration_frames,
    burst_shape = settings.burst_shape
  }

  if checkpoint_fast_forward_frames > 0 then
    e.alive = false
    return e
  end

  add(enemies, e)
  return e
end

function update_enemies()
  for e in all(enemies) do
    e.age += 1

    if e.delay_move > 0 then
      e.delay_move -= 1
    elseif e.chase then
      local dx, dy = p.x - e.x, p.y - e.y
      local d = sqrt(dx * dx + dy * dy)
      local tx, ty = 0, 0
      if d > 0.01 then
        tx, ty = (dx / d) * e.chase_speed, (dy / d) * e.chase_speed
      end
      e.vx = lerp_to(e.vx or 0, tx, e.chase_turn, 0.02)
      e.vy = lerp_to(e.vy or 0, ty, e.chase_turn, 0.02)
      e.x += e.vx
      e.y += e.vy
    elseif e.target_x ~= nil or e.target_y ~= nil then
      if e.ease_move == "lerp" then
        if e.target_x ~= nil then e.x += (e.target_x - e.x) * e.lerp_factor end
        if e.target_y ~= nil then e.y += (e.target_y - e.y) * e.lerp_factor end
      else
        local move_frames = e.duration_frames - e.delay_move_total
        local t = min(1, (e.age - e.delay_move_total) / move_frames)
        local et = _ease(t, e.ease_move)
        if e.target_x ~= nil then e.x = e.origin_x + (e.target_x - e.origin_x) * et end
        if e.target_y ~= nil then e.y = e.origin_y + (e.target_y - e.origin_y) * et end
      end
    else
      if e.vx then e.x += e.vx end
      if e.vy then e.y += e.vy end
    end

    if e.ang_vel != 0 then e.ang += e.ang_vel end

    if e.delay_grow > 0 then
      e.delay_grow -= 1
    elseif e.grow then
      if e.grow_mode == "lerp" then
        e.size += (e.max_size - e.size) * e.grow_lerp
      elseif e.grow_mode == "curve" then
        local growth_frames = max(1, e.duration_frames - e.delay_grow_total)
        local t = min(1, (e.age - e.delay_grow_total) / growth_frames)
        e.size = e.size_start + (e.max_size - e.size_start) * _ease(t, e.ease_grow)
      else
        e.size = min(e.max_size, e.size + e.grow_px)
      end
    end

    local out = e.x < -8 or e.x > 136 or e.y < -8 or e.y > 136
    if e.age > e.duration_frames + e.hold_frames or out then
      if e.burst and not out then
        spawn_bullet_burst(e)
      end
      e.alive = false
      del(enemies, e)
    end
  end
end

function draw_enemies()
  for e in all(enemies) do
    local t = enemy_types[e.type]
    assert(t, "unknown enemy type: " .. tostr(e.type))
    t.draw(e)
  end
end

-- etype          default E_CIRCLE si se omite (nil)
-- x, y           default posicion random en pantalla si se omiten (nil)
--                (near_player, si esta activo, pisa este default)
--
-- size
-- size_max
-- fill
-- color
-- duration_frames
-- hold_frames      frames extra quieto en estado final antes de morir
--
-- crecimiento — elegir uno:
--   grow_px    crece N pixeles por frame hasta size_max
--   ease_grow  nombre de curva en ease_fns — llega a size_max en duration_frames
--   grow_lerp  factor 0.0–1.0 — cada frame se acerca ese % al size_max
-- delay_grow   frames antes de empezar a crecer (independiente de delay_move)
--
-- movimiento — elegir uno:
--   vx, vy       velocidad constante
--   target_x/y
--   chase        persigue al jugador (chase_speed, chase_turn)
-- delay_move     frames quieto antes de moverse (independiente de delay_grow)
-- ease_move      curva para target_x/y — nombre en ease_fns o "lerp"
-- lerp_factor    factor para ease_move="lerp" (default 0.1)
--
-- near_player, near_range   sobreescribe x,y a una posicion cercana al jugador
--                           (resuelto UNA vez, antes del warning, para que
--                            warning y enemigo real compartan posicion)
--
-- lineas:  ang, ang_vel, len
-- burst:   count, speed, angle_offset, size, burst_shape
--          NOTA: burst siempre instancia E_BULLET internamente
--          (fire_bullet_ring), sin importar el etype del emisor.
--          usar burst_shape="square" para variar el aspecto visual
--          de las balas, no etype.
-- warning: warning, warning_time, warning_color
-- flicker: flicker, flicker_colors, flicker_rate
-- shape

function spawn(etype, x, y, params)
  params = params or {}
  etype = etype or E_CIRCLE
  x = x or (10 + rnd(108))
  y = y or (10 + rnd(108))

  if params.near_player then
    local range = params.near_range or 20
    x = mid(6, p.x + p.w / 2 + rnd(range * 2) - range, 121)
    y = mid(6, p.y + p.h / 2 + rnd(range * 2) - range, 121)
  end

  local is_burst = params.count ~= nil
  local is_bullet = etype == E_BULLET

  local do_warn = params.warning
  if do_warn == nil then
    do_warn = not is_burst and not is_bullet
  end

  if do_warn then
    local warn_size = params.size or 10
    local we = spawn_enemy(
      etype, x, y, {
        size = warn_size,
        size_max = warn_size,
        fill = params.fill,
        color = params.warning_color or C_DARK_PINK,
        duration_frames = params.warning_time or 20,
        hold_frames = params.hold_frames or 0,
        len = params.len,
        ang = params.ang,
        ang_vel = 0
      }
    )
    wait_until_enemy_dead(we)
  end

  if is_burst then
    fire_bullet_ring(
      x, y, params.count, params.speed, params.angle_offset, {
        size = params.size,
        duration_frames = params.duration_frames,
        color = params.color,
        shape = params.shape
      }
    )
    return
  end

  local base = params.size or 10
  local has_max = params.size_max ~= nil

  return spawn_enemy(
    etype, x, y, {
      size = base,
      size_max = has_max and params.size_max or base,
      grow_px = params.grow_px,
      ease_grow = params.ease_grow,
      grow_lerp = params.grow_lerp,
      fill = params.fill,
      duration_frames = params.duration_frames or 40,
      hold_frames = params.hold_frames or 0,
      color = params.color,
      vx = params.vx,
      vy = params.vy,
      delay_move = params.delay_move or 0,
      delay_grow = params.delay_grow or 0,
      target_x = params.target_x,
      target_y = params.target_y,
      ease_move = params.ease_move,
      lerp_factor = params.lerp_factor,
      len = params.len,
      chase = params.chase,
      chase_speed = params.chase_speed,
      chase_turn = params.chase_turn,
      ang = params.ang,
      ang_vel = params.ang_vel,
      shape = params.shape,

      flicker = params.flicker,
      flicker_colors = params.flicker_colors,
      flicker_rate = params.flicker_rate,

      burst = params.burst,
      burst_count = params.burst_count,
      burst_speed = params.burst_speed,
      burst_size = params.burst_size,
      burst_color = params.burst_color,
      burst_duration_frames = params.burst_duration_frames,
      burst_angle_offset = params.burst_angle_offset,
      burst_shape = params.burst_shape
    }
  )
end