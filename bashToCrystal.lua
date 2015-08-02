require "patternLang"

local lpeg = 	require "lpeg"

import = parse("Import [import]")
parameters = parse('Parameters "$@"[parameters]{Ct( (" "*C(string))^1 )}')

newPattern("command","[executable][arguments]{Ct( tablePattern(space^1 * pair('argName',P'-'*C(character) )* (space^1 *quotedString('argValue') )^-1* space^0 * backSlash^-1* newLine^-1 )^0 ) }_")
newPattern("pipe","[left]{tablePattern(command)}_|_[right]{tablePattern(command)}_")
newPattern("assignment", "[scope]{ <local (local)> + <(global)> }[left]=_$_'('_[right]{C(string^1)}_')'" )
newPattern("ifstament","if '[' h ']'\n'_then'\n'_fi")
newPattern('func','function [name]_()_{_}')
 

textbuffer = [[echo "${format}"]]

local table = tablePattern(command):match(textbuffer)

printResult(table)