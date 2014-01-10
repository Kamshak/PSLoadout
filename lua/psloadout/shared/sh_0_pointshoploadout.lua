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
		return false 
	end
	
	local cstmAttachmentTable = CWAttachments[attachmentId]
	local ITEM = {
		ID = attachmentId,
		Name = cstmAttachmentTable.name,
		Description = cstmAttachmentTable.description,
		TextureId = cstmAttachmentTable.displaytexture,
		itemType = "attachment",
		cstmAttachmentNum = cstmAttachmentTable.num
	}
	table.Merge( ITEM, infoTbl )
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

local function initializeWeapons( )
	--Hook SWEPs up with their Kind entry for TTT
	for k, v in pairs( weapons.GetList( ) ) do
		if string.find( v.Base, "cstm_base" ) 
			and not string.find( v.ClassName, "cstm_base" )
			and not string.find( v.Base, "cmodel_cstm_base" )
		then
			local weaponItem
			for _, curWeaponItem in pairs( PSLoadout.getAllWeapons( ) ) do
				if curWeaponItem.WeaponClass == v.ClassName then
					weaponItem = curWeaponItem
				end
			end
			
			local storedTbl = weapons.GetStored( v.ClassName )
			if not ( weaponItem and weaponItem.NoAutoSpawn ) then
				storedTbl.AutoSpawnable = true
			end
			
			if weaponItem and weaponItem.Kind then
				storedTbl.Kind = weaponItem.Kind
				continue
			end
			
			for k, ammoEntClass in pairs( PSLoadout.SpawnableAmmo or {} ) do
				local ammoTbl = scripted_ents.Get( ammoEntClass )
				if ammoTbl.AmmoType == storedTbl.Primary.Ammo then
					storedTbl.AmmoEnt = ammoEntClass
					print( "Weapon " .. storedTbl.ClassName .. " => ammo " .. ammoEntClass ) 
					break
				end
			end
			
			if string.find( storedTbl.ClassName, "pistol" ) then
				storedTbl.Kind = WEAPON_PISTOL
			else
				storedTbl.Kind = WEAPON_HEAVY
			end
			
			if ( weaponItem and not weaponItem.Model ) and storedTbl.WorldModel then
				weaponItem.Model = storedTbl.WorldModel
			end
			
			if ( weaponItem and not weaponItem.Attachments ) and storedTbl.Attachments then
				print( "No Attachments for " .. weaponItem.Name .. " copying from stored: " .. #storedTbl.Attachments )
				weaponItem.Attachments = table.Copy( storedTbl.Attachments )
			end
		end
	end	
end
hook.Add( "InitPostEntity", "AssignWeaponKinds", function( )
	print( "Running Init" )
	timer.Simple( 5, function( )
		initializeWeapons( )
	end )
end, 2 )

hook.Add( "InitPostEntity", "niggas", function( )
	PSLoadout.SpawnableAmmo = {}
	for k, ammoType in ipairs( game.BuildAmmoTypes( ) ) do
		local found
		for _, weaponEntTbl in pairs( weapons.GetList( ) ) do
			if ammoType.name == weaponEntTbl.Primary.Ammo then
				found = true
			end
		end
		if not found then
			print( "Not adding " .. ammoType.name )
			continue 
		end
		
		local ENT = scripted_ents.Get( "base_ammo_ttt" )
		ENT.PrintName = ammoType.name
		ENT.AmmoType = ammoType.name
		ENT.AmmoAmount = 20
		ENT.AmmoMax = 60
		ENT.Model = Model("models/items/boxsrounds.mdl")
		ENT.AutoSpawnable = true
		
		local name = "genammo_" .. k
		name = string.Replace( name, ".", "" )
		name = string.Replace( name, " ", "_" )
		ENT.ClassName = name
		
		table.insert( PSLoadout.SpawnableAmmo, name )
		print( "Registered" , name, ammoType.name )
		scripted_ents.Register( ENT, name, false )
	end
end, 1 )

if CLIENT then
	hook.Add( "Think", "RemoveStff", function( )
		hook.Remove( "PlayerBindPress", "SWEP.PlayerBindPress (CSTM)" )
	end )
	hook.Remove( "PlayerBindPress", "SWEP.PlayerBindPress (CSTM)" )
	RunConsoleCommand( "cstm_firstpersondeath", 1 )
	RunConsoleCommand( "cstm_hud_ammo", 0 )
	RunConsoleCommand( "cstm_hud_health", 0 )
	RunConsoleCommand( "cstm_ef_blur_sprint", 0 )
	RunConsoleCommand( "cstm_ef_blur_viewmodel", 0 )
	RunConsoleCommand( "cstm_ef_blur_depth", 0 )
	RunConsoleCommand( "cstm_ef_heat", 0 )
	RunConsoleCommand( "cstm_ef_smoke", 1 )
	RunConsoleCommand( "cstm_ef_sparks", 1 )
	RunConsoleCommand( "cstm_ef_laserblur", 0 )
end