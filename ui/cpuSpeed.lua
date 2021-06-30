local lg = love.graphics
local helium = require('helium')
local button = require('helium.shell.button')
local context = require('helium.hooks.context')

local btnFac = helium(function (param, view)
	local btnState = button(param.callback)

	return function()
		if not btnState.down then
			lg.setColor(0.1,0.1,0.1)
		else
			lg.setColor(0.3,0.3,0.3)
		end
		lg.rectangle('fill',0,0,view.w, view.h)
		lg.setColor(0.5,0.5,0.5)
		lg.printf(param.text,0,10,view.w,'center')
	end
end)

local function stopF()
	UPDATE_TIME = false
end

local function stepF()
	STEP_CPU()
end

local function slowF()
	UPDATE_TIME = 0.7
end

local function fastF()
	UPDATE_TIME = 0.033 
end

return helium(function (param, view)
	local style = context.get('style')

	local stop = btnFac({text = '||', callback = stopF}, 40, 40)
	local step = btnFac({text = '1', callback = stepF}, 40, 40)
	local slow = btnFac({text = '>', callback = slowF}, 40, 40)
	local fast = btnFac({text = '>>', callback = fastF}, 40, 40)

	return function()
		local leftover = (view.w - (50*4))/4

		lg.setColor(style.baseColor)
		lg.rectangle('fill',0,0,view.w,view.h)
		lg.setColor(style.accentColor)
		lg.rectangle('line',0,0,view.w,view.h)
		stop:draw(0+leftover,5)
		step:draw(50+leftover*2,5)
		slow:draw(100+leftover*3,5)
		fast:draw(150+leftover*4,5)
	end
end)