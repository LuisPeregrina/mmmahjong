local conf = require("conf")
local board = require("board")
local cursor = require("cursor")
local M = {}

M.tileset = nil
M.font = nil
M.quads = {}
M.blocked_quad = nil
M.vw = conf.SCREEN_W
M.vh = conf.SCREEN_H

--- Load Lutro image assets and create sprite-sheet quads for each tile type.
function M.load_assets()
  M.tileset = love.graphics.newImage("assets/generated/tiles.png")
  for i, tt in ipairs(conf.TILE_TYPES) do
    local col = (i - 1) % conf.SPRITE_COLS
    local row = math.floor((i - 1) / conf.SPRITE_COLS)
    M.quads[tt] = love.graphics.newQuad(
      col * conf.TILE_W, row * conf.TILE_H,
      conf.TILE_W, conf.TILE_H,
      M.tileset:getDimensions()
    )
  end

  local blocked_col = 42 % conf.SPRITE_COLS
  local blocked_row = math.floor(42 / conf.SPRITE_COLS)
  M.blocked_quad = love.graphics.newQuad(
    blocked_col * conf.TILE_W, blocked_row * conf.TILE_H,
    conf.TILE_W, conf.TILE_H,
    M.tileset:getDimensions()
  )
end

--- Load generated bitmap font required by Lutro's image-font renderer.
function M.make_font()
  local gstr = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@,.;/:-"
  M.font_img = love.graphics.newImage("assets/generated/font.png")
  M.font = love.graphics.newImageFont(M.font_img, gstr, 1)
  M.font_height = M.font_img:getHeight()
  love.graphics.setFont(M.font)
end

--- Draw wooden playing surface behind fixed board layout.
function M.draw_board_background()
  local tw = 14 * conf.TILE_SPACING_X + conf.TILE_W - conf.TILE_SPACING_X
  local th = 6 * conf.TILE_SPACING_Y + conf.TILE_H - conf.TILE_SPACING_Y
  local bx = conf.BOARD_CENTER_X - tw / 2
  local by = conf.BOARD_CENTER_Y - th / 2
  local pad = 24

  love.graphics.setColor(conf.COLORS.board_outer)
  love.graphics.rectangle("fill", bx - pad, by - pad,
    tw + pad * 2, th + pad * 2)

  love.graphics.setColor(conf.COLORS.board_inner)
  love.graphics.rectangle("fill", bx - pad + 4, by - pad + 4,
    tw + pad * 2 - 8, th + pad * 2 - 8)

  love.graphics.setColor(conf.COLORS.board_border)
  love.graphics.rectangle("line", bx - pad + 2, by - pad + 2,
    tw + pad * 2 - 4, th + pad * 2 - 4)
end

--- Draw recessed marks where higher tiles obscure lower tiles.
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
      love.graphics.setColor(conf.COLORS.shadow)
      love.graphics.rectangle("fill", x + 4, y + 4, conf.TILE_W - 8, conf.TILE_H - 8)
    end
  end
end

--- Draw board tiles from lowest to highest layer and cursor overlays.
function M.draw_board(tiles, highlight_idx, selected_idx)
  M.draw_board_background()
  M.draw_layer_cutouts(tiles)

  for l = 1, conf.MAX_LAYERS do
    for i, t in ipairs(tiles) do
      if not t.removed and t.layer == l then
        local x, y = board.tile_position(t)
        local blocked_above = not board.is_free(tiles, i, true)
        love.graphics.setColor(conf.COLORS.tile_light)
        love.graphics.draw(M.tileset, M.quads[t.type], x, y)

        if blocked_above then
          love.graphics.setColor(conf.COLORS.tile_dark)
          love.graphics.rectangle("fill", x, y, conf.TILE_W, conf.TILE_H)
        end
        if i == highlight_idx then
          love.graphics.setColor(conf.COLORS.cursor)
          love.graphics.rectangle("fill", x, y, conf.TILE_W, conf.TILE_H)
        end

        if i == selected_idx then
          love.graphics.setColor(conf.COLORS.selected)
          love.graphics.rectangle("fill", x, y, conf.TILE_W, conf.TILE_H)
        end

        if cursor.hint_idx and i == cursor.hint_idx then
          local blink = math.floor(love.timer.getTime() * 4) % 2 == 0
          if blink then
            love.graphics.setColor(conf.COLORS.hint_outline)
            love.graphics.rectangle("line", x - 2, y - 2, conf.TILE_W + 4, conf.TILE_H + 4, 3)
          end
        end
      end
    end
  end

  love.graphics.setColor(conf.COLORS.tile_light)
end

--- Return bitmap-font width while preserving manually rendered spaces.
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

--- Draw bitmap text with optional RGB color and reliable space width.
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
  love.graphics.setColor(conf.COLORS.tile_light)
end

--- Draw text centered in current Lutro viewport.
function M.draw_center_text(text, y, r, g, b)
  local w = M.text_width(text)
  M.draw_text(text, M.vw / 2 - w / 2, y, r, g, b)
end

--- Draw pair count, remaining tile count, and control reminder.
function M.draw_hud(tiles, pairs_removed)
  local fh = M.font_height
  M.draw_text("Pairs: " .. pairs_removed, 8, 2, unpack(conf.COLORS.hud_text))

  local left = 0
  for _, tile in ipairs(tiles) do
    if not tile.removed then
      left = left + 1
    end
  end
  M.draw_text("Tiles: " .. left, 8, 2 + fh, unpack(conf.COLORS.hud_text))

  if M.vw < 600 then
    M.draw_text("R1=Hint L1=Undo", 8, M.vh - fh * 2 + 2, unpack(conf.COLORS.control_text))
    M.draw_text("R2=Shuff", 8, M.vh - fh + 2, unpack(conf.COLORS.control_text))
  else
    M.draw_text("R1:Hint  L1:Undo  R2:Shuff  Start:Menu", 8, M.vh - fh - 2, unpack(conf.COLORS.control_text))
  end
end

--- Draw transient centered status notification.
function M.draw_status(msg)
  if msg then
    local fh = M.font_height
    local w = M.text_width(msg)
    love.graphics.setColor(conf.COLORS.status_bg)
    love.graphics.rectangle("fill", M.vw / 2 - w / 2 - 6, M.vh / 2 - fh - 6, w + 12, fh + 10)
    M.draw_text(msg, M.vw / 2 - w / 2, M.vh / 2 - fh / 2 - 2, unpack(conf.COLORS.status_text))
    love.graphics.setColor(conf.COLORS.tile_light)
  end
end

--- Draw final win or no-moves overlay.
function M.draw_game_over(win)
  local fh = M.font_height
  local msg = win and "YOU WIN!" or "GAME OVER"
  local w = M.text_width(msg)
  local bar_h = fh + 24
  love.graphics.setColor(conf.COLORS.overlay)
  love.graphics.rectangle("fill", 0, M.vh / 2 - bar_h / 2, M.vw, bar_h)
  M.draw_text(msg, M.vw / 2 - w / 2, M.vh / 2 - fh / 2 - 2,
    unpack(win and conf.COLORS.win_text or conf.COLORS.lose_text))
  love.graphics.setColor(conf.COLORS.tile_light)
end

return M
