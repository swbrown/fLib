fLib.GUI = {}

--returns a pretty draggable frame that you need to
--position, size, add scripts yourself
--if you provide a name, the window is closable with escape
function fLib.GUI.CreateEmptyFrame(look, name, otherparent)
	local mw
	if otherparent then
		mw = CreateFrame('frame', name, otherparent)
	else
		mw = CreateFrame('frame', name, UIParent)
	end
	mw:Hide()
	mw:SetClampedToScreen(true)
	mw:SetMovable(true)
	mw:EnableMouse(true)
	mw:RegisterForDrag('LeftButton')
	--mw:SetResizable(true)
	
	--[[
	local b = CreateFrame('button', nil, mw)
	mw.ResizeCornerButton = b
	b:SetPoint('BOTTOMRIGHT', -3, 3)
	b:SetWidth(16)
	b:SetHeight(16)
	b:SetScript('OnMouseDown', function() this:GetParent():StartSizing() end)
	--b:SetScript('OnLoad', function() this:GetNormalTexture():SetVertexColor(.6, .6, .6) end)
	b:SetScript('OnMouseUp', function() this:GetParent():StopMovingOrSizing() end)
	b:SetNormalTexture('Interface/AddOns/WowLua/images/resize')
	--]]
	
	--Some functions for mainwindow		
	function mw:Toggle()
		if self:IsVisible() then
			self:Hide()
		else
			self:Show()
		end
	end
	
	--Scripts for mainwindow
	if name and name ~= '' then
		mw:SetScript('OnShow', function()
			tinsert(UISpecialFrames,this:GetName())
		end)
	end	
	mw:SetScript('OnDragStart', function(this, button)
		this:StartMoving()
	end)
	mw:SetScript('OnDragStop', function(this, button)
		this:StopMovingOrSizing()
	end)
	
	--Look
	if not look then
		look = 1
	end
	if look == 1 then
		mw:SetBackdrop({
			bgFile='Interface/Tooltips/ChatBubble-Background',
			edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
			tile = false,
			tileSize = 0,
			edgeSize = 16,
			insets = {left = 4, right = 4, top = 4, bottom = 4}
			--insets are for the bgFile
		})
		mw:SetBackdropBorderColor(0.6, 0.6, 0.6)
	elseif look == 2 then
		mw:SetBackdrop({
			edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
			edgeSize = 16,
		})
		mw:SetBackdropBorderColor(0.6, 0.6, 0.6)
		
		bg = mw:CreateTexture(nil, 'BACKGROUND')
		bg:SetTexture("Interface/ChatFrame/ChatFrameBackground")
		bg:SetPoint('TOPLEFT', 4, -4)
		bg:SetPoint('BOTTOMRIGHT', -4, 4)
		bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.9, 0.2, 0.2, 0.2, 0.9)
	end
	
	return mw
end

--returns an empty clear frame, not draggable
function fLib.GUI.CreateClearFrame(parent)
	local mw = CreateFrame('frame', nil, parent)
	mw:SetClampedToScreen(true)
	mw:EnableMouse(true)

	--Look
	mw:SetBackdrop({
		--bgFile='Interface/Tooltips/ChatBubble-Background',
		edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
		tile = false,
		tileSize = 0,
		edgeSize = 2,
	})
	mw:SetBackdropBorderColor(0.2, 0.2, 0.2)
	
	return mw
end


function fLib.GUI.CreateSeparator(parent)
	--Separator
	local tex = parent:CreateTexture(nil, 'OVERLAY')
	tex:SetHeight(1)
	tex:SetTexture(1,1,1,.2)
	return tex
end

--returns a blank fontstring
function fLib.GUI.CreateLabel(parent)
	local fs = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	fs:SetAlpha(.6)
	return fs
end

--returns a blank checkbutton object
function fLib.GUI.CreateCheckButton(parent)
	local cb = CreateFrame('CheckButton', nil, parent, 'UICheckButtonTemplate')
	cb:SetWidth(24)
    cb:SetHeight(24)
    cb:SetHitRectInsets(3,3,4,4)
    local fs = cb:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    cb:SetFontString(fs)
    fs:SetPoint('LEFT', cb, 'RIGHT', 0, 0)
    fs:SetAlpha(.6)
    return cb
end

--returns a blank action button that highlights when hovered over
function fLib.GUI.CreateActionButton(parent)
	local b = CreateFrame('button', nil, parent)
	local fs = b:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	b:SetFontString(fs)
	fs:SetPoint('LEFT', 0,0)
	fs:SetAlpha(.6)
	
	local highlight = b:CreateTexture(nil, "BACKGROUND")
	highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	b.highlight = highlight
	highlight:SetBlendMode("ADD")
	highlight:SetAllPoints(b)
	highlight:Hide()
	
	b:SetScript('OnEnter', function(this, ...)  this.highlight:Show() end)
	b:SetScript('OnLeave', function(this, ...)  this.highlight:Hide() end)
	
	return b
end

--returns the button that gets created
--x,y point.  TOPLEFT relative to TOPLEFT
--function fLib.GUI.CreateCheck(parent, x, y)
function fLib.GUI.CreateCheck(parent)
	local button = CreateFrame('button', nil, parent)
	--button:SetFrameLevel(12)
	--button.indentation = 0
	local check = button:CreateTexture(nil, "ARTWORK")
	--local col1 = newstring(button)
	--testString = col1
	--local highlight = button:CreateTexture(nil, "BACKGROUND")
	--highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	--button.highlight = highlight
	--highlight:SetBlendMode("ADD")
	--highlight:SetAllPoints(button)
	--highlight:Hide()
	--self.buttons[#self.buttons+1] = button
	--button.check = check
	--button.col1 = col1
	--col1:SetWidth(0)
	--if self.maxLines == 1 then
	--	col1:SetFontObject(GameTooltipHeaderText)
	--	col1:SetJustifyH("CENTER")
	--	button:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT", 3, -5)
	--else
	--	col1:SetFontObject(GameTooltipText)
	--	button:SetPoint("TOPLEFT", self.buttons[self.maxLines - 1], "BOTTOMLEFT", 0, -2)
	--end
	--button:SetScript("OnEnter", button_OnEnter)
	--button:SetScript("OnLeave", button_OnLeave)
	--button.check = check
	--button.self = self
	--button:SetPoint("RIGHT", self.scrollFrame, "RIGHT", -7, 0)
	--!--button:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
	--check.shown = false
	check:SetPoint("TOPLEFT", button, "TOPLEFT")
	--col1:SetPoint("TOPLEFT", check, "TOPLEFT")
	--local size = select(2,GameTooltipText:GetFont())
	--check:SetHeight(size * 1.5)
	--check:SetWidth(size * 1.5)
	button:SetHeight(20)
	button:SetWidth(20)
	check:SetHeight(20)
	check:SetWidth(20)
	check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	--check:SetAlpha(0)
	--if not button.clicked then
	--	button:SetScript("OnMouseWheel", self:GetScript("OnMouseWheel"))
	--	button:EnableMouseWheel(true)
	--	button:Hide()
	--end
	--check:Show()
	--col1:Hide()
	return button
end

--returns an editbox with the width not set
--text is the transparent label in the edit box
function fLib.GUI.CreateEditBox(parent, text)
	local eb = CreateFrame('editbox', nil, parent)
	
	eb:SetFontObject(GameFontHighlight) --required to let you type in it
	eb:SetTextInsets(6,6,0,0)
	eb:SetAutoFocus(false) --required to let you escape focus on the editbox
	
	eb:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
	eb:SetBackdropBorderColor(0.6, 0.6, 0.6)
	
	local bg = eb:CreateTexture(nil, "BACKGROUND")
	bg:SetTexture("Interface/ChatFrame/ChatFrameBackground")
	bg:SetPoint("TOPLEFT", 1, -1)
	bg:SetPoint("BOTTOMRIGHT", -1, 1)
	bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.9, 0.2, 0.2, 0.2, 0.9)
	
	
	local label = eb:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	eb.label = label
	label:SetAlpha(0.2)
	label:SetText(text)
	label:SetPoint('LEFT', 6, 0)
	label:Show()
	
	eb:SetHeight(label:GetHeight() + 6)
	
	eb:SetScript('OnEnterPressed', function() this:ClearFocus() end)
	eb:SetScript('OnEscapePressed', function() this:ClearFocus() end)
	eb:SetScript('OnEditFocusGained', function() this:HighlightText() end)
	eb:SetScript('OnEditFocusLost', function() this:HighlightText(0,0) end)	
	return eb
end

function fLib.GUI.CreateEditBox2(parent, text)
	local eb = CreateFrame('editbox', nil, parent)
	
	eb:SetFontObject(GameFontHighlightSmallLeft) --required to let you type in it
	eb:SetTextInsets(5,5,0,0)
	eb:SetAutoFocus(false) --required to let you escape focus on the editbox
	
	--eb:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 1})
	--eb:SetBackdropBorderColor(0.6, 0.6, 0.6)
	
	--local bg = eb:CreateTexture(nil, "BACKGROUND")
	--bg:SetTexture("Interface/ChatFrame/ChatFrameBackground")
	--bg:SetPoint("TOPLEFT", 1, -1)
	--bg:SetPoint("BOTTOMRIGHT", -1, 1)
	--bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.9, 0.2, 0.2, 0.2, 0.9)
	
	
	local label = eb:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
	eb.label = label
	label:SetAlpha(0.1)
	label:SetText(text)
	label:SetPoint('LEFT', 5, 0)
	label:Show()
	
	eb:SetHeight(label:GetHeight() + 4)
	
	eb:SetScript('OnEnterPressed', function() this:ClearFocus() end)
	eb:SetScript('OnEscapePressed', function() this:ClearFocus() end)
	eb:SetScript('OnEditFocusGained', function() this:HighlightText() end)
	eb:SetScript('OnEditFocusLost', function() this:HighlightText(0,0) end)	
	return eb
end