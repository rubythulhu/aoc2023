# Package

version       = "0.1.0"
author        = "rubythulhu"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nimaoc01", "nimaoc02", "nimaoc03"]
binDir        = "bin"


# Dependencies

requires "nim >= 2.0.0"

task alldocs, "all docs?":
  exec "nimble doc src/*.nim"

task all, "all build tasks": 
  alldocsTask()
