if SERVER then
	util.AddNetworkString( "PlaySound" )
	util.AddNetworkString( "StreamSound" )
	function playOnAll( str )
		net.Start( "PlaySound" )
			net.WriteString( str )
		net.Broadcast( )
	end
	function StreamSound( str )
		net.Start( "StreamSound" )
			net.WriteString( str )
		net.Broadcast( )
	end
	
	local spawn = {
		"http://www.kamshak.com/mwmusic/HGW_mp_spawn_opfor.ogg",
		"http://www.kamshak.com/mwmusic/HGW_mp_spawn_russia.ogg",
		"http://www.kamshak.com/mwmusic/HGW_mp_spawn_sas.ogg",
		"http://www.kamshak.com/mwmusic/HGW_mp_spawn_usa.ogg"
	}
	hook.Add( "TTTBeginRound", "SoundPlay", function( )
		StreamSound( table.Random( spawn ) )
	end )
	
	hook.Add( "TTTEndRound", "SoundPlay", function( win )
		local wins = {
			"loadout/AF_1mc_mission_success_01.wav",
			"loadout/AF_1mc_mission_success_02.wav",
			"loadout/AF_1mc_mission_success_03.wav",
			"loadout/AF_1mc_win_01.wav",
		}
		local losses = {
			"loadout/AF_1mc_mission_fail_01.wav",
			"loadout/AF_1mc_mission_fail_02.wav",
			"loadout/AF_1mc_mission_fail_03.wav",
		}
		if win == WIN_INNOCENT then
			StreamSound( "http://www.kamshak.com/mwmusic/hz_mp_usvictory_1.ogg" )
			playOnAll( table.Random( wins ) )
		else
			StreamSound( "http://www.kamshak.com/mwmusic/hz_mp_usdefeat_1.ogg" )
			playOnAll( table.Random( losses ) )
		end
	end )
end

if CLIENT then
	net.Receive( "PlaySound", function( )
		surface.PlaySound( net.ReadString( ) )
	end )
	net.Receive( "StreamSound", function( )
		sound.PlayURL( net.ReadString( ), "", function( ) end ) 
	end )
end