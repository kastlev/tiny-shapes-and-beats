-- angulos en pico-8: 0.0–1.0 (vueltas, NO grados ni radianes)
-- 0=der  0.125=diagonal  0.25=abajo  0.5=izq  0.75=arriba
-- ang=40 es igual a ang=0 (40 mod 1 = 0), ang_vel=50 = caos

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
      coresume(co)
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

    while costatus(co) != "dead"
        and checkpoint_fast_forward_frames > 0 do
      coresume(co)
    end

    if costatus(co) == "dead" then return end

    add(active_patterns, co)
  end

  while costatus(co) != "dead" do
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
  return max(0, (e.duration_frames or 0) - (e.age or 0))
end
---------- -------------------------------------
-- spawn(tipo, x, y, params)
--
-- params comunes:
--   size            tamaño / radio (default 10)
--   fill            true=relleno false=contorno (default true)
--   color           (default C_PINK)
--   duration_frames (default 40)
--   vx, vy          velocidad por frame (default nil)
--   delay           frames quieto antes de moverse (default 0)
--   grow            crece hasta max_size (default false)
--   max_size, growth_rate
--
-- params para lineas:
--   ang, ang_vel, len
--
-- params para burst (count activa modo burst):
--   count           cantidad de balas
--   speed           velocidad de las balas (default 1.5)
--
-- params de warning:
--   warning         mostrar aviso (default true)
--   warning_time    frames del aviso (default 8)
--   warning_color   (default C_DARK_PINK)
--   warning_size    tamaño del circulo de aviso
--                   (default = size para circulos/squares,
--                    8 para lineas/bullets)

function spawn(etype, x, y, params)
  params = params or {}

  local is_burst = params.count ~= nil
  local is_bullet = etype == E_BULLET

  -- bullets y bursts sin warning por defecto
  local do_warn = params.warning
  if do_warn == nil then
    do_warn = not is_burst and not is_bullet
  end

  if do_warn then
    -- warning tiene el mismo tipo y fill que el enemigo real, solo color dark pink
    local warn_size = params.size or 2
    local we = spawn_enemy(etype, x, y, {
      start_size      = warn_size,
      end_size        = warn_size,
      fill            = params.fill,
      color           = params.warning_color or C_DARK_PINK,
      duration_frames = params.warning_time or DEFAULT_WARNING_TIME,
      len             = params.len or 80,
      ang             = params.ang or 0,
      ang_vel         = 0,  -- no rota durante el warning
    })
    wait_until_enemy_dead(we)
  end

  -- modo burst
  if is_burst then
    local speed  = params.speed or 1.5
    local bsize  = params.size or 1
    local offset = params.angle_offset or 0
    for i = 0, params.count - 1 do
      local a = offset + i / params.count
      spawn_enemy(E_BULLET, x, y, {
        vx              = cos(a) * speed,
        vy              = sin(a) * speed,
        size            = bsize,
        duration_frames = params.duration_frames or 70,
        color           = params.color or C_PINK,
      })
    end
    return
  end

  -- fix grow: start_size/end_size separados para que crezca correctamente
  local base_size = params.size or params.max_size or 10
  local start_s   = params.grow and (params.start_size or 2) or base_size
  local end_s     = params.max_size or base_size

  return spawn_enemy(etype, x, y, {
    start_size      = start_s,
    end_size        = end_s,
    fill            = params.fill,
    grow            = params.grow or false,
    growth_rate     = params.growth_rate or 0.2,
    duration_frames = params.duration_frames or 40,
    color           = params.color or C_PINK,
    vx              = params.vx,
    vy              = params.vy,
    delay           = params.delay or 0,
    len             = params.len or 80,
    ang             = params.ang or 0,
    ang_vel         = params.ang_vel or 0,
  })
end
