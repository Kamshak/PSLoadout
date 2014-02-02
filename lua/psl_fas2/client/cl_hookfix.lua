hook.Add( "InitPostEntity", "fixhook", function( )
	function GAMEMODE:PostDrawViewModel( vm, ply, weapon )
	   if weapon.UseHands or (not weapon:IsScripted()) then
		  local hands = LocalPlayer():GetHands()
		  if IsValid(hands) then hands:DrawModel() end
	   end
	   if weapon.PostDrawViewModel then
		weapon:PostDrawViewModel( ) 
	   end
	end
end )