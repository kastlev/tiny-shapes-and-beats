active_patterns = {}
checkpoint_fast_forward_frames = 0

function _try_skip(skip_frames)
  if checkpoint_fast_forward_frames <= 0 then return false end
  checkpoint_fast_forward_frames = max(0, checkpoint_fast_forward_frames - skip_frames)
  return true
end

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
  if _try_skip(enemy_remaining_frames(e)) then
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

    _try_skip(skip)
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

function wait_for_card()
  if _try_skip(0) then return end

  while not level_started do
    yield()
  end
end

function wait_for_orb()
  if _try_skip(0) then return end

  while not orb_collected() do
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