ISWringClothingMenu = {};


function ISWringClothing.isWringable(minWetness, item)	
	if item:IsClothing() and canWringClothing(item, minWetness) and not string.find(item:getName(), "Helmet") then
		return true;
	elseif item:getType() == "DishClothWet" and canWringDishClothWet(item, minWetness) then 
		return true;
	elseif item:getType() == "BathTowelWet" and canWringBathTowelWet(item, minWetness) then
		return true;
	end
	
	return false;
end

function ISWringClothingMenu.DoContextMenu(player, context, items)
	local character = getSpecificPlayer(player);
	local minWetness = getMinimumWetnessFromStrength(character);

	local allPotentiallyWringable = false;

	for i,v in ipairs(items) do
        local testItem = v;
        if not instanceof(v, "InventoryItem") then
            testItem = v.items[1];
        end

		if ISWringClothing.isWringable(minWetness, testItem) then 
			local option = context:addOption(getText("UI_ContextMenu_WringClothing_Option"), player, ISWringClothingMenu.onWringClothing, items)
			local tooltip = ISInventoryPaneContextMenu.addToolTip();
			tooltip.description = getText("UI_ContextMenu_WringClothing_Tooltip");
			option.toolTip = tooltip;
			break;
		end
	end
end

function ISWringClothingMenu.onWringClothing(player, items)
	local character = getSpecificPlayer(player);
	local minWetness = getMinimumWetnessFromStrength(character);
	
	for i,v in ipairs(items) do
        testItem = v;
        if not instanceof(v, "InventoryItem") then
            testItem = v.items[1];
        end

		local isWearing = false;
		if ISWringClothing.isWringable(minWetness, testItem) then
			if testItem:isEquipped() then
				ISTimedActionQueue.add(ISUnequipAction:new(character, testItem, 50))
				isWearing = true;
			elseif luautils.haveToBeTransfered(character, testItem) then
				ISTimedActionQueue.add(ISInventoryTransferAction:new(character, testItem, testItem:getContainer(), character:getInventory()))
			end
			
			ISTimedActionQueue.add(ISWringClothing:new(character, testItem))
			
			if isWearing then
				ISTimedActionQueue.add(ISWearClothing:new(character, testItem, 50))
			end
		end
	end
end

Events.OnFillInventoryObjectContextMenu.Add(ISWringClothingMenu.DoContextMenu);