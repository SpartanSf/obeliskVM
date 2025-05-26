--[[

THIS TEST REQUIRES VLSCRIPT

]]


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


local start = os.epoch() / 1000
obeliskoid:quickBytecode(0, vlscript.compile(vlscript.buildAST(vlscript.tokenize(code))))
local endtime = os.epoch() / 1000
local partA = endtime - start


start = os.epoch() / 1000

local ans
repeat
    ans = obeliskoid:run() -- Runs 1 cycle of the VM
until ans

endtime = os.epoch() / 1000

local partB = endtime - start
print("Final output information:\n")
print("Stack: "..textutils.serialise(obeliskoid.stack))
print("Variables: "..textutils.serialise(obeliskoid.variables))

print("Compiled vlscript program in "..partA.."ms")
print("Ran program in "..partB.."ms")
print("Compilation & runtime "..partA+partB.."ms")
