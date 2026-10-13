function meta(i) return _kv_parts(split(LEVEL_META[i], ";")) end

function level_setup(n)
  local cfg=meta(n)
  local cps={}
  for i=1,4 do
    local f=cfg["point"..i]
    if f then add(cps,{frac=f,color=cfg["point"..i.."_color"]}) end
  end
  hud_start(cfg.total,cps,cfg.song,cfg.name)
  wait_for_card()
  if not simulating then music(cfg.track) end
end

function play(t)
  for l in all(t) do
    if type(l)=="number" then
      wait_frames(l)
    else
      local a=split(l,"*")                     
      for i=1,#a>1 and a[1] or 1 do
        for c in all(split(a[#a],"/")) do  
          local q=split(c,";")
          local f=deli(q,1)                      
          local b=split(T[f] or f,";")           
          f=deli(b,1)
          local g=_merge(_kv_parts(b),_kv_parts(q))
          for k,v in pairs(g) do
            if v=="?" then g[k]=14+rnd(100)      -- ? = aleatorio
            elseif v=="@" then g[k]=flr(k=="x" and p.x+2 or p.y+2) end 
          end
          assert(_ENV[f],"plantilla desconocida: "..f)
          meanwhile(function() _ENV[f](g) end)
          wait_frames(g.wait or 0)
        end
      end
    end
  end
end