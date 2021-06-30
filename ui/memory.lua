local lg = love.graphics
local helium = require('helium')
local context = require('helium.hooks.context')
local setSize = require('helium.hooks.setSize')

return helium(function (param, view)
	local cpu = context.get('cpu')
	local style = context.get('style')
	local x = cpu.flipflop

	return function()
		lg.setColor(1, 1, 1)
		lg.setFont(style.smallFont)
		local acc = 0
		for name, contents in ipairs(cpu.memory) do
			if name == cpu.registers['RMA'].data then
				lg.setColor(0, 0, 1)
			else
				lg.setColor(1, 1, 1)
			end
			if not contents.data == false then
				lg.print('['..name..']:', 0, (style.smallFontSize+3)*acc)
				local w = style.smallFont:getWidth('['..name..']:')
	
				if name == cpu.registers['RMA'].data then
					lg.setColor(1, 0, 0)
				end
	
				lg.print(tostring(contents.data), w+5, (style.smallFontSize+3)*acc)
				acc = acc + 1
			end
		end
		setSize(nil, acc*(style.smallFontSize+3)+10)
	end
end)