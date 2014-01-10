hook.Add( "Initialize", "LoadSimpleSkin", function( )

local SKIN = {}
SKIN.PanelFrameColor = Color( 50, 50, 50 )
SKIN.PanelContainerColor = Color( 150, 150, 150 )
SKIN.PanelContainerInnerColor = Color( 100, 100, 100 )

SKIN.IconBackground = Color( 240, 240, 240 )
SKIN.ItemOwnedBarBackground = Color( 30, 30, 30 )

SKIN.ItemDescPanelBorder = Color( 255, 255, 255 )
SKIN.ItemDescPanelBackground = SKIN.PanelFrameColor

SKIN.PricesPanelBackground = Color( 80, 80, 80 )

SKIN.ChangeHintText = "To change your loadout click \"Change Loadout\" below the preview"

SKIN.Colours = table.Copy( derma.GetDefaultSkin( ).Colours )
SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = color_white
SKIN.Colours.Label.Bright = SKIN.ItemDescPanelBorder

function SKIN:LayoutPopupFrame( panel )
	panel:SetBackgroundBlur( true )
end

function SKIN:PaintFrame( panel, w, h )
	surface.SetDrawColor( self.PanelFrameColor )
	surface.DrawRect( 0, 0, w, h )
end

--Level 1 container
function SKIN:PaintInnerPanel( panel, w, h )
	surface.SetDrawColor( self.PanelContainerColor )
	surface.DrawRect( 0, 0, w, h )
end

--Level 2 container
function SKIN:PaintDetailPanel( panel, w, h )
	surface.SetDrawColor( self.PanelContainerInnerColor )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintItemBackground( panel, w, h )
	surface.SetDrawColor( self.IconBackground )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintItemOwnedBackground( panel, w, h )
	surface.SetDrawColor( self.ItemOwnedBarBackground )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintPricesPanel( panel, w, h )
	surface.SetDrawColor( self.PricesPanelBackground )
	surface.DrawRect( 0, 0, w, h )
end

derma.DefineSkin( "LoadoutSimple", "Default Derma with Loadout extensions", SKIN )

end ) --hook.Add( "Initialize" )