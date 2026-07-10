function meta(i) return _kv_parts(split(LEVEL_META[i], ";")) end

function init_selector()
    -- draw bg selctor in the map
end
selector_idx, selector_cam_x = 1, 0

function update_selector()
    local cfg = meta(selector_idx)
    selector_cam_x = lerp_to(selector_cam_x, cfg.map_x * 8 - 64, .15, .5)

    if btnp(1) and selector_idx < LEVEL_COUNT then
        selector_idx += 1
        music(meta(selector_idx).track)
    elseif btnp(0) and selector_idx > 1 then
        selector_idx -= 1
        music(meta(selector_idx).track)
    elseif btnp(4) or btnp(5) then
        current_level = _ENV["level_" .. selector_idx]
        delay(5, function() start_fadeout(10, init_game) end)
    end
end

function draw_selector()
    for c in all(split "3,1,13,11,4") do
        pal(c, c + 128, 1)
    end

    callfromstring "cls,1/camera,selector_cam_x,0"
    callfromstring "circfill,50,110,40,3/circfill,20,110,20,3"
    callfromstring "map,0,0,0,0,128,32/camera/spr,1,60,60"

    print(meta(selector_idx).name, 4, 110, C_WHITE)
end
