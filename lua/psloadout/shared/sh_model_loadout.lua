EquippedLoadout = class( "EquippedLoadout" )
PSLoadout.EquippedLoadout = EquippedLoadout

EquippedLoadout.static.DB = "PSLoadout"
EquippedLoadout.static.slotTypes = {
	"Primary",
	"Secondary"
}
EquippedLoadout.static.model = {
	tableName = "psl_loadouts",
	fields = {
		owner_id = "int",
		primaryWeapon = "string",
		primaryAttachments = "text", --json
		secondaryWeapon = "string",
		secondaryAttachments = "text",
		perk = "string"
	},
	/*belongsTo = {
		Owner = {
			class = "KPlayer",
			foreignKey = "owner_id"
		},
	}*/
}
EquippedLoadout:include( DatabaseModel )

function EquippedLoadout:preSave( )
	if not self.primaryWeapon then
		self.primaryWeapon = self.Primary.weapon or ""
	end
	if not self.secondaryWeapon then
		self.secondaryWeapon = self.Secondary.weapon or ""
	end
	
	if not self.primaryAttachments then
		self.primaryAttachments = util.TableToJSON( self.Primary.attachments )
	end
	if not self.secondaryAttachments then
		self.secondaryAttachments = util.TableToJSON( self.Secondary.attachments )
	end
	
	if not self.perk then
		self.perk = self.Perk.ID
	end
	
	local def = Deferred( )
	def:Resolve( )
	return def:Promise( )
end

--Transform into nice stuff for lua
function EquippedLoadout:postLoad( )
	local def = Deferred( )
	
	self.Primary = {}
	self.Primary.weapon = self.primaryWeapon
	self.Primary.attachments = util.JSONToTable( self.primaryAttachments )
	self.primaryWeapon = nil
	self.primaryAttachments = nil
	
	self.Secondary = {}
	self.Secondary.weapon = self.secondaryWeapon
	self.Secondary.attachments = util.JSONToTable( self.secondaryAttachments )
	self.secondaryWeapon = nil
	self.secondaryAttachments = nil
	
	--Todo: perk items
	self.Perk =  PS.Items[self.perk]
	
	def:Resolve( )
	return def:Promise( )
end

function EquippedLoadout:removeExpired( )
	local def = Deferred( )
	
	local plyId = self.owner_id
	local ply
	for k, v in pairs( player.GetAll( ) ) do
		if tonumber( v.kPlayerId ) == tonumber( plyId ) then
			ply = v
		end
	end
	
	self:loadItems( )
	
	--Get all owned items instances
	return LoadoutItem.findAllByOwner_id( plyId )
	:Then( function( ownedItems ) 
		--Lookup List for owned Items
		local ownedItemsAssoc = {}
		for _, v in pairs( ownedItems ) do
			ownedItemsAssoc[v.itemclass] = v
		end
		
		--Check loadout for expired items
		local updated = false
		for k, slotType in pairs( EquippedLoadout.slotTypes ) do
			local category = self[slotType]
			
			local weaponId = category.weapon and category.weapon.ID
			if weaponId and weaponId != ""  then
				local weapon = ownedItemsAssoc[weaponId]
				--Clear deleted/sold/expired weapon
				if not ownedItemsAssoc[weaponId] or ( ownedItemsAssoc[weaponId] and ownedItemsAssoc[weaponId]:isExpired( ) ) then
					KLogf( 4, "%s: removed weapon %s, expired or removed", ply:Nick( ), weaponId )
					category.weapon = nil
					updated = true
				end
			end
			
			for slotId, attachment in pairs( category.attachments or {} ) do
				if not attachment then continue end
				
				--remove delete/sold/expired attachments
				if not ownedItemsAssoc[attachment.ID] or ( ownedItemsAssoc[attachment.ID] and ownedItemsAssoc[attachmentId]:isExpired( ) ) then
					category.attachments[slotId] = nil
					updated = true
					KLogf( 4, "%s: removed attachment %s, expired or removed", ply:Nick( ), attachment.ID )
					continue
				end
				
				--Remove attachments from slots that player doesnt have access to anymore
				local slot = PSLoadout.getSlot( slotId )
				if slot.Ranks and not table.HasValue( slot.Ranks, ply:PS_GetUsergroup( ) ) then
					KLogf( 4, "%s: removed attachment %s, insufficient privileges", ply:Nick( ), attachment.Name )
					category.attachments[slotId] = nil
					updated = true
				end
			end
		end
		
		if updated then
			return self:save( )
		end
		return self
	end )
end

--Called on client after receiving, resolves the itemIds into items
function EquippedLoadout:loadItems( )
	for slotType, category in pairs( self ) do
		if table.HasValue( EquippedLoadout.slotTypes, slotType ) then
			category.weapon = PS.Items[category.weapon]
			for k, itemId in pairs( category.attachments ) do
				category.attachments[k] = PSLoadout.getAttachment( itemId )
			end
		end
	end
end

function EquippedLoadout:getLoadoutSlots( )
	local slots = {}
	for slotType, category in pairs( self ) do
		if table.HasValue( EquippedLoadout.slotTypes, slotType ) then
			slots[slotType] = category
		end
	end
end