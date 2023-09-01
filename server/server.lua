local VorpInv = exports.vorp_inventory:vorp_inventoryApi()

VorpInv.RegisterUsableItem("cloth", function(data)
	local _source = data.source
	local meta = data.item.metadata
	print(meta)
	local cloth = VorpInv.getItemContainingMetadata(_source, "cloth", meta)

	if cloth ~= nil then
		local meta = cloth.metadata
		local name = meta.description
		
		local comps = meta.comps
		TriggerClientEvent("vorpcharacter:updateCache", _source, false, comps)
		TriggerClientEvent("xakra_clothingstores:ChangeCloth", _source, comps)

	end
end)

--########################## CLOTHING STORE ##########################
RegisterNetEvent('xakra_clothingstores:OpenClothingStore')
AddEventHandler('xakra_clothingstores:OpenClothingStore', function()
	local _source = source
	local Character = VORPcore.getUser(_source).getUsedCharacter

	exports.oxmysql:execute("SELECT * FROM outfits WHERE identifier = @identifier AND charidentifier = @charidentifier", { ['@identifier'] = Character.identifier, ['@charidentifier'] = Character.charIdentifier }, function(Outfits)
		TriggerClientEvent('xakra_clothingstores:OpenClothingStore', _source, json.decode(Character.comps), json.decode(Character.skin), Outfits)
	end)
end)

--########################## BUY CLOTHING STORE ##########################
RegisterNetEvent('xakra_clothingstores:BuyClothes')
AddEventHandler('xakra_clothingstores:BuyClothes', function(Price, Comps, OutfitName)
	local _source = source
	local Character = VORPcore.getUser(_source).getUsedCharacter

	if Character.money < Price then
        VORPcore.NotifyObjective(_source, _U('NotMoney'), 4000)
        return
    end

	if Price > 0 then
		Character.removeCurrency(0, Price)
	end

	-- Character.updateComps(json.encode(Comps))
	TriggerClientEvent("vorpcharacter:updateCache", _source, false, Comps)
	TriggerClientEvent("xakra_clothingstores:CloseClothingStore", _source)

	if OutfitName ~= nil and OutfitName ~= "" then
		local Parameters = { ['@identifier'] = Character.identifier, ['@charidentifier'] = Character.charIdentifier, ['@Name'] = OutfitName, ['@Comps'] = json.encode(Comps) }
		exports.ghmattimysql:execute("INSERT INTO outfits (identifier, charidentifier, title, comps) VALUES (@identifier, @charidentifier, @Name, @Comps)", Parameters)
		exports.vorp_inventory:addItem(_source, 'cloth', 1, {description = OutfitName, comps = Comps})

	end
end)

--########################## BUY MAKEUP STORE ##########################
RegisterNetEvent('xakra_clothingstores:BuyMakeup')
AddEventHandler('xakra_clothingstores:BuyMakeup', function(Price, Skin)
	local _source = source
	local Character = VORPcore.getUser(_source).getUsedCharacter

	if Character.money < Price then
        VORPcore.NotifyObjective(_source, _U('NotMoney'), 4000)
        return
    end

	if Price > 0 then
		Character.removeCurrency(0, Price)
	end

	-- Character.updateSkin(json.encode(Skin))
	TriggerClientEvent("vorpcharacter:updateCache", _source, Skin, false)
	TriggerClientEvent("xakra_clothingstores:CloseClothingStore", _source)
end)

--########################## OUTFITS ##########################
RegisterNetEvent('xakra_clothingstores:SetOutfit')
AddEventHandler('xakra_clothingstores:SetOutfit', function(Comps)
	local _source = source
	TriggerClientEvent("vorpcharacter:updateCache", _source, false, Comps)
end)

RegisterNetEvent('xakra_clothingstores:DeleteOutfit')
AddEventHandler('xakra_clothingstores:DeleteOutfit', function(id)
	exports.oxmysql:execute("DELETE FROM outfits WHERE id = @id", { ['@id'] = id })
end)
