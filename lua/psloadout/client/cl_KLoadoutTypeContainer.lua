local PANEL = {}

function PANEL:Init( )
	self:DockPadding( 10, 10, 10, 10 )
	
	self.typeLabel = vgui.Create( "DLabel", self )
	self.typeLabel:Dock( TOP )
	self.typeLabel:SetFont( "PS_Heading2" )
	self.typeLabel:DockMargin( 0, 0, 0, 10 )
	
	self.categories = {}
	
	self:SetSkin( PSLoadout.Config.DermaSkin )
end

function PANEL:setTitle( strTitle )
	self.typeLabel:SetText( strTitle )
end

function PANEL:itemClicked( item, mcode )
	if not item.invItem or item.invItem:isExpired( ) then 
		LoadoutView:getInstance( ):startPurchaseItem( item.item )
		sound.Play( "select", LocalPlayer( ):GetPos( ) )
	end
end

function PANEL:addCategory( strCategory )
	local categoryPanel = vgui.Create( "KItemCategory", self )
	categoryPanel:Dock( TOP )
	categoryPanel:setTitle( strCategory .. "s" )
	categoryPanel:DockMargin( 10, 0, 10, 10 )
	categoryPanel:setClipTarget( self.clipTarget )
	categoryPanel.itemClicked = function( panel, item, mcode )
		self:itemClicked( item, mcode )
	end
	self.categories[strCategory] = categoryPanel
end

function PANEL:setItems( categorizedItems )
	self.items = categorizedItems
	for strCategory, items in pairs( categorizedItems ) do
		if not IsValid( self.categories[strCategory] ) then
			self:addCategory( strCategory )
		end
		
		self.categories[strCategory]:setItems( items )
	end
end

function PANEL:setClipTarget( ct )
	self.clipTarget = ct
	for k, v in pairs( self.categories ) do
		v:setClipTarget( ct )
	end
end

function PANEL:Paint( w, h )
end

function PANEL:PerformLayout( )
	local x, y
	local w, h
	for k, v in pairs( self:GetChildren( ) ) do
		v:PerformLayout( )
		v:SizeToContents( )
		x, y = v:GetPos( )
		w, h = v:GetSize( )
	end
	
	self:SetTall( y + h )
end
vgui.Register( "KLoadoutTypeContainer", PANEL, "DPanel" )