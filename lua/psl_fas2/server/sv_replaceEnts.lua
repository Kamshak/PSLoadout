local function ReplaceSingle(ent, newname)
   -- Ammo that has been mapper-placed will not have a pos yet at this point for
   -- reasons that have to do with being really annoying. So don't touch those
   -- so we can replace them later. Grumble grumble.
   if ent:GetPos() == vector_origin then
	  hook.Add( "Think", ent, function( )
		ReplaceSingle( ent, newname )
	  end )
      return
   end
	hook.Remove( "Think", ent )
   ent:SetSolid(SOLID_NONE)

   local rent = ents.Create(newname)
   rent:SetPos(ent:GetPos())
   rent:SetAngles(ent:GetAngles())
   rent:Spawn()

   rent:Activate()
   rent:PhysWake()

   ent:Remove()
end

local hl2_ammo_replace = {
   ["item_ammo_pistol"] = "ttt_random_ammo",
   ["item_box_buckshot"] = "ttt_random_ammo",
   ["item_ammo_smg1"] = "ttt_random_ammo",
   ["item_ammo_357"] = "ttt_random_ammo",
   ["item_ammo_357_large"] = "ttt_random_ammo",
   ["item_ammo_revolver"] = "ttt_random_ammo", -- zm
   ["item_ammo_ar2"] = "ttt_random_ammo",
   ["item_ammo_ar2_large"] = "ttt_random_ammo",
   ["item_ammo_smg1_grenade"] = "ttt_random_ammo",
   ["item_battery"] = "ttt_random_ammo",
   ["item_healthkit"] = "ttt_random_ammo",
   ["item_suitcharger"] = "ttt_random_ammo",
   ["item_ammo_ar2_altfire"] = "ttt_random_ammo",
   ["item_rpg_round"] = "ttt_random_ammo",
   ["item_ammo_crossbow"] = "ttt_random_ammo",
   ["item_healthvial"] = "ttt_random_ammo",
   ["item_healthcharger"] = "ttt_random_ammo",
   ["item_ammo_crate"] = "cstm_ammocrate",
   ["item_item_crate"] = "cstm_ammocrate",
   ["item_box_buckshot_ttt"] = "ttt_random_ammo",
   ["item_ammo_357_ttt"] = "ttt_random_ammo",
   ["item_ammo_pistol_ttt"] = "ttt_random_ammo",
   ["item_ammo_revolver_ttt"] = "ttt_random_ammo",
   ["item_ammo_smg1_ttt"] = "ttt_random_ammo",
};

-- Replace an ammo entity with the TTT version
-- Optional cls param is the classname, if the caller already has it handy
local function ReplaceAmmoSingle(ent, cls)
   if cls == nil then cls = ent:GetClass() end

	if string.find( cls, "item_ammo" ) or string.find( cls, "item_box" ) then
		ReplaceSingle( ent, "ttt_random_ammo" )
	end
   
   local rpl = hl2_ammo_replace[cls]
   if rpl then
      ReplaceSingle(ent, rpl)
   end
end

local function ReplaceAmmo()
   for _, ent in pairs(ents.FindByClass("item_*")) do
      ReplaceAmmoSingle(ent)
   end
end

local hl2_weapon_replace = {
   ["weapon_smg1"] = "fas2_mp5a5",
   ["weapon_shotgun"] = "fas2_m3s90",
   ["weapon_ar2"] = "fas2_ak47",
   ["weapon_357"] = "fas2_deagle",
   ["weapon_crossbow"] = "fas2_m24",
   ["weapon_rpg"] = "fas2_m24",
   ["weapon_slam"] = "fas2_glock20",
   ["weapon_frag"] = "fas2_pp19",
   ["weapon_crowbar"] = "fas2_ragingbull",
   
   ["weapon_ttt_glock"] = "fas2_glock20",
   ["weapon_ttt_m16"] = "fas2_ak47",
   ["weapon_zm_shotgun"] = "fas2_m3s90",
   ["weapon_zm_sledge"] = "fas2_g3",
   ["weapon_zm_mac10"] = "fas2_mp5a5",
   ["weapon_zm_pistol"] = "fas2_m1911",
   ["weapon_zm_revolver"] = "fas2_ragingbull",
   ["weapon_zm_rifle"] = "fas2_galil",
   ["weapon_ttt_confgrenade"] = "fas2_ks23"
};


local function ReplaceWeaponSingle(ent, cls)
	-- Loadout weapons immune
	-- we use a SWEP-set property because at this state all SWEPs identify as weapon_swep
	if cls == nil then cls = ent:GetClass() end

	local rpl = hl2_weapon_replace[cls]
	if rpl then
		ReplaceSingle(ent, rpl)
	end
end

local function ReplaceWeapons()
   for _, ent in pairs(ents.FindByClass("weapon_*")) do
      ReplaceWeaponSingle(ent)
   end
end

-- People spawn with these, so remove any pickups (ZM maps have them)
local function RemoveCrowbars()
   for k, ent in pairs(ents.FindByClass("weapon_zm_improvised")) do
      ent:Remove()
   end
end

local cls = "" -- avoid allocating
local sub = string.sub
local function ReplaceOnCreatedPSL(s, ent)
   -- Invalid ents are of no use anyway
   if not ent:IsValid() then return end

   cls = ent:GetClass()

   if sub(cls, 1, 4) == "item" then
      ReplaceAmmoSingle(ent, cls)
   elseif sub(cls, 1, 6) == "weapon" then
      ReplaceWeaponSingle(ent, cls)
   end
end


hook.Add( "Initialize", "HookEntReplace", function( )
	if engine.ActiveGamemode( ) != "terrortown" then
		return
	end
	
	--Replace HL2/TTT Ents
	function ents.TTT.ReplaceEntities()
		ReplaceAmmo()
		ReplaceWeapons()
		RemoveCrowbars()
		ents.TTT.RemoveRagdolls()
	end
	
	-- Helper so we can easily turn off replacement stuff when we don't need it
	function ents.TTT.SetReplaceChecking(state)
	   if state then
		  GAMEMODE.OnEntityCreated = ReplaceOnCreatedPSL
	   else
		  GAMEMODE.OnEntityCreated = util.noop
	   end
	end
	
	function ents.TTT.GetSpawnableAmmo()
		return PSLoadout.SpawnableAmmo or {}
	end

	hook.Add( "Think", "adfs", function( )
		GAMEMODE.OnEntityCreated = ReplaceOnCreatedPSL
	end )
end )