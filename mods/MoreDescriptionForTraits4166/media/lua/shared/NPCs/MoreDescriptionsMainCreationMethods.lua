require "NPCs/MainCreationMethods.lua";

BaseGameCharacterDetails = BaseGameCharacterDetails or {}
forageSkills = forageSkills or {}
TraitFactory = TraitFactory or {}
ProfessionFactory = ProfessionFactory or {}

BaseGameCharacterDetails.oldSetTraitDescription = function(trait)
    local desc = trait:getDescription() or ""
	local boost = transformIntoKahluaTable(trait:getXPBoostMap())
	local infoList = {}
	for perk,level in pairs(boost) do
		local perkName = PerkFactory.getPerkName(perk)
		-- "+1 Cooking" etc
		local levelStr = tostring(level:intValue())
		if level:intValue() > 0 then levelStr = "+" .. levelStr end
        if string.match(desc, levelStr .. " " .. perkName) then
            return;
        end
		table.insert(infoList, { perkName = perkName, levelStr = levelStr })
	end
	table.sort(infoList, function(a,b) return not string.sort(a.perkName, b.perkName) end)
	for _,info in ipairs(infoList) do
		if desc ~= "" then desc = desc .. "\n" end
		desc = desc .. info.levelStr .. " " .. info.perkName
	end
	trait:setDescription(desc)
end

BaseGameCharacterDetails.oldSetProfessionDescription = function(prof)
    local desc = getTextOrNull("UI_profdesc_" .. prof:getType()) or ""
	local boost = transformIntoKahluaTable(prof:getXPBoostMap())
	local infoList = {}
	for perk,level in pairs(boost) do
		local perkName = PerkFactory.getPerkName(perk)
		-- "+1 Cooking" etc
		local levelStr = tostring(level:intValue())
		if level:intValue() > 0 then levelStr = "+" .. levelStr end
        if string.match(desc, levelStr .. " " .. perkName) then
            return;
        end
		table.insert(infoList, { perkName = perkName, levelStr = levelStr })
	end
	table.sort(infoList, function(a,b) return not string.sort(a.perkName, b.perkName) end)
	for _,info in ipairs(infoList) do
        
		if desc ~= "" then desc = desc .. "\n" end
		desc = desc .. info.levelStr .. " " .. info.perkName
	end
	local traits = prof:getFreeTraits()
	for j=1,traits:size() do
		if desc ~= "" then desc = desc .. "\n" end
		local traitName = traits:get(j-1)
		local trait = TraitFactory.getTrait(traitName)
		desc = desc .. trait:getLabel()
	end
	prof:setDescription(desc)
end

BaseGameCharacterDetails.updateTraitDescription = function(trait)
	local desc = trait:getDescription() or getTextOrNull("UI_profdesc_" .. trait:getType()) or getTextOrNull("UI_trait_" .. trait:getType().."desc") or ""
    if string.match(desc, "---"..getText("IGUI_perks_Foraging")..": ---") then
        return ;
    end
    local table = forageSkills[trait:getType()]
    if table then
            desc = desc .. "\n"
            desc = desc .. "---"..getText("IGUI_perks_Foraging")..": ---"
            if table.visionBonus and table.visionBonus~=0 then
                desc = desc .. "\n"
                if table.visionBonus>0 then
                    desc = desc .. "+" .. table.visionBonus .. " " .. getText("IGUI_SearchMode_Vision_Effect_Radius")
                else
                    desc = desc .. table.visionBonus .. " " .. getText("IGUI_SearchMode_Vision_Effect_Radius")
                end
            end
            if table.weatherEffect and table.weatherEffect~=0 then
                desc = desc .. "\n"
                desc = desc .. "-" .. table.weatherEffect .. "% " .. getText("IGUI_SearchMode_Vision_Effect_Weather")
            end
            if table.darknessEffect and table.darknessEffect~=0 then
                desc = desc .. "\n"
                desc = desc .. "-" .. table.darknessEffect .. "% " .. getText("IGUI_SearchMode_Vision_Effect_Darkness")
            end
            if table.specialisations then
                for category, bonus in pairs(table.specialisations) do
                    if bonus ~= 0 then
                        desc = desc .. "\n"
                        if bonus > 0 then
                            desc = desc .."+" .. bonus .. "% ".. getText("IGUI_SearchMode_Categories_"..category)
                        else
                            desc = desc .. bonus .. "% ".." ".. getText("IGUI_SearchMode_Categories_"..category)
                        end
                    end
                end
            end
            
            if trait:getType() == "ShortSighted" then
                desc = desc .. "\n"
                desc = desc .. getText("UI_ShortSighted_Condition")
            end
    end
	trait:setDescription(desc)
end


BaseGameCharacterDetails.SetProfessionDescription = function(prof)
    BaseGameCharacterDetails.oldSetProfessionDescription(prof)
    BaseGameCharacterDetails.updateTraitDescription(prof)
end

BaseGameCharacterDetails.SetTraitDescription = function(trait)
    BaseGameCharacterDetails.oldSetTraitDescription(trait)
    BaseGameCharacterDetails.updateTraitDescription(trait)
end

-- local function addForagingDescriptionsToTraitsAndProfessions()
--     local traitList = TraitFactory.getTraits()
-- 	for i=1,traitList:size() do
-- 		local trait = traitList:get(i-1)
--         BaseGameCharacterDetails.SetTraitDescription(trait)
-- 	end

--     local profList = ProfessionFactory.getProfessions()
-- 	for i=1,profList:size() do
-- 		local prof = profList:get(i-1)
-- 		BaseGameCharacterDetails.SetProfessionDescription(prof)
-- 	end
-- end

-- Events.OnGameBoot.Add(addForagingDescriptionsToTraitsAndProfessions);
