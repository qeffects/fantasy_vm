--- @class cpuClass
--- @field memory table
--- @field gpRegisters table
--- @field instructionSet instructionSetClass
--- @field stackRegister table
--- @field sleepT table
local cpu = {}
cpu.__index = cpu

local maxStackDepth = 100
local memorySize = 1000
local gpRegisterAmount = 10

UPDATE_TIME = 0.033 --one instruction per frame , false = never, number = seconds to wait

function cpu.new(instructionSet)
    local self = {
        memoryAddressRegister = 0, --Current memory index
        memoryDataRegister = nil, --Current memory index data
        memory = {}, --array of accessible addresses
        programMemory = {}, --array of instructions

        gpRegisters = {}, --General purpose registers
        stackRegister = { stack = {}, currentPos = 0 }, --Stack register
        programCounter = 1, --next instruction address

        devices = {},
        devBuses = {},

        statusCode = 0, --0 idle / 1 active / 2 sleeping / 3 dead
        statusDetails = '',
        sleepT = {active = false, time = 0},
        accumulator = 0,
        frequency = 0,
        peakfrequency = 0,
    }

    for i = 1, memorySize do
        self.memory[i] = {data = false}
    end

    for i = 1, gpRegisterAmount do
        self.gpRegisters['R'..i] = {data = false}
    end

    self.gpRegisters['RMA'] = {data = false}
    self.gpRegisters['RMD'] = {data = false}

    self.gpRegisters['RDBA'] = {data = false}
    self.gpRegisters['RDMA'] = {data = false}
    self.gpRegisters['RDMD'] = {data = false}

    local c = setmetatable(self, cpu)
    c.instructionSet = instructionSet.new(c)

    return c
end

-- Array of sequential instructions and arguments to be executed
function cpu:load(instructions)
    --Indicate that the CPU is active
    self.statusCode = 1

    --Point to the first instruction
    self.programCounter = 1

	--Reset the memory and registers to empty 
	self.memory = {}
    
    for i = 1, gpRegisterAmount do
        self.gpRegisters['R'..i] = {data = false}
    end

    self.gpRegisters['RMA'] = {data = false}
    self.gpRegisters['RMD'] = {data = false}

    self.gpRegisters['RDBA'] = {data = false}
    self.gpRegisters['RDMA'] = {data = false}
    self.gpRegisters['RDMD'] = {data = false}

    --Reset any crashed text
    self.statusDetails = ''

    --Store the instructions in memory
    self.programMemory = instructions
end

--Outwards facing update
function cpu:update(dt)
    if UPDATE_TIME then
        if type(UPDATE_TIME) =="number" then
            self.accumulator = math.min(self.accumulator+dt, 1)
            local count = 0 
            repeat
                count = count + 1
                if self.accumulator > UPDATE_TIME then
                    
                    if self.statusCode == 1 then
                        local st = love.timer.getTime()
                        self:executeNext()
                        local ft = love.timer.getTime()-st
                        self.accumulator = self.accumulator - math.max(ft,UPDATE_TIME)
                    else
                        self.accumulator = 0
                        self.peakfrequency = 0
                    end
                    
                end
            
            until self.accumulator < UPDATE_TIME
            
            self.frequency = 1/(dt/count)

            self.peakfrequency = math.max(self.peakfrequency, self.frequency)

            if self.statusCode == 2 then
                self:status2(dt)
            end
        else
            if self.statusCode == 1 then
                self:executeNext()
            elseif self.statusCode == 2 then
                self:status2(dt)
            end
        end
    end
end

function cpu:compileAOT()
    self.preCompiled = true
    self.instructionMemory = {}

    for i, inst in ipairs(self.programMemory) do
        local s, e = self.instructionSet:preCompile(inst)

        self.instructionMemory[i] = {s = s, e = e}        
        if s == false then
            return self:crash(e)
        end
    end
    
end

--Internal update (basically :3)
function cpu:executeNext()
    self.oldProgCounter = self.programCounter
    
    self.programCounter = self.programCounter + 1

    if self.preCompiled then
        return self:executeAOT()
    end

    if not self.programMemory[self.oldProgCounter] then
        self.statusCode = 0
        self.statusDetails = 'Program Finished'
        return
    end

    local s, e = self.instructionSet:exec(self.programMemory[self.oldProgCounter])

    if s == false then
        self:crash(e)
    end
end

function cpu:executeAOT()
    if not self.instructionMemory[self.oldProgCounter] then
        self.statusCode = 0
        self.statusDetails = 'Program Finished'
        return
    end

    local s, e = self.instructionSet:runCompiled(self.instructionMemory[self.oldProgCounter].s, self.instructionMemory[self.oldProgCounter].e)
    
    if s == false then
        self:crash(e)
    end
end

--Mostly for labels, but who knows
function cpu:findInstruction(text)
    for index, instruction in ipairs(self.programMemory) do
        if instruction == text then
            return index
        end
    end
end

--Sets a gp register
function cpu:setRegister(regNum, data)
    if self.gpRegisters[regNum] then
        if regNum == 'RMA' then
            if self.memory[data] then
                self.gpRegisters['RMD'].data = self.memory[data].data
            else
                return self:crash('Tried to access memory out of range')
            end
        end

        if regNum == 'RMD' then
            local index = self.gpRegisters["RMA"].data

            if self.memory[index] then
                self.memory[index].data = data
            else
                return self:crash('Tried to access memory out of range')
            end
        end

        --Device bus address
        if regNum == 'RDBA' then
            if not self.devices[data] then
                return self:crash('Tried to set device bus register to a non-existant device '..data)
            end
        end

        --Device memory address
        if regNum == 'RDMA' then
            if not self.gpRegisters.RDBA.data then
                return self:crash('Set device bus first '..data)
            else
                if not self.devices[self.gpRegisters.RDBA.data].implements.DMI then
                    return self:crash(self.gpRegisters.RDBA.data..' doesnt implement memory access')
                else
                    if not self.devices[self.gpRegisters.RDBA.data]:check(data) then
                        return self:crash('tried to access device memory out of bounds '..self.gpRegisters.RDBA.data..':'..data)
                    end
                end
            end
        end

        --Device memory data
        if regNum == 'RDMD' then
            if not self.gpRegisters.RDBA.data or not self.gpRegisters.RDMA.data then
                return self:crash('Tried to set undefined devices memory, set RDBA and RDMA first')
            end

            if self.devices[self.gpRegisters.RDBA.data].implements.DMI then
                self.gpRegisters[regNum].data = data
                return self.devices[self.gpRegisters.RDBA.data]:set(self.gpRegisters.RDMA.data, data)
            else
                return self:crash(self.gpRegisters.RDBA.data..' doesnt implement memory access')
            end
        end

        self.gpRegisters[regNum].data = data
    else
        self:crash('Error setting data: Register '..regNum..' doesnt exist')
    end
end

--Gets data from register
function cpu:getRegister(regNum)
    if self.gpRegisters[regNum] then
        if regNum == 'RDMD' then
            self.gpRegisters[regNum].data = self.devices[self.gpRegisters.RDBA.data]:get(self.gpRegisters.RDMA.data)
        end
        return self.gpRegisters[regNum].data
    else
        self:crash('Error getting data: Register '..regNum..' doesnt exist')
    end
end

--Pushes data to stack register
function cpu:push(a,b,c,d,e,f)
    if self.stackRegister.currentPos <= 0 then
        self.stackRegister.currentPos  = 1
    elseif self.stackRegister.currentPos >= 1 then
        self.stackRegister.currentPos = self.stackRegister.currentPos + 1
    end
    self.stackRegister.stack[self.stackRegister.currentPos] = {a,b,c,d,e,f}
    if self.stackRegister.currentPos > maxStackDepth then
        self:crash('Reached max stack depth')
    end
end

--Pops data from stack register
function cpu:pop()
    if self.stackRegister.currentPos < 1 then
        return nil
    end

    local d = self.stackRegister.stack[self.stackRegister.currentPos]

    if self.stackRegister.currentPos > 0 then
        self.stackRegister.currentPos = self.stackRegister.currentPos - 1
    end

    return d[1],d[2],d[3],d[4],d[5],d[6]
end

function cpu:setProgramCounter(address)
    self.programCounter = address
end

function cpu:addDevice(device)
    self.devices[device.address] = device
end

function cpu:finish()
    self.statusCode = 0

    self.statusDetails = 'Finished'
end

function cpu:sleep(seconds)
    self.sleepT.active = true
    self.sleepT.time = seconds
    self.statusCode = 2
end

function cpu:status2(dt)
    self.sleepT.time = self.sleepT.time - dt
    if self.sleepT.time < 0 then
        self.statusCode = 1
        self.sleepT.active = false
    end
end

function cpu:crash(err)
    self.statusCode = 3

    self.statusDetails = err
end

return cpu