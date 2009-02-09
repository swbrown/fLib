fLibGUI.Table = {}

--[[

sample headerdata object
local headerdata = {
	{'Name', 275, 'prop2'},
	{'MinDkp', 50, 'prop4'},
	{'headertext', 8, 'propertyname'}
}

sample SourceList
local SorceList = {
	{
		prop1 = 'blahblah',
		prop2 = 234,
		prop3 = 'fsomethin',
		prop4 = {3, 4, 5}
	},
	{
		prop1 = 'blahblother',
		prop2 = 435,
		prop3 = 'ugue',
		prop4 = {4, 4, 3}
	}, 
	etc...
}


--]]

function fLibGUI.Table.New(parent, source, headerdata, rowcount, width)
	local mf = fLibGUI.CreateClearFrame(parent)
	
	mf.Source = source
	mf.headerdata = headerdata
	
	mf.rowheight = 12
	mf.rowcount = rowcount --availablerows
	
	mf.mincolwidth = 20
	--#rows times height of each row plus 1 for each separator plus header row
	mf.mincolheight = mf.rowheight * mf.rowcount + mf.rowcount + mf.rowheight
	mf.colcount = #headerdata
	
	mf:SetWidth(width)
	mf:setHeight(mf.colheight)
	
	mf.maxwidth = width - 25
	
	--a list of idx's that can be sorted
	mf.RowIndexList = {} --maps row number to index to access whatever list this table is supposed to display
	mf.startingrownum = 1
	mf.selectedrownum = 0 --selectedindexnum
	mf.realrowcount = 0 --previtemlistcount
	
	local ui, prevui
	
	------------------
	--UI Elements-----
	------------------
	mf.columnframes = {} --1 columnframe for each column
	local currentframe
	for i = 1, mf.colcount do
		--columnframe
		currentframe = fLibGUI.CreateClearFrame(mf)
		tinsert(mf.columnframes, currentframe)
		
		currentframe.enable = true
		currentframe:SetHeight(mf.mincolheight)
		currentframe:SetResizable(true)
		currentframe:SetMinResize(mf.mincolwidth, mf.mincolheight)
		
		--headerbutton
		ui = fLibGUI.CreateActionButton(currentframe)
		currentframe.headerbutton = ui
		ui.colnum = i
		ui:GetFontString():SetJustifyH('LEFT')
		ui:SetHeight(mf.rowheight)
		ui:SetPoint('TOPLEFT', currentframe, 'TOPLEFT', 0, 0)
		ui:SetPoint('TOPRIGHT', currentframe, 'TOPRIGHT', -4, 0)
		--ui:SetText('test')
		
		ui:SetScript('OnClick', function()
			mf:Sort(this.colnum)
			mf:LoadRows()
		end)
		
		--resizebutton
		ui = fLibGUI.CreateActionButton(currentframe)
		currentframe.resizebutton = ui
		ui:GetFontString():SetJustifyH('LEFT')
		ui:SetWidth(4)
		ui:SetHeight(mf.mincolheight)
		ui:SetPoint('TOPRIGHT', currentframe, 'TOPRIGHT', 0,0)
		ui:RegisterForDrag('LeftButton')
		
		ui:SetScript('OnDragStart', function(this, button)
			this:GetParent():StartSizing('RIGHT')
			this.highlight:Show()
		end)
		ui:SetScript('OnDragStop', function(this, button)
			this:GetParent():StopMovingOrSizing()
			this.highlight:Hide()
			--mf:ResetColumnFramePoints()
			this:GetParent():GetParent():ResetColumnFramePoints()
		end)
		
		--cells
		currentframe.cells = {}
		for j = 1, mf.rowcount do
			ui = fLibGUI.CreateLabel(currentframe)
			tinsert(currentframe.cells, ui)
			ui:SetJustifyH('LEFT')
		end
	end
	
	--setup header text and column widths
	for i = 1, mf.colcount do
		if headerdata[i] then
			mf.columnframes[i].headerbutton:SetText(headerdata[i][1])
			mf.columnframes[i]:SetWidth(headerdata[i][2])
		else
			--mf.columnframes[i].headerbutton:SetText('blank')
			mf.columnframes[i]:SetWidth(mf.mincolwidth)
		end
	end
	
	--rowbutton for each row
	mf.rowbuttons = {}
	local rowoffset = 0
	for i = 1, mf.rowcount do
		--rowheight * number of rows + 1 for each row separator
		rowoffset = mf.rowheight * i + i
		
		--separator
		ui = fLibGUI.CreateSeparator(mf)
		ui:SetPoint('TOPLEFT', mf, 'TOPLEFT', 5,-6 - rowoffset)
		ui:SetWidth(mf.width)
		
		--rowbutton
		ui = fLibGUI.CreateActionButton(mf)
		tinsert(mf.rowbuttons, ui)
		
		ui.realrownum = 0
		
		ui:SetFrameLevel(4)
		ui:GetFontString():SetJustifyH('LEFT')
		ui:SetHeight(mf.rowheight)
		ui:SetWidth(mf.maxwidth)
		ui:SetPoint('TOPLEFT', mf, 'TOPLEFT', 5, -6-rowoffset)
		
		ui.highlightspecial = ui:CreateTexture(nil, "BACKGROUND")
		ui.highlightspecial:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		ui.highlightspecial:SetBlendMode("ADD")
		ui.highlightspecial:SetAllPoints(ui)
		ui.highlightspecial:Hide()
		
		ui:SetScript('OnClick', function()
			--unselect all the other rows
			for i = 1, mf.rowcount do
				mf.rowbuttons[i].highlightspecial:Hide()
			end
			
			--select this row
			this.highlightspecial:Show()
			mf.selectedrownum = this.realrownum
			
			--fill in details
			mf:RefreshDetails()
		end)
			
		ui:SetScript('OnEnter', function()
			this.highlight:Show()
			GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			GameTooltip:SetPoint('LEFT', mf, 'RIGHT', 0, 0)
			local idx, obj = mf:SelectedData(this.realrownum)
			if obj then
				GameTooltip:SetHyperlink('item:'..obj.id)
			end
		end)
		ui:SetScript('OnLeave', function()
			this.highlight:Hide()
			GameTooltip:FadeOut()
		end)
					
		--cell location for each cell in currentrow
		for j = 1, #mf.columnframes do
			currentframe = mf.columnframes[j]
			ui = currentframe.cells[i]
			ui:SetPoint('TOPLEFT', currentframe, 'TOPLEFT', 5, -rowoffset)
			ui:SetPoint('TOPRIGHT', currentframe, 'TOPRIGHT', -5, -rowoffset)
		end
	end
	
	--Scroll bar
	ui = CreateFrame('slider', nil, mf)
	mf.slider = ui
	ui:SetFrameLevel(5)
	ui:SetOrientation('VERTICAL')
	ui:SetMinMaxValues(1, 1)
	ui:SetValueStep(1)
	ui:SetValue(1)
	
	ui:SetWidth(10)
	ui:SetHeight(mf.mincolheight + mf.rowheight)
	
	ui:SetPoint('TOPRIGHT', mf, 'TOPRIGHT', -5, -5)
	
	ui:SetThumbTexture('Interface/Buttons/UI-SliderBar-Button-Horizontal')
	ui:SetBackdrop({
		bgFile='Interface/Buttons/UI-SliderBar-Background',
		edgeFile = 'Interface/Buttons/UI-SliderBar-Border',
		tile = true,
		tileSize = 8,
		edgeSize = 8,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
		--insets are for the bgFile
	})
	
	ui:SetScript('OnValueChanged', function()
		mf:LoadRows(this:GetValue())
	end)
	
	mf:EnableMouseWheel(true)
	mf:SetScript('OnMouseWheel', function(this,delta)
		local current = this.slider:GetValue()
		local min,max = this.slider:GetMinMaxValues()
		if delta < 0 then
			current = current + 3
			if current > max then
				current = max
			end
			this.slider:SetValue(current)
		elseif delta > 0 then
			current = current - 3
			if current < min then
				current = min
			end
			this.slider:SetValue(current)
		end
	end)
	
	----------------------------------
	--Functions-----------------------
	----------------------------------
	
	--function for resizing columns
	function mf:ResetColumnFramePoints()
		local enabledcolumns = {}
		for i = 1, #mf.columnframes do
			if mf.columnframes[i].enable then
				tinsert(enabledcolumns, i)
			end
		end
		
		local firstcolumndone = false
		local runningwidth = 0
		local currentcol, currentframe, prevframe, maxw, curw
		for i = 1, #enabledcolumns do
			currentcol = enabledcolumns[i]
			currentframe = mf.columnframes[currentcol]
			
			if not firstcolumndone then
				currentframe:SetPoint('TOPLEFT', mf, 'TOPLEFT', 5, -5)
				firstcolumndone = true
			else
				currentframe:SetPoint('TOPLEFT', prevframe, 'TOPRIGHT', 0,0)
			end
			
			--calculate allowed width, current width
			maxw = mf.maxwidth - runningwidth - (mf.mincolwidth * (#enabledcolumns - i))
			curw = currentframe:GetRight() - currentframe:GetLeft()
			--check if its larger than allowed width
			if curw > maxw then
				currentframe:SetWidth(maxw)	
			end
			runningwidth = runningwidth + currentframe:GetWidth()
			
			prevframe = currentframe
		end
		
		if #enabledcolumns > 0 then
			currentcol = enabledcolumns[#enabledcolumns]
			currentframe = mf.columnframes[currentcol]
			currentframe:SetPoint('TOPRIGHT', mf, 'TOPLEFT', mf.maxwidth + 5, -5)
		end
	end
	
	function mf:SelectedData(realrownum)
		if not realrownum or realrownum < 1 then
			realrownum = this.selectedrownum
		end
		
		local idx, obj
		idx = this.RowIndexList[realrownum]
		obj = this.Source.GetObjectByIndex(idx)
		return idx, obj
	end
	
	--mf.RowIndexList maps row number to Source index
	function mf:RefreshRowIndexList()
		if this.realrowcount ~= this.Source.GetCount() then
			this.realrowcount = this.Source.GetCount()
			wipe(this.RowIndexList)
			--copy the SourceListIndex
			for _, itemidx in pairs(this.Source.GetIndex()) do
				tinsert(this.RowIndexList, itemidx)
			end
			
			local max = #this.RowIndexList - this.rowcount + 1
			if max < 1 then max = 1 end
			this.slider:SetMinMaxValues(1, max)
			this:Sort()
			
			this.title_total:SetText(this.Source.GetCount())
		end
	end

	function mf:LoadRows(startingrownum)
		if startingrownum then
			this.startingrownum = startingrownum
		end
			
		local idx, obj
		local realrownum = this.startingrownum
		
		local searchmatch = false
		local searchnum, searchname
		searchnum = tonumber(this.search)
		searchname = strlower(this.search)
		
		local selectedrowfound = false
			
		for i = 1, mf.rowcount do
			--search************************
			searchmatch = false
			while not searchmatch do
				idx, obj = this:SelectedData(realrownum)
				if this.search == '' or not obj then
					searchmatch = true
				else
					if obj.mindkp == searchnum or obj.rarity == searchnum or obj.id == searchnum then
						searchmatch = true
					elseif strfind(strlower(obj.name), searchname, 1, true) then
						searchmatch = true
					else
						realrownum = realrownum + 1
					end
				end
			end
			
			if not obj then
				for ci = 1, mf.colcount do
					mf.columnframes[ci].cells[i]:SetText('')
				end
				mf.rowbuttons[i]:Hide()
				mf.rowbuttons[i].realrownum = 0
			else
				--fill in the cells with stuff***********************************
				for ci = 1, mf.colcount do
					this.columnframes[ci].cells[i]:SetText(this.headerdata[ci][3])
				end
				mf.rowbuttons[i]:Show()
				mf.rowbuttons[i].realrownum = realrownum
		
				if realrownum == mf.selectedrownum then
					mf.rowbuttons[i].highlightspecial:Show()
					selectedrowfound = true
				else
					mf.rowbuttons[i].highlightspecial:Hide()
				end
			end
			realrownum = realrownum + 1
		end
		
		--unselect the row if it gets scrolled off screen
		if not selectedrowfound then
			mf.selectedrownum = 0
			mf:RefreshDetails()
		end
	end
	
	--REFRESH
	function mf:Refresh()
		mf:RefreshRowIndexList()
		mf:LoadRows()
	end
	
	--called when clicked on a row
	--may be called by Refresh
	function mf:RefreshDetails()
		local itemnum, itemobj = mf:SelectedData()
		if itemobj then
			mf.title_name:SetText(itemobj.name)
			mf.title_id:SetText(itemobj.id)
			mf.eb_mindkp:SetNumber(itemobj.mindkp)
		else
			mf.title_name:SetText('')
			mf.title_id:SetText('')
			mf.eb_mindkp:SetNumber(0)
		end
	end

	--a and b are indexes for ItemList
	--dosort is the column that is getting sorted, only one can be true
	mf.sortkeeper = {
		{asc = false, dosort = false},
		{asc = false, dosort = false},
		{asc = false, dosort = false},
		--{asc = false, issorted = false}
	}
	function mf.lootcomparer(a, b)
		if a== nil or b == nil then
			return true
		end

		if a < 1 or b < 1 then
			return true
		end
		
		--retrieving itemobj
		local aobj = fRaid.Item.GetObjectByIndex(a)--fRaid.db.global.ItemList[a]
		local bobj = fRaid.Item.GetObjectByIndex(b)--fRaid.db.global.ItemList[b]

		local SORT = 1
		local SORT_ASC = false
		for idx,keeper in ipairs(mf.sortkeeper) do
			if keeper.dosort then
				SORT = idx
				SORT_ASC = keeper.asc
			end
		end

		local ret = true
		if SORT == 3 then
			if aobj.rarity == bobj.rarity then
				SORT_ASC = mf.sortkeeper[1].asc
				ret = aobj.name < bobj.name
			else
				ret = aobj.rarity < bobj.rarity
			end
		elseif SORT == 2 then
			if aobj.mindkp == bobj.mindkp then
				if aobj.name == bobj.name then
					SORT_ASC = mf.sortkeeper[3].asc
					ret = aobj.rarity < bobj.rarity
				else
					SORT_ASC = mf.sortkeeper[1].asc
					ret = aobj.name < bobj.name
				end
			else
				ret = aobj.mindkp > bobj.mindkp
			end
		else
			if aobj.name == bobj.name then
				SORT_ASC = mf.sortkeeper[3].asc
				ret = aobj.rarity < bobj.rarity
			else
				ret = aobj.name < bobj.name
			end
			--[[
			if aobj.rarity == bobj.rarity then
			ret = aobj.name > bobj.name
			else
			SORT_ASC = mf.sortkeeper[3].asc
			ret = aobj.rarity > bobj.rarity
			end
			--]]
		end
		
		if SORT_ASC then
			return ret
		else
			return not ret
		end
	end

	function mf:Sort(colnum)
		if colnum then
			mf.sortkeeper[colnum].asc = not mf.sortkeeper[colnum].asc
			
			if not mf.sortkeeper[colnum].issorted then
				for idx,keeper in ipairs(mf.sortkeeper) do
					keeper.dosort = false
				end
				mf.sortkeeper[colnum].dosort = true
			end
		end
		
		table.sort(fRaid.GUI2.ItemFrame.ListIndex, mf.lootcomparer)
	end
	
	mf:ResetColumnFramePoints()
end

