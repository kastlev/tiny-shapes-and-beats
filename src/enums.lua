-- enemy shape kinds (keys into enemy_types)
EK_CIRCLE = "circle"
EK_RING = "ring"
EK_SQUARE = "square"
EK_LINE = "line"
EK_WARN = "warn" -- anillo rosa oscuro de aviso
EK_BULLET = "bullet" -- proyectil que se mueve

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