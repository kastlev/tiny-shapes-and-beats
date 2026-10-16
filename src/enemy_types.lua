function spw(cfg)
  local e,x,y=cfg.type,cfg.x,cfg.y
  cfg.type,cfg.x,cfg.y=nil,nil,nil
  return spawn(e,x,y,cfg)
end

function _dist(i,n,minv,maxv,random)
  return random and rnd(maxv-minv)+minv or minv+(i-1)*(maxv-minv)\max(1,n-1)
end

function _spw_pos(pt,i,n,c)
  local m=c.pos_margin or 10
  if pt=="perimeter" then
    local r=c.radius or 46
    local u=(c.pos_random and rnd() or (i-1)/n)*4
    return 64+r*mid(-1,2-2*abs(u-1.5),1),64+r*mid(-1,2-2*abs(u-2.5),1)
  elseif pt=="circle" then
    local r,a=c.radius or 50,(i-1)/n
    return 64+cos(a)*r,64+sin(a)*r
  elseif pt=="row" then
    return _dist(i,n,m,128-m,c.pos_random),c.row_y or -4
  elseif pt=="column" then
    return c.column_x or -4,_dist(i,n,m,128-m,c.pos_random)
  elseif pt=="point" then
    return c.x or 64,c.y or 64
  end
end

function spw_loop(cfg)
  local n,coros=cfg.n or 6,{}
  for i=1,n do
    local x,y=_spw_pos(cfg.pattern,i,n,cfg)
    local s=_merge({},cfg)
    if cfg.pattern=="circle" then s.ang_offset=(i-1)/n end
    if cfg.explode then
      local a,v=(cfg.ang or 0)+(i-1)/n,cfg.speed or 1.5
      s.vx,s.vy=cos(a)*v,sin(a)*v
    end
    for k,v in pairs(cfg) do
      if sub(k,1,8)=="stagger_" then
        local f=sub(k,9)
        s[f]=(cfg[f] or 0)+v*(i-1)
      end
    end
    if cfg.parallel then
      s.spawn_delay=(cfg.stagger or 0)*(i-1)
      add(coros,meanwhile(function() spawn(cfg.type,x,y,s) end))
    else
      spawn(cfg.type,x,y,s)
      wait_frames(cfg.spawn_interval or 15)
    end
  end
  for co in all(coros) do wait_until_pattern_finished(co) end
end