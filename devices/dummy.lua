--Test device
---@class dummy
local dummy = {
    implements = {
        DMI = true,
        PUSH = true,
        PULL = true,
    },
    name = 'DummyDevice',
    address = 'DMD0',
    memoryWidth = 10
}
dummy.__index = dummy

---@return dummy
function dummy.new()
    local self = {
        inStack = {},
        outStack = {},
        memory = {},
    }

    for i = 1, dummy.memoryWidth do
        self.memory[i] = {
            data = false
        }
    end

    return setmetatable(self, dummy)
end

--Up to six arguments containing whatever
function dummy:push(a, b, c, d, e, f)
    
end

function dummy:pull()
    
end

--Sets memory addr to val
function dummy:set(addr, val)
    self.memory[addr].data = val
end

--Gets from memory addr 
function dummy:get(addr)
    return self.memory[addr].data
end

--Checks if the addr is available
function dummy:check(addr)
    return addr <= self.memoryWidth
end

return dummy