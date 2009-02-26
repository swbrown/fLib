fLibGUI.Table = {}
local helper = {}
local private = {}

--returns a tableobj
--a tableobj is a frame with these properties
--  width
--  height
--  colcount
--  mincolwidth
--  headerheight
--  rowheight
--  separatorheight
--  rowcount - calculated
--  resizebuttonwidth
--  scrollbarwidth
function fLibGUI.Table.CreateTable(parentframe, width, height, colcount)
    local t = fLibGUI.CreateClearFrame(parentframe)
    
    --Properties
    t.width = width
    t.height = height
    
    t.colcount = colcount
    t.mincolwidth = 20
    
    t.headerheight = 12
    t.rowheight = 12
    t.separatorheight = 1
    
    --floor((height - headerheight - separator - bottompadding) / (rowheight + separator))
    t.rowcount = floor((t.height - t.headerheight - t.separatorheight - 4) / (t.rowheight + t.separatorheight))
    
    t.resizebuttonwidth = 4
    t.scrollbarwidth = 10
    
    t.startingindex = 1
    t.selectedindex = 0
    t.selectedcolnum = 1
    --t.count = 0
    
    --Frame setup
    t:SetPoint('TOPLEFT', 0, 0)
    t:SetWidth(t.width)
    t:SetHeight(t.height)
    
    --helper funcs add ui elements to my table
    helper.CreateColumns(t)
    helper.CreateRows(t)
    helper.CreateSeparators(t)
    helper.CreateCells(t)
    helper.CreateScrollBar(t)
    helper.SetUIPoints(t) --sets the points of all ui in t to the right places
    
    --list of func,args to be called
    t.headerclickactions = {}
    t.rowclickactions = {}
    t.scrollactions = {}
    
    t.AddHeaderClickAction = private.AddHeaderClickAction
    t.AddRowClickAction = private.AddRowClickAction
    t.AddScrollAction = private.AddScrollAction
    
    --needs to be called at least once right?
    --to set the column widths to the right sizes
    t:ResetColumnFramePoints()
    
    return t
end

--t.columns - list of column frames
--creates colcount column frames and stores them in t.columns
--adds a header button and a resize button to each column frame
function helper.CreateColumns(t)
    t.columns = {}
    
    local currentframe    
    for i = 1, t.colcount do
        --column frame
        currentframe = fLibGUI.CreateClearFrame(t)
        tinsert(t.columns, currentframe)
        
        currentframe.table = t        
        currentframe.enable = true
        
        currentframe:SetWidth(t.mincolwidth)
        currentframe:SetHeight(t.height)
        currentframe:SetResizable(true)
        currentframe:SetMinResize(t.mincolwidth, t.height)
        
        --header button
        ui = fLibGUI.CreateActionButton(currentframe)
        currentframe.headerbutton = ui
        
        ui.table = t
        ui.colnum = i
        
        ui:GetFontString():SetJustifyH('LEFT')
        ui:SetHeight(t.headerheight)
        ui:SetPoint('TOPLEFT', currentframe, 'TOPLEFT', 0, 0)
        ui:SetPoint('TOPRIGHT', currentframe, 'TOPRIGHT', -t.resizebuttonwidth, 0)
        ui:SetScript('OnClick', function()
            this.table.selectedcolnum = this.colnum
            --call extra actions
            for z = 1, #this.table.headerclickactions do
                this.table.headerclickactions[z][1](unpack(this.table.headerclickactions[z][2]))
            end
        end)            
        
        --resize button
        ui = fLibGUI.CreateActionButton(currentframe)
        currentframe.resizebutton = ui
        
        ui.table = t
        
        ui:GetFontString():SetJustifyH('LEFT')
        ui:SetWidth(t.resizebuttonwidth)
        ui:SetHeight(t.height)
        ui:SetPoint('TOPRIGHT', currentframe, 'TOPRIGHT', 0,0)
        ui:RegisterForDrag('LeftButton')
        
        ui:SetScript('OnDragStart', function(this, button)
            this:GetParent():StartSizing('RIGHT')
            this.highlight:Show()
        end)
        ui:SetScript('OnDragStop', function(this, button)
            this:GetParent():StopMovingOrSizing()
            this.highlight:Hide()
            this.table:ResetColumnFramePoints()
        end)
    end
    
    t.ResetColumnFramePoints = private.ResetColumnFramePoints
end



--t.rowbuttons - list of row buttons
--creates rowcount row buttons and stores them in t.rowbuttons
function helper.CreateRows(t)
    --rowbutton for each row
    t.rowbuttons = {}
    for i = 1, t.rowcount do
        --rowbutton
        ui = fLibGUI.CreateActionButton(t)
        tinsert(t.rowbuttons, ui)
        
        ui.table = t
        ui.index = 0
        
        ui:SetFrameLevel(5)
        ui:GetFontString():SetJustifyH('LEFT')
        ui:SetHeight(t.rowheight)
        ui:SetWidth(t.width)
        
        ui.highlightspecial = ui:CreateTexture(nil, "BACKGROUND")
        ui.highlightspecial:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        ui.highlightspecial:SetBlendMode("ADD")
        ui.highlightspecial:SetAllPoints(ui)
        ui.highlightspecial:Hide()
        
        ui:SetScript('OnClick', function()
            local t = this.table
            
            --unselect all the other rows
            for i = 1, t.rowcount do
            t.rowbuttons[i].highlightspecial:Hide()
            end
            
            --select this row
            this.highlightspecial:Show()
            t.selectedindex = this.index
            
            --call extra actions
            for z = 1, #t.rowclickactions do
            t.rowclickactions[z][1](unpack(t.rowclickactions[z][2]))
            end
            
            --[[
            --fill in details
            t:RefreshDetails()
            --]]
        end)
    end
end

--t.separators - list of separator frames
--creates rowcount separators frames and stores them in t.separators
function helper.CreateSeparators(t)
    t.separators = {}
    
    for i = 1, t.rowcount do
        --separator
        ui = fLibGUI.CreateSeparator(t)
        tinsert(t.separators, ui)
        ui:SetWidth(t.width)
    end
end

--creates colcount * rowcount cell fontstrings
--stores them in each column frame (currentframe.cells)    
function helper.CreateCells(t)
    local ui, currentframe
    for i = 1, t.colcount do
        currentframe = t.columns[i]
        currentframe.cells = {}
        for j = 1, t.rowcount do
            ui = fLibGUI.CreateLabel(currentframe)
            tinsert(currentframe.cells, ui)
            ui:SetJustifyH('LEFT')
        end
    end
end

--creates 1 scroll bar for t
function helper.CreateScrollBar(t)
    --Scroll bar
    ui = CreateFrame('slider', nil, t)
    t.slider = ui
    
    ui.table = t
    
    ui:SetFrameLevel(5)
    ui:SetOrientation('VERTICAL')
    ui:SetMinMaxValues(1, 1)
    ui:SetValueStep(1)
    ui:SetValue(1)
    
    ui:SetWidth(10)
    ui:SetHeight(t.height)
    
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
        this.table.startingindex = this:GetValue()
        --call extra actions
        for z = 1, #this.table.scrollactions do
            this.table.scrollactions[z][1](unpack(this.table.scrollactions[z][2]))
        end
        --this.table:LoadRows(this:GetValue())
    end)
    
    t:EnableMouseWheel(true)
    t:SetScript('OnMouseWheel', function(this,delta)
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
end

--attaches rowbuttons and separators to t
--attaches cells to column frames
function helper.SetUIPoints(t)
    local ui, currentframe
    local rowoffset = t.headerheight + t.separatorheight
    for i = 1, t.rowcount do
        t.rowbuttons[i]:SetPoint('TOPLEFT', t, 'TOPLEFT', 5, -6-rowoffset)
        --attach them on top of each rowbutton
        t.separators[i]:SetPoint('BOTTOMLEFT', t.rowbuttons[i], 'TOPLEFT', 0, 0)
        
        --cells
        for j = 1, t.colcount do
            currentframe = t.columns[j]
            ui = currentframe.cells[i]
            ui:SetPoint('TOPLEFT', currentframe, 'TOPLEFT', 5, -rowoffset)
            ui:SetPoint('TOPRIGHT', currentframe, 'TOPRIGHT', -5, -rowoffset)
        end
        
        --slider
        t.slider:SetPoint('TOPRIGHT', t, 'TOPRIGHT', -5, -5)
        
        rowoffset = rowoffset + t.rowheight + t.separatorheight
    end
end

function private.ResetColumnFramePoints(self)
    local t = self
    
    local enabledcolumns = {}
    for i = 1, #t.columns do
        if t.columns[i].enable then
            tinsert(enabledcolumns, i)
        end
    end
    
    local firstcolumndone = false
    local runningwidth = 0
    local currentcol, currentframe, prevframe, maxw, curw
    for i = 1, #enabledcolumns do
        currentcol = enabledcolumns[i]
        currentframe = t.columns[currentcol]
        if not firstcolumndone then
            currentframe:SetPoint('TOPLEFT', t, 'TOPLEFT', 5, -5)
            firstcolumndone = true
        else
            currentframe:SetPoint('TOPLEFT', prevframe, 'TOPRIGHT', 0,0)
        end
        
        --calculate allowed width, current width
        maxw = t.width - runningwidth - (t.mincolwidth * (#enabledcolumns - i))
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
        currentframe = t.columns[currentcol]
        currentframe:SetPoint('TOPRIGHT', t, 'TOPLEFT', t.width + 5, -5)
    end
end

function private.AddHeaderClickAction(self, f, ...)
    local t = self
    tinsert(t.headerclickactions, {f, {...}})
end

function private.AddRowClickAction(self, f, ...)
    local t = self
    tinsert(t.rowclickactions, {f, {...}})
end

function private.AddScrollAction(self, f, ...)
    local t = self
    tinsert(t.scrollactions, {f, {...}})
end