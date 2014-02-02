if PSLoadout.Config.WeaponProvider != "FAS2" then
	return
end

LibK.InitializeAddon{
    addonName = "PSL-FAS2",                  --Name of the addon
    author = "Kamshak",                      --Name of the author
    luaroot = "psl_fas2",                    --Folder that contains the client/shared/server structure relative to the lua folder,
	loadAfterGamemode = false
}
LibK.addReloadFile( "autorun/psl_fas2_init.lua" )