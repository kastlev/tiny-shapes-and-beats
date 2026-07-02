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
    add_trauma(0.4)              -- equilibrado, como ahora (sin cambios en llamadas existentes)
    -- add_trauma(0.6, 0)           -- fuerte hacia la derecha (0° = derecha en pico8)
    -- add_trauma(0.6, 0.5)         -- fuerte hacia la izquierda (0.5 = 180°)
    -- add_trauma(0.6, 0.25)        -- hacia abajo (0.25 = 90°, y+ es abajo en pico8)
    -- add_trauma(0.6, 0, 0.05) 
    -- wall_bump_shake(0.25)
    trigger_screen_flash(_hit_flash_cfg)
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