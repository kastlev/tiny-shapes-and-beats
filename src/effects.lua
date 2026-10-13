function cfg(s,cols,bg)
  local t=_kv_parts(split(s,";"))
  t.cols,t.bg_steps=cols,bg
  return t
end

_hit_flash_cfg = cfg(
    "frames=8",
    nil,
    {
        {0, C_DARK_PINK},
        {4, C_LAVENDER}
    }
)

_death_flash_cfg = cfg(
    "frames=8",
    nil,
    {
        {0, C_RED},
        {2, C_DARK_PINK}
    }
)

_hit_particle_cfg = cfg(
    "min_vel=.8;max_vel=2.5;min_life=10;max_life=20;layer=front",
    split"7,6,12,12,13"
)

_trail_particle_cfg = cfg(
    "min_vel=.1;max_vel=.3;min_life=6;max_life=20;min_size=1;max_size=3;square=true;rate=2;shrink=true;tag=trail",
    split"1"
)

_bounce_particle_cfg = cfg(
    "min_vel=.5;max_vel=1.8;min_life=8;max_life=16;layer=front",
    split"7,14,2"
)

_bg_particle_cfg = cfg(
    "min_vel=.1;max_vel=.6;min_size=1;max_size=1;min_life=40;max_life=100;shrink=false;tag=menu_bg",
    split"1,5"
)

-- TRAIL_COLOR_BY_BG = {
--     [C_BLACK] = split"1",
--     [C_DARK_PINK] = split"13",
--     [C_LAVENDER] = split"2"
-- }

TRAIL_COLOR_DEFAULT = split"1"

-- function trigger_hit_effect()
--     trigger_screen_flash(p.hp > 0 and _hit_flash_cfg or _death_flash_cfg)

--     if p.hp > 0 then
--         trigger_hitstop()
--         add_trauma(0.4)
--         sfx(2)
--     else
--         add_trauma(0.6)
--         sfx(1)
--     end

--     spawn_hit_particles(p.x + p.w / 2, p.y + p.h / 2)
-- end

-- function draw_screen_fx()
--     bg_color = apply_screen_flash(bg_color_base, { bg_color_base })
-- end

-- function spawn_hit_particles(x, y, cfg)
--     cfg = cfg or _hit_particle_cfg
--     for i = 1, rndb(8, 16) do
--         spawn_particle(x, y, cfg)
--     end
-- end

function spawn_trail_particle(x, y, gx, gy)
    _trail_particle_cfg.cols = TRAIL_COLOR_BY_BG[bg_color_base] or TRAIL_COLOR_DEFAULT
    spawn_particle(x, y, _trail_particle_cfg, gx, gy)
end

function spawn_bg_particles()
    if frame % 10 == 0 then
        _bg_particle_cfg.square = rnd() < .5
        spawn_particle(rnd(128), rnd(128), _bg_particle_cfg)
    end
end



TRAIL_COLOR_BY_BG={[C_DARK_PINK]=split"13",[C_LAVENDER]=split"2"}
TRAIL_COLOR_DEFAULT=split"1"

function trigger_hit_effect()
  trigger_screen_flash(p.hp>0 and _hit_flash_cfg or _death_flash_cfg)
  if p.hp>0 then
    hitstop_timer=2
    add_trauma(.4)
    sfx(2)
  else
    add_trauma(.6)
    sfx(1)
  end
  spawn_hit_particles(p.x+2,p.y+2) -- hitbox 4x4
end

function draw_screen_fx()
  bg_color=bg_color_base
  if fading then return end
  pal()
  pal(bg_color,bg_color+128,1)
  if screen_flash_timer>0 then
    for c in all(screen_flash_cfg.colors or ALL_COLORS) do pal(c,c+128,1) end
    for s in all(screen_flash_cfg.bg_steps) do
      if screen_flash_timer_max-screen_flash_timer>=s[1] then bg_color=s[2] end
    end
  end
end

function spawn_hit_particles(x,y,cfg)
  for i=1,rndb(8,16) do spawn_particle(x,y,cfg or _hit_particle_cfg) end
end
