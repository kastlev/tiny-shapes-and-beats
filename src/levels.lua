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
            if v=="?" then g[k]=14+rnd(100)
            elseif v=="@" then g[k]=flr(k=="x" and p.x+2 or p.y+2) end
          end
          meanwhile(function() _ENV[f](g) end)
          wait_frames(g.wait or 0)
        end
      end
    end
  end
end

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

LEVEL_META = {
  "name=LVL 1;song=waves;track=0;total=1560;point1=0.27;point2=0.68;map_x=8",
  "name=LVL 2;song=flux;track=8;total=2100;point1=0.23;point2=0.52;point3=0.78;map_x=16",
  "name=LVL 3;song=zona;track=16;total=2400;point1=0.25;point2=0.55;map_x=24"
}

LEVEL_COUNT = #LEVEL_META

T = {
  -- ===== formas basicas =====
  hline   = "spw;type=E_LINE_BI;x=64;ang=0;len=72;size=3;warning_frames=20;duration_frames=18",
  vline   = "spw;type=E_LINE_BI;y=64;ang=0.25;len=72;size=3;warning_frames=20;duration_frames=18",
  cross   = "spw;type=E_CROSS;x=64;y=64;len=72;size=3;ang_vel=0.006;warning_frames=30;duration_frames=210",
  burst   = "spw;type=E_CIRCLE;size=5;warning_frames=25;duration_frames=1;burst=true;burst_count=10;burst_speed=1.4;burst_size=2;burst_duration_frames=110",
  ring    = "spw;size=1;size_max=70;fill=false;grow_px=1.8;warning_frames=20;duration_frames=40",
  column  = "spw_loop;pattern=column;column_x=-4;random=true;parallel=true;type=E_BULLET;size=3;vx=3.4;n=9;duration_frames=45",
  chasers = "spw_loop;pattern=perimeter;parallel=true;chase=true;chase_turn=0.05;size=4;warning_frames=30;duration_frames=130",
  squares = "spw_loop;type=E_SQUARE;parallel=true;near_player=true;near_range=24;size=8;warning_frames=45;duration_frames=25",
  rain    = "spw_loop;pattern=row;random=true;n=3;parallel=true;type=E_BULLET;size=3;vy=1.5;duration_frames=100",
  -- aimed : bala apuntada al jugador. aim = velocidad (< 2.5, tu velocidad maxima).
  aimed   = "spw;type=E_BULLET;size=3;aim=2.2;duration_frames=120",
  -- spiral: n emisores de 1 frame, cada uno con angulo +0.03. Dura n*spawn_interval (80 f).
  spiral  = "spw_loop;pattern=point;x=64;y=64;n=16;type=E_CIRCLE;size=3;color=13;warning=false;duration_frames=1;burst=true;burst_count=3;burst_speed=1.3;burst_size=2;burst_duration_frames=110;spawn_interval=5;stagger_burst_angle_offset=0.03;burst_quiet=true",
  -- emitter: entra desde un borde (x,y -> target_x,target_y), se queda 20 f y suelta un anillo.
  --          ease_move=out_quad ya es lineal (tu _ease). Para sensacion "out" usa ease_move=lerp;lerp_factor=.15
  emitter = "spw;type=E_CIRCLE;size=4;warning=false;ease_move=out_quad;duration_frames=30;hold_frames=20;flicker=true;burst=true",

  -- ===== ZONAS (E_HOLE: lo de FUERA del circulo es letal) =====
  -- zone    : zona quieta. size = radio seguro. Dura warning_frames + duration_frames.
  zone     = "spw;type=E_HOLE;x=64;y=64;size=36;warning_frames=45;duration_frames=195",
  -- orbzone : zona que orbita. orbit_radius = tamano de la orbita, orbit_speed = vueltas/frame
  --           (0.006 ~ 0.8 px/frame, 0.009 ~ 1.5 px/frame). x = punto de partida.
  orbzone  = "spw;type=E_HOLE;orbit=true;orbit_cx=64;orbit_cy=64;orbit_ang=0;orbit_radius=22;orbit_speed=0.006;x=86;y=64;size=34;warning_frames=45;duration_frames=315",
  -- lens    : mitad de un "lente". Se lanzan DOS con orbit_ang distinto; solo la interseccion es segura.
  lens     = "spw;type=E_HOLE;orbit=true;orbit_cx=64;orbit_cy=64;orbit_radius=12;orbit_speed=0.006;y=64;size=36;warning_frames=30;duration_frames=330",
  -- jumpzone: zona de salto. Nace en x,y, vive duration_frames y desaparece.
  jumpzone = "spw;type=E_HOLE;size=28;warning_frames=30;duration_frames=90",
  -- zonering: anillo para usar DENTRO de una zona.
  --   size_max        = radio del hoyo + 2 (mas grande no sirve: afuera ya es letal)
  --   grow_px         = velocidad, la perilla principal de dificultad
  --   duration_frames = ceil(size_max / grow_px) + 1 (si es menor, muere a medio crecer)
  --   warning_frames  = frames para reaccionar (el warning es solo un punto en el centro)
  --   Tabla (size_max=30): grow_px 0.7 -> 43 (facil) | 0.9 -> 34 (normal) | 1.2 -> 26 (dificil)
  zonering = "spw;size=1;size_max=30;fill=false;grow_px=0.9;warning_frames=30;duration_frames=34"
}

function level_1()
  level_setup(1)
  play {
    -- m1-2 lluvia lenta
    "spw_loop;pattern=row;random=true;n=8;parallel=true;stagger=15;type=E_BULLET;vy=0.9;size=2;duration_frames=220;wait=120",
    -- m3-5 cuadrados cerca del jugador
    "squares;n=8;stagger=15;wait=120",
    "squares;n=2;stagger=30/squares;n=2;stagger=30;wait=60",
    -- m6-7 anillos lentos
    "spw_loop;pattern=point;x=64;y=64;n=2;parallel=true;stagger=30;size=1;size_max=92;fill=false;grow_px=1.4;warning_frames=30;duration_frames=70;wait=120",
    120, -- m8-9 respiro + checkpoint 1
    -- m10-14 perseguidores
    "chasers;n=4;stagger=30;chase_speed=0.9;wait=120",
    "chasers;n=8;stagger=15;chase_speed=1.0;wait=120",
    "chasers;n=12;stagger=5;chase_speed=1.1;wait=60",
    -- m15-18 columnas desde la derecha
    "4*column;column_x=140;n=5;vx=-2.2;duration_frames=80;wait=30",
    "4*column;column_x=140;n=7;vx=-2.6;duration_frames=80;wait=30",
    60, -- m19 respiro + checkpoint 2
    -- m20-24 bola que rebota + anillos
    "spw;x=20;y=20;vx=1.9;vy=1.5;size=3;warning_frames=30;duration_frames=270;bounce=true;bounce_speed_mult=1.05;bounce_size_mult=1.06",
    "2*ring;grow_px=1.5;warning_frames=30;duration_frames=50;wait=60",
    "6*ring;grow_px=1.5;warning_frames=30;duration_frames=50;wait=30",
    -- m25-26 final
    "burst;x=64;y=64;warning_frames=30;burst_count=12;burst_speed=1.3;wait=30",
    "burst;x=64;y=64;warning_frames=30;burst_count=12;burst_speed=1.3;burst_angle_offset=0.04;wait=30",
    "spw_loop;pattern=point;x=64;y=64;n=3;parallel=true;stagger=5;size=1;size_max=100;fill=false;grow_px=1.6;warning_frames=30;duration_frames=65;wait=60"
  }
end

function level_2()
  level_setup(2)
  play {
    -- m1-4 lineas apuntadas al jugador
    "2*hline;y=@;warning_frames=25;wait=30/vline;x=@;warning_frames=25;wait=30",
    "4*hline;y=@;wait=15/vline;x=@;wait=15",
    -- m5-8 cruces
    "4*hline;y=@/vline;x=@;wait=30",
    "2*hline;y=@/vline;x=@/vline;x=?;size=4;wait=30",
    "2*hline;y=@/vline;x=@/hline;y=?;size=4;wait=30",
    120, -- m9-10 respiro + checkpoint 1
    -- m11-15 cruz giratoria + anillos de balas
    "cross;wait=30",
    "7*burst;burst_angle_offset=?;warning_frames=20;wait=30",
    "hline;y=@;wait=30/vline;x=@;wait=30",
    -- m16-18 columnas rapidas + lineas
    "3*column;wait=15/hline;y=@;warning_frames=18;wait=15/column;column_x=140;vx=-3.4;wait=15/vline;x=@;warning_frames=18;wait=15",
    120, -- m19-20 respiro + checkpoint 2
    -- m21-27 lineas + perseguidores + bola
    "spw;x=20;y=20;vx=2.2;vy=1.7;size=4;warning_frames=25;duration_frames=300;bounce=true;bounce_speed_mult=1.04;bounce_size_mult=1.04",
    "chasers;n=8;stagger=7;chase_speed=1.5;warning_frames=25;duration_frames=150",
    "2*hline;y=@;wait=30/vline;x=@;wait=30",
    "2*ring/vline;x=?;size=4;wait=30/ring/hline;y=?;size=4;wait=30",
    "chasers;n=6;stagger=7;chase_speed=1.6;warning_frames=25;duration_frames=120",
    "6*hline;y=@;warning_frames=18;wait=15/vline;x=@;warning_frames=18;wait=15",
    120, -- m28-29 respiro + checkpoint 3
    -- m30-35 final
    "cross;ang_vel=0.007;wait=30",
    "4*burst;burst_count=12;burst_speed=1.5;burst_angle_offset=?;warning_frames=20;wait=30",
    "column;wait=15/vline;x=@;warning_frames=15;wait=15/column;column_x=140;vx=-3.4;wait=15/hline;y=@;warning_frames=15;wait=15/column;wait=15/vline;x=@;warning_frames=15;wait=15",
    -- ultimos 4 pares de beats: entra todo junto
    "hline;y=@;warning_frames=15/vline;x=@;warning_frames=15/ring;wait=30",
    "column/hline;y=@;warning_frames=15;wait=30",
    "burst;burst_count=12;burst_speed=1.5;burst_angle_offset=?/hline;y=@;warning_frames=15/vline;x=@;warning_frames=15;wait=30",
    "column;column_x=140;vx=-3.4/hline;y=@;warning_frames=15/vline;x=@;warning_frames=15/ring/burst;burst_count=12;burst_speed=1.5;burst_angle_offset=?;wait=30"
  }
end

-- =====================================================================
-- NIVEL 3 "zona"  -  120 BPM  -  1 beat = 15 f  -  1 compas = 60 f
-- Total: 2400 f (40 compases)
--
-- Formato de cada linea de play{}:
--   numero          -> espera ese numero de frames
--   "N*plantilla"   -> repite la linea N veces
--   "a/b/c"         -> lanza a, b y c a la vez
--   ";wait=30"      -> despues de lanzar ESE patron, espera 30 f
--   "x=@ / y=@"     -> posicion actual del jugador
--   "?"             -> valor aleatorio
--
-- REGLA DE LAS ZONAS: la suma de los wait= de cada tramo debe ser igual a
-- warning_frames + duration_frames de su hoyo. Asi nace el siguiente justo
-- cuando muere el anterior y los tiempos caen en beat.
-- =====================================================================
function level_3()
  level_setup(3)
  play {
    -- ---- m1-4 (240 f) zona quieta: solo aprendes que afuera duele ----
    -- zone: 45 de warning + 195 de vida = 240 f
    "zone;wait=45",
    "3*column;vx=1.4;n=3;duration_frames=110;wait=60",   -- 3 volleys lentos, uno por compas (180 f)
    15,                                                   -- ajuste para llegar a 240

    -- ---- m5-10 (360 f) la zona orbita (~0.8 px/frame): hay que seguirla ----
    -- orbzone: 45 de warning + 315 de vida = 360 f
    "orbzone;wait=45",
    "5*column;vx=1.6;n=3;duration_frames=100;wait=30/rain;wait=30",  -- 5 x (columna + lluvia) = 300 f
    15,

    120, -- m11-12 RESPIRO + checkpoint 1 (el marcador tarda ~46-80 f en llegar)

    -- ---- m13-22 (600 f) SALTOS: la zona cambia de lugar cada 2 compases ----
    -- Cada salto (120 f):
    --   jumpzone -> nace la zona (el warning pinta todo oscuro menos el circulo nuevo)
    --   zonering -> sale del centro y obliga a hacer dash
    --   rain     -> balas desde arriba para que no te quedes quieto
    -- 1er salto: warning 45 + vida 75 = 120 f (centro)
    "jumpzone;x=64;y=64;warning_frames=45;duration_frames=75;wait=45/zonering;x=64;y=64;wait=30/rain;wait=45",
    -- 2do a 5to salto: warning 30 + vida 90 = 120 f cada uno (las 4 esquinas)
    "jumpzone;x=36;y=36;wait=30/zonering;x=36;y=36;wait=30/rain;wait=60",
    "jumpzone;x=92;y=36;wait=30/zonering;x=92;y=36;wait=30/rain;wait=60",
    "jumpzone;x=92;y=92;wait=30/zonering;x=92;y=92;wait=30/rain;wait=60",
    "jumpzone;x=36;y=92;wait=30/zonering;x=36;y=92;wait=30/rain;wait=60",

    120, -- m23-24 RESPIRO + checkpoint 2

    -- ---- m25-30 (360 f) zona chica y rapida + lineas + perseguidores ----
    -- orbzone chica: 30 de warning + 330 de vida = 360 f. orbit_speed 0.009 ~ 1.5 px/frame
    "orbzone;orbit_radius=26;x=90;orbit_speed=0.009;size=28;warning_frames=30;duration_frames=330;wait=30",
    "2*hline;y=@;wait=30/vline;x=@;wait=30",              -- lineas apuntadas (120 f)
    "chasers;n=4;stagger=15;chase_speed=1.2;warning_frames=25;duration_frames=130;wait=60",
    "2*hline;y=@;wait=30/vline;x=@;wait=30",              -- (120 f)
    "zonering;x=64;y=64;wait=30",                         -- anillo lento desde el centro (30 f)

    -- ---- m31-36 (360 f) EL LENTE: dos hoyos opuestos, solo la interseccion es segura ----
    -- lens: 30 de warning + 330 de vida = 360 f
    -- orbit_ang 0 y 0.5 = lados opuestos. Subir orbit_radius achica el lente, bajarlo lo agranda.
    "lens;orbit_ang=0;x=76/lens;orbit_ang=0.5;x=52;wait=30",
    "3*zonering;x=64;y=64;size_max=34;duration_frames=38;wait=45/rain;wait=45",   -- 270 f
    "chasers;n=3;stagger=15;chase_speed=1.2;warning_frames=25;duration_frames=100;wait=60",

    -- ---- m37-40 (240 f) FINAL: zona chica quieta con todo dentro ----
    -- zone: 30 de warning + 210 de vida = 240 f
    "zone;size=28;warning_frames=30;duration_frames=210/cross;wait=30",
    "2*burst;x=64;y=64;burst_count=12;burst_speed=1.4;burst_angle_offset=?;warning_frames=20;wait=45/column;column_x=140;vx=-2.2;n=4;duration_frames=90;wait=45",
    30
  }
end