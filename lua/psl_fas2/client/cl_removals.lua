concommand.Remove( "fas2_togglegunpimper" )
hook.Add( "Think", "removeshite", function( )
	hook.Remove( "PlayerBindPress", "SWEP.PlayerBindPress (FAS2)" )
end )

RunConsoleCommand( "fas2_nohud", 1 )
RunConsoleCommand( "fas2_customhud", 0 )
RunConsoleCommand( "fas2_blureffects", 1 )
RunConsoleCommand( "fas2_hitmarker", 1 )