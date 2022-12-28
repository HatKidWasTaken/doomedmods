require "TimedActions/ISBaseTimedAction"
require "ISUI/ISLightSourceRadialMenu"
require "TimedActions/ISChargingTorch"

local function predicateLightSource(item)
	-- getLightStrength() may be > 0 even though the battery is dead.
	return (item:getLightStrength() > 0) or (item:getFullType() == "Base.Candle")
end

function ISLightSourceRadialMenu:fillMenuForItem(menu, item)
	if not (menu and item) then return; end;
	if not predicateLightSource(item) then return; end;

	local playerObj = self.character;
	local containerList = ISInventoryPaneContextMenu.getContainers(playerObj)

	if item:getFullType() == "Base.Candle" then
		local recipe = getScriptManager():getRecipe("Light Candle")
		if not recipe then return end
		local numberOfTimes = RecipeManager.getNumberOfTimesRecipeCanBeDone(recipe, playerObj, containerList, item)
		if numberOfTimes == 0 then return end
		menu:addSlice(item:getDisplayName() .. "\n" .. recipe:getName(), getTexture("media/ui/vehicles/vehicle_lightsON.png"), ISLightSourceRadialMenu.onLightCandle, self, item)
		return
	end

	if item:getFullType() == "Base.CandleLit" then
		local recipe = getScriptManager():getRecipe("Extinguish Candle")
		if not recipe then return end
		local numberOfTimes = RecipeManager.getNumberOfTimesRecipeCanBeDone(recipe, playerObj, containerList, item)
		if numberOfTimes == 0 then return end
		menu:addSlice(item:getDisplayName() .. "\n" .. recipe:getName(), getTexture("media/ui/vehicles/vehicle_lightsOFF.png"), ISLightSourceRadialMenu.onExtinguishCandle, self, item)
		return
	end

	local recipe = self:getInsertBatteryRecipe(item, containerList)
	if recipe then
		menu:addSlice(item:getDisplayName() .. "\n" .. recipe:getName(), getTexture("media/ui/LightSourceRadial_InsertBattery.png"), ISLightSourceRadialMenu.onInsertBattery, self, item)
	end

	recipe = self:getRemoveBatteryRecipe(item, containerList)
	if recipe then
		menu:addSlice(item:getDisplayName() .. "\n" .. recipe:getName(), getTexture("media/ui/LightSourceRadial_RemoveBattery.png"), ISLightSourceRadialMenu.onRemoveBattery, self, item)
	end

	if item:canBeActivated() and item:canEmitLight() then
		if item:isActivated() then
			menu:addSlice(item:getDisplayName() .. "\n" .. getText("ContextMenu_Turn_Off"), getTexture("media/ui/vehicles/vehicle_lightsOFF.png"), ISLightSourceRadialMenu.onToggle, self, item)
		else
			menu:addSlice(item:getDisplayName() .. "\n" .. getText("ContextMenu_Turn_On"), getTexture("media/ui/vehicles/vehicle_lightsON.png"), ISLightSourceRadialMenu.onToggle, self, item)
		end
	end
	
	if ISCrankTorch.itemIsTorch(item) and item:getDelta() < 0.95 then
		menu:addSlice(item:getDisplayName() .. "\n" .. getText("UI_CTTurnCrank"), getTexture("media/ui/radialcrank.png"), ISLightSourceRadialMenu.crankTorch, self, item)
		return
	end
end

function ISLightSourceRadialMenu:fillMenu()
	local menu = getPlayerRadialMenu(self.playerNum)
	menu:clear()
	local playerObj = self.character
	local playerInv = playerObj:getInventory()
	local items = playerInv:getAllEvalRecurse(predicateLightSource, ArrayList.new())

	local hasType = {}
	local itemList = {}
	for i=1,items:size() do
		local item = items:get(i-1)
		local fullType = item:getFullType()
		local accept = true
		if hasType[fullType] then
			if (fullType == "Base.Candle") or (fullType == "Base.CandleLit") then
				-- Remove duplicate Candle and CandleLit
				accept = false
			else
				-- Prefer non-dead light source over a dead one
				local other = hasType[fullType]
				if item:canEmitLight() and not other:canEmitLight() then
					if replaceItemInTable(itemList, other, item) then
						accept = false
					end
				else
					accept = false
				end
			end
		end
		if accept then
			hasType[fullType] = item
			table.insert(itemList, item)
		end
	end

	-- do equip menu entries
	for _,item in ipairs(itemList) do
		if not (playerObj:isPrimaryHandItem(item) or playerObj:isSecondaryHandItem(item)) then
			menu:addSlice(item:getDisplayName() .. "\n" .. getText("ContextMenu_Equip_Primary"), item:getTex(), ISLightSourceRadialMenu.onEquipLight, self, item, true);
			menu:addSlice(item:getDisplayName() .. "\n" .. getText("ContextMenu_Equip_Secondary"), item:getTex(), ISLightSourceRadialMenu.onEquipLight, self, item, false);
			if (item:getType() == "CrankTorch1" or item:getType() == "CrankTorch2" or item:getType() == "CrankTorch3" or item:getType() == "CrankTorch4" or item:getType() == "CrankTorch5") and playerObj:isAttachedItem(item) and item:getDelta() < 0.95 then
				menu:addSlice(item:getDisplayName() .. "\n" .. getText("UI_CTTurnCrank"), getTexture("media/ui/radialcrank.png"), ISLightSourceRadialMenu.crankTorch, self, item);
			end
		end
	end

	local primary	= playerObj:getPrimaryHandItem();
	local secondary	= playerObj:getSecondaryHandItem();

	-- do unequip options early so they are grouped with the equip menu entries
	if primary and predicateLightSource(primary) then
		menu:addSlice(primary:getDisplayName() .. "\n" .. getText("ContextMenu_Unequip"), getTexture("media/ui/ZoomOut.png"), ISLightSourceRadialMenu.onEquipLight, self, primary)
	end;
	if secondary and predicateLightSource(secondary) then
		menu:addSlice(secondary:getDisplayName() .. "\n" .. getText("ContextMenu_Unequip"), getTexture("media/ui/ZoomOut.png"), ISLightSourceRadialMenu.onEquipLight, self, secondary)
	end;

	-- do other options for light sources last
	self:fillMenuForItem(menu, primary);
	self:fillMenuForItem(menu, secondary);
end

function ISLightSourceRadialMenu:crankTorch(item)
	local playerObj = self.character
	local handInjury = self.character:getBodyDamage():getBodyPartHealth(Hand_R) < 100
	ISTimedActionQueue.add(ISChargingTorch:new(playerObj, item, handInjury))
end