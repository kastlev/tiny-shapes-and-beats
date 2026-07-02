HITSTOP_FRAMES = 2

function init_hitstop()
    hitstop_timer = 0
end

function update_hitstop()
    if hitstop_timer > 0 then
        hitstop_timer -= 1
    end
end

function trigger_hitstop(frames)
    hitstop_timer = frames or HITSTOP_FRAMES
end

function is_hitstop()
    return hitstop_timer > 0
end