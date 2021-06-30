local helium = require('helium')
local useCheckbox = require('helium.shell.checkbox')
local useState = require('helium.hooks.state')
local context = require('helium.hooks.context')
local setSize = require('helium.hooks.setSize')
local onUpdate = require('helium.hooks.onUpdate')
local lg = love.graphics

local collapserHeaderFactory = helium(function (param, view)
	local buttonState = useCheckbox(nil, function (x)
		if param.onChange then 
			param.onChange(x)
		end
	end, nil, nil, param.startOn)

	local style = context.get('style')
	local font = param.fontSize == 'big' and style.bigFont or style.smallFont
	local fontSize = param.fontSize == 'big' and 20 or 26
	local titleString = param.title

	setSize(nil, fontSize+10)

	return function()		
		lg.setColor(style.baseColor)
		lg.rectangle('fill',0,0,view.w,view.h)
		lg.setColor(style.accentColor)
		lg.rectangle('line',0,0,view.w,view.h)
		lg.setFont(font)
		lg.setColor(1, 1, 1)
		lg.translate(5,0)
		lg.print(titleString..(buttonState.toggled and ' -' or ' >' ) , 0, 0)
	end
end)

return helium(function (param,view)
	local collapserState = useState{open = false}
	collapserState.open = param.defaultOpen or false

	local style = context.get('style')

	local changeCollapserState = function(x)
		collapserState.open = x
	end

	local header = collapserHeaderFactory({
		onChange = changeCollapserState,
		fontSize = param.fontSize or 'small',
		title = param.title or 'NoTitle',
		startOn = collapserState.open
	}, view.w, 10)

	local child = param.child

	onUpdate(function ()
		local sum
		if collapserState.open and child.view then
			sum = header.view.h + child.view.h
		else
			sum = header.view.h
		end
		setSize(nil, sum)
	end)

	return function()
		header:draw(0, 0, view.w)
		if collapserState.open then
			child:draw(0, header.view.h+1, view.w)
			lg.setColor(style.accentColor)
			lg.rectangle('line',0,0,view.w,view.h)
		end
	end
end)