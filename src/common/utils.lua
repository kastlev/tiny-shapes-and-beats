function rndb(low, high)
    return flr(rnd(high - low + 1) + low)
end

function any_button_pressed()
    for i = 0, 5 do
        if btnp(i) then
            return true
        end
    end
    return false
end

-- function _tni(current_index, table_length)
--   return current_index % table_length + 1
-- end

-- function _unpack_split(values_as_text)
--   return unpack(split(values_as_text))
-- end

function cycling_color(colors, rate, t)
    local i = (t \ rate % #colors) + 1
    return colors[i]
end

-- function ptbl(keys,vals)
--     for i,k in pairs(keys) do
--         vals[k]=vals[i]
--     end
--     return vals
-- end

function lerp_to(a, b, i, m)
    local r = (1 - i) * a + i * b
    if abs(b - r) < m then
        return b
    else
        return r
    end
end

-- x, y      : posición en pantalla
-- time_t    : contador que avanza con el tiempo (ej: menu_frame)
-- base_sp   : primer sprite de la secuencia
-- t_frames  : cantidad de frames en el ciclo
-- spd       : ticks de time_t por frame (más alto = más lento)
-- w, h      : tamaño del sprite en celdas de 8px (default 1,1 = sprite normal 8x8)
-- step      : cuánto avanza el número de sprite por frame de animación
--             (default = w, útil cuando los frames están en columnas consecutivas)
function draw_anim(x, y, time_t, base_sp, t_frames, spd, w, h, step)
    w, h = w or 1, h or 1
    step = step or w
    local sp = base_sp + ((time_t \ spd) % t_frames) * step
    spr(sp, x, y, w, h)
end

function line_c(x, y, len, width, ang, col, centered)
  local dirx, diry = cos(ang), sin(ang)
  local hw = width / 2
  local i0 = centered and -len or 0
  for i = i0, len do
    circfill(x + dirx * i, y + diry * i, hw, col)
  end
end

reveal_active = false
reveal_t = 0
reveal_frames = 30
reveal_cx, reveal_cy = 64, 64

function start_reveal(cx, cy, frames)
    reveal_active = true
    reveal_t = 0
    reveal_frames = frames or 30
    reveal_cx = cx or 64
    reveal_cy = cy or 64
end

function update_reveal()
    if reveal_active then
        reveal_t += 1
        if reveal_t >= reveal_frames then
            reveal_active = false
        end
    end
end

function draw_reveal()
    if not reveal_active then return end
    fade_square(min(reveal_t/reveal_frames,1), reveal_cx, reveal_cy, 5)
end

function fade_square(progress, cx, cy, col)
    if progress >= 1 then return end
    col = col or 0
    cx,cy = cx or 64, cy or 64
    local h=64*progress
    rectfill(0,0,127,cy-h-1,col)
    rectfill(0,cy+h,127,127,col)
    rectfill(0,cy-h,cx-h-1,cy+h,col)
    rectfill(cx+h,cy-h,127,cy+h,col)
end