local PANEL = {}

function PANEL:Init( )
	self.scroll = vgui.Create( "DScrollPanel", self )
	self.scroll:Dock( FILL )
	
	self.openLoadoutBar = vgui.Create( "DPanel", self )
	self.openLoadoutBar:Dock( BOTTOM )
	function self.openLoadoutBar:Paint( w, h )
		draw.RoundedBoxEx( 6, 0, 0, w, h, Color( 80, 80, 80 ), false, false, true, true )
	end
	self.openLoadoutBar:SetTall( 40 )
	
	self:SetSkin( PSLoadout.Config.DermaSkin )
	
	local label = vgui.Create( "DLabel", self.openLoadoutBar )
	label:SetColor( color_white )
	label:SetText( self:GetSkin( ).ChangeHintText )
	label:Dock( FILL )
	label:SetFont( "PS_Heading3" )
	label:SetContentAlignment( 5 )
end

function PANEL:loadItems( )
	local itemsSorted = LoadoutView:getInstance( ):getWeaponsSorted( )
	
	self.primariesPanel = vgui.Create( "KLoadoutTypeContainer", self.scroll )
	self.primariesPanel:Dock( TOP )
	self.primariesPanel:setTitle( "Primary Weapons" )
	self.primariesPanel:setItems( itemsSorted.Primary )
	self.primariesPanel:setClipTarget( self.scroll )

	self.secondariesPanel = vgui.Create( "KLoadoutTypeContainer", self.scroll )
	self.secondariesPanel:Dock( TOP )
	self.secondariesPanel:setTitle( "Secondary Weapons" )
	self.secondariesPanel:setItems( itemsSorted.Secondary )
	self.secondariesPanel:setClipTarget( self.scroll )
end

function PANEL:Paint( w, h )
end
vgui.Register( "KLoadoutTab", PANEL, "DPanel" )


