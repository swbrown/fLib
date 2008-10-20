local MAJOR, MINOR = "fLib", 1
local fLib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not fLib then return end -- No upgrade needed
local addon = fLib

fLib.embeds = fLib.embeds or {} -- table containing objects AceConsole is embedded in.
fLib.commands = fLib.commands or {} -- table containing commands registered
fLib.weakcommands = fLib.weakcommands or {} -- table containing self, command => func references for weak commands that don't persist through enable/disable

--Outputs message to the chat window when debug is turned on
function addon:Debug(msg)
	if self.db and self.db.global and self.db.global.debug then
		self:Print(tostring(msg))
	end
end

--AceConfig options handler
--Opens a config window (type = "ace" or type = "blizz")
--type-defaults to ace config window
function addon:OpenConfig(info, type)
	if not type then
		type = "ace"
	end
	
	if (self.name ~= addon.name) then
		if type == "ace" then
			--Opens Ace config dialog
			LibStub("AceConfigDialog-3.0"):Open(self.name)
		else
			--Opens Blizz config dialog
			InterfaceOptionsFrame_OpenToCategory(self.name)
		end
	end
end

--Get handler for AceConfig
--Will get the stored value from AceDB
--info[#info] = current node name
--info[#info-1] = parent name of the current node
function addon:GetOptions(info)
	self:Debug("<<GetOptions>> start, " .. info[#info] .. ", parent = " .. info[#info - 1])
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

--Returns the 2nd word in the string
--multiple spaces count as only 1 space
function addon:ParseName(str)
	local words = {strsplit(" ", str)}
	for idx,value in ipairs(words) do
		if idx > 1 then
			if value ~= "" then
				return value
			end
		end
	end
	
	return ""
end

function addon:DisbandRaid()
	SendChatMessage("Disbanding raid.", "RAID", nil, nil)
	for M=1,GetNumRaidMembers() do UninviteUnit("raid"..M) end
end

--- embedding and embed handling

local mixins = {
	"Debug",
	"OpenConfig",
	"GetOptions",
	"SetOptions",
	"ParseName",
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