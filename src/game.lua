hitstop_timer=0
current_level=level_1

function init_game()
  simulating,enemies=false,{}
  init_player()
  run_level(current_level)
  set_screen(update_game,draw_game)
end

function update_game()
  if hitstop_timer>0 then
    hitstop_timer-=1
    return
  end

  update_player()
  update_particles()
  screen_flash_timer=max(0,screen_flash_timer-1)
  update_enemies()
  update_active_patterns()
  update_hud()
  level_runtime_frames+=1

  if p.is_dead and not death_sequence_started then
    death_sequence_started=true
    delay(45,function()
      sfx(10)
      start_fadeout(30,function()
        _do_respawn()
        sfx(9)
        death_sequence_started=false
      end)
    end)
  end
end

function draw_game()
  draw_screen_fx()
  draw_camera()
  cls(bg_color)
  spawn_bg_particles()
  draw_particles "back"
  draw_enemies(true)
  if p.is_dead or p.is_invulnerable or not player_in_danger then
    draw_enemies()
    draw_player()
  else
    draw_player()
    draw_enemies()
  end
  draw_particles "front"
  camera()
  draw_hud()
end

function _step()
  for co in all(active_patterns) do
    if costatus(co)!="dead" then coresume(co) end
  end
end

function _do_respawn()
  camera()
  enemies={}
  init_player()
  local target=last_respawn_frame
  run_level(current_level)
  _step()

  level_started=true
  level_card_state,level_card_position_x="done",200

  simulating=true
  for i=2,target do
    _step()
    update_enemies()
  end
  simulating=false

  callfromstring "init_particle/init_camera/init_screen_flash"

  local saved=level_total_frames>0 and target/level_total_frames or 0
  level_progress_frame,last_respawn_frame=target,target
  bg_color_base=BG_COLOR_DEFAULT
  for ck in all(checkpoints) do
    ck.hit=ck.frac<=saved
    if ck.hit and ck.color then bg_color_base=ck.color end
  end

  reveal_t=0
  p.hit_iframes_timer=60
  hitstop_timer=10
end