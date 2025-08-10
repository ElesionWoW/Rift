--Set up Constants
local teleportString = "Teleport: "
local portalString = "Portal: "
local teleportHeader = "Teleports"
local portalHeader = "Portals"
local buttonTooltip = "Click to open Rift. Drag while holding CTRL to move."

--Set up Variables
local RiftMage = 0
local teleportsFound
local teleportsCount
local portalsFound
local portalsCount

--FRAMES & EVENTS
Rift = CreateFrame("Frame"); --Event Frame

Rift:RegisterEvent("ADDON_LOADED")

function Rift:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "Rift" then
		--check if player is even a mage
		local _,class = UnitClass("PLAYER")
		if class == "MAGE" then RiftMage = 1 end
		
		--initial set-up on load
		if RiftMage == 1 then
			Rift:SetupFrames()
		end
	end
end

Rift:SetScript("OnEvent", Rift.OnEvent)

function Rift:SetupFrames()
	--create display frame
	self.UI = CreateFrame("Button", "RiftButton", UIParent)
	self.UI:SetFrameStrata("HIGH")
	self.UI:SetWidth(32)
	self.UI:SetHeight(32)
	self.UI:SetBackdrop({bgFile = "Interface\\Icons\\Spell_Arcane_TeleportStormWind"})
	self.UI:SetPoint("CENTER",0,0)
	
	--make it movable
	self.UI:SetMovable(true)
	self.UI:EnableMouse(true)
	self.UI:RegisterForDrag("LeftButton")
	self.UI:SetScript("OnDragStart", function()
		if IsControlKeyDown() then
			Rift.UI:StartMoving()
		end
	end)
	self.UI:SetScript("OnDragStop", function()
		Rift.UI:StopMovingOrSizing()
	end)
	
	--set tooltip
	self.UI:SetScript("OnEnter",function() 
		GameTooltip:SetOwner(Rift.UI, "ANCHOR_CURSOR")
		GameTooltip:SetText(buttonTooltip, 1, 1, 1, 1, 1)
		GameTooltip:Show()
	end)
	self.UI:SetScript("OnLeave",function()
		GameTooltip:Hide()
	end)
	
	--button functionality
	self.UI:SetScript("OnClick",function()
		Rift:CrawlSpellbook()
		UIDropDownMenu_Initialize(Rift.UI.Menu, Rift.PopulateDropdown, "MENU")
		ToggleDropDownMenu(1,nil,Rift.UI.Menu,"cursor",-80,0); --level, sublevel, dropdown frame to show, name of anchor frame, xOffset, yOffset
		PlaySound("igMainMenuOptionCheckBoxOn")
	end)
	
	--add drop down menu frame
	self.UI.Menu = CreateFrame("Frame", "RiftMenu", Rift.UI, "UIDropDownMenuTemplate")
end


--MAIN FUNCTIONALITY

-- find all teleport and portal spells in the spell book
function Rift:CrawlSpellbook()
	--reset variables for the new crawl
	teleportsFound = {}
	teleportsCount = 0
	portalsFound = {}
	portalsCount = 0
	
	--crawl entire spell book
	local spellID = 1
	while true do
		local name = GetSpellName(spellID,BOOKTYPE_SPELL)
		if not name then
			do break end
		end
		
		if string.sub(name,1,string.len(teleportString)) == teleportString then --match "Teleport: "
			teleportsCount = teleportsCount + 1
			teleportsFound[teleportsCount] = name
		elseif string.sub(name,1,string.len(portalString)) == portalString then --match "Portal: "
			portalsCount = portalsCount + 1
			portalsFound[portalsCount] = name
		end
		spellID = spellID + 1
	end
end


-- populate the spell dropdown
function Rift:PopulateDropdown()
	local title = {
		text = " ",
		isTitle = true,
		notCheckable = true,
		justifyH = "CENTER",
	}
	local entry = {
		text = " ",
		func = function() end,
		notCheckable = true,
	}
	
	if teleportsCount > 0 then
		--first header
		title.text = teleportHeader
		UIDropDownMenu_AddButton(title);
	
		--first list
		for i=1,teleportsCount do
			local index = i
			entry.text = teleportsFound[index]
			entry.func = function()
				CastSpellByName(teleportsFound[index])
			end
			UIDropDownMenu_AddButton(entry);
		end
	end
	
	if portalsCount > 0 then
		--second header
		title.text = portalHeader
		UIDropDownMenu_AddButton(title);
	
		-- add portals
		for i=1,portalsCount do
			local index = i
			entry.text = portalsFound[index]
			entry.func = function()
				CastSpellByName(portalsFound[index])
			end
			UIDropDownMenu_AddButton(entry);
		end
	end
end


--SLASH COMMANDS


--OUTPUTS


--UTILITY


