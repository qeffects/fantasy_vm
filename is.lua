---@class instructionSetClass
---@field instructions table
local instructionSet = {}
instructionSet.__index = instructionSet

--This is's commands formatted like:
-- 'COMMAND:ARG,ARG,ARG'
-- or 'COMMAND' if no args
-- Basic data types are number, alias and string literal
-- If there's a specified type for the arg it'll try casting to that
-- If the type is "any" then it'll first try casting it in to a number, then if that fails it'll try to read from registry, then if it wasn't already a string literal, it fails
-- If the type is "optional" it's of type ANY but will be filled with 0's on absence
local function parseInstruction(str, IS)
    local f = str:find(':')

	str = str:gsub('[ ]?//.+','')

    if f then
        --Arg'd path
        local cmd = str:sub(1, f-1)
        if IS[cmd] then
            if not IS[cmd].arg then
                return false, 'instruction had too many arguments'..str
            end

            local argS = str:sub(f+1)
            local containsLiterals = argS:find('"')
            local rebuiltStr = argS

            local extractedLiterals

            if containsLiterals then
                local finished = false
                local nextStart = 1
                local maxIter = 10
                local curIter = 0
                local matched = true
                extractedLiterals = {}

                while not finished do
                    local f = argS:find('"', nextStart)

                    if f then
                        local d = argS:find('"', f+1)

                        if not d then
                            return false, 'instruction "'..str..'" didnt close the string literal'
                        end

                        extractedLiterals[#extractedLiterals+1] = argS:sub(f+1, d-1)

                        local b, a

                        b = argS:sub(1, f-1)
                        a = argS:sub(d+1)

                        argS = b..'__INTENALSTING'..a

                        nextStart = 1
                    else
                        finished = true
                    end

                    curIter = curIter + 1
                    if curIter>maxIter then
                        break
                    end
                end
            end

            local argT = {}

            local multiArg = argS:find(',')

            if multiArg then
                local finished = false
                local nextStart = 1
                local maxIter = 10
                local curIter = 0
                local curStr = 1
                while not finished do
                    local f = argS:find(',', nextStart)

                    if f then
                        local arg = argS:sub(nextStart, f-1)

                        if arg == '__INTENALSTING' then
                            argT[#argT+1] = {str = extractedLiterals[curStr]}
                            curStr = curStr+1
                        else
                            argT[#argT+1] = arg
                        end

                        nextStart = f+1
                    else
                        local arg = argS:sub(nextStart)

                        if arg == '__INTENALSTING' then
                            argT[#argT+1] = {str = extractedLiterals[curStr]}
                            curStr = curStr+1
                        else
                            argT[#argT+1] = arg
                        end

                        finished = true
                    end
                    curIter = curIter + 1
                    if curIter>maxIter then
                        break
                    end
                end

                for i, arg in ipairs(argT) do
                    if not IS[cmd].arg[i] then
                        return false, 'instruction "'..str..'" contained too many arguments, expected '..#IS[cmd].arg
                    end
                    if IS[cmd].arg[i] == 'number' then
                        argT[i] = tonumber(arg)
                    end
                    if IS[cmd].arg[i] == 'any' then
                        if tonumber(arg) then
                            argT[i] = tonumber(arg)
                        end
                    end
                end

                return IS[cmd], argT
            else
                if #IS[cmd].arg>1 and not IS[cmd].optional then
                    return false, 'instruction "'..str..'" didnt contain enough arguments, expected '..#IS[cmd].arg
                end

                return IS[cmd], extractedLiterals or {argS}
            end

        else
            return false, 'no such instruction: '..str
        end        
    else
        local labelMark = str:find('{')
        local endMark = str:find('}')
        if labelMark and endMark then
            return IS.__LABEL
        else
            return IS[str] or IS.__LABEL
        end
    end
end

---@param cpu cpuClass
---@return instructionSetClass
function instructionSet.new(cpu)
    local instructions = {
        SET = {--Sets the value of RegX to Val
            arg = {'alias', 'any'},
            func = function (reg, val)
                cpu:setRegister(reg, val)
            end
        },
        ADDR = {--Adds the value of RegX to RegY, saves to RegZ
            arg = {'any', 'any', 'alias'},
            func = function (x, y, regZ)
                cpu:setRegister(regZ, x + y)
            end
        },
        DIV = {--Integer divides x y, saves to z
            arg = {'any', 'any', 'alias'},
            func = function (x, y, regZ)
                cpu:setRegister(regZ, x / y)
            end
        },
        MOD = {--Integer divides x y, saves remenant to z
            arg = {'any', 'any', 'alias'},
            func = function (x, y, regZ)
                cpu:setRegister(regZ, x % y)
            end
        },
        ADD = {--Adds the value of RegX to RegX + Val
            arg = {'alias', 'any'},
            func = function (regX, val)
                local x = cpu:getRegister(regX)

                cpu:setRegister(regX, x + val)
            end
        },
        MOV = {--Moves value from RX to RY
            arg = {'alias', 'alias'},
            func = function (regX, regY)
                local x = cpu:getRegister(regX)

                cpu:setRegister(regY, x)
            end
        },
        __LABEL = {--Dummy label marker
            arg = {'alias'},
            func = function ()
                
            end
        },
        JMP = {--Jumps to label unconditionally
            arg = {'alias'},
            func = function (labelTo)
                local addr = cpu:findInstruction('{'..labelTo..'}')

                cpu:setProgramCounter(addr)
            end
        },
        JMPL = {--Jums to label if X > Y
            arg = {'any','any','alias'},
            func = function (x, y, labelTo)
                local addr = cpu:findInstruction('{'..labelTo..'}')

                if x>y then
                    cpu:setProgramCounter(addr)
                end
            end
        },
        JMPI = {--Jums to label if X > 0
            arg = {'any','alias'},
            func = function (x, labelTo)
                local addr = cpu:findInstruction('{'..labelTo..'}')

                if x>0 then
                    cpu:setProgramCounter(addr)
                end
            end
        },
        CMPL = {--Sets register C to Z if x>y
            arg = {'any','any','any','alias'},
            func = function (x, y, c, z)
                if x>y then
                    cpu:setRegister(z,c)
                end
            end
        },
        CMPE = {--Sets register C to Z if x==y
            arg = {'any','any','any','alias'},
            func = function (x, y, c, z)
                if x == y then
                    cpu:setRegister(z,c)
                end
            end
        },
        CMPN = {--Sets register C to Z if x!=y
            arg = {'any','any','any','alias'},
            func = function (x, y, c, z)
                if not x == y then
                    cpu:setRegister(z,c)
                end
            end
        },
        SLP = {--SLEEPS for val
            arg = {'number'},
            func = function (time)
                local x = cpu:sleep(time)
            end
        },
        PUSH = {--Pushes to stack
            arg = {'any','any','any','any','any','any'},
            optional = true,
            func = function (a, b, c, d, e, f)
                cpu:push(a,b,c,d,e,f)
            end
        },
        POP = {--Pops from the stack
            arg = {'alias','alias','alias','alias','alias','alias',},
            optional = true,
            func = function (r1, r2, r3, r4, r5, r6)
                local a,b,c,d,e,f = cpu:pop()
                if r1 and not r1 == '0' then
                    cpu:setRegister(r1, a)
                end
                if r2 and not r2 == '0' then
                    cpu:setRegister(r2, b)
                end
                if r3 and not r3 == '0' then
                    cpu:setRegister(r3, c)
                end
                if r4 and not r4 == '0' then
                    cpu:setRegister(r4, d)
                end
                if r5 and not r5 == '0' then
                    cpu:setRegister(r5, e)
                end
                if r6 and not r6 == '0' then
                    cpu:setRegister(r6, f)
                end
            end
        },
        SUM = {--Sums the whole stack
            arg = {'alias'},
            func = function (reg)
                local finished = false
                local fin = 0

                while not finished do
                    local l = cpu:pop()
                    if l then
                        fin = fin + l
                    else
                        finished = true
                    end
                end

                cpu:setRegister(reg, fin)
            end
        },
        CCAT = {--Concatenates the stack
            arg = {'alias'},
            func = function (reg)
                local finished = false
                local fin = ''

                while not finished do
                    local l = cpu:pop()
                    if l then
                        fin = fin..l
                    else
                        finished = true
                    end
                end

                cpu:setRegister(reg, fin)
            end
        }
    }

    return setmetatable({
        instructions = instructions,
        cpu = cpu
    }, instructionSet)
end

function instructionSet:exec(instruction)
    local instruction, args = parseInstruction(instruction, self.instructions)

    if not instruction then
        return false, args
    else
        --Arg preprocessing

        if args then
            for i = 1, #args do
                if instruction.arg[i] == 'any' then
                    if type(args[i]) == 'table' then
                        args[i] = args[i].str
                    elseif type(args[i])=='string' and args[i]:find('R') then
                        args[i] = self.cpu:getRegister(args[i])
                    end
                end
            end
            instruction.func(unpack(args))
        else
            instruction.func()
        end
    end
end

function instructionSet:preCompile(instructionLine)
    local instruction, args = parseInstruction(instructionLine, self.instructions)



    if not instruction then
        return false, args
    else
        --Arg preprocessing

        if args then
            return instruction, args
        else
            return instruction
        end
    end
end

local newArg = {}
function instructionSet:runCompiled(instruction, argg)
    if not instruction then
        return false, argg
    else
        --Arg preprocessing


        if argg then
            for i = 1, 6 do
                newArg[i] = nil
            end
            for i, e in ipairs(argg) do
                newArg[i] = e
            end
            for i = 1, #newArg do
                if instruction.arg[i] == 'any' then
                    if type(newArg[i]) == 'table' then
                        newArg[i] = newArg[i].str
                    elseif type(newArg[i])=='string' and newArg[i]:find('R') then
                        newArg[i] = self.cpu:getRegister(newArg[i])
                    end
                end
            end
            
            instruction.func(newArg[1], newArg[2], newArg[3], newArg[4], newArg[5], newArg[6])
        else
            instruction.func()
        end
    end
end

return instructionSet