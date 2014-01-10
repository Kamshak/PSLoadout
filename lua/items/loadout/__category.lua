CATEGORY.Name = 'Loadout Weapons'
if PSLoadout.Config.DermaSkin == "ModernPS" then
	CATEGORY.Icon = 'vgui/psicons/gunicon.png'
else
	CATEGORY.Icon = 'bomb'
end
CATEGORY.Order = -2
CATEGORY.IsLoadout = true

CATEGORY.LoadoutSettings = {}
CATEGORY.LoadoutSettings.Primary = {
	ID = "PrimaryWeapon",
	Name = "Primary Weapon Slot",
	ShortName = "Primary", --Dont modify.
	AttachmentsName = "Primary Attachments",
	Price = 20000,	--Cust to unlock the slot
	attachmentSlots = {	--Attachment slots settings
		[1] = {
			ID = "PrimaryWeaponAttach1",
			Name = "Attachment Slot 1",
			ShortName = "Attachment",
			Price = 10000
		},
		[2] = {
			ID = "PrimaryWeaponAttach2",
			Name = "Attachment Slot 2",
			ShortName = "Attachment",
			Price = 50000
		},
		[3] = {
			ID = "PrimaryWeaponAttach3",
			Name = "Attachment Slot 3",
			ShortName = "Attachment",
			Description = "T-VIP+ Only",
			Price = 80000,
			Ranks = { "vip", "t-vip", "m-vip" }
		}
	}
}

CATEGORY.LoadoutSettings.Secondary = {
	ID = "SecondaryWeapon",
	Name = "Secondary Weapon Slot",
	ShortName = "Secondary",
	AttachmentsName = "Secondary Attachments",
	Price = 3000,	--Cust to unlock the slot
	attachmentSlots = {	--Attachment slots settings
		[1] = {
			ID = "SecondaryWeaponAttach1",
			Name = "Attachment Slot 1",
			ShortName = "Attachment",
			Description = "",
			Price = 5000
		},
		[2] = {
			ID = "SecondaryWeaponAttach2",
			Name = "Attachment Slot 2",
			ShortName = "Attachment",
			Description = "T-VIP+ Only",
			Price = 20000,
			Ranks = { "t-vip", "m-vip" }
		},
		[3] = {
			ID = "SecondaryWeaponAttach3",
			Name = "Attachment Slot 3",
			ShortName = "Attachment",
			Description = "M-VIP Only",
			Price = 70000,
			Ranks = { "vip", "t-vip", "m-vip" }
		},
	}
}

function MakePriceTable( basePrice )
	return {
		[1] = basePrice,
		[7] = basePrice * 5,
		[30] = basePrice * 5 * 3,
		[0] = basePrice * 5 * 3 * 2
	}
end