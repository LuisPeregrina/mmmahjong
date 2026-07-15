# Lutro API Reference

Complete API surface of Lutro (libretro LÖVE2D subset).

---

## love (callbacks)

### love.load()
Called once at startup. Load assets, initialize state.

### love.update(dt)
Called 60fps. `dt` = time since last frame (default 1/60).

### love.draw()
Called 60fps. Render game state.

### love.gamepadpressed(i, k)
Joypad button pressed. `i` = port (1-based), `k` = button name string.

### love.gamepadreleased(i, k)
Joypad button released.

### love.keypressed(key, scancode, isrepeat)
Keyboard key pressed. `key` = name string, `scancode` = numeric libretro code, `isrepeat` = false.

### love.keyreleased(key, scancode, isrepeat)
Keyboard key released.

### love.serialize(size) -> string
Optional. Return serialized game state as string for savestate.

### love.unserialize(data, size)
Optional. Restore game state from serialized string.

### love.serializeSize() -> number
Return savestate size in bytes (constant, e.g. 1024*8).

### love.reset()
Called on frontend reset. Free resources, reinitialize.

---

## love.graphics

### love.graphics.clear()
Clear screen to background color.

### love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
Draw Image or texture. `r` = rotation (radians), `sx/sy` = scale, `ox/oy` = offset, `kx/ky` = shear.

Also: `love.graphics.draw(texture, quad, x, y, r, sx, sy, ox, oy, kx, ky)` — draw a Quad region.

### love.graphics.newImage(filename) -> Image
Load image from file.
Also: `love.graphics.newImage(imgData)` — from ImageData.

### love.graphics.newImageFont(filename, glyphs, spacing) -> Font
Create pixel font from image. `glyphs` = string of characters in order. `spacing` = letter spacing (default 1 in Lutro, 0 in LÖVE).

Also: `love.graphics.newImageFont(img, glyphs, spacing)` — from Image.

### love.graphics.newQuad(x, y, w, h, sw, sh) -> Quad
Create a Quad for drawing a sub-region of a texture. `sw/sh` = texture dimensions.

### love.graphics.newCanvas(w, h) -> Canvas
Create an offscreen render target.

### love.graphics.print(text, x, y)
Draw text. Requires setFont before use.

### love.graphics.printf(text, x, y, limit, align)
Draw formatted text with word wrap. `align` = "left", "center", or "right".

### love.graphics.point(x, y)
Draw a single pixel point.

### love.graphics.points(x, y, ...)
Draw one or more points.

### love.graphics.line(x1, y1, x2, y2, ...)
Draw lines between points.

### love.graphics.rectangle(mode, x, y, w, h)
Draw rectangle. `mode` = "fill" or "line".

### love.graphics.polygon(mode, x1, y1, x2, y2, ...)
Draw polygon. `mode` = "fill" or "line".

### love.graphics.circle(mode, x, y, radius, segments)
Draw circle.

### love.graphics.ellipse(mode, x, y, rx, ry, segments)
Draw ellipse.

### love.graphics.origin()
Reset all transformations.

### love.graphics.pop()
Pop transformation from stack.

### love.graphics.push()
Push transformation onto stack.

### love.graphics.rotate(angle)
Rotate by angle (radians).

### love.graphics.scale(sx, sy)
Scale coordinate system.

### love.graphics.translate(dx, dy)
Translate coordinate system.

### love.graphics.getBackgroundColor() -> r, g, b, a
Get background color.

### love.graphics.setBackgroundColor(r, g, b, a)
Set background color.

### love.graphics.getColor() -> r, g, b, a
Get current draw color.

### love.graphics.setColor(r, g, b, a)
Set draw color for subsequent draw calls.

### love.graphics.getFont() -> Font
Get current Font.

### love.graphics.setFont(font)
Set current Font for text rendering.

### love.graphics.getHeight() -> number
Return viewport height.

### love.graphics.getWidth() -> number
Return viewport width.

### love.graphics.getCanvas() -> Canvas
Get current render target.

### love.graphics.setScissor(x, y, w, h)
Set scissor rectangle (clipping region).

### love.graphics.setCanvas(canvas)
Set render target to Canvas (or nil for screen).

---

## love.image

### love.image.newImageData(width, height) -> ImageData
Create empty ImageData.
Also: `love.image.newImageData(filename)` — load from file.

### ImageData:getWidth() -> number
### ImageData:getHeight() -> number
### ImageData:getDimensions() -> width, height
### ImageData:getPixel(x, y) -> r, g, b, a
### ImageData:setPixel(x, y, r, g, b, a)

---

## love.audio

### love.audio.newSource(filename, type) -> Source
Load audio file (.wav or .ogg). `type` = "static" or "stream".

### love.audio.play(source)
Play Source.

### love.audio.stop(source)
Stop Source.

### love.audio.pause(source, ...) -> paused_sources
Pause one or more Sources. Call with no args to pause all.

### love.audio.getVolume() -> volume
Get master volume (0.0 - 1.0).

### love.audio.setVolume(volume)
Set master volume.

### love.audio.getActiveSources() -> sources
Get currently playing sources.

### love.audio.getActiveSourceCount() -> number
Get number of simultaneously playing sources.

---

## love.sound

### love.sound.newSoundData(filename) -> SoundData
Decode audio file (.wav or .ogg). Does NOT play — use love.audio.

---

## love.filesystem

### love.filesystem.exists(name) -> bool
Check if file/dir exists.

### love.filesystem.read(name, size) -> contents, size
Read file contents.

### love.filesystem.write(name, data, size) -> success, message
Write data to file.

### love.filesystem.setRequirePath(paths)
Set Lua require search paths.

### love.filesystem.getRequirePath() -> paths
Get Lua require search paths.

### love.filesystem.load(name) -> chunk, errormsg
Load Lua file (does not run it).

### love.filesystem.setIdentity(name)
Set write directory for game.

### love.filesystem.getUserDirectory() -> path
Get user directory path.

### love.filesystem.isDirectory(name) -> bool
### love.filesystem.isFile(name) -> bool
### love.filesystem.createDirectory(name) -> success
### love.filesystem.getDirectoryItems(dir) -> files

---

## love.input (deprecated)

Use love.joystick instead.

### love.input.joypad(port, button) -> pressed
Check if joypad button pressed. Port = 1-based. Button names:
b, y, select, start, up, down, left, right, a, x, l1, r1, l2, r2, l3, r3

---

## love.keyboard

### love.keyboard.isDown(key, ...) -> pressed
Check if key(s) pressed. Key names: a-z, 0-9, space, return, escape, tab, backspace, up, down, left, right, f1-f15, lshift, rshift, lctrl, rctrl, lalt, ralt.

### love.keyboard.getScancodeFromKey(key) -> scancode
Get numeric libretro scancode for key name.

### love.keyboard.getKeyFromScancode(scancode) -> key
Get key name from numeric scancode.

---

## love.joystick

### love.joystick.getJoystickCount() -> number
Number of connected joysticks.

### love.joystick.isDown(joystick, button) -> pressed
Check button. Use RETRO_DEVICE_ID_JOYPAD constants (1-16).

### love.joystick.getAxis(joystick, axis) -> value
Get analog axis value. Use AXIS_LEFT_X=1, AXIS_LEFT_Y=2, AXIS_RIGHT_X=3, AXIS_RIGHT_Y=4.

Button constants:
```
RETRO_DEVICE_ID_JOYPAD_B      = 1
RETRO_DEVICE_ID_JOYPAD_Y      = 2
RETRO_DEVICE_ID_JOYPAD_SELECT = 3
RETRO_DEVICE_ID_JOYPAD_START  = 4
RETRO_DEVICE_ID_JOYPAD_UP     = 5
RETRO_DEVICE_ID_JOYPAD_DOWN   = 6
RETRO_DEVICE_ID_JOYPAD_LEFT   = 7
RETRO_DEVICE_ID_JOYPAD_RIGHT  = 8
RETRO_DEVICE_ID_JOYPAD_A      = 9
RETRO_DEVICE_ID_JOYPAD_X      = 10
RETRO_DEVICE_ID_JOYPAD_L      = 11
RETRO_DEVICE_ID_JOYPAD_R      = 12
RETRO_DEVICE_ID_JOYPAD_L2     = 13
RETRO_DEVICE_ID_JOYPAD_R2     = 14
RETRO_DEVICE_ID_JOYPAD_L3     = 15
RETRO_DEVICE_ID_JOYPAD_R3     = 16
```

Axis constants:
```
AXIS_LEFT_X  = 1
AXIS_LEFT_Y  = 2
AXIS_RIGHT_X = 3
AXIS_RIGHT_Y = 4
```

---

## Font (type)

Pixel font from image. No TTF support.

### Font:getWidth(text) -> width
Width of text (accounts for newlines, takes max line width).

### Font:setFilter(...)
Stub — no effect (software rendered).

---

## Image (type)

Drawable image.

### Image:getWidth() -> number
### Image:getHeight() -> number
### Image:getDimensions() -> width, height
### Image:getData() -> ImageData (returns reference to self)
### Image:setFilter(...) — stub

---

## Quad (type)

Texture coordinate quadrilateral.

### Quad:setViewport(x, y, w, h)
Set source rectangle on texture.

### Quad:getViewport() -> x, y, w, h
Get source rectangle.

---

## Source (type)

Playable audio.

### Source:setLooping(bool)
### Source:isLooping() -> bool
### Source:isStopped() -> bool
### Source:pause()
### Source:isPaused() -> bool
### Source:isPlaying() -> bool
### Source:setVolume(volume)
### Source:getVolume() -> volume
### Source:seek(position) — jump to position (seconds)
### Source:tell() -> position — current position (seconds)
### Source:setPitch(pitch)
### Source:getPitch() -> pitch
