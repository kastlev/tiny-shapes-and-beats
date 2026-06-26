enemy_types = {
  [E_CIRCLE] = {
    draw = function(e)
      if e.fill then
        circfill(e.x, e.y, e.size, e.color)
      else
        circ(e.x, e.y, e.size, e.color)
      end
    end
  },
  [E_SQUARE] = {
    draw = function(e)
      local s = e.size
      if e.fill then
        rectfill(e.x - s, e.y - s, e.x + s, e.y + s, e.color)
      else
        rect(e.x - s, e.y - s, e.x + s, e.y + s, e.color)
      end
    end
  },
  [E_LINE] = {
    draw = function(e)
      local dx, dy = cos(e.ang) * e.len, sin(e.ang) * e.len
      local x2, y2 = e.x + dx, e.y + dy
      local px, py = -sin(e.ang), cos(e.ang)
      for t = -e.size, e.size do
        line(e.x + px * t, e.y + py * t, x2 + px * t, y2 + py * t, e.color)
      end
    end
  },
  [E_LINE_BI] = {
    draw = function(e)
      local dx, dy = cos(e.ang), sin(e.ang)
      local px, py = -sin(e.ang), cos(e.ang)
      for t = -e.size, e.size do
        line(
          e.x - dx * e.len + px * t, e.y - dy * e.len + py * t,
          e.x + dx * e.len + px * t, e.y + dy * e.len + py * t, e.color
        )
      end
    end
  },
  [E_CROSS] = {
    draw = function(e)
      local function arm(a)
        local dx, dy = cos(a), sin(a)
        local px, py = -dy, dx
        for t = -e.size, e.size do
          line(
            e.x - dx * e.len + px * t, e.y - dy * e.len + py * t,
            e.x + dx * e.len + px * t, e.y + dy * e.len + py * t, e.color
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
      local col = remaining <= 8 and C_DARK_PINK or e.color
      if e.size <= 1 then
        pset(flr(e.x), flr(e.y), col)
      else
        circfill(flr(e.x), flr(e.y), e.size, col)
      end
    end
  }
}

enemies = {}

function spawn_enemy(enemy_type, x, y, settings)
  settings = settings or {}

  local s0 = settings.size or 2
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
    ease_move = settings.ease_move or "linear",
    lerp_factor = settings.lerp_factor or 0.1,

    fill = settings.fill ~= false,
    size = s0,
    size_start = s0,
    max_size = s1,
    grow = s1 > s0,
    grow_mode = grow_mode,
    grow_px = settings.grow_px or DEFAULT_GROWTH_RATE,
    grow_lerp = settings.grow_lerp or 0.1,
    ease_grow = settings.ease_grow or "linear",

    duration_frames = settings.duration_frames or 30,
    hold_frames = settings.hold_frames or 0,
    color = settings.color or C_PINK,
    len = settings.len or 80,
    ang = settings.ang or 0,
    ang_vel = settings.ang_vel or 0,
    age = 0,
    alive = true
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

function draw_enemies()
  for e in all(enemies) do
    local t = enemy_types[e.type]
    if t then t.draw(e) end
  end
end