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
  local configured_size = settings.size or settings.max_size
  local e = {
    type = enemy_type,
    x = x, y = y,
    vx = settings.vx,
    vy = settings.vy,
    delay = settings.delay or 0,
    fill = settings.fill ~= false, -- default true
    size = settings.start_size or configured_size or 2,
    max_size = settings.end_size or configured_size or 12,
    grow = settings.grow or false,
    growth_rate = settings.growth_rate or 0.2,
    duration_frames = settings.duration_frames or 30,
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

    if e.delay > 0 then
      e.delay -= 1
    else
      if e.vx then e.x += e.vx end
      if e.vy then e.y += e.vy end
    end

    if e.ang_vel != 0 then e.ang += e.ang_vel end

    if e.grow then
      e.size = min(e.max_size, e.size + e.growth_rate)
    end

    local out = e.x < -8 or e.x > 136 or e.y < -8 or e.y > 136
    if e.age > e.duration_frames or out then
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