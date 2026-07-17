local board = require("board")
local tileset = require("tiles")
local M = {}

M.current = nil
M.selected = nil
M.state = "idle"

--- Point cursor at first playable tile and clear selection.
function M.init(tiles)
  M.tiles = tiles
  for i, t in ipairs(tiles) do
    if board.is_free(tiles, i) then
      M.current = i
      break
    end
  end
  M.selected = nil
  M.state = "idle"
end

--- Move cursor to nearest playable tile when current one is no longer playable.
function M.ensure_current()
  if M.current and board.is_free(M.tiles, M.current) then return end

  local best, best_dist
  local cx, cy
  if M.current and M.tiles[M.current] then
    cx, cy = board.tile_position(M.tiles[M.current])
  end
  for i, t in ipairs(M.tiles) do
    if board.is_free(M.tiles, i) then
      if not cx then
        M.current = i
        return
      end
      local tx, ty = board.tile_position(t)
      local d = (tx - cx)^2 + (ty - cy)^2
      if not best or d < best_dist then
        best, best_dist = i, d
      end
    end
  end
  M.current = best
end

--- Move cursor to nearest playable tile in a cardinal direction.
function M.move(direction)
  if not M.current then return end
  local tiles = M.tiles
  if not tiles then return end

  local next = board.get_nearest_tile(tiles, M.current, direction)
  if next then
    M.current = next
  end
end

--- Select current tile, toggle selection, or return selected matching pair.
-- @return pair|nil, status|nil
function M.select()
  local tiles = M.tiles
  if not tiles then return nil, nil end
  local t = tiles[M.current]
  if not t or t.removed then return nil, nil end

  if not board.is_free(tiles, M.current) then return nil, "blocked" end

  if M.state == "idle" then
    M.selected = M.current
    M.state = "one_selected"
    return nil, "selected"
  elseif M.state == "one_selected" then
    if M.current == M.selected then
      M.selected = nil
      M.state = "idle"
      return nil, "deselected"
    end

    local first = tiles[M.selected]
    local second = tiles[M.current]

    if tileset.matches(first, second) then
      local idx_a, idx_b = M.selected, M.current
      M.state = "idle"
      M.selected = nil
      return { idx_a, idx_b }, "match"
    else
      M.selected = M.current
      return nil, "mismatch"
    end
  end
  return nil, nil
end

--- Clear pending tile selection.
function M.cancel()
  if M.state == "one_selected" then
    M.selected = nil
    M.state = "idle"
  end
end

--- Select a known playable tile, used by hints.
function M.set_selected(idx)
  M.selected = idx
  M.current = idx
  M.state = "one_selected"
end

--- Clear cursor state before initializing a replacement board.
function M.reset()
  M.current = nil
  M.selected = nil
  M.state = "idle"
end

return M
