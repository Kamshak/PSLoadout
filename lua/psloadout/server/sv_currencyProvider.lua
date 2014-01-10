CurrencyProvider = class( "CurrencyProvider" )
CurrencyProvider:include( Singleton )

--create required db stuff etc.
function CurrencyProvider:initialize( )
end

function CurrencyProvider:getPlayerWallet( ply )
	error( "Not implemented" ) 
end

function CurrencyProvider:fund( wallet, amount, source )
	error( "Not implemented" ) 
end

function CurrencyProvider:performTransaction( 
	sourceWallet, 
	destinationWallet, 
	amount,
	comment )
	error( "Not implemented" ) 
end

function CurrencyProvider:getServerWallet( )
	error( "Not implemented" ) 
end