local lg = love.graphics
local helium = require('helium')
local context = require('helium.hooks.context')
local setSize = require('helium.hooks.setSize')

return helium(function (param, view)
	local cpu = context.get('cpu')
	local style = context.get('style')
	local x = cpu.flipflop


	return function()
		local lines = #cpu.cpu.programMemory
		setSize(nil, lines*style.bigFontSize+70)
		lg.setColor(style.baseColor)
		lg.rectangle('fill',0,0,view.w,34)
		lg.setColor(style.accentColor)
		lg.rectangle('line',0,0,view.w,34)
		lg.rectangle('line',0,0,view.w,view.h)
		lg.setFont(style.bigFont)
		lg.setColor(1, 1, 1)
		lg.translate(5,0)
		lg.print('Instructions', 0, 0)
		lg.translate(10,13)
		for i, contents in ipairs(cpu.cpu.programMemory) do
			if i == cpu.cpu.oldProgCounter then
				lg.setColor(0, 1, 0)

				local w = style.bigFont:getWidth(contents)

				lg.rectangle('fill' , 0, ((i)*style.bigFontSize)+11, w+30, style.bigFontSize-1)
				lg.setColor(0, 0, 0)
				lg.print('>', 5, (i)*style.bigFontSize+5)
			else
				lg.setColor(1, 1, 1)
			end
			if contents:find('//') then

				local noComment = contents:gsub('[ ]?//.+','')
				local w2 = style.bigFont:getWidth(noComment)
				local loc = contents:find('[ ]?//')
				local comment = contents:sub(loc)

				lg.print(noComment, 25, (i)*style.bigFontSize+5)
				lg.setColor(0.1,0.5,0.1)
				lg.print(comment, 25+w2, (i)*style.bigFontSize+5)
			else
				lg.print(contents, 25, (i)*style.bigFontSize+5)
			end
		end
	end
end)