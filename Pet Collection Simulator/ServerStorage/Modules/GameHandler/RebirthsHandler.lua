local RebirthsHandler = {}

local RS = game:GetService("ReplicatedStorage")
local MS = game:GetService("MarketplaceService")

local RSModules = RS:WaitForChild("Modules")
local Config = require(RSModules:WaitForChild("Configuration"))


function RebirthsHandler:checkPlayer(Player)
	local leaderstats = Player:WaitForChild("leaderstats")
	local otherstats = Player:WaitForChild("otherstats")
	local upgradestats = Player:WaitForChild("upgradestats")
	
	local Clicks = leaderstats:WaitForChild("Clicks")
	local Rebirths = leaderstats:WaitForChild("Rebirths")
	local Gems = leaderstats:WaitForChild("Gems") 
	local RebirthCostUpgrade = upgradestats:WaitForChild("RebirthCost")
	
	local TotalGems = otherstats:WaitForChild("Total Gems")
	local GamepassINT = otherstats:WaitForChild("Gamepass")
	local PetMultiplier = otherstats:WaitForChild("PetMultiplier")
	
	local RebirthData = Config.RebirthSettings
	local RebirthPrice = ((RebirthData.RebirthPrice * (1.5 ^ Rebirths.Value)) * RebirthData.PriceMultiplier) * RebirthCostUpgrade.Value
	
	if Clicks.Value >= RebirthPrice then
		--Deduct Price & Add Rebirth
		Clicks.Value -= RebirthPrice
		Rebirths.Value += GamepassINT:GetAttribute("RebirthGamepass")
		
		--Clear Gems & Clicks
		Clicks.Value = 0
		
		Gems.Value += ((((RebirthData.BaseGems * Rebirths.Value) * RebirthData.PriceMultiplier) + PetMultiplier:GetAttribute("PetMultiplier2")) * GamepassINT:GetAttribute("GemsGamepass"))
		TotalGems.Value += ((((RebirthData.BaseGems * Rebirths.Value) * RebirthData.PriceMultiplier) + PetMultiplier:GetAttribute("PetMultiplier2")) * GamepassINT:GetAttribute("GemsGamepass"))
		
		return RebirthsHandler:clearWorlds(Player)
	else
		local MSG = "❗ You need %s more clicks to rebirth!"
		local RemainingRebirths = RebirthPrice - Clicks.Value
		return false, MSG:format(RemainingRebirths)
	end
end

function RebirthsHandler:clearWorlds(Player)
	warn("Clearing Worlds")
	local worldstats = Player:WaitForChild("worldstats")
	for a,b in pairs(worldstats:GetChildren()) do
		if not b:IsA("BoolValue") then continue end
		if b.Name == "Lobby" then continue end
		print("Deleted world: " .. b.Name)
		b:Destroy()
	end
	
	
	return true, "Rebirth Successful!"
end


return RebirthsHandler
