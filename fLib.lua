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
	},
}

local ace = LibStub("AceAddon-3.0"):NewAddon(NAME)

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

function ace:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New(DBNAME, defaults)
	addon:Debug(DBNAME .. " loaded")
	addon:Debug('printing global '.. DBNAME)
	for key,val in pairs(addon.db.global) do
		addon:Debug('key=' .. tostring(key) .. ',val=' .. tostring(val))
	end
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable(NAME, options, {NAME})
end

--====================================================================================

--Functions in my library
--====================================================================================
--Outputs message to the chat window when debug is turned on
--note: in order for AceConsole-3.0 to print the addon name in pretty color, the addon needs to have a metatable
--with the __tostring function set to return the addon name
function addon:Debug(msg)
	if self.db and self.db.global and self.db.global.debug then
		if self.Print then
			self:Print(tostring(msg))
		else
			LibStub('AceConsole-3.0'):Print(self, msg)
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
	return strupper(strsub(str,1,1)) .. strsub(str,2,#str)
end

function addon:ExtractItemId(itemlink)
	local _,_,itemid = strfind(itemlink, 'Hitem:(%d+):')
	return tonumber(itemid)
end

--Disbands the current raid
local function DisbandRaidHandler(callback)
	SendChatMessage("Disbanding raid.", "RAID", nil, nil)
	for M=1,GetNumRaidMembers() do UninviteUnit("raid"..M) end
	callback()
end
function addon:DisbandRaid()
	--SendChatMessage("Disbanding raid.", "RAID", nil, nil)
	--for M=1,GetNumRaidMembers() do UninviteUnit("raid"..M) end
	self:ConfirmDialog('Are you sure you want to disband the raid?', 'YESNO', DisbandRaidHandler)
end

--helper function for ConfirmDialog
local function CloseHandler()
	tablet:Close(NAME .. '_Confirm')
	tablet:Unregister(NAME .. '_Confirm')
end

--shows a confirmation dialog
--possible values for type are 'YESNO' and 'OK'
--for 'YESNO' types, clicking yes will call the callback function with args specified in ...
--for 'OK' types', clicking ok will close the dialog
--defaults to 'OK', if type 
function addon:ConfirmDialog(msg, type, callback, ...)
	if not tablet:IsRegistered(NAME .. '_Confirm') then
		self:Debug('REgistering tablet ' .. NAME .. '_Confirm')
		
		if not type or (type ~= 'OK' and type ~= 'YESNO') then
			type = 'OK'
		end
		if not callback then
			type = 'OK'
		end
		
		local tablet_data = {
			detached = true,
			anchor = "CENTER",
			offsetx = 0,
			offsety = 0 }
			
		
		local args = {...}
		local args2 = {}
		local count = 0
		if #args > 0 then
			for idx,val in ipairs(args) do
				count  = count + 1
				args2[#args2+1] = 'arg' .. tostring(count)
				args2[#args2+1] = val
			end
		end
		count = count + 1
		args2[#args2+1] = 'arg' .. tostring(count)
		args2[#args2+1] = function() LibStub('AceTimer-3.0'): ScheduleTimer( CloseHandler, 0 ) end
		
		tablet:Register(NAME.. '_Confirm', 'detachedData', tablet_data,
			'strata', "DIALOG",
			'maxHeight', 850,
			'cantAttach', true,
			'dontHook', true,
			'showTitleWhenDetached', true,
			'children', function()
				tablet:SetTitle(msg)
				tablet:SetTitleColor(.2, .6, 1)
				local cat = tablet:AddCategory('columns', 1)
				if type == 'OK' then
					cat:AddLine(
						'text', 'Ok',
						'justify', 'CENTER',
						'textR', .2, 'textG', .6, 'textB', 1,
						'func', function() LibStub('AceTimer-3.0'): ScheduleTimer( CloseHandler, 0 ) end
					)
				elseif type == 'YESNO' then
					if #args2 > 0 then
						cat:AddLine(
							'text', 'Yes',
							'justify', 'CENTER',
							'textR', 0, 'textG', 1, 'textB', 0,
							'func', callback,
							unpack(args2)
						)
					else
						cat:AddLine(
							'text', 'Yes',
							'justify', 'CENTER',
							'textR', 0, 'textG', 1, 'textB', 0,
							'func', callback
						)
					end

					cat:AddLine(
						'text', 'No',
						'justify', 'CENTER',
						'textR', 1, 'textG', 0, 'textB', 0,
						'func', function() LibStub('AceTimer-3.0'): ScheduleTimer( CloseHandler, 0 ) end
					)
				end
			end
		)
	else
		tablet:Refresh(NAME .. '_Confirm')
	end
	
	tablet:Open(NAME .. '_Confirm')
end

--[[
Example of how to use ConfirmDialog
function addon:TestPrint()
	self:ConfirmDialog('are you sure you want to testprint?', 'YESNO', self.TestPrintCallback, self, 'difhid', 'dfihoid')
end

function addon:TestPrint2()
	self:ConfirmDialog('are wsgw?', 'OK', self.TestPrintCallback, self, 'jjjjj', 'pppppp')
end

function addon:TestPrintCallback(x, y, callbackfromconfirmdialog)
	print(tostring(self))
	print('something printed by testprintcallback')
	print('x='..tostring(x))
		print('y='..tostring(y))
			print('z='..tostring(z))
	callbackfromconfirmdialog()
end
--]]

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
	"ConfirmDialog"
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