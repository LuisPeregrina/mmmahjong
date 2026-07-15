---
name: lutro
description: "Lutro game development with Lua 5.1. Lutro is a libretro core that implements a subset of the LÖVE2D API for retro game consoles. Use this skill for any code related to Lutro projects."
---

# /lutro

Lutro developer skill. Lutro = libretro + LÖVE2D subset. Runs Lua 5.1 via libretro frontend (RetroArch, etc). No GPU, no TTF fonts, no complex shaders. Software-rendered pixel graphics.

## Reference files (in this skill's references/)

- `lutro-api.md` — Complete Lutro API surface grouped by module
- `love2d-diff.md` — LÖVE2D APIs commonly expected but NOT in Lutro
- `lua-5.1.md` — Lua 5.1 language reference manual

## Key constraints

1. **No `love.graphics.newFont`** — only `love.graphics.newImageFont` (bitmap/pixel fonts)
2. **No `love.filesystem` in LÖVE2D sense** — path is relative to the ROM dir
3. **No TTF/OTF fonts** — pixel fonts only
4. **No shaders** — software rasterizer
5. **No default font** — must provide your own pixel font
6. **Screen size** = libretro viewport (`love.graphics.getWidth`/`getHeight`)
7. **Savestates** via `love.serialize`/`love.unserialize`/`love.serializeSize` callbacks
8. **No `love.event`, `love.mouse`, `love.timer`, `love.window`, `love.system`**
9. **No `love.math`** — use plain Lua 5.1 math library
10. **Coordinate system** — origin (0,0) at upper-left, y increases downward

## Typical game loop structure

```
love.load()         # called once at start
love.update(dt)     # called 60fps
love.draw()         # called 60fps
love.keypressed(key, scancode, isrepeat)
love.keyreleased(key, scancode, isrepeat)
love.gamepadpressed(i, k)
love.gamepadreleased(i, k)
love.serialize(size)    # optional savestate
love.unserialize(data, size)
love.serializeSize()
love.reset()            # frontend reset
```

## Importing this skill in a prompt

"Use lutro skill. Build a game."
