local lg = love.graphics
local helium = require('helium')
local grid = require('helium.layout.grid')
local gridConf = {
	colSpacing = 10,
	rowSpacing = 10,
	verticalStretchMode = 'normal',
	horizontalStretchMode = 'stretch',
	verticalAlignMode = 'center',
	horizontalAlignMode = 'center',
}

return helium(function (param, view)
	return function()
		local l = grid.new(gridConf)
		for i, element in ipairs(param.children) do
			element:draw()
		end
		l:draw()
	end
end)