-- tiny beats and shapes (an just shapes and beats demake)
-- by Frank C.

function _init()
	frame = 0
	menuitem(
		1, "back to levels", function()
			start_fadein(25)
			set_screen(update_selector, draw_selector)
		end
	)
	start_fadein(25)

	bg_color_base = BG_COLOR_DEFAULT
	callfromstring "init_camera/init_screen_flash/init_particle/init_player/init_menu"
end

function _update()
	frame += 1
	update_fade()
	update_reveal()
	update_delays()
	screen_update()
end

function _draw()
	draw_fade()
	screen_draw()
	draw_reveal()
end

function set_screen(u, d)
	pal()
	screen_update = u
	screen_draw = d
end