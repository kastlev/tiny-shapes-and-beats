-- tiny beats and shapes (an just shapes and beats demake)
-- by Frank C.

function _init()
	start_fadein(25)

	bg_color_base = BG_COLOR_DEFAULT
	init_hitstop()
	init_camera()
	init_screen_flash()
	init_particle()
	init_player()
	init_menu()
end

function _update()
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
	screen_update = u
	screen_draw = d
end