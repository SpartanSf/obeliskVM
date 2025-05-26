# obeliskVM
Stack-based VM for ComputerCraft: Tweaked

Supported languages:
- [vlscript](https://github.com/SpartanSf/vlscript/)

## Installation
Run `wget run https://raw.githubusercontent.com/SpartanSf/obeliskVM/main/install.lua`

## Demo
Yes, VLScript over the obeliskVM can run much faster than Lua in some cases (this has obeliskVM up to 180x faster than the lua equivalent). The magic of bypass the Lua VM's overhead and placing your own VM on it.
```lua
--[[

THIS TEST REQUIRES VLSCRIPT

]]


local obelisk = require("obelisk")
local vlscript = require("vlscript")

local code = [[
define main {
    let x 5000000000
    let f #'loop
    call f
    halt
}

define loop {
    - x x 1
    if = x 0 {
        return
    }
    jump f
}

]]

local obeliskoid = obelisk.new()

local data = vlscript.compile(vlscript.buildAST(vlscript.tokenize(code)))

obeliskoid:quickBytecode(0, data)

obeliskoid:run()

print("Final output information:\n")
print("Stack: "..textutils.serialise(obeliskoid.stack))
print("Variables: "..textutils.serialise(obeliskoid.variables))
```
