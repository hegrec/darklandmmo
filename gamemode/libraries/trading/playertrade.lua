AddCSLuaFile("cl_playertrade.lua")
Trades = {}


attemptedTrades = {}
function PlayerTrade(pl,cmd,args)
	local otherPlayer = ents.GetByIndex(args[1])
	if !ValidEntity(otherPlayer) || !otherPlayer:IsPlayer() || !pl:CanReach(otherPlayer) || attemptedTrades[otherPlayer] || !otherPlayer:Alive() then return end
	if otherPlayer.TradingWith then return end
	if pl.TradingWith then return end
	if table.HasValue(attemptedTrades,otherPlayer) then return end
	
	
	umsg.Start("tradeAsk",otherPlayer)
		umsg.Entity(pl)
	umsg.End()
	
	umsg.Start("setTradeEnt",pl)
		umsg.Entity(otherPlayer)
	umsg.End()
	
	attemptedTrades[otherPlayer] = pl
	
end
concommand.Add("tradePlayer",PlayerTrade)


function TradeAsk(pl,cmd,args)

	if pl.TradingWith then return end
	
	local answer = args[1]
	local tradeStarter = attemptedTrades[pl]
	attemptedTrades[pl] = nil
	
	
	if answer == "yes" then
	
	
		pl.TradingWith = tradeStarter
		tradeStarter.TradingWith = pl
		
		
		pl:Freeze(true)
		tradeStarter:Freeze(true)
		
		Trades[pl] = {
			Money = 0,
			Items = {}
		}
		Trades[tradeStarter] = {
			Money = 0,
			Items = {}
		}
		
		
		local rf = RecipientFilter()
		rf:AddPlayer(tradeStarter)
		rf:AddPlayer(pl)
		umsg.Start("beginTrade",rf)
		umsg.End()
	end
end
concommand.Add("tradeAsk",TradeAsk)


function TradeSetMoney(pl,cmd,args)

	local amt = tonumber(args[1]) or 0
	
	if amt > pl:GetMoney() || amt < 1 then return end
	if !Trades[pl] then return end
	Trades[pl].Money = amt
	
	umsg.Start("ISetMoney",pl)
		umsg.Long(amt)
	umsg.End()
	
	umsg.Start("HeSetMoney",pl.TradingWith)
		umsg.Long(amt)
	umsg.End()


end
concommand.Add("tradeSetMoney",TradeSetMoney)


function RemoveTradeItem(pl,cmd,args)
	if !pl.TradingWith then return end
	
	
	local item
	for i,v in pairs(Trades[pl].Items) do	
		if v.ID == tonumber(args[1]) then
			Trades[pl].Items[i] = nil
			item = v
			break
		end
	end
	if !item then return end
	
	pl:AddItem(item)
	
	
	umsg.Start("IRemovedItem",pl)
		umsg.String(item.ID)
	umsg.End()
	
	umsg.Start("HeRemovedItem",pl.TradingWith)
		umsg.String(item.ID)
	umsg.End()
end
concommand.Add("removeTradeItem",RemoveTradeItem)

function AddTradeItem(pl,cmd,args)
	if !pl.TradingWith then return end
	
	
	local item = pl.Inventory[tonumber(args[1])]
	if !item then return end
	
	Trades[pl].Items[item.ID] = item
	
	local iId = item:Send(pl)

	umsg.Start("IAddedItem",pl)
		umsg.Long(iId)
	umsg.End()
	
	pl:TakeItem(item)
	
	local iId = item:Send(pl.TradingWith)
	
	umsg.Start("HeAddedItem",pl.TradingWith)
		umsg.Long(iId)
	umsg.End()
	
end
concommand.Add("addTradeItem",AddTradeItem)

function AcceptTrade(pl,cmd,args)
	
	local other = pl.TradingWith
	if !other then return end
	pl.AcceptedTrade = true
	umsg.Start("plyAcceptedTrade",other)
	umsg.End()
	if !pl.TradingWith.AcceptedTrade then return end
	
	
	pl:TakeMoney(Trades[pl].Money)
	pl:AddMoney(Trades[other].Money)
	for i,v in pairs(Trades[other].Items) do
		print(v)
		pl:AddItem(v)
	end
	other:TakeMoney(Trades[other].Money)
	other:AddMoney(Trades[pl].Money)
	for i,v in pairs(Trades[pl].Items) do
		print(v)
		pl:AddItem(v)
	end
	
	Trades[pl] = nil
	Trades[other] = nil
	
	pl.TradingWith = nil
	other.TradingWith = nil
	
	pl.AcceptedTrade = false
	other.AcceptedTrade = false
	
	pl:Freeze(false)
	other:Freeze(false)
	
	umsg.Start("canceledTrade",other)
	umsg.End()
	umsg.Start("canceledTrade",pl)
	umsg.End()
	
	


end
concommand.Add("acceptTrade",AcceptTrade)



function CancelTrade(pl,cmd,args)

	local other = pl.TradingWith
	if !other then return end
	--pl:AddMoney(Trades[pl].Money)
	for i,v in pairs(Trades[pl].Items) do
		pl:AddItem(i)
	end
	
	--other:AddMoney(Trades[other].Money)
	for i,v in pairs(Trades[other].Items) do
		other:AddItem(i)
	end
	
	Trades[pl] = nil
	Trades[other] = nil
	
	pl.TradingWith = nil
	other.TradingWith = nil
	
	
	pl.AcceptedTrade = false
	other.AcceptedTrade = false
	
	
	pl:Freeze(false)
	other:Freeze(false)
	
	umsg.Start("canceledTrade",other)
	umsg.End()
	
	


end
concommand.Add("cancelTrade",CancelTrade)