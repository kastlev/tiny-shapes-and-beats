function meta(i) return _kv_parts(split(LEVEL_META[i], ";")) end

selector_idx, selector_cam_x, selector_vel = 1, 0, 0
can_move_frames = 0
level_chosen = false

function update_selector()
    local cfg = meta(selector_idx)

    local prev_x = selector_cam_x
    selector_cam_x = lerp_to(selector_cam_x, cfg.map_x * 8 - 64, .15, .5)
    selector_vel = selector_cam_x - prev_x

    can_move = not level_chosen
    can_move_frames += 1
    song = meta(selector_idx).song
    name = meta(selector_idx).name

    if abs(selector_vel) > 1 then
        song, name, can_move, can_move_frames = nil, nil, false, 0
    end

    if btnp(1) and selector_idx < LEVEL_COUNT and can_move then
        selector_idx += 1
        music(meta(selector_idx).track)
    elseif btnp(0) and selector_idx > 1 and can_move then
        selector_idx -= 1
        music(meta(selector_idx).track)
    elseif (btnp(4) or btnp(5)) and can_move then
        level_chosen = true
        current_level = _ENV["level_" .. selector_idx]
        delay(5, function() start_fadeout(10, init_game) end)
    end
end

function draw_selector()
    for c in all(split "3,1,13,11,5") do
        pal(c, c + 128, 1)
    end
    callfromstring "cls,1/camera,selector_cam_x,0"
    callfromstring "ovalfill,8,40,40,110,5/ovalfill,24,24,55,110,5/ovalfill,38,40,70,110,5/ovalfill,104,40,136,110,5/ovalfill,120,24,151,110,5/ovalfill,134,40,166,110,5"
    callfromstring "circfill,10,110,40,3/circfill,95,110,60,3/circfill,145,120,45,3"
    callfromstring "map,0,0,0,0,128,32/camera"
    spr(1, 60, 64, 1, 1)

    if can_move and can_move_frames > 10 then
        local cx, cy = 64 - 50 / 2, 64 - 16 - 8
        rectfill(cx, cy, cx + 50, cy + 16, 13) -- 2,5,13
        local box_cx = cx + 25

        print(song, box_cx - #song * 2, cy + 3, C_WHITE)
        print(name, box_cx - #name * 2, cy + 9, C_LIGHT_GRAY)
    end
end