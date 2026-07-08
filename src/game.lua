current_level = level_1

function init_game()
	run_level(current_level)
	set_screen(update_game, draw_game)
	init_particle()
end

function update_game()
	if is_hitstop() then
		update_hitstop()
		return
	end

	update_player()
	update_particles()
	update_screen_flash()
	update_enemies()
	update_active_patterns()
	update_hud()

	level_runtime_frames += 1

	if p.is_dead then
		if not death_sequence_started then
			death_sequence_started = true
			delay(
				45, function()
					start_fadeout(
						30, function()
							_do_respawn()
							death_sequence_started = false
						end
					)
				end
			)
		end
	end
	-- if level_runtime_frames % 10 == 0 then
	-- 	spawn_particle(
	-- 		rnd(128), rnd(128), {
	-- 			min_vel = 0.1,
	-- 			max_vel = 0.6,
	-- 			min_size = 1,
	-- 			max_size = 1,
	-- 			shrink = false,
	-- 			square = (rnd() < 0.5),
	-- 			cols = { C_DARK_BLUE, C_DARK_GRAY },
	-- 			min_life = 40,
	-- 			max_life = 100,
	-- 			tag = "menu_bg"
	-- 		}
	-- 	)
	-- end
end

function draw_game()
	draw_screen_fx()
	draw_camera()
	cls(bg_color)

	draw_particles "back"

	draw_warnings()

	if p.is_dead or p.is_invulnerable or not real_danger_nearby() then
		draw_real_enemies()
		draw_player()
	else
		draw_player()
		draw_real_enemies()
	end
	draw_particles "front"

	camera()
	draw_hud()

	-- poke(0x5f2f,1)-- pausa el sonido de la musica
	-- poke(0x5f31,0xaa)
	-- poke(0x5f32,0xaa)
	-- poke(0x5f33,2)
	-- poke(0x5f54, 0x60)
	-- sspr(0,0,128,128, 100,5,20,20)
	-- poke(0x5f54, 0x00)
	-- pal() -- return to defaults
end

function _do_respawn()
	camera()
	death_sequence_started = false
	enemies = {}
	active_patterns = {}
	ps = {}
	waves = {}
	active_checkpoint_markers = {}
	orb = nil

	callfromstring "init_player/init_hitstop/init_camera/init_screen_flash/init_particle"

	local target_frame = last_respawn_frame
	-- srand(level_seed)
	run_level(current_level)

	local sim_frame = 0
	while sim_frame < target_frame do
		_update_card()
		for co in all(active_patterns) do
			if costatus(co) != "dead" then
				coresume(co)
			end
		end
		update_enemies()
		sim_frame += 1
	end
	init_particles()
	local saved_frac = level_total_frames > 0 and (target_frame / level_total_frames) or 0
	level_progress_frame = target_frame
	last_respawn_frame = target_frame
	level_started = true
	level_card_state = "done"
	level_card_position_x = 200

	bg_color_base = BG_COLOR_DEFAULT
	for ck in all(checkpoints) do
		ck.hit = ck.frac <= saved_frac
		if ck.hit and ck.color then
			bg_color_base = ck.color
		end
	end

	callfromstring "start_reveal,64,64,10"
	p.hit_iframes_timer = 60
	trigger_hitstop(10)
end