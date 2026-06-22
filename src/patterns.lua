-- ============================
-- pattern system (coroutines)
-- a "pattern" is a function that scripts a sequence of spawns,
-- run as its own coroutine so it can be paused with wait_* calls
-- ============================
patterns = {}

function start_pattern(fn)
  local co = cocreate(fn)
  add(patterns, co)
  return co
end

function update_patterns()  -- call once per frame
  for co in all(patterns) do
    if costatus(co) == "dead" then
      del(patterns, co)
    else
      coresume(co)
    end
  end
end

-- --- "await" primitives, only usable inside a pattern function ---

function wait_frames(n)
  for i = 1, n do yield() end
end

function wait_for_enemy(e)
  while e.alive do yield() end
end

function wait_for_clear()
  while #enemies > 0 do yield() end
end

function wait_for_pattern(co)
  while costatus(co) != "dead" do yield() end
end

function wait_for_input(btn_id)
  btn_id = btn_id or 5  -- ❎ by default
  while not btnp(btn_id) do yield() end
end

-- runs fn(i) n times in sequence, i = wave number (1..n)
-- fn is expected to call wait_frames() itself for spacing between waves
function repeat_pattern(n, fn)
  for i = 1, n do
    fn(i)
  end
end

-- spawn el anillo de aviso, espera que expire, luego spawnea el circulo real
function spawn_warned_circle(x,y,warn_frames,params)

    params = params or {}

    local max_tam = params.max_tam or 10
    local grow = params.grow
    if grow == nil then grow = true end

    local growth_rate = 0
    if grow then
        growth_rate = max_tam / warn_frames
    end

    local warn = spawn_enemy(EK_WARN,x,y,{
        start_size = grow and 0 or max_tam,
        end_size = max_tam,
        grow = grow,
        growth_rate = growth_rate,
        duration_frames = warn_frames
    })

    wait_for_enemy(warn)

    return spawn_enemy(EK_CIRCLE,x,y,{
        size = max_tam,
        duration_frames = params.duration_frames or 40
    })
end

function spawn_warned_burst(x, y, count, warn_frames, params)

    params = params or {}
    warn_frames = warn_frames or 35

    local max_tam = params.warn_size or 8
    local grow = params.grow
    if grow == nil then grow = true end

    local growth_rate = 0
    if grow then
        growth_rate = max_tam / warn_frames
    end

    local warn = spawn_enemy(EK_WARN, x, y, {
        start_size = grow and 0 or max_tam,
        end_size = max_tam,
        grow = grow,
        growth_rate = growth_rate,
        duration_frames = warn_frames,
        color = params.warn_color or C_DARK_PINK
    })

    wait_for_enemy(warn)

    spawn_burst(x, y, count, params)
end