--[[

MapLegendUI
by NikGamer#1008
Version: 2.0.7

This is my first mod ever. If you are reading this - have a good day.
Thanks to all who downloaded and liked the mod and the PZ Discord community for your support.

Special thanks:
- Wipe#8785 for implementing a compatibility between this mod and the "Extra Map Symbols UI" mod
- MrBounty#5616 for a bunch of useful information on building a UI and being a huge help with the code

]]--

require "ISUI/ISPanelJoypad"
require "ISUI/ISButton"
require "ISUI/Maps/ISWorldMap"

mapLegendWindow = ISPanelJoypad:derive("mapLegendWindow")
mapLegendButton = ISButton:derive("mapLegendButton")
local private = {}
private.createChildren = ISWorldMap.createChildren

--Adding the legend window and button to the world map
function ISWorldMap:createChildren()

    private.createChildren(self)

	self.legendButton = mapLegendButton:new(10, 10, 10, 10, "", self, self.LegendToggle)
	self.legendButton.parent = self
	self.legendButton:initialise()
	self:addChild(self.legendButton)
	
	self.mapLegend = mapLegendWindow:new(10, 10, 0, 0)
	self.mapLegend.parent = self
	self.mapLegend:initialise()
	self.legendButton:addChild(self.mapLegend)

end

function mapLegendButton:initialise()	

	ISButton.initialise(self)
	
end

function mapLegendButton:prerender()

	ISButton.prerender(self)
	--button size and coordinates
	local buttonSize = self.imageButton:getWidthOrig()
	self:setHeight(buttonSize)
	self:setWidth(buttonSize)
	self:setX(20)
	self:setY(getCore():getScreenHeight() - buttonSize - 20)
	self:drawTexture(self.imageButton, 0, 0, 1, 1, 1, 1)

end

function mapLegendWindow:initialise()

	ISPanelJoypad.initialise(self)
	
end

function mapLegendWindow:prerender()	

	ISPanelJoypad.prerender(self)
	
	--calculating columns 
	--very crude solution, but I can't be asked to figure out and implement a better way to do this (tables, you say? ew, gross)
	local iconSize = self.colorCommunity:getWidthOrig()
	
	local tsizeCommunity = getTextManager():MeasureStringX(UIFont.Small, getText("UI_legendCommunity"))
	local tsizeRetail = getTextManager():MeasureStringX(UIFont.Small, getText("UI_legendRetail"))
	local tsizeIndustrial = getTextManager():MeasureStringX(UIFont.Small, getText("UI_legendIndustrial"))
	local tsizeResidential = getTextManager():MeasureStringX(UIFont.Small, getText("UI_legendResidential"))
	local tsizeRestaurants = getTextManager():MeasureStringX(UIFont.Small, getText("UI_legendRestaurants"))
	local tsizeHospitality = getTextManager():MeasureStringX(UIFont.Small, getText("UI_legendHospitality"))
	local tsizeMedical = getTextManager():MeasureStringX(UIFont.Small, getText("UI_legendMedical"))
	local tsizeParks = getTextManager():MeasureStringX(UIFont.Small, getText("UI_legendParks"))
	
	local maxTextWidth = math.max(tsizeCommunity, tsizeRetail, tsizeIndustrial,  tsizeResidential, tsizeRestaurants, tsizeHospitality, tsizeMedical, tsizeParks)
	
	self.iconColumn = iconSize
	self.textColumn = self.iconColumn + 25
	
	--padding for the first row
	self.iconPadding = 10
	
		--adjusting vertical padding for non-standard fonts
		local langText = Translator.getLanguage():name()
		if langText == "CN" then 
		self.textPadding = (iconSize / 2) + 1
		elseif langText == "RU" and not ActiveMods.getById("currentGame"):isModActive("RussianLanguagePack41") then
		self.textPadding = (iconSize / 2) + 2
		elseif langText == "TH" then
		self.textPadding = (iconSize / 2) + 2
		elseif langText == "KO" then
		self.textPadding = (iconSize / 2) + 2
		elseif langText == "JP" then
		self.textPadding = (iconSize / 2) + 3
		else
		self.textPadding = iconSize / 2
		end
	
	--padding for the subsequent rows
	self.itemPadding = 25
	
	--calculating and applying legend window size
	LegendWindowWidth = self.textColumn + maxTextWidth + (iconSize - 1)
	LegendWindowHeight = self.iconPadding + (self.itemPadding * 8) + 1
	self:setWidth(LegendWindowWidth)
	self:setHeight(LegendWindowHeight)
	
	self:setX(-10)
	self:setY(10 - (getCore():getScreenHeight() - 48 - 20))
	
	--Templates (for reference)
	--drawText(str, x, y, r, g, b, a, font)
	--drawTexture(texture, x, y, a, r, g, b)
	
	-- creating icons
	self:drawTexture(self.colorCommunity, self.iconColumn, self.iconPadding, 1, 1, 1, 1)
	self:drawTexture(self.colorRetail, self.iconColumn, self.iconPadding + self.itemPadding, 1, 1, 1, 1)
	self:drawTexture(self.colorIndustrial, self.iconColumn, self.iconPadding + (self.itemPadding * 2), 1, 1, 1, 1)
	self:drawTexture(self.colorResidential, self.iconColumn, self.iconPadding + (self.itemPadding * 3), 1, 1, 1, 1)
	self:drawTexture(self.colorRestaurants, self.iconColumn, self.iconPadding + (self.itemPadding * 4), 1, 1, 1, 1)
	self:drawTexture(self.colorHospitality, self.iconColumn, self.iconPadding + (self.itemPadding * 5), 1, 1, 1, 1)
	self:drawTexture(self.colorMedical, self.iconColumn, self.iconPadding + (self.itemPadding * 6), 1, 1, 1, 1)
	self:drawTexture(self.colorParks, self.iconColumn, self.iconPadding + (self.itemPadding * 7), 1, 1, 1, 1)
	
	-- creating text
	self:drawText(getText("UI_legendCommunity"), self.textColumn, self.textPadding, 1, 1, 1, 1, UIFont.Small)
	self:drawText(getText("UI_legendRetail"), self.textColumn, self.textPadding + self.itemPadding, 1, 1, 1, 1, UIFont.Small)
	self:drawText(getText("UI_legendIndustrial"), self.textColumn, self.textPadding + (self.itemPadding * 2), 1, 1, 1, 1, UIFont.Small)
	self:drawText(getText("UI_legendResidential"), self.textColumn, self.textPadding + (self.itemPadding * 3), 1, 1, 1, 1, UIFont.Small)
	self:drawText(getText("UI_legendRestaurants"), self.textColumn, self.textPadding + (self.itemPadding * 4), 1, 1, 1, 1, UIFont.Small)
	self:drawText(getText("UI_legendHospitality"), self.textColumn, self.textPadding + (self.itemPadding * 5), 1, 1, 1, 1, UIFont.Small)
	self:drawText(getText("UI_legendMedical"), self.textColumn, self.textPadding + (self.itemPadding * 6), 1, 1, 1, 1, UIFont.Small)
	self:drawText(getText("UI_legendParks"), self.textColumn, self.textPadding + (self.itemPadding * 7), 1, 1, 1, 1, UIFont.Small)
	
end

--closing & opening of the legend window
function ISWorldMap:LegendToggle()
	
	local isHidden = not self.mapLegend:isVisible() 
	self.mapLegend:setVisible(isHidden)

end

--legend window
function mapLegendWindow:new(x, y, width, height)

	local o = {}
	o = ISPanelJoypad:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.backgroundColor = {r=0, g=0, b=0, a=0.8}
	o.colorCommunity = getTexture("media/ui/MapLegendUI/community.png")
	o.colorRetail = getTexture("media/ui/MapLegendUI/retail.png")
	o.colorIndustrial = getTexture("media/ui/MapLegendUI/industrial.png")
	o.colorResidential = getTexture("media/ui/MapLegendUI/residential.png")
	o.colorRestaurants = getTexture("media/ui/MapLegendUI/restaurants.png")
	o.colorHospitality = getTexture("media/ui/MapLegendUI/hospitality.png")
	o.colorMedical = getTexture("media/ui/MapLegendUI/medical.png")
	o.colorParks = getTexture("media/ui/MapLegendUI/parks.png")
	return o
	
end

--legend ON\OFF button
function mapLegendButton:new(x, y, width, height, title, clicktarget, onclick)

	local o = {}
	o = ISButton:new (x, y, width, height, title, clicktarget, onclick)
	setmetatable(o, self)
	self.__index = self
	o.imageButton = getTexture("media/ui/MapLegendUI/button.png")
	return o
	
end