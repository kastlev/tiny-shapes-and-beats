active_patterns = {}
checkpoint_fast_forward_frames = 0

function run_level(fn)
  active_patterns = {}
  local co = cocreate(fn)
  add(active_patterns, co)
  return co
end

function meanwhile(fn)
  local co = cocreate(fn)
  add(active_patterns, co)
  return co
end

function update_active_patterns()
  for co in all(active_patterns) do
    if costatus(co) == "dead" then
      del(active_patterns, co)
    else
      local ok, err = coresume(co)
      assert(ok, err)
    end
  end
end

function wait_frames(n)
  if checkpoint_fast_forward_frames >= n then
    checkpoint_fast_forward_frames -= n
    return
  elseif checkpoint_fast_forward_frames > 0 then
    n -= checkpoint_fast_forward_frames
    checkpoint_fast_forward_frames = 0
  end

  for i = 1, n do
    yield()
  end
end

function wait_until_enemy_dead(e)
  if checkpoint_fast_forward_frames > 0 then
    checkpoint_fast_forward_frames -= enemy_remaining_frames(e)
    if checkpoint_fast_forward_frames < 0 then
      checkpoint_fast_forward_frames = 0
    end
    if e then e.alive = false end
    return
  end

  while e and e.alive do
    yield()
  end
end

function wait_for_clear()
  if checkpoint_fast_forward_frames > 0 then
    local skip = 0
    for e in all(enemies) do
      skip = max(skip, enemy_remaining_frames(e))
    end

    checkpoint_fast_forward_frames -= skip
    if checkpoint_fast_forward_frames < 0 then
      checkpoint_fast_forward_frames = 0
    end

    enemies = {}
    return
  end

  while #enemies > 0 do
    yield()
  end
end

function wait_until_pattern_finished(co)
  if checkpoint_fast_forward_frames > 0 then
    del(active_patterns, co)
    while costatus(co) != "dead" and checkpoint_fast_forward_frames > 0 do
      local ok, err = coresume(co)
      assert(ok, err)
    end
    if costatus(co) == "dead" then return end
    add(active_patterns, co)
  end
  while costatus(co) != "dead" do
    local ok, err = coresume(co)
    assert(ok, err)
    yield()
  end
end

function wait_for_input(btn_id)
  if checkpoint_fast_forward_frames > 0 then
    return
  end

  btn_id = btn_id or 5
  while not btnp(btn_id) do
    yield()
  end
end

function wait_for_card()
  if checkpoint_fast_forward_frames > 0 then
    return
  end

  while not card_done() do
    yield()
  end
end
function wait_for_orb()
  if checkpoint_fast_forward_frames > 0 then
    return
  end

  while not orb_collected() do
    yield()
  end
end

function sync(...)
  local cos = {}
  for _, fn in ipairs({ ... }) do
    add(cos, meanwhile(fn))
  end
  for co in all(cos) do
    wait_until_pattern_finished(co)
  end
end

function enemy_remaining_frames(e)
  return max(0, (e.duration_frames or 0) + (e.hold_frames or 0) - (e.age or 0))
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
    local warn_size = params.size or 2
    local we = spawn_enemy(
      etype, x, y, {
        size = warn_size,
        size_max = warn_size,
        fill = params.fill,
        color = params.warning_color or C_DARK_PINK,
        duration_frames = params.warning_time or DEFAULT_WARNING_TIME,
        hold_frames = params.hold_frames or 0,
        len = params.len or 80,
        ang = params.ang or 0,
        ang_vel = 0
      }
    )
    wait_until_enemy_dead(we)
  end

  if is_burst then
    local speed = params.speed or 1.5
    local bsize = params.size or 1
    local offset = params.angle_offset or 0
    for i = 0, params.count - 1 do
      local a = offset + i / params.count
      spawn_enemy(
        E_BULLET, x, y, {
          vx = cos(a) * speed,
          vy = sin(a) * speed,
          size = bsize,
          duration_frames = params.duration_frames or 70,
          color = params.color or C_PINK
        }
      )
    end
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
      color = params.color or C_PINK,
      vx = params.vx,
      vy = params.vy,
      delay_move = params.delay_move or 0,
      target_x = params.target_x,
      target_y = params.target_y,
      ease_move = params.ease_move or "linear",
      lerp_factor = params.lerp_factor or 0.1,
      len = params.len or 80,
      ang = params.ang or 0,
      ang_vel = params.ang_vel or 0
    }
  )
end