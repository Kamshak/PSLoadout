local PANEL = {}
Derma_Hook( PANEL, "Paint", "Paint", "ItemBackground" )

function PANEL:Init( )
	self:SetSize( 80, 80 )
	
	self.modelPanel = vgui.Create( "DModelPanel", self )
	self.modelPanel:SetSize( 80, 80 )
	function self.modelPanel:LayoutEntity( ent )
		self:SetCamPos( Vector( 20, 20, 20 ) )
		self:SetLookAt( ent:GetPos( ) + Vector( 0, 0, 5 ) )
		if self.Hovered then
			ent:SetAngles( ent:GetAngles( ) + Angle( 0, FrameTime() * 50,  0) )
		end
	end	
	self.modelPanel:Dock( FILL )
	self.modelPanel.weaponIcon = self
	local oldPaint = self.modelPanel.Paint
	function self.modelPanel:Paint( w, h )
		local pnl = self.clipTarget or self:GetParent()
		local x2, y2 = pnl:LocalToScreen( 0, 0 )
		local w2, h2 = pnl:GetSize()
		render.SetScissorRect( x2, y2, x2 + w2, y2 + h2, true )
		
		oldPaint( self )
		
		render.SetScissorRect( 0, 0, 0, 0, false )
	end
	
	LoadoutView:getInstance( ):addItemChangeListener( self )
	self:SetSkin( PSLoadout.Config.DermaSkin )
end

function PANEL:setClipTarget( target )
	self.clipTarget = target
	self.modelPanel.clipTarget = target
end

function PANEL:setItem( item )
	self.item = item
	if IsValid( self.itemNameLabel ) then
		self.itemNameLabel:Remove( )
	end
	if item.Model then
		self.modelPanel:SetModel( item.Model or "models/props/cs_office/cardboard_box03.mdl" )
	elseif item.TextureId then
		self.modelPanel:Remove( )
		self.modelPanel = vgui.Create( "DImage", self )
		self.modelPanel:Dock( FILL )
		function self.modelPanel:Paint( w, h )
			surface.SetTexture( item.TextureId )
			surface.SetDrawColor( color_white )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		self.modelPanel.weaponIcon = self
		self.weaponIcon = self
	end
	self.itemNameLabel = vgui.Create( "DLabel", self.modelPanel )
	self.itemNameLabel:Dock( TOP )
	if item.TextureId then
		self.itemNameLabel:SetColor( Color( 255, 255, 255 ) )
		function self.itemNameLabel:Paint( w, h )
			draw.SimpleText( self:GetText( ), self:GetFont( ), w / 2 + 0.5, h / 2 + 0.5, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( self:GetText( ), self:GetFont( ), w / 2 + 1, h / 2 + 1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	else
		self.itemNameLabel:SetColor( Color( 0, 0, 0 ) )
	end
	self.itemNameLabel:SetContentAlignment( 5 )
	self.itemNameLabel:SetText( item.ShortName or item.Name )
	self.modelPanel.OnMousePressed = function( p, m ) self:OnMousePressed( m ) end
	
	if item.Ranks then
		local star = vgui.Create( "DImage", self.modelPanel )
		star:SetImage( "icon16/star.png" )
		star:SizeToContents( )
		function star.PerformLayout( )
			star:SetPos( self.modelPanel:GetWide( ) - star:GetWide( ) - 5, self.modelPanel:GetTall( ) - star:GetTall( ) - 5 )
		end
	end
	
	local ownedItems = LoadoutView:getInstance( ).ownedItems
	if ownedItems and ownedItems[item.ID] then
		self:SetInvItem( ownedItems[item.ID] )
	end
end

function PANEL:SetInvItem( invItem )
	if invItem.itemclass != self.item.ID then
		return
	end
	self.invItem = invItem
	if not IsValid( self.ownedLabel ) and not self.hideOwned then
		self.ownedLabel = vgui.Create( "DLabel", self.modelPanel )
		self.ownedLabel:Dock( BOTTOM )
		
		self.ownedLabel:SetContentAlignment( 5 )
		self.ownedLabel:SetFont( "PS_Heading3" )
		function self.ownedLabel:Paint( w, h )
			derma.SkinHook( "Paint", "ItemOwnedBackground", self, w, h )
		end
		function self.ownedLabel:Think( )
			if invItem:isExpired( ) then
				self:SetText( "Expired" )
				self:SetColor( Color( 200, 0, 0 ) )
			else
				if invItem.expirationTime == 0 then
					self:SetColor( Color( 0, 255, 0 ) )
				elseif invItem.expirationTime > os.time( ) then
					self:SetColor( Color( 20, 200, 0 ) )
				end
				self:SetText( "Owned" )
			end
		end
	end
end

function PANEL:Think( )
end

function PANEL:getHoverPanel( )
	if not self.item then 
		return
	end

	local panel = vgui.Create( "KItemDescriptionPanel" )
	panel:setItem( self.item )
	panel:SetWide( 300 )
	
	if self.item.Attachments then
		local validAttachmentsPanel = vgui.Create( "KItemCategory", panel )
		validAttachmentsPanel:setTitle( "Usable Attachments" )
		local items = {}
		for rail, attachmentsTable in pairs( self.item.Attachments ) do
			for k, attachmentKey in pairs( attachmentsTable ) do
				local ITEM = PSLoadout.getAttachment( attachmentKey )
				table.insert( items, ITEM )
			end
		end
		validAttachmentsPanel:SetIconSize( 60 )
		validAttachmentsPanel:setItems( items )
		validAttachmentsPanel:Dock( TOP )
	end
	
	if self.invItem and not self.invItem:isExpired( ) then
		local ownedLbl = vgui.Create( "DLabel", panel )
		ownedLbl:SetFont( "PS_Heading3" )
		ownedLbl:DockMargin( 10, 10, 10, 10 )
		ownedLbl:Dock( TOP )
		if self.invItem:isPermanent( ) then
			ownedLbl:SetText( "Owned(permanently)" )
			ownedLbl:SetColor( Color( 0, 255, 0 ) )
		elseif self.invItem:isExpired( ) then
			ownedLbl:SetText( "Expired" )
			ownedLbl:SetColor( Color( 200, 0, 0 ) )
		else
			ownedLbl:SetText( "Owned, " .. self.invItem:getTimeLeftString( ) .. " left" )
			ownedLbl:SetColor( Color( 0, 200, 0 ) )
		end
	end
	
	if not self.invItem or self.invItem:isExpired( ) then
		if type( self.item.Price ) == "table" then
			local pricesPanel = vgui.Create( "KShowPricePanel", panel )
			pricesPanel:DockMargin( 10, 10, 10, 10 )
			pricesPanel:Dock( TOP )
			pricesPanel:setItem( self.item )
		else
			local priceLabel = vgui.Create( "DLabel", panel )
			priceLabel:SetFont( "PS_Heading3" )
			priceLabel:DockMargin( 10, 10, 10, 10 )
			priceLabel:SetText( "Price: " .. self.item.Price .. ( PS.Config.Currency or "pts" ) )
			priceLabel:Dock( TOP )
			function priceLabel.Think( )
				if LocalPlayer():PS_HasPoints( self.item.Price ) then
					priceLabel:SetColor( Color( 0, 200, 0 ) )
				else
					priceLabel:SetColor( Color( 200, 0, 0 ) )
				end
			end
		end
	end
	
	return panel
end
vgui.Register( "KItemIcon", PANEL, "DPanel" )

local PANEL = {}

Derma_Hook( PANEL, "Paint", "Paint", "PricesPanel" )

function PANEL:Init( )
	self:DockPadding( 5, 5, 5, 5 )
	self.titleLabel = vgui.Create( "DLabel", self )
	self.titleLabel:Dock( TOP )
	self.titleLabel:SetFont( "PS_Heading2" )
	self.titleLabel:SetText( "Prices" )
	
	self.pnls = {}
end

function PANEL:showBuyButtons( )
	self.shouldShowBuyButtons = true
end

local descTrans = {
	[1] = "One Day",
	[7] = "One Week", 
	[30] = "One Month",
	[0] = "Permanent"
}
function PANEL:setItem( item )
	for len, price in pairs( item.Price ) do
		local pnl = vgui.Create( "DPanel", self )
		function pnl:Paint( w, h )
		end
		pnl:DockMargin( 0, 5, 0, 0 )
		pnl:Dock( TOP )
		function pnl:Think( )
			if LocalPlayer():PS_HasPoints( price ) then
				if self.buyBtn then
					self.buyBtn:SetText( "Purchase" )
					self.buyBtn:SetColor( Color( 0, 200, 0 ) )
				end
				self.priceLbl:SetColor( Color( 0, 200, 0 ) )
			else
				if self.buyBtn then
					self.buyBtn:SetText( "Can't afford" )
					self.buyBtn:SetColor( Color( 200, 0, 0 ) )
				end
				self.priceLbl:SetColor( Color( 200, 0, 0 ) )
			end
		end
		
		pnl.lenName = vgui.Create( "DLabel", pnl ) 
		pnl.lenName:SetText( descTrans[len] .. ": " )
		pnl.lenName:SetFont( "PS_Heading3" )
		pnl.lenName:Dock( LEFT )
		pnl.lenName:DockMargin( 0, 0, 10, 0 )
		pnl.lenName:SizeToContents( )
		
		pnl.priceLbl = vgui.Create( "DLabel", pnl )
		pnl.priceLbl:SetText( price .. PS.Config.Currency or "pts" )
		pnl.priceLbl:SetFont( "PS_Heading3" )
		pnl.priceLbl:Dock( LEFT )
		
		if self.shouldShowBuyButtons then
			pnl.buyBtn = vgui.Create( "DButton", pnl )
			pnl.buyBtn:SetText( "Purchase" )
			pnl.buyBtn:SetFont( "PS_Heading3" )
			pnl.buyBtn:Dock( LEFT )
			function pnl.buyBtn.DoClick( ) 
				if LocalPlayer():PS_HasPoints( price ) then
					self:buyOrder( len )
				end
			end
		end
		
		table.insert( self.pnls, pnl )
	end
end

function PANEL:PerformLayout( )
	local maxW = 0
	for k, v in pairs( self.pnls ) do
		v.lenName:SizeToContents( )
		maxW = math.max( maxW, v.lenName:GetWide( ) )
	end

	for k, v in pairs( self.pnls ) do
		v.lenName:SetWide( maxW )
		v.priceLbl:SetWide( v:GetWide( ) - v.lenName:GetWide( ) - 10 )
		if v.buyBtn then
			v.buyBtn:SizeToContents( )
			v.priceLbl:SetWide( v.priceLbl:GetWide( ) - v.buyBtn:GetWide( ) - 30 )
			v.buyBtn:SetWide( v:GetWide( ) - v.lenName:GetWide( ) - 10 - v.priceLbl:GetWide( ) )
		end
	end

	self:SizeToChildren( false, true )
end

vgui.Register( "KShowPricePanel", PANEL, "DPanel" )