fLib.GUI = {}

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
	button = fLib.GUI.CreateActionButton('Close', mw, 0, 0, mw.Toggle)
	button:ClearAllPoints()
	button:SetPoint('BOTTOMRIGHT', mw, 'BOTTOMRIGHT', -padding-8, padding+8)
	
	return mw, y
end

--y, TOP relative TOP
--returns a texture object
function fLib.GUI.CreateSeparator(parent, y)
	--Separator
	local tex = parent:CreateTexture(nil, 'OVERLAY')
	tex:SetPoint("TOP", parent, "TOP", 0, y)
	tex:SetWidth(parent:GetWidth() - 30)
	tex:SetHeight(1)
	tex:SetTexture(1,1,1,.2)
	return tex
end

--x,y TOPLEFT relative TOPLEFT
--returns a fontstring object
function fLib.GUI.CreateLabel(parent, x, y, text)
	local fs = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	fs:SetText(text)
	fs:SetPoint('TOPLEFT', x, y)
	fs:SetAlpha(.6)
	return fs
end

--x,y TOPLEFT relative TOPLEFT
--returns a checkbutton object
function fLib.GUI.CreateCheckButton(parent, x, y, text)
	local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetWidth(20);
    cb:SetHeight(22);
    cb:SetHitRectInsets(3,3,4,4);
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 10, y + 4);
	fs = cb:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	fs:SetText(text)
	fs:SetPoint('TOPLEFT', cb, 'TOPRIGHT', 0, -4)
	fs:SetAlpha(.6)
	return cb
end

--returns the button that gets created
--x,y point.  TOPLEFT of button relative to TOPLEFT of parent
--... are args for onclickhandler
function fLib.GUI.CreateActionButton(text, parent, x, y, onclickhandler, ...)
	local button = CreateFrame('button', nil, parent)
	button:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
	label = button:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	label:SetText(text)
	label:SetPoint('LEFT', 0,0)
	label:SetAlpha(.6)
	button:SetWidth(label:GetWidth())
	button:SetHeight(label:GetHeight())
	
	local highlight = button:CreateTexture(nil, "BACKGROUND")
	highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	button.highlight = highlight
	highlight:SetBlendMode("ADD")
	highlight:SetAllPoints(button)
	highlight:Hide()
	
	local args = {...}
	button:SetScript('OnClick', function() onclickhandler(unpack(args)) end)
	
	button:SetScript('OnEnter', function(this, ...)  this.highlight:Show() end)
	button:SetScript('OnLeave', function(this, ...)  this.highlight:Hide() end)
	
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
