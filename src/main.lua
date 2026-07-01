-- tiny beats and shapes (an just shapes and beats demake)
-- by Frank C.

current_level = nil

TITLE_X = 0
TITLE_Y = 32
TITLE_W = 64
TITLE_H = 32
title_scale = 1

function _init()
	bg_color_base = BG_COLOR_DEFAULT  -- checkpoints pueden cambiar esto
	_update = menu_update
	_draw = menu_draw
	hitstop_init()
	camera_init()
	screen_flash_init()
	particle_init()
	player_init()
end

function menu_update()
	if any_button_pressed() then
		current_level = level_1
		run_level(current_level)
		_update = game_update
		_draw = game_draw
	end
end

function game_update()
	if p.is_dead then
		_do_respawn()
		return
	end

	if is_hitstop() then
		update_hitstop()
		return
	end

	update_player()
	update_screen_flash()

	if p.is_dead then
		_do_respawn()
		return
	end

	for part in all(ps) do
		update_particle(part)
	end
	update_enemies()
	update_active_patterns()
	update_hud()
	level_runtime_frames += 1
end

function draw_title()
	local x = 64 - TITLE_W / 2
	local y = 35

	sspr(
		TITLE_X,
		TITLE_Y,
		TITLE_W,
		TITLE_H,
		x,
		y,
		TITLE_W,
		TITLE_H
	)
end

function menu_draw()
	cls()
	draw_title()
	local msg = "press any button to start"
	print(msg, 64 - (#msg * 2), 100)
	circfill(63,110, 0)
	circfill(63,113, 1)
	rectfill(63,116, 64,117)
	circfill(63,122, 2)
end

function game_draw()
	draw_screen_fx()
	draw_camera()
	
	cls(bg_color)

	for part in all(ps) do
		draw_particle(part)
	end

	draw_enemies()
	draw_player()

	camera_clear_offset()
	draw_hud()
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