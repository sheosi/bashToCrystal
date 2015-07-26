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
Ct = lpeg.Ct

locale ={}
lpeg.locale(locale)   -- adds locale entries into 'lpeg' table

space = locale.space
character = locale.alpha


string = (character+'_')^1

--File definition
------------------------------------
function append( table, value)
	table[#table]=value
end
function pair( name,pattern)
	if type(pattern) == "string" then
		return Cg(Cc(name)*Cc(pattern))
	else
		return Cg(Cc(name)*pattern)
	end
end


function valueString( name )
	return pair(name,C(string) )
end
function parse(str)
	local pairPattern = Cf('['*Ct("")* pair("type","value")*valueString("pattern")*']',rawset)
	local optSpace = P'_'*Cf(Ct("")*pair("type","optwhitespace"),rawset)
	local other = Cf(Ct("")*pair("type","constantPattern")*pair("string",C(P'$'+P'=') )
		
	--local patternResult = pairPattern:match(str)
	--if patternResult~=nil then
		--return valueString(patternResult)
	--elseif P'_':match(str) then
		--return space^0
	--else
		--return P(str)
	--end
	local parsePattern= Ct(pairPattern + optSpace)
	local result = parsePattern:match(str)
	if result == nil then
		return P(str)
	end
	if result[1].type == "value" then
		return valueString(result[1].pattern)
	elseif result[1].type == "optwhitespace" then
		return space^0
	end
end
--pattern ("import","Import [import]")
import = 'Import' * space^1 * valueString("import")
parameters = 'Parameters' * space^1 * '"$@"' * pair("parameters",  Ct( (' ' * C(string) )^1 ))
assignation = pair("type","assignation")* pair( "scope", ('local'* space^1)*Cc('local') + Cc('global') )
 * parse("[left]") * parse('=')
  * parse('_') *
parse('$')
   *parse('_')*'('*space^0*pair("right",C(string^1))* space^0*')'
--pair("type","assignation")*pair( "scope",  ) * valueString("left") * '=' *space^0 * '$'*space^0*'('*space^0*pair("right",C(string^1))* space^0*')'
--"[scope]{'local' (local) |(global) }-$[left]_'='_"
--"Import [import]"

endline =   P'\n'
inst = assignation
func = 'function'* space^1 *pair("type","function") * valueString("name",string) * space^0 * '()'* space^0 *'{' * space^0 * parameters^0 *
Cg(Cc("instructions")*Ct(""))
* space^0*'}'

pattern = assignation
createTable=Cf(lpeg.Ct("")* pattern,rawset)

textbuffer = [[function Get_Archive_Format ()     {
	   Parameters "$@" archive
}]]
textbuffer = [[
local format=$(Downcase  )]]
table = createTable:match(textbuffer)

if table == nil then
	table = {}
end
for key,value in pairs(table) do --actualcode
   	print(key,": ",value)
end