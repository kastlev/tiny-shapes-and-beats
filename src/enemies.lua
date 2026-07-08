DEATH_WARN_FRAMES = 1
BOUNCE_VARIANCE = 0.03

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
      local col = enemy_color(e)
      local fx, fy = flr(e.x), flr(e.y)
      if e.shape == "square" then
        local s = e.size
        rectfill(fx - s, fy - s, fx + s, fy + s, col)
      else
        circfill(fx, fy, e.size, col)
      end
    end
  },
  [E_HOLE] = {
    draw = function(e)
      local col = enemy_color(e)
      poke(0x5f34, 0x2)
      circfill(e.x, e.y, e.size, col | 0x1800)
      poke(0x5f34, 0x0)
    end
},
}

enemies = {}

function enemy_color(e)
  if e.flicker then
    local c = e.flicker_colors or { C_PINK, C_WHITE }
    return c[e.age \ (e.flicker_rate or 4) % #c + 1]
  end
  return enemy_remaining_frames(e) <= DEATH_WARN_FRAMES
      and C_DARK_PINK
      or e.color or C_PINK
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
    _create_enemy(
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
  trigger_screen_flash(_hit_flash_cfg)
  spawn_hit_particles(x, y, _bounce_particle_cfg)
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
      e.x += e.vx or 0
      e.y += e.vy or 0
    end

    if e.wave then
      local off = sin(e.age * e.wave_freq) * e.wave_amp
      if e.wave_axis == "y" then
        e.y += off - (e.wave_last_off or 0)
      else
        e.x += off - (e.wave_last_off or 0)
      end
      e.wave_last_off = off
    end

    if e.wrap then
      if e.x < -8 then
        e.x = 136
      elseif e.x > 136 then
        e.x = -8
      end

      if e.y < -8 then
        e.y = 136
      elseif e.y > 136 then
        e.y = -8
      end
    elseif e.bounce and (e.vx or e.vy) then
      local bounced = false

      if e.x < 0 then
        e.x = 0
        if e.vx then e.vx = abs(e.vx) end
        bounced = true
      elseif e.x > 128 then
        e.x = 128
        if e.vx then e.vx = -abs(e.vx) end
        bounced = true
      end

      if e.y < 0 then
        e.y = 0
        if e.vy then e.vy = abs(e.vy) end
        bounced = true
      elseif e.y > 128 then
        e.y = 128
        if e.vy then e.vy = -abs(e.vy) end
        bounced = true
      end

      if bounced then
        local jitter = rnd(BOUNCE_VARIANCE * 2) - BOUNCE_VARIANCE
        local ca, sa = cos(jitter), sin(jitter)
        e.vx, e.vy = e.vx * ca - e.vy * sa, e.vx * sa + e.vy * ca

        if e.bounce_speed_mult then
          if e.vx then e.vx *= e.bounce_speed_mult end
          if e.vy then e.vy *= e.bounce_speed_mult end
        end

        if e.bounce_size_mult then
          e.size *= e.bounce_size_mult
        end

        add_trauma(mid(0.1, e.size * 0.02, 0.6))
        spawn_hit_particles(e.x, e.y, _bounce_particle_cfg)
        sfx(5)
      end
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

    local margin = (e.size or 0) + 16
    if e.type == E_LINE_BI or e.type == E_CROSS then
      margin += e.len or 0
    end
    local out = false
    if not e.wrap and not e.bounce then
      out = (e.x < -margin or e.x > 128 + margin or e.y < -margin or e.y > 128 + margin)
    end

    if e.age > e.duration_frames + e.hold_frames or out then
      if e.burst and not out then
        spawn_bullet_burst(e)
      end
      e.alive = false
      del(enemies, e)
    end
  end
end

function draw_warnings()
  for e in all(enemies) do
    if e.is_warning then
      enemy_types[e.type].draw(e)
    end
  end
end

function draw_real_enemies()
  for e in all(enemies) do
    if not e.is_warning then
      enemy_types[e.type].draw(e)
    end
  end
end

function spawn(etype, x, y, params)
  params = params or {}
  if params.delay_spawn and params.delay_spawn > 0 then
    wait_frames(params.delay_spawn)
  end

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
  local sz = params.size or 10

  local do_warn = params.warning
  if do_warn == nil then
    do_warn = not is_burst and not is_bullet
  end

  if do_warn then
    if sz >= 40 then
      add_trauma(0.1)
    end
    wait_until_enemy_dead(_create_enemy(
      etype, x, y, {
        size = sz,
        fill = params.fill,
        color = params.warning_color or C_DARK_PINK,
        duration_frames = params.warning_time or 20,
        hold_frames = params.hold_frames or 0,
        len = params.len,
        ang = params.ang,
        ang_vel = 0,
        is_warning = true
      }
    ))
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

  if params.v_random then
    local ang = rnd(1)
    local vmin, vmax = params.v_speed_min or 1, params.v_speed_max or 3
    local spd = vmin + rnd(vmax - vmin)
    params.vx = cos(ang) * spd
    params.vy = sin(ang) * spd
  end

  params.size = sz
  params.size_max = params.size_max or sz
  params.duration_frames = params.duration_frames or 40

  return _create_enemy(etype, x, y, params)
end

function _create_enemy(enemy_type, x, y, settings)
  settings = settings or {}

  local s0 = settings.size or (enemy_type == E_BULLET and 1 or 2)
  settings.type = enemy_type or E_CIRCLE
  settings.x = x
  settings.y = y

  settings.size = s0
  settings.size_start = s0
  settings.max_size = settings.size_max or s0
  settings.grow = settings.max_size > s0

  settings.origin_x = x
  settings.origin_y = y

  settings.delay_move = settings.delay_move or 0
  settings.delay_move_total = settings.delay_move
  settings.delay_grow = settings.delay_grow or 0
  settings.delay_grow_total = settings.delay_grow

  settings.grow_mode = settings.grow_lerp and "lerp"
      or settings.ease_grow and "curve"
      or "px"

  settings.fill = settings.fill ~= false
  settings.chase = settings.chase or false
  settings.wrap = settings.wrap or false
  settings.bounce = settings.bounce or false
  settings.wave = settings.wave or false
  settings.flicker = settings.flicker or false
  settings.burst = settings.burst or false
  settings.is_warning = settings.is_warning or false
  settings.alive = true
  settings.age = 0

  settings.lerp_factor = settings.lerp_factor or .1
  settings.chase_speed = settings.chase_speed or 1.6
  settings.chase_turn = settings.chase_turn or .06
  settings.grow_px = settings.grow_px or .5
  settings.grow_lerp = settings.grow_lerp or .1
  settings.wave_amp = settings.wave_amp or 10
  settings.wave_freq = settings.wave_freq or .05
  settings.wave_axis = settings.wave_axis or "y"
  settings.duration_frames = settings.duration_frames or 30
  settings.hold_frames = settings.hold_frames or 0
  settings.len = settings.len or 80
  settings.ang = settings.ang or 0
  settings.ang_vel = settings.ang_vel or 0

  add(enemies, settings)
  return settings
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
-- lineas:  ang, ang_vel, len (ang: 0= der  0.125=diagonal  0.25=abajo  0.5=izq  0.75=arriba)
-- burst:   count, speed, angle_offset, size, burst_shape --
--          NOTA: burst siempre instancia E_BULLET internamente
--          (fire_bullet_ring), sin importar el etype del emisor.
--          usar burst_shape="square" para variar el aspecto visual
--          de las balas, no etype.
-- warning: warning, warning_time, warning_color
-- flicker: flicker, flicker_colors, flicker_rate
-- shape