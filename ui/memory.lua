local lg = love.graphics
local helium = require('helium')
local context = require('helium.hooks.context')

return helium(function (param, view)
	local cpu = context.get('cpu')
	local style = context.get('style')
	local x = cpu.flipflop

	return function()
		lg.setColor(style.baseColor)
		lg.rectangle('fill',0,0,view.w,28)
		lg.setColor(style.accentColor)
		lg.rectangle('line',0,0,view.w,28)
		lg.rectangle('line',0,0,view.w,view.h)
		local acc = 2
		lg.setFont(style.smallFont)
		lg.setColor(1, 1, 1)
		lg.print('Memory', 0, 0)
		for name, contents in ipairs(cpu.memory) do
			if name == cpu.registers['RMA'].data then
				lg.setColor(0, 0, 1)
			else
				lg.setColor(1, 1, 1)
			end
			if not contents.data == false then
				lg.print(name, 0, style.smallFontSize*acc)
				local w = style.smallFont:getWidth(name)
	
				if name == cpu.registers['RMA'].data then
					lg.setColor(1, 0, 0)
				end
	
				lg.print(': '..tostring(contents.data), w+5, style.smallFontSize*acc)
				acc = acc + 1
			end
		end
	end
end)