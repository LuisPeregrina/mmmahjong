local conf = require("conf")
local board = require("board")
local M = {}

M.tileset = nil
M.font = nil
M.quads = {}

function M.load_assets()
  M.tileset = love.graphics.newImage("assets/generated/tiles.png")
  for i, tt in ipairs(conf.TILE_TYPES) do
    local col = (i - 1) % conf.SPRITE_COLS
    local row = math.floor((i - 1) / conf.SPRITE_COLS)
    M.quads[tt] = love.graphics.newQuad(
      col * conf.TILE_W, row * conf.TILE_H,
      conf.TILE_W, conf.TILE_H,
      M.tileset:getWidth(), M.tileset:getHeight())
  end
end

function M.make_font()
  local gstr = [[ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~]]
  local gw, gh = 8, 10
  local cols = 16
  local rows = math.ceil(#gstr / cols)
  local iw, ih = cols * gw, rows * gh

  local data = love.image.newImageData(iw, ih)
  for y = 0, ih - 1 do
    for x = 0, iw - 1 do
      data:setPixel(x, y, 0, 0, 0, 255)
    end
  end

  local function sp(x, y)
    if x >= 0 and x < iw and y >= 0 and y < ih then
      data:setPixel(x, y, 255, 255, 255, 255)
    end
  end

  local gl = {}
  local function gd(ch, dots) gl[ch] = dots end

  gd(" ", {})
  gd("!", {{3,0},{3,1},{3,2},{3,3},{3,4},{3,5}})
  gd("?", {{1,0},{5,0},{7,1},{7,2},{5,3},{3,4},{3,5},{3,7}})
  gd(".", {{3,7},{3,8}})
  gd(",", {{3,7},{3,8},{4,9}})
  gd(":", {{3,2},{3,3},{3,6},{3,7}})
  gd(";", {{3,2},{3,3},{3,6},{3,7},{4,8}})
  gd("-", {{1,4},{6,4}})
  gd("+", {{2,2},{2,3},{1,4},{2,4},{3,4},{2,5},{2,6}})
  gd("0", {{1,0},{2,0},{3,0},{4,0},{5,0},{0,0},{6,0},{0,1},{6,1},{0,2},{6,2},{0,3},{6,3},{0,4},{6,4},{0,5},{6,5},{0,6},{6,6},{0,7},{6,7},{1,8},{2,8},{3,8},{4,8},{5,8}})
  gd("1", {{3,0},{2,1},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{3,7},{3,8}})
  gd("2", {{1,0},{2,0},{3,0},{4,0},{5,1},{6,2},{5,3},{2,4},{3,4},{4,4},{1,5},{0,6},{0,7},{1,7},{2,7},{3,7},{4,7},{5,7},{6,7}})
  gd("3", {{1,0},{2,0},{3,0},{4,0},{5,1},{6,2},{5,3},{3,4},{5,5},{6,6},{5,7},{1,8},{2,8},{3,8},{4,8}})
  gd("4", {{4,0},{4,1},{4,2},{4,3},{4,4},{4,5},{4,6},{4,7},{4,8},{0,5},{1,5},{2,5},{3,5},{5,5},{6,5}})
  gd("5", {{0,0},{1,0},{2,0},{3,0},{4,0},{5,0},{6,0},{0,1},{0,2},{0,3},{0,4},{1,4},{2,4},{3,4},{4,4},{5,4},{5,5},{6,6},{5,7},{1,8},{2,8},{3,8},{4,8}})
  gd("6", {{2,0},{3,0},{4,0},{1,1},{5,2},{0,3},{1,3},{0,4},{1,4},{2,4},{3,4},{4,4},{5,4},{0,5},{5,5},{0,6},{5,6},{0,7},{1,7},{2,7},{3,7},{4,7}})
  gd("7", {{0,0},{1,0},{2,0},{3,0},{4,0},{5,0},{6,0},{6,1},{5,2},{4,3},{4,4},{4,5},{4,6},{4,7}})
  gd("8", {{1,0},{2,0},{3,0},{4,0},{0,1},{5,1},{0,2},{5,2},{1,3},{2,3},{3,3},{4,3},{0,4},{5,4},{0,5},{5,5},{0,6},{5,6},{0,7},{5,7},{1,8},{2,8},{3,8},{4,8}})
  gd("9", {{1,0},{2,0},{3,0},{4,0},{0,1},{5,1},{0,2},{5,2},{0,3},{5,3},{1,4},{2,4},{3,4},{4,4},{5,4},{5,5},{4,6},{3,7},{1,8},{2,8},{3,8},{4,8}})
  gd("=", {{1,3},{6,3},{1,5},{6,5}})
  gd("/", {{6,0},{5,1},{4,2},{3,3},{2,4},{1,5},{0,6}})
  gd("(", {{4,0},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{4,7}})
  gd(")", {{2,0},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{2,7}})
  gd("a", {{2,2},{3,2},{4,2},{1,3},{5,3},{0,4},{5,4},{1,5},{2,5},{3,5},{4,5}})
  gd("b", {{0,0},{0,1},{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{0,8},{1,2},{2,2},{3,2},{4,2},{4,3},{4,4},{3,5},{2,5},{1,5}})
  gd("c", {{1,2},{2,2},{3,2},{4,2},{0,3},{0,4},{0,5},{0,6},{0,7},{1,7},{2,7},{3,7},{4,7}})
  gd("d", {{6,0},{6,1},{6,2},{6,3},{6,4},{6,5},{6,6},{6,7},{6,8},{1,2},{2,2},{3,2},{4,2},{5,2},{5,3},{5,4},{4,5},{3,5},{2,5},{1,5}})
  gd("e", {{1,2},{2,2},{3,2},{4,2},{0,3},{0,4},{0,5},{0,6},{0,7},{1,7},{2,7},{3,7},{4,4},{5,4}})
  gd("f", {{4,0},{3,1},{3,2},{3,3},{0,3},{1,3},{2,3},{4,3},{5,3},{6,3},{3,4},{3,5},{3,6},{3,7},{3,8}})
  gd("g", {{2,2},{3,2},{4,2},{1,3},{5,3},{0,4},{5,4},{1,5},{2,5},{3,5},{4,5},{5,6},{4,7},{2,8},{3,8}})
  gd("h", {{0,0},{0,1},{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{0,8},{0,2},{1,2},{2,2},{3,2},{4,2},{5,2},{5,3},{5,4},{5,5},{5,6},{5,7},{5,8}})
  gd("i", {{3,0},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{3,7},{3,8}})
  gd("j", {{5,0},{5,1},{5,2},{5,3},{5,4},{5,5},{5,6},{5,7},{4,8},{3,8},{2,8}})
  gd("k", {{0,0},{0,1},{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{0,8},{4,2},{3,3},{2,4},{1,5},{2,6},{3,7},{4,8}})
  gd("l", {{0,0},{0,1},{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{0,8},{1,8},{2,8},{3,8},{4,8},{5,8}})
  gd("m", {{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{1,2},{2,2},{3,2},{4,2},{5,2},{6,2},{6,3},{6,4},{6,5},{6,6},{6,7}})
  gd("n", {{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{0,8},{1,2},{2,2},{3,2},{4,2},{5,2},{5,3},{5,4},{5,5},{5,6},{5,7},{5,8}})
  gd("o", {{1,2},{2,2},{3,2},{4,2},{0,3},{5,3},{0,4},{5,4},{0,5},{5,5},{0,6},{5,6},{1,7},{2,7},{3,7},{4,7}})
  gd("p", {{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{0,8},{1,2},{2,2},{3,2},{4,2},{4,3},{4,4},{3,5},{2,5},{1,5}})
  gd("q", {{2,2},{3,2},{4,2},{1,3},{5,3},{0,4},{5,4},{0,5},{5,5},{0,6},{5,6},{1,7},{2,7},{3,7},{4,7},{5,8}})
  gd("r", {{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{0,8},{1,2},{2,2},{3,2},{4,2},{4,3},{3,4},{2,5}})
  gd("s", {{1,2},{2,2},{3,2},{4,2},{0,3},{0,4},{1,4},{2,4},{3,5},{4,6},{5,6},{5,7},{1,7},{2,7},{3,7},{4,7}})
  gd("t", {{3,0},{3,1},{3,2},{3,3},{0,3},{1,3},{2,3},{4,3},{5,3},{6,3},{3,4},{3,5},{3,6},{3,7}})
  gd("u", {{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{5,2},{5,3},{5,4},{5,5},{5,6},{5,7},{1,8},{2,8},{3,8},{4,8}})
  gd("v", {{0,2},{0,3},{0,4},{0,5},{0,6},{6,2},{6,3},{6,4},{6,5},{6,6},{1,7},{5,7},{2,8},{4,8},{3,9}})
  gd("w", {{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{6,2},{6,3},{6,4},{6,5},{6,6},{6,7},{1,6},{5,6},{2,5},{4,5},{3,4}})
  gd("x", {{0,2},{5,2},{1,3},{4,3},{2,4},{3,4},{1,5},{4,5},{0,6},{5,6}})
  gd("y", {{0,2},{0,3},{0,4},{0,5},{0,6},{6,2},{6,3},{6,4},{6,5},{6,6},{1,7},{5,7},{2,8},{4,8},{3,9}})
  gd("z", {{0,2},{1,2},{2,2},{3,2},{4,2},{5,2},{6,2},{6,3},{5,4},{4,5},{2,6},{1,7},{0,8},{1,8},{2,8},{3,8},{4,8},{5,8},{6,8}})

  for i = 1, #gstr do
    local ch = gstr:sub(i, i)
    local d = gl[ch]
    if d then
      local r = math.floor((i - 1) / cols)
      local c = (i - 1) % cols
      local ox, oy = c * gw, r * gh
      for _, p in ipairs(d) do
        sp(ox + p[1], oy + p[2])
      end
    end
  end

  M.font_img = love.graphics.newImage(data)
  M.font = love.graphics.newImageFont(M.font_img, gstr, 1)
  love.graphics.setFont(M.font)
end

function M.draw_board(tiles, highlight_idx)
  for l = 1, conf.MAX_LAYERS do
    for i, t in ipairs(tiles) do
      if not t.removed and t.layer == l then
        local x, y = board.tile_position(t)
        local ok = board.is_free(tiles, i)

        if ok then
          love.graphics.setColor(255, 255, 255, 255)
        else
          love.graphics.setColor(80, 80, 80, 180)
        end

        love.graphics.draw(M.tileset, M.quads[t.type], x, y)

        if i == highlight_idx then
          love.graphics.setColor(255, 255, 0, 160)
          love.graphics.rectangle("fill", x, y, conf.TILE_W, conf.TILE_H)
        end
      end
    end
  end
  love.graphics.setColor(255, 255, 255, 255)
end

function M.draw_text(text, x, y, r, g, b)
  love.graphics.setColor(r or 255, g or 255, b or 255, 255)
  love.graphics.print(text, x, y)
  love.graphics.setColor(255, 255, 255, 255)
end

function M.draw_center_text(text, y, r, g, b)
  local w = M.font and M.font:getWidth(text) or #text * 10
  M.draw_text(text, conf.SCREEN_W / 2 - w / 2, y, r, g, b)
end

function M.draw_hud(tiles, pairs_removed)
  M.draw_text("Pairs: " .. pairs_removed, 8, 8, 200, 200, 200)
  M.draw_text("H:Hint  Z:Undo  S:Shuffle", 8, conf.SCREEN_H - 16, 160, 160, 160)

  if M.tiles_left then
    local left = 0
    for _, t in ipairs(tiles) do
      if not t.removed then left = left + 1 end
    end
    M.draw_text("Tiles: " .. left, 8, 20, 200, 200, 200)
  end
end

function M.draw_status(msg)
  if msg then
    local w = M.font and M.font:getWidth(msg) or #msg * 10
    love.graphics.setColor(255, 220, 0, 255)
    love.graphics.rectangle("fill", conf.SCREEN_W / 2 - w / 2 - 6, conf.SCREEN_H / 2 - 16, w + 12, 24)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print(msg, conf.SCREEN_W / 2 - w / 2, conf.SCREEN_H / 2 - 12)
    love.graphics.setColor(255, 255, 255, 255)
  end
end

function M.draw_game_over(win)
  local msg = win and "YOU WIN!" or "GAME OVER"
  local w = M.font and M.font:getWidth(msg) or #msg * 10
  love.graphics.setColor(0, 0, 0, 220)
  love.graphics.rectangle("fill", 0, conf.SCREEN_H / 2 - 40, conf.SCREEN_W, 80)
  love.graphics.setColor(win and 80 or 255, win and 255 or 80, win and 80 or 80, 255)
  love.graphics.print(msg, conf.SCREEN_W / 2 - w / 2, conf.SCREEN_H / 2 - 12)
  love.graphics.setColor(255, 255, 255, 255)
end

return M
