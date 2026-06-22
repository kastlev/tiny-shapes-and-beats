-- ============================
-- init
-- ============================
function _init()
	-- start in the menu
	_update = menu_update
	_draw = menu_draw

	-- player
	p = {
		hp = 4,
		-- position and movement
		x = 63,
		y = 63,
		acc = 0.9,
		friction = 0.8,
		dx = 0,
		dy = 0,
		max_dx = 2.5,
		max_dy = 2.5,
		-- sprite and drawing
		sp = 0, -- sprite index
		flip_x = false,
		flip_y = false,
		scl_x = 1,
		scl_y = 1,
		w = 4,
		h = 4,
		-- dash
		dash_timer_max = 8,
		dash_timer = 0,
		dash_force_max = 4,
		dash_force = 0,
		dash_cooldown_max = 20,
		dash_cooldown_timer = 0,
		dash_explosion_x = 0,
		dash_explosion_y = 0,
		-- state
		is_diagonal = false,
		is_dashing = false,
		is_invulnerable = false,
		is_stunned = false,
		is_dead = false
	}

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
	player_update()
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
-- pico-8 default palette, named

function game_draw()
	cls(C_DARK_BLUE)
	player_draw()
	draw_enemies()

	-- assume light blue is color 12, pink is color 14
	if pget(p.x + p.w / 2, p.y + p.h / 2) == C_PINK then
		print("pink collision!")
	end
end