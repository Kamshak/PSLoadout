local PANEL = {}

function PANEL:Init( )
	self:SetTitle( "WeaponInventory" )
	
	self:SetSkin( PSLoadout.Config.DermaSkin )
	derma.SkinHook( "Layout", "PopupFrame", self )
end

function PANEL:setSlotId( slotId )
	self.slotId = slotId
end

function PANEL:onItemSelected( item )
	if self.slotType == "attachmentSlot" then
		LoadoutView:getInstance( ):equipLoadout( item.item, self.slotId )
	else
		LoadoutView:getInstance( ):equipLoadout( item.item, self.slotId )
	end
	surface.PlaySound( "loadout/mp_oldschool_pickup_01.wav" )
	self:Remove( )
end

function PANEL:setSelectionType( slotType, slotCategory )
	self.selectionType = slotCategory
	self.slotType = slotType
	
	--Grab items to show
	if slotType == "slot" then
		
		local itemsSorted = LoadoutView:getInstance( ):getWeaponsSorted( )
		self.items = {}
		for cat, items in pairs( itemsSorted[slotCategory] ) do
			for k, item in pairs( items ) do
				if LoadoutView:getInstance( ).ownedItems[item.ID] then
					self.items[cat] = self.items[cat] or {}
					table.insert( self.items[cat], item )
				end
			end
		end
		
	elseif slotType == "attachmentSlot" then
	
		local attachments = LoadoutView:getInstance( ):getAttachmentsSorted( )
		local loadout = LoadoutView:getInstance( ):getCurrentLoadout( )
		local weapon = loadout[slotCategory].weapon
		local attachmentsOnWeapon = loadout[slotCategory].attachments
		
		self.items = {}
		for cat, items in pairs( attachments ) do
			for k, attachment in pairs( items ) do
				--Ownership
				if not LoadoutView:getInstance( ).ownedItems[attachment.ID] 
				   or LoadoutView:getInstance( ).ownedItems[attachment.ID]:isExpired( ) then
					continue
				end
				
				--Can put on weapon?
				if not PSLoadout.attachmentValidForWeapon( attachment.ID, weapon ) then
					continue
				end
				
				--Compatible with other chosen attachents?
				local incompatible = false
				for slotId, attachmentOnWeapon in pairs( attachmentsOnWeapon ) do
					if attachmentOnWeapon.ID == attachment.ID then
						continue --Dont allow it twice
					end
				end
				if incompatible then
					print( attachment.ID, "incompat" )
					continue
				end
				
				self.items[cat] = self.items[cat] or {}
				table.insert( self.items[cat], attachment )
			end
		end
	else
		error( "Unknown slot type ", slotType )
	end
	
	self:displayItems( )
end

function PANEL:displayItems( )
	if table.Count( self.items ) == 0 then
		local lbl = vgui.Create( "DLabel", self )
		lbl:Dock( TOP )
		lbl:SetContentAlignment( 5 )
		lbl:SetText( "No items found" )
		lbl:SetColor( Color( 200, 0, 0 ) )
		return
	end
	
	local scroll = vgui.Create( "DScrollPanel", self )
	scroll:DockMargin( 10, 5, 20, 5 )
	scroll:Dock( FILL )
	
	self.itemsPanel = vgui.Create( "KLoadoutTypeContainer", scroll )
	self.itemsPanel:setClipTarget( scroll )
	self.itemsPanel:setTitle( "Select an item" )
	self.itemsPanel:setItems( self.items )
	function self.itemsPanel.itemClicked( pnl, item )
		self:onItemSelected( item )
	end
	self.itemsPanel:Dock( FILL )
end

function PANEL:Think( )
end

vgui.Register( "KWeaponInventory", PANEL, "DFrame" )