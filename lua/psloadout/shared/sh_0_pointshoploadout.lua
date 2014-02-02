PSLoadout = {}

function PSLoadout.getAttachment( attachmentId )
	local infoTbl
	for subCat, attachmentTable in pairs( PS.Categories.attachments.Attachments ) do
		if attachmentTable[attachmentId] then
			infoTbl = attachmentTable[attachmentId]
			break
		end
	end
	if not infoTbl then
		return nil 
	end
	
	local ITEM = {
		ID = attachmentId,
		itemType = "attachment",
		Name = "Invalid Name set",
		Description = "No Description",
	}
	if CLIENT then
		ITEM.TextureId = surface.GetTextureID( "Brick/brickfloor001a" )
	end
	table.Merge( ITEM, infoTbl )
	PSLoadout:getProvider( ):addAttributes( ITEM )
	
	return ITEM
end

function PSLoadout.getSlot( slotId )
	local ITEM
	for slotType, slotCat in pairs( PS.Categories.loadout.LoadoutSettings ) do
		if slotCat.ID == slotId then
			ITEM = table.Copy( slotCat )
			ITEM.slotType = slotType
			ITEM.itemType = "slot"
			break
		end
		for _, v in pairs( slotCat.attachmentSlots ) do
			if v.ID == slotId then
				ITEM = table.Copy( v )
				ITEM.itemType = "attachmentSlot"
				ITEM.parentSlotType = slotType
				break
			end
		end
		if ITEM then break end
	end
	return ITEM
end

function PSLoadout.attachmentValidForWeapon( attachmentId, weapon )
	for key, tbl in pairs( weapon.Attachments or {} ) do
		if table.HasValue( tbl, attachmentId ) then
			return true
		end
	end
	return false
end

function PSLoadout.getAllWeapons( )
	local loadoutItems = {}
	for _, ITEM in pairs( PS.Items ) do
		if ITEM.Category == PS.Categories.loadout.Name then
			table.insert( loadoutItems, ITEM )
		end
	end
	return loadoutItems
end

function PSLoadout.recreateTables( )
	for k, v in pairs( PSLoadout ) do
		if istable( v ) and v.dropTable then
			v.dropTable( )
		end
	end
end

