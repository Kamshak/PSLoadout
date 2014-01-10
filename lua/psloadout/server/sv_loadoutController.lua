LoadoutController = class( "LoadoutController" )
LoadoutController:include( BaseController )

function LoadoutController:initialize( )
end

function LoadoutController:canDoAction( ply, action )
	local def = Deferred( )
	if action == "equipLoadout" then
		def:Resolve( true )
	elseif action == "buyItem" then
		def:Resolve( true )
	--elseif action == "LoadEquipment" then
	--	def:Resolve( true )
	else
		def:Reject( false )
	end
	return def:Promise( )
end

function LoadoutController:sendOwnLoadoutToPlayer( ply )
	EquippedLoadout.findByOwner_id( ply.kPlayerId )
	:Then( function( loadout )
		self:startView( "LoadoutView", "receiveLoadout", ply, loadout )
	end )
end

function LoadoutController:equipLoadout( ply, slotId, itemId )
	local slot = PSLoadout.getSlot( slotId )
	if not slot then
		self:startView( "LoadoutView", "displayError", ply, "Invalid slot " .. slotId )
		return false 
	end
	
	local ITEM
	if slot.itemType == "attachmentSlot" then
		ITEM = PSLoadout.getAttachment( itemId )
		if not ITEM then 
			self:startView( "LoadoutView", "displayError", ply,
				"Invalid attachment " .. itemId )
			return false 
		end
		
		
	elseif slot.itemType == "slot" then
		ITEM = PS.Items[itemId]
		if not ITEM then
			if not ITEM then 
				self:startView( "LoadoutView", "displayError", ply,
					"Invalid item " .. itemId )
				return false 
			end
		end
		
		if ITEM.Type != slot.slotType then
			self:startView( "LoadoutView", "displayError", ply,
				"Item " .. itemId .. ", cant be put in this slot" )
			return false 
		end
	else
		self:startView( "LoadoutView", "displayError", ply,
			"Invalid itemType " .. slot.itemType .. " tell an admin" )
		return false 
	end
	
	LoadoutItem.getDbEntries( Format( "WHERE owner_id = %i AND itemclass = %s", ply.kPlayerId, PSLoadout.DB.SQLStr( itemId ) ) )
	:Then( function( invItem )
		--Check for item ownership
		local invItem = invItem[1]
		if not invItem or invItem:isExpired( ) then
			local def = Deferred( )
			def:Reject( 1, "You dont own this item or it expired" )
			return def:Promise( )
		end
		
		return LoadoutItem.getDbEntries( Format( "WHERE owner_id = %i AND itemclass = %s", ply.kPlayerId, PSLoadout.DB.SQLStr( slotId ) ) )
	end )
	:Then( function( items )
		--Check for slot ownership
		if not items[1] or items[1]:isExpired( ) then
			local def = Deferred( )
			def:Reject( 1, "You dont own this slot or it expired" )
			return def:Promise( )
		end
		
		return EquippedLoadout.findByOwner_id( ply.kPlayerId )
	end )
	:Then( function( loadoutTable )
		--Apply loadout changes
		
		local slotType
		if slot.itemType == "slot" then
			slotType = slot.slotType
			--Set new loadout
			loadoutTable[slot.slotType].weapon = itemId

			KLogf( 4, "Player %s equiped %s in slot %s", ply:Nick( ), ITEM.Name, slotId )
		end
		
		if slot.itemType == "attachmentSlot" then
			slotType = slot.parentSlotType
			--Set new attachment
			loadoutTable[slot.parentSlotType].attachments[slotId] = itemId
			
			--Dont allow for incompatible attachments(2x scope etc)
			--Am I incompatible with any previous attachments?
			local attachments = loadoutTable[slot.parentSlotType].attachments
			for _slot, attachmentId2 in pairs( attachments ) do
				if attachmentId2 == self then
					return
				end
				local cstmAttachmentTable = CWAttachments[attachmentId2]
				if table.HasValue( cstmAttachmentTable.incompability or {}, itemId ) then
					print( itemId, "Incompat", attachmentId2 )
					attachments[_slot] = nil --Yes, remove other from list
				end
			end
			
			KLogf( 4, "Player %s equiped %s in slot %s", ply:Nick( ), ITEM.Name, slotId )
		end
		
		--Validate attachments
		local attachments = loadoutTable[slotType].attachments
		local weapon = PS.Items[loadoutTable[slotType].weapon]
		
		
		local attachmentsHandled = {}
		for slot, attachmentId in pairs( attachments ) do
			if not PSLoadout.attachmentValidForWeapon( attachmentId, weapon ) then
				attachments[slot] = nil
				continue
			end
			
			--Attachment check again to be sure
			for _slot, attachmentId2 in pairs( attachments ) do
				if attachmentId2 == self then
					return
				end
				local cstmAttachmentTable = CWAttachments[attachmentId2]
				if table.HasValue( cstmAttachmentTable.incompability or {}, attachmentId ) then
					print( attachmentId, "Incompat", attachmentId2 )
					attachments[_slot] = nil --Yes, remove other from list
				end
			end
			
			--Prevent having the same attachment twice on a weapon
			if table.HasValue( attachmentsHandled, attachmentId ) then
				attachments[slot] = nil
				continue
			end
			
			table.insert( attachmentsHandled, attachmentId )
		end
		
		return loadoutTable:save( )
	end )
	:Then( function( )
		--Send changes to player
		self:sendOwnLoadoutToPlayer( ply )
	end, function( errid, err )
		self:reportError( "LoadoutView", ply, "Error changing loadout", errid, err )
	end )
end

function LoadoutController:buyItem( ply, itemId, duration, itemType, bExtend )
	--DEFAULT: WEAPON
	local ITEM = PS.Items[itemId]
	
	--ATTACHMENT
	if itemType == "attachment" then
		ITEM = PSLoadout.getAttachment( itemId )
		if not ITEM then
			self:startView( "LoadoutView", "displayError", ply,
			"Invalid attachment " .. itemId )
			return false
		end
	end
	
	--SLOT
	if itemType == "slot" or itemType == "attachmentSlot" then
		ITEM = PSLoadout.getSlot( itemId )
		
		if not ITEM then
			self:startView( "LoadoutView", "displayError", ply,
				"Invalid slot " .. itemId )
			return false 
		end
	end
	
	if not ITEM then 
		self:startView( "LoadoutView", "displayError", ply,
				"Invalid item " .. itemId )
		return false 
	end
	
	local points = ITEM.Price
	if type( points ) == "table" then
		if duration then
			points = points[duration]
		end
		if not points then
			self:startView( "LoadoutView", "displayError", ply,
				"Invalid subscription duration " .. tostring( duration ) )
			return
		end
	end
	
	if not ply:PS_HasPoints( points ) then
		self:startView( "LoadoutView", "displayError", ply,
			"You cannot afford this item" )
		return
	end

	ply:PS_TakePoints( points )

	LoadoutItem.getDbEntries( 
		string.format( "WHERE itemclass = %s AND owner_id = %i", 
			PSLoadout.DB.SQLStr( itemId ), 
			ply.kPlayerId )
	)
	:Then( function( resultSet )
		ownedItem = resultSet[1]
		
		--If user does not want to extend the purchase and owns the item, bail
		--maybe a sync error is happening, a check to be sure
		if ownedItem 
			and not bExtend 
			and not ownedItem:isExpired( ) 
		then
			local def = Deferred( )
			def:Reject( 1, "Item already owned" )
			return def:Promise( )
		end
		
		local invItem
		if ownedItem then
			invItem = ownedItem
		else
			invItem = LoadoutItem:new( )
			invItem.owner_id = ply.kPlayerId
			invItem.itemclass = itemId
			
			invItem.txnId = txnId or -1
		end
		
		if duration and duration > 0 then
			if bExtend then
				invItem.expirationTime = invItem.expirationTime 
					+ duration * 60 * 60 * 24
			else
				if duration and duration > 0 then
					invItem.expirationTime = os.time( ) 
						+ duration * 60 * 60 * 24
				else
					invItem.expirationTime = 0
				end
			end
		else
			invItem.expirationTime = 0
		end
		
		return invItem:save( )
	end )
	:Then( function( item )
		self:startView( "LoadoutView", "itemBought", ply, item )
	end )
	:Fail( function( errid, err )
		self:reportError( "LoadoutView", ply, "Error performing transaction", errid, err )
		ply:PS_GivePoints( points ) --Error, refund points
	end )
	:Done( function( )
		if bExtend then
			KLogf( 4, 
				"Player %s extended their subscription of %s for %i days",
				ply:Nick( ),
				ITEM.Name,
				duration or 0
			)
		else
			KLogf( 4, 
				"Player %s bought a subscription of %s for %i days",
				ply:Nick( ),
				ITEM.Name,
				duration or 0
			)
		end
	end )
end

function LoadoutController:playerInitialSpawn( ply, instant )
	EquippedLoadout.findByOwner_id( ply.kPlayerId )
	:Done( function( loadout )
		if not loadout then
			local loadout = EquippedLoadout:new( )
			loadout.owner_id = ply.kPlayerId
			loadout.primaryWeapon = ""
			loadout.primaryAttachments = util.TableToJSON( {} ) 
			loadout.secondaryWeapon = ""
			loadout.secondaryAttachments = util.TableToJSON( {} ) 
			loadout.perk = ""
			loadout:save( )
			
			KLogf( 4, "[Loadout] Loadout entry for %s created", ply:Nick( ) )
			
			--Give default items
			for itemId, duration in pairs( PSLoadout.Config.PreOwnedItems ) do
				local item = LoadoutItem:new( )
				item.owner_id = ply.kPlayerId
				item.itemclass = itemId
				if duration and duration > 0 then
					item.expirationTime = os.time( ) + duration * 60 * 60 * 24
				else
					item.expirationTime = 0
				end
				item.txnId = txnId or -2
				item:save( )
				:Then( function( item )
					KLogf( 4, "Gave %s default item %s", ply:Nick( ), itemId )
				end, function( errid, err )
					KLogf( 4, "Error giving %s default item %s. %i: %s", ply:Nick( ), itemId, errid, err )
				end )
			end
		end
	end )
	
	--If you send too early the message doesnt get through... CL_LuaInit wasnt callled
	timer.Simple( instant and 0 or 2, function( )
		self:sendOwnLoadoutToPlayer( ply )
		LoadoutItem.clearExpiredItems( ply ) 
		:Then( function( )
			return LoadoutItem.findAllByOwner_id( ply.kPlayerId )
		end )
		:Then( function( items )
			self:startView( "LoadoutView", "receiveOwnedItems", ply, items )
		end )
	end )
end
hook.Add( "LibK_PlayerInitialSpawn", "LoadLoadout", function( ply )
	LoadoutController:getInstance( ):playerInitialSpawn( ply )
end )
hook.Add( "OnReloaded", "LoadLoadout", function( )
	timer.Simple( 2, function( )
		for k, ply in pairs( player.GetAll( ) ) do
			LoadoutController:getInstance( ):playerInitialSpawn( ply, true )
		end
	end )
end )

function LoadoutController:playerSpawn( ply )
	if not ply.kPlayerId then
		--Try again when he is 
		hook.Add( "LibK_PlayerInitialSpawn", "LoadoutInitial" .. ply:Nick( ), function( )
			hook.Remove( "LibK_PlayerInitialSpawn", "LoadoutInitial" .. ply:Nick( ) )
			LoadoutController:playerSpawn( ply )
		end )
		return
	end
	
	EquippedLoadout.findByOwner_id( ply.kPlayerId )
	:Then( function( loadout )
		if not loadout then
			timer.Simple( 1, function( )
				LoadoutController:getInstance( ):playerSpawn( ply )
			end )
			local def = Deferred( )
			def:Reject( -1, "Sync error, no loadout found, will retry in 1s" )
			return def:Promise( )
		end
		loadout:loadItems( )

		return loadout:removeExpired( ply )
		:Then( function( )
			return EquippedLoadout.findByOwner_id( ply.kPlayerId )
		end )
	end )
	:Then( function( loadout )
		if not ply:Alive( ) or ( ply.IsSpec and ply:IsSpec( ) ) then
			return
		end
		
		loadout:loadItems( )
		for slotType, category in pairs( loadout ) do
			if table.HasValue( EquippedLoadout.slotTypes, slotType ) then
				local weaponItem = category.weapon
				if not weaponItem then 
					continue 
				end
				
				--Strip Weapons of the same kind(TTT Weapon carry limitations)
				local swepTable = weapons.Get( weaponItem.WeaponClass )
				for k, w in pairs( ply:GetWeapons( ) ) do
					if w.Kind and w.Kind == swepTable.Kind then
						ply:StripWeapon( w:GetClass( ) )
					end
				end
				
				ply:Give( weaponItem.WeaponClass )
				local weapon = ply:GetWeapon( weaponItem.WeaponClass )
				if not ply:HasWeapon( weaponItem.WeaponClass ) or not weapon then
					KLogf( 2, "[Loadout] Couldn't give player %s his loadout %s!", ply:Nick( ), weaponItem.WeaponClass )
					continue
				end
				
				timer.Simple( 2, function( )
					for slot, attachment in pairs( category.attachments ) do
						timer.Simple( 1, function( )
							weapon:K_AddAttachment( attachment.cstmAttachmentNum )
						end )
						KLogf( 4, "[Loadout] Attachment %s added to %s", attachment.Name, weaponItem.Name )
					end
				end )
			end
		end
	end, function( errid, err )
		KLogf( 3, "Error loading loadout for %s(%i), code %i error was %s", ply:Nick( ), ply.kPlayerId, errid, err )
	end )
	
	--block:
	--cstm_requestpimp
	
	--DTInt 1 == scoped
	--dtint 19 == in cstm menu
end
hook.Add( "PlayerSpawn", "GivePlayerLoadout", function( ply )
	LoadoutController:getInstance( ):playerSpawn( ply )
end, -1 )

hook.Add( "Think", "RemoveCstmBind", function( )
	hook.Remove( "PlayerBindPress", "SWEP.PlayerBindPress (CSTM)" )
	concommand.Remove( "cstm_requestpimp" )
	concommand.Remove( "cstm_pimpmygun" )
	concommand.Remove( "cstm_unpimpmygun" )
	concommand.Remove( "cstm_addswag" )
	concommand.Remove( "cstm_removeswag" )
	concommand.Remove( "cstm_selectammo" )
	concommand.Remove( "cstm_deselectammo" )
end )