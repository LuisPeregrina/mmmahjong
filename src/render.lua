local conf = require("conf")
local board = require("board")
local M = {}

M.tileset = nil
M.font = nil
M.quads = {}
M.vw = conf.SCREEN_W
M.vh = conf.SCREEN_H

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
  local gstr = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@,.;/:-"
  M.font_img = love.graphics.newImage("assets/generated/font.png")
  M.font = love.graphics.newImageFont(M.font_img, gstr, 1)
  love.graphics.setFont(M.font)
end

function M.draw_board_background()
  local tw = 14 * conf.TILE_W
  local th = 6 * conf.TILE_H
  local bx = conf.BOARD_CENTER_X - tw / 2
  local by = conf.BOARD_CENTER_Y - th / 2
  local pad = 24

  love.graphics.setColor(60, 40, 20, 255)
  love.graphics.rectangle("fill", bx - pad, by - pad,
    tw + pad * 2, th + pad * 2)

  love.graphics.setColor(100, 70, 30, 255)
  love.graphics.rectangle("fill", bx - pad + 4, by - pad + 4,
    tw + pad * 2 - 8, th + pad * 2 - 8)

  love.graphics.setColor(40, 25, 10, 255)
  love.graphics.rectangle("line", bx - pad + 2, by - pad + 2,
    tw + pad * 2 - 4, th + pad * 2 - 4)
end

function M.draw_layer_cutouts(tiles)
  local above = {}
  for i, t in ipairs(tiles) do
    if not t.removed then
      for j, other in ipairs(tiles) do
        if not other.removed and other.layer > t.layer and other.row == t.row and other.col == t.col then
          above[i] = true
          break
        end
      end
    end
  end

  for i, t in ipairs(tiles) do
    if not t.removed and above[i] then
      local x, y = board.tile_position(t)
      love.graphics.setColor(15, 20, 50, 200)
      love.graphics.rectangle("fill", x + 4, y + 4, conf.TILE_W - 8, conf.TILE_H - 8)
    end
  end
end

function M.draw_board(tiles, highlight_idx, selected_idx)
  M.draw_board_background()
  M.draw_layer_cutouts(tiles)

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
          love.graphics.setColor(255, 255, 0, 120)
          love.graphics.rectangle("fill", x, y, conf.TILE_W, conf.TILE_H)
        end

        if i == selected_idx then
          love.graphics.setColor(0, 255, 0, 160)
          love.graphics.rectangle("fill", x, y, conf.TILE_W, conf.TILE_H)
        end
      end
    end
  end

  love.graphics.setColor(255, 255, 255, 255)
end

function M.text_width(text)
  local width = 0
  local space_width = M.font and M.font:getWidth("I") or 5
  for word, spaces in text:gmatch("([^ ]*)( *)") do
    if word ~= "" then
      width = width + (M.font and M.font:getWidth(word) or #word * 10)
    end
    width = width + #spaces * space_width
  end
  return width
end

function M.draw_text(text, x, y, r, g, b)
  love.graphics.setColor(r or 255, g or 255, b or 255, 255)
  local space_width = M.font and M.font:getWidth("I") or 5
  for word, spaces in text:gmatch("([^ ]*)( *)") do
    if word ~= "" then
      love.graphics.print(word, x, y)
      x = x + (M.font and M.font:getWidth(word) or #word * 10)
    end
    x = x + #spaces * space_width
  end
  love.graphics.setColor(255, 255, 255, 255)
end

function M.draw_center_text(text, y, r, g, b)
  local w = M.text_width(text)
  M.draw_text(text, conf.SCREEN_W / 2 - w / 2, y, r, g, b)
end

function M.draw_center_text_at(screen_w, text, y, r, g, b)
  local w = M.text_width(text)
  M.draw_text(text, screen_w / 2 - w / 2, y, r, g, b)
end

function M.draw_hud(tiles, pairs_removed)
  M.draw_text("Pairs: " .. pairs_removed, 8, 8, 200, 200, 200)
  M.draw_text("H:Hint  Z:Undo  S:Shuffle", 8, M.vh - 16, 160, 160, 160)

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
    local w = M.text_width(msg)
    love.graphics.setColor(255, 220, 0, 255)
    love.graphics.rectangle("fill", M.vw / 2 - w / 2 - 6, M.vh / 2 - 16, w + 12, 24)
    M.draw_text(msg, M.vw / 2 - w / 2, M.vh / 2 - 12, 0, 0, 0)
    love.graphics.setColor(255, 255, 255, 255)
  end
end

function M.draw_game_over(win)
  local msg = win and "YOU WIN!" or "GAME OVER"
  local w = M.text_width(msg)
  love.graphics.setColor(0, 0, 0, 220)
  love.graphics.rectangle("fill", 0, M.vh / 2 - 40, M.vw, 80)
  M.draw_text(msg, M.vw / 2 - w / 2, M.vh / 2 - 12,
    win and 80 or 255, win and 255 or 80, win and 80 or 80)
  love.graphics.setColor(255, 255, 255, 255)
end

return M
