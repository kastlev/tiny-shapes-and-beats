DEATH_BULLET_SPRITE, death_sequence_started, death_bullets = 32, false, {}

function spawn_death_bullets(x, y, n, speed)
	n = n or 6
	speed = speed or 1.5
	for i = 0, n - 1 do
		local a = i / n
		add(
			death_bullets, {
				x = x, y = y,
				dx = cos(a) * speed, dy = sin(a) * speed,
				age = 0
			}
		)
	end
end

function update_death_bullets()
	for b in all(death_bullets) do
		b.x += b.dx
		b.y += b.dy
		b.age += 1
		if b.age > 60 or b.x < -8 or b.x > 136 or b.y < -8 or b.y > 136 then
			del(death_bullets, b)
		end
	end
end

function draw_death_bullets()
	for b in all(death_bullets) do
		local size = 8 * (1 - min(b.age / 60, 1))
		if size > 0.5 then
			local half = size / 2
			sspr(
				(DEATH_BULLET_SPRITE % 16) * 8, (DEATH_BULLET_SPRITE \ 16) * 8, 8, 8,
				b.x - half, b.y - half, size, size
			)
		end
	end
end