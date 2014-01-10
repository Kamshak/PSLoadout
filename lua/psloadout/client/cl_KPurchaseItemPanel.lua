local PANEL = {}

function PANEL:Init( )
	self.container = vgui.Create( "DPanel", self )
	self.container:Dock( FILL )
	self.container:DockPadding( 10, 10, 10, 10 )
	Derma_Hook( self.container, "Paint", "Paint", "InnerPanel" )

	self.topPnl = vgui.Create( "DPanel", self.container )
	self.topPnl:Dock( TOP )
	self.topPnl:DockMargin( 0, 0, 0, 5 )
	function self.topPnl:Paint( w, h )
	end
	self:SetDrawOnTop( true )
	
	self:SetSkin( PSLoadout.Config.DermaSkin )
	derma.SkinHook( "Layout", "PopupFrame", self )
end

function PANEL:setItem( item )
	self.item = item
	if item.Model then
		self.modelPanel = vgui.Create( "DModelPanel", self.topPnl )
		self.modelPanel:SetSize( 80, 80 )
		function self.modelPanel:LayoutEntity( ent )
			self:SetCamPos( Vector( 20, 20, 20 ) )
			self:SetLookAt( ent:GetPos( ) + Vector( 0, 0, 5 ) )
			ent:SetAngles( ent:GetAngles( ) + Angle( 0, FrameTime() * 50,  0) )
		end
		local op = self.modelPanel.Paint
		function self.modelPanel:Paint( w, h )
			derma.SkinHook( "Paint", "DetailPanel", self, w, h )
			op( self, w, h )
		end
		self.modelPanel:SetModel( item.Model or "models/props/cs_office/cardboard_box03.mdl" )
		self.modelPanel:Dock( LEFT )
	elseif item.TextureId then
		self.modelPanel = vgui.Create( "DImage", self.topPnl )
		self.modelPanel:Dock( LEFT )
		function self.modelPanel:Paint( w, h )
			surface.SetTexture( item.TextureId )
			surface.SetDrawColor( color_white )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		self.modelPanel:SetSize( 64, 64 )
	end
	
	self.lbl = vgui.Create( "DLabel", self.topPnl )
	self.lbl:Dock( FILL )
	self.lbl:SetFont( "PS_Heading2" )
	self.lbl:SetText( "Purchase a " .. item.Name )
	self.lbl:SizeToContents( )
	self.lbl:DockMargin( 10, 0, 0, 0 )
	self.lbl:SetContentAlignment( 4 )
	
	self.topPnl:SizeToChildren( false, true )
	
	self.priceTbl = vgui.Create( "DPanel", self.container )
	self.priceTbl:Dock( TOP )
	Derma_Hook( self.priceTbl, "Paint", "Paint", "DetailPanel" )
	
	if item.Ranks and not table.HasValue( item.Ranks, LocalPlayer( ):PS_GetUsergroup( ) ) then
		local vipOnly = vgui.Create( "DLabel", self.priceTbl ) 
		vipOnly:SetText( "This item can only be bought by " .. table.concat( item.Ranks, ", " ) )
		vipOnly:Dock( TOP )
		vipOnly:SetColor( Color( 200, 0, 0 ) )
		vipOnly:SetContentAlignment( 5 )
		return
	end
	
	if type( self.item.Price ) == "table" then
		local pricesPanel = vgui.Create( "KShowPricePanel", self.priceTbl )
		pricesPanel:showBuyButtons( true )
		pricesPanel:DockMargin( 10, 10, 10, 10 )
		pricesPanel:DockPadding( 10, 10, 10, 10 )
		pricesPanel:Dock( TOP )
		pricesPanel:setItem( self.item )
		function pricesPanel:buyOrder( duration )
			LoadoutView:getInstance( ):orderItem( item.ID, duration, item.itemType )
		end
	else
		local priceLabel = vgui.Create( "DLabel", self.priceTbl )
		priceLabel:SetFont( "PS_Heading3" )
		priceLabel:DockMargin( 10, 10, 10, 10 )
		priceLabel:SetText( "Price: " .. self.item.Price .. ( PS.Config.Currency or "pts" ) )
		priceLabel:Dock( TOP )
		priceLabel:SizeToContents( )
		
		local buyButton = vgui.Create( "DButton", self.priceTbl )
		buyButton:DockMargin( 5, 0, 5, 10 )
		function buyButton.DoClick( )
			if ( item.Type == "Primary" and not LoadoutView:getInstance( ):validSubscription( "PrimaryWeapon" ) ) 
				or ( item.Type == "Secondary" and not LoadoutView:getInstance( ):validSubscription( "SecondaryWeapon" ) ) 
			then
				return Derma_Query( 
					Format( "You don't own a %s Weapon Slot yet, are you sure you want to buy this item?", item.Type ), 
					"Warning",
					"Yes", function( )
						if LocalPlayer():PS_HasPoints( self.item.Price ) then
							LoadoutView:getInstance( ):orderItem( self.item.ID, 0, item.itemType )
						end
					end,
					"No", function( )
						self:Remove( )
					end 
				)
			end
			
			if LocalPlayer():PS_HasPoints( self.item.Price ) then
				LoadoutView:getInstance( ):orderItem( self.item.ID, 0, item.itemType )
			end
		end
		function buyButton.Think( )
			if LocalPlayer():PS_HasPoints( self.item.Price ) then
				buyButton:SetColor( Color( 0, 100, 0 ) )
				buyButton:SetText( "Purchase" )
			else
				buyButton:SetColor( Color( 200, 0, 0 ) )
				buyButton:SetText( "Can't afford" )
			end
		end
		buyButton:Dock( TOP )
	end
	function self.priceTbl:PerformLayout( )
		self:SizeToChildren( true, true )
		self:SetTall( self:GetTall( ) + 5 )
	end
end

vgui.Register( "KPurchaseItemPanel", PANEL, "DFrame" )