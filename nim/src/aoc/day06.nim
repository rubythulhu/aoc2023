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

proc extractNums(input: string): seq[int] =
  input.split(Whitespace).filterIt(it.len > 0).mapIt(parseInt $it)

proc initRaces(input: string): Races =
  var races: Races

  var
    times: seq[int]
    distances: seq[int]

  for line in input.splitLines():
    if line.len == 0: continue
    if line[0..4] == "Time:": times = line.split(":")[1].extractNums
    elif line[0..8] == "Distance:": distances = line.split(":")[1].extractNums
    else: raise LibraryError.newException "what: " & line

  if times.len != distances.len:
    raise LibraryError.newException "times.len != distances.len"

  for idx, time in times:
    let distance = distances[idx]
    races.add (time, distance)


  races

when isMainModule:
  block:
    let races = initRaces sampleData
    echo $races

    # static testing of sampleData here
    discard

  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
