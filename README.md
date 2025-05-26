# obeliskVM
Stack-based VM for ComputerCraft: Tweaked

Supported languages:
- [vlscript](https://github.com/SpartanSf/vlscript/)

## Installation
Run `wget run https://raw.githubusercontent.com/SpartanSf/obeliskVM/main/install.lua`

## Demo

```lua
local obelisk = require("obelisk")
local vlscript = require("vlscript")


-- vlscript code
local code = [[
define main {
    let x 5

    define loop {
        sub x x 1
        if = x 0 {
            halt
        }
        jump loop
    }
}
]]

local obeliskoid = obelisk.new() -- Spawn a new obelisk VM instance

-- Completely compile and load the bytecode for the previous vlscript script
obeliskoid:quickBytecode(0, vlscript.compile(vlscript.buildAST(vlscript.tokenize(code))))

obeliskoid:run() -- Runs the VM

print("Final output information:\n")
print("Stack: "..textutils.serialise(obeliskoid.stack))
print("Variables: "..textutils.serialise(obeliskoid.variables)) -- Should have x = 0, as x was decremented until 0
```
