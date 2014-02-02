CATEGORY.Name = 'Loadout Attachments'
if PSLoadout.Config.DermaSkin == "ModernPS" then
	CATEGORY.Icon = 'vgui/psicons/iconreticule.png'
else
	CATEGORY.Icon = 'wrench'
end
CATEGORY.Order = -1

CATEGORY.IsAttachments = true
CATEGORY.Attachments = {}
if PSLoadout.Config.WeaponProvider == "CSTM" then
	CATEGORY.Attachments = {
		Scope = {
			reflex = {
				Price = 10000
			},
			kobra = {
				Price = 7000
			},
			riflereflex = {
				Price = 15000
			},
			eotech = {
				Price = 25000
			},
			aimpoint = {
				Price = 27000
			},
			elcan = {
				Price = 28000
			},
			acog = {
				Price = 30000
			},
			ballistic = {
				Price = 25000
			}
		},
		["Barrel Attachment"] = {
			vertgrip = {
				Price = 15000
			},
			grenadelauncher = {
				Price = 20000
			},
			bipod = {
				Price = 15000
			},
		},
		["Other Attachent"] = {
			laser = {
				Price = 15000
			},
			cmag = {
				Price = 30000
			}
		}
	}
elseif PSLoadout.Config.WeaponProvider == "FAS2" then
	CATEGORY.Attachments = {
		Scope = {
			eotech = {
				Price = 25000
			},
			compm4 = {
				Price = 27000
			},
			leupold = {
				Price = 28000
			},
			pso1 = {
				Price = 30000
			},
			c79 = {
				Price = 40000
			},
			tritiumsights = {
				Price = 25000
			}
		},
		["Barrel Attachment"] = {
			foregrip = {
				Price = 15000
			},
			harrisbipod = {
				Price = 20000
			}
		},
		["Other Attachent"] = {
			sks20mag = {
				Price = 15000
			},
			suppressor = {
				Price = 30000
			}
		}
	}
end