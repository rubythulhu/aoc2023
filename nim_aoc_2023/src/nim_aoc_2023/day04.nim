import std/[intsets, os, math, sequtils, strutils, strformat]

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

proc day04(input: string): int =
  var totalScore = 0
  var cards = newSeq[Card]()
  let lines = input.split(Newlines)
  for line in lines.filterIt(it.len > 0):
    var card = Card(num: 0, winning: initIntSet(), yours: initIntSet())
    let parts = line.split {':', '|'}
    card.num = parts[0].split(Whitespace)[^1].parseInt
    card.winning = parts[1].parseNums
    card.yours = parts[2].parseNums
    totalScore.inc card.score
  totalScore

when isMainModule:
  block:
    let p1score = day04 sampleData
    echo "sample/day04: {p1score=}".fmt

  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
  let p1score = day04 readFile params[0]
  echo "day04: {p1score=}".fmt
  assert p1score == 26346, "regression in solution"




