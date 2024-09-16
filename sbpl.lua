Path = (arg[0]:match(".+[\\/]") or ""):sub(1, -2):match(".+[\\/]") or ""
Deb = false

if #arg < 1 then
    print("sbpl: no file given.")
else
    local f = io.open(arg[1], "r")
    if f then
        code = f:read("a")
        f:close()
        dofile(Path.."src/main.lua")
        return
    end
    print("sbpl: no file named \""..arg[1]..'"')
end