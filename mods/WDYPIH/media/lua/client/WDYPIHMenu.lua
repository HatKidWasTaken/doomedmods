local function onRename(target, button, containerObj)
    containerObj:setHighlighted(false)

    if button.internal ~= "OK" then return end

    local text = button.parent.entry:getText()
    if string.len(text) > 0 then
        containerObj:getModData().wdypihName = text
    else
        containerObj:getModData().wdypihName = nil
    end
    containerObj:transmitModData()
end

local function showRenameModal(playerObj, containerObj)
    containerObj:setHighlighted(true, false)
    containerObj:setHighlightColor(getCore():getObjectHighlitedColor())

    local label = getText("IGUI_WDYPIH_Name", getTextOrNull("IGUI_ContainerTitle_" .. containerObj:getContainer():getType()))
    local name = containerObj:getModData().wdypihName or ""

    local modal = ISTextBox:new(0, 0, 280, 150, label, name,
            nil, onRename, playerObj:getPlayerNum(), containerObj)
    modal:initialise()
    modal:addToUIManager()
end

local function inspectContainers(playerObj)
    local bo = WDYPIHCursor:new(playerObj)
    getCell():setDrag(bo, playerObj:getPlayerNum())
end

local function createWorldMenu(player, context, worldObjects)
    local playerObj = getSpecificPlayer(player)

    local containerObj
    for _, object in ipairs(worldObjects) do
        local test = object:getItemContainer()
        if test then
            containerObj = object
            break
        end
    end

    if not containerObj then return end
    local name = getText("ContextMenu_WDYPIH_Container")
    if containerObj:getModData().wdypihName then
        name = "# " .. containerObj:getModData().wdypihName
        if #name > 20 then
            name = string.sub(name, 1, 20) .. "..."
        end
    end

    local option = context:addOptionOnTop(name, nil, nil)
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(option, subMenu)

    subMenu:addOption(getText("ContextMenu_WDYPIH_Inspect"), playerObj, inspectContainers)

    local renameOption = subMenu:addOption(getText("ContextMenu_WDYPIH_Rename"), playerObj, showRenameModal, containerObj)
    local toolTip = ISToolTip:new()
    toolTip:initialise()
    toolTip:setVisible(false)
    renameOption.toolTip = toolTip

    toolTip.description = WDYPIHUtils.formatTooltip(containerObj)
end

Events.OnFillWorldObjectContextMenu.Add(createWorldMenu)