local helium = require('helium')
local context = require('helium.hooks.context')
local lg = love.graphics
local setSize = require('helium.hooks.setSize')

return helium(function (param,view)
	local cpu = context.get('cpu')
	local style = context.get('style')
	local x = cpu.flipflop

	setSize(nil, 440)

	return function()
		lg.setColor(1, 1, 1)
		lg.setFont(style.smallFont)

		lg.translate(10, -20)
		for i = 1, 10 do
			if cpu.registers['RDMA'].data == i then
				lg.setColor(0, 0.5, 0.5)
			else
				lg.setColor(1, 1, 1)
			end
			lg.print('['..i..']: ', 0, i*40)
			lg.setColor(0.1, 0.1, 0.1)
			if cpu.busDevice.memory[i].data and cpu.busDevice.memory[i].data < 1 then
				lg.setColor(1, 0, 0)
			elseif cpu.busDevice.memory[i].data == 1 then
				lg.setColor(0, 1, 0)
			end
			lg.rectangle('fill', 60, i*40, 30, 30, 5)
		end
	end
end)