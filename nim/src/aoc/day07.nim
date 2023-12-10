import std/[
  algorithm,
  os,
  sequtils,
  strformat,
  strutils,
  sugar,
  tables,
]

const
  sampleData = staticRead "../../inputs/07/sample.txt"

type

  Card = enum c2, c3, c4, c5, c6, c7, c8, c9, c10, cJ, cQ, cK, cA
  WildCard = enum cJ, c2, c3, c4, c5, c6, c7, c8, c9, c10, cQ, cK, cA
  HandData = array[5, Card]
  WildHandData = array[5, WildCard]
  HandType = enum HighCard, Pair, TwoPairs, ThreeOfAKind, FullHouse,
    FourOfAKind, FiveOfAKind
  HandComparison = enum Lose = -1, Tie = 0, Win = 1
  Hand = object
    data: HandData
    wild: WildHandData
    handType: HandType
  Player = object
    hand: Hand
    bid: int
  Game = seq[Player]

proc toWildCard(card: Card): WildCard =
  case card
  of cJ: result = cJ
  of c2: result = c2
  of c3: result = c3
  of c4: result = c4
  of c5: result = c5
  of c6: result = c6
  of c7: result = c7
  of c8: result = c8
  of c9: result = c9
  of c10: result = c10
  of cQ: result = cQ
  of cK: result = cK
  of cA: result = cA

proc `$`(game: Game): string =
  "Game(\n" & game.mapIt("  " & $it).join("\n") & "\n)"

proc handType[T](hand: openArray[T]): HandType =
  var
    counts = initCountTable[T]()
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

proc compareSameHandType[T](a, b: openArray[T]): HandComparison =
  for idx, aCard in a:
    let bCard = b[idx]
    if aCard > bCard:
      result = Win
      return
    elif aCard < bCard:
      result = Lose
      return
  result = Tie

proc compareHandData[T](a, b: openArray[T]): HandComparison =
  var
    at = a.handType
    bt = b.handType

  if at != bt: result = compareHandTypes(at, bt)
  else: result = compareSameHandType(a, b)


proc sortPlayers(a, b: Player): int =
  compareHandData(a.hand.data, b.hand.data).ord

proc sortPlayersWild(a, b: Player): int =
  compareHandData(a.hand.wild, b.hand.wild).ord

proc toCard(ch: char): Card {.inline.} =
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

proc toChar(card: Card): char {.inline.} =
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

proc toWildHandData(handData: HandData): WildHandData =
  for i in 0..4:
    result[i] = handData[i].toWildCard

proc bestWildcardHand(handData: HandData): WildHandData =
  let orig = handData.toWildHandData
  result = orig
  for i in WildCard.toSeq:
    var alt = orig
    for j in 0..4:
      if alt[j] == cJ:
        alt[j] = i
    if compareHandData(alt, result) == Win:
      result = alt

proc gameResultsWild(game: Game): int =
  result = 0
  for i, player in game.sorted(sortPlayersWild):
    result.inc (i + 1) * player.bid

proc gameResults(game: Game): int =
  result = 0
  for i, player in game.sorted(sortPlayers):
    result.inc (i + 1) * player.bid


proc initHand(handStr: string): Hand =
  var handData: array[0..4, Card]
  for i in 0..4:
    handData[i] = handStr[i].toCard

  result.data = handData
  result.wild = handData.bestWildcardHand
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
    assert game.gameResults == 6440
    assert game.gameResultsWild == 5905
    # TODO: add sample data checks
    discard

when isMainModule:
  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
  let game = initGame readFile params[0]
  echo "day07/part1: {game.gameResults}".fmt
  echo "day07/part2: {game.gameResultsWild}"
