function init_player()
	p = _kv_parts(split(
		"hp=1;hp_max=4;x=61;y=61;input_x=0;input_y=0;acc=0.9;friction=0.8;dx=0;dy=0;max_dx=2.5;max_dy=2.5;sp=1;flip_x=false;flip_y=false;scl_x=1;scl_y=1;w=4;h=4;dash_dir_x=0;dash_dir_y=0;dash_timer_max=8;dash_timer=0;dash_force_max=4;dash_force=0;dash_cooldown_max=16;dash_cooldown_timer=0;dash_explosion_x=0;dash_explosion_y=0;dash_buffer_timer=0;dash_buffer_max=7;dash_wall_hit=false;last_input_x=0;last_input_y=0;last_input_timer=0;last_input_max=5;is_diagonal=false;is_dashing=false;is_invulnerable=false;is_stunned=false;is_dead=false;hit_iframes_timer=0;hit_iframes_timer_max=40;trail_active=false;in_danger=false",
		";"
	))
end
function update_player()
  if p.is_dead then
    update_death_bullets()
    return
  end

  local dx=(btn(➡️) and 1 or 0)-(btn(⬅️) and 1 or 0)
  local dy=(btn(⬇️) and 1 or 0)-(btn(⬆️) and 1 or 0)
  p.input_x,p.input_y=dx,dy

  if dx!=0 or dy!=0 then
    p.last_input_x,p.last_input_y,p.last_input_timer=dx,dy,p.last_input_max
    local len=sqrt(dx*dx+dy*dy)
    p.dx+=dx/len*p.acc
    p.dy+=dy/len*p.acc
  end

  p.dx*=p.friction
  p.dy*=p.friction
  p.is_dashing=p.dash_timer>0
  if btnp(❎) then p.dash_buffer_timer=p.dash_buffer_max end

  local ix,iy=p.last_input_x,p.last_input_y
  if p.dash_buffer_timer>0 and p.dash_cooldown_timer<=0 and not p.is_dashing and (ix!=0 or iy!=0) then
    sfx(0)
    local len=sqrt(ix*ix+iy*iy)
    p.dash_dir_x,p.dash_dir_y=ix/len,iy/len
    p.dash_timer,p.dash_cooldown_timer,p.dash_buffer_timer=p.dash_timer_max,p.dash_cooldown_max,0
    p.dash_explosion_x,p.dash_explosion_y=p.x+2,p.y+2
    p.dash_wall_hit=false
  end

  if p.dash_timer>0 then
    local f=p.dash_force_max*p.dash_timer/p.dash_timer_max
    p.dx+=p.dash_dir_x*f
    p.dy+=p.dash_dir_y*f
    p.dash_timer-=1
  end

  p.x+=p.dx
  p.y+=p.dy
  local bx,by=p.x,p.y
  p.x=mid(0,p.x,123) -- 127-w
  p.y=mid(0,p.y,123)

  if p.is_dashing and not p.dash_wall_hit and (p.x!=bx or p.y!=by) then
    p.dash_wall_hit=true
    wall_bump_shake(atan2(-p.dash_dir_x,-p.dash_dir_y))
    sfx(5)
  end

  p.dx=mid(-p.max_dx,p.dx,p.max_dx)
  p.dy=mid(-p.max_dy,p.dy,p.max_dy)
  p.is_invulnerable=p.is_dashing or p.hit_iframes_timer>0

  if not p.is_invulnerable then
    local x1,y1=flr(p.x)+1,flr(p.y)+1
    local x2,y2=x1+3,y1+3
    local l,r=edge_hit(x1,y1,x1,y2),edge_hit(x2,y1,x2,y2)
    local t,b=edge_hit(x1,y1,x2,y1),edge_hit(x1,y2,x2,y2)
    if l then p.dx=7.5 end
    if r then p.dx=-7.5 end
    if t then p.dy=7.5 end
    if b then p.dy=-7.5 end
    if l or r or t or b or check_hole_danger(7.5) then
      p.hit_iframes_timer=p.hit_iframes_timer_max
      p.hp-=1
      if p.hp<=0 then
        p.is_dead=true
        spawn_death_bullets(p.x+2,p.y+2)
        music(-1, 900)
      end
      trigger_hit_effect()
    end
  end

  for t in all(split"dash_cooldown_timer,hit_iframes_timer,dash_buffer_timer,last_input_timer") do
    p[t]=max(0,p[t]-1)
  end
  if p.last_input_timer<=0 then p.last_input_x,p.last_input_y=0,0 end
end

function draw_player()
  if p.is_dead then
    draw_death_bullets()
    return
  end

  p.flip_x=p.dx<0
  p.flip_y=p.dy<0

  local spd=sqrt(p.dx*p.dx+p.dy*p.dy)
  if spd>.6 then
    spawn_trail_particle(p.x+2-p.dx/spd*3,p.y+2-p.dy/spd*3)
    p.trail_active=true
  end
  if p.trail_active and p.input_x==0 and p.input_y==0 then
    expire_particles("trail",8)
    p.trail_active=false
  end

  local diag=p.input_x!=0 and p.input_y!=0
  p.sp=p.is_dashing and (diag and 0 or p.dash_dir_x!=0 and 2 or 3) or diag and 4 or 1

  if p.is_dashing then
    local r=5-p.dash_timer
    if r>0 then
      (p.dash_timer>1 and circfill or circ)(p.dash_explosion_x-1,p.dash_explosion_y-1,r,C_BLUE)
    end
    for i=0,15 do pal(i,C_DARK_GRAY,0) end
    spr(p.sp,p.x-p.dash_dir_x-1,p.y-p.dash_dir_y-1,1,1,p.flip_x,p.flip_y)
    pal(0)
  end

  local t=p.hit_iframes_timer
  local fl=t>0 and t\max(1,flr(4*t/p.hit_iframes_timer_max))%2==0
  if fl then pal(C_BLUE,C_DARK_PINK,0) end
  spr(p.sp,p.x-1,p.y-1,1,1,p.flip_x,p.flip_y)
  if fl then pal(0) end

  -- cuadrantes: 1 arriba-der, 2 abajo-der, 3 abajo-izq, 4 arriba-izq
  for i=1,p.hp_max-p.hp do
    clip(p.x-1+(i<3 and 4 or 0),p.y-1+i%4\2*4,4,4)
    for c=0,15 do pal(c,C_DARK_BLUE,0) end
    spr(p.sp,p.x-1,p.y-1,1,1,p.flip_x,p.flip_y)
    pal(0)
    clip()
  end
end

function edge_hit(x1,y1,x2,y2)
  for x=x1,x2 do
    for y=y1,y2 do
      if pget(x,y)==C_PINK then return true end
    end
  end
  return false
end

function check_hole_danger(force)
  for e in all(enemies) do
    if e.type==E_HOLE and not e.is_warning then
      local dx,dy=p.x+2-e.x,p.y+2-e.y
      local d2=dx*dx+dy*dy
      if d2>e.size*e.size then
        local d=sqrt(d2)
        p.dx,p.dy=-dx/d*force,-dy/d*force
        return true
      end
    end
  end
  return false
end

function edge_hit(x1,y1,x2,y2)
  for x=x1,x2 do
    for y=y1,y2 do
      if pget(x,y)==C_PINK then return true end
    end
  end
  return false
end

function check_hole_danger(force)
  for e in all(enemies) do
    if e.type==E_HOLE and not e.is_warning then
      local dx,dy=p.x+2-e.x,p.y+2-e.y
      local d2=dx*dx+dy*dy
      if d2>e.size*e.size then
        local d=sqrt(d2)
        p.dx,p.dy=-dx/d*force,-dy/d*force
        return true
      end
    end
  end
  return false
end