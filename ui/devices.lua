local lg = love.graphics
local helium = require('helium')
local context = require('helium.hooks.context')
local setSize = require('helium.hooks.setSize')

return helium(function (param, view)
	local cpu = context.get('cpu')
	local style = context.get('style')
	local x = cpu.flipflop

	return function()
		local acc = 0
		lg.setColor(style.baseColor)
		lg.rectangle('fill',0,0,view.w,28)
		lg.setColor(style.accentColor)
		lg.rectangle('line',0,0,view.w,28)
		lg.rectangle('line',0,0,view.w,view.h)
		lg.setColor(style.textColor)
		lg.setFont(style.smallFont)
		lg.translate(5,0)
		lg.print('Bus Devices ', 0, 0)
		for i, dev in pairs(cpu.devices) do
			acc = acc + 1
			lg.print(''..i..': ['..tostring(dev.name)..']',0, 10+style.smallFontSize*acc)
		end
		setSize(nil, 30+acc*(style.smallFontSize+10))
	end
end)