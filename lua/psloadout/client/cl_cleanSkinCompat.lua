hook.Add( "CleanSkinAddButtons", "AddLoadoutButton", function( s )
	s.changeLoadoutButton = vgui.Create('DButton', s)
	s.changeLoadoutButton:SetText('')
	s.changeLoadoutButton:SetSize(200, 20)
	s.changeLoadoutButton:SetPos(s:GetWide()-205, 105+345+5+20)
	s.changeLoadoutButton.Paint = function( ss, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(57, 61, 72))
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color(255, 255, 255, 10))
		draw.RoundedBox( 0, 2, 2, w-4, h-4, Color(57, 61, 72))
		draw.SimpleText('Change Loadout', 'PS_CatName', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	end
	s.changeLoadoutButton.DoClick = function()
		local frame = vgui.Create('KChangeLoadout')
		frame:MakePopup( )
	end
end )

hook.Add( "CleanSkinAddCategory", "AddCustomCats", function( s, inv )
	local cat = PS.Categories[s.CurrentCat]
	if cat.IsLoadout then
		s.Scroll = vgui.Create('KLoadoutTab', s)
		s.Scroll:SetSkin( "FreshPointshop" )
		s.Scroll:loadItems( cat )
		s.Scroll:SetPos( 255, 105 )
		s.Scroll:SetSize( s:GetWide()-460, s:GetTall()-110 )
		return true
	elseif cat.IsAttachments then
		s.Scroll = vgui.Create('KAttachmentsTab', s)
		s.Scroll:SetSkin( "FreshPointshop" )
		s.Scroll:loadItems( cat )
		s.Scroll:SetPos( 255, 105 )
		s.Scroll:SetSize( s:GetWide()-460, s:GetTall()-110 )
		return true
	end
end )