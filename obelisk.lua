local bit = require("bit")

local obelisk = {}

function obelisk.new()
    local obeliskoid = {
        stack = {},
        bytecode = {},
        variables = {},
        functions = {},
        flags = {equal = false, zero = false},
        PC = 0,
    }

    local function pop(self)
        if #self.stack <= 0 then
            self.stackUnderflow()
        else
            return table.remove(self.stack)
        end
    end

    local function push(self, val)
        if #self.stack >= 0x7FF then
            self.stackOverflow()
        else
            self.stack[#self.stack+1] = val
        end
    end

    local function pushEnv(self)
        table.insert(self.variables, {})
    end

    local function popEnv(self)
        table.remove(self.variables)
    end

    local function getVar(self, name)
        for i = #self.variables, 1, -1 do
            if self.variables[i][name] ~= nil then
                return self.variables[i][name]
            end
        end
        error("Undefined variable: "..name, 0)
    end

    local function setVar(self, name, value)
        for i = #self.variables, 1, -1 do
            if self.variables[i][name] ~= nil then
                self.variables[i][name] = value
                return
            end
        end
        self.variables[#self.variables][name] = value
    end

    function obeliskoid:run()
        local instruction = self.bytecode[self.PC]
        if not instruction then error("Obelisk could not find bytecode at "..self.PC, 0) end

        --print(instruction[1])

        if instruction[1] == "PUSH_IMMEDIATE" then
            push(self, bit.band(instruction[2], 0xFFFF))
        elseif instruction[1] == "PUSH_VARIABLE" then
            local var = getVar(self, instruction[2])
            if var == nil then error("Attempt to push a nil variable to stack", 0) end
            push(self, var)
        elseif instruction[1] == "ADD" then
            local res = pop(self) + pop(self)
            push(self, res)
        elseif instruction[1] == "SUB" then
            local res = pop(self) - pop(self)
            push(self, res)
        elseif instruction[1] == "MUL" then
            local res = pop(self) * pop(self)
            push(self, res)
        elseif instruction[1] == "DIV" then
            local res = pop(self) / pop(self)
            push(self, res)
        elseif instruction[1] == "CMP" then
            local val = pop(self)
            local val2 = pop(self)
            self.flags.zero = val == 0
            self.flags.equal = val == val2
        elseif instruction[1] == "SET" then
            setVar(self, instruction[2], pop(self))
        elseif instruction[1] == "JUMP" then
            self.PC = pop(self) - 1
        elseif instruction[1] == "JUMP_IF_ZERO" then
            local location = pop(self)
            if self.flags.zero == true then
                self.PC = location - 1
            end
        elseif instruction[1] == "JUMP_IF_NONZERO" then
            local location = pop(self)
            if self.flags.zero == false then
                self.PC = location - 1
            end
        elseif instruction[1] == "JUMP_IF_EQUAL" then
            local location = pop(self)
            if self.flags.equal == true then
                self.PC = location - 1
            end
        elseif instruction[1] == "JUMP_IF_NONEQUAL" then
            local location = pop(self)
            if self.flags.equal == false then
                self.PC = location - 1
            end
        elseif instruction[1] == "CALL" then
            local location = pop(self)
            push(self, self.PC)
            self.PC = location - 1
        elseif instruction[1] == "PUSHENV" then
            pushEnv(self)
        elseif instruction[1] == "POPENV" then
            popEnv(self)
        elseif instruction[1] == "HALT" then
            return true
        end
        self.PC = bit.band(self.PC + 1, 0xFFFF)
    end

    function obeliskoid:quickBytecode(location, bytecode)
        for i = 1, #bytecode do
            self.bytecode[location + i - 1] = bytecode[i]
        end
    end

    function obeliskoid:stackOverflow() -- If you are in an environment requiring it, you can overwrite these
        error("Stack overflow", 0)
    end

    function obeliskoid:stackUnderflow()
        error("Stack underflow", 0)
    end

    return obeliskoid
end

return obelisk
