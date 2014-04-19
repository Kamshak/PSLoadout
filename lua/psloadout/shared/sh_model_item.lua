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
	--sqlite support
	local now = "NOW( )"
	local permanent = "1970-01-01 00:00:00"
	
	--MySQL support
	if not DATABASES[LoadoutItem.DB].CONNECTED_TO_MYSQL then
		now = "'now'"
		permanent = "0000-00-00 00:00:00"
	end
	return DATABASES[LoadoutItem.DB].DoQuery( Format( [[
		DELETE FROM %s 
		WHERE ( expirationTime != "%s" AND expirationTime < %s ) 
		AND owner_id = "%i" AND 0]],
		LoadoutItem.model.tableName,
		permanent,
		now,
		ply.kPlayerId ) )
end

function LoadoutItem:getTimeLeftString( )
	local timeleft = self:getTimeLeft( )

	if timeleft <= 0 then
		return "0s"
	end
	
	local weeks		= math.floor( timeleft / 604800 )
	local days		= math.floor( timeleft / 86400 - weeks * 7 )
	local hours 	= math.floor( timeleft / 3600 - days * 24 - weeks * 168  )
	local minutes	= math.floor( timeleft / 60 - hours * 60 - days * 1440 - weeks * 10080 )
	local seconds	= math.floor( timeleft / 60 - hours * 60 - days * 1440 - weeks * 10080 - minutes * 60 )
	
	local function splural( num, str )
		if num > 1 or num == 0 then
			return string.format( "%i %ss", num, str )
		else
			return string.format( "%i %s", num, str )
		end
	end
	
	if timeleft < 3600 then
		return string.format( "%s", splural( minutes, "minute" ) )
	elseif timeleft < 24 * 3600 then
		return string.format( "%s, %s", 
			splural( hours, "hour" ),
			splural( minutes, "minute" ) ) .. timeleft
	elseif timeleft < 7 * 24 * 3600 then
		return string.format( "%s, %s", 
			splural( days, "day" ),
			splural( hours, "hour" ) )
	else
		return string.format( "%s, %s",
			splural( weeks, "week" ),
			splural( days, "day" ) )
	end
		
end