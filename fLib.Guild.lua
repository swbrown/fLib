fLib.Guild = {}
local roster = {} --complete list of guildees
--key = player name
--value = player info: rank, level, class, online, status
local total = 0
local totalonline = 0

local callbacks = {} --list of functions to callback after refreshstatus

--watches for system messages that should affect roster
function fLib.Guild.CHAT_MSG_SYSTEM(eventName, msg)
	local words = fLib.String.ParseWords(msg)
	local  name, info
	--[name] has gone offline.
	--[name] has come online.
	--[name] has joined the guild.
	--[name] has left the guild.
	--[name] has been kicked out of the guild by Tamrah.
	--[You] has promoted/demoted [name] to [newrank].
	--You have invited [name] to join your guild.

	if words[4] == 'offline.' then
		--> update roster
		name = words[1]
		info = roster[name]
		if info then
			info.online = 0
		end
	elseif words[4] == 'online.' then
		--> update roster
		name = words[1]
		info = roster[name]
		if info then
			info.online = 1
		end
	elseif words[3] == 'promoted' or words[3] == 'demoted' then
		--> update roster
		name = words[4]
		info = roster[name]
		if info then
			local newrank = strsub(words[6], 1, #words[6] - 1)
			info.rank = newrank
		end
	elseif words[5] == 'guild.' then
		if words[3] == 'joined' then
			print('guild join detected')
			-->  update roster
			name = words[1]
		elseif words[3] == 'left' then
			print('guild left detected')
			name = words[1]
			wipe(roster[name])
			info = true
		end
	elseif words[8] == 'guild' then
		if words[3] == 'kicked' then
			--> update roster
			name = words[1]
			wipe(roster[name])
			info = true
		end
	end
	
	if name and not info then
		GuildRoster()
	end
end

function fLib.Guild.CHAT_MSG_WHISPER(eventName, msg, author)
	--update the guildees online status if they whisper you
	if roster[author] then
		roster[author].online = 1
	end
end

--making a call to GuildRoster() is the only way to refresh the status of guildees
function fLib.Guild.RefreshStatus(func)
	if not fLib.ExistsInList(callbacks, func) then
		tinsert(callbacks, func)
	end
	GuildRoster()
end

--save the guild list into roster
function fLib.Guild.GUILD_ROSTER_UPDATE()
	fLib:Debug("fLib.Guild.GUILD_ROSTER_UPDATE")
	wipe(roster)
	total = 0
	totalonline = 0
	for i = 1, GetNumGuildMembers(true) do
		local name, rank, rankIndex, level, class, zone, note, 
		officernote, online, status, _ = GetGuildRosterInfo(i)
		
		if name then
			roster[name] = {
				rank = rank,
				level = level,
				class = class,
				zone = zone,
				online = online,
				status = status,
			}
			total = total + 1
			if online then
				totalonline = totalonline + 1
			end
		end
	end
	
	--callbacks
	while #callbacks > 0 do
		local func = tremove(callbacks, 1)
		func()
	end
end

function fLib.Guild.Count(onlineonly)
	if onlineonly then
		return totalonline
	end
	return total
end

function fLib.Guild.GetInfo(name)
	name = fLib.String.Capitalize(name)
	return roster[name]
end

function fLib.Guild.PrintInfo(name)
	name = fLib.String.Capitalize(name)
	local info = roster[name]
	if not info then
		print(name .. ' is not in the guild.')
	else
		for key, val in pairs(info) do
			print(key .. ' = ' .. val)
		end
	end
end

