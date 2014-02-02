ITEM.Name = 'UMP 45'
ITEM.Price = MakePriceTable( 3000 )
ITEM.Model = "models/weapons/w_smg_ump45.mdl"
ITEM.WeaponClass = 'cstm_smg_ump45'
ITEM.Type = "Primary"
ITEM.SubCategory = "SMG"

ITEM.Description = "German SMG, the UMP(Universale Maschinenpistole). Fires .45CP bullets. Low fireate, high damage."

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
