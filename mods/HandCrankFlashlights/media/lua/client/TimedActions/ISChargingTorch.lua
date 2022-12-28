require "TimedActions/ISBaseTimedAction"

ISChargingTorch = ISBaseTimedAction:derive("ISChargingTorch");

function ISChargingTorch:isValid()
	if self.item:getDelta() >= 0.95 then
		return false
	else
		return true;
	end
end

function ISChargingTorch:update()
	self.item:setJobDelta(self:getJobDelta());
    self.character:setMetabolicTarget(Metabolics.HeavyDomestic);
end

function ISChargingTorch:start()
	if self.crankSound ~= '' then
        self.crankAudio = self.character:getEmitter():playSound(self.crankSound);
		--self.crankAudio = self.character:playSound(self.crankSound);
		addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), 7, 1)
    end
	self:setActionAnim("Craft");
	if not self.character:isAttachedItem(self.item) then
		self:setOverrideHandModels(nil, self.item);
	else
		self:setOverrideHandModels(nil, nil);
	end
	self.item:setJobDelta(0.0);
end

function ISChargingTorch:stop()
	if self.crankAudio ~= 0 and self.character:getEmitter():isPlaying(self.crankAudio) then
        self.character:getEmitter():stopSound(self.crankAudio);
    end
	self.item:setJobDelta(0.0);
	
	if self.character:getInventory():contains(self.item) then
		self.item:setDelta(self.item:getDelta() + (self:getJobDelta() * (1 - self.item:getDelta())));
		self.item:setLightDistance(12.5 * (0.4 + self.item:getDelta()));
		self.item:setLightStrength(1.25 * (0.4 + self.item:getDelta()));
		if self.item:getDelta() >= 1 then
			self.item:setDelta(1);
		end
	end
	
    ISBaseTimedAction.stop(self);
end

function ISChargingTorch:perform()
	if self.crankAudio ~= 0 and self.character:getEmitter():isPlaying(self.crankAudio) then
        self.character:getEmitter():stopSound(self.crankAudio);
		self.crankSound = nil
    end
	self.item:setJobDelta(0.0);
	local item = self.item;
	item:setDelta(1);
	item:setLightStrength(1.5);
	item:setLightDistance(15);
	ISBaseTimedAction.perform(self);
end

function ISChargingTorch:new(character, item, injured)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.item = item;
	o.stopOnWalk = false;
	o.stopOnRun = true;
	o.injured = injured;
	o.maxTime = (1 - o.item:getDelta()) * 300;
	o.crankSound = "turncrankS";
	
	if o.injured then
		o.maxTime = (1 - o.item:getDelta()) * 400;
		o.crankSound = "turncrankL";
	end
	
	o.crankAudio = 0;
	
	if o.character:isTimedActionInstant() then o.maxTime = 1; end
	
	return o;
end

