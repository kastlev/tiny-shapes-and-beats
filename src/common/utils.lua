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
			s[i]=_ENV[si] or tonum(si) or si
		end
		deli(s,1)(unpack(s))
	end
end

function _merge(base, over)
  for k, v in pairs(over or {}) do base[k] = v end
  return base
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

function _kv_parts(parts)
    local t = {}
    for pair in all(parts) do
        local kv = split(pair, "=")
        local k, v = kv[1], kv[2]
        if v == "true" then v = true
        elseif v == "false" then v = false
        elseif tonum(v) then v = tonum(v)
        elseif _ENV[v] ~= nil then v = _ENV[v]
        end
        t[k] = v
    end
    return t
end

function run(str)
    local branches = split(str, "|")
    if #branches > 1 then
        local fns = {}
        for b in all(branches) do add(fns, function() run(b) end) end
        return sync(unpack(fns))
    end
    local last
    for call in all(split(str, "/")) do
        local parts = split(call, ";")
        local fname = parts[1]
        deli(parts, 1)
        last = _ENV[fname](_kv_parts(parts))
    end
    return last
end

function lerp(a,b,t)
    return a+(b-a)*t
end