import std/[tables, sequtils, strformat, strutils, strscans, os]

const
  sampleData = staticRead "../../inputs/05/sample.txt"

type
  MapRule = object
    src: int
    dst: int
    size: int

    # tuple[sourceLocation,destinationLocation,size: int, src, dst: HSlice[int,int]]
    ## this is the "core" "meaty-bit" of this challenge.

  MapRules = seq[MapRule]
    ## Convenience Alias

  Mapping = object
    ## Represents one line of challenge's `THING_1-to-THING_2` sections
    src: string
    dst: string
    rules: MapRules

  Mappings = Table[string, Mapping]
    ## Table b/c makes traversing ez

  Almanac = object  ## full representation of puzzle input
    seeds: seq[int] ## the initial seeds
    maps: Mappings  ## table of maps

  ParsingStateKind = enum Bored, Cartographing
  ParsingState = object
    kind: ParsingStateKind
    idx: int
    alm: Almanac
    num: int
    str: string
    map: Mapping
    rule: MapRule

template addDigit (v, c: untyped): untyped =
  v = (v * 10) + (c.int - 0x30) # teehee 😉

proc endSeed(s: var ParsingState) =
  if s.num != 0:
    s.alm.seeds.add s.num
    s.num = 0

proc initAlmanac(input: string): Almanac =
  # echo "{input=}".fmt

  var
    s = ParsingState(kind: Bored)

  while true:
    # echo "<<<", input[s.idx .. min(s.idx + 20, input.len-1)], "...>>> "
    # echo s.idx, ", ", input.len-1, ": ", s.kind
    if input.scanp(s.idx, '\L'):
      s.kind = Bored
      if s.map.rules.len > 0:
        s.alm.maps[s.map.src] = s.map
        s.map = Mapping()
      continue

    case s.kind:
    of Bored:
      if input.scanp(s.idx, ("seeds:", +(' ', (+{'0'..'9'} -> addDigit(s.num,
          $_))) -> s.endSeed(), '\L') -> s.endSeed()):
        # echo "seeds: {s.alm.seeds}".fmt
        continue

      elif input.scanp(s.idx, (+{'a' .. 'z'} -> s.map.src.add $_), "-to-", (+{
          'a' .. 'z'} -> s.map.dst.add $_), " map:", '\L'):
        s.kind = Cartographing
        # echo "starting map: src={s.map.src} dst={s.map.dst}".fmt
        continue

    of Cartographing:
      if input.scanp(s.idx, (+{'0' .. '9'}) -> addDigit(s.rule.dst, $_),
          ' ') and
         input.scanp(s.idx, (+{'0' .. '9'}) -> addDigit(s.rule.src, $_),
             ' ') and
         input.scanp(s.idx, (+{'0' .. '9'}) -> addDigit(s.rule.size, $_), '\L'):
        s.map.rules.add s.rule
        s.rule = MapRule() # 196
        continue

    if s.idx < input.len:
      raise LibraryError.newException "no more parsing rules but not at eof? idx={s.idx} len={input.len} rest={input[s.idx..input.len-1]}".fmt

    if s.map.rules.len > 0:
      s.alm.maps[s.map.src] = s.map
      s.map = Mapping()

    break

  s.alm

proc locationOf(almanac: Almanac, seed: int): int =
  var
    cur = "seed"
    map = Mapping()
    loc = seed

  while true:
    if cur notin almanac.maps:
      break
    map = almanac.maps[cur]
    cur = map.dst
    for rule in map.rules:
      if loc in rule.src .. rule.src + rule.size - 1:
        loc = loc - rule.src + rule.dst
        break
      else:
        discard


  loc

proc min(almanac: Almanac): int =
  almanac.seeds.mapIt(almanac.locationOf it).min

when isMainModule:
  block:
    let almanac = initAlmanac sampleData
    echo "sample/day05-part1: {almanac.min}".fmt

  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
  let
    almanac = initAlmanac readFile params[0]
    lowest = almanac.min

  echo "Answer: {lowest}".fmt

