local bit = require("bit")
local obelisk = {}
local log = fs.open("obl.log", "w")

local doLog = false

function obelisk.new()
    local obeliskoid = {
        stack = {},
        stackTop = 0,
        bytecode = {},
        variables = {},
        functions = {},
        flags = { equal = false, zero = false },
        PC = 0,
    }

    local function push(self, val)
        self.stackTop = self.stackTop + 1
        self.stack[self.stackTop] = val
        if self.stackTop > 0x7FF then
            self:stackOverflow()
        end
    end

    local function pop(self)
        if self.stackTop == 0 then
            self:stackUnderflow()
        end
        local val = self.stack[self.stackTop]
        self.stack[self.stackTop] = nil
        self.stackTop = self.stackTop - 1
        return val
    end

    local function pushEnv(self)
        table.insert(self.variables, {})
    end

    local function popEnv(self)
        table.remove(self.variables)
    end

    local function getVar(self, name)
        for i = #self.variables, 1, -1 do
            local frame = self.variables[i]
            if frame[name] ~= nil then
                return frame[name]
            end
        end
        error("Undefined variable: " .. (name or ""), 0)
    end

    local function setVar(self, name, value)
        for i = #self.variables, 1, -1 do
            local frame = self.variables[i]
            if frame[name] ~= nil then
                frame[name] = value
                return
            end
        end
        self.variables[#self.variables][name] = value
    end

    local handlers = {
        PUSH_IMMEDIATE = function(self, arg)
            push(self, bit.band(arg, 0xFFFF))
        end,

        PUSH_VARIABLE = function(self, name)
            push(self, getVar(self, name))
        end,

        ADD = function(self)
            push(self, pop(self) + pop(self))
        end,

        SUB = function(self)
            push(self, pop(self) - pop(self))
        end,

        MUL = function(self)
            push(self, pop(self) * pop(self))
        end,

        DIV = function(self)
            local b = pop(self)
            local a = pop(self)
            push(self, a / b)
        end,

        CMP = function(self)
            local b = pop(self)
            local a = pop(self)
            self.flags.zero = (b == 0)
            self.flags.equal = (a == b)
        end,

        SET = function(self, name)
            setVar(self, name, pop(self))
        end,

        JUMP = function(self)
            self.PC = pop(self) - 1
        end,

        JUMP_IF_ZERO = function(self)
            local loc = pop(self)
            if self.flags.zero then
                self.PC = loc - 1
            end
        end,

        JUMP_IF_NONZERO = function(self)
            local loc = pop(self)
            if not self.flags.zero then
                self.PC = loc - 1
            end
        end,

        JUMP_IF_EQUAL = function(self)
            local loc = pop(self)
            if self.flags.equal then
                self.PC = loc - 1
            end
        end,

        JUMP_IF_NONEQUAL = function(self)
            local loc = pop(self)
            if not self.flags.equal then
                self.PC = loc - 1
            end
        end,

        CALL = function(self)
            local loc = pop(self)
            push(self, self.PC + 1)
            pushEnv(self)
            self.PC = loc - 1
        end,

        RETURN = function(self)
            popEnv(self)
            self.PC = pop(self) - 1
        end,

        PUSHENV = function(self)
            pushEnv(self)
        end,

        POPENV = function(self)
            popEnv(self)
        end,

        HALT = function(self)
            self.halted = true
        end,
    }

    function obeliskoid:run(cycles)
        cycles = cycles or -1
        local currentCycle = 0
        self.halted = false
        while not self.halted and cycles ~= currentCycle do
            currentCycle = currentCycle + 1
            local instruction = self.bytecode[self.PC]

            if not instruction then
                error("Obelisk could not find bytecode at: " .. self.PC, 0)
            end

            if doLog then
                log.writeLine(instruction[1].." executing with parameter "..(instruction[2] or ""))
                log.writeLine("PC: "..self.PC..": "..textutils.serialise(instruction, {compact = true}))
                log.flush()
            end

            local opcode = instruction[1]
            local handler = handlers[opcode]
            if not handler then
                error("Unknown opcode: " .. tostring(opcode), 0)
            end

            handler(self, instruction[2])

            self.PC = bit.band(self.PC + 1, 0xFFFF)

            if doLog then
                log.writeLine("PC: "..self.PC..": "..textutils.serialise(self.bytecode[self.PC], {compact = true}))
                log.writeLine(instruction[1].." executed\n\n")
                log.flush()
            end
        end
        return self.halted
    end

    function obeliskoid:quickBytecode(location, bytecode)
        for i = 1, #bytecode do
            self.bytecode[location + i - 1] = bytecode[i]
        end
    end

    function obeliskoid:stackOverflow()
        error("Stack overflow", 0)
    end

    function obeliskoid:stackUnderflow()
        error("Stack underflow", 0)
    end

    return obeliskoid
end

return obelisk
