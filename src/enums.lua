-- enemy shape types (keys into enemy_types)
E_CIRCLE  = "circle"   -- fill o outline segun param
E_SQUARE  = "square"   -- fill o outline segun param
E_LINE    = "line"     -- rayo desde origen, una direccion
E_LINE_BI = "line_bi"  -- rayo en ambas direcciones desde centro
E_CROSS   = "cross"    -- cruz (dos E_LINE_BI perpendiculares)
E_BULLET  = "bullet"   -- pixel que se mueve

DEFAULT_WARNING_TIME = 20

-- pico-8 default palette, named
C_BLACK = 0
C_DARK_BLUE = 1
C_DARK_PINK = 2
C_DARK_GREEN = 3
C_BROWN = 4
C_DARK_GRAY = 5
C_LIGHT_GRAY = 6
C_WHITE = 7
C_RED = 8
C_ORANGE = 9
C_YELLOW = 10
C_GREEN = 11
C_BLUE = 12
C_LAVENDER = 13
C_PINK = 14
C_PEACH = 15

--  dash parameters
DASH_EXPLOSION_RADIUS = 6
DASH_EXPLOSION_COLOR = C_BLUE
DASH_TRAIL_COLOR = C_DARK_GRAY
DASH_TRAIL_OFFSET = 1

-- hp damage mask params
-- HP_DAMAGE_COLOR = 5  -- shade used to "drain" the sprite as hp drops
HP_DAMAGE_FX_SLOT = C_DARK_BLUE

-- combat / feedback params
HITSTOP_FRAMES = 2
SHAKE_DURATION = 8
SHAKE_MAGNITUDE = 2

BG_COLOR_DEFAULT = C_BLACK

function trigger_hit_juice()
	hitstop_timer = HITSTOP_FRAMES
	shake_timer = SHAKE_DURATION
	p.flash_damage_timer = p.flash_damage_timer_max
	sfx(1)
	spawn_damage_particles(p.x + p.w/2, p.y + p.h/2)
end