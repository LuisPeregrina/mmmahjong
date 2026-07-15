local conf = require("conf")
local M = {}

local TYPE_TO_COL = {}
for i, tt in ipairs(conf.TILE_TYPES) do
  TYPE_TO_COL[tt] = (i - 1) % conf.SPRITE_COLS
  TYPE_TO_COL[tt.."_row"] = math.floor((i - 1) / conf.SPRITE_COLS)
end

local function shuffle(arr, n)
  for i = n, 2, -1 do
    local j = math.random(i)
    arr[i], arr[j] = arr[j], arr[i]
  end
end

function M.create_deck()
  local deck = {}
  for i = 1, conf.NUM_TILES do
    deck[i] = { type = conf.DECK[i], id = i }
  end
  shuffle(deck, conf.NUM_TILES)
  return deck
end

function M.clone_deck(deck)
  local out = {}
  for i, t in ipairs(deck) do
    out[i] = { type = t.type, id = t.id }
  end
  return out
end

function M.same_type(a, b)
  return a.type == b.type
end

function M.type_index(tt)
  for i, v in ipairs(conf.TILE_TYPES) do
    if v == tt then return i end
  end
  return 1
end

function M.get_quad(tt)
  local i = M.type_index(tt)
  local col = (i - 1) % conf.SPRITE_COLS
  local row = math.floor((i - 1) / conf.SPRITE_COLS)
  return col, row
end

return M
