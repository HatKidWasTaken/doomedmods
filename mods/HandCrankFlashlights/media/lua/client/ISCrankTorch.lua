ISCrankTorch = {}

function ISCrankTorch.itemIsTorch(item)
	local AllTorches = {"CrankTorch1", "CrankTorch2", "CrankTorch3", "CrankTorch4", "CrankTorch5"}
	for i=0,5 do
		if item:getType() == AllTorches[i] then
			return true
		end
	end
	return false
end

function ISCrankTorch.ContextMenu(player, context, items)
	local character = getSpecificPlayer(player);
	
	for i,v in ipairs(items) do
        local testItem = v;
        if not instanceof(v, "InventoryItem") then
            testItem = v.items[1];
		end
		
		if ISCrankTorch.itemIsTorch(testItem) and character:getInventory():contains(testItem) and testItem:getDelta() < 0.95 then
			local option = context:addOption(getText("UI_CTTurnCrank"), player, ISCrankTorch.CheckTorch, items);
			break;
		end
	end
end

function ISCrankTorch.CheckTorch(player, items)
	local character = getSpecificPlayer(player);
	for i,v in ipairs(items) do
        testItem = v;
        if not instanceof(v, "InventoryItem") then
            testItem = v.items[1];
        end
		
		if ISCrankTorch.itemIsTorch(testItem) then
			handInjury = character:getBodyDamage():getBodyPartHealth(Hand_R) < 100
			ISTimedActionQueue.add(ISChargingTorch:new(character, testItem, handInjury))
		end
	end
end

function ISCrankTorch.CheckDelta()
	for playerIndex = 0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(playerIndex);
		
		if player ~= nil then
			if (player:getInventory():contains("CTorch.CrankTorch1") or player:getInventory():contains("CTorch.CrankTorch2") or player:getInventory():contains("CTorch.CrankTorch3") or player:getInventory():contains("CTorch.CrankTorch4") or player:getInventory():contains("CTorch.CrankTorch5")) then
				local itemTable = player:getInventory():getItems();
				for i=0, itemTable:size() - 1 do
					local testItem = itemTable:get(i);
					
					if ISCrankTorch.itemIsTorch(testItem) and player:getInventory():contains(testItem) and testItem:isActivated() and testItem:getDelta() <= 0.8 then
							testItem:setLightDistance(12.5 * (0.4 + testItem:getDelta()));
							testItem:setLightStrength(1.25 * (0.4 + testItem:getDelta()));
					else
						if ISCrankTorch.itemIsTorch(testItem) and player:getInventory():contains(testItem) and testItem:isActivated() and testItem:getDelta() > 0.8 then
							testItem:setLightDistance(15);
							testItem:setLightStrength(1.5);
						end
					end
				end
			end
		end
	end
end

Events.EveryOneMinute.Add(ISCrankTorch.CheckDelta);
Events.OnFillInventoryObjectContextMenu.Add(ISCrankTorch.ContextMenu);