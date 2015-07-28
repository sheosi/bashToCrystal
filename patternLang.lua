local lpeg = 	require "lpeg"



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
anyChar = 1 

string = (character+'_')^1

--File definition
------------------------------------
function parseOperator( table )
	if table.type == "value" then
		if table.valpattype == "string" then
			return valueString(table.name)
		elseif table.valpattype == "lpegPattern" then
			--Substitute "<" with "parse('" , and ">" with "')"
			if table.pattern==nil then
				error("Had an error parsing inline lua")
			end
			local subsPattern=lpeg.Cs( ( (P'<'/"parse('") + (P'>'/"')"+1))^0 )
			table.pattern = subsPattern:match(table.pattern)

			return pair( table.name,assert(loadstring("return "..table.pattern))())
		end
	elseif table.type == "optwhitespace" then
		return space^0
	elseif table.type == "mandatoryspace" then
		return space^1
	elseif table.type == "export" then
		return Cc(table.string)
	elseif table.type == "constantPattern" then
		return P(table.string)
	elseif table.type == "orPattern" then
		return parseOperator(table.left)+parseOperator(table.right)
	end
end
function pair( name,pattern)
	if type(pattern) == "string" then
		return Cg(Cc(name)*Cc(pattern))
	else
		return Cg(Cc(name)*pattern)
	end
end

function ttype( string )
	return pair("type",string)
end
function valueString( name )
	return pair(name,C(string) )
end
function tablify( tabletype,pattern )
	return Cf(Ct("")*ttype(tabletype)*pattern,rawset)
end
function printTable(self)
	if self == nil then
		print(nil)
	else
		for key,table in pairs(self)do
			for key,value in pairs(table) do --actualcode
				print(key,": ",value)
			end
		print("---------------")
		end
		print("================")
	end
end


function newPattern( name,pattern )
	if type(pattern) == "string" then
		pattern=ttype(name)*parse(pattern)
	else
		pattern=ttype(name)*pattern
	end
	_G[name]=pattern
end
--Own syntax for parsing
--[name]: defines a pair for the output table, expects a string, <name> will be the key of the pair
--[name]{pattern}: same as above but expects <pattern> instead of a string
--(name): when the pattern is true it will emit <name> as constant (just like lpeg.Cc)
--_: 0 or more spaces
-- : 1 or more spaces
-- any other thing: will generate a pattern with that string, symbol, whatever
--'char': when you need to use anything which is already in the syntax use single quotes. NOTE: single quotes only acceps one character
function parse(str)
	local luaChars = (1- (P'}'+P'{') )^1

	local pairPattern = tablify("value",'[' *valueString("name")*']'*Cg(Cc("valpattype")*(P'{'* Cc"lpegPattern"+ Cc"string") )*pair("pattern",C(luaChars)*'}')^-1)
	local optSpace    = tablify("optwhitespace",P'_')
	local mandatorySpace = tablify("mandatoryspace",P' ')
	local exportConstant = tablify("export",'('*valueString("string")*')')
	local other       = tablify( "constantPattern",pair("string",C(P'$'+P'='+character^1+'"'+'@')+ P"'"*C(anyChar)*"'"  ) )
	
	local allPatterns = pairPattern + optSpace + mandatorySpace + other + exportConstant
	local parsePattern= Ct( (allPatterns)^1 )
	local orPattern = tablify("orPattern",pair("left",parsePattern)*'|'*pair("right",parsePattern))
	parsePattern = Ct( (allPatterns+orPattern)^1 )

	local patResult = parsePattern:match(str)
	local parseResult = P''
	for _,result in ipairs(patResult) do
		parseResult= parseResult*parseOperator(result)
	end
	return parseResult
end