local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local MS = game:GetService("MarketplaceService")
local RSModules = RS:WaitForChild("Modules")

local Config = require(RSModules:WaitForChild("Configuration"))
local Short = require(RSModules:WaitForChild("Short"))

local PortalLoader = {}

function PortalLoader:Load()
	warn("Loading")
	for a,b in pairs(CS:GetTagged(Config.Tags.ExportPortal)) do
		local Att = b:FindFirstChild("Att")
		if not Att then continue end
		local BGUI = Att:FindFirstChild("BillboardGui")
		if not BGUI then continue end
		local PortalName = BGUI:FindFirstChild("Name")
		if not PortalName then continue end
		local PortalPrice = BGUI:FindFirstChild("Price")
		if not PortalPrice then continue end
		local WorldData = Config.Worlds[b:GetAttribute("World")]
		if not WorldData then continue end
		
		PortalName.Text = tostring(b:GetAttribute("World"))
		
		if WorldData.Type == "Currency" then
			PortalPrice.Text = Short.en(WorldData.Price) .. " " .. WorldData.Currency
		elseif WorldData.Type == "Rebirths" then
			PortalPrice.Text = Short.en(WorldData.Price) .. " rebirths"
		elseif WorldData.Type == "Gamepass" then
			local GamepassInfo = MS:GetProductInfo(WorldData.Id, Enum.InfoType.GamePass)
			if not GamepassInfo then continue end
			PortalPrice.Text = GamepassInfo.Name .. " gamepass"
		end
		warn(b:GetAttribute("World") .. " loaded!")
	end
end

return PortalLoader