local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local SSModules = SS:WaitForChild("Modules")
local RSModules = RS:WaitForChild("Modules")

local Config = require(RSModules:WaitForChild("Configuration"))

local HatchHandler = require(SSModules:WaitForChild("HatchHandler"))

local RobuxProcess = {}

function RobuxProcess:ProcessReceipt(receiptInfo)
	local Player = PL:GetPlayerByUserId(receiptInfo.PlayerId)
	local CurrencyType = "Robux"

	if not Player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if Player then
		local ProductIDInfo = Config.DevProducts[receiptInfo.ProductId]
		if ProductIDInfo then
			return RobuxProcess:CheckRobuxProducts(receiptInfo)
		end

		return RobuxProcess:CheckRobuxPet(receiptInfo)
	end

end

function RobuxProcess:CheckRobuxPet(receiptInfo)
	warn("Checking Robux Pet Products")
	return HatchHandler:BuyRobuxPet(receiptInfo)
end

function RobuxProcess:CheckRobuxProducts(receiptInfo)
	warn("Checking Robux Products")

	local ProductIDInfo = Config.DevProducts[receiptInfo.ProductId]
	if not ProductIDInfo then return end

	local Player = PL:GetPlayerByUserId(receiptInfo.PlayerId)

	local Source = Player:WaitForChild(ProductIDInfo.Source)
	local Currency = Source:WaitForChild(ProductIDInfo.Currency)

	if ProductIDInfo.Currency == "Clicks" then
		local leaderstats = Player:WaitForChild("leaderstats")
		local Rebirths = leaderstats:WaitForChild("Rebirths")
		
		Currency.Value += (ProductIDInfo.Value * Rebirths.Value)
	else
		Currency.Value += ProductIDInfo.Value
	end

	return true, "ShopProduct"

end

return RobuxProcess