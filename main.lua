love.window.setMode(1280, 720)
local CPU = require('cpu')
local IS = require('is')
local cpu = require "cpu"
local localCpu = CPU.new(IS)
local dummy = require('devices.dummy')
local localDummy = dummy.new()

local font = love.graphics.newFont('RobotoMono-Regular.ttf', 26)
local fontSmall = love.graphics.newFont('RobotoMono-Regular.ttf', 12)
local fontSize = 26

local code = {
    'SET:RDBA,DMD0',
    'SET:R1,0',
    '{FILL}',
    'ADD:R1,1',
    'SET:RDMA,R1',
    'MOD:R1,2,R2',
    'CMPL:R2,0,1,RDMD',
    'CMPE:0,R2,0,RDMD',
    'JMPL:10,R1,FILL',
    '{START}',
    'SET:R1,0',
    '{FLIP}',
    'ADD:R1,1',
    'SET:RDMA,R1',
    'MOV:RDMD,R2',
    'CMPE:0,R2,1,RDMD',
    'CMPE:1,R2,0,RDMD',
    'JMPL:10,R1,FLIP',
    'SLP:0.3',
    'JMP:START',
}

function love.update(dt)
    localCpu:update(dt)
end

function love.draw()
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    local acc = 2
    love.graphics.print('Registers: ', 0, 0)
    for name, contents in pairs(localCpu.gpRegisters) do

        if not contents.data == false and not(name == 'RMA') and not(name == 'RMD') and not(name == 'RDBA') and not(name == 'RDMA') and not(name == 'RDMD') then  
            love.graphics.print(name..': '..tostring(contents.data),0, fontSize*acc)
            acc = acc + 1
        end
    end

    acc = acc + 1

    love.graphics.setColor(0, 0, 1)
    local data = localCpu.gpRegisters['RMA'].data or ''
    love.graphics.print('RMA'..': '..tostring(data),0, fontSize*acc)
    acc = acc + 1

    love.graphics.setColor(1, 0, 0)
    data = localCpu.gpRegisters['RMD'].data or ''
    love.graphics.print('RMD'..': '..tostring(data),0, fontSize*acc)
    acc = acc + 2

    love.graphics.setColor(0, 0.5, 0.5)
    local data = localCpu.gpRegisters['RDBA'].data or ''
    love.graphics.print('RDBA'..': '..tostring(data),0, fontSize*acc)
    acc = acc + 1

    love.graphics.setColor(0, 0.5, 0.5)
    data = localCpu.gpRegisters['RDMA'].data or ''
    love.graphics.print('RDMA'..': '..tostring(data),0, fontSize*acc)
    acc = acc + 1

    love.graphics.setColor(0, 0.5, 0.5)
    data = localCpu.gpRegisters['RDMD'].data or ''
    love.graphics.print('RDMD'..': '..tostring(data),0, fontSize*acc)
    acc = acc + 1


    acc = acc + 1
    love.graphics.setColor(1, 1, 1)
    love.graphics.print('Available Bus Devices: ', 0, fontSize*acc)
    for i, dev in pairs(localCpu.devices) do
        acc = acc + 1
        love.graphics.print(''..i..': ['..tostring(dev.name)..']',0, fontSize*acc)
    end
    --[[love.graphics.print('Stack: ', 0, 300)
    for i = 1, localCpu.stackRegister.currentPos do
        love.graphics.print(''..i..': ['..tostring(localCpu.stackRegister.stack[i][1])..']',0, 300 + fontSize*i)
    end]]

    acc = 2
    --love.graphics.print('Memory: ', 250, 0)
    --[[for name, contents in ipairs(localCpu.memory) do
        if name == localCpu.gpRegisters['RMA'].data then
            love.graphics.setColor(0, 0, 1)
        else
            love.graphics.setColor(1, 1, 1)
        end
        if not contents.data == false then
            love.graphics.print(name, 250, fontSize*acc)

            if name == localCpu.gpRegisters['RMA'].data then
                love.graphics.setColor(1, 0, 0)
            end

            love.graphics.print(': '..tostring(contents.data),250+30, fontSize*acc)
            acc = acc + 1
        end
    end]]
    
    love.graphics.print('Instructions:', 450, 0)
    for i, contents in ipairs(localCpu.programMemory) do
        if i == localCpu.oldProgCounter then
            love.graphics.setColor(0, 1, 0)
            local w = font:getWidth(contents)
            love.graphics.rectangle('fill' , 425, ((i+1)*fontSize)+6, w+30, fontSize-1)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print('>',430, (i+1)*fontSize)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.print(contents, 450, (i+1)*fontSize)
    end

    love.graphics.setColor(1, 1, 1)

    love.graphics.print("Bus device:", 900, 0)
    for i = 1, 10 do
        love.graphics.setColor(0.1, 0.1, 0.1)
        if localDummy.memory[i].data and localDummy.memory[i].data < 1 then
            love.graphics.setColor(1, 0, 0)
        elseif localDummy.memory[i].data == 1 then
            love.graphics.setColor(0, 1, 0)
        end
        love.graphics.rectangle('fill', 960, fontSize+i*40, 30, 30, 5)
    end

    
    love.graphics.setFont(fontSmall)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print('CPU status: '..localCpu.statusCode, 10, 550)
    love.graphics.print('CPU details: '..localCpu.statusDetails, 10, 570)
    love.graphics.print(string.format('CPU frequency: %.3fHZ',localCpu.frequency), 10, 590)
    love.graphics.print(string.format('CPU peak freq: %.3fHZ',localCpu.peakfrequency), 10, 610)
end

function love.keypressed(key)
    if key == 'return' then
        localCpu:load(code)
        localCpu:compileAOT()
        localCpu:addDevice(localDummy)
    end
    if key == 'lshift' then
        localCpu:executeNext()
    end
end