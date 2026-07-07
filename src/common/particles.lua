function init_particle()
    ps = {}
end

function spawn_particle(x, y, cfg, gx_ov, gy_ov)
    cfg = cfg or {}

    cfg._tick = ((cfg._tick or -1) + 1) % (cfg.rate or 1)
    if cfg._tick != 0 then return end

    local min_vel = cfg.min_vel or 0.5
    local max_vel = cfg.max_vel or 1.5
    local a = rnd()
    local f = min_vel + rnd(max_vel - min_vel)

    local min_s = cfg.min_size or 0
    local max_s = cfg.max_size or min_s
    local size = cfg.shrink and max_s or (min_s + rnd(max_s - min_s))

    local cols = cfg.cols or { 7 }

    add(ps, {
        x = x, y = y,
        vx = cos(a) * f,
        vy = sin(a) * f,
        life = rndb(cfg.min_life or 10, cfg.max_life or 20),
        age = 0,
        col = cols[1],
        cols = cols,
        gx = gx_ov or cfg.gx or 0,
        gy = gy_ov or cfg.gy or 0,
        size = size,
        size_max = max_s,
        size_min = min_s,
        shrink = cfg.shrink or false,
        square = cfg.square or false,
        trail  = cfg.trail  or false,
        tag    = cfg.tag,
        age_mult = 1,
        layer = cfg.layer or "back"
    })
end

function update_particle(pt)
    pt.vx += pt.gx
    pt.vy += pt.gy
    pt.x  += pt.vx
    pt.y  += pt.vy
    pt.age += pt.age_mult

    if pt.age >= pt.life then
        del(ps, pt)
        return
    end

    local t = pt.age / pt.life

    if pt.shrink then
        pt.size = pt.size_min + (pt.size_max - pt.size_min) * (1 - t)
    end

    local i = mid(1, flr(t * #pt.cols) + 1, #pt.cols)
    pt.col = pt.cols[i]
end

function draw_particle(pt)
    local fx, fy = flr(pt.x), flr(pt.y)

    if pt.trail then
        line(flr(pt.x - pt.vx), flr(pt.y - pt.vy), fx, fy, pt.col)
    elseif pt.size <= 0 then
        pset(fx, fy, pt.col)
    elseif pt.square then
        local lo = flr(pt.size / 2)
        local hi = flr((pt.size + 1) / 2) - 1
        rectfill(fx - lo, fy - lo, fx + hi, fy + hi, pt.col)
    else
        circfill(fx, fy, pt.size, pt.col)
    end
end

function update_particles()
    for pt in all(ps) do
        update_particle(pt)
    end
end

function draw_particles(layer)
    for p in all(ps) do
        if p.layer == layer then
            draw_particle(p)
        end
    end
end

-- acorta la vida restante de particulas con ese tag.
-- llamar cuando el emisor para: las existentes desaparecen
-- en max `remaining` frames en vez de su vida original.
function expire_particles(tag, remaining)
    remaining = remaining or 8
    for pt in all(ps) do
        if pt.tag == tag then
            pt.life = min(pt.life, pt.age + remaining)
        end
    end
end