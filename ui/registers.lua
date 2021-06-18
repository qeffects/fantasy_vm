local lg = love.graphics
local helium = require('helium')
local context = require('helium.hooks.context')
local setSize = require('helium.hooks.setSize')

local seperated = {
	RMA = true,
	RMD = true,
	RDBA = true,
	RDMA = true,
	RDMD = true,
}

return helium(function (param, view)
	local cpu = context.get('cpu')
	local style = context.get('style')
	local x = cpu.flipflop

	setSize(nil, 30)

	return function()
		local acc = 0

		lg.setColor(style.baseColor)
		lg.rectangle('fill',0,0,view.w,28)
		lg.setColor(style.accentColor)
		lg.rectangle('line',0,0,view.w,28)
		lg.rectangle('line',0,0,view.w,view.h)
		lg.setFont(style.smallFont)
		lg.setColor(style.textColor)
		lg.translate(5,0)
		lg.print('Registers', 0, 0)
		for name, contents in pairs(cpu.registers) do
			if not seperated[name] and contents.data then  
				acc = acc + 1
				lg.print(name..': '..tostring(contents.data),0, style.smallFontSize*acc+10)
			end
		end
	
		acc = acc + 2
	
		lg.setColor(0, 0, 1)
		local data = cpu.registers['RMA'].data or ''
		lg.print('RMA'..': '..tostring(data),0, style.smallFontSize*acc)
		acc = acc + 1
	
		lg.setColor(1, 0, 0)
		data = cpu.registers['RMD'].data or ''
		lg.print('RMD'..': '..tostring(data),0, style.smallFontSize*acc)
		acc = acc + 2
	
		lg.setColor(0, 0.5, 0.5)
		local data = cpu.registers['RDBA'].data or ''
		lg.print('RDBA'..': '..tostring(data),0, style.smallFontSize*acc)
		acc = acc + 1
	
		lg.setColor(0, 0.5, 0.5)
		data = cpu.registers['RDMA'].data or ''
		lg.print('RDMA'..': '..tostring(data),0, style.smallFontSize*acc)
		acc = acc + 1
	
		lg.setColor(0, 0.5, 0.5)
		data = cpu.registers['RDMD'].data or ''
		lg.print('RDMD'..': '..tostring(data),0, style.smallFontSize*acc)
		acc = acc + 2


		setSize(nil, acc*style.smallFontSize-10)
	end
end)