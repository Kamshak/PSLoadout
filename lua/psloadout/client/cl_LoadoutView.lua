LoadoutView = class( "LoadoutView" )
LoadoutView.static.controller = "LoadoutController" 
LoadoutView:include( BaseView )

sound.Add( 
{
 name = "hover",
 channel = CHAN_STATIC,
 volume = 0.01,
 soundlevel = 10,
 pitchstart = 100,
 pitchend = 105,
 sound = "loadout/hover.ogg"
} )

sound.Add( 
{
 name = "select",
 channel = CHAN_STATIC,
 volume = 0.01,
 soundlevel = 10,
 pitchstart = 100,
 pitchend = 105,
 sound = "loadout/select.ogg"
} )

function LoadoutView:initialize( )
	self.loadoutChangeListeners = {} --weak table for updates
	setmetatable( self.loadoutChangeListeners, { __mode = 'v' } )
	
	self.itemChangeListeners = {} --weak table for updates
	setmetatable( self.itemChangeListeners, { __mode = 'v' } )
end

function LoadoutView:getCurrentLoadout( )
	return self.loadout
end

function LoadoutView:equipLoadout( item, strType, slotId )
	self:controllerAction( "equipLoadout", strType, item.ID, slotId )
end

function LoadoutView:addLoadoutChangeListener( listener )
	table.insert( self.loadoutChangeListeners, listener )
end

function LoadoutView:addItemChangeListener( listener )
	table.insert( self.itemChangeListeners, listener )
end

function LoadoutView:receiveLoadout( loadout )
	print( "[Loadout] Received Loadout" )
	self.loadout = loadout
	
	self.loadout:loadItems( ) --make itemIds into items
	
	for k, v in pairs( self.loadoutChangeListeners ) do
		if v.loadoutChanged then
			v:loadoutChanged( self.loadout )
		end
	end
end

function LoadoutView:receiveOwnedItems( ownedItems )
	print( "[Loadout] Received Items" )
	self.ownedItems = self.ownedItems or { }
	for k, v in pairs( ownedItems ) do
		self.ownedItems[v.itemclass] = v
		
		for _, listener in pairs( self.itemChangeListeners ) do
			if listener.item and listener.item.ID == v.itemclass then
				listener:SetInvItem( v )
			end
		end
	end
end

function LoadoutView:validSubscription( itemClass )
	if not self.ownedItems then 
		return false
	end
	
	local item = self.ownedItems[itemClass]
	if not item then
		return false
	end
	
	if item:isExpired( ) then
		return false
	end
	return true
end

function LoadoutView:itemBought( item )
	self.ownedItems = self.ownedItems or {}
	self.ownedItems[item.itemclass] = item
	
	if IsValid( self.buyDialog ) then
		self.buyDialog:Remove( )
	end
	if IsValid( self.orderLoading ) then
		self.orderLoading:Remove( )
	end
	
	for k, v in pairs( self.itemChangeListeners ) do
		if v.item and v.item.ID == item.itemclass then
			v:SetInvItem( item )
		end
	end
	
	surface.PlaySound( "loadout/mp_cardslide_v6.wav" )
end

function LoadoutView:startPurchaseItem( item )
	if IsValid( self.buyDialog ) then
		self.buyDialog:Remove( )
	end
	
	self.buyDialog = vgui.Create( "KPurchaseItemPanel" )
	self.buyDialog:SetTitle( "Buy " .. item.Name )
	self.buyDialog:SetSize( 400, 300 )
	self.buyDialog:DoModal( )
	self.buyDialog:setItem( item )

	self.buyDialog:Center( )
	self.buyDialog:MakePopup( )
end

function LoadoutView:orderItem( itemId, duration, itemType )
	self:controllerAction( "buyItem", itemId, duration, itemType )
	self.orderLoading = vgui.Create( "KLoadingPanel" )
	self.orderLoading:Center( )
	self.orderLoading:MakePopup( )
	self.orderLoading:SetDrawOnTop( true )
	self.orderLoading:setText( "Performing Purchase..." )
end

function LoadoutView:getWeaponsSorted( )
	local items = {}
	for _, i in pairs( PS.Items ) do
		table.insert( items, i )
	end
	
	table.SortByMember( items, "Name", function(a, b) return a > b end )
	
	local loadoutItems = PSLoadout.getAllWeapons( )
	
	--Sub category = assault rifle, smg, lmg etc.
	--Type = Primary, Secondary
	local itemsSorted = {
		Primary = {},
		Secondary = {}
	}
	for _, item in pairs( loadoutItems ) do
		if item.Type != "Primary" and item.Type != "Secondary" then
			error( "Weapon " .. item.ID .. " has invalid type ", item.Type, " valid: Primary, Secondary" )
		end
		itemsSorted[item.Type][item.SubCategory] = itemsSorted[item.Type][item.SubCategory] or {}
		table.insert( itemsSorted[item.Type][item.SubCategory], item ) 
	end
	return itemsSorted
end

function LoadoutView:getAttachmentsSorted( )
	local items = {}
	
	for subCategoryName, attachmentTable in pairs( PS.Categories.attachments.Attachments ) do
		items[subCategoryName] = {}
		
		for attachmentKey, infoTable in pairs( attachmentTable ) do
			local ITEM = PSLoadout.getAttachment( attachmentKey )
			table.insert( items[subCategoryName], ITEM )
		end
	end
	return items
end