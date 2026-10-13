function init_camera()
  shk_x,shk_y,kick_x,kick_y=0,0,0,0
end

function draw_camera()
  if abs(shk_x)+abs(shk_y)<.7 then
    shk_x,shk_y=0,0
  else
    local f=-(.45+rnd(.2))
    shk_x*=f
    shk_y*=f
  end
  kick_x=lerp_to(kick_x,0,.6,.3)
  kick_y=lerp_to(kick_y,0,.6,.3)
  camera(shk_x+kick_x,shk_y+kick_y)
end

function add_trauma(a)
  local r=rnd()
  shk_x+=a*12*cos(r)
  shk_y+=a*12*sin(r)
end

function wall_bump_shake(a)
  kick_x+=cos(a)*7
  kick_y+=sin(a)*7
end