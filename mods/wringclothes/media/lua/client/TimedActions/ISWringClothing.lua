--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISWringClothing = ISBaseTimedAction:derive("ISWringClothing");

maxDishClothWetCooldown = 8000.0;
maxBathTowelWetCooldown = 10000.0;


function canWringDishClothWet(item, minWetness)
	local dishClothWetness = (item:getWetCooldown() / maxDishClothWetCooldown) * 100.0;
	if dishClothWetness > minWetness then return true else return false end
end

function canWringBathTowelWet(item, minWetness) 
	local bathTowelWetness = (item:getWetCooldown() / maxBathTowelWetCooldown) * 100.0;
	if bathTowelWetness > minWetness then return true else return false end
end

function canWringClothing(item, minWetness)
	if item:getWetness() > minWetness then return true else return false end
end

function getMinimumWetnessFromStrength(character) 
	local playerStr = character:getPerkLevel(Perks.Strength);
	
	local minWetness = 100;
	
	if playerStr >= 10 then
		minWetness = 35;
	elseif playerStr >= 8 then
		minWetness = 45;
	elseif playerStr >= 6 then
		minWetness = 55;
	elseif playerStr >= 4 then
		minWetness = 65;
	elseif playerStr >= 2 then
		minWetness = 75;
	elseif playerStr >= 0 then
		minWetness = 85;
	end
	
	return minWetness;
end

function ISWringClothing:isValid()
	return true;
end

function ISWringClothing:update()
	self.item:setJobDelta(self:getJobDelta());
    self.character:setMetabolicTarget(Metabolics.HeavyDomestic);
end

function ISWringClothing:start()
	self:setActionAnim("RipSheets");
	self:setOverrideHandModels(nil, nil);
	self.item:setJobDelta(0.0);
end

function ISWringClothing:stop()
    self.item:setJobDelta(0.0);
    ISBaseTimedAction.stop(self);
end

function ISWringClothing:perform()
    self.item:setJobDelta(0.0);
	local item = self.item;

	if self.isClothing then
		if item:getWetness() > self.minWetness then
			item:setWetness(self.minWetness);
		end
	else
		local minWetnessNorm = self.minWetness / 100.0;
		if self.isBathTowel then
			item:setWetCooldown(minWetnessNorm * maxBathTowelWetCooldown);
		elseif self.isDishCloth then
			item:setWetCooldown(minWetnessNorm * maxDishClothWetCooldown);
		end
	end

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function ISWringClothing:new(character, item)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.item = item;
	o.stopOnWalk = false;
	o.stopOnRun = true;
	o.maxTime = 220;
	
	o.isDishCloth = false;
	o.isClothing = false;
	o.isBathTowel = false;
	
	local minWetness = getMinimumWetnessFromStrength(character);
	o.minWetness = minWetness;
	
	if item:getType() == "DishClothWet" and canWringDishClothWet(item, minWetness) then 
		o.isDishCloth = true;
	elseif item:getType() == "BathTowelWet" and canWringBathTowelWet(item, minWetness) then
		o.isBathTowel = true;
	elseif item:IsClothing() and canWringClothing(item, minWetness) then
		o.isClothing = true;
	else 
		-- Sanity Check
		o.maxTime = 1;
	end

	if o.character:isTimedActionInstant() then
		o.maxTime = 1;
	end

	return o;
end
