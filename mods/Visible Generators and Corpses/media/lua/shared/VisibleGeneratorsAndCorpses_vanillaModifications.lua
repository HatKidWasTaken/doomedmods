local scriptItem = getScriptManager():getItem("Base.CorpseFemale")
if scriptItem then
	-- print("Visible Female Corpse!")
	scriptItem:DoParam("StaticModel = PA_Corpse")
	scriptItem:DoParam("primaryAnimMask = HoldingTorchRight")
	scriptItem:DoParam("secondaryAnimMask = HoldingTorchLeft")
end

local scriptItem = getScriptManager():getItem("Base.CorpseMale")
if scriptItem then
	-- print("Visible Male Corpse!")
	scriptItem:DoParam("StaticModel = PA_Corpse")
	scriptItem:DoParam("primaryAnimMask = HoldingTorchRight")
	scriptItem:DoParam("secondaryAnimMask = HoldingTorchLeft")
end

local scriptItem = getScriptManager():getItem("Base.Generator")
if scriptItem then
	-- print("Visible Generator!")
	scriptItem:DoParam("StaticModel = PA_Generator")
	scriptItem:DoParam("primaryAnimMask = HoldingTorchRight")
	scriptItem:DoParam("secondaryAnimMask = HoldingTorchLeft")
end
