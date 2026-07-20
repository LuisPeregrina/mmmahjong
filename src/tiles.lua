local conf = require("conf")
local M = {}

--- Shuffle an array in place using Fisher-Yates.
function M.shuffle(items)
  for i = #items, 2, -1 do
    local j = math.random(i)
    items[i], items[j] = items[j], items[i]
  end
end

--- Assign a copy of the pre-built shuffled deck with stable identifiers.
function M.create_deck()
  local deck = {}
  for i = 1, conf.NUM_TILES do
    deck[i] = { type = conf.DECK[i], id = i }
  end
  M.shuffle(deck)
  return deck
end

--- Return whether two tiles form a legal Mahjong Solitaire pair.
function M.matches(first, second)
  if first.type == second.type then
    return true
  end

  local first_suit = conf.TYPE_SUITE[first.type]
  return first_suit == conf.TYPE_SUITE[second.type]
    and (first_suit == "season" or first_suit == "flower")
end

return M
