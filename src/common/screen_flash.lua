ALL_COLORS=split"0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15"
flash_disabled=false

function init_screen_flash()
  screen_flash_timer,screen_flash_timer_max,screen_flash_cfg=0,0,nil
end

function trigger_screen_flash(cfg)
  if flash_disabled then return end
  screen_flash_timer,screen_flash_timer_max,screen_flash_cfg=cfg.frames,cfg.frames,cfg
end