love.window.setMode(1280, 720, {resizable = true})
local IS = require('is')
local CPU = require('cpu')
local localCpu = CPU.new(IS)

local dummy = require('devices.dummy')
local localDummy = dummy.new()

local helium = require('helium')
local scene = helium.scene.new(false)
scene:activate()

local root = require('ui.root')({cpu = localCpu, busDevice = localDummy},800, 600)
root:draw(0,0, 1280, 720)

love.graphics.setLineWidth(2)

local code = {}
for line in love.filesystem.lines("opcodes") do
  table.insert(code, line)
end

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