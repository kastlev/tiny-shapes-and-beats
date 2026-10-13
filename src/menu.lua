function _add_menu_shape(kind, x, y, size, col, ang, ang_vel, amp, spd)
    add(
        menu_shapes, {
            kind = kind, x = x, base_y = y, y = y,
            size = size, ang = ang or 0, ang_vel = ang_vel or 0,
            amp = amp, spd = spd, phase = rnd(1), col = col
        }
    )
end

function init_menu()
    menu_started = false
    set_screen(update_menu, draw_menu)
    rate_color_title, menu_shapes = 20, {}

    for i, c in ipairs({ { 38, 60 }, { 64, 55 }, { 90, 60 } }) do
        _add_menu_shape(
            "square", c[1], c[2], 30 - i * 2, C_DARK_BLUE,
            i * 0.08, 0.0005 * (i % 2 == 0 and 1 or -1),
            5 + i * 2, 0.0008 + i * 0.002
        )
        _add_menu_shape(
            "circle", 10 + rnd(108), 18 + rnd(85), 6 + rnd(3), C_DARK_PINK,
            0, 0, 4 + rnd(5), 0.0008 + rnd(0.004)
        )
    end
end

function update_menu()
    for s in all(menu_shapes) do
        s.ang += s.ang_vel
        s.y = s.base_y + sin(frame * s.spd + s.phase) * s.amp
    end

    if not menu_started and btnp()>0 and not fading then
        menu_started = true
        sfx(3)
        rate_color_title = 3
        delay(
            45, function()
                start_fadeout(
                    10, function()
                        set_screen(update_selector, draw_selector)
                        start_fadein(10)
                    end
                )
            end
        )
    end
end

function draw_menu()
    callfromstring "cls,bg_color/pal,C_DARK_BLUE,129,1/pal,C_DARK_GRAY,133,1/pal,C_DARK_PINK,130,1"

    for s in all(menu_shapes) do
        if s.kind == "square" then
            _draw_rotated_square(s.x, s.y, s.size, s.ang, s.col)
        else
            circ(s.x, s.y, s.size, s.col)
        end
    end

    callfromstring "sspr,0,32,72,32,28,35,72,32"

    local msg = "♪ press to play ♪"
    print(msg, 64 - (#msg * 2), 100, cycling_color({ C_BLUE, C_LAVENDER }, rate_color_title, frame))
    print("⬆️⬇️⬅️➡️ MOVE", 1, 120, C_DARK_GRAY)
    print("❎ DASH", 100, 120)
end

function _draw_rotated_square(cx, cy, half, ang, col)
    local d = half * 1.414
    local px, py = cx + cos(ang + 0.875) * d, cy + sin(ang + 0.875) * d
    for i = 0, 3 do
        local a = ang + 0.125 + i * 0.25
        local nx, ny = cx + cos(a) * d, cy + sin(a) * d
        line(px, py, nx, ny, col)
        px, py = nx, ny
    end
end