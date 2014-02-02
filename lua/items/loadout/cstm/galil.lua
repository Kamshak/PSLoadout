ITEM.Name = 'Galil'
ITEM.Price = MakePriceTable( 4000 )
ITEM.Model = "models/weapons/w_rif_galil.mdl"
ITEM.WeaponClass = 'cstm_rif_galil'
ITEM.Type = "Primary"
ITEM.SubCategory = "Assault-Rifle"

ITEM.Description = "Israelian Rifle using a system very similar to the AK47."

ITEM.Attachments = {
	[1] = {"kobra", "riflereflex", "aimpoint", "acog"},
	[2] = {"vertgrip", "bipod"},
	[3] = {"laser"}}
	
ITEM.InternalParts = {
	[1] = {{key = "hbar"}, {key = "lbar"}},
	[2] = {{key = "hframe"}},
	[3] = {{key = "ergonomichandle"}},
	[4] = {{key = "customstock"}},
	[5] = {{key = "lightbolt"}, {key = "heavybolt"}},
	[6] = {{key = "gasdir"}}}