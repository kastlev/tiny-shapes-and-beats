-- ============================
-- enums / named constants
-- pico-8 no tiene un tipo enum real,
-- usamos tablas de constantes con nombre
-- en vez de strings/numeros magicos
-- ============================

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
DASH_REMAP_FROM = C_DARK_BLUE -- color 1, se remapea durante el dash diagonal
DASH_REMAP_TO = C_BLUE -- color 12