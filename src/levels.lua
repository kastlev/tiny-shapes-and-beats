

LEVEL_META = {
  "name=LVL 1;song=waves;track=0;total=1560;point1=0.27;point2=0.68;map_x=8",
  "name=LVL 2;song=flux;track=8;total=2100;point1=0.23;point2=0.52;point3=0.78;map_x=16",
  "name=LVL 3;song=zona;track=16;total=2400;point1=0.25;point2=0.55;map_x=24"
}
LEVEL_COUNT = #LEVEL_META

T = {
  hline   = "spw;type=E_LINE_BI;x=64;ang=0;len=72;size=3;warning_frames=20;duration_frames=18",
  vline   = "spw;type=E_LINE_BI;y=64;ang=0.25;len=72;size=3;warning_frames=20;duration_frames=18",
  cross   = "spw;type=E_CROSS;x=64;y=64;len=72;size=3;ang_vel=0.006;warning_frames=30;duration_frames=210",
  ring    = "spw;size=1;size_max=70;fill=false;grow_px=1.8;warning_frames=20;duration_frames=40",
  burst   = "spw;type=E_CIRCLE;size=5;warning_frames=25;duration_frames=1;burst=true;burst_count=10;burst_speed=1.4;burst_size=2;burst_duration_frames=110",
  column  = "spw_loop;pattern=column;column_x=-4;random=true;parallel=true;type=E_BULLET;size=3;vx=3.4;n=9;duration_frames=45",
  rain    = "spw_loop;pattern=row;random=true;n=3;parallel=true;type=E_BULLET;size=3;vy=1.5;duration_frames=100",
  aimed   = "spw;type=E_BULLET;size=3;aim=2.2;duration_frames=120",
  spiral  = "spw_loop;pattern=point;x=64;y=64;n=16;type=E_CIRCLE;size=3;color=13;warning=false;duration_frames=1;burst=true;burst_count=3;burst_speed=1.3;burst_size=2;burst_duration_frames=110;spawn_interval=5;stagger_burst_angle_offset=0.03;burst_quiet=true",
  emitter = "spw;type=E_CIRCLE;size=4;warning=false;ease_move=out_quad;duration_frames=30;hold_frames=20;flicker=true;burst=true",
  chasers = "spw_loop;pattern=perimeter;parallel=true;chase=true;chase_turn=0.05;size=4;warning_frames=30;duration_frames=130",
  squares = "spw_loop;type=E_SQUARE;parallel=true;near_player=true;near_range=24;size=8;warning_frames=45;duration_frames=25",
  zone     = "spw;type=E_HOLE;x=64;y=64;size=36;warning_frames=45;duration_frames=195",
  orbzone  = "spw;type=E_HOLE;orbit=true;orbit_cx=64;orbit_cy=64;orbit_ang=0;orbit_radius=22;orbit_speed=0.006;x=86;y=64;size=34;warning_frames=45;duration_frames=315",
  lens     = "spw;type=E_HOLE;orbit=true;orbit_cx=64;orbit_cy=64;orbit_radius=12;orbit_speed=0.006;y=64;size=36;warning_frames=30;duration_frames=330",
  jumpzone = "spw;type=E_HOLE;size=28;warning_frames=30;duration_frames=90",
  zonering = "spw;size=1;size_max=30;fill=false;grow_px=0.9;warning_frames=30;duration_frames=34"
}

function level_1()
  level_setup(1)
  play {
    "spw_loop;pattern=row;random=true;n=8;parallel=true;stagger=15;type=E_BULLET;vy=0.9;size=2;duration_frames=220;wait=120", -- f0 lluvia
    "squares;n=8;stagger=15;wait=120",                       -- f120 cuadrados de uno en uno
    "squares;n=2;stagger=30/squares;n=2;stagger=30;wait=60", -- f240 cuadrados de dos en dos
    "spw_loop;pattern=point;x=64;y=64;n=2;parallel=true;stagger=30;size=1;size_max=92;fill=false;grow_px=1.4;warning_frames=30;duration_frames=70;wait=120", -- f300 anillos
    120,                                                     -- f420 RESPIRO (checkpoint 1)
    "chasers;n=4;stagger=30;chase_speed=0.9;wait=120",       -- f540 perseguidores x4
    "chasers;n=8;stagger=15;chase_speed=1.0;wait=120",       -- f660 x8
    "chasers;n=12;stagger=5;chase_speed=1.1;wait=60",        -- f780 x12
    "4*column;column_x=140;n=5;vx=-2.2;duration_frames=80;wait=30", -- f840 columnas
    "4*column;column_x=140;n=7;vx=-2.6;duration_frames=80;wait=30", -- f960 columnas +
    60,                                                      -- f1080 RESPIRO (checkpoint 2)
    "spw;x=20;y=20;vx=1.9;vy=1.5;size=3;warning_frames=30;duration_frames=270;bounce=true;bounce_speed_mult=1.05;bounce_size_mult=1.06", -- f1140 bola rebota
    "2*ring;grow_px=1.5;warning_frames=30;duration_frames=50;wait=60", -- f1140 anillos
    "6*ring;grow_px=1.5;warning_frames=30;duration_frames=50;wait=30", -- f1260 anillos rapido
    "burst;x=64;y=64;warning_frames=30;burst_count=12;burst_speed=1.3;wait=30", -- f1440 final
    "burst;x=64;y=64;warning_frames=30;burst_count=12;burst_speed=1.3;burst_angle_offset=0.04;wait=30", -- f1470
    "spw_loop;pattern=point;x=64;y=64;n=3;parallel=true;stagger=5;size=1;size_max=100;fill=false;grow_px=1.6;warning_frames=30;duration_frames=65;wait=60" -- f1500 anillos triples
  }                                                          -- f1560 = total
end
function level_2()
  level_setup(2)
  play {
    "2*hline;y=@;warning_frames=25;wait=30/vline;x=@;warning_frames=25;wait=30", -- f0 lineas apuntadas lento
    "4*hline;y=@;wait=15/vline;x=@;wait=15",                 -- f120 lineas apuntadas al beat
    "4*hline;y=@/vline;x=@;wait=30",                         -- f240 cruces sobre el jugador
    "2*hline;y=@/vline;x=@/vline;x=?;size=4;wait=30",        -- f360 cruz + vline gruesa
    "2*hline;y=@/vline;x=@/hline;y=?;size=4;wait=30",        -- f420 cruz + hline gruesa
    120,                                                     -- f480 RESPIRO (checkpoint 1)
    "cross;wait=30",                                         -- f600 cruz giratoria
    "7*burst;burst_angle_offset=?;warning_frames=20;wait=30", -- f630 bursts (la cruz sigue)
    "hline;y=@;wait=30/vline;x=@;wait=30",                   -- f840 lineas
    "3*column;wait=15/hline;y=@;warning_frames=18;wait=15/column;column_x=140;vx=-3.4;wait=15/vline;x=@;warning_frames=18;wait=15", -- f900 columnas alternas + lineas
    120,                                                     -- f1080 RESPIRO (checkpoint 2)
    "spw;x=20;y=20;vx=2.2;vy=1.7;size=4;warning_frames=25;duration_frames=300;bounce=true;bounce_speed_mult=1.04;bounce_size_mult=1.04", -- f1200 bola rebota (sin wait)
    "chasers;n=8;stagger=7;chase_speed=1.5;warning_frames=25;duration_frames=150", -- f1200 perseguidores x8 (sin wait)
    "2*hline;y=@;wait=30/vline;x=@;wait=30",                 -- f1200 lineas
    "2*ring/vline;x=?;size=4;wait=30/ring/hline;y=?;size=4;wait=30", -- f1320 anillos + lineas gruesas
    "chasers;n=6;stagger=7;chase_speed=1.6;warning_frames=25;duration_frames=120", -- f1440 perseguidores x6 (sin wait)
    "6*hline;y=@;warning_frames=18;wait=15/vline;x=@;warning_frames=18;wait=15", -- f1440 lineas rapidas
    120,                                                     -- f1620 RESPIRO (checkpoint 3)
    "cross;ang_vel=0.007;wait=30",                           -- f1740 FINAL cruz giratoria
    "4*burst;burst_count=12;burst_speed=1.5;burst_angle_offset=?;warning_frames=20;wait=30", -- f1770 bursts
    "column;wait=15/vline;x=@;warning_frames=15;wait=15/column;column_x=140;vx=-3.4;wait=15/hline;y=@;warning_frames=15;wait=15/column;wait=15/vline;x=@;warning_frames=15;wait=15", -- f1890 columnas + lineas
    "hline;y=@;warning_frames=15/vline;x=@;warning_frames=15/ring;wait=30", -- f1980 cruz + anillo
    "column/hline;y=@;warning_frames=15;wait=30",            -- f2010 columna + linea
    "burst;burst_count=12;burst_speed=1.5;burst_angle_offset=?/hline;y=@;warning_frames=15/vline;x=@;warning_frames=15;wait=30", -- f2040 burst + cruz
    "column;column_x=140;vx=-3.4/hline;y=@;warning_frames=15/vline;x=@;warning_frames=15/ring/burst;burst_count=12;burst_speed=1.5;burst_angle_offset=?;wait=30" -- f2070 todo junto
  }                                                          -- f2100 = total
end
function level_3()
  level_setup(3)
  play {
    "zone;wait=45",                                          -- f0 zona quieta (dura 240)
    "3*column;vx=1.4;n=3;duration_frames=110;wait=60",       -- f45 columnas lentas
    15,                                                      -- f225 ajuste hasta f240
    "orbzone;wait=45",                                       -- f240 zona orbitante (dura 360)
    "5*column;vx=1.6;n=3;duration_frames=100;wait=30/rain;wait=30", -- f285 columnas + lluvia
    15,                                                      -- f585 ajuste hasta f600
    120,                                                     -- f600 RESPIRO (checkpoint 1)
    "jumpzone;x=64;y=64;warning_frames=45;duration_frames=75;wait=45/zonering;x=64;y=64;wait=30/rain;wait=45", -- f720 salto centro
    "jumpzone;x=36;y=36;wait=30/zonering;x=36;y=36;wait=30/rain;wait=60", -- f840 salto arriba-izq
    "jumpzone;x=92;y=36;wait=30/zonering;x=92;y=36;wait=30/rain;wait=60", -- f960 salto arriba-der
    "jumpzone;x=92;y=92;wait=30/zonering;x=92;y=92;wait=30/rain;wait=60", -- f1080 salto abajo-der
    "jumpzone;x=36;y=92;wait=30/zonering;x=36;y=92;wait=30/rain;wait=60", -- f1200 salto abajo-izq
    120,                                                     -- f1320 RESPIRO (checkpoint 2)
    "orbzone;orbit_radius=26;x=90;orbit_speed=0.009;size=28;warning_frames=30;duration_frames=330;wait=30", -- f1440 zona chica y rapida (dura 360)
    "2*hline;y=@;wait=30/vline;x=@;wait=30",                 -- f1470 lineas
    "chasers;n=4;stagger=15;chase_speed=1.2;warning_frames=25;duration_frames=130;wait=60", -- f1590 perseguidores
    "2*hline;y=@;wait=30/vline;x=@;wait=30",                 -- f1650 lineas
    "zonering;x=64;y=64;wait=30",                            -- f1770 anillo lento
    "lens;orbit_ang=0;x=76/lens;orbit_ang=0.5;x=52;wait=30", -- f1800 LENTE (dura 360)
    "3*zonering;x=64;y=64;size_max=34;duration_frames=38;wait=45/rain;wait=45", -- f1830 anillos + lluvia
    "chasers;n=3;stagger=15;chase_speed=1.2;warning_frames=25;duration_frames=100;wait=60", -- f2100 perseguidores
    "zone;size=28;warning_frames=30;duration_frames=210/cross;wait=30", -- f2160 FINAL zona chica + cruz (dura 240)
    "2*burst;x=64;y=64;burst_count=12;burst_speed=1.4;burst_angle_offset=?;warning_frames=20;wait=45/column;column_x=140;vx=-2.2;n=4;duration_frames=90;wait=45", -- f2190 bursts + columnas
    30                                                       -- f2370 ajuste hasta f2400
  }                                                          -- f2400 = total
end