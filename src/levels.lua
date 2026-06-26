function level_setup(cfg)
  hud_start(cfg.total_frames, cfg.checkpoints, cfg.song, cfg.name)
end

function level_1()
  level_setup {
    name = "level 1", song = "waves",
    total_frames = 1142, checkpoints = { 0.4, 0.72 }
  }
  wait_for_card()

  spawn(E_CIRCLE, 64, 32, { size=12 })
  wait_frames(25)

  spawn(E_CIRCLE, 32, 64, { size=10 })
  wait_frames(20)

  spawn(E_CIRCLE, 96, 64, { size=10 })
  wait_frames(30)

  spawn(E_BULLET, 64, 64, { count=6, speed=1.3 })
  wait_frames(15)

  spawn(E_CIRCLE, 64, 48, { size=14 })
  wait_frames(15)

  spawn(E_BULLET, 64, 64, { count=8, speed=1.5 })
  wait_frames(20)

  meanwhile(function()
    spawn(E_CIRCLE, 30, 60, { size=10, duration_frames=40, warning=false })
    wait_frames(20)
    spawn(E_CIRCLE, 30, 80, { size=10, duration_frames=40, warning=false })
  end)

  wait_frames(10)
  spawn(E_CIRCLE, 90, 60, { size=10, duration_frames=40, warning=false })
  wait_frames(20)
  spawn(E_CIRCLE, 90, 80, { size=10, duration_frames=40, warning=false })
  wait_frames(20)

  for i = 1, 3 do
    spawn(E_CIRCLE, 64, 64, { size=20+i*5, fill=false, duration_frames=50, warning=false })
    wait_frames(30)
  end
  wait_frames(20)

  sync(
    function() spawn(E_CIRCLE, 40, 40, { size=12 }) end,
    function() spawn(E_CIRCLE, 88, 88, { size=12 }) end
  )
  wait_frames(20)

  spawn(E_BULLET, 64, 64, { count=10, speed=1.8 })
  wait_for_clear()

  spawn(E_BULLET, 64, 64, { count=12, speed=2.1 })
  wait_frames(10)

  spawn(E_CIRCLE, 64, 64, { size=16 })
  wait_for_clear()

  spawn(E_LINE_BI, 64, 64, { ang=0.25, ang_vel=0.01, duration_frames=90, len=90, size=2 })

  wait_for_clear()
  level_final_frames = level_runtime_frames
  spawn_orb(64, 52)
  wait_for_orb()
end

function level_2()
  level_setup {
    name = "level 2", song = "flux",
    total_frames = 2100, checkpoints = { 0.25, 0.52, 0.78 }
  }
  wait_for_card()

  meanwhile(function() ring_expand(3) end)
  four_corners(14)
  wait_for_clear()
  wait_frames(25)

  meanwhile(function() ring_expand(4) end)
  sweep_h(1)
  wait_frames(15)
  sweep_h(-1)
  wait_for_clear()
  wait_frames(15)

  meanwhile(function() sweep_v(1, C_DARK_PINK) end)
  sync(
    function() spawn(E_CIRCLE, 18,  18,  { size=12 }) end,
    function() spawn(E_CIRCLE, 109, 109, { size=12 }) end
  )
  wait_for_clear()
  wait_frames(20)

  spawn(E_CROSS, 64, 64, { ang=0, ang_vel=0, duration_frames=65, len=90, size=2 })
  wait_frames(15)

  sync(
    function()
      spawn(E_LINE_BI, 64, 64, { ang=0.125, ang_vel=0, duration_frames=75, len=100, size=2 })
    end,
    function()
      wait_frames(15)
      spawn(E_BULLET, 10,  64, { count=6, speed=1.5 })
    end,
    function()
      wait_frames(15)
      spawn(E_BULLET, 118, 64, { count=6, speed=1.5 })
    end
  )
  wait_for_clear()
  wait_frames(20)

  burst_triangle(1.5)
  wait_frames(20)

  meanwhile(function() burst_triangle(1.8) end)
  wait_frames(14)
  burst_triangle(1.8)
  wait_for_clear()
  wait_frames(20)

  meanwhile(function()
    for i = 1, 6 do
      spawn(E_CIRCLE, 64, 0 + rnd(96), {
        size=2, max_size=72, fill=false,
        grow=true, growth_rate=2.6,
        duration_frames=60, warning=false
      })
      wait_frames(14)
    end
  end)
  meanwhile(function() sweep_v(1, C_DARK_PINK) end)
  sync(
    function() spawn(E_CIRCLE, 18,  64, { size=13 }) end,
    function() spawn(E_CIRCLE, 109, 64, { size=13 }) end
  )
  wait_frames(10)
  sync(
    function() spawn(E_CIRCLE, 64, 18,  { size=13 }) end,
    function() spawn(E_CIRCLE, 64, 109, { size=13 }) end
  )
  wait_for_clear()
  wait_frames(20)

  meanwhile(function() bullet_rain(10, 1.3) end)
  spawn(E_CROSS, 64, 64, { ang=0, ang_vel=0.009, duration_frames=130, len=90, size=2 })
  wait_for_clear()
  wait_frames(10)

  sync(
    function()
      spawn(E_CROSS, 64, 64, { ang=0, ang_vel=0.018, duration_frames=110, len=90, size=2 })
    end,
    function()
      for i = 1, 4 do
        wait_frames(22)
        spawn(E_BULLET, 64, 64, { count=12, speed=2.2 })
      end
    end,
    function()
      wait_frames(10)
      meanwhile(function() sweep_h(1)  end)
      meanwhile(function() sweep_h(-1) end)
    end
  )

  wait_for_clear()
  level_final_frames = level_runtime_frames
  spawn_orb(64, 52)
  wait_for_orb()
end