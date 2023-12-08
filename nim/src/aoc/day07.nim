import std/[
  os,
  sequtils,
  strformat,
  strutils,
]

const
  sampleData = staticRead "../../inputs/07/sample.txt"

when isMainModule:
  block:
    # TODO: add sample data checks
    discard

when isMainModule:
  let params = commandLineParams()
  if params.len != 1: quit("give me a file name", 1)
