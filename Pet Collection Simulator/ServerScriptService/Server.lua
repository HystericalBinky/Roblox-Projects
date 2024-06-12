local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local MS = game:GetService("MarketplaceService")
local PL = game:GetService("Players")

local SSModules = SS:WaitForChild("Modules")
local RSModules = RS:WaitForChild("Modules")
local RSEvents = RS:WaitForChild("Events")

local DataHandler = require(SSModules:WaitForChild("DataHandler"))
local GameHandler = require(SSModules:WaitForChild("GameHandler"))
local RobuxPurchaseHandler = require(SSModules:WaitForChild("RobuxPurchaseHandler"))
local HatchHandler = require(SSModules:WaitForChild("HatchHandler"))
local Config = require(RSModules:WaitForChild("Configuration"))

local RequestEgg = RSEvents:WaitForChild("RequestEgg")

DataHandler:Init()
GameHandler:Init()

local function ProcessReceipt(receiptInfo)
	local isSuccess, Result = RobuxPurchaseHandler:ProcessReceipt(receiptInfo)
	local Player = PL:GetPlayerByUserId(receiptInfo.PlayerId)
	if isSuccess then
		if Result == "ShopProduct" then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			RequestEgg:InvokeClient(Player,isSuccess,Result)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
end
local timesTriggered = 0

local function getEggData(Player,Egg,HatchCount)
	timesTriggered += 1
	print("Times Triggered: " .. timesTriggered)
	local EggData = Config.EggModule[Egg.Name]
	if HatchCount == "Single" then
		return HatchHandler:BuyPet(Player,Egg,EggData,1)
	elseif HatchCount == "Triple" then
		return HatchHandler:BuyPet(Player,Egg,EggData,3)
	elseif HatchCount == "Octuple" then
		return HatchHandler:BuyPet(Player,Egg,EggData,8)
	end
	warn("This shouldn't be printed!!!!")
end

RequestEgg.OnServerInvoke = getEggData
MS.ProcessReceipt = ProcessReceipt