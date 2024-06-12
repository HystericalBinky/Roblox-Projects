local TokenConvertHandler = {}

function TokenConvertHandler:check(Player,ClickAmount)
	local leaderstats = Player:WaitForChild("leaderstats")
	local Clicks = leaderstats:WaitForChild("Clicks")
	if ClickAmount <= Clicks.Value then
		Clicks.Value -= ClickAmount
		TokenConvertHandler:givePlayer(Player,ClickAmount)
	else
		warn("Player entered invalid amount!")
	end
end

function TokenConvertHandler:givePlayer(Player,ClickAmount)
	local leaderstats = Player:WaitForChild("leaderstats")
	local otherstats = Player:WaitForChild("otherstats")
	local Tokens = leaderstats:WaitForChild("Tokens")
	local TotalToken = otherstats:WaitForChild("Total Tokens")	
	local TokenAmount = math.floor(ClickAmount/2)
	
	Tokens.Value += TokenAmount
	TotalToken.Value += TokenAmount
end

return TokenConvertHandler
