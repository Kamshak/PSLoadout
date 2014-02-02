if PSLoadout.Config.WeaponProvider != "CSTM" then
	return
end

LibK.InitializeAddon{
    addonName = "PSL-CSTM",                  --Name of the addon
    author = "Kamshak",                      --Name of the author
    luaroot = "psl_cstm",                    --Folder that contains the client/shared/server structure relative to the lua folder,
	loadAfterGamemode = false
}
LibK.addReloadFile( "autorun/psl_cstm_init.lua" )