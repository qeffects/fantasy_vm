local lg = love.graphics
local helium = require('helium')
local onUpdate = require('helium.hooks.onUpdate')
local context = require('helium.hooks.context')
local state = require('helium.hooks.state')
local grid = require('helium.layout.grid')

local deviceFactory = require('ui.devices')
local memoryFactory = require('ui.memory')
local opcodeFactory = require('ui.opcode')
local statusFactory = require('ui.status')
local cpuSpeedFactory = require('ui.cpuSpeed')
local busDeviceFactory = require('ui.busDevice')
local registersFactory = require('ui.registers')
local verticalTrackFactory = require('ui.verticalTrack')
local collapsibleFactory = require('ui.collapsibleStack')

local style = {
	bigFont = love.graphics.newFont('RobotoMono-Regular.ttf', 26),
	smallFont = love.graphics.newFont('RobotoMono-Regular.ttf', 20),
	bigFontSize = 26,
	smallFontSize = 20,
	baseColor = {0, 0.007, 0.474},
	accentColor = {0.333, 0, 0.745},
	backgroundColor = {0.09,0.095,0.085},
	textColor = {0.95, 0.96, 0.94, 1},
}

local preconfiguredGrid = {
	colSpacing = 20,
	rowSpacing = 20,
	verticalStretchMode = 'stretch',
	horizontalStretchMode = 'stretch',
	verticalAlignMode = 'center',
	horizontalAlignMode = 'center',
	rows = {1},
	columns = {1,3,1},
	layout = {
		{'trackOne','opcode','trackTwo'},
	}
}

return helium(function (param, view)
	local selfState = state {flipflop = false}
	local styleContext = context.use('style', style)
	local cpuStateContext = context.use('cpuState',{
		statusCode = param.cpu.statusCode,
		statusDetails = param.cpu.statusDetails,
		frequency = param.cpu.frequency,
		peakfrequency = param.cpu.peakfrequency,
		cpuCounter = param.cpu.oldProgCounter,
	})

	local cpuContext = context.use('cpu',{
		memory = param.cpu.memory,
		registers = param.cpu.gpRegisters,
		devices = param.cpu.devices,
		cpu = param.cpu,
		busDevice = param.busDevice,
		flipflop = false,
	})

	onUpdate(function()
		--Keep this updating
		selfState.flipflop = not selfState.flipflop
		cpuContext.flipflop = not cpuContext.flipflop

		cpuStateContext.statusCode = param.cpu.statusCode
		cpuStateContext.statusDetails = param.cpu.statusDetails
		cpuStateContext.frequency = param.cpu.frequency
		cpuStateContext.peakfrequency = param.cpu.peakfrequency
		cpuStateContext.cpuCounter = param.cpu.oldProgCounter
	end)

	local deviceElement = deviceFactory({}, 10, 1)
	local memoryElement = memoryFactory({}, 10, 1)
	local cpuSpeedElement = cpuSpeedFactory({}, 10, 50)
	local opcodeElement = opcodeFactory({}, 10, 50, {opcode = true})
	local statusElement = statusFactory({}, 10, 10)
	local registersElement = registersFactory({}, 10, 10)
	local busDeviceElement = busDeviceFactory({}, 10, 10)

	local deviceCollapser = collapsibleFactory({child = deviceElement, title = 'Bus Devices', defaultOpen = true}, 10, 10)
	local memoryCollapser = collapsibleFactory({child = memoryElement, title = 'Memory', defaultOpen = true}, 10, 10)
	local statusCollapser = collapsibleFactory({child = statusElement, title = 'CPU State', defaultOpen = true}, 10, 10)
	local registersCollapser = collapsibleFactory({child = registersElement, title = 'Registers', defaultOpen = true}, 10, 10)
	local busDeviceCollapser = collapsibleFactory({child = busDeviceElement, title = 'Bus device', defaultOpen = false}, 10, 10)

	local trackOne = verticalTrackFactory({
		children = {
			cpuSpeedElement,
			registersCollapser,
			statusCollapser,
		}
	}, 10, 10, {trackOne = true})
	local trackTwo = verticalTrackFactory({
		children = {
			memoryCollapser,
			deviceCollapser,
			busDeviceCollapser
		}
	}, 10, 10, {trackTwo = true})

	return function()
		selfState.flipflop = not selfState.flipflop
		local l = grid.new(preconfiguredGrid)
		opcodeElement:draw(0,0)
		trackOne:draw(0,0)
		trackTwo:draw(0,0)
		l:draw()
	end
end)