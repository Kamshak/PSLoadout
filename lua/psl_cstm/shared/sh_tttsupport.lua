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
			--print( "Not adding " .. ammoType.name )
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
		--print( "Registered" , name, ammoType.name )
		scripted_ents.Register( ENT, name, false )
	end
end, 1 )

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
					--print( "Weapon " .. storedTbl.ClassName .. " => ammo " .. ammoEntClass ) 
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
	dp( "Running Init" )
	timer.Simple( 5, function( )
		initializeWeapons( )
	end )
end, 2 )