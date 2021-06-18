love.window.setMode(1280, 720, {resizable = true})
local IS = require('is')
local CPU = require('cpu')
local localCpu = CPU.new(IS)

local dummy = require('devices.dummy')
local localDummy = dummy.new()

local helium = require('helium')
local scene = helium.scene.new(true)
scene:activate()

local root = require('ui.root')({cpu = localCpu},800, 600)
root:draw(0,0, 1280, 720)

love.graphics.setLineWidth(2)

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

function love.resize(nw, nh)
	scene:resize(nw, nh)
	root:draw(0,0,nw,nh)
end

function love.update(dt)
	scene:update(dt)
    localCpu:update(dt)
end

function love.draw()
	scene:draw()
    --[[love.graphics.print('Stack: ', 0, 300)
    for i = 1, localCpu.stackRegister.currentPos do
        love.graphics.print(''..i..': ['..tostring(localCpu.stackRegister.stack[i][1])..']',0, 300 + fontSize*i)
    end]]

    
end

function STEP_CPU()
	localCpu:executeNext()
end

function love.keypressed(key)
    if key == 'return' then
        localCpu:load(code)
        localCpu:compileAOT()
        localCpu:addDevice(localDummy)
    end
end