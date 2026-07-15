local conf = require("conf")
local tiles = require("tiles")
local board = require("board")
local cursor = require("cursor")
local render = require("render")

local gamestate = {}
local gs = {}

local SCREEN = "title"
local blink_time = 0
local cam_x, cam_y = 0, 0
local vw, vh = 0, 0

local function update_camera()
  if not cursor.current or not gs.tiles then return end
  local t = gs.tiles[cursor.current]
  if not t or t.removed then return end
  local tx, ty = board.tile_position(t)

  cam_x = tx - vw / 2 + conf.TILE_W / 2
  cam_y = ty - vh / 2 + conf.TILE_H / 2

  local board_w = 14 * conf.TILE_W + 48
  local board_h = 6 * conf.TILE_H + 48
  cam_x = math.max(0, math.min(cam_x, board_w - vw))
  cam_y = math.max(0, math.min(cam_y, board_h - vh))
end

local cam_x, cam_y = 0, 0
local vw, vh = 0, 0

function love.load()
  math.randomseed(os.time())

  vw = love.graphics.getWidth()
  vh = love.graphics.getHeight()
  render.vw = vw
  render.vh = vh

  render.load_assets()
  render.make_font()

  gs.tiles = nil
  gs.pairs_removed = 0
  gs.history = {}
  gs.status_msg = ""
  gs.status_timer = 0
  gs.game_over = false
  gs.won = false
  blink_time = 0
end

function new_game()
  local deck = tiles.create_deck()
  gs.tiles = board.init(deck)
  gs.pairs_removed = 0
  gs.history = {}
  gs.status_msg = ""
  gs.status_timer = 0
  gs.game_over = false
  gs.won = false
  cursor.tiles = gs.tiles
  cursor.init(gs.tiles)
end

function love.update(dt)
  blink_time = blink_time + dt

  if gs.status_timer > 0 then
    gs.status_timer = gs.status_timer - dt
    if gs.status_timer <= 0 then
      gs.status_msg = ""
    end
  end

  if SCREEN == "game" then
    update_camera()
  end
end

function love.draw()
  love.graphics.clear()
  love.graphics.setBackgroundColor(20, 30, 70, 255)

  if SCREEN == "title" then
    render.draw_center_text_at(vw, "MAHJONG SOLITAIRE", vh / 2 - 40, 255, 220, 80)
    render.draw_center_text_at(vw, "Press SPACE or A to start", vh / 2 + 20, 200, 200, 200)

    local blink = math.floor(blink_time * 2) % 2 == 0
    if blink then
      render.draw_center_text_at(vw, "H - Help  S - Shuffle  Z - Undo", vh / 2 + 50, 120, 120, 120)
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

  if gs.status_msg and gs.status_timer > 0 then
    render.draw_status(gs.status_msg)
  end

  if gs.game_over then
    render.draw_game_over(gs.won)
  end
end

function set_status(msg, duration)
  gs.status_msg = msg
  gs.status_timer = duration or 1.5
end

function love.keypressed(key, scode, isrepeat)
  if SCREEN == "title" then
    if key == conf.KEYS.select or key == conf.KEYS.menu then
      SCREEN = "game"
      new_game()
    end
    return
  end

  if gs.game_over then
    if key == conf.KEYS.select or key == conf.KEYS.menu then
      new_game()
    end
    return
  end

  if key == conf.KEYS.up then cursor.move("up")
  elseif key == conf.KEYS.down then cursor.move("down")
  elseif key == conf.KEYS.left then cursor.move("left")
  elseif key == conf.KEYS.right then cursor.move("right")
  elseif key == conf.KEYS.select then
    local result, status = cursor.select()
    if status == "match" then
      local i, j = result[1], result[2]
      board.remove_pair(gs.tiles, i, j)
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
    elseif status == "selected" then
    elseif status == "deselected" then
    end
  elseif key == conf.KEYS.cancel then
    cursor.cancel()
  elseif key == conf.KEYS.undo then
    if #gs.history > 0 then
      local last = gs.history[#gs.history]
      board.restore_pair(gs.tiles, last[1], last[2])
      gs.history[#gs.history] = nil
      gs.pairs_removed = gs.pairs_removed - 1
      cursor.reset()
      cursor.tiles = gs.tiles
      cursor.init(gs.tiles)
      set_status("Undo", 1.0)
    end
  elseif key == conf.KEYS.hint then
    local a, b = board.find_hint(gs.tiles)
    if a then
      cursor.set_selected(a)
      set_status("Hint!", 1.5)
    else
      set_status("No hint available", 1.0)
    end
  elseif key == conf.KEYS.shuffle then
    local remaining = {}
    for i, t in ipairs(gs.tiles) do
      if not t.removed then
        remaining[#remaining + 1] = i
      end
    end
    local types = {}
    for _, idx in ipairs(remaining) do
      types[#types + 1] = gs.tiles[idx].type
    end
    for i = #types, 2, -1 do
      local j = math.random(i)
      types[i], types[j] = types[j], types[i]
    end
    for k, idx in ipairs(remaining) do
      gs.tiles[idx].type = types[k]
    end
    cursor.reset()
    cursor.tiles = gs.tiles
    cursor.init(gs.tiles)
    set_status("Shuffled!", 1.0)
  end
end

function love.gamepadpressed(port, button)
  local key
  if button == "up" then key = conf.KEYS.up
  elseif button == "down" then key = conf.KEYS.down
  elseif button == "left" then key = conf.KEYS.left
  elseif button == "right" then key = conf.KEYS.right
  elseif button == "a" then key = conf.KEYS.select
  elseif button == "b" then key = conf.KEYS.cancel
  end
  if key then love.keypressed(key, 0, false) end
end

function love.serializeSize()
  return 1024 * 8
end

function love.serialize(size)
  local out = {}
  for _, t in ipairs(gs.tiles) do
    out[#out + 1] = tostring(t.id) .. ":" .. tostring(t.removed)
  end
  return table.concat(out, ",")
end

function love.unserialize(data, size)
  new_game()
  local parts = {}
  for v in data:gmatch("[^,]+") do
    parts[#parts + 1] = v
  end
  for i, p in ipairs(parts) do
    local id_str, rem_str = p:match("^(%d+):(%a+)$")
    if id_str and rem_str and gs.tiles[i] then
      gs.tiles[i].removed = (rem_str == "true")
    end
  end
end
