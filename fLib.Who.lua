fLib.Who = {}
local wholist = {} --list of people you've request info about
--key = player name
--value = player info: guild, rank, level, class, online, status


--returns info about name if we have it
--otherwise returns nil
function fLib.Who.Info(name)
	local info = wholist[name]
	if not info then
	end
	return info
end

