local PANEL = {}

function PANEL:Init( )
	self:DockPadding( 5, 5, 5, 5 )
	self:SetWide( 500 )
	--self:SetTall( 300 )
	
	self.heading = vgui.Create( "DLabel", self )
	self.heading:Dock( TOP )
	self.heading:SetFont( "PS_Heading2" )
	self.heading:SetColor( color_white )
	self.heading:DockMargin( 0, 0, 0, 10 )
	self.heading:SetText( "My Loadout" )
	self.heading:SizeToContents( )
	
	self.bottomPanel = vgui.Create( "DPanel", self )
	self.bottomPanel:Dock( FILL )
	function self.bottomPanel.PerformLayout( panel )
		self.primariesPanel:PerformLayout( )
		self.secondariesPanel:PerformLayout( )
		panel:SizeToChildren( false, true )
	end
	self.bottomPanel.Paint = function( ) end
	
	self.primariesPanel = vgui.Create( "KLoadoutSelectSubPanel", self.bottomPanel )
	self.primariesPanel:setSlotInfo( PS.Categories.loadout.LoadoutSettings.Primary, "Primary" )
	self.primariesPanel:Dock( LEFT )
	
	self.secondariesPanel = vgui.Create( "KLoadoutSelectSubPanel", self.bottomPanel )
	self.secondariesPanel:setSlotInfo( PS.Categories.loadout.LoadoutSettings.Secondary, "Secondary" )
	self.secondariesPanel:Dock( RIGHT )
end

function PANEL:PerformLayout( )
	--self.primariesPanel:SetWide( self:GetWide( ) / 2 - 7 )
	--self.primariesPanel:SizeToChildren( false, true )
	
	--self.secondariesPanel:SetWide( self:GetWide( ) / 2 - 7 )
	--self.secondariesPanel:SizeToChildren( false, true )
	
	--local x, y = self.primariesPanel:GetPos( )
	--self:SetTall( self.primariesPanel:GetTall( ) + y )
	self.bottomPanel:SetTall( 1000 )
	self.primariesPanel:SetWide( 500 )
	self.secondariesPanel:SetWide( 500 )
	self.bottomPanel:PerformLayout( )
	self:SizeToChildren( false, true )
end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanel" )
vgui.Register( "KLoadoutSelectPanel", PANEL, "DPanel" )

local PANEL = {}

function PANEL:Init( )
	self.weaponPanel = vgui.Create( "DPanel", self )
	self.weaponPanel:Dock( TOP )
	self.weaponPanel:DockPadding( 10, 0, 0, 10 )
	self.weaponPanel.Paint = function( p, w, h )
		--surface.SetDrawColor( 255,200 ,0 )
		--surface.DrawRect( 0, 0, w, h )
	end
	function self.weaponPanel.PerformLayout( panel )
		panel:SizeToChildren( false, true )
	end
	
	self.slotTitle = vgui.Create( "DLabel", self.weaponPanel )
	self.slotTitle:Dock( TOP )
	self.slotTitle:SetColor( color_white )
	self.slotTitle:SetFont( "PS_Heading2" )
	self.slotTitle:SetContentAlignment( 5 )
	self.slotTitle:DockMargin( 5, 0, 5, 5 )
	
	self.weaponSelectPanel = vgui.Create( "KItemSelectPanel", self.weaponPanel )
	self.weaponSelectPanel:Dock( TOP )
	
	self.attachmentPanel = vgui.Create( "DPanel", self )
	self.attachmentPanel:Dock( TOP )
	self.attachmentPanel.Paint = function( ) end
	function self.attachmentPanel.PerformLayout( panel )
		panel:SetWide( 1000 )
		self.attachmentSlotsTitle:SizeToContents( )
		panel:SetWide( self.attachmentSlotsTitle:GetWide( ) + 40 )
		self.attachmentSlotLayout:PerformLayout( )
		if ( self.attachmentSlotLayout:GetWide( ) + 40 ) > panel:GetWide( ) then
			panel:SetWide( self.attachmentSlotLayout:GetWide( ) + 40 )
			self.attachmentSlotLayout:PerformLayout( )
		end
		panel:SizeToChildren( false, true )
	end
	
	self.attachmentSlotsTitle = vgui.Create( "DLabel", self.attachmentPanel )
	self.attachmentSlotsTitle:Dock( TOP )
	self.attachmentSlotsTitle:SetColor( color_white )
	self.attachmentSlotsTitle:SetFont( "PS_Heading2" )
	self.attachmentSlotsTitle:SetContentAlignment( 5 )
	self.attachmentSlotsTitle:DockMargin( 5, 0, 5, 10 )
	
	self.attachmentSlotLayout = vgui.Create( "DIconLayout", self.attachmentPanel )
	self.attachmentSlotLayout:Dock( FILL )
	self.attachmentSlotLayout:DockMargin( 5, 0, 5, 10 )
	self.attachmentSlotLayout:SetSpaceX( 10 )
	local op = self.attachmentSlotLayout.PerformLayout
	function self.attachmentSlotLayout:PerformLayout( )
		self:SetWide( 460 )
		op( self )
		self:SizeToChildren( true, true )
		
		local space = self:GetParent( ):GetWide( ) - self:GetWide( )
		self:DockMargin( space / 2, 0, space / 2, 0 )
	end
end

function PANEL:PerformLayout( )
	--Let panels set themselves to required min size
	self.weaponSelectPanel:PerformLayout( )
	self.weaponPanel:PerformLayout( )
	self.attachmentPanel:PerformLayout( )
	
	--Center weaponselectpanel
	local space = self.weaponPanel:GetWide( ) - self.weaponSelectPanel:GetWide( )
	self.weaponSelectPanel:DockMargin( space / 2, 0, space / 2, 0 )
	
	local x, y = self.attachmentSlotLayout:GetPos( )
	self:SetTall( y + self.attachmentSlotLayout:GetTall( ) + 15 )
	self:SizeToChildren( true, true )
	self:SetTall( self:GetTall( ) + 5 )
end

function PANEL:setSlotInfo( tblSlotInfo, slotType )
	self.slotInfo = tblSlotInfo
	self.slotInfo.itemType = "slot"
	self.slotInfo.slotType = slotType
	
	self.slotTitle:SetText( tblSlotInfo.Name )
	self.slotTitle:SizeToContents( )
	
	self.attachmentSlotsTitle:SetText( tblSlotInfo.AttachmentsName )
	self.attachmentSlotsTitle:SizeToContents( )
	
	self.weaponSelectPanel:setSlotInfo( tblSlotInfo )
	
	self:PerformLayout( )
	
	for k, v in ipairs( tblSlotInfo.attachmentSlots ) do
		local attachmentPanel = self.attachmentSlotLayout:Add( "KItemSelectPanel" )
		v.itemType = "attachmentSlot"
		v.TextureId = surface.GetTextureID( "vgui/white" )
		v.parentSlotType = self.slotInfo.slotType
		attachmentPanel:setSlotInfo( v )
	end
end

Derma_Hook( PANEL, "Paint", "Paint", "DetailPanel" )

vgui.Register( "KLoadoutSelectSubPanel", PANEL, "DPanel" )

local PANEL = {}

function PANEL:Init( )
	self.itemIcon = vgui.Create( "KItemIcon", self )
	self.itemIcon:SetSize( 64, 64 )
	self.itemIcon:Dock( TOP )
	self.itemIcon.hideOwned = true
	
	self.changeButton = vgui.Create( "DButton", self )
	self.changeButton:SetText( "Buy Slot" )
	self.changeButton:Dock( TOP )
	self.changeButton:DockMargin( 0, 5, 0, 0 )
	function self.changeButton.DoClick( )
		self:changeButtonClicked( )
	end
	
	LoadoutView:getInstance( ):addLoadoutChangeListener( self )
end

function PANEL:loadoutChanged( newLoadout )
	self:updateIcon( )
end

--Update icon and button depending on current loadout
function PANEL:updateIcon( )
	local loadout = LoadoutView:getInstance( ):getCurrentLoadout( )
	if not loadout then
		print( "Couldnt update, no loadout info present!" )
		return 
	end
	
	if self.slotInfo.itemType == "slot" then
	
		local equippedWeapon = loadout[self.slotInfo.slotType].weapon 
		self.itemIcon:setItem( equippedWeapon or self.slotInfo )
		
	elseif self.slotInfo.itemType == "attachmentSlot" then
	
		local loadoutInfo = loadout[self.slotInfo.parentSlotType]
		self.itemIcon:setItem( loadoutInfo.attachments[self.slotInfo.ID] or self.slotInfo )
		
	else
		error( "Invalid slot type " .. tostring( self.slotInfo.slotType ) )
	end
end

function PANEL:PerformLayout( )
	self:SetWide( 64 )
	self:SizeToChildren( false, true )
end

function PANEL:changeButtonClicked( )
	sound.Play( "select", LocalPlayer( ):GetPos( ) )
	if self.itemIcon.invItem then
		
		--Open inv select
		local changePanel = vgui.Create( "KWeaponInventory" )
		if self.slotInfo.itemType == "slot" then
			changePanel:setSelectionType( self.slotInfo.itemType, self.slotInfo.ShortName ) 
		else
			changePanel:setSelectionType( self.slotInfo.itemType, self.slotInfo.parentSlotType ) 
		end
		changePanel:setSlotId( self.slotInfo.ID )
		changePanel:SetSize( 500, 400 )
		changePanel:Center( )
		changePanel:MakePopup( )
		--changePanel:SetDrawOnTop( true )
	else
		LoadoutView:getInstance( ):startPurchaseItem( self.slotInfo )
	end
end

function PANEL:Think( )
	if not self.slotInfo then return end
	
	if self.itemIcon.invItem then
		self.changeButton:SetText( "Select" )
	else
		if self.slotInfo.Ranks then
			if table.HasValue( self.slotInfo.Ranks, LocalPlayer( ):PS_GetUsergroup( ) ) then
				self.changeButton:SetText( "Unlock Slot" )
			else
				self.changeButton:SetVisible( false )
			end
		else
			self.changeButton:SetText( "Unlock Slot" )
		end
	end
end

function PANEL:setSlotInfo( slotInfo )
	self.slotInfo = slotInfo
	self.itemIcon:setItem( slotInfo )
	
	self:updateIcon( )
end

function PANEL:Paint( w, h )
end
vgui.Register( "KItemSelectPanel", PANEL, "DPanel" )

--TODO: Recode this shit.
--Simple model: slot -> item,
--slot has it's own validation function depending on type
--fuck! should have done this earlier