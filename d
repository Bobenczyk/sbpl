-- local a = "Kondrys"
-- local a = "TakNie"

-- local a = "Czy  i  jest ruwne?\n"
local a = "Odpowiedz: "


print(a)
local t = {}
for i = 1, #a do
    local b = a:sub(i, i)
    table.insert(t, b:byte())
end
print(table.concat(t, ', ')..((#t > 0 and ',') or ""))