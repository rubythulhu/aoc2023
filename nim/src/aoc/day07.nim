import std/[
  os,
  sequtils,
  strformat,
  strutils,
  tables,
]

const
  sampleData = staticRead "../../inputs/07/sample.txt"

type
  Card = enum c2, c3, c4, c5, c6, c7, c8, c9, c10, cJ, cQ, cK, cA
  HandData = array[5, Card]
  HandType = enum HighCard, Pair, TwoPairs, ThreeOfAKind, FullHouse,
    FourOfAKind, FiveOfAKind
  HandComparison = enum Win, Lose, Tie
  Hand = object
    data: HandData
    handType: HandType
  Player = object
    hand: Hand
    bid: int
  Game = seq[Player]

proc `$`(game: Game): string =
  "Game(\n" & game.mapIt("  " & $it).join("\n") & "\n)"

proc handType(hand: HandData): HandType =
  var
    counts = initCountTable[Card]()
    maxCount = 0
  for card in hand:
    counts.inc card
    if counts[card] > maxCount: maxCount = counts[card]
  case maxCount
  of 1: result = HighCard
  of 2:
    if counts.len == 4: result = Pair
    else: result = TwoPairs
  of 3:
    if counts.len == 3: result = ThreeOfAKind
    else: result = FullHouse
  of 4: result = FourOfAKind
  of 5: result = FiveOfAKind
  else: quit "invalid hand"

proc compareHandTypes(a, b: HandType): HandComparison =
  if a == b: result = Tie
  elif a > b: result = Win
  else: result = Lose

proc compareSameHandType(a, b: HandData): HandComparison =
  for idx, card in a:
    if card > b[idx]: result = Win
    elif card < b[idx]: result = Lose
  result = Tie

proc compareHandData(a, b: HandData): HandComparison =
  var
    at = a.handType
    bt = b.handType

  if at != bt: result = compareHandTypes(at, bt)
  else: result = compareSameHandType(a, b)

proc charToCard(ch: char): Card {.inline.} =
  case ch
  of '2': result = c2
  of '3': result = c3
  of '4': result = c4
  of '5': result = c5
  of '6': result = c6
  of '7': result = c7
  of '8': result = c8
  of '9': result = c9
  of 'T': result = c10
  of 'J': result = cJ
  of 'Q': result = cQ
  of 'K': result = cK
  of 'A': result = cA
  else: quit "invalid card"

proc cardToChar(card: Card): char {.inline.} =
  case card
  of c2: result = '2'
  of c3: result = '3'
  of c4: result = '4'
  of c5: result = '5'
  of c6: result = '6'
  of c7: result = '7'
  of c8: result = '8'
  of c9: result = '9'
  of c10: result = 'T'
  of cJ: result = 'J'
  of cQ: result = 'Q'
  of cK: result = 'K'
  of cA: result = 'A'

proc initHand(handStr: string): Hand =
  var handData: array[0..4, Card]
  for i in 0..4:
    handData[i] = handStr[i].charToCard

  result.data = handData
  result.handType = handType result.data

proc initGame(input: string): Game =
  for line in input.splitLines():
    if line.len == 0: continue
    var
      player: Player
      handStr = line[0..min(4, line.len - 1)]
      bidStr = line[6..line.len - 1]
    player.hand = initHand handStr
    player.bid = parseInt bidStr
    result.add player

when isMainModule and not defined(release):
  block:
    let game = initGame sampleData
    echo $game
    # TODO: add sample data checks
    discard

when isMainModule:
  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
