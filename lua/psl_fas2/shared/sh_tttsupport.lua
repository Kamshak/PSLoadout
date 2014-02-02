hook.Add( "InitPostEntity", "fas2builtammo", function( )
	if engine.ActiveGamemode( ) != "terrortown" then
		return
	end
	
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
		print( "Registered" , name, ammoType.name )
		scripted_ents.Register( ENT, name, false )
	end
end, 1 )

local function initializeWeapons( )
	if engine.ActiveGamemode( ) != "terrortown" then
		return
	end
	
	local tttbase
	--Hook SWEPs up with their Kind entry for TTT
	for k, v in pairs( weapons.GetList( ) ) do
		if v.ClassName == "weapon_tttbase" then
			tttbase = v
		end
	end
	for k, v in pairs( weapons.GetList( ) ) do
		if string.find( v.Base, "fas2_base" ) then
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
			
			if table.HasValue( { "pistol", "revolver" }, storedTbl.HoldType ) then
				storedTbl.Kind = WEAPON_PISTOL
			else
				storedTbl.Kind = WEAPON_HEAVY
			end
			
			if weaponItem and weaponItem.Kind then
				storedTbl.Kind = weaponItem.Kind
			end
			
			storedTbl.StoredAmmo = 0
			storedTbl.GetIronsights = tttbase.GetIronsights
			storedTbl.IsEquipment = tttbase.IsEquipment
			storedTbl.PreDrop = tttbase.PreDrop
			storedTbl.DampenDrop = tttbase.DampenDrop
			storedTbl.Ammo1 = tttbase.Ammo1
			storedTbl.Equip = function( self )
				print( "TTT Equip" )
				tttbase.Equip( self )
			end
			storedTbl.Primary.ClipMax = storedTbl.Primary.ClipSize * 3
			storedTbl.WasBought = tttbase.WasBought
			storedTbl.DyingShot = function( ) end
			storedTbl.GetHeadshotMultiplier = function( )
				print( "got hs" )
				return 2
			end
			
			for k, ammoEntClass in pairs( PSLoadout.SpawnableAmmo or {} ) do
				local ammoTbl = scripted_ents.Get( ammoEntClass )
				if ammoTbl.AmmoType == storedTbl.Primary.Ammo then
					print( storedTbl.ClassName .. "\t" .. ammoEntClass )
					storedTbl.AmmoEnt = ammoEntClass
					break
				end
			end
			
			if ( weaponItem and not weaponItem.Model ) and storedTbl.WorldModel then
				weaponItem.Model = storedTbl.WorldModel
			end
			
			if ( weaponItem and not weaponItem.Attachments ) and storedTbl.Attachments then
				print( "No Attachments for " .. weaponItem.Name .. " copying from stored" )
				weaponItem.Attachments = {}
				for _, group in pairs( storedTbl.Attachments ) do
					for _, attachmentId in pairs( group.atts ) do
						weaponItem.Attachments[group.header] = weaponItem.Attachments[group.header] or {}
						table.insert( weaponItem.Attachments[group.header], attachmentId )
					end
				end
			end
		end
	end	
end

hook.Add( "InitPostEntity", "AssignWeaponKinds", function( )
	dp( "Running Init" )
	
	function GAMEMODE:ScalePlayerDamage( )
	end
	
	timer.Simple( 2, function( )
		initializeWeapons( )
	end )
end, 2 )
hook.Add( "OnReloaded", "asfd", function( )
	dp( "Running Init" )
	timer.Simple( 2, function( )
		initializeWeapons( )
	end )
end )

if not oldGetEyeTrace then
	local meta = FindMetaTable( "Player" )
	oldGetEyeTrace = meta.GetEyeTrace
end
hook.Add( "InitPostEntity", "fixtrace", function( )
	if engine.ActiveGamemode( ) != "terrortown" then
		return
	end
	
	local meta = FindMetaTable( "Player" )
	meta.GetEyeTrace = oldGetEyeTrace
end )