function meta(i) return _kv_parts(split(LEVEL_META[i], ";")) end
selector_idx,selector_cam_x,can_move_frames,level_chosen,selector_arrived=1,0,0,false,true

function update_selector()
  local cfg=meta(selector_idx)
  local tx=cfg.map_x*8-64
  local prev=selector_cam_x
  selector_cam_x=lerp_to(selector_cam_x,tx,.15,.5)
  local v=selector_cam_x-prev

  if not selector_arrived and abs(selector_cam_x-tx)<1 then
    selector_cam_x,v,selector_arrived=tx,0,true
    sfx(7)
  end

  can_move=not level_chosen
  can_move_frames+=1
  song,name=cfg.song,cfg.name

  if abs(v)>1 then song,name,can_move,can_move_frames=nil,nil,false,0 end

    if btnp(1) and selector_idx < LEVEL_COUNT and can_move then
        selector_idx += 1
        sfx(6)
        selector_arrived = false
    elseif btnp(0) and selector_idx > 1 and can_move then
        selector_idx -= 1
        sfx(6)
        selector_arrived = false
    elseif (btnp(4) or btnp(5)) and can_move then
        sfx(8)
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

  if can_move and can_move_frames>10 then
    rectfill(39,40,89,56,13)
    print(song,64-#song*2,43,C_WHITE)
    print(name,64-#name*2,49,C_LIGHT_GRAY)
  end
end