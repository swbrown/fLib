local MAJOR, MINOR = "fLib", 1
local fLibStub, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not fLibStub then return end -- No upgrade needed

fLib = fLibStub
local addon = fLib
local NAME = "fLib"
local DBNAME = "fLibDB"
local ICONNAME = "fLibICON"
local icon = LibStub("LibDBIcon-1.0", true)

fLib = LibStub("AceConsole-3.0"):Embed(fLib)

local defaults = {
	global = {
		debug = false,
		minimap = {
			hide = false,
		},
	},
}

addon.name = NAME
addon.iconname = ICONNAME
addon.db = LibStub("AceDB-3.0"):New(DBNAME, defaults)

addon.embeds = addon.embeds or {} -- table containing objects fLib is embedded in.
addon.commands = addon.commands or {} -- table containing commands registered
addon.weakcommands = addon.weakcommands or {} -- table containing self, command => func references for weak commands that don't persist through enable/disable

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
			set = function(info, v)
				local hide = not v
				addon.db.global.minimap.hide = hide
				if hide then
					icon:Hide(ICONNAME)
				else
					icon:Show(ICONNAME)
				end
			end,
		},
	}
}
fLib.options = options
LibStub("AceConfig-3.0"):RegisterOptionsTable(NAME, options, {NAME})

--Outputs message to the chat window when debug is turned on
function addon:Debug(msg)
	if self.db and self.db.global and self.db.global.debug then
		if self == addon then
			LibStub('AceConsole-3.0'):Print("|cff33ff99"..NAME.."|r: " .. msg)
		else
			self:Print(tostring(msg))
		end
	end
end

--Send a whisper
function addon:Whisper(name, msg)
	SendChatMessage("[" .. self.name .. "] " .. msg, "WHISPER", nil, name)
end

--AceConfig options handler
--Opens a config window (type = "ace" or type = "blizz")
--type-defaults to ace config window
function addon:OpenConfig(info, type)
	if not type then
		type = "ace"
	end
	
	--if (self.name ~= NAME) then
		if type == "ace" then
			--Opens Ace config dialog
			LibStub("AceConfigDialog-3.0"):Open(self.name)
		else
			--Opens Blizz config dialog
			InterfaceOptionsFrame_OpenToCategory(self.name)
		end
	--end
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

function addon:DisbandRaid()
	SendChatMessage("Disbanding raid.", "RAID", nil, nil)
	for M=1,GetNumRaidMembers() do UninviteUnit("raid"..M) end
end

--- embedding and embed handling

local mixins = {
	"Debug",
	"Whisper",
	"OpenConfig",
	"GetOptions",
	"SetOptions",
	"ParseName",
	"ParseWords",
	"DisbandRaid",
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