-- si tu cancion esta a 120 BPM y corres a 30 FPS:
-- 1 beat = 60/120 * 30 = 15 frames
BEAT_FRAMES = 15

function beats(n)
  return n * BEAT_FRAMES
end

function level_setup(cfg)
  local checkpoints = {}
  for i = 1, 4 do
    local frac = cfg["point" .. i]
    if frac then
      add(checkpoints, { frac = frac, color = cfg["point" .. i .. "_color"] })
    end
  end
  hud_start(cfg.total, checkpoints, cfg.song, cfg.name)
  wait_for_card()
end

function finish_level(x, y)
  wait_for_clear()
  level_final_frames = level_runtime_frames
  spawn_orb(x, y)
  wait_for_orb()
end

function level_1()
  run"level_setup;name=lvl 1;song=waves;total=1552;point1=0.3;point2=0.7"
  run"spw_loop;pattern=column;column_x=140;parallel=true;stagger=5;n=8;enemy_type=E_BULLET;vx=-4.5;size=3;duration_frames=30"
  run"spw_loop;pattern=circle;n=16;radius=60;parallel=true;target_x=64;target_y=64;duration_frames=400;size=3"
  run"spw_loop;pattern=point;n=16;parallel=true;stagger=5;chase=true;chase_speed=2.6;duration_frames=140;size=3"
  run"spw_loop;pattern=row;n=20;random=true;parallel=true;stagger=5;vy=1.8;duration_frames=100;size=3"
  run"spw;vx=1.9;vy=1.9;duration_frames=300;size=3;bounce=true;bounce_speed_mult=1.09;bounce_size_mult=1.1"
  -- o mismo que arriba pero direccion aleatoria
  run"spw_loop;pattern=column;margin=40;n=6;parallel=true;vx=1.8;duration_frames=140;size=3"
  run"spw_loop;pattern=point;x=-4;y=64;enemy_type=E_LINE_BI;n=8;parallel=true;stagger=30;duration_frames=140;len=128;size=5;vx=1.8;ang=0.75"
  run"spw_loop;pattern=perimeter;random=true;radius=50;n=16;parallel=true;stagger=5;chase=true;chase_speed=1.6;duration_frames=140;size=3"
  run("spw_loop;n=8;size=8;near_player=true;near_range=0;delay_move=10;chase=true;chase_speed=1.9;duration_frames=100")
  run"spw_loop;n=8;size=1;size_max=200;fill=false;grow_px=1.8;duration_frames=60;warning_time=10;spawn_interval=15;n=6"
  run"spw;enemy_type=E_CROSS;size=1;x=64;y=64;ang_vel=0.01;size_max=4;ease_grow=out_quad;duration_frames=60;burst=true;burst_count=10/wait_for_clear"
  run"spw_loop;enemy_type=E_BULLET;count=8;size=1;size_max=4;burst=true;burst_count=10;warning_time=30"
  run"emit;x=-1;y=40;target_x=15;target_y=40/wait_frames;n=40/emit;x=129;y=80;target_x=119;target_y=80"
  run("spw_loop;pattern=perimeter;parallel=true;size=15;warning_time=40;n=8;delay_move=20;chase=true;chase_speed=1.6;duration_frames=100")
end

function level_2()
  run"level_setup;name=lvl 2;song=flux;total=2100;point1=0.25;point1_color=C_DARK_PINK;point2=0.52;point2_color=C_LAVENDER;point3=0.78;point3_color=C_DARK_BLUE"

end