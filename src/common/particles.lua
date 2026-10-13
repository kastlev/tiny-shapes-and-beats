function init_particle() ps={} end

function spawn_particle(x,y,c,gx,gy)
  c=c or {}
  c._tick=((c._tick or -1)+1)%(c.rate or 1)
  if c._tick!=0 then return end
  local lo=c.min_size or 0
  local hi=c.max_size or lo
  local v=c.min_vel or .5
  local a,f=rnd(),v+rnd((c.max_vel or 1.5)-v)
  local cols=c.cols or {7}
  add(ps,{x=x,y=y,vx=cos(a)*f,vy=sin(a)*f,
    life=rndb(c.min_life or 10,c.max_life or 20),age=0,
    col=cols[1],cols=cols,gx=gx or c.gx or 0,gy=gy or c.gy or 0,
    size=c.shrink and hi or lo+rnd(hi-lo),size_max=hi,size_min=lo,
    shrink=c.shrink,square=c.square,trail=c.trail,tag=c.tag,
    age_mult=1,layer=c.layer or "back"})
end

function update_particles()
  for pt in all(ps) do
    pt.vx+=pt.gx
    pt.vy+=pt.gy
    pt.x+=pt.vx
    pt.y+=pt.vy
    pt.age+=pt.age_mult
    if pt.age>=pt.life then
      del(ps,pt)
    else
      local t=pt.age/pt.life
      if pt.shrink then pt.size=pt.size_min+(pt.size_max-pt.size_min)*(1-t) end
      pt.col=pt.cols[flr(t*#pt.cols)+1]
    end
  end
end

function draw_particles(layer)
  for pt in all(ps) do
    if pt.layer==layer then
      local x,y,s=flr(pt.x),flr(pt.y),pt.size
      if pt.trail then
        line(flr(pt.x-pt.vx),flr(pt.y-pt.vy),x,y,pt.col)
      elseif s<=0 then
        pset(x,y,pt.col)
      elseif pt.square then
        local lo,hi=s\2,(s+1)\2-1
        rectfill(x-lo,y-lo,x+hi,y+hi,pt.col)
      else
        circfill(x,y,s,pt.col)
      end
    end
  end
end

function expire_particles(tag,r)
  for pt in all(ps) do
    if pt.tag==tag then pt.life=min(pt.life,pt.age+(r or 8)) end
  end
end