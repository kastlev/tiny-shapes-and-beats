LEVEL_META = {
  "name=LVL 1;song=waves;track=0;total=1560;point1=0.27;point2=0.68;map_x=8",
  "name=LVL 2;song=flux;track=1;total=2100;point1=0.23;point2=0.52;point3=0.78;map_x=16"
}

LEVEL_COUNT = #LEVEL_META

-- plantillas: "funcion;clave=valor;..."
T = {
  h = "spw;enemy_type=E_LINE_BI;x=64;ang=0;len=72;size=3;warning_time=20;duration_frames=18",
  v = "spw;enemy_type=E_LINE_BI;y=64;ang=0.25;len=72;size=3;warning_time=20;duration_frames=18",
  x = "spw;enemy_type=E_CROSS;x=64;y=64;len=72;size=3;ang_vel=0.006;warning_time=30;duration_frames=210",
  b = "spw;enemy_type=E_CIRCLE;size=5;warning_time=25;duration_frames=1;burst=true;burst_count=10;burst_speed=1.4;burst_size=2;burst_duration_frames=110",
  r = "spw;size=1;size_max=70;fill=false;grow_px=1.8;warning_time=20;duration_frames=40",
  c = "spw_loop;pattern=column;column_x=-4;random=true;parallel=true;enemy_type=E_BULLET;size=3;vx=3.4;n=9;duration_frames=45",
  ch = "spw_loop;pattern=perimeter;parallel=true;chase=true;chase_turn=0.05;size=4;warning_time=30;duration_frames=130",
  sq = "spw_loop;enemy_type=E_SQUARE;parallel=true;near_player=true;near_range=24;size=8;warning_time=45;duration_frames=25"
}

function play(t)
  for l in all(t) do
    if type(l) == "number" then
      wait_frames(l)
    else
      local a = split(l, "*")
      for i = 1, #a > 1 and a[1] or 1 do
        for c in all(split(a[#a], "/")) do
          local q = split(c, ";")
          local f, b = deli(q, 1), {}
          if T[f] then
            b = split(T[f], ";")
            f = deli(b, 1)
          end
          local g = _merge(_kv_parts(b), _kv_parts(q))
          for k, v in pairs(g) do
            if v == "?" then g[k] = 14 + rnd(100)
            elseif v == "@" then g[k] = flr(k == "x" and p.x + 2 or p.y + 2) end
          end
          meanwhile(function() _ENV[f](g) end)
          wait_frames(g.w or 0)
        end
      end
    end
  end
end

function level_setup(n)
  local cfg = meta(n)
  level_name, level_song = cfg.name, cfg.song

  local checkpoints = {}
  for i = 1, 4 do
    local key = "point" .. i
    local frac = cfg[key]
    if frac then add(checkpoints, { frac = frac, color = cfg[key .. "_color"] }) end
  end

  hud_start(cfg.total, checkpoints, level_song, level_name)
  wait_for_card()
end

function level_1()
  level_setup(1)
  play {
    -- m1-2 lluvia lenta
    "spw_loop;pattern=row;random=true;n=8;parallel=true;stagger=15;enemy_type=E_BULLET;vy=0.9;size=2;duration_frames=220;w=120",
    -- m3-5 cuadrados cerca del jugador
    "sq;n=8;stagger=15;w=120",
    "sq;n=2;stagger=30/sq;n=2;stagger=30;w=60",
    -- m6-7 anillos lentos
    "spw_loop;pattern=point;x=64;y=64;n=2;parallel=true;stagger=30;size=1;size_max=92;fill=false;grow_px=1.4;warning_time=30;duration_frames=70;w=120",
    120, -- m8-9 respiro + checkpoint 1
    -- m10-14 perseguidores
    "ch;n=4;stagger=30;chase_speed=0.9;w=120",
    "ch;n=8;stagger=15;chase_speed=1.0;w=120",
    "ch;n=12;stagger=5;chase_speed=1.1;w=60",
    -- m15-18 columnas desde la derecha
    "4*c;column_x=140;n=5;vx=-2.2;duration_frames=80;w=30",
    "4*c;column_x=140;n=7;vx=-2.6;duration_frames=80;w=30",
    60, -- m19 respiro + checkpoint 2
    -- m20-24 bola que rebota + anillos
    "spw;x=20;y=20;vx=1.9;vy=1.5;size=3;warning_time=30;duration_frames=270;bounce=true;bounce_speed_mult=1.05;bounce_size_mult=1.06",
    "2*r;grow_px=1.5;warning_time=30;duration_frames=50;w=60",
    "6*r;grow_px=1.5;warning_time=30;duration_frames=50;w=30",
    -- m25-26 final
    "b;x=64;y=64;warning_time=30;burst_count=12;burst_speed=1.3;w=30",
    "b;x=64;y=64;warning_time=30;burst_count=12;burst_speed=1.3;burst_angle_offset=0.04;w=30",
    "spw_loop;pattern=point;x=64;y=64;n=3;parallel=true;stagger=5;size=1;size_max=100;fill=false;grow_px=1.6;warning_time=30;duration_frames=65;w=60"
  }
end

function level_2()
  level_setup(2)
  play {
    -- m1-4 lineas apuntadas al jugador
    "2*h;y=@;warning_time=25;w=30/v;x=@;warning_time=25;w=30",
    "4*h;y=@;w=15/v;x=@;w=15",
    -- m5-8 cruces
    "4*h;y=@/v;x=@;w=30",
    "2*h;y=@/v;x=@/v;x=?;size=4;w=30",
    "2*h;y=@/v;x=@/h;y=?;size=4;w=30",
    120, -- m9-10 respiro + checkpoint 1
    -- m11-15 cruz giratoria + anillos de balas
    "x;w=30",
    "7*b;burst_angle_offset=?;warning_time=20;w=30",
    "h;y=@;w=30/v;x=@;w=30",
    -- m16-18 columnas rapidas + lineas
    "3*c;w=15/h;y=@;warning_time=18;w=15/c;column_x=140;vx=-3.4;w=15/v;x=@;warning_time=18;w=15",
    120, -- m19-20 respiro + checkpoint 2
    -- m21-27 lineas + perseguidores + bola
    "spw;x=20;y=20;vx=2.2;vy=1.7;size=4;warning_time=25;duration_frames=300;bounce=true;bounce_speed_mult=1.04;bounce_size_mult=1.04",
    "ch;n=8;stagger=7;chase_speed=1.5;warning_time=25;duration_frames=150",
    "2*h;y=@;w=30/v;x=@;w=30",
    "2*r/v;x=?;size=4;w=30/r/h;y=?;size=4;w=30",
    "ch;n=6;stagger=7;chase_speed=1.6;warning_time=25;duration_frames=120",
    "6*h;y=@;warning_time=18;w=15/v;x=@;warning_time=18;w=15",
    120, -- m28-29 respiro + checkpoint 3
    -- m30-35 final
    "x;ang_vel=0.007;w=30",
    "4*b;burst_count=12;burst_speed=1.5;burst_angle_offset=?;warning_time=20;w=30",
    "c;w=15/v;x=@;warning_time=15;w=15/c;column_x=140;vx=-3.4;w=15/h;y=@;warning_time=15;w=15/c;w=15/v;x=@;warning_time=15;w=15",
    -- ultimos 4 pares de beats: entra todo junto
    "h;y=@;warning_time=15/v;x=@;warning_time=15/r;w=30",
    "c/h;y=@;warning_time=15;w=30",
    "b;burst_count=12;burst_speed=1.5;burst_angle_offset=?/h;y=@;warning_time=15/v;x=@;warning_time=15;w=30",
    "c;column_x=140;vx=-3.4/h;y=@;warning_time=15/v;x=@;warning_time=15/r/b;burst_count=12;burst_speed=1.5;burst_angle_offset=?;w=30"
  }
end