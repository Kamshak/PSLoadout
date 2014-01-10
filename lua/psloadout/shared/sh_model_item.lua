LoadoutItem = class( "Item" )
PSLoadout.LoadoutItem = LoadoutItem

LoadoutItem.static.DB = "PSLoadout"
LoadoutItem.static.model = {
	tableName = "psl_items",
	fields = {
		owner_id = "int",
		itemclass = "string",
		expirationTime = "time",
		created_at = "createdTime",
		updated_at = "updatedTime",
		txnId = "int",
	},
	/*belongsTo = {
		Owner = {
			class = "KPlayer",
			foreignKey = "owner_id"
		},
	}*/
}
LoadoutItem:include( DatabaseModel )

function LoadoutItem:isExpired( )
	if not self.expirationTime or self.expirationTime == 0 then
		return false
	end
	if self:getTimeLeft( ) <= 0 then
		return true
	end
	return false
end

function LoadoutItem:isPermanent( )
	return self.expirationTime == 0
end

function LoadoutItem:getTimeLeft( )
	local dif = os.difftime( os.time( ), self.expirationTime )
	return self.expirationTime - os.time( )
end

function LoadoutItem.static.getOwnedAndValid( ply )
	local now = "NOW( )"
	if not DATABASES[LoadoutItem.DB].CONNECTED_TO_MYSQL then
		now = "'now'"
	end
	return self:getDbEntries( string.format( "WHERE ( expirationTime = \"0000-00-00 00:00:00\" OR expirationTime > %s ) AND owner_id = %i", now, ply.kPlayerId ) )
end

function LoadoutItem.static.clearExpiredItems( ply )
	local now = "NOW( )"
	if not DATABASES[LoadoutItem.DB].CONNECTED_TO_MYSQL then
		now = "'now'"
	end
	return DATABASES[LoadoutItem.DB].DoQuery( Format( [[
		DELETE FROM %s 
		WHERE ( expirationTime != "0000-00-00 00:00:00" AND expirationTime < %s ) 
		AND owner_id = "%i"]],
		LoadoutItem.model.tableName,
		now, --sqlite support
		ply.kPlayerId ) )
end

function LoadoutItem:getTimeLeftString( )
	local timeleft = self:getTimeLeft( )

	if timeleft <= 0 then
		return "0s"
	end
	
	local diffTbl = os.date( "*t", timeleft )
	--need to do this because of epoch start
	diffTbl.day = diffTbl.day - 1
	diffTbl.year = diffTbl.year - 1970
	diffTbl.month = diffTbl.month - 1
	diffTbl.hour = diffTbl.hour - 1
	
	local function splural( num, str )
		if num > 1 or num == 0 then
			return string.format( "%i %ss", num, str )
		else
			return string.format( "%i %s", num, str )
		end
	end
	
	if timeleft < 3600 then
		return string.format( "%s", splural( diffTbl.min, "minute" ) )
	elseif timeleft < 24 * 3600 then
		return string.format( "%s, %s", 
			splural( diffTbl.hour, "hour" ),
			splural( diffTbl.min, "minute" ) )
	elseif timeleft < 7 * 24 * 3600 then
		return string.format( "%s, %s", 
			splural( diffTbl.day, "day" ),
			splural( diffTbl.hour, "hour" ) )
	else
		diffTbl.week = math.floor( diffTbl.day / 7 )
		diffTbl.day = diffTbl.day % 7
		return string.format( "%s, %s",
			splural( diffTbl.week, "week" ),
			splural( diffTbl.day, "day" ) )
	end
		
end