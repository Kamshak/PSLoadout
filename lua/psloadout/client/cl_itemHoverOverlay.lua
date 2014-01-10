local hoverPanel, lastHoverItem
hook.Add( "DrawOverlay", "ItemInfoPaint", function( )
	if ( dragndrop.m_Dragging != nil ) then return end
	local hoverItem = vgui.GetHoveredPanel( )
	if not IsValid( hoverItem ) then
		if IsValid( hoverPanel ) then
			hoverPanel:Remove( )
		end
		return
	end
	
	if hoverItem != lastHoverItem then
		if IsValid( hoverPanel ) then
			hoverPanel:Remove( )
		end
	end
	lastHoverItem = hoverItem
	
	if hoverItem.weaponIcon then
		local weaponIcon = hoverItem.weaponIcon
		if not IsValid( hoverPanel ) then
			hoverPanel = weaponIcon:getHoverPanel( )
			if not IsValid( hoverPanel ) then
				return
			end
			hoverPanel:SetPaintedManually( true )
			hoverPanel:SetTargetPanel( weaponIcon )
			sound.Play( "hover", LocalPlayer( ):GetPos( ) )
		end
		
		DisableClipping( true )
		local itemBottomCenterX, itemBottomCenterY = weaponIcon:LocalToScreen( weaponIcon:GetWide( ) / 2, weaponIcon:GetTall( ) )
		local paintPosX, paintPosY = itemBottomCenterX - hoverPanel:GetWide( ) / 2, itemBottomCenterY 
		
		paintPosX = math.Clamp( paintPosX, 0, ScrW( ) )
		if paintPosX + hoverPanel:GetWide( ) > ScrW( ) then
			paintPosX = ScrW( ) - hoverPanel:GetWide( )
		end
		
		if paintPosY + hoverPanel:GetTall( ) > ScrH( ) then
			paintPosY = ScrH( ) - hoverPanel:GetTall( ) 
			hoverPanel:SetTargetPanel( nil )
		else
			hoverPanel:SetTargetPanel( weaponIcon )
		end
		
		hoverPanel:SetPaintedManually( false )
		hoverPanel:PaintAt( paintPosX, paintPosY )
		hoverPanel:SetPaintedManually( true )
		DisableClipping( false )
	end
end )