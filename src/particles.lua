function particle_init()
    ps = {}

    particle_cols = {
        7,
        6,
        12,
        12,
        13
    }

    min_particles = 8
    max_particles = 16

    particle_min_vel = 0.8
    particle_max_vel = 2.5

    particle_min_life = 10
    particle_max_life = 20

    particle_gravity = 0.00
end

function spawn_particle(x, y)
    local p = {}

    p.x = x
    p.y = y

    local a = rnd()
    local f = rnd(particle_max_vel - particle_min_vel) + particle_min_vel

    p.vx = cos(a) * f
    p.vy = sin(a) * f

    p.life = rndb(particle_min_life, particle_max_life)
    p.age = 0

    p.col = particle_cols[1]

    add(ps, p)
end

function spawn_damage_particles(x, y)
    local n = rndb(min_particles, max_particles)

    for i = 1, n do
        spawn_particle(x, y)
    end
end

function update_particle(p)
    p.vy += particle_gravity

    p.x += p.vx
    p.y += p.vy

    p.age += 1

    if p.age >= p.life then
        del(ps, p)
        return
    end

    local t = p.age / p.life
    local i = flr(t * #particle_cols) + 1
    i = mid(1, i, #particle_cols)

    p.col = particle_cols[i]
end

function draw_particle(p)
    local ox = p.x - p.vx
    local oy = p.y - p.vy
    line(ox, oy, p.x, p.y, p.col)
end

function rndb(low, high)
    local range = high - low + 1
    return flr(rnd(range) + low)
end