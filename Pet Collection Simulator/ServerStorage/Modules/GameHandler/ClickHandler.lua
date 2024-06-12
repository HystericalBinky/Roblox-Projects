local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local MS = game:GetService("MarketplaceService")

local RSModules = RS:WaitForChild("Modules")
local Config = require(RSModules:WaitForChild("Configuration"))

local ClickHandler = {}

function ClickHandler:updateClickEvents()
	for _,b in pairs(CS:GetTagged(Config.Tags.ClickEventTag)) do
		if b:IsA("RemoteEvent") then
			b.OnServerEvent:Connect(function(Player)
				ClickHandler:givePlayerClicks(Player)
			end)
		end
	end
end

function ClickHandler:givePlayerClicks(Player)
	local leaderstats = Player:WaitForChild("leaderstats")
	local otherstats = Player:WaitForChild("otherstats") 
	local upgradestats = Player:WaitForChild("upgradestats")

	local Rebirths = leaderstats:WaitForChild("Rebirths")
	local World = otherstats:WaitForChild("World")
	local Friend_Boost = otherstats:WaitForChild("Friend Boost")
	local PetMultiplier = otherstats:WaitForChild("PetMultiplier")
	local ClickUpgradeMultiplier = upgradestats:WaitForChild("ClickMultiplier")

	local Clicks = leaderstats:WaitForChild("Clicks")
	local Total_Clicks = otherstats:WaitForChild("Total Clicks")
	
	local GamepassINT = otherstats:WaitForChild("Gamepass")
	
	local perClick = GamepassINT:GetAttribute("ClickGamepass")

	local World_Boost = World:GetAttribute("Boost")

	local M1_ = perClick * Friend_Boost.Value
	local M2_ = perClick * World_Boost
	
	local M3_ = (M1_ + M2_) * PetMultiplier.Value
	local M4_ = (M1_ + M2_) * Rebirths.Value
	
	local clickValue = (M3_ + M4_) * ClickUpgradeMultiplier.Value

	Clicks.Value += clickValue
	Total_Clicks.Value += clickValue

end

return ClickHandler
