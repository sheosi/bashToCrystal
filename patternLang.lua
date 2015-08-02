local lpeg = 	require "lpeg"
require "switch"


--io.input("example.sh")
--textbuffer = io.read("*all")
--Lpeg set
----------------------------
P = lpeg.P
C = lpeg.C
lpeg.Group = lpeg.Cg
Cb = lpeg.Cb
Cp = lpeg.Cp
lpeg.Constant = lpeg.Cc
Cf = lpeg.Cf
Ct = lpeg.Ct

lpeg:locale()   -- adds locale entries into 'lpeg' table

space = lpeg.space
character = lpeg.alpha
anyChar = 1 
newLine = P"\n"
backSlash = P"\\"

string = (character+'_')^1

--File definition
------------------------------------	
function printResult( table )
	if table == nil then
		print('Error: match failed')
	elseif type(table) == 'string' then
		print(table)
	else
		for key,element in pairs(table)do
			if type(element) == "table" then
				print(key,'----------')
				for key,value in pairs(element) do --actualcode
					print(key,": ",value)
				end
			else
				print(key,": ",element)
			end
			print("---------------")
		end
		print("================")
	end
end

function pair( name,pattern)
	return lpeg.Group(lpeg.Constant(name) * pattern)
end

function quotedString( name )
	return '\"'*pair(name,C( (1-P'"')^1))*'\"'
end

function tablePattern( tabletype,pattern)
	if not pattern then return Cf(Ct("")*tabletype,rawset)
	else            return Cf(Ct("")*pair("type", lpeg.Constant(tabletype) )*pattern,rawset)
	end
end

function newPattern( name,pattern )
	if type(pattern) == "string" then
		pattern= parse(pattern)
	end
	_G[name]= pair("type",lpeg.Constant(name)) * pattern
end

function parseOperator( table )
	return switch(table.type){
		value = function ()
			if table.valpattype == "string" then

				return pair(table.name,C(string))

			elseif table.valpattype == "lpegPattern" then

				--Substitute "<" with "parse('" , and ">" with "')"
				if not table.pattern then
					error("Had an error parsing inline lua")
				end

				local subsPattern=lpeg.Cs( ( (P'<'/"parse('") + (P'>'/"')"+1))^0 )
				table.pattern = subsPattern:match(table.pattern)

				--local patternResult = assert( loadstring("return "..table.pattern) )()
				local patternResult = loadstring("return "..table.pattern) ()--Assert is supossedly for better errors
				return pair( table.name,patternResult)
			end
		end;

		optwhitespace = space^0;
		mandatoryspace = space^1;
		export = function () return lpeg.Constant(table.string) end;
		constantPattern = function () return P(table.string) end;
	}
end	

--Own syntax for parsing
--[name]: defines a pair for the output table, expects a string, <name> will be the key of the pair
--[name]{pattern}: same as above but expects <pattern> instead of a string
--(name): when the pattern is true it will emit <name> as Constant (just like lpeg.Cc)
--_: 0 or more spaces
-- : 1 or more spaces
-- any other thing: will generate a pattern with that string, symbol, whatever
--'char': when you need to use anything which is already in the syntax use single quotes. NOTE: single quotes only accepts one character
local luaChars = (1-lpeg.S'{}')^1
local pairPattern    = tablePattern("value",'[' *pair("name",C(string))*']'*pair("valpattype",'{'* lpeg.Constant"lpegPattern"+ lpeg.Constant"string" )*pair("pattern",C(luaChars)*'}')^-1)
local optSpace       = tablePattern("optwhitespace",'_')
local mandatorySpace = tablePattern("mandatoryspace",' ')
local exportConstant = tablePattern("export",'('* pair("string",C(string)) *')')
local other          = tablePattern("constantPattern",pair("string",C( character^1+lpeg.S'"@$=' )+ "'"*C(anyChar)*"'"  ) )
	
local parsePattern= Ct( (pairPattern + optSpace + mandatorySpace + other + exportConstant)^1 )
function parse(str)
	local parseResult = 0 -- 0 = Nothing
	for _,result in ipairs( parsePattern:match(str) ) do
		parseResult= parseResult*parseOperator(result)
	end
	return parseResult
end