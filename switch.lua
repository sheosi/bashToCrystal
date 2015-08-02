function switch( input )
	return function (caseTable)
		local f

		if input then f = caseTable[input]  or caseTable.default
		else		  f = caseTable.missing or caseTable.default --nil values
		end

		if f then 
			if type(f)=="function" then return f(input,self)
			else                        return f
			end

		else
			error("switch:",input," has no entry and there's no 'default' one")
			
		end
	end
end
