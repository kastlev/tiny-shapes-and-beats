# 🎵 Guía para crear niveles


**Dónde buscar cada cosa**

| Quiero... | Voy a |
|---|---|
| Escribir o editar un nivel | `src/levels.lua` |
| Ver qué hace un parámetro | [Referencia](#7-referencia-de-parámetros) (al final de esta guía) |
| Entender un error | [Cuando algo falla](#6-cuando-algo-falla) |

---

## 1. Tu primer patrón en 30 segundos

> ⏱️ **Nota:** el juego corre a **30 frames por segundo**. Todos los números de espera (`wait`, `120`...) están en frames: **30 frames = 1 segundo**.

```lua
function level_4()
  level_setup(4)
  play {
    "hline;y=@;wait=30",   -- línea horizontal donde está el jugador, espera 30 frames (1 s)
    "4*rain;wait=15",      -- 4 lluvias de balas, una cada 15 frames (0.5 s)
    120                    -- 120 frames (4 s) sin enemigos: un respiro
  }
end
```

Se lee de arriba abajo. Cada línea hace tres cosas:

1. **Elige una plantilla** (`hline`, `rain`...).
2. **Cambia lo que quieras** de ella (`y=@`).
3. **Espera** (`wait=30`) antes de pasar a la siguiente.

Si no pones `wait`, la siguiente línea sale **en el mismo frame**.

---

## 2. Anatomía de una línea

```
"4*column;column_x=140;vx=-2.2;wait=30"
  │  │      │            │       └─ DESPUÉS de lanzar toda la columna, espera 30 frames
  │  │      │            └───────── velocidad fija en x (negativa = hacia la izquierda)
  │  │      └────────────────────── x donde nacen (140 = fuera de pantalla, a la derecha)
  │  └───────────────────────────── plantilla
  └──────────────────────────────── repite la línea 4 veces
```

Una plantilla como `column` crea **varios enemigos** (`n`, por defecto 9). Por defecto **nacen todos en el mismo frame**, y el `wait` cuenta **una sola vez**, después de lanzarlos todos. Repetida 4 veces, son 4 columnas separadas por 30 frames.

### `wait` y `stagger`: dos esperas distintas

| | Separa | Dónde se escribe |
|---|---|---|
| `wait` | una **línea** de la siguiente | al final de la línea |
| `stagger` | los **enemigos de un mismo patrón** entre sí | dentro de la línea, en plantillas de `spw_loop` (`column`, `rain`, `chasers`, `squares`) |

El `wait` es solo un temporizador: **no espera a que los enemigos mueran**.

```lua
"column;column_x=140;vx=-2.2;wait=30"             -- las 9 balas nacen a la vez
"column;column_x=140;vx=-2.2;stagger=5;wait=30"   -- una bala cada 5 frames (9 balas = 40 f)
"column;column_x=140;vx=-2.2;stagger=5;random=false;wait=30"  -- igual, pero barriendo de arriba a abajo
```

- La bala `i` nace `stagger × (i-1)` frames después de la primera.
- `stagger` solo funciona con `parallel=true`, que ya traen `column`, `rain`, `chasers` y `squares`. Si lo usas en un `spw_loop` escrito a mano, añade `parallel=true`.
- Las plantillas sin `parallel` (como `spiral`) usan `spawn_interval` en su lugar.
- Sin `stagger`, las plantillas con `random=true` (como `column`) ponen las balas a alturas al azar.

Los valores que escribes **pisan** los de la plantilla. Lo que no escribes, se queda como la plantilla lo define.

---

## 3. Sintaxis de `play{}`

| Escribo | Significa |
|---|---|
| `120` | Espera 120 frames |
| `"plantilla;k=v;k=v"` | Lanza la plantilla cambiando esos valores |
| `"spw;type=E_CIRCLE;k=v"` | Un enemigo suelto, todo a mano |
| `"spw_loop;pattern=row;n=8"` | Varios enemigos de golpe |
| `"N*..."` | Repite la línea N veces (incluyendo su `wait`) |
| `"a/b/c"` | Lanza `a`, luego `b`, luego `c` |
| `;wait=30` | Espera 30 frames **después de lanzar ese patrón** |
| `x=@` `y=@` | Posición del jugador en el momento de lanzar |
| `x=?` `y=?` | Posición aleatoria (14 a 114) |

> ⚠️ **Sobre `a/b/c`:** salen uno tras otro en el mismo frame **solo si no tienen `wait`**. Si `a` lleva `wait=30`, `b` sale 30 frames después. Para lanzar cosas a la vez, deja el `wait` solo en el último.
>
> ```lua
> "hline;y=@/vline;x=@;wait=30"       -- cruz: salen juntas, espera después
> "hline;y=@;wait=30/vline;x=@;wait=30" -- una, 30 f, la otra, 30 f
> ```

---

## 4. El tiempo

El juego va a 30 fps y la música a **120 BPM**.

| Unidad | Frames | Para qué |
|---|---|---|
| 1 segundo | 30 | |
| 1 beat | **15** | `stagger`, `warning_frames` |
| 2 beats | 30 | `wait` típico |
| 1 compás | **60** | secciones |
| Respiro | 120 | 2 compases tras cada checkpoint |

> 💡 Usa **múltiplos de 15** en `wait`, `stagger` y `warning_frames`: así todo cae en el beat.

### Contar frames: la convención `fN`

Anota en cada línea el frame donde **empieza**, en un comentario a la derecha:

```lua
"squares;n=8;stagger=15;wait=120",   -- f120 cuadrados de uno en uno
"squares;n=2;stagger=30;wait=60",    -- f240 de dos en dos
120,                                 -- f300 RESPIRO (checkpoint 1)
```

Con eso sacas los números de `LEVEL_META` sin pensar:

- `total` = el último `fN` del nivel.
- `pointN` = `fN del respiro / total` (respiro en f420 de 1560 → `0.27`).

Si cambias un `wait`, todos los `fN` siguientes se mueven. Para no recalcular a mano: **juega el nivel una vez** y mira el `frames: N` que sale al terminar. Ese `N` es el `total` real.

---

## 5. Crear un nivel paso a paso

**Checklist**

- [ ] 1. Agrega una línea a `LEVEL_META` (en `levels.lua`).
- [ ] 2. Escribe `function level_N()` con `level_setup(N)` y `play{...}`.
- [ ] 3. Dibuja el icono del nivel en el mapa, en la columna `map_x`.
- [ ] 4. Compón la música en el pattern `track`.
- [ ] 5. Juega el nivel, copia el `frames: N` a `total` y ajusta los `point`.

### Campos de `LEVEL_META`

| Campo | Qué es | Ejemplo |
|---|---|---|
| `name` | Texto pequeño de la card | `LVL 4` |
| `song` | Título de la canción (card y selector) | `waves` |
| `track` | Pattern donde empieza la música | `24` |
| `total` | Frames del nivel | `2400` |
| `pointN` | Checkpoint N (1 a 4), como fracción 0–1 | `point1=0.25` |
| `pointN_color` | (opcional) color de fondo desde ese checkpoint | `point1_color=1` |
| `map_x` | Columna del icono en el mapa | `32` |

```lua
"name=LVL 4;song=nombre;track=24;total=2400;point1=0.25;point2=0.55;map_x=32"
```

### Forma recomendada de un nivel

```
intro → desarrollo → RESPIRO (checkpoint) → clímax → RESPIRO → final
```

- **Una idea nueva por sección.** Enséñala sola y combínala después.
- **Respiro de 120 f** tras cada checkpoint: el marcador tarda 46–80 f en llegar al jugador.
- **Los avisos se acortan** con la dificultad: 40–45 f al inicio, 15 f al final.
- **Casi todo por debajo de la velocidad del jugador (2.5 px/frame).** Solo las balas rápidas la superan.

---

## 6. Cuando algo falla

| Lo que ves | Causa probable |
|---|---|
| El enemigo desaparece enseguida | `duration_frames` es corta (por defecto **40**), o salió de la pantalla. |
| El anillo muere a medio crecer | `duration_frames` menor que `size_max / grow_px`. |
| El aviso sale en un sitio y el enemigo en otro | En `orbit`, `x,y` deben ser el punto de partida de la órbita. |
| Lo siguiente sale demasiado pronto | Falta un `wait`. |
| Un valor no se interpreta bien | No definas variables globales con nombres como `column`, `row`, `circle`, `point`: el parser las confundiría con el texto. |

### Notas Adicionales

- 🎯 **Lo letal es el color.** Solo duelen los píxeles `C_PINK` (14). Un enemigo con otro `color` se ve pero no hiere. El aviso (rosa oscuro) tampoco.
- 🐌 **Las líneas cuestan fps:** cada una dibuja ~`2*len` círculos por frame.
- 💨 **El dash hace invulnerable** durante 8 frames.

---

## 7. Referencia de parámetros

Todos los parámetros se pueden usar en cualquier plantilla, en `spw` y en `spw_loop`. El valor entre paréntesis es el default.

### Plantillas disponibles (`levels.lua`)

#### Líneas y cruces
| Plantilla | Qué hace | Ajustes habituales |
|---|---|---|
| `hline` | Línea horizontal barredora | `y=@` o `y=?`, `size`, `warning_frames` |
| `vline` | Línea vertical | `x=@` o `x=?` |
| `cross` | Cruz giratoria en el centro (dura 210 f) | `ang_vel`, `len` |

#### Formas que crecen
| Plantilla | Qué hace | Ajustes habituales |
|---|---|---|
| `ring` | Anillo que crece desde `x,y` hasta `size_max` | `grow_px`, `size_max`, `x`, `y` |

#### Balas y ráfagas
| Plantilla | Qué hace | Ajustes habituales |
|---|---|---|
| `burst` | Emisor que al morir suelta un anillo de balas | `burst_count`, `burst_speed`, `burst_angle_offset=?` |
| `column` | Columna de balas desde la izquierda | `n`, `vx`; derecha: `column_x=140;vx=-3.4` |
| `rain` | Lluvia desde arriba | `n`, `vy` |
| `aimed` | Bala dirigida al jugador | `x`, `y` (origen), `aim` |
| `spiral` | Espiral de 3 brazos (~80 f) | `burst_count`, `stagger_burst_angle_offset` |
| `emitter` | Entra desde un borde, se queda 20 f y suelta un anillo | `x`, `y`, `target_x`, `target_y` |

#### Perseguidores y cuadrados
| Plantilla | Qué hace | Ajustes habituales |
|---|---|---|
| `chasers` | Persiguen al jugador, nacen en el perímetro | `n`, `chase_speed`, `stagger` |
| `squares` | Cuadrados que aparecen junto al jugador | `n`, `stagger`, `near_range` |

#### Zonas (`E_HOLE`: **lo de fuera del círculo es letal**)
| Plantilla | Qué hace | Ajustes habituales |
|---|---|---|
| `zone` | Zona quieta | `size` (radio seguro), `x`, `y` |
| `orbzone` | Zona que orbita | `orbit_radius`, `orbit_speed` |
| `lens` | Mitad de un "lente": lanza **dos** con `orbit_ang` distinto | `orbit_ang`, `x` |
| `jumpzone` | Zona que aparece en `x,y` y desaparece | `x`, `y` |
| `zonering` | Anillo lento para usar **dentro** de una zona | `grow_px`, `size_max`, `duration_frames` |

> 📏 **Regla de las zonas:** en cada tramo, la suma de los `wait` debe ser igual a `warning_frames + duration_frames` de su hoyo. Así nace el siguiente justo cuando muere el anterior.
>
> **`zonering`:** `size_max` = radio del hoyo + 2, y `duration_frames = size_max / grow_px + 1`.
> `grow_px 0.7` → fácil · `0.9` → normal · `1.2` → difícil.

<details>
<summary><strong>Forma, posición y vida</strong></summary>

| Parámetro | Default | Qué hace |
|---|---|---|
| `type` | `E_CIRCLE` | `E_CIRCLE`, `E_SQUARE`, `E_LINE_BI`, `E_CROSS`, `E_BULLET`, `E_HOLE` |
| `x`, `y` | aleatorio 10–118 | Posición de nacimiento |
| `near_player` | — | `true`: nace cerca del jugador |
| `near_range` | 20 | Distancia máxima al jugador |
| `size` | 10 | Radio (círculo), mitad del lado (cuadrado), grosor (líneas) |
| `size_max` | — | Tamaño final si crece |
| `fill` | `true` | `false` dibuja solo el contorno |
| `color` | rosa (letal) | Cualquier otro color no hiere |
| `duration_frames` | 40 | Vida del enemigo **real** desde que nace |
| `hold_frames` | 0 | Frames extra al final. Vida total = `duration + hold` |
| `delay_spawn` | 0 | Espera antes de nacer |
| `len` | 80 | Largo de la línea hacia **cada** lado |
| `ang` | 0 | Ángulo: 0 = der · 0.25 = abajo · 0.5 = izq · 0.75 = arriba |
| `ang_vel` | 0 | Giro por frame |

**Tipos**

- `E_LINE_BI`: línea centrada en `x,y`.
- `E_CROSS`: dos líneas, `ang` y `ang+0.25`.
- `E_BULLET`: sin aviso automático.
- `E_HOLE`: `size` es el radio **seguro**.

**¿Qué cuenta dentro de `duration_frames`?**

```
spawn ─┬─ delay_spawn ........ antes de nacer (no cuenta)
       ├─ warning_frames ..... aviso (no cuenta)
       └─ enemigo real ─┬─ duration_frames (incluye delay_move y delay_grow)
                        └─ hold_frames (extra al final)
```

- `target_x/y` y `ease_grow` terminan justo al final de `duration_frames`.
- Con `vx/vy`, `chase` u `orbit`, solo marca cuánto vive. Durante el `hold` **siguen moviéndose**.
- Es un máximo: si sale de pantalla (sin `wrap` ni `bounce`), muere antes y **no** dispara su `burst`.
- Los últimos 2 frames se dibujan en rosa oscuro y no hieren.

</details>

<details>
<summary><strong>Movimiento</strong></summary>

Se aplica **solo uno**, por este orden de prioridad:

| Parámetro | Default | Qué hace |
|---|---|---|
| `delay_move` | 0 | Frames quieto antes de moverse |
| `orbit` | — | Gira alrededor de `orbit_cx`, `orbit_cy` (por defecto, donde nació) |
| `orbit_radius` | 20 | Radio de la órbita |
| `orbit_speed` | 0.01 | Vueltas/frame (negativo = al revés). 0.006 ≈ 0.8 px/f |
| `orbit_ang` | azar | Ángulo inicial |
| `chase` | — | Persigue al jugador |
| `chase_speed` | 1.6 | Velocidad |
| `chase_turn` | 0.06 | Cuánto gira por frame (menor = más torpe) |
| `target_x`, `target_y` | — | Va de su origen a ese destino en `duration_frames` |
| `ease_move` | lineal | `"lerp"` acerca un % cada frame (con `lerp_factor`, 0.1) |
| `vx`, `vy` | 0 | Velocidad constante |
| `v_random` | — | Velocidad al azar entre `v_speed_min` (1) y `v_speed_max` (3) |
| `aim` | — | Apunta al jugador **al nacer** (después del aviso). Mantenlo **< 2.5** |

> 📍 En `orbit`, `x,y` deben coincidir con el punto de partida: `x = orbit_cx + cos(orbit_ang) * orbit_radius`.

**Extras que se suman al movimiento anterior**

| Parámetro | Default | Qué hace |
|---|---|---|
| `wave` | — | Ondulación (`wave_amp` 10, `wave_freq` 0.05, `wave_axis` `"y"` o `"x"`) |
| `wrap` | — | Sale por un borde y entra por el opuesto |
| `bounce` | — | Rebota en los bordes (`bounce_speed_mult`, `bounce_size_mult`) |

</details>

<details>
<summary><strong>Crecimiento</strong></summary>

Solo crece si `size_max > size`. Elige **un** modo (prioridad: `grow_lerp` > `ease_grow` > `grow_px`):

| Parámetro | Default | Qué hace |
|---|---|---|
| `grow_px` | 0.5 | Píxeles por frame hasta `size_max` |
| `grow_lerp` | 0.1 | Cada frame se acerca ese % al `size_max` |
| `ease_grow` | — | Llega a `size_max` justo en `duration_frames` (hoy, lineal) |
| `delay_grow` | 0 | Frames antes de empezar a crecer |

> `grow_px` y `grow_lerp` no dependen de `duration_frames`. Si esta es más corta de lo que tarda en llegar a `size_max`, el enemigo muere a medio crecer.

</details>

<details>
<summary><strong>Aviso (warning)</strong></summary>

Una copia en rosa oscuro, **antes** del enemigo real, que no hiere.

| Parámetro | Default | Qué hace |
|---|---|---|
| `warning` | `true` | `false` lo quita. Las balas y las ráfagas con `count` no lo tienen salvo que pongas `warning=true` |
| `warning_frames` | 20 | Cuánto dura |
| `warning_color` | rosa oscuro | Color del aviso |

> En `E_HOLE`, el aviso oscurece todo menos el círculo nuevo. En un `ring`, el aviso es solo un punto en el centro.

</details>

<details>
<summary><strong>Balas (burst al morir y ráfaga instantánea)</strong></summary>

**Burst al morir** (`burst=true`): al terminar su vida suelta un anillo de balas. Siempre crea `E_BULLET`, sea cual sea el `type` del emisor.

| Parámetro | Default | Qué hace |
|---|---|---|
| `burst_count` | 8 | Cuántas balas |
| `burst_speed` | 1.5 | Velocidad |
| `burst_angle_offset` | 0 | Giro del anillo (`?` = azar) |
| `burst_size` | 1 | Tamaño de las balas |
| `burst_duration_frames` | 80 | Vida de las balas |
| `burst_color`, `burst_shape` | — | `burst_shape=square` para balas cuadradas |
| `burst_quiet` | — | `true`: sin flash ni partículas (útil en espirales) |

**Ráfaga instantánea:** si pasas `count`, `speed` y `angle_offset` (más `size`, `color`, `shape`), dispara un anillo al nacer y **no crea enemigo**.

</details>

<details>
<summary><strong>Parpadeo</strong></summary>

| Parámetro | Default | Qué hace |
|---|---|---|
| `flicker` | — | Alterna colores |
| `flicker_colors` | rosa, blanco | Colores que alterna |
| `flicker_rate` | 4 | Frames por color |

</details>

---

## 8. `spw_loop`: varios enemigos de golpe

Acepta **todos** los parámetros de arriba, más estos:

| Parámetro | Default | Qué hace |
|---|---|---|
| `n` | 6 | Cantidad |
| `pattern` | — | Dónde nacen (ver abajo) |
| `parallel` | — | `true`: cada enemigo nace por su cuenta, con su aviso al mismo tiempo, separados por `stagger`. Sin `parallel`: uno tras otro (espera su aviso y luego `spawn_interval`) |
| `stagger` | 0 | Frames entre cada nacimiento (modo `parallel`) |
| `spawn_interval` | 15 | Frames entre cada nacimiento (modo **no** `parallel`) |
| `stagger_CAMPO=N` | — | El enemigo `i` recibe `CAMPO + N*(i-1)` |

**Patrones de posición**

| `pattern` | Dónde nacen | Opciones |
|---|---|---|
| `perimeter` | En un cuadrado alrededor del centro | `radius` (46), `random` |
| `row` | Fila superior | `row_y` (-4), `margin` (10), `random` |
| `column` | Columna izquierda | `column_x` (-4), `margin` (10), `random` |
| `point` | Un punto | `x`, `y` (64, 64) |
| *(ninguno)* | `x,y` dados, o al azar | |

- `perimeter` con `radius=64` y `n=4` pone un enemigo en cada **esquina**.
- `random=true` reparte al azar en vez de a intervalos iguales.

**`stagger_CAMPO` en acción**

```
stagger_chase_speed=0.2           cada perseguidor es 0.2 más rápido que el anterior
stagger_burst_angle_offset=0.03   cada anillo gira 0.03 más: así se hace una espiral
stagger_size=1.5                  cada uno es 1.5 más grande
```

---

## 9. Recetas listas para copiar

```lua
-- Presión constante sobre el jugador
"4*hline;y=@;wait=15"

-- Cruz exacta sobre el jugador (salen juntas)
"hline;y=@/vline;x=@;wait=30"

-- Muro de balas desde la derecha
"column;column_x=140;vx=-3;n=7;wait=30"

-- Anillos de balas con giro al azar
"4*burst;burst_angle_offset=?;warning_frames=20;wait=30"

-- Ráfaga apuntada desde el borde izquierdo, a tu altura
"8*aimed;x=-4;y=@;warning=true;warning_frames=15;wait=20"

-- Perseguidores en las 4 esquinas
"chasers;n=4;radius=64;chase_speed=1.0;wait=120"

-- Doble espiral cruzada
"spiral/spiral;stagger_burst_angle_offset=-0.03;wait=120"

-- Emisores que entran por los lados
"emitter;x=-1;y=40;target_x=15;target_y=40"
40
"emitter;x=129;y=80;target_x=119;target_y=80"

-- Zona que salta, con anillo y lluvia dentro (120 f)
"jumpzone;x=36;y=36;wait=30/zonering;x=36;y=36;wait=30/rain;wait=60"
```

---

## 10. Crear una plantilla nueva

Una plantilla es un string en la tabla `T` de `templates.lua`. Cuesta ~3 tokens.

```lua
T = {
  -- ...
  fastbullets = "spw_loop;pattern=row;n=5;parallel=true;type=E_BULLET;size=2;vy=2.4;duration_frames=60",
}
```

Úsala por su nombre: `"fastbullets;n=8;wait=30"`.

- El primer elemento (`spw`, `spw_loop`) es la función que se llama.
- Pon en la plantilla lo que **casi siempre** quieras y deja fuera lo que cambies cada vez (`x`, `y`, `n`...).
- Si dos valores se contradicen, gana el de la línea del nivel.