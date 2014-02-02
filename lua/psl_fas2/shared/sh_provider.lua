local FAS2 = {}
PSLoadout.Providers.FAS2 = FAS2

function FAS2:isAttachmentCompatible( weapon, attachmentId, attachmentId2 )
	local attachmentsTable = weapon.Attachments
	
	local found = false
	for _, group in pairs( attachmentsTable ) do
		if table.HasValue( group, attachmentId ) then
			found = true
		end
		if table.HasValue( group, attachmentId ) and
		   table.HasValue( group, attachmentId2 ) then
			return false
		end
	end
	if not found then 
		return false 
	end
	
	return true
end

if SERVER then
	util.AddNetworkString( "PSL_FAS2_ATTACH" )

	--SV function
	function FAS2:addAttachmentToWeapon( swep, attachment )
		local attachmentId = attachment.AttachId
		if IsValid( swep ) and swep.IsFAS2Weapon then
			local group
			for _, attachmentGroup in pairs( swep.Attachments ) do
				if table.HasValue( attachmentGroup.atts, attachmentId ) then
					group = attachmentGroup
				end
			end
			if not group then 
				KLogf( 3, "Invalid attachment given to FAS2:addAttachmentToWeapon, weapon was %s, attachment was %s", swep.ClassName, attachmentId )
				return
			end
			
			local oldPlayAnim = FAS2_PlayAnim
			FAS2_PlayAnim = function( ) end
			
			if group.lastdeattfunc then
				group.lastdeattfunc( swep.Owner, wep )
				group.lastdeattfunc = nil
			end
			
			group.last = attachmentId
			
			local fasAttachmentTable = FAS2_Attachments[attachmentId]
			
			if fasAttachmentTable.attfunc then
				fasAttachmentTable.attfunc( self.Owner, swep )
			end
				
			if fasAttachmentTable.deattfunc then
				group.lastdeattfunc = fasAttachmentTable.deattfunc
			end
			
			FAS2_PlayAnim = oldPlayAnim
		
			net.Start( "PSL_FAS2_ATTACH" )
				net.WriteEntity( swep )
				net.WriteString( attachmentId )
			net.Send( swep.Owner )
		else
			KLogf( 3, "Invalid weapon passed to FAS2:addAttachmentToWeapon %s", ( not IsValid( swep ) ) and "(Not Valid)" or "(Not FAS2)" )
			debug.Trace( )
		end
	end
end

if CLIENT then
	function FAS2:attachmentAddedToWeapon( swep, attachment )
		local attachmentId = attachment.AttachId
		local group
		for _, attachmentGroup in pairs( swep.Attachments ) do
			if table.HasValue( attachmentGroup.atts, attachmentId ) then
				group = attachmentGroup
			end
		end
		group.active = attachment.Name
		group.last = group.last or {}
		group.last[attachment.Name] = true
		
		local fasAttachmentTable = FAS2_Attachments[attachmentId]
		
		if fasAttachmentTable.aimpos then
			swep.AimPos = swep[fasAttachmentTable.aimpos]
			swep.AimAng = swep[fasAttachmentTable.aimang]
			swep.AimPosName = fasAttachmentTable.aimpos
			swep.AimAngName = fasAttachmentTable.aimang
		end
		
		local oldPlayAnim = FAS2_PlayAnim
		FAS2_PlayAnim = function( ) end
		
		if group.lastdeattfunc then
			group.lastdeattfunc(ply, wep)
		end
		
		if fasAttachmentTable.clattfunc then
			if IsValid( wep ) then
				fasAttachmentTable.clattfunc(ply, wep)
			end
		end
		
		FAS2_PlayAnim = oldPlayAnim
		
		group.lastdeattfunc = fasAttachmentTable.cldeattfunc
		
		swep:AttachBodygroup( attachmentId )
	end
	net.Receive( "PSL_FAS2_ATTACH", function( len )
		local weapon, attachmentId = net.ReadEntity( ), net.ReadString( )
		local attachment = PSLoadout.getAttachment( attachmentId )
		FAS2:attachmentAddedToWeapon( weapon, attachment )
	end )
end

--attachmentId and corresponding ITEM
function FAS2:addAttributes( ITEM )	
	local fasAttachmentTable = FAS2_Attachments[ITEM.ID]
	local attachmentTable = {
		Name = fasAttachmentTable.namefull,
		AttachId = ITEM.ID,
		Description = fasAttachmentTable.desc,
		TextureId = fasAttachmentTable.displaytexture,
		itemType = "attachment"
	}
	table.Merge( ITEM, attachmentTable ) --Add/overwrite default attributes
end 