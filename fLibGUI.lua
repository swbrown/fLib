fLib.GUI = {}

--returns a draggable empty frame
function fLib.GUI.CreateMainWindowEx()
	--Main Window
	local mw = CreateFrame('frame', nil, UIParent)
	mw:Hide()
	mw:SetClampedToScreen(true)
	mw:SetMovable(true)
	mw:EnableMouse(true)
	mw:RegisterForDrag('LeftButton')
	
	--Some functions for mainwindow
	mw.closers = {}
	function mw.AddCloser(func)
		tinsert(mw.closers, func)
	end
	
	function mw.Toggle()
		if mw:IsVisible() then
			mw:Hide()
			--if type(closehandler) == 'function' then
			--	closehandler()
			--end
			for idx,func in ipairs(mw.closers) do
				func()
			end
		else
			mw:Show()
		end
	end
	
	--Scripts for mainwindow
	mw:SetScript('OnDragStart', function(this, button)
		this:StartMoving()
	end)
	mw:SetScript('OnDragStop', function(this, button)
		this:StopMovingOrSizing()
		--save new coords
		if type(savecoordshandler) == 'function' then
			savecoordshandler(mw)
		end
	end)
	
	mw:SetBackdrop({
		edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
		edgeSize = 16,
		insets = {left = 2, right = 2, top = 2, bottom = 2}
	})
	mw:SetBackdropBorderColor(0.6, 0.6, 0.6)
	
	bg = mw:CreateTexture(nil, 'BACKGROUND')
	bg:SetTexture("Interface/ChatFrame/ChatFrameBackground")
	bg:SetPoint('TOPLEFT', 4, -4)
	bg:SetPoint('BOTTOMRIGHT', -4, 4)
	bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.9, 0.2, 0.2, 0.2, 0.9)
	
	--Title of main window
	fs = mw:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	fs:SetText(title)
	fs:SetPoint('TOP', 0, -y)
	fs:SetAlpha(.6)
	
	--Close Button
	button = fLib.GUI.CreateActionButton(mw)
	mw.closebutton = button
	button:SetText('Close')
	button:SetWidth(button:GetTextWidth())
	button:SetHeight(button:GetTextHeight())
	button:SetScript('OnClick', function() mw.Toggle() end)
	button:SetPoint('BOTTOMRIGHT', mw, 'BOTTOMRIGHT', -padding-8, padding+8)
	
	return mw
end


--title of the window
--gx,gy point TOPLEFT relative TOPLEFT
--padding between elements
--savecoordshandler will be called ondragstop, and will receive one arg, the frame being created
--closehandler will be called Toggle, when hiding the frame
--returns frame, y
--y is a positive number, indicating the distance from the top of the frame
--where you can start putting stuff below the title
function fLib.GUI.CreateMainWindow(title, gx, gy, width, height, padding, savecoordshandler, closehandler)
	local x = padding
	local y = padding
	local bg, fs, button
	
	--Main Window
	local mw = CreateFrame('frame', nil, UIParent)
	mw:Hide()
	mw:SetWidth(width)
	mw:SetHeight(height)
	mw:SetClampedToScreen(true)
	mw:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', gx,gy)
	mw:SetMovable(true)
	mw:EnableMouse(true)
	mw:RegisterForDrag('LeftButton')
	
	--Some functions for mainwindow
	function mw.Toggle()
		if mw:IsVisible() then
			mw:Hide()
			if type(closehandler) == 'function' then
				closehandler()
			end
		else
			mw:Show()
		end
	end
	
	--Scripts for mainwindow
	mw:SetScript('OnDragStart', function(this, button)
		this:StartMoving()
	end)
	mw:SetScript('OnDragStop', function(this, button)
		this:StopMovingOrSizing()
		--save new coords
		if type(savecoordshandler) == 'function' then
			savecoordshandler(mw)
		end
	end)
	
	mw:SetBackdrop({
		edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
		edgeSize = 16,
		insets = {left = 2, right = 2, top = 2, bottom = 2}
	})
	mw:SetBackdropBorderColor(0.6, 0.6, 0.6)
	
	bg = mw:CreateTexture(nil, 'BACKGROUND')
	bg:SetTexture("Interface/ChatFrame/ChatFrameBackground")
	bg:SetPoint('TOPLEFT', 4, -4)
	bg:SetPoint('BOTTOMRIGHT', -4, 4)
	bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.9, 0.2, 0.2, 0.2, 0.9)
	
	--Title of main window
	fs = mw:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	fs:SetText(title)
	fs:SetPoint('TOP', 0, -y)
	fs:SetAlpha(.6)
	y = y + fs:GetHeight() + padding
	
	--Close Button
	--button = fLib.GUI.CreateActionButton('Close', mw, 0, 0, mw.Toggle)
	button = fLib.GUI.CreateActionButton(mw)
	button:SetText('Close')
	button:SetWidth(button:GetTextWidth())
	button:SetHeight(button:GetTextHeight())
	button:SetScript('OnClick', function() mw.Toggle() end)
	button:SetPoint('BOTTOMRIGHT', mw, 'BOTTOMRIGHT', -padding-8, padding+8)
	
	return mw, y
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
function fLib.GUI.CreateCheck(parent, x, y)
	local button = CreateFrame("button", nil, parent)
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
	button:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
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

--returns the editbox that gets greated
--text is the transparent label in the edit box
function fLib.GUI.CreateEditBox(text, parent, x, y, width, height)
	local eb = CreateFrame('editbox', nil, parent)
	eb:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
	eb:SetWidth(width)
	eb:SetHeight(height)
	
	eb:SetFontObject(ChatFontNormal) --required to let you type in it
	eb:SetTextInsets(8,8,0,0)
	eb:SetAutoFocus(false) --required to let you escape focus on the editbox
	
	eb:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = {left = 2, right = 2, top = 2, bottom = 2}})
	eb:SetBackdropBorderColor(0.6, 0.6, 0.6)
	
	local bg = eb:CreateTexture(nil, "BACKGROUND")
	bg:SetTexture("Interface/ChatFrame/ChatFrameBackground")
	bg:SetPoint("TOPLEFT", 4, -4)
	bg:SetPoint("BOTTOMRIGHT", -4, 4)
	bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.9, 0.2, 0.2, 0.2, 0.9)
	
	local label = eb:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	label:SetAlpha(0.2)
	label:SetText(text)
	label:SetPoint("TOPLEFT", 8, 0)
	label:SetPoint("BOTTOMLEFT", -8, 0)
	label:Show()
	
	eb:SetScript('OnEnterPressed', function() this:ClearFocus() end)
	eb:SetScript('OnEscapePressed', function() this:ClearFocus() end)
	eb:SetScript('OnEditFocusGained', function() this:HighlightText() end)
	eb:SetScript('OnEditFocusLost', function() this:HighlightText(0,0) end)
	
	
	
		--editBox:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	--editBox:SetScript("OnEscapePressed", function() this:SetText(""); this:ClearFocus(); fDKPSearch_Label:Show() end)
	--editBox:SetScript("OnEditFocusGained", function() if IsControlKeyDown() then this:SetText(""); this:ClearFocus(); fDKPSearch_Label:Show() else fDKPSearch_Label:Hide(); this:HighlightText() end end)
	--editBox:SetScript("OnTextChanged", function() fDKPSearch:Search(this:GetText()) end)
	
	return eb
end
