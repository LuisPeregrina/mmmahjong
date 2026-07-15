local conf = require("conf")
local board = require("board")
local M = {}

M.current = nil
M.selected = nil
M.state = "idle"

function M.init(tiles)
  M.tiles = tiles
  for i, t in ipairs(tiles) do
    if not t.removed then
      M.current = i
      break
    end
  end
  M.selected = nil
  M.state = "idle"
end

function M.move(direction)
  if not M.current then return end
  local tiles = M.tiles
  if not tiles then return end

  local next = board.get_nearest_tile(tiles, M.current, direction)
  if next then
    M.current = next
  end
end

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

    if first.type == second.type then
      local idx_a, idx_b = M.selected, M.current
      M.state = "idle"
      M.selected = nil
      return { idx_a, idx_b }, "match"
    else
      local old = M.selected
      M.selected = M.current
      return nil, "mismatch"
    end
  end
  return nil, nil
end

function M.cancel()
  if M.state == "one_selected" then
    M.selected = nil
    M.state = "idle"
  end
end

function M.set_selected(idx)
  M.selected = idx
  M.current = idx
  M.state = "one_selected"
end

function M.reset()
  M.current = nil
  M.selected = nil
  M.state = "idle"
end

return M
