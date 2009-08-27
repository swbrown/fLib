fLib.Friends = {}
local roster = {} --complete list of friends
--key = player name
--value = player info: guild, level, class, online, status
local total = 0
local totalonline = 0

local callbacks = {} --list of functions to callback after refreshstatus

--fLib.db.global.friends.tbr
----list of names to remove from friend list when you login

function fLib.Friends.CHAT_MSG_WHISPER(eventName, msg, author)
	--update the guildees online status if they whisper you
	if roster[author] then
		roster[author].online = 1
	end
end

--making a call to ShowFriends() is the only way to refresh the status of friends
function fLib.Friends.RefreshStatus(func)
	if not fLib.ExistsInList(callbacks, func) then
		tinsert(callbacks, func)
	end
	ShowFriends()
end

--remove friends in your tbr from friend list
function fLib.Friends.CleanUp()
	local name = fLib.db.global.friends.tbr[1]
	while name do
		RemoveFriend(name)
		tremove(fLib.db.global.friends.tbr, 1)
		name = fLib.db.global.friends.tbr[1]
	end
end

--save your friends list into roster
function fLib.Friends.FRIENDLIST_UPDATE()
	wipe(roster)
	total = 0
	totalonline = 0
	for i = 1, GetNumFriends(true) do
		local name, level, class, zone, online, status, note = GetFriendInfo(i)
		if name then
			roster[name] = {
				level = level,
				class = class,
				zone = zone,
				online = online,
				status = status,
				note = note
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

function fLib.Friends.Count(onlineonly)
	if onlineonly then
		return totalonline
	end
	return total
end

function fLib.Friends.GetInfo(name)
	name = fLib.String.Capitalize(name)
	local info = roster[name]
	if not info then
		AddFriend(name)
		tinsert(fLib.db.global.friends.tbr, name)
	end
	return info
end

function fLib.Friends.PrintInfo(name)
	name = fLib.String.Capitalize(name)
	local info = roster[name]
	if not info then
		print(name .. ' is not in your friends list.')
	else
		for key, val in pairs(info) do
			print(key .. ' = ' .. val)
		end
	end
end