local lpeg = 	require "lpeg"
local ins = require "inspect"

function printContents( )
	table = getmetatable(Cb("parameters"))

	for key,value in pairs(table.__index) do --actualcode
    	print(key,": ",value)
	end

end

--io.input("example.sh")
--textbuffer = io.read("*all")
--Lpeg set
----------------------------
P = lpeg.P
V = lpeg.V
R = lpeg.R
C = lpeg.C
Cg = lpeg.Cg
Cb = lpeg.Cb
Cp = lpeg.Cp
Cc = lpeg.Cc
Cf = lpeg.Cf

locale ={}
lpeg.locale(locale)   -- adds locale entries into 'lpeg' table

space = locale.space
character = locale.alpha

string = (character+'_')^1

--File definition
------------------------------------

import = 'Import' * space^1 * C(string)
string = character^1
parameters = 'Parameters' * space^1 * '"$@"' * Cg(Cc("parameters") * (' ' * C(string) )^1 )
assignation = ('local'* space^1)^0 * string
endline ='\n'
func = 'function '* Cg(Cc("name") * C(string)) * '() {}'

createTable=Cf(lpeg.Ct("")* func,rawset)

textbuffer = [[function Get_Archive_Format() {}]]
table = createTable:match(textbuffer)

if table == nil then
	table = {}
end
for key,value in pairs(table) do --actualcode
   	print(key,": ",value)
end