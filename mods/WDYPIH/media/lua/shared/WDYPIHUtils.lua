WDYPIHUtils = {}

function WDYPIHUtils.formatTooltip(containerObj)
    local cType = getTextOrNull("IGUI_ContainerTitle_" .. containerObj:getContainer():getType()) or getText("IGUI_ItemCat_Container")
    local cName = containerObj:getModData().wdypihName or getText("IGUI_WDYPIH_NoName")
    local t = " <RGB:0.8,0.8,0.8> [" .. cType .. "] <LINE> <RGB:1,1,1> " .. cName
    return t
end