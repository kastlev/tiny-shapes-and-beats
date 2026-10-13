HUD_X,HUD_Y,HUD_W,level_final_frames,checkpoint_marker_speed,card_timer=unpack(split"1,1,125,0,1.5,0")
CARD_W,CARD_H,CARD_DISPLAY_TIME,CARD_REVEAL_FRAC,CART_SPEED_IN,CART_SPEED_OUT,ORB_R,ORB_HR=unpack(split"72,14,30,1,0.2,0.07,5,8")

function hud_start(total_f,list,song,lvl)
  level_total_frames=total_f
  level_progress_frame,level_runtime_frames,last_respawn_frame,level_started=0,0,0,false
  checkpoints,active_checkpoint_markers,bg_color_base={},{},BG_COLOR_DEFAULT
  for f in all(list) do
    local t=type(f)=="table" and f or {f}
    add(checkpoints,{frac=t.frac or t[1],color=t.color or t[2],hit=false})
  end
  card_song,level_name,level_card_state,level_card_position_x=song or "no title",lvl or "level 1","in",128+CARD_W
  orb,orb_waves=nil,{}
end

function update_hud()
  if level_started and level_progress_frame<level_total_frames-1 then level_progress_frame+=1 end
  if orb and #enemies==0 then bg_color_base=BG_COLOR_DEFAULT end

  local frac=level_progress_frame/level_total_frames
  for ck in all(checkpoints) do
    if not ck.hit and frac>=ck.frac then
      ck.hit=true
      add(active_checkpoint_markers,{x=130,color=ck.color})
    end
  end

  for c in all(active_checkpoint_markers) do
    c.x-=checkpoint_marker_speed
    if abs(c.x-p.x-2)<=3 and not p.is_dead then
      last_respawn_frame=level_progress_frame
      bg_color_base=c.color or bg_color_base
      sfx(4)
      trigger_screen_flash(_hit_flash_cfg)
      del(active_checkpoint_markers,c)
    elseif c.x<-2 then
      del(active_checkpoint_markers,c)
    end
  end

  _update_card()

  if orb and not orb.collected then
    orb.x+=orb.vx
    orb.y+=orb.vy
    local m=ORB_R+3
    if orb.x<m or orb.x>127-m then orb.vx=-orb.vx orb.x=mid(m,orb.x,127-m) end
    if orb.y<m+4 or orb.y>127-m then orb.vy=-orb.vy orb.y=mid(m+4,orb.y,127-m) end
    local dx,dy=p.x+p.w/2-orb.x,p.y+p.h/2-orb.y
    if dx*dx+dy*dy<ORB_HR*ORB_HR then
      orb.collected=true
      _spawn_wave(orb.x,orb.y)
      sfx(3)
    end
  end

  for w in all(orb_waves) do
    w.r+=w.spd
    if w.r>w.max_r then del(orb_waves,w) end
  end
end

function draw_hud()
  if level_started then
    local fx=HUD_X+flr((progress_bar_drawing and 1 or level_progress_frame/25)*HUD_W)
    line(HUD_X,HUD_Y,fx,HUD_Y,C_DARK_GRAY)
    progress_bar_drawing=progress_bar_drawing or fx==HUD_X+HUD_W

    fx=HUD_X+flr(min(1,level_progress_frame/level_total_frames)*HUD_W)
    if fx>HUD_X then line(HUD_X,HUD_Y,fx,HUD_Y,C_BLUE) end
    if progress_bar_drawing then
      for ck in all(checkpoints) do
        local tx=HUD_X+flr(ck.frac*HUD_W)
        line(tx,HUD_Y-1,tx,HUD_Y+1,ck.hit and C_WHITE or C_LIGHT_GRAY)
      end
    end
  end

  for c in all(active_checkpoint_markers) do
    local lx=flr(c.x)
    if lx>=0 and lx<=127 then
      for y=0,127,2 do pset(lx,y,C_LIGHT_GRAY) end
    end
  end

  if level_card_state!="idle" and level_card_state!="done" then
    camera(-flr(level_card_position_x),CARD_H-124)
    callfromstring "rectfill,1,1,73,15,C_BLACK/rectfill,0,0,72,14,C_DARK_BLUE/rectfill,0,0,2,14,C_LAVENDER/print,level_name,5,9,C_LIGHT_GRAY/print,card_song,5,3,C_WHITE"
    camera()
  end

  if orb and not orb.collected then
    local ox,oy=flr(orb.x)-4,flr(orb.y)-4
    draw_anim(ox,oy,level_runtime_frames*2,5,16,8)
    draw_anim(ox-4,oy-4,level_runtime_frames,21,5,6,2,2)
  end

  for w in all(orb_waves) do circ(flr(w.x),flr(w.y),flr(w.r),w.col) end

  if level_final_frames>0 then print("frames: "..level_final_frames,2,120,C_WHITE) end
end

function spawn_orb()
  orb=_kv_parts(split("x=12;y=12;vx=0.55;vy=0.4;collected=false",";"))
  orb.x+=rnd(104)
  orb.y+=rnd(104)
  orb_waves={}
end

function orb_collected() return orb==nil or orb.collected end

function _update_card()
  local s=level_card_state
  if s=="idle" or s=="done" then return end
  local tx,x=128-CARD_W,level_card_position_x
  if s=="in" then
    x+=(tx-x)*CART_SPEED_IN
    if abs(x-tx)<.5 then
      x=tx
      if CARD_DISPLAY_TIME>0 then
        level_card_state,card_timer="hold",CARD_DISPLAY_TIME
      else
        level_card_state,level_started="out",true
      end
    end
  elseif s=="hold" then
    card_timer-=1
    if not level_started and card_timer<=CARD_DISPLAY_TIME*(1-CARD_REVEAL_FRAC) then level_started=true end
    if card_timer<=0 then level_card_state="out" end
  else
    x+=(200-x)*CART_SPEED_OUT
    if abs(x-200)<.5 then x,level_card_state=200,"done" end
  end
  level_card_position_x=x
end

function _spawn_wave(cx,cy)
  orb_waves={}
  for i=1,6 do
    add(orb_waves,{x=cx,y=cy,r=i*2,max_r=24+i*14,col=i%2==0 and C_LAVENDER or C_WHITE,spd=1+i*.3})
  end
end