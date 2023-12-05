# Package

version       = "0.1.0"
author        = "rubythulhu"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
binDir        = "bin"

namedBin["nim_aoc_2023/day01"] = "day01"
namedBin["nim_aoc_2023/day02"] = "day02"
namedBin["nim_aoc_2023/day03"] = "day03"

# Dependencies
 
requires "nim >= 2.0.0"

task docs, "build docs for all":
  exec "nimble doc src/**/*.nim"

task all, "all build tasks":
  exec "nimble build"
  exec "nimble docs"
  exec "nimble test"

task release, "all build tasks (release)":
  exec "nimble build -d:release"
  exec "nimble docs"
  exec "nimble test"
