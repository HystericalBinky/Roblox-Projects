local UpgradesHandler = {}

local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local CS = game:GetService("CollectionService")

local RSEvents = RS:WaitForChild("Events")
local SSModules = SS:WaitForChild("Modules")

local UpgradeSuccess = RSEvents:WaitForChild("UpgradeSuccess")
local UpgradeFail = RSEvents:WaitForChild("UpgradeFail")

local GamepassHandler = require(SSModules:WaitForChild("DataHandler"):WaitForChild("GamepassHandler"))

function UpgradesHandler:check(Player, TokenAmount, UpgradeType)
	local leaderstats = Player:WaitForChild("leaderstats")
	local Tokens = leaderstats:WaitForChild("Tokens")
	if TokenAmount <= Tokens.Value then
		Tokens.Value -= TokenAmount
		UpgradesHandler:giveUpgrade(Player, 1, UpgradeType)
	else
		UpgradeFail:FireClient(Player)
		warn("Player does not have enough!")
	end
end

function UpgradesHandler:giveUpgrade(Player, UpgradeAmount, UpgradeType)
	local leaderstats = Player:WaitForChild("leaderstats")
	local otherstats = Player:WaitForChild("otherstats")
	local upgradestats = Player:WaitForChild("upgradestats")
	
	local ClickMultiplier = upgradestats:WaitForChild("ClickMultiplier")
	local ExtraEquips = upgradestats:WaitForChild("ExtraEquips")
	local ExtraStorage = upgradestats:WaitForChild("ExtraStorage")
	local RebirthCost = upgradestats:WaitForChild("RebirthCost")

	if UpgradeType == 1 then
		if ClickMultiplier.Value == 1 then
			ClickMultiplier.Value = 1.33
		elseif ClickMultiplier.Value == 1.33 then
			ClickMultiplier.Value = 1.66
		elseif ClickMultiplier.Value == 1.66 then
			ClickMultiplier.Value = 1.99
		else
			warn("Invalid ClickMultiplier!")
		end
	elseif UpgradeType == 2 then
		ExtraEquips.Value += 1
	elseif UpgradeType == 3 then
		RebirthCost.Value -= 0.1
	elseif UpgradeType == 4 then
		ExtraStorage.Value += 5
	else
		warn("Invalid Upgrade!")
	end
	
	GamepassHandler:UpdateGamepassFeatures(Player)
	UpgradeSuccess:FireClient(Player)
end

return UpgradesHandler