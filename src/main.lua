-- tiny beats and shapes (an just shapes and beats demake)
-- by Frank C.

function _init()
	-- scene management
	_update = menu_update
	_draw = menu_draw

	-- init
	player_init()
	particle_init()

	-- timers
	hitstop_timer = 0
	shake_timer = 0

	-- level
	bg_color = BG_COLOR_DEFAULT
	start_pattern(level_1)
end
-- ============================
-- scene updates
-- ============================
function menu_update()
	if btnp(5) then
		_update = game_update
		_draw = game_draw
	end
end

function game_update()
	if hitstop_timer > 0 then
		hitstop_timer -= 1
		return
	end

	player_update()
	for p in all(ps) do
		update_particle(p)
	end
	update_enemies()
	update_patterns()
end

-- ============================
-- scene draws
-- ============================
function menu_draw()
	cls()
	local msg = "press ❎ to start"
	print(msg, 64 - (#msg * 2), 63)
end

function game_draw()
	if shake_timer > 0 then
		camera(rnd(SHAKE_MAGNITUDE * 2) - SHAKE_MAGNITUDE, rnd(SHAKE_MAGNITUDE * 2) - SHAKE_MAGNITUDE)
		shake_timer -= 1
	else
		camera(0, 0)
	end

	-- reset base
	pal()

	-- fondo: negro normal en memoria
	bg_color = BG_COLOR_DEFAULT

	-- screen palette base: negro -> negro secundario
	pal(BG_COLOR_DEFAULT, BG_COLOR_DEFAULT + 128, 1)

	-- flash daño: solo remapea colores extra
	if p.flash_damage_timer > 0 then
		pal(C_DARK_BLUE, C_DARK_BLUE + 128, 1)
		pal(C_DARK_PINK, C_DARK_PINK + 128, 1)
		pal(C_DARK_GREEN, C_DARK_GREEN + 128, 1)
		pal(C_BROWN, C_BROWN + 128, 1)
		pal(C_DARK_GRAY, C_DARK_GRAY + 128, 1)
		pal(C_LIGHT_GRAY, C_LIGHT_GRAY + 128, 1)
		pal(C_WHITE, C_WHITE + 128, 1)
		pal(C_RED, C_RED + 128, 1)
		pal(C_ORANGE, C_ORANGE + 128, 1)
		pal(C_YELLOW, C_YELLOW + 128, 1)
		pal(C_GREEN, C_GREEN + 128, 1)
		pal(C_BLUE, C_BLUE + 128, 1)
		pal(C_LAVENDER, C_LAVENDER + 128, 1)
		pal(C_PINK, C_PINK + 128, 1)
		pal(C_PEACH, C_PEACH + 128, 1)

		-- si quieres que el fondo también cambie durante daño, cambia bg_color aquí:
		if p.flash_damage_timer_max - p.flash_damage_timer >= 0 then
			bg_color = C_DARK_PINK
		end
		if p.flash_damage_timer_max - p.flash_damage_timer >= 4 then
			bg_color = C_LAVENDER
		end
	end

	cls(bg_color)

	draw_enemies()
	player_draw()
	for p in all(ps) do
		draw_particle(p)
	end
end