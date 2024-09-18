function isWhiteSpace(c)
    return c == ' ' or c == '\n' or c == "\t"
end
function isDigit(c)
    if type(c) == "string" and c:len() == 1 then
        local cac = string.byte(c)
        return cac >= 48 and cac <= 57
    end
end


function number(i)
    while isDigit(code:sub(i, i)) do
        i = i + 1
    end
    return i - 1
end

local gobackState = false
local goback = 0
local stack = {}
function push(val)
    table.insert(stack, val)
end
function get(pos)
    return (pos>0 and ((pos<=#stack and stack[pos]) or 0)) or 0
end
function pop()
    if gobackState then
        return get(#stack-goback+1)
    else
        return table.remove(stack) or 0
    end
end
function pushList(list)
    assert(type(list) == "table", "sbpl_vm: pushList list wasn't a list but ".. type(list))
    for i = #list, 1, -1 do
        push(tonumber(list[i]))
    end
    push(#list)
end

function toBool(temp)
    return (temp == 0 and 0) or 1
end

function toBool_Not(temp)
    return (temp == 0 and 1) or 0
end

function bool_or(v0, v1)
    return (toBool(v0)==1 and 1) or toBool(v1)
end

function bool_and(v0, v1)
    return (toBool(v0)==1 and toBool(v1)) or 0
end

local ops = {
    ["+"] = function()
        push(pop() + pop())
    end,
    ["*"] = function()
        push(pop() * pop())
    end,
    ["-"] = function()
        local temp = pop()
        push(pop() - temp)
    end,
    ["/"] = function()
        local temp = pop()
        push(pop() // temp)
    end,

    ["_"] = function()
        pop()
    end,

    ["!"] = function()
        push(toBool_Not(pop()))
    end,
    ["#"] = function()
        push(toBool(pop()))
    end,

    ["%"] = function()
        local temp1 = pop()
        local temp2 = pop()
        push(temp1)
        push(temp2)
    end,

    ["|"] = function()
        push(bool_or(pop(), pop()))
    end,

    ["&"] = function()
        push(bool_and(pop(), pop()))
    end,

    ["="] = function()
        push((pop()==pop() and 1) or 0)
    end,
    ["<"] = function()
        local temp = pop()
        push((pop() < temp and 1) or 0)
    end,
    [">"] = function()
        local temp = pop()
        push((pop() > temp and 1) or 0)
    end,

    ["$"] = function()
        local f = pop()
        local t = pop()
        push((pop() == 0 and f) or t)
    end,

    ["\\"] = function()
        io.write(pop())
    end,

    ["^"] = function()
        local temp = pop()
        if not gobackState then
            push(temp)
        end
        push(temp)
    end,

    ["`"] = function ()
        push(#stack)
    end,

    ["@"] = function()
        for i, v in ipairs(stack) do
            print(i..": "..tostring(v))
        end
    end,

    ["."] = function()
        local temp = pop()
        if temp > 0 then
            gobackState = true
            goback = temp
        end
    end,

    [","] = function()
        io.write(string.char(pop()))
    end,

    -- [""] = function()
        
    -- end,
}

local ls = {}
local ifs = {}

-- local skipMode = false

local i = 0

function vm_run()
    while i < code:len() do
        i = i + 1
        local c = code:sub(i, i)

        if isWhiteSpace(c) then   goto vm_next   end

        if #ifs == 0 then

            if isDigit(c) then
                local temp = number(i)
                local num = tonumber(code:sub(i, temp))
                i = temp
                if Deb then  print(num)  end
                push(num)
            elseif c == '[' then
                if Deb then  print('[')  end
                table.insert(ls, {i, #stack})
            elseif c == ']' then
                if Deb then  print(']')  end
                if #ls > 0 then
                    local index = #ls
                    local si = math.min(ls[index][2], #stack)
                    if si > 0 then
                        if stack[si]~=0 then
                            i = ls[index][1]
                        else
                            table.remove(ls)
                        end
                    end
                end
            elseif c == '(' then
                if Deb then  print('(')  end
                local temp = pop()
                push(temp)
                if temp == 0 then
                    table.insert(ifs, {i, #stack-((gobackState and goback) or 0)})
                end
            elseif c == ')' then
                if Deb then  print(')')  end
            elseif type(ops[c]) == "function" then
                if Deb then  print(c)  end
                ops[c]()
                if c ~= '.' and gobackState then
                    gobackState = false
                    goback = 0
                end
            else
                print(c..'!')
            end

        else

            if c == '(' then
                if Deb then  print('(_')  end
                table.insert(ifs, {i, #stack})
            elseif c == ')' then
                if Deb then  print(')_')  end
                table.remove(ifs)
            end

        end

        ::vm_next::
    end

    print("\n Stack:")
    for i, v in ipairs(stack) do
        print(i..": "..tostring(v))
    end
end


