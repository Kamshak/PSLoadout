CATEGORY.Name = 'Loadout Attachments'
if PSLoadout.Config.DermaSkin == "ModernPS" then
	CATEGORY.Icon = 'vgui/psicons/iconreticule.png'
else
	CATEGORY.Icon = 'wrench'
end
CATEGORY.Order = -1
CATEGORY.IsAttachments = true

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