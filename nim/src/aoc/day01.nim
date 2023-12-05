import std / [os, options, strutils, syncio, strtabs]

var textual = {
  "zero": "0",
  "one": "1",
  "two": "2",
  "three": "3",
  "four": "4",
  "five": "5",
  "six": "6",
  "seven": "7",
  "eight": "8",
  "nine": "9"
}

template chkdigit(str: string, ch: char): bool = ch >= '0' and ch <= '9'
template chktxt (txt, str: string, n: int): bool =
  let nn = n + txt.len - 1
  if nn > str.len - 1: false
  else: txt == str[n .. nn]

proc chk(str: string, at: int, ch: char): Option[string] =
  if chkdigit(str, ch): return some $ch
  for (txt, res) in textual:
    if chktxt(txt, str, at): return some $res
  none string

template ok(first, last, s: untyped) =
  if isnone first: first = some s
  last = some s

proc extract(str: string): int =
  var first, last: Option[string]

  for i, ch in pairs str:
    let res = chk(str, i, ch)
    if issome res:
      ok(first, last, get res)

  if first.isnone or last.isnone:
    raise newException(Exception, "it dont got numbers: " & str)

  ($first.get & $last.get).parseInt


proc parse*(fn: string): int =
  var sum: int = 0
  for line in fn.lines:
    sum += extract line
  sum


when isMainModule:
  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
  echo parse(params[0])
