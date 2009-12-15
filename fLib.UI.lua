fLib.UI = {}
fLib.UI.Frame = {}
fLib.UI.CheckBox = {}
fLib.UI.Button = {}
fLib.UI.EditBox = {}

--frame.Background: texture being used for the background
--frame.Separators: list of textures being used as separators
--frame.Checkmarks: list of checkmarks
--frame.SortArrowsDown
--frame.SortArrowsUp
--frame.Texts: list of fontstrings
--frame.CheckBoxes: list of checkbuttons
--frame.Buttons: list of buttons

--expects source is a table
--expects target is a table
local function MapFuncs(source, target)
	--map functions
	for funcn, funcf in pairs(source) do
		if type(funcf) == 'function' then
			if target[funcn] then
				error('Target already has a function called ' .. funcn)
			elseif funcn ~= 'New' then
				target[funcn] = funcf
			end
		end
	end
end

function fLib.UI.Frame.New(parent)
	if not parent then
		parent = UIParent
	end
	
	local frame = CreateFrame('frame', nil, parent)
	frame:SetClampedToScreen(true) --so it can't be dragged offscreen
	frame:EnableMouse(true) --so mouse can click on it to bring to front or drag
	frame:SetToplevel(true) --so clicking on it causes it to come to the front
	
	MapFuncs(fLib.UI.Frame, frame)
	
	return frame
end

local samplebackdrop = {
	-- path to the background texture
	bgFile = "Interface\\Tooltips\\ChatBubble-Background",
	-- path to the border texture
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	-- true to repeat the background texture to fill the frame, false to scale it
	tile = true,
	-- size (width or height) of the square repeating background tiles (in pixels)
	tileSize = 32,
	-- thickness of edge segments and square size of edge corners (in pixels)
	edgeSize = 16,
	-- distance from the edges of the frame to those of the background texture (in pixels)
	insets = { left = 6, right = 7, top = 7, bottom = 6 }
}

--normal sized border
function fLib.UI.Frame.AddBorder(self)
	--doh! backdrops can't do gradients!!!!!! ='(
	local backdrop = {
		-- path to the border texture
		edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
		-- thickness of edge segments and square size of edge corners (in pixels)
		edgeSize = 16,
	}
	self:SetBackdrop(backdrop)
	self:SetBackdropBorderColor(0.8, 0.6, 0.6)
end

--very thin border
function fLib.UI.Frame.AddBorder2(self)
	local backdrop = {
		edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
		edgeSize = 4,
	}
	self:SetBackdrop(backdrop)
	self:SetBackdropBorderColor(0.2, 0.2, 0.2)
end

--medium border
function fLib.UI.Frame.AddBorder3(self)
	local backdrop = {
		edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
		edgeSize = 8,
	}
	self:SetBackdrop(backdrop)
	self:SetBackdropBorderColor(0.6, 0.6, 0.6)
end

--gradient grayish background
function fLib.UI.Frame.AddBackground(self)
	--let's make a texture for my background instead!
	if not self.Background then
		self.Background = self:CreateTexture(nil, "BACKGROUND")
	end
	self.Background:SetTexture("Interface/ChatFrame/ChatFrameBackground")
	self.Background:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.9, 0.2, 0.2, 0.2, 0.9)
	self.Background:SetPoint('TOPLEFT', 4, -4)
	self.Background:SetPoint('BOTTOMRIGHT', -4, 4)
	self.Background:Show()
	--self.Background:Hide()
end

function fLib.UI.Frame.AddBackground2(self)
	if not self.Background then
		self.Background = self:CreateTexture(nil, "BACKGROUND")
	end
	self.Background:SetTexture("Interface/ChatFrame/ChatFrameBackground")
	self.Background:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.9, 0.2, 0.2, 0.2, 0.9)
	self.Background:SetPoint('TOPLEFT', 1, -1)
	self.Background:SetPoint('BOTTOMRIGHT', -1, 1)
	self.Background:Show()
	--self.Background:Hide()	
	
end

function fLib.UI.Frame.MakeDraggable(self)
	self:SetMovable(true) --so it can move
	self:RegisterForDrag('LeftButton') --OnDragStart and OnDragStop eventswork
	self:SetScript('OnDragStart', function(this, button)
		this:StartMoving()
	end)
	self:SetScript('OnDragStop', function(this, button)
		this:StopMovingOrSizing()
	end)
end

--stores the texture in frame.Separators
--stores the index in texture.Index
--returns the texture
function fLib.UI.Frame.AddSeparator(self)
	if not self.Separators then
		self.Separators = {}
	end
	
	local ui = self:CreateTexture(nil, 'ARTWORK')
	ui:SetTexture(1,1,1,0.2)
	ui:SetHeight(1)
	ui:SetWidth(10) --default width
	
	tinsert(self.Separators, ui)
	ui.Index = #self.Separators
	return ui
end

function fLib.UI.Frame.AddCheckmark(self)
	if not self.Checkmarks then
		self.Checkmarks = {}
	end
	
	local ui = self:CreateTexture(nil, 'OVERLAY')
	ui:SetTexture('Interface/AchievementFrame/UI-Achievement-Criteria-Check')
	tinsert(self.Checkmarks, ui)
	ui.Index = #self.Checkmarks
	return ui
end

function fLib.UI.Frame.AddSortArrowDown(self)
	if not self.SortArrowsDown then
		self.SortArrowsDown = {}
	end
	
	local ui = self:CreateTexture(nil, 'OVERLAY')
	ui:SetTexture('Interface/BUTTONS/Arrow-Down-Up')
	tinsert(self.SortArrowsDown, ui)
	ui.Index = #self.SortArrowsDown
	return ui
end

function fLib.UI.Frame.AddSortArrowUp(self)
	if not self.SortArrowsUp then
		self.SortArrowsUp = {}
	end
	
	local ui = self:CreateTexture(nil, 'OVERLAY')
	ui:SetTexture('Interface/BUTTONS/Arrow-Up-Up')
	tinsert(self.SortArrowsUp, ui)
	ui.Index = #self.SortArrowsUp
	return ui
end

--stores the fontstring in frame.Texts
--stores the index in fontstring.Index
--returns the fontstring
function fLib.UI.Frame.AddText(self)
	if not self.Texts then
		self.Texts = {}
	end
	
	local ui = self:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	ui:SetAlpha(0.8)
	
	tinsert(self.Texts, ui)
	ui.Index = #self.Texts
	return ui
end

--stores the checkbutton in frame.CheckBoxes
--stores the index in checkbutton.Index
--returns the checkbutton
--Note: use checkbutton:SetText('blahblah'), b/c we set the fontstrong, so it should work
function fLib.UI.Frame.AddCheckBox(self)
	if not self.CheckBoxes then
		self.CheckBoxes = {}
	end

	local ui = fLib.UI.CheckBox.New(self)
	tinsert(self.CheckBoxes, ui)
	ui.Index = #self.CheckBoxes
	return ui
end

function fLib.UI.Frame.AddButton(self)
	if not self.Buttons then
		self.Buttons = {}
	end
	
	local ui = fLib.UI.Button.New(self)
	tinsert(self.Buttons, ui)
	ui.Index = #self.Buttons
	return ui
end

function fLib.UI.CheckBox.New(parent)
	if not fLib.UI.CheckBox.Number then
		fLib.UI.CheckBox.Number = 0
	end
	
	fLib.UI.CheckBox.Number = fLib.UI.CheckBox.Number + 1
	local name = 'fLibUICheckBox' .. fLib.UI.CheckBox.Number
	local ui = CreateFrame('CheckButton', name, parent, 'InterfaceOptionsCheckButtonTemplate')
	ui:SetFontString(_G[name..'Text'])
	
	--no functions to map yet...
	--MapFuncs(fLib.UI.CheckBox, ui)
	
	return ui
end

function fLib.UI.Button.New(parent)
	if not fLib.UI.Button.Font then
		fLib.UI.Button.Font = GameFontNormal:GetFontObject()
		fLib.UI.Button.Font:SetTextColor(0, 0.5, 1, 0.8)
	end

	local ui = CreateFrame('button', nil, parent)
	ui:SetNormalFontObject(fLib.UI.Button.Font)
	fLib.UI.Frame.AddBorder2(ui)
	
	ui:SetHighlightTexture('Interface/BUTTONS/UI-Listbox-Highlight2')
	local high = ui:GetHighlightTexture()
	high:SetAlpha(0.5)
	high:SetPoint('TOPLEFT', 2, -2)
	high:SetPoint('BOTTOMRIGHT', -2, 2)
	
	MapFuncs(fLib.UI.Button, ui)
	
	return ui
end

function fLib.UI.Button.Resize(self)
	self:SetWidth(self:GetTextWidth() + 4)
	self:SetHeight(self:GetTextHeight() + 4)
end

function fLib.UI.Button.TogglePermanentHighlight(self)
	if not self.PermanentHighlight then
		self.PermanentHighlight = self:CreateTexture(nil, 'BACKGROUND')
		self.PermanentHighlight:SetTexture('Interface/BUTTONS/UI-Listbox-Highlight')
		self.PermanentHighlight:SetAlpha(0.5)
		self.PermanentHighlight:SetPoint('TOPLEFT', 2, -2)
		self.PermanentHighlight:SetPoint('BOTTOMRIGHT', -2, 2)
	else
		if self.PermanentHighlight:IsVisible() then
			self.PermanentHighlight:Hide()
		else
			self.PermanentHighlight:Show()
		end
	end
end

--style 1 is normal text box
function fLib.UI.EditBox.New(parent, style)
	if not style then
		style = 1
	end
	
	if style ~= 1 then
		style = 1
	end
	
	local ui = CreateFrame('editbox', nil, parent)
	ui:SetAutoFocus(false)
	ui:SetFontObject(GameFontHighlight)
	ui:SetTextInsets(6, 6, 0, 0)
	
	if style == 1 then
		fLib.UI.Frame.AddBorder3(ui)
		fLib.UI.Frame.AddBackground2(ui)
		ui:SetHeight(18)
		ui:SetWidth(25)
	end
	
	ui.Label = fLib.UI.Frame.AddText(ui)
	if style == 1 then
		ui.Label:SetAlpha(0.2)
		ui.Label:SetPoint('LEFT', 6, 0)
	end
	
	
	ui:SetScript('OnEnterPressed', function() this:ClearFocus() end)
	ui:SetScript('OnEscapePressed', function() this:ClearFocus() end)
	ui:SetScript('OnEditFocusGained', function() this:HighlightText() end)
	ui:SetScript('OnEditFocusLost', function() this:HighlightText(0,0) end)	
	
	
	return ui
end

--[[
print('----')

local function printt(t, max)
local m = 1
if not t then
print('table is nil')
else
for key, val in pairs(t) do
if max and m > max then
return
end
--if type(key) ~= 'number' then
print(key, val)
--end
m = m + 1
end
print('total = ' .. m)
end
end


print(fLib.GetTimestamp())

if not TT then
TT = {}
end
if not TT.f1 then
TT.f1 = fLib.UI.Frame.New()
end

TT.f1:AddBorder()
TT.f1:AddBackground()
TT.f1:MakeDraggable()

TT.f1:SetWidth(100)
TT.f1:SetHeight(100)
TT.f1:SetPoint("CENTER", 0, 0)
TT.f1:Show()

local ui
local y = -5

ui = TT.f1:AddText()
ui:SetText('blahblah')
ui:SetPoint('TOPLEFT', 5, y)
y = y - ui:GetHeight() - 5

ui = TT.f1:AddCheckBox()
ui:SetText("goooby")
ui:SetPoint('TOPLEFT', 5, y)
y = y - ui:GetHeight() - 5

ui = TT.f1:AddButton()
ui:SetText("blahblah")
ui:Resize()
ui:SetPoint('TOPLEFT', 5, y)
y = y - ui:GetHeight() - 5

if not TT.x then
TT.x = fLib.UI.EditBox.New(TT.f1)
end


TT.x:SetPoint('TOPLEFT', 5, y)
TT.x:SetWidth(100)

--TT.x.Label:SetText("blahbalhb")
--TT.x:SetHeight(TT.x.Label:GetHeight() + 6)


--]]


