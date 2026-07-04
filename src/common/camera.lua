CAM_SHAKE_POWER, CAM_SHAKE_DECAY, CAM_SHAKE_JITTER = 12, 0.45, 0.2

function init_camera()
  cam_x, cam_y, cam_vx, cam_vy, shk_x, shk_y, kick_x, kick_y, kick_decay = unpack(split("0,0,0,0,0,0,0,0,0.08"))
end

function draw_camera()
  if abs(shk_x) + abs(shk_y) < 0.7 then
    shk_x, shk_y = 0, 0
  else
    local f = -(CAM_SHAKE_DECAY + rnd(CAM_SHAKE_JITTER))
    shk_x, shk_y = f * shk_x, f * shk_y
  end

  kick_x = lerp_to(kick_x, 0, kick_decay, 0.3)
  kick_y = lerp_to(kick_y, 0, kick_decay, 0.3)

  cam_x, cam_y = cam_x + cam_vx, cam_y + cam_vy

  if abs(cam_x) + abs(cam_y) > 0.5 then
    local a, d = atan2(cam_x, cam_y), sqrt(cam_x * cam_x + cam_y * cam_y)
    cam_vx -= cos(a) * (0.25 + max(d - 2, 0) * 0.1)
    cam_vy -= sin(a) * (0.25 + max(d - 2, 0) * 0.1)
    cam_vx, cam_vy = lerp_to(cam_vx, 0, 0.1, 0.4), lerp_to(cam_vy, 0, 0.1, 0.4)
    cam_x, cam_y = lerp_to(cam_x, 0, 0.1, 0.2), lerp_to(cam_y, 0, 0.1, 0.2)
  else
    cam_x, cam_y = 0, 0
  end

  camera(cam_x + shk_x + kick_x, cam_y + shk_y + kick_y)
end

function add_trauma(amount)
  local a, p = rnd(1), (amount or 0.4) * CAM_SHAKE_POWER
  shk_x, shk_y = shk_x + p * cos(a), shk_y + p * sin(a)
end

function add_kick(power, dir_ang, decay)
  kick_x, kick_y = kick_x + cos(dir_ang) * power, kick_y + sin(dir_ang) * power
  kick_decay = decay or 0.08
end

function wall_bump_shake(dir_ang)
  add_kick(7, dir_ang, 0.6)
end