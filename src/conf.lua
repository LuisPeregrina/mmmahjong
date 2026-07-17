require("global")

local M = {}

M.SCREEN_W = 640
M.SCREEN_H = 480

M.TILE_W = 48
M.TILE_H = 60
M.LAYER_DX = 6
M.LAYER_DY = -4

M.SPRITE_COLS = 12

M.BOARD_CENTER_X = M.SCREEN_W / 2
M.BOARD_CENTER_Y = M.SCREEN_H / 2 + 10

M.NUM_TILES = 144

M.SCALE = 1

M.TILE_TYPES = {}
local t = 0
local function add_numbered_types(suit)
  for i = 1, 9 do
    t = t + 1
    M.TILE_TYPES[t] = suit .. "_" .. i
  end
end

--- Add one numbered suit's tile types in sprite-sheet order.
add_numbered_types("bamboo")
add_numbered_types("dot")
add_numbered_types("char")
local winds = { "east", "south", "west", "north" }
for _, w in ipairs(winds) do
  t = t + 1; M.TILE_TYPES[t] = "wind_" .. w
end
local dragons = { "red", "green", "white" }
for _, d in ipairs(dragons) do
  t = t + 1; M.TILE_TYPES[t] = "dragon_" .. d
end
for i = 1, 4 do
  t = t + 1; M.TILE_TYPES[t] = "season_" .. i
end
for i = 1, 4 do
  t = t + 1; M.TILE_TYPES[t] = "flower_" .. i
end

M.TYPE_SUITE = {}
for _, tt in ipairs(M.TILE_TYPES) do
  local suite = tt:match("^(%a+)_")
  M.TYPE_SUITE[tt] = suite
end

M.SUITE_COUNT = {
  bamboo = 4,
  dot = 4,
  char = 4,
  wind = 4,
  dragon = 4,
  season = 1,
  flower = 1
}

M.DECK = {}
local deck_idx = 0
for _, tt in ipairs(M.TILE_TYPES) do
  local suite = M.TYPE_SUITE[tt]
  local cnt = M.SUITE_COUNT[suite]
  for _ = 1, cnt do
    deck_idx = deck_idx + 1; M.DECK[deck_idx] = tt
  end
end

M.KEYS = {
  up = "up",
  down = "down",
  left = "left",
  right = "right",
  select = "x",
  cancel = "z",
  undo = "u",
  hint = "h",
  shuffle = "s",
  menu = "escape",
}

M.GPAD = {
  up = RETRO_DEVICE_ID_JOYPAD_UP,
  down = RETRO_DEVICE_ID_JOYPAD_DOWN,
  left = RETRO_DEVICE_ID_JOYPAD_LEFT,
  right = RETRO_DEVICE_ID_JOYPAD_RIGHT,
  a = RETRO_DEVICE_ID_JOYPAD_A,
  b = RETRO_DEVICE_ID_JOYPAD_B,
}

M.MAX_LAYERS = 5

return M
