local CSTM = {}
PSLoadout.Providers.CSTM = CSTM

function CSTM:isAttachmentCompatible( weapon, attachmentId, attachmentId2 )
	local cstmAttachmentTable = CWAttachments[attachmentId2]
	if table.HasValue( cstmAttachmentTable.incompability or {}, attachmentId ) then
		dp( itemId, "Incompat", attachmentId2 )
		return false
	end
	return true
end

function CSTM:addAttachmentToWeapon( weapon, attachment )
	weapon:K_AddAttachment( attachment.cstmAttachmentNum )
end

--attachmentId and corresponding ITEM
function CSTM:addAttributes( ITEM )	
	local cstmAttachmentTable = CWAttachments[ITEM.ID]
	local attachmentTable = {
		Name = cstmAttachmentTable.name,
		Description = cstmAttachmentTable.description,
		TextureId = cstmAttachmentTable.displaytexture,
		itemType = "attachment",
		cstmAttachmentNum = cstmAttachmentTable.num
	}
	table.Merge( ITEM, attachmentTable ) --Add/overwrite default attributes
end 