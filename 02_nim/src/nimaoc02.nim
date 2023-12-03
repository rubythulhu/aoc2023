import std/[os, strutils, strformat]

const 
  rMax = 12
  gMax = 13
  bMax = 14

type 
  Counts = object
    r,g,b: int
  GameDef = object 
    id: int
    samples: seq[Counts]

proc extractGame(line: string): tuple[id: int, samplestr: string] =
  let parts = line.split(": ", 2)
  let gparts = parts[0].split(' ')
  (gparts[1].parseInt, parts[1])

proc extractSamples(s: string): seq[Counts] =
  var allCounts = newSeq[Counts]()
  for sample in s.split("; "):
    var counts: Counts 
    for cubeset in sample.split(", "):
      let parts = cubeset.split(" ");
      case parts[1]:
        of "red": counts.r = parts[0].parseInt
        of "green": counts.g = parts[0].parseInt
        of "blue": counts.b = parts[0].parseInt
        else: discard
    allCounts.add counts 
  allCounts
  
proc parseline (line: string): tuple[id, r, g, b: int] =
  var r, g, b: int = 0
  let (id, samplestr) = extractGame line
  let samples = extractSamples samplestr
  for sample in samples:
    r = max(sample.r, r)
    g = max(sample.g, g)
    b = max(sample.b, b)
  (id, r, g, b)

proc linescore (line: string): int = 
  let (id, r, g, b) = parseline line
  if r>rMax or g>gMax or b>bMax: return 0
  id

proc parse*(fn: string): int = 
  var sum = 0
  for line in lines fn:
    let score = linescore line
    sum += score
  sum

when isMainModule:
  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1) 
  echo parse(params[0])

