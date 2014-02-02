PSLoadout.Providers = {}

function PSLoadout:getProvider( )
	return self.Providers[self.Config.WeaponProvider]
end