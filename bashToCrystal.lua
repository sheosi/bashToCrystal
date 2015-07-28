require "patternLang"
local lpeg = 	require "lpeg"

import = parse("Import [import]")
parameters = parse('Parameters "$@"[parameters]{Ct( (" "*C(string))^1 )}')
newPattern("assignation", "[scope]{ <local (local)> + <(global)> }[left]=_$_'('_[right]{C(string^1)}_')'" )
newPattern("command","[executable][arguments]{Ct( Cf( Ct('')*space^1 * pair('argName',P'-'*C(character) )* (space^1 *'\"'*valueString('argValue')*'\"')^-1 * P'\\'^-1 *P'\n'^-1 ,rawset )^0 ) }_")


endline =   P'\n'
inst = command 
newPattern('func','function [name]_()_{_}')
 

pattern = command
createTable=Cf(lpeg.Ct("")* pattern,rawset)

textbuffer = [[function Get_Archive_Format ()  {}]]
textbuffer = [[sed -r \
   -e "s/.*\.(tar\.bz|tbz)$/tarbzip/" \
   -e "s/.*\.(tar\.bz2|tbz2)$/tarbzip2/" \
   -e "s/.*\.(tar\.(gz|Z)|tgz)$/targzip/" \
   -e "s/.*\.(cpio\.(gz|Z)|tgz)$/cpiogzip/" \
   -e "s/.*\.tar\.(lzma|7z)$/tarlzma/" \
   -e "s/.*\.tar\.xz$/tarxz/" \
   -e "s/.*\.bz$/bzip/" \
   -e "s/.*\.bz2$/bzip2/" \
   -e "s/.*\.gz$/gzip/" \
   -e "s/.*\.Z$/gzip/" \
   -e "s/.*\.tar$/tar/" \
   -e "s/.*\.(lzma|7z)$/lzma/" \
   -e "s/.*\.xz$/xz/" \
   -e "s/.*\.zip$/zip/" \
   -e "s/.*\.cpio$/cpio/"]]
table = createTable:match(textbuffer)

if table == nil then
	table = {}
end
for key,value in pairs(table.arguments) do --actualcode
	print(key,": ",value)
end