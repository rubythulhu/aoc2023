# i had a thing here but i am going to start over :)

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
    
  Position* = tuple[x,y: int]
  Dimensions* = tuple[w,h: int]
  NumSpan* = tuple[x,y,sz,val: int]

  Schematic* = object 
    dim*: Dimensions
    data*: seq[Item]
    nums*: seq[NumSpan]


proc `~@`*(pos: Position, dim: Dimensions): int = (pos.x + dim.w * pos.y)
proc `@~`*(val: int, dim: Dimensions): Position = (val div dim.w, val mod dim.w)

proc `[]`*(sch: Schematic, pos: Position): Item = sch.data[pos ~@ sch.dim]
proc `[]`*(sch: Schematic, x,y: int): Item = sch[(x,y)]
proc `[]`*(sch: Schematic, idx: int): Item = sch[idx @~ sch.dim]

proc `[]=`*(sch: var Schematic, pos: Position, item: Item) = sch.data[pos ~@ sch.dim] = item
proc `[]=`*(sch: var Schematic, x,y: int, item: Item) = sch[(x,y)] = item
proc `[]=`*(sch: var Schematic, idx: int, item: Item) = sch[idx @~ sch.dim] = item

proc cellCount*(dim:Dimensions): int = ( dim.w * dim.h ) - 1

iterator cells*(dim: Dimensions): tuple[x,y, idx: int] =
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

proc hasLen*(s:string): bool = 
  s.len > 0

proc isPartNumber(sch: Schematic, num: NumSpan): bool =
  let xrange = num.x .. num.x + num.sz - 1
  var neighbors = 0
  # var derp= "\n"
  
  for y in num.y-1..num.y + 1:
    for x in num.x-1..num.x + num.sz:
      let idx = (x,y) ~@ sch.dim
      # echo "{x=} {y=} {idx=}".fmt
      if idx < 0 or 
        idx > sch.data.len-1 or 
        x < 0 or 
        x > sch.dim.w-1 or
        y < 0 or 
        y > sch.dim.h-1: 
          # derp.add "\e[1;31m✖\e[0m"
          continue 
      # echo "  ch={sch.data[idx].ch}".fmt
      let item = sch.data[idx] 

      # derp.add if item.ch in Digits: "\e[0;1;36m{item.ch}\e[0m".fmt
      #   elif item.ch in SymbolChars: "\e[0;1;32m{item.ch}\e[0m".fmt
      #   else : $item.ch
      if y == num.y and x in xrange: 
        # derp.add "\e[0;1;31m"
        continue
      if item.kind == sym: inc neighbors
    # derp.add "\n"

  # echo "{num=} {neighbors=} {derp=}".fmt

  neighbors > 0

proc parts*(sch: Schematic): seq[int] =
  sch.nums.filterIt(sch.isPartNumber it).mapIt(it.val)

proc findNums(data: seq[Item], dim: Dimensions): seq[NumSpan] = 
  type State = enum In,Out
  var 
    state = Out 
    cur: NumSpan = (0, 0, 0, 0)
    curstr = ""
    nums = newSeq[NumSpan]()

  template endWord() =
    cur.val = curstr.parseInt
    nums.add cur 
    cur = (0, 0, 0, 0)
    curstr = ""
    state = Out

  for (x,y,idx) in dim.cells:
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
      case state:
      of In: endWord()
      of Out: discard

  if cur.x != 0: 
    cur.val = curstr.parseInt
    nums.add cur

  nums

proc `$`(sch: Schematic): string =
  var digits, dots, symbols = 0
  for item in sch.data:
    case item.kind
    of digit: inc digits 
    of dot: inc dots
    of sym: inc symbols

  let data = sch.data.mapIt(it.ch).join ""
  let nums = sch.nums.mapIt("    @ {(it.x,it.y)} : {it.val} ({it.sz}) ({sch.isPartNumber it})".fmt).join "\n"
  """
  [Schematic:
    Dimensions: {sch.dim.w} x {sch.dim.h}
    digits: {digits}
    dots: {dots}
    symbols: {symbols}
    nums: {'\n'}{nums}
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
    
  let nums = chars.findNums( (width, height) )

  Schematic(dim: (width, height), data: chars, nums: nums)


proc day03part1*(input: string): int = 
  let sch = initSchematic(input)
  # echo $sch
  let p = sch.parts
  # echo "{p=}".fmt
  p.foldl(a + b)


when isMainModule:
  block:
    let sum = day03part1 sampleData
    echo "sample / part1: {sum=}".fmt
    # echo sampleData


when isMainModule:
  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1) 
  let sum = params[0].readFile.day03part1
  echo "part1: {sum=}".fmt


