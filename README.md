# obeliskVM
Stack-based VM for ComputerCraft: Tweaked

Supported languages:
- [vlscript](https://github.com/SpartanSf/vlscript/)

## Installation
Copy `obelisk.lua` and `bit.lua`

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

local done
repeat
    done = obeliskoid:run() -- Runs 1 cycle of the VM
until done -- Repeats until VM signals done

print("Final output information:\n")
print("Stack: "..textutils.serialise(obeliskoid.stack))
print("Variables: "..textutils.serialise(obeliskoid.variables))
```
