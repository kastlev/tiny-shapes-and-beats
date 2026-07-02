function init_game()
    current_level = level_1
    run_level(current_level)
    set_screen(update_game, draw_game)
end

function update_game()
	if is_hitstop() then
		update_hitstop()
		return
	end

	update_player()
	
	if p.is_dead then
		_do_respawn()
		return
	end
	
	for part in all(ps) do
		update_particle(part)
	end
	
	update_screen_flash()
	update_enemies()
	update_active_patterns()
	update_hud()
	
	level_runtime_frames += 1
end

function draw_game()
	draw_screen_fx()
	draw_camera()
	
	cls(bg_color)

	for part in all(ps) do
		draw_particle(part)
	end

	draw_enemies()
	draw_player()

	camera()
	draw_hud()
end

function _do_respawn()
	enemies = {}
	active_patterns = {}
	ps = {}
	waves = {}
	active_checkpoint_markers = {}
	orb = nil

	init_player()
	level_progress_frame = last_respawn_frame
	hud_level_complete = false

	local target_frame = last_respawn_frame
	local saved_frac = level_total_frames > 0 and (target_frame / level_total_frames) or 0

	for ck in all(checkpoints) do
		ck.hit = ck.frac <= saved_frac
	end

	level_card_state = "done"
	run_level(current_level)

	local sim_frame = 0
	while sim_frame < target_frame do
		for co in all(active_patterns) do
			if costatus(co) != "dead" then
				coresume(co)
			end
		end
		update_enemies()
		sim_frame += 1
	end

	checkpoint_fast_forward_frames = 0
end