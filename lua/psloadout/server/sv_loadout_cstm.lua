local CSTM = {}
LoadoutController.Providers.CSTM = CSTM


function CSTM:isAttachmentCompatible( weapon, attachmentId, attachmentId2 )
	local cstmAttachmentTable = CWAttachments[attachmentId2]
	if table.HasValue( cstmAttachmentTable.incompability or {}, attachmentId ) then
		dp( itemId, "Incompat", attachmentId2 )
		return false
	end
	return true
end