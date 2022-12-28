require('BuildingObjects/ISBuildingObject')

WDYPIHCursor = ISBuildingObject:derive("WDYPIHCursor")

function WDYPIHCursor:isValid(square)
    return true
end

function WDYPIHCursor:create(x, y, z, north, sprite)
end

function WDYPIHCursor:render(x, y, z, square)
    local containers = {}
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        local doHighlight = false
        if object:getContainer() then
            doHighlight = true
            table.insert(containers, object)
        elseif object:getProperties():Is(IsoFlagType.solidfloor) then
            doHighlight = true
        end

        if doHighlight then
            object:setHighlighted(true)
            object:setHighlightColor(getCore():getObjectHighlitedColor())
        end
    end

    local text = ""
    for i = #containers, 1, -1 do
        local object = containers[i]
        text = text .. WDYPIHUtils.formatTooltip(object)
        if i ~= 1 then
            text = text .. " <LINE> <LINE> "
        end
    end

    if text ~= "" then
        self.tooltipRender.description = text
        self.tooltipRender:setVisible(true)
        self.tooltipRender:addToUIManager()
    elseif self.tooltipRender:isVisible() then
        self.tooltipRender:removeFromUIManager()
        self.tooltipRender:setVisible(false)
    end
end

function WDYPIHCursor:init()
    ISBuildingObject.init(self)

    self.tooltipRender = ISToolTip:new()
    self.tooltipRender:initialise()
    self.tooltipRender:setVisible(false)
    self.tooltipRender:addToUIManager()
end

function WDYPIHCursor:deactivate()
    if self.tooltipRender then
        self.tooltipRender:setVisible(false)
        self.tooltipRender:removeFromUIManager()
    end
end

function WDYPIHCursor:new(character, containerObj)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o:init()
    o:setSprite("")
    o:setNorthSprite("")
    o.character = character
    o.player = character:getPlayerNum()
    o.containerObj = containerObj
    o.noNeedHammer = true
    o.skipBuildAction = true
    return o
end