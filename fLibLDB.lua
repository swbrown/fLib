--http://github.com/tekkub/libdatabroker-1-1/tree/master

if not LibStub then return end

local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then return end

local dew = AceLibrary("Dewdrop-2.0")
local icon = LibStub("LibDBIcon-1.0", true)

fLibLDB = ldb:NewDataObject("fLibLDB", {
	type = "data source",
	text = "0",
	icon = "Interface\\AddOns\\fLib\\Media\\pup",
})


local function CreateDewMenu()
	local dewmenu = {}
	
	if fList then
		dewmenu.fList = {
	        text = "fList",
	        func = function() if fList then fList:OpenConfig() end end,
	        hasArrow = true,
	        subMenu = {
	            Apple = {
	                text = "A juicy apple",
	                func = function()
	                	fLib:Print("You clicked a juicy apple")
	                	fListTablet:ShowGUI()
	                end,
	            },
	            Strawberry = {
	                text = "A tasty strawberry", 
	                func = function()
	                	fLib:Print("You clicked a tasty strawberry")
	                	fListTablet:HideGUI()
	                end,
	            },
	        }
	     }
	end
	
	if fDKP then
		dewmenu.fDKP = {
	        text = "fDKP",
	        func = function() if fDKP then fDKP:OpenConfig() end end,
	    }
	end
	
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
		if IsShiftKeyDown() then
			--ReloadUI()
		elseif IsAltKeyDown() then
			--BugSack:Reset()
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
	local hint = "|cffeda55fRight-Click|r for fAddons"--"|cffeda55fClick|r to set date. |cffeda55fShift-Click|r to reload the user interface. |cffeda55fAlt-Click|r does nothing."
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