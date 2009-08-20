--a request for class

fLib.Who = {}
local whoqueue = {} --queue of players you are requesting
--key = player name
--value = callbackfunc, list of arguments

local wholist = {} --list of players and their info 
--key = player name
--value = player info: guildname, level, race, class, zone, online, status

--returns info about name if we have it
--otherwise returns nil
function fLib.Who.Info(name)
	local info = wholist[name]
	if not info then
	end
	return info
end
