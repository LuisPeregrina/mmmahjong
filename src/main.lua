local conf = require("conf")
local tiles = require("tiles")
local board = require("board")
local cursor = require("cursor")
local render = require("render")

local gs = {}

local SCREEN = "title"
local input_depth = 0
local blink_time = 0
local cam_x, cam_y = 0, 0
local cam_target_x, cam_target_y = 0, 0
local vw, vh = 0, 0
local CAM_SPEED = 6
local music = {}
local music_playing = nil
local sfx_cursor = nil

--- Start named music track, stopping current track when it changes.
local function play_music(name)
  if music_playing and music_playing ~= name then
    local prev = music[music_playing]
    if prev then
      love.audio.stop(prev)
    end
  end
  local src = music[name]
  if src then
    love.audio.play(src)
    music_playing = name
  end
end

--- Smoothly center camera on currently focused tile within board bounds.
local function update_camera(dt)
  if not cursor.current or not gs.tiles then return end
  local t = gs.tiles[cursor.current]
  if not t or t.removed then return end
  local tx, ty = board.tile_position(t)

  cam_target_x = tx - vw / 2 + conf.TILE_W / 2
  cam_target_y = ty - vh / 2 + conf.TILE_H / 2

  local board_w = 14 * conf.TILE_W + 48
  local board_h = 6 * conf.TILE_H + 48
  local max_x = math.max(0, board_w - vw)
  local max_y = math.max(0, board_h - vh)
  if max_x <= 0 then cam_target_x = 0 end
  if max_y <= 0 then cam_target_y = 0 end
  cam_target_x = math.max(0, math.min(cam_target_x, max_x))
  cam_target_y = math.max(0, math.min(cam_target_y, max_y))

  local dx = cam_target_x - cam_x
  local dy = cam_target_y - cam_y
  local dist = math.sqrt(dx * dx + dy * dy)
  if dist < 0.5 then
    cam_x, cam_y = cam_target_x, cam_target_y
  else
    local speed = math.min(CAM_SPEED, dist * 1.5)
    cam_x = cam_x + dx * dt * speed
    cam_y = cam_y + dy * dt * speed
  end
end

--- Initialize cursor against current board and reset camera position.
local function reset_navigation()
  cursor.init(gs.tiles)
  cam_x, cam_y = 0, 0
  cam_target_x, cam_target_y = 0, 0
end

--- Reset all per-game state while retaining loaded assets and viewport.
local function reset_game_state()
  gs.pairs_removed = 0
  gs.history = {}
  gs.status_msg = ""
  gs.status_timer = 0
  gs.hint_timer = nil
  gs.game_over = false
  gs.won = false
end

--- Show a timed status message.
local function set_status(message, duration)
  gs.status_msg = message
  gs.status_timer = duration or 1.5
end

--- Create and display a new randomized board.
local function new_game()
  gs.tiles = board.init(tiles.create_deck())
  reset_game_state()
  reset_navigation()
  if board.no_moves_left(gs.tiles) then
    gs.game_over = true
    gs.won = false
    set_status("No moves! Try shuffle", 3.0)
  end
end

--- Configure Lutro's fixed logical framebuffer before startup callbacks.
function love.conf(t)
  t.width = conf.SCREEN_W
  t.height = conf.SCREEN_H
end

--- Load Lutro assets and initialize title-screen state.
function love.load()
  math.randomseed(os.time())

  love.graphics.setDefaultFilter("nearest", "nearest", 0)
  love.graphics.setBackgroundColor(conf.COLORS.bg)

  vw = love.graphics.getWidth()
  vh = love.graphics.getHeight()
  render.vw = vw
  render.vh = vh

  render.load_assets()
  render.make_font()
  love.audio.setVolume(1)
  music.title = love.audio.newSource("assets/music/Lotus Pond - Loop.ogg", "stream")
  music.game = love.audio.newSource("assets/music/Dragon Dance - Loop.ogg", "stream")
  sfx_cursor = love.audio.newSource("assets/sounds/ceramic.wav", "static")
  play_music("title")

  gs.tiles = nil
  reset_game_state()
  blink_time = 0
end

--- Advance animation timers and camera state once per frame.
function love.update(dt)
  blink_time = blink_time + dt

  if gs.status_timer and gs.status_timer > 0 then
    gs.status_timer = gs.status_timer - dt
    if gs.status_timer <= 0 then
      gs.status_msg = ""
    end
  end

  if gs.hint_timer and gs.hint_timer > 0 then
    gs.hint_timer = gs.hint_timer - dt
    if gs.hint_timer <= 0 then
      gs.hint_timer = nil
      cursor.clear_hint()
    end
  end

  if SCREEN == "game" then
    update_camera(dt)
  end
end

--- Draw title screen or active game frame.
function love.draw()
  love.graphics.clear()
  if SCREEN == "title" then
    render.draw_center_text("MAHJONG SOLITAIRE", vh / 2 - 40, unpack(conf.COLORS.title_text))
    render.draw_center_text("Press X or A to start", vh / 2 + 20, unpack(conf.COLORS.title_sub))

    local blink = math.floor(blink_time * 2) % 2 == 0
    if blink then
      render.draw_center_text("R1:Hint  L1:Undo  R2:Shuff  Start:Restart", vh / 2 + 50, unpack(conf.COLORS.title_hint))
    end
    return
  end

  love.graphics.push()
  love.graphics.translate(-cam_x, -cam_y)

  if gs.tiles then
    local sel = (cursor.state == "one_selected" and cursor.selected) or nil
    render.draw_board(gs.tiles, cursor.current, sel)
  end

  love.graphics.pop()

  render.draw_hud(gs.tiles, gs.pairs_removed)

  if gs.status_msg and gs.status_timer and gs.status_timer > 0 then
    render.draw_status(gs.status_msg)
  end

  if gs.game_over then
    render.draw_game_over(gs.won)
  end
end

--- Handle keyboard input for title and active game states.
function love.keypressed(key, scode, isrepeat)
  if input_depth > 0 then return end
  input_depth = input_depth + 1

  local function done()
    input_depth = input_depth - 1
  end

  if SCREEN == "title" then
    if key == conf.KEYS.select or key == conf.KEYS.menu then
      SCREEN = "game"
      new_game()
      play_music("game")
    end
    done(); return
  end

  if gs.game_over then
    if key == conf.KEYS.select or key == conf.KEYS.menu then
      new_game()
    elseif key == conf.KEYS.undo and #gs.history > 0 then
      local last = gs.history[#gs.history]
      board.restore_pair(gs.tiles, last[1], last[2])
      gs.history[#gs.history] = nil
      gs.pairs_removed = gs.pairs_removed - 1
      gs.game_over = false
      gs.won = false
      reset_navigation()
      set_status("Undo", 1.0)
    elseif key == conf.KEYS.shuffle then
      local remaining = {}
      local types = {}
      for i, tile in ipairs(gs.tiles) do
        if not tile.removed then
          remaining[#remaining + 1] = i
          types[#types + 1] = tile.type
        end
      end
      tiles.shuffle(types)
      for index, tile_index in ipairs(remaining) do
        gs.tiles[tile_index].type = types[index]
      end
      gs.game_over = false
      gs.won = false
      reset_navigation()
      set_status("Shuffled!", 1.0)
    end
    done(); return
  end

  if key == conf.KEYS.up then
    cursor.move("up")
    love.audio.play(sfx_cursor)
  elseif key == conf.KEYS.down then
    cursor.move("down")
    love.audio.play(sfx_cursor)
  elseif key == conf.KEYS.left then
    cursor.move("left")
    love.audio.play(sfx_cursor)
  elseif key == conf.KEYS.right then
    cursor.move("right")
    love.audio.play(sfx_cursor)
  elseif key == conf.KEYS.select then
    local result, status = cursor.select()
    if status == "match" then
      local i, j = result[1], result[2]
      board.remove_pair(gs.tiles, i, j)
      cursor.ensure_current()
      gs.pairs_removed = gs.pairs_removed + 1
      gs.history[#gs.history + 1] = { i, j }

      set_status("Match!", 1.0)

      if board.all_cleared(gs.tiles) then
        gs.won = true
        gs.game_over = true
      elseif board.no_moves_left(gs.tiles) then
        gs.game_over = true
        gs.won = false
        set_status("No moves left!", 2.0)
      end
    elseif status == "mismatch" then
      set_status("No match", 0.8)
    elseif status == "blocked" then
      set_status("Tile blocked!", 0.8)
    end
  elseif key == conf.KEYS.cancel then
    cursor.cancel()
  elseif key == conf.KEYS.undo then
    if #gs.history > 0 then
      local last = gs.history[#gs.history]
      board.restore_pair(gs.tiles, last[1], last[2])
      gs.history[#gs.history] = nil
      gs.pairs_removed = gs.pairs_removed - 1
      reset_navigation()
      set_status("Undo", 1.0)
    end
  elseif key == conf.KEYS.hint then
    local a, b = board.find_hint(gs.tiles)
    if a then
      if cursor.state == "idle" then
        cursor.set_selected(a)
      end
      cursor.set_hint(b)
      gs.hint_timer = 2.0
      set_status("Hint!", 1.5)
    else
      set_status("No hint available", 1.0)
    end
  elseif key == conf.KEYS.shuffle then
    local remaining = {}
    local types = {}
    for i, tile in ipairs(gs.tiles) do
      if not tile.removed then
        remaining[#remaining + 1] = i
        types[#types + 1] = tile.type
      end
    end
    tiles.shuffle(types)
    for index, tile_index in ipairs(remaining) do
      gs.tiles[tile_index].type = types[index]
    end
    reset_navigation()
    set_status("Shuffled!", 1.0)
  end
  done()
end

--- Translate Lutro gamepad buttons into keyboard actions.
function love.gamepadpressed(port, button)
  local key
  if button == "up" or button == conf.GPAD.up then key = conf.KEYS.up
  elseif button == "down" or button == conf.GPAD.down then key = conf.KEYS.down
  elseif button == "left" or button == conf.GPAD.left then key = conf.KEYS.left
  elseif button == "right" or button == conf.GPAD.right then key = conf.KEYS.right
  elseif button == "a" or button == conf.GPAD.a then key = conf.KEYS.select
  elseif button == "b" or button == conf.GPAD.b then key = conf.KEYS.cancel
  elseif button == "start" or button == conf.GPAD.start or button == conf.GPAD.r1 then
    key = conf.KEYS.menu
  elseif button == conf.GPAD.l1 then key = conf.KEYS.undo
  elseif button == conf.GPAD.l2 then key = conf.KEYS.shuffle
  elseif button == conf.GPAD.r2 then key = conf.KEYS.hint
  end
  if key then love.keypressed(key, 0, false) end
end

--- Return maximum serialized savestate byte size expected by Lutro.
function love.serializeSize()
  return 1024 * 8
end

--- Serialize board types and removal state for Lutro savestates.
function love.serialize(size)
  if not gs.tiles then
    return ""
  end

  local out = {}
  for _, t in ipairs(gs.tiles) do
    out[#out + 1] = t.type .. ":" .. (t.removed and "1" or "0")
  end
  out[#out + 1] = gs.won and "won:1" or "won:0"
  return table.concat(out, ",")
end

--- Restore board types and removal state from a Lutro savestate.
function love.unserialize(data, size)
  if data == "" then
    SCREEN = "title"
    return
  end

  new_game()
  local removed_count = 0
  local index = 0
  local end_marker = false
  for entry in data:gmatch("[^,]+") do
    if entry == "won:1" then
      gs.won = true
      gs.game_over = true
      end_marker = true
    elseif entry == "won:0" then
      gs.won = false
      gs.game_over = false
      end_marker = true
    else
      index = index + 1
      local tile_type, removed = entry:match("^([%a_]+):([01])$")
      if tile_type and removed and gs.tiles[index] then
        gs.tiles[index].type = tile_type
        gs.tiles[index].removed = removed == "1"
        if gs.tiles[index].removed then
          removed_count = removed_count + 1
        end
      end
    end
  end
  gs.pairs_removed = removed_count / 2
  SCREEN = "game"
  if not end_marker then
    if board.all_cleared(gs.tiles) then
      gs.won = true
      gs.game_over = true
    elseif board.no_moves_left(gs.tiles) then
      gs.game_over = true
      gs.won = false
    end
  end
  reset_navigation()
  play_music("game")
end
