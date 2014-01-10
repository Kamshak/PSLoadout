LibK.InitializeAddon{
    addonName = "PSLoadouts",                  --Name of the addon
    author = "Kamshak",                         --Name of the author
    luaroot = "psloadout",                     --Folder that contains the client/shared/server structure relative to the lua folder,
	loadAfterGamemode = false
}
LibK.addReloadFile( "autorun/loadout_init.lua" )