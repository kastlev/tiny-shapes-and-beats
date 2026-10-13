gradients = {}

for row in all(split(
  "0,0,0,0,0,0,0,0;1,1,0,0,0,0,0,0;2,1,0,0,0,0,0,0;3,5,1,0,0,0,0,0;4,2,1,0,0,0,0,0;5,1,0,0,0,0,0,0;6,13,5,1,0,0,0,0;7,6,13,5,1,0,0,0;8,4,2,1,0,0,0,0;9,8,4,2,1,0,0,0;10,9,8,4,2,1,0,0;11,3,1,0,0,0,0,0;12,1,0,0,0,0,0,0;13,5,1,0,0,0,0,0;14,2,1,0,0,0,0,0;15,14,2,1,0,0,0,0",
  ";"
)) do
  add(gradients, split(row))
end

fading, fade_t, reveal_t
 = false, 0,10

function start_fade(from, to, frames, cb)
    fade_from, fade_to, fade_frames, fade_timer, fade_cb, fading = from, to, frames, 0, cb, true
end

function start_fadein(frames) start_fade(8, 0, frames or 30) end
function start_fadeout(frames, cb) start_fade(0, 8, frames or 30, cb) end

function update_fade()
    if not fading then return end
    fade_timer += 1
    fade_t = fade_from + (fade_to - fade_from) * fade_timer / fade_frames
    if fade_timer >= fade_frames then
        fading, fade_t = false, fade_to
        if fade_t <= 0 then pal() end
        if fade_cb then fade_cb() end
    end
end

function draw_fade()
    if fade_t > 0 then
        local s = mid(1, ceil(fade_t), 8)
        for c = 0, 15 do
            pal(c, gradients[c + 1][s])
        end
    end
end


function draw_reveal()
  if reveal_t<10 then
    local h=reveal_t*6.4
    poke(0x5f34,2)
    rectfill(64-h,64-h,64+h,64+h,5|0x1800)
    poke(0x5f34,0)
  end
end

