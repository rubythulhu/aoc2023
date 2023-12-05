# i had a thing here but i am going to start over :)

import std / options
import std / os
import std / sequtils
import std / strformat
import std / strutils
import std / sugar

const
  sampleData = staticRead "../../inputs/03/sample.txt"
  SymbolChars = PunctuationChars - {'.'}

type
  ItemKind* = enum dot, sym, digit
  Item* = object
    kind*: ItemKind
    ch*: char

  SchematicError* = object of ValueError

  Position* = tuple[x, y: int]
  Dimensions* = tuple[w, h: int]
  NumSpan* = tuple[x, y, sz, val: int]
  SymLoc* = tuple[x, y: int, ch: char]

  NeighborIterResult = tuple[x, y, idx: int, item: Item]

  Schematic* = object
    dim*: Dimensions
    data*: seq[Item]
    nums*: seq[NumSpan]
    syms*: seq[SymLoc]


proc `~@`*(pos: Position, dim: Dimensions): int =
  (pos.x + dim.w * pos.y)

proc `@~`*(val: int, dim: Dimensions): Position =
  (val div dim.w, val mod dim.w)

proc `[]`*(sch: Schematic, pos: Position): Item =
  sch.data[pos ~@ sch.dim]

proc `[]`*(sch: Schematic, x, y: int): Item =
  sch[(x, y)]

proc `[]`*(sch: Schematic, idx: int): Item =
  sch[idx @~ sch.dim]

proc `[]=`*(sch: var Schematic, pos: Position, item: Item) =
  sch.data[pos ~@ sch.dim] = item

proc `[]=`*(sch: var Schematic, x, y: int, item: Item) =
  sch[(x, y)] = item

proc `[]=`*(sch: var Schematic, idx: int, item: Item) =
  sch[idx @~ sch.dim] = item

proc cellCount*(dim: Dimensions): int =
  (dim.w * dim.h) - 1

iterator cells*(dim: Dimensions): tuple[x, y, idx: int] =
  for y in 0 .. dim.h - 1:
    for x in 0 .. dim.w - 1:
      let idx = (x, y) ~@ dim
      yield (x, y, idx)


proc initItem*(ch: char): Item =
  case ch:
  of Digits: Item(kind: digit, ch: ch)
  of SymbolChars: Item(kind: sym, ch: ch)
  of '.': Item(kind: dot, ch: ch)
  else: raise SchematicError.newException "not a valid schematic thingy: " & ch

proc hasLen*(s: string): bool =
  s.len > 0


iterator neighbors(sch: Schematic, pos: Position, sz: int,
    withSelf = false): NeighborIterResult =
  for y in pos.y - 1 .. pos.y + 1:
    for x in pos.x - 1 .. pos.x + sz:
      let idx = (x, y) ~@ sch.dim
      if idx notin 0..sch.data.len-1: continue
      if x notin 0..sch.dim.w-1: continue
      if y notin 0..sch.dim.h-1: continue
      let
        isLine = y == pos.y
        isInRange = x in pos.x .. pos.x + sz - 1
        isSelf = isLine and isInRange
        item = sch.data[idx]

      if isSelf and withSelf: yield (x, y, idx, item)
      elif not isSelf: yield (x, y, idx, item)

iterator neighbors(sch: Schematic, num: NumSpan,
    withSelf = false): NeighborIterResult =
  for it in sch.neighbors((num.x, num.y), num.sz, withSelf): yield it

iterator neighbors(sch: Schematic, pos: Position,
    withSelf = false): NeighborIterResult =
  for it in sch.neighbors(pos, 1, withSelf): yield it

iterator neighbors(sch: Schematic, sym: SymLoc,
    withSelf = false): NeighborIterResult =
  for it in sch.neighbors((sym.x, sym.y), 1, withSelf): yield it

proc isPartNumber(sch: Schematic, num: NumSpan): bool =
  var ct = 0

  for x, y, idx, item in sch.neighbors(num):
    if item.kind == sym:
      inc ct

  ct > 0

proc isBroken(sch: Schematic, sym: SymLoc): Option[int] =
  if sym.ch != '*': return none int
  type Candidate = tuple[x, y, idx: int]
  var candidates: seq[Candidate] = @[]
  for x, y, idx, item in sch.neighbors(sym):
    if item.kind == digit:
      candidates.add (x, y, idx)

  if candidates.len < 2: return none int

  # var seen : seq[NumSpan] = @[]
  var seen: set[int16] = {}
  var vals: seq[int] = @[]

  # echo "{sym=} {candidates=}".fmt

  for c in candidates:
    for num in sch.nums:
      if num.y != c.y: continue
      if c.x notin num.x .. num.x + num.sz - 1: continue

      let idx = int16((num.x, num.y) ~@ sch.dim)
      if idx notin seen:
        seen.incl idx
        vals.add num.val

  # echo "{seen=}".fmt
  if seen.len == 2: some vals[0] * vals[1]
  else: none int


proc parts*(sch: Schematic): seq[int] =
  sch.nums.filterIt(sch.isPartNumber it).mapIt(it.val)

proc broken*(sch: Schematic): seq[int] =
  var b = newSeq[int]()
  for sym in sch.syms:
    let res = sch.isBroken sym
    if issome res:
      b.add get res
  b

proc extract(data: seq[Item], dim: Dimensions): tuple[nums: seq[NumSpan],
    syms: seq[SymLoc]] =
  type State = enum In, Out
  var
    state = Out
    cur: NumSpan = (0, 0, 0, 0)
    curstr = ""
    nums = newSeq[NumSpan]()
    syms = newSeq[SymLoc]()

  template endWord() =
    cur.val = curstr.parseInt
    nums.add cur
    cur = (0, 0, 0, 0)
    curstr = ""
    state = Out

  for (x, y, idx) in dim.cells:
    var item = data[idx]
    if x == 0 and state == In:
      endWord()

    # let ch = item.ch
    # if y == 0: echo "\n"
    # echo "{x=},{y=},{idx=},{ch=}: {state=} > {cur=} {curstr=} ".fmt

    if item.kind == digit:
      case state:
      of In:
        curstr.add item.ch
        cur.sz = curstr.len
      of Out:
        curstr = $item.ch
        cur = (x, y, 1, 0)
        state = In

    else:
      if item.kind == sym:
        syms.add (x, y, item.ch)
      case state:
      of In: endWord()
      of Out: discard

  if cur.x != 0:
    cur.val = curstr.parseInt
    nums.add cur

  (nums, syms)

proc `$`*(sch: Schematic): string =
  var digits, dots, symbols = 0
  for item in sch.data:
    case item.kind
    of digit: inc digits
    of dot: inc dots
    of sym: inc symbols

  # let data = sch.data.mapIt(it.ch).join ""
  let nums = sch.nums.mapIt("    @ {(it.x,it.y)} : {it.val} ({it.sz}) ({sch.isPartNumber it})".fmt).join "\n"
  let syms = sch.syms.mapIt("    @ {(it.x,it.y)} : {it.ch} ".fmt).join "\n"
  """
  [Schematic:
    Dimensions: {sch.dim.w} x {sch.dim.h}
    digits: {digits}
    dots: {dots}
    symbols: {symbols}
    nums: {'\n'}{nums}
    syms: {'\n'}{syms}
  ]
  """.fmt

proc initSchematic*(input: string): Schematic =
  let
    lines = input.split(Newlines).filter hasLen
    height = lines.len
    width = lines[0].len

  var chars = newSeq[Item]()

  for line in lines:
    if line.len != width:
      raise SchematicError.newException "All lines must be the same width"
    chars.add line.items.toSeq.map initItem

  let (nums, syms) = chars.extract( (width, height))

  Schematic(dim: (width, height), data: chars, nums: nums, syms: syms)


proc day03*(input: string): tuple[part1: int, part2: int] =
  let
    sch = initSchematic(input)
    p = sch.parts
    b = sch.broken

  (p.foldl(a + b), if b.len > 0: b.foldl(a+b) else: 0)




when isMainModule:
  block:
    let (p1sum, p2sum) = day03 sampleData
    echo "sample / part1: {p1sum=}".fmt
    echo "sample / part2: {p2sum=}".fmt
    # echo sampleData


when isMainModule:
  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
  let (p1sum, p2sum) = params[0].readFile.day03
  echo "part1: {p1sum=}".fmt
  echo "part2: {p2sum=}".fmt
  assert p1sum == 521601, "answer regression"


