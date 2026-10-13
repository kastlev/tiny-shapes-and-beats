active_patterns = {}

function run_level(fn)
  active_patterns = {}
  return meanwhile(function()
    fn()
    level_final_frames = level_runtime_frames
    run "wait_for_clear/spawn_orb"
    
    while not orb_collected() do
      yield()
    end
  end)
end

function meanwhile(fn) return add(active_patterns,cocreate(fn)) end

function update_active_patterns()
  for co in all(active_patterns) do
    if costatus(co)=="dead" then del(active_patterns,co) else assert(coresume(co)) end
  end
end

function wait_frames(n)
  if type(n) == "table" then n = n.n end
  for i = 1, n do
    yield()
  end
end

function wait_until_enemy_dead(e)
  while e and e.alive do
    yield()
  end
end

function wait_for_clear()
  while #enemies > 0 do
    yield()
  end
end

function wait_until_pattern_finished(co)
  while costatus(co) != "dead" do
    yield()
  end
end

function wait_for_card()
  while not level_started do
    yield()
  end
end

function sync(...)
  local coros = {}
  for _, fn in ipairs({ ... }) do
    add(coros, meanwhile(fn))
  end
  for co in all(coros) do
    wait_until_pattern_finished(co)
  end
end