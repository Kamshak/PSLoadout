local PANEL = {}

function PANEL:Init( )
	self:SetTitle( "Loading" )
	self:SetSize( 200, 200 )
	
	self.message = vgui.Create( "DLabel", self )
	self.message:Dock( TOP )
	self.message:SetText( "Loading Data" )
end

function PANEL:setText( txt )
	self.message:SetText( txt )
end

function PANEL:Paint( w, h )
		self.BaseClass.Paint( self, w, h )
		
	
		surface.SetDrawColor( 0, 100, 0, 150 )
		surface.DrawRect( 4, self:GetTall() - 10, self:GetWide() - 8, 5 )
		
		surface.SetDrawColor( 0, 50, 0, 255 )
		surface.DrawRect( 5, self:GetTall() - 9, self:GetWide() - 10, 3 )
		
		local w = self:GetWide() * 0.25
		local x = math.fmod( SysTime() * 200, self:GetWide() + w ) - w
		
		if ( x + w > self:GetWide() - 11 ) then w = ( self:GetWide() - 11 ) - x end 
		if ( x < 0 ) then w = w + x; x = 0 end
		
		surface.SetDrawColor( 0, 255, 0, 255 )
		surface.DrawRect( 5 + x, self:GetTall() - 9, w, 3 )
end
derma.DefineControl( "KLoadingPanel", "Loading indicator", PANEL, "DFrame" )