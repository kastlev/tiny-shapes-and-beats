

CAM_TRAUMA_DECAY   = 0.06 -- frames
CAM_MAX_OFFSET     = 4 -- pixels

function camera_init()
  cam_trauma, cam_x, cam_y = 0, 0, 0
end

function draw_camera()
  if cam_trauma > 0 then
    cam_trauma = max(0, cam_trauma - CAM_TRAUMA_DECAY)
    local s = cam_trauma * cam_trauma
    cam_y = (rnd(2) - 1) * CAM_MAX_OFFSET * s
  else
    cam_x = 0
    cam_y = 0
  end
  camera(cam_x, cam_y)
end

function camera_clear_offset()
  camera()
end

-- called in level load / respawn
function camera_reset()
  cam_trauma = 0
  camera()
end

function add_trauma(amount) -- 0 -> 1
  cam_trauma = min(1, cam_trauma + (amount or 0.4))
end