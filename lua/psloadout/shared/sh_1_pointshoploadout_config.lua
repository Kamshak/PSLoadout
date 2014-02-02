local Config = {}
PSLoadout.Config = Config

--Items that the player owns when first joining.
--Can be set to 0 for permanent or the number in days the item should be owned for.
--For items that can only be bought permanently(attachments by default) be sure to put 0
Config.PreOwnedItems = {
	SecondaryWeapon = 0, --Secondary Weapon Slot
	SecondaryWeaponAttach1 = 0, --First Secondary Attachment Slot
}

--Derma Skin to use.
--Included is a skin for the default pointshop: DefaultLoadout
--For Modern Pointshop Skin( http://coderhire.com/scripts/view/354 ) owners 
--a matching skin is available as DLC(Skin Name: ModernPS).
Config.DermaSkin = "ModernPS"

--Weapon provider to use.
--Supported are CSTM for Customizable Weaponry 
--          and FAS2 for Firearms:Source
Config.WeaponProvider = "FAS2"