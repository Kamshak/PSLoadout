ITEM.Name = 'Desert Eagle'
ITEM.Price = MakePriceTable( 2000 )
ITEM.Model = "models/weapons/w_pist_deagle.mdl"
ITEM.WeaponClass = 'cstm_pistol_deagle'
ITEM.Type = "Secondary"
ITEM.SubCategory = "Pistol"

ITEM.Description = ".50 AE bullets. #swag"

ITEM.Attachments = {
	[1] = {"reflex"},
	[2] = {"laser"}}
	
ITEM.InternalParts = {
	[1] = {{key = "ergonomichandle"}},
	[2] = {{key = "burstconvert"}}}

