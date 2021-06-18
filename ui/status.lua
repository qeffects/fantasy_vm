local lg = love.graphics
local helium = require('helium')
local context = require('helium.hooks.context')
local setSize = require('helium.hooks.setSize')

return helium(function (param, view)
	local status = context.get('cpuState')
	local style = context.get('style')

	setSize(nil, 117)

	return function()
		lg.setColor(style.baseColor)
		lg.rectangle('fill',0,0,view.w,28)
		lg.setColor(style.accentColor)
		lg.rectangle('line',0,0,view.w,28)
		lg.rectangle('line',0,0,view.w,view.h)
		lg.setColor(style.textColor)
		lg.setFont(style.smallFont)
		lg.print('CPU state', 5, 0)
		lg.setFont(style.smallFont)
		lg.print('Status: '..status.statusCode, 5, 27)
		lg.print('Details: '..status.statusDetails, 5, 47)
		lg.print(string.format('Frequency: %.1fHZ',status.frequency), 5, 67)
		lg.print(string.format('Peak freq: %.1fHZ',status.peakfrequency), 5, 87)
	end
end)