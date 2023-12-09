import std/[
  os,
  sequtils,
  strformat,
  strutils,
]

const
  sampleData = staticRead "../../inputs/06/sample.txt"

type
  Race = tuple[time, distance: int]
  Races = seq[Race]

proc `$`(races: Races): string =
  "Races(\n" & races.mapIt("    " & $it).join("\n") & "\n)"

proc extractNums(line: string): seq[int] {.inline.} =
  line
    .split(Whitespace)
    .filterIt(it.len > 0)
    .mapIt(parseInt it)

proc parseLine(line: string): seq[int] {.inline.} =
  line.split(':')[1].extractNums

proc extractNumBadKerning(line: string): int {.inline.} =
  line
    .split(Whitespace)
    .filterIt(it.len > 0)
    .join("")
    .parseInt

proc parseLineBadKerning(line: string): int {.inline.} =
  line.split(':')[1].extractNumBadKerning

proc winningStrategies(race: Race): int =
  var left, right: int
  for t in 1 .. race.time:
    if t * (race.time - t) > race.distance:
      left = t
      break
  for t in countdown(race.time, max(left, 1)):
    if t * (race.time - t) > race.distance:
      right = t
      break
  right + 1 - left

proc winningStrategies(races: Races): int =
  races.map(winningStrategies).foldl(a * b)

proc initRaces(input: string): Races =
  var races: Races

  var
    times: seq[int]
    distances: seq[int]

  for line in input.splitLines():
    if line.len == 0: continue
    if line[0..4] == "Time:": times = line.parseLine
    elif line[0..8] == "Distance:": distances = line.parseLine
    else: raise LibraryError.newException "what: " & line

  if times.len != distances.len:
    raise LibraryError.newException "times.len != distances.len"

  for idx, time in times:
    let distance = distances[idx]
    races.add (time, distance)

  races

proc initRaceBadKerning(input: string): Race =
  var time, distance: int
  for line in input.splitLines():
    if line.len == 0: continue
    if line[0..4] == "Time:": time = line.parseLineBadKerning
    elif line[0..8] == "Distance:": distance = line.parseLineBadKerning
    else: raise LibraryError.newException "what: " & line
  (time, distance)

when isMainModule and not defined(release):
  block:
    let races = initRaces(sampleData)
    assert races == @[(7, 9), (15, 40), (30, 200)]
    assert races.map(winningStrategies) == @[4, 8, 9]
    assert races.winningStrategies == 288
    let race = initRaceBadKerning(sampleData)
    echo "Race: ", race
    assert race == (71530, 940200)
    assert race.winningStrategies == 71503

when isMainModule:
  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
  let races = initRaces readFile params[0]
  echo "winning strats: ", races.winningStrategies
  let race = initRaceBadKerning readFile params[0]
  echo "winning strats (kerning fixt): ", race.winningStrategies
