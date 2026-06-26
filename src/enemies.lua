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
  [E_LINE] = {
    draw = function(e)
      local col = enemy_color(e)
      local dx, dy = cos(e.ang) * e.len, sin(e.ang) * e.len
      local x2, y2 = e.x + dx, e.y + dy
      local px, py = -sin(e.ang), cos(e.ang)
      for t = -e.size, e.size do
        line(e.x + px * t, e.y + py * t, x2 + px * t, y2 + py * t, col)
      end
    end
  },
  [E_LINE_BI] = {
    draw = function(e)
      local col = enemy_color(e)
      local dx, dy = cos(e.ang), sin(e.ang)
      local px, py = -sin(e.ang), cos(e.ang)
      for t = -e.size, e.size do
        line(
          e.x - dx * e.len + px * t, e.y - dy * e.len + py * t,
          e.x + dx * e.len + px * t, e.y + dy * e.len + py * t, col
        )
      end
    end
  },
  [E_CROSS] = {
    draw = function(e)
      local col = enemy_color(e)
      local function arm(a)
        local dx, dy = cos(a), sin(a)
        local px, py = -dy, dx
        for t = -e.size, e.size do
          line(
            e.x - dx * e.len + px * t, e.y - dy * e.len + py * t,
            e.x + dx * e.len + px * t, e.y + dy * e.len + py * t, col
          )
        end
      end
      arm(e.ang)
      arm(e.ang + 0.25)
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

-- unico lugar que resuelve color/flicker cuando no se especifico nada.
-- base color y flicker comparten el mismo punto de verdad.
function enemy_color(e)
  if e.flicker then
    local colors = e.flicker_colors or DEFAULT_FLICKER_COLORS
    local rate = e.flicker_rate or DEFAULT_FLICKER_RATE
    local i = (e.age \ rate % #colors) + 1
    return colors[i]
  end
  return e.color or C_PINK
end

function enemy_remaining_frames(e)
  return max(0, (e.duration_frames or 0) + (e.hold_frames or 0) - (e.age or 0))
end

-- unico lugar que sabe armar un anillo de E_BULLET: cuantas, a que
-- velocidad, desde que angulo, si no se especifica nada. usado tanto
-- por el burst inmediato de spawn() como por el burst-al-morir.
function fire_bullet_ring(x, y, count, speed, angle_offset, bullet_settings)
  count = count or DEFAULT_BURST_COUNT
  speed = speed or DEFAULT_BULLET_SPEED
  angle_offset = angle_offset or 0
  bullet_settings = bullet_settings or {}

  for i = 0, count - 1 do
    local a = angle_offset + i / count
    spawn_enemy(
      E_BULLET, x, y, {
        vx = cos(a) * speed,
        vy = sin(a) * speed,
        size = bullet_settings.size,
        duration_frames = bullet_settings.duration_frames,
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

  local default_size = enemy_type == E_BULLET and DEFAULT_BULLET_SIZE or DEFAULT_ENEMY_SIZE
  local s0 = settings.size or default_size
  local s1 = settings.size_max or s0

  local grow_mode = "px"
  if settings.grow_lerp ~= nil then
    grow_mode = "lerp"
  elseif settings.ease_grow ~= nil then
    grow_mode = "curve"
  end

  local e = {
    type = enemy_type,
    x = x, y = y,

    vx = settings.vx,
    vy = settings.vy,
    delay_move = settings.delay_move or 0,
    delay_move_total = settings.delay_move or 0,

    origin_x = x,
    origin_y = y,
    target_x = settings.target_x,
    target_y = settings.target_y,
    ease_move = settings.ease_move, -- nil ok: _ease() ya defaultea a linear
    lerp_factor = settings.lerp_factor or DEFAULT_MOVE_LERP,

    fill = settings.fill ~= false,
    shape = settings.shape, -- nil ok: el draw trata todo lo que no sea "square" como circulo
    size = s0,
    size_start = s0,
    max_size = s1,
    grow = s1 > s0,
    grow_mode = grow_mode,
    grow_px = settings.grow_px or DEFAULT_GROWTH_RATE,
    grow_lerp = settings.grow_lerp or DEFAULT_GROW_LERP,
    ease_grow = settings.ease_grow, -- nil ok: _ease() ya defaultea a linear

    duration_frames = settings.duration_frames or DEFAULT_DURATION_FRAMES,
    hold_frames = settings.hold_frames or 0,
    color = settings.color, -- nil ok: enemy_color() resuelve a C_PINK
    len = settings.len or DEFAULT_LINE_LEN,
    ang = settings.ang or 0,
    ang_vel = settings.ang_vel or 0,
    age = 0,
    alive = true,

    flicker = settings.flicker or false,
    flicker_colors = settings.flicker_colors, -- nil ok: enemy_color() resuelve
    flicker_rate = settings.flicker_rate, -- nil ok: enemy_color() resuelve

    -- burst: campo explicito, no implicito por burst_count (igual que flicker)
    burst = settings.burst or false,
    burst_count = settings.burst_count, -- nil ok: fire_bullet_ring() resuelve
    burst_speed = settings.burst_speed, -- nil ok: fire_bullet_ring() resuelve
    burst_angle_offset = settings.burst_angle_offset, -- nil ok: fire_bullet_ring() resuelve
    burst_size = settings.burst_size, -- nil ok: spawn_enemy() del hijo resuelve
    burst_color = settings.burst_color, -- nil ok: enemy_color() del hijo resuelve
    burst_duration_frames = settings.burst_duration_frames, -- nil ok: spawn_enemy() del hijo resuelve
    burst_shape = settings.burst_shape -- nil ok: draw del hijo resuelve
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

    if e.grow then
      if e.grow_mode == "lerp" then
        e.size += (e.max_size - e.size) * e.grow_lerp
      elseif e.grow_mode == "curve" then
        local t = min(1, e.age / e.duration_frames)
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
    if t then t.draw(e) end
  end
end

------------------------------------------------------
-- spawn(tipo, x, y, params)
--
-- size            radio inicial (default 10)
-- size_max        radio final — implica grow automaticamente
-- fill            true=relleno false=contorno (default true)
-- color           (default C_PINK)
-- duration_frames (default 40)
-- hold_frames      frames extra quieto en estado final antes de morir (default 0)

--
-- crecimiento — elegir uno:
--   grow_px    crece N pixeles por frame hasta size_max
--              (default DEFAULT_GROWTH_RATE si hay size_max)
--   ease_grow  nombre de curva en ease_fns — llega a size_max en duration_frames
--              ej: "out_quad" "out_bounce" "out_elastic"
--   grow_lerp  factor 0.0–1.0 — cada frame se acerca ese % al size_max
--              ej: 0.1 = acercamiento suave, 0.3 = llega rapido
--
-- movimiento — elegir uno:
--   vx, vy       velocidad constante por frame
--   target_x/y   destino — llega al final de duration_frames
--   delay_move   frames quieto antes de empezar a moverse
--
-- ease_move    curva para target_x/y — nombre en ease_fns o "lerp"
-- lerp_factor  factor para ease_move="lerp" (default 0.1)
--
-- lineas:  ang, ang_vel, len
-- burst:   count, speed, angle_offset, size
-- warning: warning, warning_time, warning_color

function spawn(etype, x, y, params)
  params = params or {}

  local is_burst = params.count ~= nil
  local is_bullet = etype == E_BULLET

  local do_warn = params.warning
  if do_warn == nil then
    do_warn = not is_burst and not is_bullet
  end

  if do_warn then
    local warn_size = params.size or DEFAULT_WARNING_SIZE
    local we = spawn_enemy(
      etype, x, y, {
        size = warn_size,
        size_max = warn_size,
        fill = params.fill,
        color = params.warning_color or DEFAULT_WARNING_COLOR,
        duration_frames = params.warning_time or DEFAULT_WARNING_TIME,
        hold_frames = params.hold_frames or 0,
        len = params.len, -- spawn_enemy ya defaultea, no repetir aqui
        ang = params.ang, -- idem
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

  local base = params.size or DEFAULT_SHAPE_SIZE
  local has_max = params.size_max ~= nil

  return spawn_enemy(
    etype, x, y, {
      size = base,
      size_max = has_max and params.size_max or base,
      grow_px = params.grow_px,
      ease_grow = params.ease_grow,
      grow_lerp = params.grow_lerp,
      fill = params.fill,
      duration_frames = params.duration_frames or DEFAULT_SHAPE_DURATION,
      hold_frames = params.hold_frames or 0,
      color = params.color,
      vx = params.vx,
      vy = params.vy,
      delay_move = params.delay_move or 0,
      target_x = params.target_x,
      target_y = params.target_y,
      ease_move = params.ease_move,
      lerp_factor = params.lerp_factor or DEFAULT_MOVE_LERP,
      len = params.len,
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


-- bulletspawner(x, y, target_x, target_y, params)
-- entra desde fuera de pantalla parpadeando pink/white, desacelera
-- hasta target_x/y, se queda quieto hold_frames, y al morir dispara
-- un burst de E_BULLET desde su posicion final.
-- bullet_emitter(x, y, target_x, target_y, params)
-- entra desde fuera de pantalla parpadeando, desacelera hasta
-- target_x/y, se queda quieto hold_frames, y al morir dispara
-- un anillo de E_BULLET desde su posicion final.

function bullet_emitter(x, y, target_x, target_y, params)
  params = params or {}
  return spawn(
    E_CIRCLE, x, y, {
      size = params.size or DEFAULT_EMITTER_SIZE,
      color = params.color,
      shape = params.shape,
      warning = false,

      target_x = target_x,
      target_y = target_y,
      ease_move = params.ease_move or "out_quad",
      duration_frames = params.duration_frames or DEFAULT_EMITTER_DURATION,
      hold_frames = params.hold_frames or DEFAULT_EMITTER_HOLD,

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
