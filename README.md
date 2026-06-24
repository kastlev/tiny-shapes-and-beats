# Tiny beats and shapes - PICO-8

A small PICO-8 demake inspired by Just Shapes & Beats.

Recreated core mechanics:
- Top-down movement
- Dash mechanic
- Invulnerability frames
- Enemy attack patterns
- Warning indicators
- Projectile bursts
- Scripted level patterns

## Built with

- PICO-8
- Lua

## Architecture

The code is separated into:

- player.lua
  - movement
  - acceleration
  - dash system

- enemies.lua
  - enemy entities
  - projectile handling
  - drawing

- patterns.lua
  - coroutine based attack scripting

- levels.lua
  - level sequences

## Run

Open the `.p8` file with PICO-8.

## Credits

Inspired by Just Shapes & Beats by Berzerk Studio.

This is a fan-made non-commercial demake created for learning purposes.