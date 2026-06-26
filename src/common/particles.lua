function particle_init()
    ps = {}
end

function spawn_particle(x, y, cfg)
    cfg = cfg or {
        cols = { 7 },
        min_vel = 0.5,
        max_vel = 1.5,
        min_life = 10,
        max_life = 20,
        gravity = 0
    }

    local a = rnd()
    local f = rnd(cfg.max_vel - cfg.min_vel) + cfg.min_vel

    local part = {
        x = x, y = y,
        vx = cos(a) * f,
        vy = sin(a) * f,
        life = rndb(cfg.min_life, cfg.max_life),
        age = 0,
        col = cfg.cols[1],
        cols = cfg.cols,
        gravity = cfg.gravity
    }
    add(ps, part)
end

function update_particle(p)
    p.vy += p.gravity
    p.x += p.vx
    p.y += p.vy
    p.age += 1

    if p.age >= p.life then
        del(ps, p)
        return
    end

    local t = p.age / p.life
    local i = flr(t * #p.cols) + 1
    i = mid(1, i, #p.cols)
    p.col = p.cols[i]
end

function draw_particle(p)
    local ox = p.x - p.vx
    local oy = p.y - p.vy
    line(ox, oy, p.x, p.y, p.col)
end