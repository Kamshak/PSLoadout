hook.Add( "PreDrawViewModel", "addffix", function( vm, ply, weapon2 )
	local weapon = LocalPlayer():GetActiveWeapon( )
	if weapon.PostDrawViewModel and weapon.Clip1 and weapon:Clip1( ) == 0 then
		weapon:PreDrawViewModel( )
	end
end )

hook.Add( "PostDrawViewModel", "addffix", function( vm, ply, weapon2 )
	local weapon = LocalPlayer():GetActiveWeapon( )
	if weapon.PostDrawViewModel and weapon.Clip1 and weapon:Clip1( ) == 0 then
		weapon:PostDrawViewModel( )
		return true
	end
end )