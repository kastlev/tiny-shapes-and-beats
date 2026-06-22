-- ============================
-- player update
-- ============================
function player_update()
	-- normalized input
	local dx = (btn(➡️) and 1 or 0) - (btn(⬅️) and 1 or 0)
	local dy = (btn(⬇️) and 1 or 0) - (btn(⬆️) and 1 or 0)

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

	if btnp(❎) and p.dash_cooldown_timer <= 0 then
		local ix = (btn(➡️) and 1 or 0) - (btn(⬅️) and 1 or 0)
		local iy = (btn(⬇️) and 1 or 0) - (btn(⬆️) and 1 or 0)

		if ix != 0 or iy != 0 then
			local len = sqrt(ix * ix + iy * iy)
			p.dash_dir_x = ix / len
			p.dash_dir_y = iy / len
			p.dash_timer = p.dash_timer_max
			p.dash_force = p.dash_force_max
			p.dash_cooldown_timer = p.dash_cooldown_max
		end

		-- store position before the dash, used by the explosion fx
		p.dash_explosion_x = p.x + p.w / 2
		p.dash_explosion_y = p.y + p.h / 2
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
	p.x = mid(0, p.x, 127 - p.w)
	p.y = mid(0, p.y, 127 - p.h)

	-- clamp speed
	p.dx = mid(-p.max_dx, p.dx, p.max_dx)
	p.dy = mid(-p.max_dy, p.dy, p.max_dy)

	-- reduce dash cooldown
	if p.dash_cooldown_timer > 0 then
		p.dash_cooldown_timer -= 1
	end
	-- reset invulnerability after dash
	p.is_invulnerable = false

	if not p.is_dashing and not p.is_invulnerable then
		local offset = 1
		local px, py = flr(p.x), flr(p.y)

		local hit_left  = pget(px - offset,       py + p.h / 2) == C_PINK
		local hit_right = pget(px + p.w + offset, py + p.h / 2) == C_PINK
		local hit_top   = pget(px + p.w / 2,      py - offset)  == C_PINK
		local hit_bot   = pget(px + p.w / 2,      py + p.h + offset) == C_PINK

		local force = 7.5
		if hit_left  then p.dx =  force end
		if hit_right then p.dx = -force end
		if hit_top   then p.dy =  force end
		if hit_bot   then p.dy = -force end

		if hit_left or hit_right or hit_top or hit_bot then
			p.is_stunned     = true
			p.is_invulnerable = true
			p.hp = p.hp - 1
		end
	end
end

-- ============================
-- player draw
-- ============================
function player_draw()
	local ix = (btn(➡️) and 1 or 0) - (btn(⬅️) and 1 or 0)
	local iy = (btn(⬇️) and 1 or 0) - (btn(⬆️) and 1 or 0)

	p.is_diagonal = (ix != 0 and iy != 0)

	if p.is_diagonal then
		-- flip sprite on diagonal
		if (iy == -1 and ix == 1) or (iy == 1 and ix == -1) then
			p.flip_x = true
		else
			p.flip_x = false
		end

		p.sp = 2
		p.scl_y = .7
		p.scl_x = .7
	else
		p.sp = 0
		p.scl_y = .8
		p.scl_x = .8
	end

	if not p.is_diagonal then
		pal()
	end

	if p.dash_timer > 0 then
		if p.is_diagonal then
			pal(DASH_REMAP_FROM, DASH_REMAP_TO, 0)
		end

		if not p.is_diagonal then
			if ix == 1 then
				p.scl_x = 1.2
				p.flip_x = false
			elseif ix == -1 then
				p.scl_x = 1.2
				p.flip_x = true
			else
				p.flip_x = false
			end

			if iy == 1 then
				p.scl_y = 1.2
				p.flip_y = false
			elseif iy == -1 then
				p.scl_y = 1.2
				p.flip_y = true
			else
				p.flip_y = false
			end
		end

		local r = DASH_EXPLOSION_RADIUS - p.dash_timer - 1

		if p.dash_timer > 1 then
			circfill(p.dash_explosion_x, p.dash_explosion_y, r, C_BLUE)
		else
			circ(p.dash_explosion_x, p.dash_explosion_y, r, C_BLUE)
		end
	else
		pal()
	end

	spr(p.sp, p.x, p.y, p.scl_x, p.scl_y, p.flip_x, p.flip_y)
end