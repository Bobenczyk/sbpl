Path = (arg[0]:match(".+[\\/]") or ""):sub(1, -2):match(".+[\\/]") or ""
Deb = false


co = coroutine
async = require "src.asink"


if #arg < 1 then
    print("sbpl: no file given.")
else
    local f = io.open(arg[1], "r")
    if f then
        code = f:read("a")
        f:close()

        dofile(Path.."src/main.lua")

        for i = #arg, 2, -1 do
            local t = {}
            for j = 1, #arg[i] do
                local a = {arg[i]:sub(j,j):byte()}
                table.insert(t, a[1])
            end
            pushList(t)
        end
        push(#arg-1)

        main = function ()
            vm_run()
        end
        main_thread = async.sync(main)
        main_thread(function ()
            
        end)

        return
    end
    print("sbpl: no file named \""..arg[1]..'"')
end