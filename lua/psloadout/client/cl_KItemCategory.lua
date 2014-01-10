local PANEL = {}

Derma_Hook( PANEL, "Paint", "Paint", "DetailPanel" )

AccessorFunc( PANEL, "m_iconSize", "IconSize" )
function PANEL:Init( )
	self:DockPadding( 10, 5, 10, 10 )
	
	self.titleLabel = vgui.Create( "DLabel", self )
	self.titleLabel:DockMargin( 0, 0, 0, 5 )
	self.titleLabel:Dock( TOP )
	self.titleLabel:SetFont( "PS_Heading3" )
	
	self.weaponsList = vgui.Create( "DIconLayout", self )
	self.weaponsList:SetSpaceX( 10 )
	self.weaponsList:SetSpaceY( 10 )
	self.weaponsList:DockMargin( 0, 0, 0, 0 )
	self.weaponsList:Dock( FILL )

	self:SetIconSize( 100 )
	self:SetSkin( PSLoadout.Config.DermaSkin )
end

function PANEL:setTitle( strTitle )
	self.titleLabel:SetText( strTitle )
end

function PANEL:addItem( item )
	local weaponIcon = self.weaponsList:Add( "KItemIcon" )
	weaponIcon:setItem( item )
	weaponIcon:SetSize( self.m_iconSize, self.m_iconSize )
	weaponIcon:setClipTarget( self.clipTarget )
	if item.OwnLine then
		weaponIcon.OwnLine = item.OwnLine
	end
	weaponIcon.OnMousePressed = function( panel, mcode )
		self:itemClicked( panel, mcode )
	end
end

function PANEL:setClipTarget( ct )
	self.clipTarget = ct
	for k, v in pairs( self.weaponsList:GetChildren( ) ) do
		v:setClipTarget( ct )
	end
end

function PANEL:setItems( items )
	for k, item in pairs( items ) do
		self:addItem( item ) 
	end
end

function PANEL:itemClicked( item, mcode )
end

function PANEL:PerformLayout( )
	self:SetTall( 10 )
	self.weaponsList:PerformLayout( )
	local wx, wy, ww, wh = 0, 0, 0, 0
	for k, v in pairs( self.weaponsList:GetChildren( ) ) do
		wx, wy = v:GetPos( )
		ww, wh = v:GetSize( )
	end	
	self.weaponsList:SetTall( wy + wh + 10 )
	
	wx, wy = self.weaponsList:GetPos( )
	
	self:SetTall( self.weaponsList:GetTall( ) + wy )
end
vgui.Register( "KItemCategory", PANEL, "DPanel" )