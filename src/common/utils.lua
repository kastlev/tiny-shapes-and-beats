function lerp_to(a,b,i,m)
  local r=(1-i)*a+i*b
  return abs(b-r)<m and b or r
end

function rndb(low,high)
  return flr(rnd(high-low+1)+low)
end

function callfromstring(l)
  for s in all(split(l,"/")) do
    s=split(s)
    for i,v in inext,s do s[i]=_ENV[v] or tonum(v) or v end
    deli(s,1)(unpack(s))
  end
end

function _merge(base,over)
  for k,v in pairs(over or {}) do base[k]=v end
  return base
end

function cycling_color(c,rate,t) return c[t\rate%#c+1] end

function draw_anim(x,y,t,sp,n,spd,w,h,step)
  w=w or 1
  spr(sp+t\spd%n*(step or w),x,y,w,h or 1)
end

function line_c(x,y,len,width,ang,col,centered)
  local dx,dy=cos(ang),sin(ang)
  for i=centered and -len or 0,len do
    circfill(x+dx*i,y+dy*i,width/2,col)
  end
end

function _kv_parts(parts)
  local t={}
  for pair in all(parts) do
    local k,v=unpack(split(pair,"="))
    t[k]=v=="true" or v!="false" and (tonum(v) or _ENV[v] or v)
  end
  return t
end

function run(str)
  local last
  for call in all(split(str,"/")) do
    local br=split(call,"|")
    if #br>1 then
      local fns={}
      for b in all(br) do add(fns,function() run(b) end) end
      last=sync(unpack(fns))
    else
      local parts=split(call,";")
      local f=deli(parts,1)
      last=_ENV[f](_kv_parts(parts))
    end
  end
  return last
end

function _ease(t) return mid(0,t,1) end