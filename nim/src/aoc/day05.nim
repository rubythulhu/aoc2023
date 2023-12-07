import std/[tables, sequtils, strformat, strutils, strscans, os, math]

const
  sampleData = staticRead "../../inputs/05/sample.txt"

type
  MapRule = object
    ## this is the "core" "meaty-bit" of this challenge.
    src: int
    dst: int
    size: int

  MapRules = seq[MapRule]
    ## Convenience Alias

  Mapping = object
    ## Represents one line of challenge's `THING_1-to-THING_2` sections
    src: string
    dst: string
    rules: MapRules

  Mappings = seq[Mapping]
    ## Table b/c makes traversing ez


  Almanac = object  ## full representation of puzzle input
    seeds: seq[int] ## the initial seeds
    seedranges: seq[HSlice[int, int]]
    maps: Mappings  ## table of maps

  ParsingStateCurState = enum Bored, Cartographing
  ParsingState = object
    curState: ParsingStateCurState
    idx: int
    alm: Almanac
    num: int
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
    s = ParsingState(curState: Bored)


  while true:
    # echo "<<<", input[s.idx .. min(s.idx + 20, input.len-1)], "...>>> "
    # echo s.idx, ", ", input.len-1, ": ", s.curState
    if input.scanp(s.idx, '\L'):
      s.curState = Bored
      if s.map.rules.len > 0:
        s.alm.maps.add s.map
        s.map = Mapping()
      continue

    case s.curState:
    of Bored:
      if input.scanp(s.idx, ("seeds:", +(' ', (+{'0'..'9'} -> addDigit(s.num,
          $_))) -> s.endSeed(), '\L') -> s.endSeed()):
        for i, val in s.alm.seeds.pairs:
          if i mod 2 == 1: continue
          s.alm.seedranges.add val .. val + s.alm.seeds[i+1]
        continue

      elif input.scanp(s.idx, (+{'a' .. 'z'} -> s.map.src.add $_), "-to-", (+{
          'a' .. 'z'} -> s.map.dst.add $_), " map:", '\L'):
        s.curState = Cartographing
        # echo "starting map: src={s.map.src} dst={s.map.dst}".fmt
        continue

    of Cartographing:
      if input.scanp(s.idx,
            (+{'0' .. '9'}) -> addDigit(s.rule.dst, $_), ' ') and
          input.scanp(s.idx,
            (+{'0' .. '9'}) -> addDigit(s.rule.src, $_), ' ') and
          input.scanp(s.idx,
            (+{'0' .. '9'}) -> addDigit(s.rule.size, $_), '\L'):
        s.map.rules.add s.rule
        s.rule = MapRule() # 196
        continue

    if s.idx < input.len:
      raise LibraryError.newException "no more parsing rules but not at eof? idx={s.idx} len={input.len} rest={input[s.idx..input.len-1]}".fmt

    if s.map.rules.len > 0:
      s.alm.maps.add s.map
      s.map = Mapping()

    break

  s.alm

proc locationOf(almanac: Almanac, seed: int): int =
  var loc = seed

  for map in almanac.maps:
    for rule in map.rules:
      if loc in rule.src .. rule.src + rule.size - 1:
        loc = loc - rule.src + rule.dst
        break

  loc

proc min(almanac: Almanac): int =
  almanac.seeds
    .mapIt(almanac.locationOf it)
    .min

proc rangePairsMin(almanac: Almanac): int =
  var lowest = almanac.seedranges[0].a
  for range in almanac.seedranges:
    for i in range:
      let loc = almanac.locationOf i
      if lowest == -1 or loc < lowest:
        lowest = loc
  lowest

when isMainModule:
  block:
    let almanac = initAlmanac sampleData
    echo "sample/day05-part1: {almanac.min}".fmt
    echo "sample/day05-part2: {almanac.rangePairsMin}".fmt

  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
  let
    almanac = initAlmanac readFile params[0]
    lowest = almanac.min

  echo "day05-part1: {lowest}".fmt
  let
    lowestRP = almanac.rangePairsMin

  echo "day05-part2: {lowestRP}".fmt

