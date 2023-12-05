import std/[intsets, os, math, sequtils, strutils, strformat, tables]

const
  sampleData = staticRead "../../inputs/04/sample.txt"

type
  Card = object
    num: int
    winning: IntSet
    yours: IntSet

proc parseNums(nums: string): IntSet =
  nums
    .split(Whitespace)
    .filterIt(it.len > 0)
    .mapIt(it.parseInt)
    .toIntSet

proc results(card: Card): seq[int] =
  var s: seq[int]
  for i in items(card.winning * card.yours):
    s.add i
  s

proc score(card: Card): int =
  var x = 0
  for i in card.results:
    x = nextPowerOfTwo x + 1
  x

proc actualScore(card: Card): int =
  (card.winning * card.yours).len

proc day04(input: string): tuple[p1score, p2cards: int] =
  var 
    p1score = 0
    p2cards = 0

  var totals = initCountTable[int]()

  let lines = input.split(Newlines)
  for i, line in lines.filterIt(it.len > 0).pairs:
    var card = Card(num: 0, winning: initIntSet(), yours: initIntSet())
    let parts = line.split {':', '|'}
    card.num = parts[0].split(Whitespace)[^1].parseInt
    card.winning = parts[1].parseNums
    card.yours = parts[2].parseNums
    totals.inc card.num
    let sc = card.score 
    let ac = card.actualScore
    let n = card.num
    for j in n + 1 .. n + ac:
        totals.inc(j, totals[n])
    p1score.inc sc

  for ct in totals.values:
    p2cards.inc ct

  (p1score, p2cards)

when isMainModule:
  block:
    let (p1score, p2cards) = day04 sampleData

    echo "sample/day04: {p1score=}".fmt
    echo "sample/day04: {p2cards=}".fmt

  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
  let (p1score, p2cards) = day04 readFile params[0]
  echo "day04: {p1score=}".fmt
  echo "day04: {p2cards=}".fmt
  assert p1score == 26346, "regression in solution"




