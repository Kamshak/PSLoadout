local PANEL = {}

function PANEL:Init( )
	self:DockPadding( 5, 10, 5, 5 )
	self.titleLabel = vgui.Create( "DLabel", self )
	self.titleLabel:DockMargin( 5, 5, 5, 0 )
	self.titleLabel:Dock( TOP )
	self.titleLabel:SetFont( "PS_Heading2" )
	self.titleLabel:SetBright( true )
	
	self.descriptionLabel = vgui.Create( "RichText", self )
	self.descriptionLabel:DockMargin( 5, 0, 10, 5 )
	self.descriptionLabel:Dock( TOP )
	self.descriptionLabel:SetVerticalScrollbarEnabled( false )
	self.descriptionLabel:SetPaintBackgroundEnabled( false )
	--self.descriptionLabel:SetMultiline( true )
	self.descriptionLabel:SetFontInternal( "PS_Heading3" )
	--self.descriptionLabel:SetEditable( false )
	function self.descriptionLabel:Paint( )
		--self:DrawTextEntryText( self.m_colText, self.m_colHighlight, self.m_colCursor )
	end
	
	self:SetSkin( PSLoadout.Config.DermaSkin )
end

function PANEL:PerformLayout( )
	--self.descriptionLabel:SetToFullHeight( )
	--self.descriptionLabel:SetTall( self.descriptionLabel:GetTall( ) + 30 )
	--self:SetTall( 20 + self.descriptionLabel:GetTall( ) )
	--self:SizeToContents( )
	local x, y
	local w, h
	for k, v in pairs( self:GetChildren( ) ) do
		v:SizeToContents( )
		if v.SetToFullHeight then
			v:SetToFullHeight( )
		end
		if v.PerformLayout then
			v:PerformLayout( )
		end
		x, y = v:GetPos( )
		w, h = v:GetSize( )
	end
	
	self:SetTall( y + h + 10 )
end

function PANEL:SetTargetPanel( pnl )
	self.targetPanel = pnl
end

function PANEL:setItem( item )
	self.titleLabel:SetText( item.Name )
	self.titleLabel:SizeToContents( )
	local text = item.Description
	
	if type( item.Description ) == "string" then
		self.descriptionLabel:SetText( text )
	elseif istable( item.Description ) then
		for k, v in ipairs( item.Description ) do
			self.descriptionLabel:InsertColorChange( v.c.r, v.c.g, v.c.b, v.c.a )
			self.descriptionLabel:AppendText( v.t .. "\n" )
		end
	end
	self.descriptionLabel:SizeToContents( )
end
	
-- only for indexed tables!
function table.reverse ( tab )
	local size = #tab
	local newTable = {}
 
	for i,v in ipairs ( tab ) do
		newTable[size-i] = v
	end
 
	return newTable
end

function PANEL:Paint( w, h )
	w, h = w - 1, h - 1
	--Fill
	surface.SetDrawColor( self:GetSkin( ).ItemDescPanelBackground )
	if self.targetPanel then
		local targetXScreen, targetYScreen = self.targetPanel:LocalToScreen( 0, 0 )
		local targetX, targetY = self:ScreenToLocal( targetXScreen, targetYScreen )
		
		local targetW, targetH = self.targetPanel:GetSize( )
		local targetCenterX = targetX + targetW / 2
		local fillVertices = {}
		table.insert( fillVertices, { x = targetCenterX + 10, y = 10 } )
		table.insert( fillVertices, { x = targetCenterX, y = 0 } ) --top
		table.insert( fillVertices, { x = targetCenterX - 10, y = 10 } )
		table.insert( fillVertices, { x = targetCenterX + 10, y = 10 } )
		fillVertices = table.reverse( fillVertices )
		
		draw.NoTexture( )
		surface.DrawPoly( fillVertices )
	end
	surface.DrawRect( 0, 10, w, h - 10 )
	
	--Outline
	local vertices = {}
	table.insert( vertices, { x = 0, y = 10 } )
	table.insert( vertices, { x = 0, y = h } )
	table.insert( vertices, { x = w, y = h } )
	table.insert( vertices, { x = w, y = 10 } )
	
	if self.targetPanel then
		local targetXScreen, targetYScreen = self.targetPanel:LocalToScreen( 0, 0 )
		local targetX, targetY = self:ScreenToLocal( targetXScreen, targetYScreen )
		local targetW, targetH = self.targetPanel:GetSize( )
		local targetCenterX = targetX + targetW / 2
		table.insert( vertices, { x = targetCenterX + 10, y = 10 } )
		table.insert( vertices, { x = targetCenterX, y = 0 } ) --top
		table.insert( vertices, { x = targetCenterX - 10, y = 10 } )
	end
	
	surface.SetDrawColor( self:GetSkin( ).ItemDescPanelBorder )
	table.insert( vertices, { x = 0, y = 10 } )
	local lastVert
	for k, vert in pairs( vertices ) do
		if k > 1 then 
			surface.DrawLine( lastVert.x, lastVert.y, vert.x, vert.y ) 
		end
		lastVert = vert
	end
end
vgui.Register( "KItemDescriptionPanel", PANEL, "DPanel" )