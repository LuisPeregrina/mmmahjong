local conf = require("conf")
local tileset = require("tiles")
local M = {}

-- Compact four-layer layout: 84 + 48 + 10 + 2 = 144 positions.
local LAYER_CONFIG = {
  { rows = 6, cols = 14, row_offset = 0, col_offset = 0 },
  { rows = 4, cols = 12, row_offset = 1, col_offset = 1 },
  { rows = 2, cols = 5, row_offset = 2, col_offset = 4 },
  { rows = 1, cols = 2, row_offset = 3, col_offset = 6 },
}

--- Append positions for one rectangular layer to a layout.
local function append_layer(layout, layer, config)
  for row = 0, config.rows - 1 do
    for col = 0, config.cols - 1 do
      layout[#layout + 1] = {
        layer = layer,
        row = config.row_offset + row,
        col = config.col_offset + col,
      }
    end
  end
end

local LAYOUT = {}
for layer, config in ipairs(LAYER_CONFIG) do
  append_layer(LAYOUT, layer, config)
end

assert(#LAYOUT == conf.NUM_TILES, "Layout tile count must match deck size")

--- Return a tile's top-left pixel coordinate.
function M.tile_position(pos)
  local tw = conf.TILE_W
  local th = conf.TILE_H
  local ldx = pos.layer * conf.LAYER_DX
  local ldy = pos.layer * conf.LAYER_DY

  local total_cols = 14
  local gx = (pos.col - (total_cols - 1) / 2) * tw
  local gy = (pos.row - (6 - 1) / 2) * th

  local cx = conf.BOARD_CENTER_X + gx + ldx
  local cy = conf.BOARD_CENTER_Y + gy + ldy
  return cx, cy
end

--- Build board tiles by assigning shuffled deck entries to fixed positions.
function M.init(deck)
  local tiles = {}
  for i, pos in ipairs(LAYOUT) do
    local d = deck[i]
    tiles[i] = {
      type = d.type,
      id = d.id,
      layer = pos.layer,
      row = pos.row,
      col = pos.col,
      removed = false,
    }
  end
  return tiles
end

local function tile_rect(t)
  local total_cols = 14
  local gx = (t.col - (total_cols - 1) / 2) * conf.TILE_W
  local gy = (t.row - (6 - 1) / 2) * conf.TILE_H
  local x = conf.BOARD_CENTER_X + gx + t.layer * conf.LAYER_DX
  local y = conf.BOARD_CENTER_Y + gy + t.layer * conf.LAYER_DY
  return x, y, x + conf.TILE_W - 1, y + conf.TILE_H - 1
end

local function rects_overlap(l1x, l1y, l1x2, l1y2, l2x, l2y, l2x2, l2y2)
  return l1x < l2x2 and l1x2 > l2x and l1y < l2y2 and l1y2 > l2y
end

--- Return whether tile has no tile above and an open left or right side.
function M.is_free(tiles, idx)
  local t = tiles[idx]
  if t.removed then return false end

  local tx, ty, tx2, ty2 = tile_rect(t)

  for _, other in ipairs(tiles) do
    if not other.removed and other.layer > t.layer then
      local ox, oy, ox2, oy2 = tile_rect(other)
      if rects_overlap(tx, ty, tx2, ty2, ox, oy, ox2, oy2) then
        return false
      end
    end
  end

  local left_blocked = false
  local right_blocked = false
  for _, other in ipairs(tiles) do
    if not other.removed and other.layer == t.layer then
      local ox, oy, ox2, oy2 = tile_rect(other)
      if ox2 > tx and ox < tx then
        if oy < ty2 and oy2 > ty then
          left_blocked = true
        end
      end
      if ox < tx2 and ox2 > tx2 then
        if oy < ty2 and oy2 > ty then
          right_blocked = true
        end
      end
    end
  end

  return not left_blocked or not right_blocked
end

--- Return indices of all currently playable tiles.
function M.find_free_tiles(tiles)
  local free = {}
  for i in ipairs(tiles) do
    if M.is_free(tiles, i) then
      free[#free + 1] = i
    end
  end
  return free
end

--- Return every legal pair among currently playable tiles.
function M.find_matches(tiles)
  local free = M.find_free_tiles(tiles)
  local pairs = {}
  for i = 1, #free do
    for j = i + 1, #free do
      local a = tiles[free[i]]
      local b = tiles[free[j]]
      if tileset.matches(a, b) then
        pairs[#pairs + 1] = { free[i], free[j] }
      end
    end
  end
  return pairs
end

--- Mark both tiles in a legal pair as removed.
function M.remove_pair(tiles, i, j)
  tiles[i].removed = true
  tiles[j].removed = true
end

--- Restore both tiles from an undone move.
function M.restore_pair(tiles, i, j)
  tiles[i].removed = false
  tiles[j].removed = false
end

--- Return whether no legal pair remains on board.
function M.no_moves_left(tiles)
  return #M.find_matches(tiles) == 0
end

--- Return whether every board tile has been removed.
function M.all_cleared(tiles)
  for _, t in ipairs(tiles) do
    if not t.removed then return false end
  end
  return true
end

--- Return first legal pair, or two nil values when none exists.
function M.find_hint(tiles)
  local matches = M.find_matches(tiles)
  if #matches > 0 then
    return matches[1][1], matches[1][2]
  end
  return nil, nil
end

--- Return nearest playable tile in requested cardinal direction.
function M.get_nearest_tile(tiles, current_idx, direction)
  local current = tiles[current_idx]
  if not current or current.removed then return nil end

  local cx, cy = M.tile_position(current)

  local candidates = {}
  for i, t in ipairs(tiles) do
    if i ~= current_idx and M.is_free(tiles, i) then
      local tx, ty = M.tile_position(t)
      local dx = tx - cx
      local dy = ty - cy

      local valid = false
      if direction == "left" and dx < 0 then valid = true end
      if direction == "right" and dx > 0 then valid = true end
      if direction == "up" and dy < 0 then valid = true end
      if direction == "down" and dy > 0 then valid = true end

      if valid then
        local axis_penalty = 0
        if direction == "left" or direction == "right" then
          axis_penalty = math.abs(dy) * 10
        else
          axis_penalty = math.abs(dx) * 10
        end
        local dist = math.sqrt(dx * dx + dy * dy * 0.5 + (t.layer - current.layer) * 20) + axis_penalty
        candidates[#candidates + 1] = { idx = i, dist = dist }
      end
    end
  end

  if #candidates == 0 then return nil end
  table.sort(candidates, function(a, b) return a.dist < b.dist end)
  return candidates[1].idx
end

return M
