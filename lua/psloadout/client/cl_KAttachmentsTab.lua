local PANEL = {}

function PANEL:Init( )
	self.scroll = vgui.Create( "DScrollPanel", self )
	self.scroll:Dock( FILL )
	
	self.attachmentsPanel = vgui.Create( "KLoadoutTypeContainer", self.scroll )
	self.attachmentsPanel:Dock( FILL )
	self.attachmentsPanel:setTitle( "Weapon Attachments" )
end

function PANEL:loadItems( )
	local items = LoadoutView:getInstance( ):getAttachmentsSorted( )
	self.attachmentsPanel:setItems( items )
end

function PANEL:Paint( )
end
vgui.Register( "KAttachmentsTab", PANEL, "DPanel" )