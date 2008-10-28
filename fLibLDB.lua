--http://github.com/tekkub/libdatabroker-1-1/tree/master
--LibStub
--LibDataBroker-1.1
--DewDrop-2.0
--LibDBIcon-1.0

if not LibStub then return end

local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then return end

local dew = AceLibrary("Dewdrop-2.0")
local icon = LibStub("LibDBIcon-1.0", true)

fLibLDB = ldb:NewDataObject("fLibLDB", {
	type = "data source",
	text = "0",
	icon = "Interface\\AddOns\\fLib\\Media\\pup",
	--minimapPos = fLib.db.global.minimap.minimapPos,
	--hide = fLib.db.global.minimap.hide
})


local function CreateDewMenu()
	local dewmenu = {
		config = {
			text = 'Config',
			func = function() fLib:OpenConfig() end,
		},
		minimap = {
			text = 'Show minimap icon',
			checked = not fLib.db.global.minimap.hide,
			func = function()
				fLib.db.global.minimap.hide = not fLib.db.global.minimap.hide
				if fLib.db.global.minimap.hide then
					icon:Hide(fLib.ICONNAME)
				else
					icon:Show(fLib.ICONNAME)
				end
			end,
		},
		debug = {
			text = 'Debug',
			checked = fLib.db.global.debug,
			func = function() fLib.db.global.debug = not fLib.db.global.debug end,
		},
	}
	return dewmenu
end


function fLibLDB.OnClick(self, button)
	if button == "RightButton" then
		dew:Open(self,
			"children", function()
				--dew:FeedAceOptionsTable(fDKP.options)
				--need to make fDKP.options Dew compatible by taking out input types i believe
				--or
				dew:FeedTable(CreateDewMenu())
			end
		)
	else
		if not IsModifierKeyDown() then
			--open fDKP gui
			--if fDKP then fDKP:OpenConfig() end
		elseif IsShiftKeyDown() then
			--ReloadUI()
			fList.GUI.Toggle()
		--elseif IsAltKeyDown() then
			--BugSack:Reset()
		elseif IsControlKeyDown() then
			--fDKP.GUI.dkplist.Toggle()
			fDKP.GUI.mainwindow.Toggle()
		--elseif BugSackFrame:IsShown() then
			--BugSackFrame:Hide()
		else
			--BugSack:ShowFrame("session")
			--fDKP:OpenConfig()
		end
	end
end

-- Invoked from fLib --not
function fLibLDB:Update()
	--local e = BugSack:GetErrors("session")
	--local count = e and #e or 0
	--self.text = count
	--self.icon = count == 0 and "Interface\\AddOns\\BugSack\\Media\\icon" or "Interface\\AddOns\\BugSack\\Media\\icon_red"
end

do
	--local pauseHint = L["|cffeda55fBugGrabber|r is paused due to an excessive amount of errors being generated. It will resume normal operations in |cffff0000%d|r seconds. |cffeda55fDouble-Click|r to resume now."]
	local hint = "|cffeda55fClick|r for fRaid.\n|cffeda55fShift-Click|r for fList.\n|cffeda55fCtrl-Click|r for fDKP."
	local line = "%d. %s (x%d)"
	function fLibLDB.OnTooltipShow(tt)
		--tt:AddLine("fAddons")
		--tt:AddLine(" ")
		tt:AddLine(hint, 0.2, 1, 0.2, 1)
	end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
	if icon then
		icon:Register(fLib.ICONNAME, fLibLDB, fLib.db.global.minimap)
	end
end)
f:RegisterEvent("PLAYER_LOGIN")