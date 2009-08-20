fLib.String = {}

--Returns an array of words
--Multiple spaces count as only 1 space
function fLib.String.ParseWords(str)
	local savedwords = {}
	for _, part in ipairs({strsplit(' ', str)}) do
		if part ~= '' then
			tinsert(savedwords, part)
		end
	end
	
	return savedwords
end

--Returns the string with the first letter capitalized
function fLib.String.Capitalize(str)
	return strupper(strsub(str,1,1)) .. strsub(str,2,#str)
end