LEVEL_META = {
  "name=LVL 1;song=waves;track=0;total=1560;point1=0.27;point2=0.68;map_x=8",
  "name=LVL 2;song=flux;track=8;total=2100;point1=0.23;point2=0.52;point3=0.78;map_x=16",
  "name=LVL 3;song=zona;track=16;total=2400;point1=0.25;point2=0.55;map_x=24",
  "name=LVL 4;song=test;track=0;total=4350;point1=0.423;point2=0.811;map_x=32"
}
LEVEL_COUNT = #LEVEL_META

T = {
  hline    = "spw;type=E_LINE_BI;x=64;size=3;len=72;ang=0;warn_frames=20;frames=18",
  vline    = "spw;type=E_LINE_BI;y=64;size=3;len=72;ang=0.25;warn_frames=20;frames=18",
  cross    = "spw;type=E_CROSS;x=64;y=64;size=3;len=72;spin=0.006;warn_frames=30;frames=210",
  ring     = "spw;size=1;size_max=70;grow_px=1.8;fill=false;warn_frames=20;frames=40",
  burst    = "spw;type=E_SQUARE;size=5;warn_frames=25;frames=1;burst=true;burst_count=10;burst_speed=1.4;burst_size=2;burst_frames=110",
  column   = "spw_loop;type=E_BULLET;pattern=column;parallel=true;n=9;column_x=-4;pos_random=true;vx=3.4;size=3;frames=45",
  rain     = "spw_loop;type=E_BULLET;pattern=row;parallel=true;n=3;pos_random=true;vy=1.5;size=3;frames=100",
  aimed    = "spw;type=E_BULLET;aim_speed=2.2;size=3;frames=120",
  spiral   = "spw_loop;type=E_CIRCLE;pattern=point;n=16;spawn_interval=5;stagger_burst_ang=0.03;x=64;y=64;size=3;color=13;warn=false;frames=1;burst=true;burst_count=3;burst_speed=1.3;burst_size=2;burst_frames=110;burst_quiet=true",
  emitter  = "spw;type=E_CIRCLE;move_ease=out_quad;size=4;flicker=true;warn=false;frames=30;hold_frames=20;burst=true",
  chasers  = "spw_loop;pattern=perimeter;parallel=true;chase=true;chase_turn=0.05;size=4;warn_frames=30;frames=130",
  squares  = "spw_loop;type=E_SQUARE;parallel=true;near_player=true;near_range=24;size=8;warn_frames=45;frames=25",
  zone     = "spw;type=E_HOLE;x=64;y=64;size=36;warn_frames=45;frames=195",
  orbzone  = "spw;type=E_HOLE;x=64;y=64;orbit=true;ang_offset=0;orbit_radius=22;orbit_spin=0.006;size=34;warn_frames=45;frames=315",
  lens     = "spw;type=E_HOLE;x=64;y=64;orbit=true;orbit_radius=12;orbit_spin=0.006;size=36;warn_frames=30;frames=330",
  jumpzone = "spw;type=E_HOLE;size=28;warn_frames=30;frames=90",
  zonering = "spw;size=1;size_max=30;grow_px=0.9;fill=false;warn_frames=30;frames=34",
  sweep    = "spw;type=E_LINE_BI;x=2;y=64;vx=1.8;size=3;len=72;ang=0.25;warn_frames=25;frames=80", -- linea vertical que barre de izq a der (al reves: x=126;vx=-1.8)
  wiper    = "spw;type=E_LINE_BI;x=64;y=0;size=2;len=144;ang=0;spin=0.004;warn_frames=30;frames=125", -- limpiaparabrisas: media vuelta desde el borde superior (125 f = 0.5/spin)
  gun      = "spw_loop;type=E_BULLET;pattern=point;parallel=true;n=30;stagger=2;x=-4;y=64;dir_random=true;speed_random=true;speed_min=1.5;speed_max=3;size=2;frames=120",
  core     = "spw;type=E_CIRCLE;x=64;y=64;size=7;color=13;warn_frames=30;frames=125", -- nucleo inofensivo (color 13) en el centro; se lanza con fountain
  fountain = "spw_loop;type=E_BULLET;pattern=point;parallel=true;n=40;stagger=3;x=64;y=64;dir_random=true;speed_random=true;speed_min=0.8;speed_max=2;size=2;frames=150",
  ripple   = "spw_loop;type=E_BULLET;pattern=column;parallel=true;n=6;column_x=-4;pos_random=false;vx=1.4;wave=true;wave_amp=12;wave_freq=0.03;size=3;frames=130", -- muro de balas que ondula
  pop      = "spw;count=12;speed=1.5;size=3;warn=true;warn_frames=20;frames=100", -- anillo de balas sin emisor: solo aviso y ¡pum!
  worm     = "spw_loop;type=E_CIRCLE;pattern=point;parallel=true;n=10;stagger=4;x=-5;y=64;vx=1.5;wave=true;wave_amp=10;wave_freq=0.02;size=3;warn=false;frames=200", -- gusano: cada circulo repite el recorrido ondulado con retraso
  mine     = "spw;type=E_CIRCLE;near_player=true;near_range=18;size=9;warn_frames=30;frames=45", -- circulo estatico junto al jugador
  block    = "spw;type=E_SQUARE;size=9;warn_frames=30;frames=45", -- cuadrado estatico en sitio aleatorio
  stalker  = "spw;type=E_SQUARE;chase=true;speed=1.3;chase_turn=0.04;size=5;warn_frames=30;frames=150", -- un cuadrado perseguidor
  strobe   = "spw;type=E_SQUARE;size=14;flicker=true;flicker_frames=8;warn_frames=30;frames=120", -- parpadea rosa/blanco: solo hiere en los frames rosa
  bomb     = "spw;type=E_CIRCLE;size=2;size_max=16;grow_lerp=0.12;warn_frames=30;frames=60;burst=true;burst_count=12;burst_speed=1.4;burst_size=2;burst_frames=100", -- crece desde un punto y explota en balas
  orbiter  = "spw;type=E_SQUARE;x=64;y=64;orbit=true;ang_offset=.875;orbit_radius=40;orbit_spin=0.03;size=5;warn_frames=10;frames=150", -- satelite que gira alrededor del centro (~2 px/f)
  bouncer  = "spw;x=20;y=20;vx=1.9;vy=1.5;bounce=true;bounce_speed_mult=1.05;bounce_size_mult=1.06;size=3;warn_frames=30;frames=180", -- rebota, se acelera y crece
  wrapper  = "spw;type=E_CIRCLE;vx=2;vy=0.9;wrap=true;size=4;warn_frames=30;frames=150", -- sale por un borde y entra por el opuesto
  orbring  = "spw_loop;type=E_BULLET;pattern=circle;parallel=true;n=12;orbit=true;orbit_cx=64;orbit_cy=64;orbit_radius=80;orbit_grow=-2;orbit_spin=0.006;size=2;warn=true;warn_frames=30;frames=240",
  belt     = "spw_loop;type=E_BULLET;pattern=row;parallel=true;n=9;row_y=40;vx=1;wrap=true;size=2;warn=true;warn_frames=30;frames=300",
  gapring  = "spw_loop;type=E_BULLET;pattern=circle;parallel=true;n=24;pos_keep=1;pos_skip=2;orbit=true;orbit_cx=64;orbit_cy=64;orbit_radius=70;orbit_grow=-1.2;orbit_spin=0.008;size=2;warn=true;warn_frames=30;frames=200", -- 8 balas orbitando con huecos, ya sin pos_radius duplicado
  gapwall  = "spw_loop;type=E_BULLET;pattern=column;parallel=true;n=12;pos_keep=3;pos_skip=2;column_x=-4;vx=2;size=3;frames=100", -- muro con agujeros por donde pasar
  gapfan   = "spw_loop;type=E_BULLET;pattern=point;parallel=true;n=16;pos_keep=2;pos_skip=2;stagger_dir=0.0625;x=64;y=64;dir=0;speed=1.5;size=2;frames=120", -- abanico en pares (reemplaza a explode)
  seeker   = "spw_loop;type=E_BULLET;pattern=row;parallel=true;n=20;stagger=3;row_y=-4;pos_random=true;vy=4.7;pull=-0.09;size=4;frames=170", -- lluvia rapida que se desvia del jugador (pull negativo repele)
  repeller = "spw;type=E_CIRCLE;near_player=true;near_range=14;pull=-0.1;size=5;warn_frames=30;frames=90", -- nace junto a ti y se aleja acelerando (pull negativo)
  stopchasers = "spw_loop;pattern=perimeter;parallel=true;n=6;chase=true;chase_turn=0.08;speed=1.6;stop_every=40;stop_for=20;stop_ease=14;start_ease=6;size=4;warn_frames=30;frames=240",
  stopbouncer = "spw;x=20;y=20;vx=2.4;vy=1.9;bounce=true;bounce_speed_mult=1.03;stop_every=50;stop_for=20;stop_ease=16;start_ease=1;size=3;warn_frames=30;frames=240",
  stopwall    = "spw_loop;type=E_BULLET;pattern=column;parallel=true;n=6;column_x=-4;vx=1.6;wave=true;wave_amp=12;wave_freq=0.03;stop_every=30;stop_for=15;stop_ease=14;start_ease=6;size=3;frames=170", -- muro ondulante que se congela (la onda se pausa con el mt)
  stoporb     = "spw_loop;type=E_SQUARE;pattern=circle;parallel=true;n=6;orbit=true;orbit_cx=64;orbit_cy=64;orbit_radius=45;orbit_spin=0.012;stop_every=30;stop_for=20;stop_ease=14;start_ease=6;size=4;warn_frames=30;frames=240", -- cuadrados orbitando a saltos
  twinsat  = "spw_loop;type=E_LINE_BI;pattern=circle;parallel=true;n=2;orbit=true;orbit_cx=64;orbit_cy=64;orbit_radius=34;orbit_spin=0.008;size=2;len=26;spin=0.02;warn_frames=30;frames=240", -- 2 lineas: orbitan lento y giran rapido sobre su eje
  spinline = "spw;type=E_LINE_BI;x=64;y=64;size=3;len=72;ang=?;spin=0.01;warn_frames=30;frames=100", -- angulo aleatorio (el aviso coincide con el vivo)
  chaseburst  = "spw;type=E_CIRCLE;size=5;warn_frames=30;frames=60;burst=true;burst_type=E_CIRCLE;burst_count=6;burst_speed=1.2;burst_size=3;burst_frames=140;burst_chase=true;burst_chase_turn=0.05", -- explota en perseguidores
  squareburst = "spw;type=E_CROSS;size=5;warn_frames=25;frames=1;burst=true;burst_type=E_SQUARE;burst_count=8;burst_speed=1.6;burst_size=3;burst_frames=100", -- explota en cuadrados
  homingburst = "spw;type=E_CROSS;size=5;warn_frames=25;frames=1;burst=true;burst_count=8;burst_speed=1.2;burst_size=2;burst_frames=140;burst_pull=0.03", -- balas que tras explotar curvan hacia ti
  squarepop   = "spw;type=E_SQUARE;count=10;speed=1.4;size=3;warn=true;warn_frames=20;frames=100", -- pop con cuadrados (antes solo balas)
  ringwarn    = "spw;size=1;size_max=70;grow_px=1.8;warn_frames=30;warn_size=70;frames=40" -- anillo con aviso del radio completo

}

function level_1()
  level_setup(1)
  play {
    "spw_loop;wait=120;type=E_BULLET;pattern=row;parallel=true;n=8;stagger=15;pos_random=true;vy=0.9;size=2;frames=220",
    "squares;wait=120;n=8;stagger=15",
    "squares;n=2;stagger=30/squares;wait=60;n=2;stagger=30",
    "spw_loop;wait=120;pattern=point;parallel=true;n=2;stagger=30;x=64;y=64;size=1;size_max=92;grow_px=1.4;fill=false;warn_frames=30;frames=70",
    120,                                                     -- checkpoint 1
    "chasers;wait=120;n=4;stagger=30;speed=0.9",
    "chasers;wait=120;n=8;stagger=15;speed=1.0",
    "chasers;wait=60;n=12;stagger=5;speed=1.1",
    "4*column;wait=30;n=5;column_x=140;vx=-2.2;frames=80",
    "4*column;wait=30;n=7;column_x=140;vx=-2.6;frames=80",
    60,                                                      -- checkpoint 2
    "spw;x=20;y=20;vx=1.9;vy=1.5;bounce=true;bounce_speed_mult=1.05;bounce_size_mult=1.06;size=3;warn_frames=30;frames=270",
    "2*ring;wait=60;grow_px=1.5;warn_frames=30;frames=50",
    "6*ring;wait=30;grow_px=1.5;warn_frames=30;frames=50",
    "burst;wait=30;x=64;y=64;warn_frames=30;burst_count=12;burst_speed=1.3",
    "burst;wait=30;x=64;y=64;warn_frames=30;burst_count=12;burst_speed=1.3;burst_ang=0.04",
    "spw_loop;wait=60;pattern=point;parallel=true;n=3;stagger=5;x=64;y=64;size=1;size_max=100;grow_px=1.6;fill=false;warn_frames=30;frames=65"
  }
end
function level_2()
  level_setup(2)
  play {
    "2*hline;wait=30;y=@;warn_frames=25/vline;wait=30;x=@;warn_frames=25",
    "4*hline;wait=15;y=@/vline;wait=15;x=@",
    "4*hline;y=@/vline;wait=30;x=@",
    "2*hline;y=@/vline;x=@/vline;wait=30;x=?;size=4",
    "2*hline;y=@/vline;x=@/hline;wait=30;y=?;size=4",
    120,
    "cross;wait=30",
    "7*burst;wait=30;warn_frames=20;burst_ang=?",
    "hline;wait=30;y=@/vline;wait=30;x=@",
    "3*column;wait=15/hline;wait=15;y=@;warn_frames=18/column;wait=15;column_x=140;vx=-3.4/vline;wait=15;x=@;warn_frames=18",
    120,
    "spw;x=20;y=20;vx=2.2;vy=1.7;bounce=true;bounce_speed_mult=1.04;bounce_size_mult=1.04;size=4;warn_frames=25;frames=300",
    "chasers;n=8;stagger=7;speed=1.5;warn_frames=25;frames=150",
    "2*hline;wait=30;y=@/vline;wait=30;x=@",
    "2*ring/vline;wait=30;x=?;size=4/ring/hline;wait=30;y=?;size=4",
    "chasers;n=6;stagger=7;speed=1.6;warn_frames=25;frames=120",
    "6*hline;wait=15;y=@;warn_frames=18/vline;wait=15;x=@;warn_frames=18",
    120,
    "cross;wait=30;spin=0.007",
    "4*burst;wait=30;warn_frames=20;burst_count=12;burst_speed=1.5;burst_ang=?",
    "column;wait=15/vline;wait=15;x=@;warn_frames=15/column;wait=15;column_x=140;vx=-3.4/hline;wait=15;y=@;warn_frames=15/column;wait=15/vline;wait=15;x=@;warn_frames=15",
    "hline;y=@;warn_frames=15/vline;x=@;warn_frames=15/ring;wait=30",
    "column/hline;wait=30;y=@;warn_frames=15",
    "burst;burst_count=12;burst_speed=1.5;burst_ang=?/hline;y=@;warn_frames=15/vline;wait=30;x=@;warn_frames=15",
    "column;column_x=140;vx=-3.4/hline;y=@;warn_frames=15/vline;x=@;warn_frames=15/ring/burst;wait=30;burst_count=12;burst_speed=1.5;burst_ang=?"
  }
end
function level_3()
  level_setup(3)
  play {
    "zone;wait=45",
    "3*column;wait=60;n=3;vx=1.4;frames=110",
    15,                                                     
    "orbzone;wait=45",
    "5*column;wait=30;n=3;vx=1.6;frames=100/rain;wait=30",
    15,                                                    
    120,
    "jumpzone;wait=45;x=64;y=64;warn_frames=45;frames=75/zonering;wait=30;x=64;y=64/rain;wait=45",
    "jumpzone;wait=30;x=36;y=36/zonering;wait=30;x=36;y=36/rain;wait=60",
    "jumpzone;wait=30;x=92;y=36/zonering;wait=30;x=92;y=36/rain;wait=60",
    "jumpzone;wait=30;x=92;y=92/zonering;wait=30;x=92;y=92/rain;wait=60",
    "jumpzone;wait=30;x=36;y=92/zonering;wait=30;x=36;y=92/rain;wait=60",
    120,
    "orbzone;wait=30;orbit_radius=26;orbit_spin=0.009;size=28;warn_frames=30;frames=330",
    "2*hline;wait=30;y=@/vline;wait=30;x=@",
    "chasers;wait=60;n=4;stagger=15;speed=1.2;warn_frames=25;frames=130",
    "2*hline;wait=30;y=@/vline;wait=30;x=@",
    "zonering;wait=30;x=64;y=64",
    "lens;ang_offset=0/lens;wait=30;ang_offset=0.5",
    "3*zonering;wait=45;x=64;y=64;size_max=34;frames=38/rain;wait=45",
    "chasers;wait=60;n=3;stagger=15;speed=1.2;warn_frames=25;frames=100",
    "zone;size=28;warn_frames=30;frames=210/cross;wait=30",
    "2*burst;wait=45;x=64;y=64;warn_frames=20;burst_count=12;burst_speed=1.4;burst_ang=?/column;wait=45;n=4;column_x=140;vx=-2.2;frames=90",
    30                                                       
  }
end

function level_4()
  level_setup(4)
  play {
    "gapring;wait=190",
    "gapwall;wait=100",
    "gapfan;wait=150",
    60,
    "seeker;wait=150",
    "repeller;wait=120",
    60,
    "stopchasers;wait=240",
    "stopbouncer;wait=270",
    "stopwall;wait=190",
    "stoporb;wait=270",
    60,
    "twinsat;wait=270",
    "spinline;wait=130",
    "chaseburst;wait=230",
    "squareburst;wait=170",
    "homingburst;wait=190",
    "squarepop;wait=140",
    "ringwarn;wait=100",
    "spw_loop;type=E_BULLET;pattern=circle;parallel=true;n=24;stagger=4;stagger_ang_offset=0.0417;x=64;y=64;orbit=true;orbit_radius=0;orbit_grow=1;size=2;frames=150",
    "chasers;wait=170;n=4;stagger_dir=0.25;pos_radius=4;dir=0;speed=1.5",
    "7*burst;wait=30;warn_frames=20;burst_ang=2",
    "orbiter;wait=185",
    "orbring;wait=270;n=10",
    "belt;row_y=36/belt;row_y=64;vx=-1/belt;wait=330;row_y=92",
    "hline;wait=45;y=@",
    "vline;wait=45;x=@",
    "cross;wait=150;frames=120",
    "ring;wait=75;x=64;y=64",
    "mine;wait=80",
    "block;wait=80",
    "stalker;wait=185",
    "squares;wait=120;n=4;stagger=15",
    "chasers;wait=170;n=4;pos_radius=64",
    "bouncer;wait=210",
    "wrapper;wait=185",
    "strobe;wait=160",
    "orbiter;wait=185",
    "bomb;wait=150",
    120,
    "column;wait=60",
    "rain;wait=100;n=6",
    "ripple;wait=130",
    "5*aimed;wait=32;x=3;y=@;warn=true;warn_frames=15",
    "burst;wait=110;x=64;y=64",
    "pop;wait=120;x=?;y=?",
    "gun;wait=120;y=?",
    "core;wait=30/fountain;wait=170",
    "spiral;wait=190",
    "emitter;wait=110;x=-1;y=40;target_x=15;target_y=40",
    "sweep;wait=110",
    "wiper;wait=160",
    120,

    "zone;wait=145;frames=100",
    "orbzone;wait=195;frames=150",
    "lens;ang_offset=0;frames=150/lens;wait=180;ang_offset=0.5;frames=150",
    "jumpzone;wait=30;x=40;y=40/zonering;wait=90;x=40;y=40",
    60                                                       
  }
end