current_level = nil

function init_menu()
    menu_frame, menu_started = 0, false
    set_screen(update_menu, draw_menu)
    rate_color_title = 20

    menu_shapes = {}
    local centers = { { 38, 60 }, { 64, 55 }, { 90, 60 } }
    for i, c in ipairs(centers) do
        add(
            menu_shapes, {
                kind = "square",
                x = c[1], base_y = c[2], y = c[2],
                size = 30 - i * 2,
                ang = i * 0.08,
                ang_vel = 0.0005 * (i % 2 == 0 and 1 or -1),
                amp = 5 + i * 2,
                spd = 0.0008 + i * 0.002,
                phase = rnd(1),
                col = C_DARK_BLUE
            }
        )
    end
    for i = 1, 4 do
        local x, y
        while true do
            x = 10 + rnd(108)
            y = 18 + rnd(85)

            local found = false
            for s in all(menu_shapes) do
                if s.kind == "circle" then
                    local dx = x - s.x
                    local dy = y - s.base_y
                    if dx * dx + dy * dy < 400 then
                        found = true
                        break
                    end
                end
            end

            if not found then break end
        end

        add(
            menu_shapes, {
                kind = "circle",
                x = x, base_y = y, y = y,
                size = 6 + rnd(3),
                ang = 0, ang_vel = 0,
                amp = 4 + rnd(5),
                spd = 0.0008 + rnd(0.004),
                phase = rnd(1),
                col = C_DARK_PINK
            }
        )
    end
end

function update_menu()
    menu_frame += 1

    for s in all(menu_shapes) do
        s.ang += s.ang_vel
        s.y = s.base_y + sin(menu_frame * s.spd + s.phase) * s.amp
    end

    if not menu_started and any_button_pressed() and not fading then
        menu_started = true
        sfx(3)
        rate_color_title = 3
        delay(
            45, function()
                start_fadeout(
                    10, function()
                        init_game()
                        start_fadein(10)
                    end
                )
            end
        )
    end

    -- if menu_frame % 10 == 0 then
    --     spawn_particle(
    --         rnd(128), rnd(128), {
    --             min_vel = 0.1,
    --             max_vel = 0.6,
    --             min_size = 1,
    --             max_size = 1,
    --             shrink = false,
    --             square = (rnd() < 0.5),
    --             cols = { C_DARK_BLUE, C_DARK_GRAY },
    --             min_life = 40,
    --             max_life = 100,
    --             tag = "menu_bg"
    --         }
    --     )
    -- end
    update_particles()
end

function _draw_title()
    local TITLE_X = 0
    local TITLE_Y = 32
    local TITLE_W = 72
    local TITLE_H = 32
    local x = 64 - TITLE_W / 2
    local y = 35
    sspr(TITLE_X, TITLE_Y, TITLE_W, TITLE_H, x, y, TITLE_W, TITLE_H)
end

function draw_menu()
    cls(bg_color)
    draw_particles()

    pal(C_DARK_BLUE, C_DARK_BLUE + 128, 1)
    pal(C_DARK_GRAY, C_DARK_GRAY + 128, 1)
    pal(C_DARK_PINK, C_DARK_PINK + 128, 1)

    for s in all(menu_shapes) do
        if s.kind == "square" then
            _draw_rotated_square(s.x, s.y, s.size, s.ang, s.col)
        else
            circ(s.x, s.y, s.size, s.col)
        end
    end

    _draw_title()
    local msg = "♪ press to play ♪"
    print(msg, 64 - (#msg * 2), 100, cycling_color({ C_BLUE, C_LAVENDER }, rate_color_title, menu_frame))
    print("⬆️⬇️⬅️➡️ MOVE", 1, 120, C_DARK_GRAY)
    print("❎ DASH", 100, 120)
end

function _draw_rotated_square(cx, cy, half, ang, col)
    local d = half * 1.414
    local x1, y1 = cx + cos(ang + 0.125) * d, cy + sin(ang + 0.125) * d
    local x2, y2 = cx + cos(ang + 0.375) * d, cy + sin(ang + 0.375) * d
    local x3, y3 = cx + cos(ang + 0.625) * d, cy + sin(ang + 0.625) * d
    local x4, y4 = cx + cos(ang + 0.875) * d, cy + sin(ang + 0.875) * d
    line(x1, y1, x2, y2, col)
    line(x2, y2, x3, y3, col)
    line(x3, y3, x4, y4, col)
    line(x4, y4, x1, y1, col)
end