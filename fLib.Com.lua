fLib.Com = {}
--[[
Chat Types:
"SAY" 
Speech to nearby players (/say).
"EMOTE" 
Text emote to nearby players (/em) (Use DoEmote("action") for voice emotes)
"YELL" 
Yell to not so nearby players (/yell).
"PARTY" 
Message to party members (/p)
"GUILD" 
Message to guild members (/g)
"OFFICER" 
Message to guild officers (/o)
"RAID" 
Message to raid members (/raid)
"RAID_WARNING" 
Warning to raid members (/rw)
"BATTLEGROUND" 
Message to battleground raid group (/bg)
"WHISPER" 
Message to a specific other player (/whisper) - Player name provided as channel.
"CHANNEL" 
Message to a specific chat channel (/1,/2,...) - Channel number provided as channel

"AFK"
Not a real channel; sets your AFK message to the message you send. Send an empty message to clear AFK status.
"DND"
Not a real channel; sets your DND message to the message you send. Send an empty message to clear DND status.
--]]

function fLib.Com.Send(msg, chattype, dest)
	local msgpart = ""
	local size = 255
	for i = 1, #msg, size do
		msgpart = strsub(msg, i, i + size - 1)
		ChatThrottleLib:SendChatMessage("NORMAL", "", msgpart, chattype, nil, dest)
		--print(msgpart)
	end
end

function fLib.Com.Whisper(msg, target)
	fLib.Com.Send(msg, "WHISPER", target)
end

function fLib.Com.Channel(msg, ...)
	for _, channeltarget in ipairs({...}) do
		if type(channeltarget) == "number" then
			fLib.Com.Send(msg, "CHANNEL", channeltarget)
		else
			local id = GetChannelName(channeltarget)
			fLib.Com.Send(msg, "CHANNEL", id)
		end
	end
end

function fLib.Com.Special(msg, ...)
	for _, chattype in ipairs({...}) do
		fLib.Com.Send(msg, chattype)
	end
end