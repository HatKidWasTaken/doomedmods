local KEY_CRANK = {
	name = "CRANK_HOTKEY",
	key = Keyboard.KEY_NONE,
}

if ModOptions and ModOptions.AddKeyBinding then
	ModOptions:AddKeyBinding("[Hotkeys]",KEY_CRANK);
end

local function crankTorch(item, player)
	local handInjury = player:getBodyDamage():getBodyPartHealth(Hand_R) < 100
	ISTimedActionQueue.add(ISChargingTorch:new(player, item, handInjury))
end

local function KeyUp(keynum)
	local player = getSpecificPlayer(0)
	if player ~= nil then
		if keynum == KEY_CRANK.key then
			local items = player:getInventory():getItems()
			for i=0, items:size() - 1 do
				local testItem = items:get(i);
		
				if ISCrankTorch.itemIsTorch(testItem) and (player:isAttachedItem(testItem) or player:isPrimaryHandItem(testItem) or player:isSecondaryHandItem(testItem)) and testItem:getDelta() < 0.95 then
					crankTorch(testItem, player);
				end
			end
		end
	end
end

Events.OnKeyPressed.Add(KeyUp);