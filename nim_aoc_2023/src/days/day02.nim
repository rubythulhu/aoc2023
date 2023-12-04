import std/[os, strutils, strformat]
# have i gone too template-heavy? i don't care.

type Counts = object
  r, g, b: int

const lim = Counts(r:12, g:13, b:14)

template extractGame(line: string): tuple[id: int, samplestr: string] =
  let parts = line.split(": ", 2)
  let gparts = parts[0].split(' ')
  (gparts[1].parseInt, parts[1])

template extractSamples(s: string): seq[Counts] = 
  block:
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

template adjust(color: var int, val: int) = color = color.max val

template adjustAll(cur, val: Counts) =
  cur.r.adjust val.r
  cur.g.adjust val.g
  cur.b.adjust val.b

template parseline (line: string): tuple[id: int, c: Counts] = 
  block:
    let 
      (id, samplestr) = extractGame line
      samples = extractSamples samplestr
      fst = samples[0]

    var c: Counts = fst

    for sample in samples[1..high samples]:
      adjustAll(c, sample)

    (id, c)

template linescore (line: string): tuple[p1, p2: int] = 
  block: 
    let (id, c) = parseline line
    let p1 = if c.r > lim.r or c.g > lim.g or c.b > lim.b: 0 else: id
    let p2 = c.r * c.g * c.b
    (p1, p2)

template parse*(fn: string): tuple[p1, p2: int] = 
  var s1, s2 = 0
  for line in lines fn:
    let (p1, p2) = linescore line
    s1 += p1
    s2 += p2
  (s1, s2)

proc run() =
  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1) 
  let (part1, part2) = parse(params[0])
  echo "Scores: "
  echo "    Part 1: {part1}".fmt
  echo "    Part 2: {part2}".fmt

when isMainModule: 
  run()
