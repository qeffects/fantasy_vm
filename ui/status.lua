local lg = love.graphics
local helium = require('helium')
local context = require('helium.hooks.context')
local setSize = require('helium.hooks.setSize')

return helium(function (param, view)
	local status = context.get('cpuState')
	local style = context.get('style')

	setSize(nil, 110)

	return function()
		lg.setColor(style.textColor)
		lg.setFont(style.smallFont)
		lg.print('Status: '..status.statusCode, 5, 0)
		lg.print('Prog Counter: '..(status.cpuCounter or ''), 5, 20)
		lg.print('Details: '..status.statusDetails, 5, 40)
		lg.print(string.format('Frequency: %.1fHZ',status.frequency), 5, 60)
		lg.print(string.format('Peak freq: %.1fHZ',status.peakfrequency), 5, 80)
	end
end)