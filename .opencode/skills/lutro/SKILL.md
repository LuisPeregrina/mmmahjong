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
11. **Must declare resolution** — use `lutro.conf(t)` (or `love.conf(t)`) to set `t.width` and `t.height`. Without it the core defaults to 320x240. Standard LÖVE2D's `love.conf(t)` uses `t.window.width`/`t.window.height` — Lutro uses flat `t.width`/`t.height`.
12. **Both namespaces work** — `love.*` and `lutro.*` are both valid. `lutro.conf(t)` is the canonical resolution callback; `love.conf(t)` may also work as an alias.
13. **`setDefaultFilter`** — `love.graphics.setDefaultFilter("nearest", "nearest", 0)` is available and recommended for pixel-art crispness.
14. **⚠️ `unpack` trims in non-tail position** — In Lua 5.1, `unpack(t)` in a non-trailing position of an expression list gets trimmed to 1 value (the first element). The remaining elements are discarded.
    ```lua
    -- BAD: unpack is NOT the last expression - gets trimmed to 1 value
    darken_color(unpack({255, 255, 255}), 255, 0.5)  -- only passes 255, 255, 0.5
    -- GOOD: pass table directly, unpack inside the function
    darken_color({255, 255, 255}, 0.5)
    -- ALSO GOOD: unpack is the LAST/only expression - all values pass through
    love.graphics.setColor(darken_color({255, 255, 255}, 0.5))
    ```

## Typical game loop structure

Callbacks can be defined under either `love.*` or `lutro.*` namespace:

```
lutro.conf(t)       # MUST call: set t.width / t.height     ← CRITICAL
love.load()         # called once at startup
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

Real example from love-vespa game:
```lua
function lutro.conf(t)
    t.width = 320
    t.height = 240
end

function lutro.load()
    lutro.graphics.setDefaultFilter("nearest", "nearest", 0)
    -- ... load assets ...
end
```

## Importing this skill in a prompt

"Use lutro skill. Build a game."
