require("global")

local M = {}

M.SCREEN_W = 750
M.SCREEN_H = 560

M.TILE_W = 48
M.TILE_H = 60
M.TILE_SPACING_X = 44
M.TILE_SPACING_Y = 56
M.LAYER_DX = 6
M.LAYER_DY = -4

M.SPRITE_COLS = 12

M.BOARD_CENTER_X = M.SCREEN_W / 2
M.BOARD_CENTER_Y = M.SCREEN_H / 2 + 30

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
  start = RETRO_DEVICE_ID_JOYPAD_START,
  select = RETRO_DEVICE_ID_JOYPAD_SELECT,
  l1 = RETRO_DEVICE_ID_JOYPAD_L,
  r1 = RETRO_DEVICE_ID_JOYPAD_R,
  l2 = RETRO_DEVICE_ID_JOYPAD_L2,
  r2 = RETRO_DEVICE_ID_JOYPAD_R2,
}

M.MAX_LAYERS = 5

M.COLORS = {
  board_outer   = { 60,  40,  20 },
  board_inner   = { 100, 70,  30 },
  board_border  = { 40,  25,  10 },
  shadow        = { 15,  20,  50, 200 },
  tile_light    = { 255, 255, 255 },
  cursor        = { 255, 255, 0,   120 },
  selected      = { 0,   255, 0,   160 },
  hint_outline  = { 255, 0,   255, 180 },
  hud_text      = { 200, 200, 200 },
  control_text  = { 160, 160, 160 },
  status_bg     = { 255, 220, 0 },
  status_text   = { 0,   0,   0 },
  overlay       = { 0,   0,   0,   220 },
  win_text      = { 80,  255, 80 },
  lose_text     = { 255, 80,  80 },
  bg            = { 20,  30,  70 },
  title_text    = { 255, 220, 80 },
  title_sub     = { 200, 200, 200 },
  title_hint    = { 120, 120, 120 },
}
M.blocked_tint_pct = 1
return M
