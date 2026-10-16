enemies={}

function _draw_shape(x,y,s,fill,sq,col)
  if sq then
    (fill and rectfill or rect)(x-s,y-s,x+s,y+s,col)
  else
    (fill and circfill or circ)(x,y,s,col)
  end
end

enemy_types={
  [E_CIRCLE]=function(e) _draw_shape(e.x,e.y,e.size,e.fill,false,enemy_color(e)) end,
  [E_SQUARE]=function(e) _draw_shape(e.x,e.y,e.size,e.fill,true,enemy_color(e)) end,
  [E_LINE_BI]=function(e) line_c(e.x,e.y,e.len,e.size*2,e.ang,enemy_color(e),true) end,
  [E_CROSS]=function(e)
    local c=enemy_color(e)
    line_c(e.x,e.y,e.len,e.size*2,e.ang,c,true)
    line_c(e.x,e.y,e.len,e.size*2,e.ang+.25,c,true)
  end,
  [E_BULLET]=function(e) _draw_shape(flr(e.x),flr(e.y),e.size,true,e.shape=="square",enemy_color(e)) end,
  [E_HOLE]=function(e)
    poke(0x5f34,2)
    circfill(e.x,e.y,e.size,enemy_color(e)|0x1800)
    poke(0x5f34,0)
  end
}

function enemy_color(e)
  if e.flicker then
    local c=e.flicker_colors or {C_PINK,C_WHITE}
    return c[e.age\(e.flicker_frames or 4)%#c+1]
  end
  return e.draw_behind and C_DARK_PINK or e.color or C_PINK
end

-- b: count,speed,ang,type(def E_BULLET),quiet + cualquier parametro de enemigo
function fire_bullet_ring(x,y,b)
  local n,v=b.count or 8,b.speed or 1.5
  for i=0,n-1 do
    local a=(b.ang or 0)+i/n
    _create_enemy(b.type or E_BULLET,x,y,_merge({vx=cos(a)*v,vy=sin(a)*v,frames=80},b))
  end
  if not b.quiet then
    trigger_screen_flash(_hit_flash_cfg)
    spawn_hit_particles(x,y,_bounce_particle_cfg)
  end
end

-- todo burst_X del emisor pasa a ser X del hijo (burst_type, burst_chase, burst_size...)
function spawn_bullet_burst(e)
  local b={}
  for k,v in pairs(e) do
    if sub(k,1,6)=="burst_" then b[sub(k,7)]=v end
  end
  fire_bullet_ring(e.x,e.y,b)
end

function update_enemies()
  player_in_danger=false
  local cx,cy=p.x+2,p.y+2

  for e in all(enemies) do
    e.age+=1
    e.draw_behind=e.frames+e.hold_frames-e.age<=1

    if e.age<=e.move_delay then
    elseif e.orbit then
      e.ang_offset+=e.orbit_spin
      e.orbit_radius+=e.orbit_grow
      e.x=e.orbit_cx+cos(e.ang_offset)*e.orbit_radius
      e.y=e.orbit_cy+sin(e.ang_offset)*e.orbit_radius
    elseif e.chase then
      local a=atan2(p.x-e.x,p.y-e.y)
      e.vx=lerp_to(e.vx,cos(a)*e.speed,e.chase_turn,.02)
      e.vy=lerp_to(e.vy,sin(a)*e.speed,e.chase_turn,.02)
      e.x+=e.vx
      e.y+=e.vy
    elseif e.target_x or e.target_y then
      if e.move_ease=="lerp" then
        if e.target_x then e.x+=(e.target_x-e.x)*e.move_lerp end
        if e.target_y then e.y+=(e.target_y-e.y)*e.move_lerp end
      else
        local t=min(1,(e.age-e.move_delay)/(e.frames-e.move_delay))
        local et=_ease(t,e.move_ease)
        if e.target_x then e.x=e.origin_x+(e.target_x-e.origin_x)*et end
        if e.target_y then e.y=e.origin_y+(e.target_y-e.origin_y)*et end
      end
    else
      if e.pull then
        local a=atan2(cx-e.x,cy-e.y)
        e.vx+=cos(a)*e.pull
        e.vy+=sin(a)*e.pull
      end
      e.x+=e.vx
      e.y+=e.vy
    end

    if e.wave then
      local o=sin(e.age*e.wave_freq)*e.wave_amp
      e[e.wave_axis]+=o-(e.wave_last_off or 0)
      e.wave_last_off=o
    end

    if e.wrap then
      if e.x<-8 then e.x=136 elseif e.x>136 then e.x=-8 end
      if e.y<-8 then e.y=136 elseif e.y>136 then e.y=-8 end
    elseif e.bounce then
      local b
      if e.x<0 or e.x>128 then e.vx,e.x,b=sgn(64-e.x)*abs(e.vx),mid(0,e.x,128),1 end
      if e.y<0 or e.y>128 then e.vy,e.y,b=sgn(64-e.y)*abs(e.vy),mid(0,e.y,128),1 end
      if b then
        local j=rnd(.06)-.03
        local ca,sa,m=cos(j),sin(j),e.bounce_speed_mult
        e.vx,e.vy=(e.vx*ca-e.vy*sa)*m,(e.vx*sa+e.vy*ca)*m
        e.size*=e.bounce_size_mult
        add_trauma(mid(.1,e.size*.02,.6))
        spawn_hit_particles(e.x,e.y,_bounce_particle_cfg)
        sfx(5)
      end
    end

    e.ang+=e.spin

    if e.age<=e.grow_delay then
    elseif e.grow then
      local m=e.grow_mode
      if m=="lerp" then
        e.size+=(e.size_max-e.size)*e.grow_lerp
      elseif m=="curve" then
        local t=min(1,(e.age-e.grow_delay)/max(1,e.frames-e.grow_delay))
        e.size=e.size_start+(e.size_max-e.size_start)*_ease(t,e.grow_ease)
      else
        e.size=min(e.size_max,e.size+e.grow_px)
      end
    end

    local l=(e.type==E_LINE_BI or e.type==E_CROSS) and e.len or 0
    local dx,dy,r=cx-e.x,cy-e.y,e.size+3+l
    if not e.is_warning and dx*dx+dy*dy<r*r then player_in_danger=true end

    local mg=e.size+16+l
    local out=not e.wrap and not e.bounce and (abs(e.x-64)>64+mg or abs(e.y-64)>64+mg)

    if e.age>e.frames+e.hold_frames or out then
      if e.burst and not out then spawn_bullet_burst(e) end
      e.alive=false
      del(enemies,e)
    end
  end
end

function draw_enemies(behind)
  for e in all(enemies) do
    if not(e.is_warning or e.draw_behind)==not behind then enemy_types[e.type](e) end
  end
end

function spawn(etype,x,y,params)
  params=params or {}
  wait_frames(params.spawn_delay or 0)

  params.type=etype
  etype=etype or E_CIRCLE
  x=x or 10+rnd(108)
  y=y or 10+rnd(108)

  if params.near_player then
    local r=params.near_range or 20
    x=mid(6,p.x+p.w/2+rnd(r*2)-r,121)
    y=mid(6,p.y+p.h/2+rnd(r*2)-r,121)
  end

  if params.orbit then
    local a,r=params.ang_offset or rnd(),params.orbit_radius or 20
    params.ang_offset,params.orbit_radius,params.orbit_cx,params.orbit_cy=a,r,params.orbit_cx or x,params.orbit_cy or y
    x,y=params.orbit_cx+cos(a)*r,params.orbit_cy+sin(a)*r
  end

  local burst=params.count
  local sz=params.size or 10
  local warn=params.warn
  if warn==nil then warn=not burst and etype!=E_BULLET end

  if warn then
    if sz>=40 then add_trauma(.1) end
    wait_until_enemy_dead(_create_enemy(etype,x,y,{
      size=params.warn_size or sz,fill=params.fill,color=params.warn_color or C_DARK_PINK,
      frames=params.warn_frames or 20,
      len=params.len,ang=params.ang,is_warning=true}))
  end

  if burst then
    fire_bullet_ring(x,y,params)
    return
  end

  if params.dir or params.dir_random then
    local sp=params.dir_spread or 1
    local a=(params.dir or 0)+(params.dir_random and rnd(sp)-sp/2 or 0)
    local lo=params.speed_min or 1
    local v=params.speed_random and lo+rnd((params.speed_max or 3)-lo) or params.speed or 1
    params.vx,params.vy=cos(a)*v,sin(a)*v
  end

  if params.aim_speed then
    local a=atan2(p.x+2-x,p.y+2-y)
    params.vx,params.vy=cos(a)*params.aim_speed,sin(a)*params.aim_speed
  end

  params.size=sz
  params.frames=params.frames or 40
  return _create_enemy(etype,x,y,params)
end

local DEFAULTS=_kv_parts(split("chase=false;wrap=false;bounce=false;wave=false;flicker=false;burst=false;is_warning=false;orbit=false;move_delay=0;grow_delay=0;move_lerp=.1;speed=1.6;chase_turn=.06;grow_px=.5;grow_lerp=.1;wave_amp=10;wave_freq=.05;wave_axis=y;frames=30;hold_frames=0;len=80;ang=0;spin=0;orbit_spin=.01;orbit_grow=0;vx=0;vy=0;bounce_speed_mult=1;bounce_size_mult=1",";"))

function _create_enemy(t,x,y,s)
  local s0=s.size or (t==E_BULLET and 1 or 2)
  s.type,s.x,s.y,s.origin_x,s.origin_y=t,x,y,x,y
  s.size,s.size_start,s.size_max=s0,s0,s.size_max or s0
  s.grow=s.size_max>s0
  s.grow_mode=s.grow_lerp and "lerp" or s.grow_ease and "curve" or "px"
  for k,v in pairs(DEFAULTS) do s[k]=s[k] or v end
  s.fill=s.fill~=false
  s.alive,s.age=true,0
  add(enemies,s)
  return s
end