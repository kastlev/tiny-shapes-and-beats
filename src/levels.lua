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

  -- =========================
  -- INTRO: lectura del jugador
  -- =========================
  spawn_warned_circle(64, 32, 50, { max_tam = 12, grow = false })
  wait_frames(25)

  spawn_warned_circle(32, 64, 50, { max_tam = 10, grow = false })
  wait_frames(20)

  spawn_warned_circle(96, 64, 50, { max_tam = 10, grow = false })
  wait_frames(30)

  -- =========================
  -- PRIMERA PRESIÓN: bursts suaves
  -- =========================
  spawn_warned_burst(64, 64, 6, 35, { speed = 1.3 })
  wait_frames(15)

  spawn_warned_circle(64, 48, 45, { max_tam = 14, grow = false })
  wait_frames(15)

  spawn_warned_burst(64, 64, 8, 35, { speed = 1.5, grow = false })
  wait_frames(20)

  -- =========================
  -- MOVIMIENTO LATERAL (patrones clásicos)
  -- =========================
  pattern_left()
  wait_frames(10)
  pattern_right()
  wait_frames(20)

  -- =========================
  -- CONTROL DEL CENTRO (ring pressure)
  -- =========================
  for i = 1, 3 do
    wave_ring(i)
  end

  wait_frames(20)

  -- =========================
  -- DOBLE PRESIÓN (simultáneo)
  -- =========================
  spawn_warned_circle(40, 40, 45, { max_tam = 12, grow = false })
  spawn_warned_circle(88, 88, 45, { max_tam = 12, grow = false })

  wait_frames(20)

  spawn_warned_burst(64, 64, 10, 30, { speed = 1.8, grow = false })

  wait_for_clear()

  -- =========================
  -- CLIMAX FINAL
  -- =========================
  spawn_warned_burst(64, 64, 12, 25, { speed = 2.1, grow = false })
  wait_frames(10)

  spawn_warned_circle(64, 64, 35, { max_tam = 16, grow = false })

  wait_for_clear()

end