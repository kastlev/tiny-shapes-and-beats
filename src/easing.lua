-- todas las funciones reciben t en rango 0->1
-- y devuelven un valor modificado en ~0->1
-- uso: ease_grow="outquad" ease_move="elastic_out"

-- ── lineales ──────────────────────────────────────
function ease_linear(t)       return t end

-- ── quadraticas ───────────────────────────────────
function ease_in_quad(t)      return t*t end
function ease_out_quad(t)     t-=1 return 1-t*t end
function ease_inout_quad(t)
  if t<.5 then return t*t*2
  else t-=1 return 1-t*t*2 end
end
function ease_outin_quad(t)
  if t<.5 then t-=.5 return .5-t*t*2
  else t-=.5 return .5+t*t*2 end
end

-- ── quarticas ─────────────────────────────────────
function ease_in_quart(t)     return t*t*t*t end
function ease_out_quart(t)    t-=1 return 1-t*t*t*t end
function ease_inout_quart(t)
  if t<.5 then return 8*t*t*t*t
  else t-=1 return 1-8*t*t*t*t end
end
function ease_outin_quart(t)
  if t<.5 then t-=.5 return .5-8*t*t*t*t
  else t-=.5 return .5+8*t*t*t*t end
end

-- ── overshoot ─────────────────────────────────────
function ease_in_over(t)      return 2.7*t*t*t-1.7*t*t end
function ease_out_over(t)     t-=1 return 1+2.7*t*t*t+1.7*t*t end
function ease_inout_over(t)
  if t<.5 then return (2.7*8*t*t*t-1.7*4*t*t)/2
  else t-=1 return 1+(2.7*8*t*t*t+1.7*4*t*t)/2 end
end
function ease_outin_over(t)
  if t<.5 then t-=.5 return (2.7*8*t*t*t+1.7*4*t*t)/2+.5
  else t-=.5 return (2.7*8*t*t*t-1.7*4*t*t)/2+.5 end
end

-- ── elastic ───────────────────────────────────────
function ease_in_elastic(t)
  if t==0 then return 0 end
  return 2^(10*t-10)*cos(2*t-2)
end
function ease_out_elastic(t)
  if t==1 then return 1 end
  return 1-2^(-10*t)*cos(2*t)
end
function ease_inout_elastic(t)
  if t<.5 then return 2^(10*2*t-10)*cos(2*2*t-2)/2
  else t-=.5 return 1-2^(-10*2*t)*cos(2*2*t)/2 end
end
function ease_outin_elastic(t)
  if t<.5 then return .5-2^(-10*2*t)*cos(2*2*t)/2
  else t-=.5 return 2^(10*2*t-10)*cos(2*2*t-2)/2+.5 end
end

-- ── bounce ────────────────────────────────────────
function ease_out_bounce(t)
  local n,d=7.5625,2.75
  if     t<1/d   then return n*t*t
  elseif t<2/d   then t-=1.5/d   return n*t*t+.75
  elseif t<2.5/d then t-=2.25/d  return n*t*t+.9375
  else                t-=2.625/d return n*t*t+.984375 end
end
function ease_in_bounce(t)
  t=1-t
  local n,d=7.5625,2.75
  if     t<1/d   then return 1-n*t*t
  elseif t<2/d   then t-=1.5/d   return 1-n*t*t-.75
  elseif t<2.5/d then t-=2.25/d  return 1-n*t*t-.9375
  else                t-=2.625/d return 1-n*t*t-.984375 end
end

-- ── tabla de lookup ───────────────────────────────
ease_fns = {
  ["linear"]        = ease_linear,
  ["in_quad"]       = ease_in_quad,
  ["out_quad"]      = ease_out_quad,
  ["inout_quad"]    = ease_inout_quad,
  ["outin_quad"]    = ease_outin_quad,
  ["in_quart"]      = ease_in_quart,
  ["out_quart"]     = ease_out_quart,
  ["inout_quart"]   = ease_inout_quart,
  ["outin_quart"]   = ease_outin_quart,
  ["in_over"]       = ease_in_over,
  ["out_over"]      = ease_out_over,
  ["inout_over"]    = ease_inout_over,
  ["outin_over"]    = ease_outin_over,
  ["in_elastic"]    = ease_in_elastic,
  ["out_elastic"]   = ease_out_elastic,
  ["inout_elastic"] = ease_inout_elastic,
  ["outin_elastic"] = ease_outin_elastic,
  ["in_bounce"]     = ease_in_bounce,
  ["out_bounce"]    = ease_out_bounce,
}

function _ease(t, mode)
  t = mid(0, t, 1)
  local fn = ease_fns[mode] or ease_linear
  return fn(t)
end