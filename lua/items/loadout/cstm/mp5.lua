ITEM.Name = 'MP5'
ITEM.Price = MakePriceTable( 2000 )
ITEM.Model = "models/weapons/w_smg_mp5.mdl"
ITEM.WeaponClass = 'cstm_smg_mp5'
ITEM.Type = "Primary"
ITEM.SubCategory = "SMG"

ITEM.Description = "German machine pistol by Heckler&Koch. Used by special forces all over the world"

ITEM.Attachments = {
	[1] = {"eotech", "aimpoint"},
	[2] = {"laser"}}
	
ITEM.InternalParts = {
	[1] = {{key = "hbar"}, {key = "lbar"}},
	[2] = {{key = "hframe"}},
	[3] = {{key = "ergonomichandle"}},
	[4] = {{key = "customstock"}},
	[5] = {{key = "lightbolt"}, {key = "heavybolt"}},
	[6] = {{key = "gasdir"}}}
