-- tiny beats and shapes (an just shapes and beats demake)
-- by Frank C.

function _init()
	_update = menu_update
	_draw = menu_draw

	player_init()
	particle_init()

	hitstop_timer = 0
	shake_timer = 0

	bg_color = BG_COLOR_DEFAULT
end

function menu_update()
	if btnp(5) then
		run_level(level_2)
		_update = game_update
		_draw = game_draw
	end
end

function game_update()
	if p.is_dead then
		_do_respawn()
		return
	end

	if hitstop_timer > 0 then
		hitstop_timer -= 1
		return
	end

	player_update()

	if p.is_dead then
		_do_respawn()
		return
	end

	for part in all(ps) do
		update_particle(part)
	end

	update_enemies()
	update_active_patterns()
	hud_update()
	level_runtime_frames += 1
end

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

	pal()
	bg_color = BG_COLOR_DEFAULT
	pal(BG_COLOR_DEFAULT, BG_COLOR_DEFAULT + 128, 1)

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
	for part in all(ps) do
		draw_particle(part)
	end
	hud_draw()
end

function _do_respawn()
	enemies = {}
	active_patterns = {}
	ps = {}
	waves = {}
	active_checkpoint_markers = {}
	orb = nil

	player_init()

	level_progress_frame = last_respawn_frame
	hud_level_complete = false

	local target_frame = last_respawn_frame

	local saved_frac = level_total_frames > 0 and (target_frame / level_total_frames) or 0
	for ck in all(checkpoints) do
		ck.hit = ck.frac <= saved_frac
	end

	level_card_state = "done"

	meanwhile(level_1)

	local sim_frame = 0
	while sim_frame < target_frame do
		for co in all(active_patterns) do
			if costatus(co) != "dead" then
				coresume(co)
			end
		end

		for e in all(enemies) do
			e.age += 1

			if e.vx then e.x += e.vx end
			if e.vy then e.y += e.vy end

			if e.ang_vel and e.ang_vel != 0 then
				e.ang += e.ang_vel
			end

			if e.grow then
				e.size = min(e.max_size, e.size + e.growth_rate)
			end

			local out = e.x < -8 or e.x > 136 or e.y < -8 or e.y > 136
			if e.age > e.duration_frames or out then
				e.alive = false
				del(enemies, e)
			end
		end

		sim_frame += 1
	end

	checkpoint_fast_forward_frames = 0
end