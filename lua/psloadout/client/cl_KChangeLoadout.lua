local PANEL = {}

function PANEL:Init( )
	self.loadoutPanel = vgui.Create( "KLoadoutSelectPanel", self )
	self.loadoutPanel:Dock( FILL )
	
	self:SetTitle( "Select Loadout" )
	self:SetWide( 550 )
	self:SetSkin( PSLoadout.Config.DermaSkin )
	
	derma.SkinHook( "Layout", "PopupFrame", self )
end

function PANEL:PerformLayout( )
	self.loadoutPanel:PerformLayout( )
	self:SizeToChildren( false, true )
	
	self.BaseClass.PerformLayout( self )
	
	self:SetPos( ScrW() / 2 - self:GetWide( ) / 2, ScrH( ) / 2 - self:GetTall( ) / 2 )
end

vgui.Register( "KChangeLoadout", PANEL, "DFrame" )