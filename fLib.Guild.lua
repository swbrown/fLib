fLib.Guild = {}
local roster = {} --complete list of guildees
--key = player name
--value = player info: rank, level, class, online, status
local total = 0
local totalonline = 0

local callbacks = {} --list of functions to callback after refreshstatus

--queue of names to demote/promote
local demotequeue = {}
local promotequeue = {}

fLib.Guild.Roster = roster

function fLib.Guild.TimeUp()
	fLib.Guild.DoMotes()
end

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
		name = fLib:CardinalName(words[1])
		info = roster[name]
		if info then
			info.online = 0
		end
	elseif words[4] == 'online.' then
		--> update roster
		name = fLib:CardinalName(words[1])
		info = roster[name]
		if info then
			info.online = 1
		end
	elseif words[3] == 'promoted' or words[3] == 'demoted' then
		--> update roster
		name = fLib:CardinalName(words[4])
		info = roster[name]
		if info then
			local newrank = strsub(words[6], 1, #words[6] - 1)
			info.rank = newrank
		end
		
		--remove from demote/promote queue if necessary
		local num = fLib.ExistsInList(demotequeue, name)
		if num and words[3] == 'demoted' then
			tremove(demotequeue, num)
		end
		
		num = fLib.ExistsInList(promotequeue, name)
		if num and words[3] == 'promoted' then
			tremove(promotequeue, num)
		end
		
		fLib.Guild.DoMotes()
	elseif words[5] == 'guild.' then
		if words[3] == 'joined' then
			print('guild join detected')
			-->  update roster
			name = fLib:CardinalName(words[1])
		elseif words[3] == 'left' then
			print('guild left detected')
			name = fLib:CardinalName(words[1])
			wipe(roster[name])
			info = true
		end
	elseif words[8] == 'guild' then
		if words[3] == 'kicked' then
			--> update roster
			name = fLib:CardinalName(words[1])
			wipe(roster[name])
			info = true
		end
	end
	
	if name and not info then
		GuildRoster()
	end
end

function fLib.Guild.CHAT_MSG_WHISPER(eventName, msg, author)
	local cardinalAuthor = fLib:CardinalName(author)
	--update the guildees online status if they whisper you
	if roster[cardinalAuthor] then
		roster[cardinalAuthor].online = 1
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
                local cardinalName = fLib:CardinalName(name)

		if cardinalName then
			roster[cardinalName] = {
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
	
	fLib.Guild.LoadedOnce = true
	fLib.Guild.LastLoadedTime = fLib.GetTimestamp()
	
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
	local cardinalName = fLib:CardinalName(name)
	return roster[cardinalName]
end

function fLib.Guild.PrintInfo(name)
	local cardinalName = fLib:CardinalName(name)
	local info = roster[cardinalName]
	if not info then
		print(cardinalName .. ' is not in the guild.')
	else
		for key, val in pairs(info) do
			print(key .. ' = ' .. val)
		end
	end
end

function fLib.Guild.ConfirmMotions(func)
	fLib.Guild.ConfirmMotionsEndFunc = func
	--making a timer that will call DoMotes every some minutes in case
	--a promotion or demotion fails
	--which is hopefully really unlikely
	if not fLib.Guild.MoteTimer then
		fLib.Guild.MoteTimer = fLib.ace:ScheduleRepeatingTimer(fLib.Guild.TimeUp, 180) --secs
	end
	fLib.Guild.DoMotes()
end

function fLib.Guild.DoMotes()
	--demote/promote the next person in the queue
	if #demotequeue > 0 then
		GuildDemote(demotequeue[1])
	elseif #promotequeue > 0 then
		GuildPromote(promotequeue[1])
	else
		fLib.ace:CancelTimer(fLib.Guild.MoteTimer, true)
		if fLib.Guild.ConfirmMotionsEndFunc then
			fLib.Guild.ConfirmMotionsEndFunc()
			fLib.Guild.ConfirmMotionsEndFunc = nil
		end
	end
end

function fLib.Guild.Demote(name)
	tinsert(demotequeue, name)
end

function fLib.Guild.Promote(name)
	tinsert(promotequeue, name)
end

function fLib.Guild.PrintQueue()
	local msg = ""
	for _, name in ipairs(demotequeue) do
		msg = msg .. name .. ","
	end
	
	for _, name in ipairs(promotequeue) do
		msg = msg .. name .. ","
	end
	fLib.ace:Print(msg)
end
