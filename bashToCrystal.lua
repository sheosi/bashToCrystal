require "patternLang"
local lpeg = 	require "lpeg"

import = parse("Import [import]")
parameters = parse('Parameters "$@"[parameters]{Ct( (" "*C(string))^1 )}')
newPattern("assignation", "[scope]{ <local (local)> + <(global)> }[left]=_$_'('_[right]{C(string^1)}_')'" )



endline =   P'\n'
inst = assignation
newPattern('func','function [name]_()_{_}')
 

pattern = func
createTable=Cf(lpeg.Ct("")* pattern,rawset)

textbuffer = [[function Get_Archive_Format ()  {}]]
table = createTable:match(textbuffer)

if table == nil then
	table = {}
end
for key,value in pairs(table) do --actualcode
	print(key,": ",value)
end