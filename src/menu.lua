current_level = nil

function init_menu()
    menu_frame = 0
    menu_started = false
    set_screen(update_menu, menu_draw)
    
    rate_color_txt = 20
    -- delay(26, function()
    --     bg_color = 1
    -- end)
end

function update_menu()
    menu_frame += 1
    if not menu_started and any_button_pressed() and not fading then
        menu_started = true
        sfx(3)
        rate_color_txt = 3
        delay(45, function()
            start_fadeout(
                10, function()
                    init_game()
                    start_fadein(10)
                end
            )
        end)
    end
end

function draw_title()
    local TITLE_X = 0
    local TITLE_Y = 32
    local TITLE_W = 72
    local TITLE_H = 32
    local x = 64 - TITLE_W / 2
    local y = 35
    sspr(TITLE_X, TITLE_Y, TITLE_W, TITLE_H, x, y, TITLE_W, TITLE_H)
end

function menu_draw()
    cls(bg_color)
    draw_title()
    local msg = "press to play"
    print(msg, 64 - (#msg * 2), 100, cycling_color({ C_BLUE, C_LAVENDER }, rate_color_txt, menu_frame))
end