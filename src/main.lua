-- tiny beats and shapes (an just shapes and beats demake)
-- by Frank C.

function _init()
	-- scene management
	_update = menu_update
	_draw = menu_draw

	-- init
	player_init()

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

	if p.flash_damage_timer > 0 then
		pal(C_BLACK, C_BLACK + 128, 1)
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
		pal(C_PINK, C_RED + 128, 1)
		pal(C_PEACH, C_PEACH + 128, 1)
		-- pal({[0]=128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143}, 1)
	else
		pal()
	end

	-- flash damage background color
	if p.flash_damage_timer > 0 then
		if p.flash_damage_timer_max - p.flash_damage_timer >= 0 then
			bg_color = C_DARK_PINK
		end
		if p.flash_damage_timer_max - p.flash_damage_timer >= 4 then
			bg_color = C_LAVENDER
		end
	else
		bg_color = BG_COLOR_DEFAULT
	end

	cls(bg_color)

	rectfill(0,0,0,127,C_DARK_GRAY)
	rectfill(127,0,127,127,C_DARK_GRAY)
	draw_enemies()
	player_draw()

	-- debug: check for pink collision
	local offset = 1
	local px, py = flr(p.x), flr(p.y)
	local hit_left = pget(px - offset, py + p.h / 2) == C_PINK
	local hit_right = pget(px + p.w + offset, py + p.h / 2) == C_PINK
	local hit_top = pget(px + p.w / 2, py - offset) == C_PINK
	local hit_bot = pget(px + p.w / 2, py + p.h + offset) == C_PINK

	if hit_left or hit_right or hit_top or hit_bot then
		print("pink collision! l:" .. (hit_left and 1 or 0) .. " r:" .. (hit_right and 1 or 0) .. " t:" .. (hit_top and 1 or 0) .. " b:" .. (hit_bot and 1 or 0), 0, 0, C_WHITE)
	end
end