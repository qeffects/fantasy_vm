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
		for i, dev in pairs(cpu.devices) do
			lg.setColor(1,1,1,1)
			lg.setFont(style.smallFont)
			lg.print(''..i..': ['..tostring(dev.name)..']',5, style.smallFontSize*acc)
			acc = acc + 1
		end

		setSize(nil, acc*(style.smallFontSize+10))
	end
end)