local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local MS = game:GetService("MarketplaceService")
local RSModules = RS:WaitForChild("Modules")

local Config = require(RSModules:WaitForChild("Configuration"))
local Short = require(RSModules:WaitForChild("Short"))
local EggHandler = {}

function EggHandler:LoadEggPrice()
	for a,b in pairs(CS:GetTagged("EggPriceLabel")) do
		local EggName = b.Parent.Parent.Parent.Parent.Name
		
		local EggData = Config.EggModule[EggName]
		if not EggData then warn("Egg Data not exist: " .. b.Name) continue end
		local CurrentCurrencyImage = Config.CurrencyImages[EggData.Currency]
		if not CurrentCurrencyImage then continue end
		local CurrencyImage = b.Parent:FindFirstChild("CurrencyImage")
		if not CurrencyImage then continue end
		CurrencyImage.Image = CurrentCurrencyImage

		if EggData.Currency == "Robux" then
			--[[if not EggData.ProductId then continue end
			
			local ProductInfo = MS:GetProductInfo(EggData.ProductId)
			task.wait(1)
			b.Text = ProductInfo and ProductInfo.PriceInRobux or "Loading..."]]
			b.Text = Short.en(EggData.Cost)
			
		else
			b.Text = Short.en(EggData.Cost)
		end
		
	end
	warn("All egg price loaded!")
end

return EggHandler