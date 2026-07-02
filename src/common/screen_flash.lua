SCREEN_FLASH_ALL_COLORS = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }

function init_screen_flash()
	screen_flash_timer = 0
	screen_flash_timer_max = 0
	screen_flash_cfg = nil
end

function trigger_screen_flash(cfg)
	screen_flash_timer = cfg.frames
	screen_flash_timer_max = cfg.frames
	screen_flash_cfg = cfg
end

function update_screen_flash()
	if screen_flash_timer > 0 then
		screen_flash_timer -= 1
	end
end

function is_screen_flash()
	return screen_flash_timer > 0
end

-- aplica el pal() del flash y devuelve el bg_color de este frame.
-- default_bg:  color de fondo cuando no hay flash activo
-- base_colors: colores siempre redirigidos a +128 (flash o no),
--              util para mantener reservado el slot del bg
function apply_screen_flash(default_bg, base_colors)
	if fading then return default_bg end
	pal()

	if base_colors then
		for c in all(base_colors) do
			pal(c, c + 128, 1)
		end
	end

	local bg = default_bg

	if screen_flash_timer > 0 then
		local cfg = screen_flash_cfg
		local cols = cfg.colors or SCREEN_FLASH_ALL_COLORS

		for c in all(cols) do
			pal(c, c + 128, 1)
		end

		if cfg.bg_steps then
			local elapsed = screen_flash_timer_max - screen_flash_timer
			for step in all(cfg.bg_steps) do
				if elapsed >= step[1] then
					bg = step[2]
				end
			end
		end
	end

	return bg
end