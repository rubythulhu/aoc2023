
import std/[
  options,
  os,
  re,
  strformat,
  strutils,
  tables,
]

const
  sampleData1 = staticRead "../../inputs/08/sample1.txt"
  sampleData2 = staticRead "../../inputs/08/sample2.txt"

let # std/re can't be compile time / const :(
  mappingRegex = re"^(\w+)\s+=\s+\((\w+),\s*(\w+)\)$"

type
  NodeID = int # should be `distinct int` but i am too lazy to figure out the `{.borrow.}`'s
  WordToNodeID = TableRef[string, NodeID]
  RevWordToNodeID = TableRef[NodeID, string]
  Mapping = TableRef[NodeID, NodeID]
  Direction = enum Left, Right
  Directions = seq[Direction]
  Challenge = object
    directions: Directions
    lookup: WordToNodeID
    lookupRev: RevWordToNodeID
    idx: NodeID
    first: NodeID
    last: NodeID
    left: Mapping
    right: Mapping

proc addWord(challenge: var Challenge, word: string): NodeID {.inline.} =
  let
    lut = challenge.lookup

  if lut.hasKey(word): result = lut[word]
  else:
    inc challenge.idx
    let idx = NodeID(challenge.idx)
    lut[word] = idx
    challenge.lookupRev[idx] = word
    result = idx

  if word == "AAA": challenge.first = lut[word]
  if word == "ZZZ": challenge.last = lut[word]

proc steps(challenge: Challenge): int =
  var
    cur = challenge.first
    steps = 0
  while true:
    let dir = challenge.directions[steps mod 3]
    inc steps
    let nxt: NodeID =
      if dir == Left: challenge.left[cur]
      else: challenge.right[cur]
    # echo "cur: {challenge.lookupRev[cur]}, dir: {dir} nxt: {challenge.lookupRev[nxt]}".fmt

    if nxt == challenge.last:
      return steps
    elif nxt == cur:
      raise LibraryError.newException "oh no"
    else:
      cur = nxt

  steps


proc parseMappingLine(input: string): Option[(string, string, string)] =
  var matches: array[4, string]
  if not input.match(mappingRegex, matches):
    return none (string, string, string)
  let
    word = matches[0]
    left = matches[1]
    right = matches[2]
  some (word, left, right)

proc initChallenge(input: string): Challenge =
  var challenge = Challenge()
  challenge.lookup = newTable[string, NodeID]()
  challenge.lookupRev = newTable[NodeID, string]()
  challenge.left = newTable[NodeID, NodeID]()
  challenge.right = newTable[NodeID, NodeID]()

  let lines = input.splitLines()

  for i, line in pairs lines:
    if line.len == 0: continue

    if challenge.directions.len == 0:
      for ch in line:
        let dir = if ch == 'L': Left else: Right
        challenge.directions.add dir
      continue

    let res = parseMappingLine line
    if res.isnone: raise LibraryError.newException "invalid line: {line=}".fmt

    let (word, left, right) = res.get

    let
      curNode = challenge.addWord word
      leftNode = challenge.addWord left
      rightNode = challenge.addWord right

    challenge.left[curNode] = leftNode
    challenge.right[curNode] = rightNode

  challenge

when isMainModule and not defined(release):
  block:
    let sample1 = initChallenge sampleData1
    assert sample1.steps == 2
    let sample2 = initChallenge sampleData2
    assert sample2.steps == 6

when isMainModule:
  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
  let races = initChallenge readFile params[0]
