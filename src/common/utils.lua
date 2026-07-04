function lerp_to(a, b, i, m)
    local r = (1 - i) * a + i * b
    if abs(b - r) < m then
        return b
    else
        return r
    end
end

function rndb(low, high)
    return flr(rnd(high - low + 1) + low)
end

function ptbl(keys, vals)
    for i, k in pairs(keys) do
        vals[k] = vals[i]
    end
    return vals
end

function callfromstring(l)
	for s in all(split(l,"/")) do
		s=split(s)
		for i,si in inext,s do
			s[i]=_ENV[si] or si
		end
		deli(s,1)(unpack(s))
	end
end

function cycling_color(colors, rate, t)
    local i = (t \ rate % #colors) + 1
    return colors[i]
end

function draw_anim(x, y, time_t, base_sp, t_frames, spd, w, h, step)
    w, h = w or 1, h or 1
    step = step or w
    local sp = base_sp + ((time_t \ spd) % t_frames) * step
    spr(sp, x, y, w, h)
end

function any_button_pressed()
    for i = 0, 5 do
        if btnp(i) then
            return true
        end
    end
    return false
end

function line_c(x, y, len, width, ang, col, centered)
  local dirx, diry = cos(ang), sin(ang)
  local hw = width / 2
  local i0 = centered and -len or 0
  for i = i0, len do
    circfill(x + dirx * i, y + diry * i, hw, col)
  end
end


