fLibTable = {}

function fLibTable.New(parent, colnum)
	local ftd = {}
	ftd.mainframe = CreateFrame('frame', nil, parent)
	ftd.columns = {} --list of cframes
	ftd.rows = {} -- (highlightbutton, items), items (list of ui elements)
	
	ftd.uibuttons = {}
	ftd.uichecks = {}
	ftd.uieditboxes = {}
	
	--indices pointing at the last used ui element in corresponding table
	ftd.uibuttons_idx = 0
	ftd.uichecks_idx = 0
	ftd.uieditboxes_idx = 0
	
	--create column frames
	local cframe
	for i = 1, colnum do
		cframe = CreateFrame('frame', nil, ftd.mainframe)
		if i == 1 then
			cframe:SetPoint('TOPLEFT', ftd.mainframe, 'TOPLEFT', 0, 0)
		else
			cframe:SetPoint('TOPLEFT', ftd.columns[i-1], 'TOPRIGHT', 0, 0)
		end
		ftd.columns[i] = cframe
	end
	
	--map functions
	for key, val in pairs(fLibTable) do
		if key ~= 'New' and type(val) == 'function' then
			ftd[key] = val
		end
	end
	
	return ftd
end

function fLibTable:Refresh()
	--reset mainframe
	self.mainframe:SetWidth(0)
	self.mainframe:SetHeight(0)
	
	--reset columns
	local cframe
	for i = 1, #self.columns do
		cframe = self.columns[i]
		cframe:SetWidth(0)
	end
	
	--reset rows
	self.rows = {}
	
	--reset uielements
	self.uibuttons_idx = 0
	self.uichecks_idx = 0
	self.uieditboxes_idx = 0
	
	--call childcreationhandler
	--child creation handler should add rows
	
	--hide extra ui elements
	local ui
	for i = self.uibuttons_idx + 1, #self.uibuttons do
		ui = self.uibuttons[i]
		ui:Hide()
	end
	
	for i = self.uichecks_idx + 1, #self.uichecks do
		ui = self.uichecks[i]
		ui:Hide()
	end
	
	for i = self.uieditboxes_idx + 1, #self.uieditboxes do
		ui = self.uieditboxes[i]
		ui:Hide()
	end
end

local function AcquireButton(self)
	self.uibuttons_idx = self.uibuttons_idx + 1
	local ui = self.uibuttons[self.uibuttons_idx]
	if not ui then
		--create it
		ui = CreateFrame('button', nil, nil)
		local fs = ui:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
		fs:SetPoint('LEFT', 0, 0)
		fs:SetAlpha(.6)
		ui:SetFontString(fs)
		self.uibuttons[self.uibuttons_idx] = ui
	end
	return ui
end
local function AcquireCheck(self)
	self.uichecks_idx = self.uichecks_idx + 1
	local ui = self.uichecks[self.uichecks_idx]
	if not ui then
		--create it
		ui = CreateFrame('button', nil, nil)
		local check = ui:CreateTexture(nil, "ARTWORK")
		check:SetPoint("TOPLEFT", ui, "TOPLEFT")
		button:SetHeight(20)
		button:SetWidth(20)
		check:SetHeight(20)
		check:SetWidth(20)
		check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
		self.uichecks_idx[self.uichecks_idx] = ui
	end
	return ui
end
local function AcquireEditBox(self)
	self.uieditboxes_idx = self.uieditboxes_idx + 1
	local ui = self.uieditboxes[self.uieditboxes_idx]
	if not ui then
		--create it
		
	end
	return ui
end

function fLibTable:AddRow(items)
	--items should have #columns items in it, extra items are ignored
	--each item is a table with the info (type, data, func)
	--type can be button, check, or editbox
	--button data is the text for the label of the button
	--check data is true or false for whether it is checked or not
	--editbox data is the text for the contents of the editbox
	--button func is the function to call when the button is clicked
	--check func not available
	--editbox func is the function to call when you press enter with the edit box in focus
	
	local item, ui
	for i = 1, #self.columns do
		item = items[i]
		if item.type == 'check' then
		elseif item.type == 'editbox' then
		else --default to a button
		end
	end
end