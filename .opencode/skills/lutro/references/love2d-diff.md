# LÖVE2D → Lutro Differences

Common LÖVE2D APIs that do NOT exist in Lutro, plus notable behavioral differences.

## Entire modules missing

| Module | Notes |
|--------|-------|
| `love.data` | No data hashing/encoding |
| `love.event` | No event pump — use callbacks |
| `love.math` | Use plain Lua `math.*` |
| `love.mouse` | No mouse support in libretro |
| `love.path` | No path object |
| `love.system` | No system info |
| `love.thread` | No threading |
| `love.timer` | No `getTime`, `getFPS`, etc |
| `love.video` | No video playback |
| `love.window` | Use getWidth/getHeight |

## Missing love.graphics functions

| Function | Lutro alternative |
|----------|-------------------|
| `love.graphics.newFont` | Use `love.graphics.newImageFont` (bitmap only) |
| `love.graphics.newText` | Use `print`/`printf` |
| `love.graphics.newMesh` | N/A |
| `love.graphics.newParticleSystem` | N/A |
| `love.graphics.newShader` | N/A — software renderer |
| `love.graphics.newSpriteBatch` | N/A |
| `love.graphics.newVideo` | N/A |
| `love.graphics.arc` | N/A |
| `love.graphics.ellipse` (with arc) | Basic ellipse only |
| `love.graphics.setLineWidth` | N/A |
| `love.graphics.setLineStyle` | N/A |
| `love.graphics.setBlendMode` | N/A |
| `love.graphics.setDefaultFilter` | N/A |
| `love.graphics.setNewFont` | N/A |
| `love.graphics.setWireframe` | N/A |
| `love.graphics.isSupported` | N/A |
| `love.graphics.getDimensions` | Use getWidth/getHeight |
| `love.graphics.getDPIScale` | N/A |
| `love.graphics.getPixelWidth`/`Height` | N/A |
| `love.graphics.getStackDepth` | N/A |
| `love.graphics.getStats` | N/A |
| `love.graphics.getShader` | N/A |
| `love.graphics.getBlendMode` | N/A |
| `love.graphics.getLineWidth`/`Style` | N/A |
| `love.graphics.getPointSize` | N/A |
| `love.graphics.getImageFilter` | N/A |
| `love.graphics.getTextureTypes` | N/A |
| `love.graphics.getSystemLimits` | N/A |
| `love.graphics.captureScreenshot` | N/A |
| `love.graphics.present` | N/A |
| `love.graphics.setPointSize` | N/A |
| `love.graphics.setFrontFaceWinding` | N/A |
| `love.graphics.setColorMask` | N/A |
| `love.graphics.stencil` | N/A |
| `love.graphics.setStencilTest` | N/A |
| `love.graphics.invertStencilTest` | N/A |
| `love.graphics.setMeshCullMode` | N/A |
| `love.graphics.setDepthMode` | N/A |

## Missing love.image functions

| Function | Notes |
|----------|-------|
| `love.image.newCompressedData` | Only PNG via newImageData |
| `love.image.isCompressed` | N/A |
| `love.image.compress` | N/A |
| `love.image.convertPixelFormat` | N/A |
| `love.image.getFormatInfo` | N/A |
| `love.image.getPixelFormatCount` | N/A |
| `love.image.setPixelFormat` | N/A |

## Missing love.audio functions

| Function | Notes |
|----------|-------|
| `love.audio.newSource` with microphone | Only file-based |
| `love.audio.getActiveEffects` | No effects support |
| `love.audio.setEffect` | No effects support |
| `love.audio.getEffect` | No effects support |
| `love.audio.setDopplerEffect` | N/A |
| `love.audio.getDopplerEffect` | N/A |
| `love.audio.getOrientation` | N/A |
| `love.audio.setOrientation` | N/A |
| `love.audio.getPosition` | N/A |
| `love.audio.setPosition` | N/A |
| `love.audio.getVelocity` | N/A |
| `love.audio.setVelocity` | N/A |
| `love.audio.getDistanceModel` | N/A |
| `love.audio.setDistanceModel` | N/A |
| `love.audio.getSourceCount` | Use getActiveSourceCount |
| `love.audio.record` | N/A |
| `love.audio.getRecordedData` | N/A |

## Behavioral differences

| Aspect | LÖVE2D | Lutro |
|--------|--------|-------|
| Fonts | TTF/OTF + bitmap | Bitmap only (newImageFont) |
| Default font | Built-in | None — must provide |
| Renderer | GPU (OpenGL/Vulkan/Metal) | Software rasterizer |
| Coordinate system | (0,0) top-left | Same, but pixel-aligned |
| `Image:setFilter` | Works | Stub |
| `Font:setFilter` | Works | Stub |
| `newImageFont` spacing | Default 0 | Default 1 |
| Audio formats | Many | Only .wav and .ogg |
| Ogg sample rate | Any | **44100 Hz only** (vorbis decoder rejects other rates) |
| Ogg channels | Any | Mono or stereo only |
| Wav sample rate | Any | **44100 Hz** required (non-44100 may play at wrong pitch/speed) |
| Screen size | Configurable window | Libretro viewport |
| Input | keyboard/mouse/joystick/touch | keyboard + joystick only |
| Savestates | N/A | serialize/unserialize callbacks |
| Framerate | Configurable | Fixed ~60fps |
