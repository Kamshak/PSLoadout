ITEM.Name = 'AK-47'
ITEM.Price = MakePriceTable( 4500 )
ITEM.Model = "models/weapons/w_rif_ak47.mdl"
ITEM.WeaponClass = 'cstm_rif_ak47'
ITEM.Type = "Primary"
ITEM.SubCategory = "Assault-Rifle"

ITEM.Description = "Terrorist's Favorite. Reliable, close to unbreakable and shoots bullets."

ITEM.Attachments = {
	[1] = {"kobra", "aimpoint", "acog"},
	[2] = {"vertgrip"},
	[3] = {"laser"}
}
	
ITEM.InternalParts = {
	[1] = {{key = "hbar"}, {key = "lbar"}},
	[2] = {{key = "hframe"}},
	[3] = {{key = "ergonomichandle"}},
	[4] = {{key = "customstock"}},
	[5] = {{key = "lightbolt"}, {key = "heavybolt"}},
	[6] = {{key = "gasdir"}}
}