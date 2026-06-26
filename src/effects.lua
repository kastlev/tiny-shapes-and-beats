local _hit_flash_cfg = {
	frames = 8,
	colors = {
		C_DARK_BLUE, C_DARK_PINK, C_DARK_GREEN, C_BROWN, C_DARK_GRAY,
		C_LIGHT_GRAY, C_WHITE, C_RED, C_ORANGE, C_YELLOW,
		C_GREEN, C_BLUE, C_LAVENDER, C_PINK, C_PEACH
	},
	bg_steps = {
		{ 0, C_DARK_PINK },
		{ 4, C_LAVENDER }
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
    cols = { C_BLUE, C_LAVENDER, C_DARK_GRAY },
    min_vel = 0.2,
    max_vel = 0.8,
    min_life = 5,
    max_life = 10,
    gravity = 0.0
}

function trigger_hit_effect()
	trigger_hitstop()
	add_trauma(1)
	trigger_screen_flash(_hit_flash_cfg)
	sfx(1)
	spawn_hit_particles(p.x + p.w / 2, p.y + p.h / 2)
end

function draw_screen_fx()
	bg_color = apply_screen_flash(BG_COLOR_DEFAULT, { BG_COLOR_DEFAULT })
end

function spawn_hit_particles(x, y, n)
    n = n or rndb(8, 16)
    for i = 1, n do
        spawn_particle(x, y, _hit_cfg)
    end
end

function spawn_trail_particle(x, y)
    spawn_particle(x, y, _trail_cfg)
end