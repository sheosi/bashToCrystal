#!/usr/bin/fish
set actualFile bash.g4
set crcFile .(echo $actualFile).crc32

function rebuildFile
  antlr4 -Dlanguage=Python3 $actualFile
end

function action
  python3 main.py example.sh
end

function rebuild
  echo "Had to rebuild"
	rebuildFile
	crc32 $actualFile > $crcFile
	if [ $status ]
		action
	else
		rm $crcFile
	end
end

if [ ! -f $crcFile ]
	rebuild
else 
	if [ (cat $crcFile) != (crc32 $actualFile) ]
			rebuild
	else
		action
	end
end
