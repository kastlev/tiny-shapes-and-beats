death_sequence_started,death_bullets=false,{}

function spawn_death_bullets(x,y)
  for i=0,5 do
    local a=i/6
    add(death_bullets,{x=x,y=y,dx=cos(a)*1.5,dy=sin(a)*1.5,age=0})
  end
end

function update_death_bullets()
  for b in all(death_bullets) do
    b.x+=b.dx
    b.y+=b.dy
    b.age+=1
    if b.age>60 then del(death_bullets,b) end
  end
end

function draw_death_bullets()
  for b in all(death_bullets) do
    local s=8-b.age/7.5
    if s>.5 then sspr(0,16,8,8,b.x-s/2,b.y-s/2,s,s) end
  end
end