Wallet = class( "Wallet" )

Wallet.static.DB = "PSLoadout"
Wallet.static.model = {
	tableName = "psl_wallets",
	fields = {
		owner_id = "int",
		currency_id = "int",
		balance = "int"
	},
	belongsTo = {
		Owner = {
			class = "KPlayer",
			foreignKey = "owner_id"
		},
	}
}

Wallet:include( DatabaseModel )

function Wallet:getBalance( )
	return self.balance
end

function Wallet:giveAmount( plyTarget, amount, comment )
	return self.currencyProvider:performTransaction( 
		self, 
		plyTarget, 
		amount,
		comment )
end

function Wallet:canAfford( amount )
	if amount < 0 then return false end
	
	return self.balance >= amount
end