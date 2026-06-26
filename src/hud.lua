-- ---- progress bar
HUD_X = 1
HUD_Y = 1
HUD_W = 125

level_total_frames = 0
level_progress_frame = 0
last_respawn_frame = 0 -- { frac, hit }
hud_level_complete = false

level_runtime_frames = 0
level_final_frames = 0

-- ---- checkpoint lines
checkpoints = {}
active_checkpoint_markers = {} -- { x, frac }
checkpoint_marker_speed = 1.5

-- ---- intro card
CARD_W = 72
CARD_H = 14
CARD_DISPLAY_TIME = 20
CART_SPEED_IN = 0.2
CART_SPEED_OUT = 0.09
card_song = "no title" -- ??
level_name = "level 1"
level_card_state = "idle"
card_timer = 0
level_card_position_x = 200 -- ??

-- ---- goal orb ----
ORB_R = 5
ORB_HR = 8

orb = nil
waves = {}

function hud_start(total_f, checkpoint_list, song, lvl)
    level_total_frames = total_f
    level_progress_frame = 0
    level_runtime_frames = 0
    hud_level_complete = false
    checkpoints = {}
    last_respawn_frame = 0
    active_checkpoint_markers = {}

    for _, f in pairs(checkpoint_list or {}) do
        add(checkpoints, { frac = f, hit = false })
    end

    card_song = song or "no title"
    level_name = lvl or "level 1"
    level_card_state = "in"
    level_card_position_x = 128 + CARD_W
    orb = nil
    waves = {}
end

function hud_set_complete()
    hud_level_complete = true
end

function hud_update()
    if card_done() then
        if level_progress_frame < level_total_frames - 1 then level_progress_frame += 1 end
    end

    -- spawn lines checkpoints
    local frac = level_progress_frame / level_total_frames
    for ck in all(checkpoints) do
        if not ck.hit and frac >= ck.frac then
            ck.hit = true
            add(active_checkpoint_markers, { x = 130, frac = ck.frac })
        end
    end

    for c in all(active_checkpoint_markers) do
        c.x -= checkpoint_marker_speed

        if c.x >= p.x - 1 and c.x <= p.x + p.w + 1 then
            last_respawn_frame = level_progress_frame
            sfx(2) -- ??
            -- ??
            del(active_checkpoint_markers, c)
        elseif c.x < -2 then
            del(active_checkpoint_markers, c)
        end
    end

    _card_update()

    -- orb
    if orb and not orb.collected then
        orb.pulse += 0.06
        orb.x += orb.vx
        orb.y += orb.vy

        local margin = ORB_R + 3
        if orb.x < margin or orb.x > 127 - margin then
            orb.vx = -orb.vx
            orb.x = mid(margin, orb.x, 127 - margin)
        end
        if orb.y < margin + 4 or orb.y > 127 - margin then
            orb.vy = -orb.vy
            orb.y = mid(margin + 4, orb.y, 127 - margin)
        end

        local dx = (p.x + p.w / 2) - orb.x
        local dy = (p.y + p.h / 2) - orb.y
        if dx * dx + dy * dy < ORB_HR * ORB_HR then
            orb.collected = true
            _spawn_wave(orb.x, orb.y)
            sfx(3) -- ??
        end
    end

    for w in all(waves) do
        w.r += w.spd
        if w.r > w.max_r then del(waves, w) end
    end
end

function hud_draw()
    -- bar
    line(HUD_X, HUD_Y, HUD_X + HUD_W, HUD_Y, C_DARK_GRAY)

    -- progress bar
    local frac = min(1, level_progress_frame / level_total_frames)
    local fill_x = HUD_X + flr(frac * HUD_W)
    if fill_x > HUD_X then
        line(HUD_X, HUD_Y, fill_x, HUD_Y, C_BLUE)
    end

    -- checkpoints
    for ck in all(checkpoints) do
        local tx = HUD_X + flr(ck.frac * HUD_W)
        local tc = ck.hit and C_WHITE or C_LIGHT_GRAY
        line(tx, HUD_Y - 1, tx, HUD_Y + 1, tc)
    end

    -- line checkpoint
    for c in all(active_checkpoint_markers) do
        local lx = flr(c.x)
        if lx >= 0 and lx <= 127 then
            for y = 0, 127, 2 do
                pset(lx, y, C_LIGHT_GRAY)
            end
        end
    end

    if level_card_state != "idle" and level_card_state != "done" then
        local cx = flr(level_card_position_x)
        local cy = 128 - CARD_H - 4
        rectfill(cx + 1, cy + 1, cx + CARD_W + 1, cy + CARD_H + 1, C_BLACK)
        rectfill(cx, cy, cx + CARD_W, cy + CARD_H, C_DARK_BLUE)
        rectfill(cx, cy, cx + 2, cy + CARD_H, C_LAVENDER)
        print(level_name, cx + 5, cy + 3, C_LIGHT_GRAY)
        print(card_song, cx + 5, cy + 9, C_WHITE)
    end

    if orb and not orb.collected then
        local r = ORB_R + sin(orb.pulse) * 1.5
        local r2 = max(1, r - 2)
        -- todo
        circfill(flr(orb.x), flr(orb.y), flr(r2), C_YELLOW)
        circ(flr(orb.x), flr(orb.y), flr(r), C_WHITE)
        for i = 0, 3 do
            local a = orb.pulse + i * 0.25
            local sx = orb.x + cos(a) * (r + 3)
            local sy = orb.y + sin(a) * (r + 3)
            pset(flr(sx), flr(sy), C_WHITE)
        end
    end

    for w in all(waves) do
        if w.r > 0 then
            circ(flr(w.x), flr(w.y), flr(w.r), w.col)
        end
    end

    if level_final_frames > 0 then
        print("frames: " .. level_final_frames, 2, 120, C_WHITE)
    end
end

function spawn_orb(x, y)
    orb = {
        x = x or 64, y = y or 52,
        vx = 0.55, vy = 0.4,
        pulse = 0,
        collected = false
    }
    waves = {}
end

function card_done()
    return level_card_state == "done" or level_card_state == "idle"
end

function orb_collected()
    return orb == nil or orb.collected
end

function _card_update()
    if level_card_state == "idle" or level_card_state == "done" then
        return
    end

    local target_x = 128 - CARD_W - 0 -- ??

    if level_card_state == "in" then
        level_card_position_x += (target_x - level_card_position_x) * CART_SPEED_IN

        if abs(level_card_position_x - target_x) < 0.5 then
            level_card_position_x = target_x

            if CARD_DISPLAY_TIME > 0 then
                level_card_state = "hold"
                card_timer = CARD_DISPLAY_TIME
            else
                level_card_state = "out"
            end
        end
    elseif level_card_state == "hold" then
        card_timer -= 1

        if card_timer <= 0 then
            level_card_state = "out"
        end
    elseif level_card_state == "out" then
        level_card_position_x += (200 - level_card_position_x) * CART_SPEED_OUT

        if abs(level_card_position_x - 200) < 0.5 then
            level_card_position_x = 200
            level_card_state = "done"
        end
    end
end

function _spawn_wave(cx, cy) -- ??
    waves = {}
    for i = 1, 6 do
        add(
            waves, {
                x = cx, y = cy,
                r = i * 2, max_r = 24 + i * 14,
                col = (i % 2 == 0) and C_LAVENDER or C_WHITE,
                spd = 1.0 + i * 0.3
            }
        )
    end
end