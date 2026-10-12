function init_player()
	p = _kv_parts(split(
		"hp=1;hp_max=4;x=61;y=61;input_x=0;input_y=0;acc=0.9;friction=0.8;dx=0;dy=0;max_dx=2.5;max_dy=2.5;sp=1;flip_x=false;flip_y=false;scl_x=1;scl_y=1;w=4;h=4;dash_dir_x=0;dash_dir_y=0;dash_timer_max=8;dash_timer=0;dash_force_max=4;dash_force=0;dash_cooldown_max=16;dash_cooldown_timer=0;dash_explosion_x=0;dash_explosion_y=0;dash_buffer_timer=0;dash_buffer_max=7;dash_wall_hit=false;last_input_x=0;last_input_y=0;last_input_timer=0;last_input_max=5;is_diagonal=false;is_dashing=false;is_invulnerable=false;is_stunned=false;is_dead=false;hit_iframes_timer=0;hit_iframes_timer_max=40;trail_active=false;in_danger=false",
		";"
	))
end

function update_player()
	if p.is_dead then
		update_death_bullets()
		return
	end

	-- normalized input
	local dx = (btn(➡️) and 1 or 0) - (btn(⬅️) and 1 or 0)
	local dy = (btn(⬇️) and 1 or 0) - (btn(⬆️) and 1 or 0)

	p.input_x = dx
	p.input_y = dy

	-- last input
	if dx != 0 or dy != 0 then
		p.last_input_x = dx
		p.last_input_y = dy
		p.last_input_timer = p.last_input_max
	end

	-- if moving
	if dx != 0 or dy != 0 then
		-- normalize
		local len = sqrt(dx * dx + dy * dy)
		dx /= len
		dy /= len

		-- apply acceleration
		p.dx += dx * p.acc
		p.dy += dy * p.acc
	end

	-- apply friction
	p.dx *= p.friction
	p.dy *= p.friction

	-- dash
	p.is_dashing = p.dash_timer > 0

	if btnp(❎) then
		p.dash_buffer_timer = p.dash_buffer_max
	end

	-- try to dash
	if p.dash_buffer_timer > 0 and p.dash_cooldown_timer <= 0 and not p.is_dashing then
		local ix = p.input_x
		local iy = p.input_y

		-- use last input if no current input
		if ix == 0 and iy == 0 and p.last_input_timer > 0 then
			ix = p.last_input_x
			iy = p.last_input_y
		end

		--  if we have a direction, start the dash
		if ix != 0 or iy != 0 then
			sfx(0) -- dash sound
			local len = sqrt(ix * ix + iy * iy)

			p.dash_dir_x = ix / len
			p.dash_dir_y = iy / len

			p.dash_timer = p.dash_timer_max
			p.dash_force = p.dash_force_max
			p.dash_cooldown_timer = p.dash_cooldown_max

			p.dash_explosion_x = p.x + p.w / 2
			p.dash_explosion_y = p.y + p.h / 2

			p.dash_buffer_timer = 0
			p.dash_wall_hit = false
		end
	end

	-- while dashing, apply a soft impulse
	if p.dash_timer > 0 then
		local t = p.dash_timer / p.dash_timer_max -- 1.0 -> 0.0
		local f = p.dash_force * t -- linear decay
		p.dx += p.dash_dir_x * f
		p.dy += p.dash_dir_y * f
		p.dash_timer -= 1
	end

	-- move player
	p.x += p.dx
	p.y += p.dy

	-- clamp player position to play area (after moving)
	local before_x, before_y = p.x, p.y
	p.x = mid(0, p.x, 127 - p.w)
	p.y = mid(0, p.y, 127 - p.h)

	-- wall bump
	if p.is_dashing and not p.dash_wall_hit and (p.x != before_x or p.y != before_y) then
		p.dash_wall_hit = true
		local bump_ang = atan2(-p.dash_dir_x, -p.dash_dir_y)
		wall_bump_shake(bump_ang)
		sfx(5)
	end

	-- clamp speed
	p.dx = mid(-p.max_dx, p.dx, p.max_dx)
	p.dy = mid(-p.max_dy, p.dy, p.max_dy)

	-- hit iframes
	p.is_invulnerable = p.is_dashing or p.hit_iframes_timer > 0

	-- stun
	if not p.is_invulnerable then
		local x1, y1, x2, y2 = player_hitbox_points()
		local hit_left = edge_hit(x1, y1, x1, y2)
		local hit_right = edge_hit(x2, y1, x2, y2)
		local hit_top = edge_hit(x1, y1, x2, y1)
		local hit_bot = edge_hit(x1, y2, x2, y2)
		local edge_hit_any = hit_left or hit_right or hit_top or hit_bot

		local force = 7.5
		if hit_left then p.dx = force end
		if hit_right then p.dx = -force end
		if hit_top then p.dy = force end
		if hit_bot then p.dy = -force end

		local hole_hit = not edge_hit_any and check_hole_danger(force)

		p.in_danger = edge_hit_any or hole_hit

		if p.in_danger then
			p.is_stunned = true
			p.hit_iframes_timer = p.hit_iframes_timer_max
			p.hp -= 1

			if p.hp <= 0 then
				p.is_dead = true
				spawn_death_bullets(p.x + p.w / 2, p.y + p.h / 2, 6)
			end

			trigger_hit_effect()
		end
	end

	player_timers = split(
		"dash_cooldown_timer,hit_iframes_timer,dash_buffer_timer,last_input_timer", ","
	)

	-- decrement timers
	for t in all(player_timers) do
		p[t] = max(0, p[t] - 1)
	end

	-- reset last input
	if p.last_input_timer <= 0 then
		p.last_input_x = 0
		p.last_input_y = 0
	end
end

function draw_player()
	if p.is_dead then
		draw_death_bullets()
		return
	end
	-- -- debug hitbox
	-- local x1, y1, x2, y2 = player_hitbox_points()
	-- rect(x1, y1, x2, y2, 8)

	p.flip_x = p.dx < 0
	p.flip_y = p.dy < 0

	-- trail particles
	local spd = sqrt(p.dx * p.dx + p.dy * p.dy)

	if spd > 0.6 then
		local nx = p.dx / spd
		local ny = p.dy / spd
		local cx = p.x + p.w / 2
		local cy = p.y + p.h / 2

		spawn_trail_particle(
			cx - nx * 3,
			cy - ny * 3
		)
		p.trail_active = true
	end

	-- trail particles (when not moving)
	if p.trail_active and p.input_x == 0 and p.input_y == 0 then
		expire_particles("trail", 8)
		p.trail_active = false
	end

	local is_diagonal = p.input_x != 0 and p.input_y != 0

	if p.is_dashing then
		if abs(p.dash_dir_x) > 0 then
			p.sp = 2
		elseif abs(p.dash_dir_y) > 0 then
			p.sp = 3
		end
		if is_diagonal then
			p.sp = 0
		end

		local r = 6 - p.dash_timer - 1

		if r > 0 then
			local ex = p.dash_explosion_x - 1
			local ey = p.dash_explosion_y - 1

			if p.dash_timer > 1 then
				circfill(ex, ey, r, C_BLUE)
			else
				circ(ex, ey, r, C_BLUE)
			end
		end

		-- dash trail sprite
		local trail_x = p.x - p.dash_dir_x * 1
		local trail_y = p.y - p.dash_dir_y * 1

		-- trail sprite shadow
		for i = 0, 15 do
			pal(i, C_DARK_GRAY, 0)
		end

		spr(p.sp, trail_x - 1, trail_y - 1, 1, 1, p.flip_x, p.flip_y)

		pal(0)
	else
		p.sp = 1 -- sprite normal

		if is_diagonal then
			p.sp = 4
		end
	end

	-- hit iframes flicker
	local flicker = false

	if p.hit_iframes_timer > 0 then
		local t = p.hit_iframes_timer / p.hit_iframes_timer_max
		local max_interval = 4
		local iframe_flicker_interval = max(1, flr(max_interval * t))

		flicker = (p.hit_iframes_timer \ iframe_flicker_interval) % 2 == 0
		if flicker then
			pal(C_BLUE, C_DARK_PINK, 0)
		end
	end

	spr(p.sp, p.x - 1, p.y - 1, 1, 1, p.flip_x, p.flip_y)

	if flicker then
		pal(0)
	end

	-- sprite quadrants when taking HP
	local rx, ry = p.x - 1, p.y - 1
	local half = 4

	local quadrants = {
		{ rx + half, ry }, -- top-right
		{ rx + half, ry + half }, -- bottom-right
		{ rx, ry + half }, -- bottom-left
		{ rx, ry } -- top-left
	}

	local damage_count = p.hp_max - p.hp

	for i = 1, damage_count do
		local q = quadrants[i]
		if q then
			clip(q[1], q[2], half, half)
			for c = 0, 15 do
				pal(c, C_DARK_BLUE, 0)
			end
			spr(p.sp, rx, ry, 1, 1, p.flip_x, p.flip_y)
			pal(0)
			clip()
		end
	end
end

function player_hitbox_points()
	local px, py = flr(p.x), flr(p.y)
	return px + 1, py + 1, px + 4, py + 4
end

function edge_hit(x1, y1, x2, y2)
	if x1 == x2 then
		for y = y1, y2 do
			if pget(x1, y) == C_PINK then return true end
		end
	else
		for x = x1, x2 do
			if pget(x, y1) == C_PINK then return true end
		end
	end
	return false
end

function check_hole_danger(force)
	for e in all(enemies) do
		if e.type == E_HOLE and not e.is_warning then
			local dx, dy = p.x + p.w / 2 - e.x, p.y + p.h / 2 - e.y
			local d2 = dx * dx + dy * dy
			if d2 > e.size * e.size then
				local d = sqrt(d2)
				p.dx, p.dy = -dx / d * force, -dy / d * force
				return true
			end
		end
	end
	return false
end