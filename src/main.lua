-- tiny beats and shapes (an just shapes and beats demake)
-- by Frank C.

function _init()
	frame = 0
	start_fadein(25)

	bg_color_base = BG_COLOR_DEFAULT
	callfromstring "init_camera/init_screen_flash/init_particle/init_player/init_menu"
end

function _update()
	frame += 1
	update_fade()
	reveal_t=min(reveal_t+1,10)
	update_delays()
	screen_update()
end

function _draw()
	draw_fade()
	screen_draw()
	draw_reveal()
end

function set_screen(u, d)
	callfromstring"pal/init_particle"
	screen_update, screen_draw = u, d

	if u == update_game then
		menuitem(1, "back to levels", function()
			music(-1)
			delays,death_sequence_started, level_chosen={},false, false
			start_fadein(20)
			set_screen(update_selector, draw_selector)
		end)
		menuitem(2, "respawn", function()
			death_sequence_started=false
			_do_respawn()
			sfx(9)
		end)
		flash_menuitem()
	else
		menuitem(1)
		menuitem(2)
		menuitem(3)
	end
end

function flash_menuitem()
  menuitem(3, flash_disabled and "flashes: off" or "flashes: on", function()
    flash_disabled = not flash_disabled
    flash_menuitem()
    return true
  end)
end