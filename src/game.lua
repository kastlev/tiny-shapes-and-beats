hitstop_timer = 0
current_level = level_1

function init_game()
	simulating = false
	enemies, active_patterns, orb_waves, active_checkpoint_markers, orb = {}, {}, {}, {}, nil
	init_player()
	run_level(current_level)
	set_screen(update_game, draw_game)
end

function update_game()
	if is_hitstop() then
		hitstop_timer -= 1
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
					sfx(10)
					start_fadeout(
						30, function()
							_do_respawn()
							sfx(9)
							death_sequence_started = false
						end
					)
				end
			)
		end
	end
end

function draw_game()
	draw_screen_fx()
	draw_camera()
	cls(bg_color)
	spawn_bg_particles()
	draw_particles "back"

	draw_warnings()

	if p.is_dead or p.is_invulnerable or not player_in_danger then
		draw_real_enemies()
		draw_player()
	else
		draw_player()
		draw_real_enemies()
	end
	draw_particles "front"

	camera()
	draw_hud()
end
function _do_respawn()
	camera()
	death_sequence_started = false
	enemies, active_patterns, ps, orb_waves, active_checkpoint_markers, orb = {}, {}, {}, {}, {}, nil
	callfromstring "init_player/init_camera/init_screen_flash/init_particle"

	local target_frame = last_respawn_frame
	run_level(current_level)

	for co in all(active_patterns) do
		if costatus(co) != "dead" then coresume(co) end
	end

	level_started = true
	level_card_state = "done"
	level_card_position_x = 200

	simulating = true
	local sim_frame = 1
	while sim_frame < target_frame do
		for co in all(active_patterns) do
			if costatus(co) != "dead" then coresume(co) end
		end
		update_enemies()
		sim_frame += 1
	end
	simulating = false

	callfromstring "init_particle/init_camera/init_screen_flash"

	local saved_frac = level_total_frames > 0 and (target_frame / level_total_frames) or 0
	level_progress_frame = target_frame
	last_respawn_frame = target_frame

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

function trigger_hitstop(frames)
	hitstop_timer = frames or 2
end

function is_hitstop()
	return hitstop_timer > 0
end