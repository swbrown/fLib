fLib.Guild = {}
local groster = {} --complete list of guildees
--key = player name
--value = player info: rank, level, class, online, status

--watches for system messages that should affect groster
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
		info = groster[name]
		if info then
			info.online = 0
		end
	elseif words[4] == 'online.' then
		--> update roster
		name = words[1]
		info = groster[name]
		if info then
			info.online = 1
		end
	elseif words[3] == 'promoted' or words[3] == 'demoted' then
		--> update roster
		name = words[4]
		info = groster[name]
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
			wipe(groster[name])
			info = true
		end
	elseif words[8] == 'guild' then
		if words[3] == 'kicked' then
			--> update roster
			name = words[1]
			wipe(groster[name])
			info = true
		end
	end
	
	if name and not info then
		GuildRoster()
	end
end

function fLib.Guild.CHAT_MSG_WHISPER(eventName, msg, author)
	--update the guildees online status if they whisper you
	if groster[author] then
		groster[author].online = 1
	end
end

--making a call to GuildRoster() is the only way to refresh the status of guildees
function fLib.Guild.RefreshStatus()
	GuildRoster()
end

function fLib.Guild.GUILD_ROSTER_UPDATE()
	wipe(groster)
	for i = 1, GetNumGuildMembers(true) do
		local name, rank, rankIndex, level, class, zone, note, 
		officernote, online, status, something = GetGuildRosterInfo(i)
		
		if name then
			groster[name] = {
				rank = rank,
				level = level,
				class = class,
				online = online,
				status = status,
			}
		end
	end
end

function fLib.Guild.GetInfo(name)
	fLib.String.Capitalize(name)
	return groster[name]
end

function fLib.Guild.PrintInfo(name)
	fLib.String.Capitalize(name)
	local info = groster[name]
	if not info then
		print(name .. ' is not in the guild.')
	else
		for key, val in pairs(info) do
			print(key .. ' = ' .. val)
		end
	end
end

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