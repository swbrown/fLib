--LibStub
--AceAddon-3.0
--AceConfig-3.0
--AceConfigDialog-3.0
--AceDB-3.0
--AceTimer-3.0
--AceLibrary
--LibDBIcon-1.0
--Tablet-2.0

local MAJOR, MINOR = "fLib", 1
local fLibStub, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not fLibStub then return end -- No upgrade needed
fLib = fLibStub

local addon = fLib
local NAME = "fLib"
local DBNAME = "fLibDB"
local ICONNAME = "fLibICON"
local icon = LibStub("LibDBIcon-1.0", true)

addon.ICONNAME = ICONNAME

local addon_meta = {
	__tostring = function() return NAME end
}
setmetatable(addon, addon_meta)

local tablet = AceLibrary('Tablet-2.0')

--====================================================================================
--Initializing ace stuff

local defaults = {
	global = {
		debug = false,
		minimap = {
			hide = false,
			minimapPos = 180,
		},
		friends = {
			tbr = {}
		}
	},
}

local options = {
	type='group',
	name = NAME,
	handler = addon,
	args = {
		debug = {
			order = -1,
			type = "toggle",
			name = 'Debug',
            desc = "Enables and disables debug mode.",
            get = "GetOptions",
            set = "SetOptions",
		},
		config = {
	    	order = -1,
	    	type = 'execute',
	    	name = 'config',
	    	desc = 'Opens configuration window',
	    	func = 'OpenConfig',
	    	guiHidden = true,
	    },
		minimap = {
			order = 1,
			type = "toggle",
			name = "Minimap icon",
			desc = "Toggle the minimap icon.",
			get = function()
				return not addon.db.global.minimap.hide
				--return true
			end,
			set = function(info, checked)
				addon.db.global.minimap.hide = not checked
				
				--local hide = not v
				--addon.db.global.minimap.hide = hide
				if not checked then
					icon:Hide(ICONNAME)
				else
					icon:Show(ICONNAME)
				end
			end,
		},
	}
}
addon.options = options

local ace = LibStub("AceAddon-3.0"):NewAddon(NAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
fLib.ace = ace
local timer1
local TIMER_INTERVAL = 5 --secs

function ace:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New(DBNAME, defaults)
	addon:Debug(DBNAME .. " loaded")
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable(NAME, options, {NAME})
	
	--cleanup friends in your tbr
	--fLib.Friends.CleanUp() --might cause crash?
	
	self:RegisterEvent('CHAT_MSG_SYSTEM')
	self:RegisterEvent('CHAT_MSG_WHISPER')
	self:RegisterEvent('GUILD_ROSTER_UPDATE')
	self:RegisterEvent('FRIENDLIST_UPDATE')
	
	GuildRoster()
end

function ace:CHAT_MSG_SYSTEM(...)
	fLib.Guild.CHAT_MSG_SYSTEM(...)
end
function ace:CHAT_MSG_WHISPER(...)
	fLib.Guild.CHAT_MSG_WHISPER(...)
	fLib.Friends.CHAT_MSG_WHISPER(...)
end
function ace:GUILD_ROSTER_UPDATE()
	fLib.Guild.GUILD_ROSTER_UPDATE()
end
function ace:FRIENDLIST_UPDATE()
	fLib.Friends.FRIENDLIST_UPDATE()
end

--====================================================================================

--Functions in my library
--====================================================================================
--Outputs message to the chat window when debug is turned on
--note: in order for AceConsole-3.0 to print the addon name in pretty color, the addon needs to have a metatable
--with the __tostring function set to return the addon name
function addon:Debug(...)
	if self.db and self.db.global and self.db.global.debug then
		if self.Print then
			self:Print(...)
		else
			LibStub('AceConsole-3.0'):Print(self, msg)
		end
	end
end


--Send a whisper
function addon:Whisper(name, msg)
	--SendChatMessage("[" .. self.name .. "] " .. msg, "WHISPER", nil, name)
	fLib.Com.Whisper("[" .. self.name .. "] " .. msg, name)
end

--AceConfig options handler
--Opens a config window (type = "ace" or type = "blizz")
--type-defaults to ace config window
function addon:OpenConfig(info, type)
	if self == addon then
		self.name = NAME
	end
	
	if not self.name or self.name == '' then
		return
	end
	
	if not type then
		type = "ace"
	end
	
	if type == "ace" then
		--Opens Ace config dialog
		LibStub("AceConfigDialog-3.0"):Open(self.name)
	else
		--Opens Blizz config dialog
		InterfaceOptionsFrame_OpenToCategory(self.name)
	end
end

--Get handler for AceConfig
--Will get the stored value from AceDB
--info[#info] = current node name
--info[#info-1] = parent name of the current node
function addon:GetOptions(info)
	if not info then
		self:Debug("<<GetOptions>> info is null")
		return
	end
	self:Debug("<<GetOptions>> start, " .. info[#info] .. ", parent = " .. tostring(info[#info - 1]))
	if info[#info - 1] == self.name then
		return self.db.global[info[#info]]
	else
		if self.db.global[info[#info-1]] == nil then
			return nil
		else
			return self.db.global[info[#info-1]][info[#info]]
		end
	end
	self:Debug("<<GetOptions>> end")
end

--Set handler for AceConfig
--Will set the value to AceDB
function addon:SetOptions(info, input)
	if not info then
		self:Debug("<<SetOptions>> info is null")
		return
	end
	self:Debug("<<SetOptions>> start")
	if info[#info - 1] == nil then
		self.db.global[info[#info]] = input
		self:Debug("self.db.global." .. info[#info] .. "set to " .. tostring(input))
	else
		if self.db.global[info[#info-1]] == nil then
			self.db.global[info[#info-1]] = {}
		end
		self.db.global[info[#info-1]][info[#info]] = input
		self:Debug("self.db.global." .. info[#info-1] .. "." .. info[#info] .. "set to " .. tostring(input))
	end
	self:Debug("<<SetOptions>> end")
end

--Returns an array of words
--Multiple spaces count as only 1 space
function addon:ParseWords(str)
	self:Debug("<<PARSEWORDS>> " .. tostring(str))
	local words = {strsplit(" ", strtrim(str))}
	local savedwords = {}
	for idx,value in ipairs(words) do
		if value ~= "" then
			savedwords[#savedwords+1] = value
		end
	end
	
	self:Debug("savedwordscount=" .. #savedwords)
	return savedwords
end

--Returns the string with the first letter capitalized
function addon:Capitalize(str)
	if str then
		return strupper(strsub(str,1,1)) .. strsub(str,2,#str)
	else
		return ''
	end
end

function addon:ExtractItemId(itemlink)
	local _,_,itemid = strfind(itemlink, 'Hitem:(%d+):')
	return tonumber(itemid)
end

--Disbands the current raid
local function DisbandRaidHandler()
	SendChatMessage("Disbanding raid.", "RAID", nil, nil)
	for M=1,GetNumGroupMembers() do UninviteUnit("raid"..M) end
end
function addon:DisbandRaid()
	--SendChatMessage("Disbanding raid.", "RAID", nil, nil)
        --for M=1,GetNumGroupMembers() do UninviteUnit("raid"..M) end
	self:ConfirmDialog2('Are you sure you want to disband the raid?', DisbandRaidHandler)
end

--shows a confirmation dialog
--clicking yes will call the callback function with args specified in ...
function addon:ConfirmDialog2(msg, callback, data)
	StaticPopupDialogs['fLib_Confirm_Dialog'] = {
		text = msg,
		button1 = 'Yes',
		button2 = 'No',
		OnAccept = function()
			callback(data)
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 0
	}
	
	StaticPopup_Show('fLib_Confirm_Dialog')
end

--tsobj, expected computer time or nil
--returns string in universal time
--warning: time(tsobj) returns seconds based on computer's time, so
----it expects tsobj to be in computer time also.
--date(format), the ! in the format converts computer time to universal time
function addon.GetTimestamp(tsobj)
	if tsobj then
		return date('!%y/%m/%d %H:%M:%S', time(tsobj))
	else
    	return date('!%y/%m/%d %H:%M:%S')
	end
end

--returns computer time object (can be used in time(obj))
function addon.GetTimestampObj()
	return date('*t') --computer time
end

--tsobj, expected computer time or nil
--returns computer time
function addon.AddDays(tsobj, daysnum)
	if not tsobj then tsobj = fLib.GetTimestampObj() end
	local dayssec = daysnum*24*60*60
	local startsec = time(tsobj)
	local endsec = startsec + dayssec
	return date('*t', endsec)
end
function addon.AddMinutes(tsobj, minsnum)
	if not tsobj then tsobj = fLib.GetTimestampObj() end
	local minssec = minsnum * 60
	local startsec = time(tsobj)
	local endsec = startsec + minssec
	return date('*t', endsec)
end

function addon.ConvertTimeStringToObject(tstr)
	local dat, tim = strsplit(' ', tstr)
	local y, m, d = strsplit('/', dat)
	local H, M, S
	if tim then
	 	H, M, S = strsplit(':', tim)
	else
		H, M, S = 0, 0, 0
	end
	
	y = tonumber(y)
	m = tonumber(m)
	d = tonumber(d)
	H = tonumber(H)
	M = tonumber(M)
	S = tonumber(S)
	y = 2000 + y
	
	local tsobj = date('*t')
	tsobj.year = y
	tsobj.month = m
	tsobj.day = d
	tsobj.hour = H
	tsobj.min = M
	tsobj.sec = S
	
	return tsobj
end

function addon.T1MinusT2ToMinutes(t1str, t2str)
	--convert time strings to data table
	local sec1 = time(fLib.ConvertTimeStringToObject(t1str))
	local sec2 = time(fLib.ConvertTimeStringToObject(t2str))
	
	local diff = sec1 - sec2
	diff = ceil(diff/60)
	
	return diff
end

function addon.ExistsInList(list, item)
	if list then
		for id, curitem in ipairs(list) do
			if item == curitem then
				return id
			end
		end
	end
	return false
end




--- embedding and embed handling

addon.embeds = addon.embeds or {} -- table containing objects fLib is embedded in.
addon.commands = addon.commands or {} -- table containing commands registered
addon.weakcommands = addon.weakcommands or {} -- table containing self, command => func references for weak commands that don't persist through enable/disable

local mixins = {
	"Debug",
	"Whisper",
	"OpenConfig",
	"GetOptions",
	"SetOptions",
	"Capitalize",
	"ParseWords",
	"ExtractItemId",
	"DisbandRaid",
	"ConfirmDialog2",
}

-- addon:Embed( target )
-- target (object) - target object to embed lib in
--
-- Embeds addon into the target object making the functions from the mixins list available on target:..
function addon:Embed( target )
	for k, v in pairs( mixins ) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

function addon:OnEmbedEnable( target )
	if addon.weakcommands[target] then
		for command, func in pairs( addon.weakcommands[target] ) do
			target:RegisterChatCommand( command, func, false, true ) -- nonpersisting and silent registry
		end
	end
end

function addon:OnEmbedDisable( target )
	if addon.weakcommands[target] then
		for command, func in pairs( addon.weakcommands[target] ) do
			target:UnregisterChatCommand( command ) -- TODO: this could potentially unregister a command from another application in case of command conflicts. Do we care?
		end
	end
end

for addon in pairs(addon.embeds) do
	addon:Embed(addon)
end
