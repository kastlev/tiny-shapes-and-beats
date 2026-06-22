-- ============================
-- level scripts
-- ============================
function pattern_left()
  spawn_enemy(EK_CIRCLE, 30, 60, { duration_frames = 40, max_tam = 10 })
  wait_frames(20)
  spawn_enemy(EK_CIRCLE, 30, 80, { duration_frames = 40, max_tam = 10 })
end

function pattern_right()
  wait_frames(10)
  spawn_enemy(EK_CIRCLE, 90, 60, { duration_frames = 40, max_tam = 10 })
  wait_frames(20)
  spawn_enemy(EK_CIRCLE, 90, 80, { duration_frames = 40, max_tam = 10 })
end

function wave_ring(i)
  spawn_enemy(EK_RING, 64, 64, { max_tam = 20 + i * 5, duration_frames = 50 })
  wait_frames(30)
end

function level_1()
  -- circulo con aviso previo
  spawn_warned_circle(64, 40, 60, { max_tam = 14, duration_frames = 50 })
  wait_frames(20)

  -- explosion de 8 proyectiles con aviso
  spawn_warned_burst(64, 64, 8, 35, { speed = 1.8, duration_frames = 60 })
  wait_for_clear()
end