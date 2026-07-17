local conf = require("conf")
local M = {}

-- Layout layer sizes: layer -> {rows, cols}
local LAYER_CONFIG = {
  { rows = 6, cols = 14 },  -- 84 tiles
  { rows = 4, cols = 12 },  -- 48 tiles
  { rows = 2, cols = 8  },  -- 16 tiles
  { rows = 1, cols = 6  },  --  6 tiles
  { rows = 1, cols = 2  },  --  2 tiles  -- wait, 84+48+16+6+2 = 156
}
-- 84+48+16+6+2 = 156, too many. Redesign:

-- Standard turtle: shrinking by 1 on each side per layer
-- L1: 14x6 = 84
-- L2: 12x4 = 48 (offset by 1 row+1 col)
-- L3: 10x2 = 20 (offset by 2)
-- But L3 = 10x2 = 20, that's too few total positions...

-- 84+48 = 132, need 12 more
-- L3: 6x2 = 12  (offset by 3)
-- L4: 2x2 = 4? No...
-- Let me recalculate. 

-- Actually the classic layout is:
-- L1: 84 (14x6)
-- L2: 48 (12x4)
-- L3: 12 (split: six 2-high pairs) 

-- Simpler approach: define positions manually for 144 tiles.

local LAYOUT = {}

-- Generate turtle positions: L1=84, L2=48, L3=12 = 144
local LAYER_SIZES = { 84, 48, 12 }

--- Generate positions for a rectangular layer centered around BOARD_CENTER
-- with a given crop offset from previous layer
local function gen_layer(rows, cols, row_off, col_off)
  local r = {}
  local base_row = row_off
  local base_col = col_off
  for row = 0, rows - 1 do
    for col = 0, cols - 1 do
      r[#r + 1] = { layer = 0, row = base_row + row, col = base_col + col }
    end
  end
  return r
end

-- L1: 14 cols x 6 rows = 84
local L1_rows = 6
local L1_cols = 14
local L1 = gen_layer(L1_rows, L1_cols, 0, 0)
for _, p in ipairs(L1) do p.layer = 1 end

-- L2: 12 cols x 4 rows = 48, offset 1 right, 1 down from L1
local L2_rows = 4
local L2_cols = 12
local L2 = gen_layer(L2_rows, L2_cols, 1, 1)
for _, p in ipairs(L2) do p.layer = 2 end

-- L3: 10 cols x 2 rows = 20, but 84+48+20 = 152 > 144
-- Need only 12 more. Let L3 be smaller.
-- L3: 8 cols x 2 rows = 16, but that's still 148
-- Actually 84+48 = 132. We need 12. 
-- L3: 6 cols x 2 rows centered = 12. Perfect: 144.

-- But wait, many mahjong implementations use more than 3 visible layers.
-- The "depth" illusion through cutouts. Let's do:
-- L1: 84, L2: 48, L3: 10, L4: 2 = 144
-- 84+48+10+2 = 144 ✓ 

local L3_rows = 2
local L3_cols = 5
local L3 = gen_layer(L3_rows, L3_cols, 2, 4)
for _, p in ipairs(L3) do p.layer = 3 end

-- L4: 2 tiles at center
local function single_tile(layer, row, col)
  return { { layer = layer, row = row, col = col } }
end

local L4 = {
  { layer = 4, row = 3, col = 6 },
  { layer = 4, row = 3, col = 7 },
}

LAYOUT = {}
for _, pos in ipairs(L1) do LAYOUT[#LAYOUT+1] = pos end
for _, pos in ipairs(L2) do LAYOUT[#LAYOUT+1] = pos end
for _, pos in ipairs(L3) do LAYOUT[#LAYOUT+1] = pos end
for _, pos in ipairs(L4) do LAYOUT[#LAYOUT+1] = pos end

assert(#LAYOUT == 144, "Layout has "..#LAYOUT.." positions, need 144")

--- Compute pixel position for a tile given its layer/row/col
function M.tile_position(pos)
  local tw = conf.TILE_W
  local th = conf.TILE_H
  local ldx = pos.layer * conf.LAYER_DX
  local ldy = pos.layer * conf.LAYER_DY

  local total_cols = 14
  local grid_w = total_cols * tw
  local grid_h = 6 * th

  local gx = (pos.col - (total_cols - 1) / 2) * tw
  local gy = (pos.row - (6 - 1) / 2) * th

  local cx = conf.BOARD_CENTER_X + gx + ldx
  local cy = conf.BOARD_CENTER_Y + gy + ldy
  return cx, cy
end

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

function M.is_free(tiles, idx)
  local t = tiles[idx]
  if t.removed then return false end

  for i, other in ipairs(tiles) do
    if not other.removed and other.layer > t.layer then
      if other.row == t.row and other.col == t.col then
        return false
      end
    end
  end

  local left_blocked = false
  local right_blocked = false
  for i, other in ipairs(tiles) do
    if not other.removed and other.layer == t.layer then
      if other.col == t.col - 1 and other.row == t.row then
        left_blocked = true
      end
      if other.col == t.col + 1 and other.row == t.row then
        right_blocked = true
      end
    end
  end

  return not left_blocked or not right_blocked
end

function M.find_free_tiles(tiles)
  local free = {}
  for i, t in ipairs(tiles) do
    if M.is_free(tiles, i) then
      free[#free + 1] = i
    end
  end
  return free
end

function M.find_matches(tiles)
  local free = M.find_free_tiles(tiles)
  local pairs = {}
  for i = 1, #free do
    for j = i + 1, #free do
      local a = tiles[free[i]]
      local b = tiles[free[j]]
      if a.type == b.type then
        pairs[#pairs + 1] = { free[i], free[j] }
      end
    end
  end
  return pairs
end

function M.remove_pair(tiles, i, j)
  tiles[i].removed = true
  tiles[j].removed = true
end

function M.restore_pair(tiles, i, j)
  tiles[i].removed = false
  tiles[j].removed = false
end

function M.no_moves_left(tiles)
  return #M.find_matches(tiles) == 0
end

function M.all_cleared(tiles)
  for _, t in ipairs(tiles) do
    if not t.removed then return false end
  end
  return true
end

function M.find_hint(tiles)
  local matches = M.find_matches(tiles)
  if #matches > 0 then
    return matches[1][1], matches[1][2]
  end
  return nil, nil
end

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
        local dist = math.sqrt(dx * dx + dy * dy * 0.5 + (t.layer - current.layer) * 20)
        candidates[#candidates + 1] = { idx = i, dist = dist }
      end
    end
  end

  if #candidates == 0 then return nil end
  table.sort(candidates, function(a, b) return a.dist < b.dist end)
  return candidates[1].idx
end

return M
