local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local MS = game:GetService("MarketplaceService")
local PL = game:GetService("Players")
local RSS = game:GetService("RunService")

local LocalPlayer = PL.LocalPlayer

local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local Rebirths = leaderstats:WaitForChild("Rebirths")

local PlayerGui = LocalPlayer.PlayerGui
local MainGui = PlayerGui:WaitForChild("MainGui")
local MainFrames = MainGui:WaitForChild("MainFrames")
local CenterFrame_ = MainFrames:WaitForChild("CenterFrame"):WaitForChild("Frames")
local ShopFrame = CenterFrame_:WaitForChild("ShopFrame")
local SubFrame = ShopFrame:WaitForChild("SubFrame")
local ShopProductFrames = SubFrame:WaitForChild("ShopProductFrames")


local RSModules = RS:WaitForChild("Modules")
local Config = require(RSModules:WaitForChild("Configuration"))
local Notify = require(RSModules:WaitForChild("NotificationHandler"))
local Short = require(RSModules:WaitForChild("Short"))

local ShopHandler = {}

function ShopHandler:Init()
	ShopHandler:Listener()
end

function ShopHandler:Listener()
	
	RSS.Heartbeat:Connect(function()
		for a,b in pairs(CS:GetTagged("ClickShopProducts")) do
			if not b:IsA("TextButton") then continue end
			if not tonumber(b.Name) then continue end
			
			local PriceFrame = b:WaitForChild("PriceFrame")
			local ProdClicks = PriceFrame:WaitForChild("ProdClicks")
			local DevProdInfo = Config.DevProducts[tonumber(b.Name)]
			ProdClicks.Text = "+" .. Short.en((DevProdInfo.Value * Rebirths.Value) ).. " Clicks"
			
		end
		for a,b in pairs(CS:GetTagged("GemShopProducts")) do
			if not b:IsA("TextButton") then continue end
			if not tonumber(b.Name) then continue end

			local PriceFrame = b:WaitForChild("PriceFrame")
			local ProdClicks = PriceFrame:WaitForChild("ProdClicks")
			local DevProdInfo = Config.DevProducts[tonumber(b.Name)]
			
			ProdClicks.Text = "+" .. Short.en(DevProdInfo.Value).. " Gems"

		end
	end)
	
	for a,b in pairs(CS:GetTagged("ShopFrameButton")) do
		if not b:IsA("TextButton") then continue end
		b.MouseButton1Up:Connect(function()
			local TargetFrame = ShopProductFrames:FindFirstChild(b.Name .. "Frame")
			
			for c,d in pairs(ShopProductFrames:GetChildren()) do
				if not d:IsA("Frame") then continue end
				if d.Name == b.Name .. "Frame" then
					d.Visible = true
				else
					d.Visible = false
				end
			end
			
		end)
	end
	
	for a,b in pairs(CS:GetTagged("ProductButton")) do
		if not b:IsA("TextButton") then continue end
		if not tonumber(b.Name) then b.Visible = false continue end

		b.MouseButton1Up:Connect(function()
			MS:PromptProductPurchase(LocalPlayer,tonumber(b.Name))
		end)
	end
	
	ShopHandler:LoadShopProducts()
end

function ShopHandler:LoadShopProducts()
	for a,b in pairs(CS:GetTagged(Config.Tags.GamepassButton)) do

		if not b:IsA("TextButton") then continue end
		if not tonumber(b.Name) then continue end
			local function isOwn(gamepassID)
				local suc,isOwned = pcall(function()
					MS:UserOwnsGamePassAsync(LocalPlayer.UserId,gamepassID)
				end)
				if not suc then return false end
				if isOwned then return true end
				return false
			end

			local GamepassInfo = MS:GetProductInfo(tonumber(b.Name),Enum.InfoType.GamePass)

			b:WaitForChild("GamepassName").Text = GamepassInfo.Name
			b:WaitForChild("GamepassDesc").Text = GamepassInfo.Description
			b:WaitForChild("GamepassIcon").Image = "rbxassetid://" .. GamepassInfo.IconImageAssetId

			b:WaitForChild("PriceFrame"):WaitForChild("GamepassPrice").Text =  isOwn(tonumber(b.Name)) and "Owned" or "R$" .. GamepassInfo.PriceInRobux
	end
	
	ShopHandler:ActivateGamepass()
	
	for a,b in pairs(CS:GetTagged("ShopProducts")) do
		if not b:IsA("TextButton") then continue end
		if not tonumber(b.Name) then b.Visible = false continue end
			local ShopProductInfo = MS:GetProductInfo(tonumber(b.Name),Enum.InfoType.Product)

			local ProdPrice = b:WaitForChild("ProdPrice")

			ProdPrice.Text = ShopProductInfo.PriceInRobux .. " R$"
	end
	
	ShopHandler:ActivateShopProducts()

end

function ShopHandler:ActivateGamepass()
	for a,b in pairs(CS:GetTagged(Config.Tags.GamepassButton)) do
		if not b:IsA("TextButton") then continue end
		if not tonumber(b.Name) then continue end
		b.MouseButton1Up:Connect(function()
			ShopHandler:PromptGamepass(tonumber(b.Name))
		end)
	end
end

function ShopHandler:ActivateShopProducts()
	for a,b in pairs(CS:GetTagged("ShopProducts")) do
		if not b:IsA("TextButton") then continue end
		if not tonumber(b.Name) then b.Visible = false continue end

		b.MouseButton1Up:Connect(function()
			MS:PromptProductPurchase(LocalPlayer,tonumber(b.Name))
		end)
	end
end

function ShopHandler:PromptGamepass(GamepassId)
	if MS:UserOwnsGamePassAsync(LocalPlayer.UserId,GamepassId) then Notify:Notify("You already own this gamepass!") return end
	MS:PromptGamePassPurchase(LocalPlayer,GamepassId)
end

return ShopHandler
