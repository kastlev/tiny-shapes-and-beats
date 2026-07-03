local _hit_flash_cfg = {
	frames = 8,
	bg_steps = {
		{ 0, C_DARK_PINK },
		{ 4, C_LAVENDER }
	}
}

local _death_flash_cfg = {
	frames = 8,
	bg_steps = {
		{ 0, C_RED },
		{ 2, C_DARK_PINK },
	}
}

local _hit_cfg = {
    cols = { C_WHITE, C_LIGHT_GRAY, C_BLUE, C_BLUE, C_LAVENDER },
    min_vel = 0.8,
    max_vel = 2.5,
    min_life = 10,
    max_life = 20,
    gravity = 0.0
}

local _trail_cfg = {
    cols = {C_DARK_BLUE }, -- C_DARK_BLUE, 
    min_vel = 0.1,
    max_vel = 0.3,
    min_life = 6,
    max_life = 20,
    min_size = 1,
    max_size = 3,
    square = true,
    rate = 2,
    shrink = true,
    tag = "trail"
}

function trigger_hit_effect()
    trigger_hitstop()
    add_trauma(0.4)
    trigger_screen_flash(p.hp > 0 and _hit_flash_cfg or _death_flash_cfg)

    if p.hp > 0 then
        sfx(2)
    else
        sfx(1)
    end
    spawn_hit_particles(p.x + p.w / 2, p.y + p.h / 2)
end

function draw_screen_fx()
    bg_color = apply_screen_flash(bg_color_base, { bg_color_base})
end

function spawn_hit_particles(x, y, n)
    n = n or rndb(8, 16)
    for i = 1, n do
        spawn_particle(x, y, _hit_cfg)
    end
end

function spawn_trail_particle(x, y, gx, gy)
    spawn_particle(x, y, _trail_cfg, gx, gy)
end